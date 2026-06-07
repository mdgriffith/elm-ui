module Internal.Teleport exposing
    ( persistentClass, persistentId
    , encodeParentTrigger, encodeChildReaction
    , Box, CssAnimation, Data(..), Event, ParentTriggerDetails, Trigger(..), decode, encodeCss, encodeFocusOnHover, reactionPropertyName, stringToTrigger
    )

{-| This is data that is teleported to the central state.

@docs persistentClass, persistentId

@docs encodeParentTrigger, encodeChildReaction

-}

import Animator
import Json.Decode as Decode
import Json.Encode as Encode


persistentClass : String -> String -> String
persistentClass group instance =
    "elm-ui-persistent-" ++ group ++ "-" ++ instance


persistentId : String -> String -> Encode.Value
persistentId group instance =
    Encode.object
        [ ( "group", Encode.string group )
        , ( "instance", Encode.string instance )
        ]



-- ENCODER


encodeCss : String -> String -> Animator.Css -> Encode.Value
encodeCss trigger keyframesHash css =
    let
        -- If this is a transition (meanining no keyframes)
        -- Then we need to render the props as !important
        -- If there are keyframes, then the props can't be !important
        -- or else they'll clobber the animation
        noKeyframes =
            String.isEmpty css.keyframes
    in
    Encode.object
        [ ( "type", Encode.string "css" )
        , ( "trigger", Encode.string trigger )
        , ( "hash", Encode.string css.hash )
        , ( "keyframesHash", Encode.string keyframesHash )
        , ( "keyframes", Encode.string css.keyframes )
        , ( "transition", Encode.string css.transition )
        , ( "props", Encode.list (encodeProp noKeyframes) css.props )
        ]


encodeProp : Bool -> ( String, String ) -> Encode.Value
encodeProp asImportant ( key, value ) =
    Encode.object
        [ ( "key", Encode.string key )
        , ( "value"
          , if asImportant then
                --  this works for hover but not for intro
                Encode.string (value ++ " !important")

            else
                Encode.string value
          )
        ]


encodeParentTrigger : String -> String -> Encode.Value
encodeParentTrigger trigger identifierClass =
    Encode.object
        [ ( "type", Encode.string "parentTrigger" )
        , ( "trigger", Encode.string trigger )
        , ( "identifierClass", Encode.string identifierClass )
        ]


encodeChildReaction : String -> String -> String -> Animator.Css -> Encode.Value
encodeChildReaction triggerPseudoclass identifierClass keyframeHash css =
    encodeCss triggerPseudoclass keyframeHash css


encodeFocusOnHover : String -> Encode.Value
encodeFocusOnHover htmlId =
    Encode.object
        [ ( "type", Encode.string "focusOnHover" )
        , ( "id", Encode.string htmlId )
        ]



-- DECODER


type Data
    = Css CssAnimation
    | ParentTrigger ParentTriggerDetails
    | FocusOnHover String


type Trigger
    = OnHover
    | OnRender
    | OnFocus
    | OnFocusWithin
    | OnActive
    | OnDismount


stringToTrigger : String -> Maybe Trigger
stringToTrigger str =
    case str of
        "on-rendered" ->
            Just OnRender

        "on-focused" ->
            Just OnRender

        "on-hovered" ->
            Just OnHover

        "on-focused-within" ->
            Just OnFocusWithin

        _ ->
            Nothing


type alias Box =
    { x : Float
    , y : Float
    , width : Float
    , height : Float
    }


type alias Event =
    { timestamp : Float
    , data : List Data
    }


decode : Decode.Decoder Event
decode =
    Decode.map2 Event
        (Decode.field "timeStamp" Decode.float)
        (Decode.oneOf
            [ Decode.field "target"
                (Decode.field "data-elm-ui"
                    (Decode.list decodeCssData)
                )
            , Decode.field "target"
                (Decode.field "data-elm-ui"
                    (Decode.map2
                        (\trigger identifierClass ->
                            { trigger = trigger
                            , identifierClass = identifierClass
                            }
                        )
                        (Decode.field "trigger" Decode.string)
                        (Decode.field "identifierClass" Decode.string)
                    )
                    |> Decode.andThen
                        (\idents ->
                            Decode.map
                                (\cssChildren ->
                                    [ ParentTrigger <|
                                        ParentTriggerDetails
                                            idents.trigger
                                            idents.identifierClass
                                            cssChildren
                                    ]
                                )
                                (Decode.field "parentNode"
                                    (decodeCssChildren idents.identifierClass)
                                )
                        )
                )
            ]
        )


decodeCssData : Decode.Decoder Data
decodeCssData =
    Decode.field "type" Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "css" ->
                        Decode.map Css decodeCss

                    "focusOnHover" ->
                        Decode.map FocusOnHover (Decode.field "id" Decode.string)

                    _ ->
                        Decode.fail ("Unknown type: " ++ str)
            )


{-| Parent triggers are never disabled, because the children may have changed their animation in some way.
-}
type alias ParentTriggerDetails =
    { trigger : String

    -- The unique identifier provided by the user
    , identifierClass : String
    , children : List CssAnimation
    }


type alias CssAnimation =
    { trigger : String
    , hash : String
    , keyframesHash : String
    , keyframes : String
    , transition : String
    , props : List ( String, String )
    }


decodeCss : Decode.Decoder CssAnimation
decodeCss =
    Decode.map6 CssAnimation
        (Decode.field "trigger" Decode.string)
        (Decode.field "hash" Decode.string)
        (Decode.field "keyframesHash" Decode.string)
        (Decode.field "keyframes" Decode.string)
        (Decode.field "transition" Decode.string)
        (Decode.field "props" (Decode.list decodeProp))


decodeProp : Decode.Decoder ( String, String )
decodeProp =
    Decode.map2 (\key value -> ( key, value ))
        (Decode.field "key" Decode.string)
        (Decode.field "value" Decode.string)


reactionPropertyName : String -> String
reactionPropertyName identifier =
    "data-elm-ui-reaction-" ++ identifier


decodeTriggeredChild : String -> Decode.Decoder (List CssAnimation)
decodeTriggeredChild identifier =
    Decode.oneOf
        [ Decode.field (reactionPropertyName identifier)
            (Decode.list decodeCss)
        , Decode.succeed []
        ]


decodeCssChildren : String -> Decode.Decoder (List CssAnimation)
decodeCssChildren identifier =
    decodeTriggeredChild identifier
        |> Decode.andThen
            (\triggeredChildren ->
                case triggeredChildren of
                    [] ->
                        -- No children found, keep searching
                        Decode.map2
                            (++)
                            (Decode.field "nextElementSibling"
                                (Decode.oneOf
                                    [ Decode.null []
                                    , Decode.lazy
                                        (\_ ->
                                            decodeCssChildren identifier
                                        )
                                    ]
                                )
                            )
                            (Decode.field "firstElementChild"
                                (Decode.oneOf
                                    [ Decode.null []
                                    , Decode.lazy
                                        (\_ ->
                                            decodeCssChildren identifier
                                        )
                                    ]
                                )
                            )

                    nonEmpty ->
                        -- We've found something
                        -- let's skip searching its children
                        -- but lets continue searching its siblings
                        Decode.map
                            (\next ->
                                nonEmpty ++ next
                            )
                            (Decode.field "nextElementSibling"
                                (Decode.oneOf
                                    [ Decode.null []
                                    , Decode.lazy
                                        (\_ ->
                                            decodeCssChildren identifier
                                        )
                                    ]
                                )
                            )
            )
