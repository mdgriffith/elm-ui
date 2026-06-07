module Internal.Model2 exposing (..)

import Browser.Dom
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Html.Keyed
import Html.Lazy
import Internal.BitField as BitField
import Internal.Bits.Analyze as AnalyzeBits
import Internal.Bits.Inheritance as Inheritance
import Internal.Flag as Flag exposing (Flag)
import Internal.Style2 as Style
import Internal.Teleport as Teleport
import Json.Decode as Json
import Json.Encode as Encode
import Set exposing (Set)
import Task
import Time
import VirtualDom


{-| -}
type Element msg
    = Element (Inheritance.Encoded -> Html.Html msg)


unwrap : Inheritance.Encoded -> Element msg -> Html.Html msg
unwrap inheritance (Element fn) =
    fn inheritance


map : (a -> b) -> Element a -> Element b
map fn el =
    case el of
        Element elem ->
            Element
                (\s ->
                    Html.map fn (elem s)
                )


type Msg
    = Tick Time.Posix
    | Teleported Teleport.Trigger Teleport.Event
    | Focused (Result Browser.Dom.Error ())


type State
    = State
        { added : Set String
        , rules : List String
        , keyframes : List String
        }


type alias Box =
    { x : Float
    , y : Float
    , width : Float
    , height : Float
    }


update : (Msg -> msg) -> Msg -> State -> ( State, Cmd msg )
update toAppMsg msg ((State details) as unchanged) =
    case msg of
        Tick _ ->
            ( unchanged, Cmd.none )

        Focused _ ->
            ( unchanged, Cmd.none )

        Teleported trigger teleported ->
            let
                ( updated, cmds ) =
                    List.foldl
                        (applyTeleported teleported)
                        ( unchanged, [] )
                        teleported.data
            in
            ( updated
            , Cmd.map toAppMsg (Cmd.batch cmds)
            )


addChildReactions : Teleport.ParentTriggerDetails -> List Teleport.CssAnimation -> State -> ( State, List (Cmd Msg) )
addChildReactions parent anims ((State state) as untouched) =
    case anims of
        [] ->
            ( untouched, [] )

        css :: remaining ->
            if Set.member css.hash state.added then
                addChildReactions parent remaining untouched

            else
                -- The key difference between this renderer and the one in applyTeleported
                -- is that this one does *not* disable the trigger element
                -- Because the parent that fired the trigger doesn't know if the child changed in some way.
                let
                    cssClass =
                        -- "." ++ css.hash ++ css.trigger ++ "{" ++ addStylesToString css.props "" ++ "}"
                        ("." ++ parent.identifierClass ++ css.trigger ++ " ." ++ css.hash)
                            ++ ("{" ++ addStylesToString css.props "" ++ "}")

                    keyframes =
                        if Set.member css.keyframesHash state.added then
                            state.keyframes

                        else
                            state.keyframes
                                |> addRule css.keyframes
                in
                addChildReactions parent
                    remaining
                    (State
                        { state
                            | rules =
                                state.rules
                                    |> addRule cssClass
                            , keyframes = keyframes
                            , added =
                                state.added
                                    |> Set.insert css.hash
                                    |> Set.insert css.keyframesHash
                        }
                    )


applyTeleported : Teleport.Event -> Teleport.Data -> ( State, List (Cmd Msg) ) -> ( State, List (Cmd Msg) )
applyTeleported event data ( (State state) as untouched, cmds ) =
    case data of
        Teleport.ParentTrigger parentTrigger ->
            addChildReactions parentTrigger parentTrigger.children untouched

        Teleport.Css css ->
            if Set.member css.hash state.added then
                ( untouched, cmds )

            else
                let
                    cssClass =
                        "." ++ css.hash ++ css.trigger ++ "{" ++ addStylesToString css.props "" ++ "}"

                    disableTrigger =
                        "." ++ css.hash ++ "." ++ Style.classes.trigger ++ "{ display: none; }"

                    keyframes =
                        if Set.member css.keyframesHash state.added then
                            state.keyframes

                        else
                            state.keyframes
                                |> addRule css.keyframes
                in
                ( State
                    { state
                        | rules =
                            state.rules
                                |> addRule cssClass
                                |> addRule disableTrigger
                        , keyframes = keyframes
                        , added =
                            state.added
                                |> Set.insert css.hash
                                |> Set.insert css.keyframesHash
                    }
                , cmds
                )

        Teleport.FocusOnHover htmlId ->
            ( untouched
            , Task.attempt Focused (Browser.Dom.focus htmlId) :: cmds
            )


addRule : String -> List String -> List String
addRule rule existingRules =
    if rule == "" then
        existingRules

    else
        rule :: existingRules


type alias Transform =
    { scale : Float
    , x : Float
    , y : Float
    , rotation : Float
    }


emptyTransform : Transform
emptyTransform =
    { scale = 1
    , x = 0
    , y = 0
    , rotation = 0
    }


mapAttr : (a -> b) -> Attribute a -> Attribute b
mapAttr fn (Attribute attrList) =
    Attribute
        (List.map
            (\{ flag, attr } ->
                { flag = flag
                , attr =
                    { node = attr.node
                    , additionalInheritance = attr.additionalInheritance
                    , attrs = List.map (Attr.map fn) attr.attrs
                    , class = attr.class
                    , styles = attr.styles
                    , nearby =
                        List.map (\( loc, elem ) -> ( loc, map fn elem )) attr.nearby
                    }
                }
            )
            attrList
        )


type Layout
    = AsRow
    | AsColumn
    | AsEl
    | AsGrid
    | AsParagraph
    | AsTextColumn
    | AsRoot


noAttr : Attribute msg
noAttr =
    Attribute
        [ { flag = Flag.skip
          , attr =
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Nothing
                , styles = noStyles
                , nearby = []
                }
          }
        ]


justFlag : Flag -> Attribute msg
justFlag flag =
    Attribute
        [ { flag = flag
          , attr =
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Nothing
                , styles = noStyles
                , nearby = []
                }
          }
        ]


nearby : Location -> Element msg -> Attribute msg
nearby loc el =
    Attribute
        [ { flag = Flag.skip
          , attr =
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Nothing
                , styles = noStyles
                , nearby = [ ( loc, el ) ]
                }
          }
        ]


teleport :
    { trigger : String
    , class : String
    , style : List ( String, String )
    , data : Encode.Value
    }
    -> Attribute msg
teleport options =
    Attribute
        [ { flag = Flag.skip
          , attr =
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Just (options.class ++ " " ++ options.trigger)
                , styles =
                    \_ _ ->
                        options.style
                , nearby =
                    [ ( Trigger
                      , Element
                            (\_ ->
                                Html.div
                                    [ Attr.class (options.class ++ " " ++ Style.classes.trigger)
                                    , Attr.property "data-elm-ui" (Encode.list identity [ options.data ])
                                    , Attr.style "pointer-events" "none"
                                    ]
                                    []
                            )
                      )
                    ]
                }
          }
        ]


teleportTrigger :
    { trigger : String
    , identifierClass : String
    }
    -> Attribute msg
teleportTrigger options =
    Attribute
        [ { flag = Flag.skip
          , attr =
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Just (options.trigger ++ " " ++ options.identifierClass)
                , styles =
                    \_ _ ->
                        []
                , nearby =
                    [ ( Trigger
                      , Element
                            (\_ ->
                                Html.div
                                    [ Attr.class Style.classes.trigger
                                    , Attr.property "data-elm-ui"
                                        (Teleport.encodeParentTrigger
                                            options.trigger
                                            options.identifierClass
                                        )
                                    , Attr.style "pointer-events" "none"
                                    ]
                                    []
                            )
                      )
                    ]
                }
          }
        ]


teleportReaction :
    { trigger : String
    , identifierClass : String
    , class : String
    , style : List ( String, String )
    , data : Encode.Value
    }
    -> Attribute msg
teleportReaction options =
    Attribute
        [ { flag = Flag.skip
          , attr =
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Just options.class
                , styles =
                    \_ _ ->
                        options.style
                , nearby =
                    [ ( Trigger
                      , Element
                            (\_ ->
                                Html.div
                                    [ Attr.class (options.class ++ " " ++ Style.classes.trigger)
                                    , Attr.property
                                        (Teleport.reactionPropertyName options.identifierClass)
                                        (Encode.list identity [ options.data ])
                                    , Attr.style "pointer-events" "none"
                                    ]
                                    []
                            )
                      )
                    ]
                }
          }
        ]


noStyles :
    Inheritance.Encoded
    -> AnalyzeBits.Encoded
    -> List ( String, String )
noStyles inheritance encoded =
    []


class : String -> Attribute msg
class cls =
    Attribute
        [ { flag = Flag.skip
          , attr =
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Just cls
                , styles = noStyles
                , nearby = []
                }
          }
        ]


classWith : Flag -> String -> Attribute msg
classWith flag cls =
    Attribute
        [ { flag = flag
          , attr =
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Just cls
                , styles = noStyles
                , nearby = []
                }
          }
        ]


type alias TransformSlot =
    Int


keepOnly : (Flag -> Bool) -> Attribute msg -> Maybe (Attribute msg)
keepOnly isPassing (Attribute attrList) =
    let
        newAttrs =
            List.filter
                (\attr ->
                    isPassing attr.flag
                )
                attrList
    in
    case newAttrs of
        [] ->
            Nothing

        _ ->
            Just (Attribute newAttrs)


removeIfFlag : (Flag -> Bool) -> Attribute msg -> Attribute msg
removeIfFlag shouldRemove (Attribute attrList) =
    Attribute (List.filter (\attr -> not (shouldRemove attr.flag)) attrList)


type Attribute msg
    = Attribute (List (FlaggedAttr msg))


type alias FlaggedAttr msg =
    { flag : Flag
    , attr : Attr msg
    }


attrs : List (Attribute msg) -> Attribute msg
attrs attrList =
    Attribute
        (List.concatMap
            (\(Attribute attrDetails) ->
                attrDetails
            )
            attrList
        )


type alias Attr msg =
    { node : Node
    , additionalInheritance : Inheritance.Encoded
    , attrs : List (Html.Attribute msg)
    , class : Maybe String
    , styles :
        Inheritance.Encoded
        -> AnalyzeBits.Encoded
        -> List ( String, String )
    , nearby : List ( Location, Element msg )
    }


type Node
    = NodeAsDiv
    | NodeAsSpan
    | NodeAsLink
    | NodeAsParagraph
    | NodeAsButton
      -- Table Nodes
    | NodeAsTable
    | NodeAsTableHead
    | NodeAsTableHeaderCell
    | NodeAsTableRow
    | NodeAsTableD
    | NodeAsTableFoot
    | NodeAsTableBody
      -- Input stuff
    | NodeAsLabel
    | NodeAsInput
    | NodeAsTextArea
      -- Accessibility nodes
    | NodeAsH1
    | NodeAsH2
    | NodeAsH3
    | NodeAsH4
    | NodeAsH5
    | NodeAsH6
    | NodeAsNav
    | NodeAsMain
    | NodeAsAside
    | NodeAsSection
    | NodeAsArticle
    | NodeAsFooter
    | NodeAsNumberedList
    | NodeAsBulletedList
    | NodeAsListItem
    | NodeAsImage
      -- webcomponents
    | NodeAs String


type ResponsiveInt
    = StaticInt Int
    | ResponsiveInt String


type Location
    = Above
    | Below
    | OnRight
    | OnLeft
    | InFront
    | Behind
      -- Special
    | Trigger


defaultOptions : Options msg
defaultOptions =
    Options
        { breakpoints = Nothing
        , animation = Nothing
        , includeStylesheet = True
        }


defaultEmbedOptions : Options msg
defaultEmbedOptions =
    Options
        { breakpoints = Nothing
        , animation = Nothing
        , includeStylesheet = True
        }


type Options msg
    = Options (OptionDetails msg)


type alias OptionDetails msg =
    { breakpoints : Maybe (List Int)
    , animation : Maybe (Anim msg)
    , includeStylesheet : Bool
    }


type alias Anim msg =
    { toMsg : Msg -> msg
    , state : State
    }


emptyDetails : Details
emptyDetails =
    { fontSize = -1
    , transform = Nothing
    , teleportData = []
    }


unwrapKeyed : Inheritance.Encoded -> ( String, Element msg ) -> ( String, Html.Html msg )
unwrapKeyed s el =
    case el of
        ( key, Element html ) ->
            ( key, html s )


wrapText s el =
    case el of
        Element html ->
            html s


text : String -> Element msg
text str =
    Element
        (\encoded ->
            -- Only wrap the text in a span if it's not a text layout
            -- Or if there is a text modification (like a text gradient)
            if
                not (BitField.has Inheritance.isTextLayout encoded)
                    || BitField.has Inheritance.hasTextModification encoded
            then
                Html.span [ Attr.class textElementClasses ] [ Html.text str ]

            else
                Html.text str
        )


none : Element msg
none =
    Element (\_ -> Html.text "")


attrIf : Bool -> Attribute msg -> Attribute msg
attrIf bool attr =
    if bool then
        attr

    else
        noAttr


attribute : Html.Attribute msg -> Attribute msg
attribute a =
    Attribute
        [ { flag = Flag.skip
          , attr =
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = [ a ]
                , class = Nothing
                , styles = noStyles
                , nearby = []
                }
          }
        ]


attributeWith : Flag -> Html.Attribute msg -> Attribute msg
attributeWith flag a =
    Attribute
        [ { flag = flag
          , attr =
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = [ a ]
                , class = Nothing
                , styles = noStyles
                , nearby = []
                }
          }
        ]


focusOnHover : String -> Attribute msg
focusOnHover htmlId =
    attrs
        [ attributeWith Flag.id (Attr.id htmlId)
        , attribute (Attr.tabindex -1)
        , teleport
            { trigger = "on-hovered"
            , class = "focus-on-hover"
            , style = []
            , data = Teleport.encodeFocusOnHover htmlId
            }
        ]


onPress :
    msg
    -> Attribute msg
onPress msg =
    Attribute
        [ { flag = Flag.skip
          , attr =
                { node = NodeAsButton
                , additionalInheritance = BitField.none
                , attrs =
                    [ Events.onClick msg
                    ]
                , class = Just Style.classes.cursorPointer
                , styles = noStyles
                , nearby = []
                }
          }
        ]


onKey :
    { key : String
    , msg : msg
    }
    -> Attribute msg
onKey details =
    let
        decode code =
            if code == details.key then
                Json.succeed details.msg

            else
                Json.fail "Not the enter key"

        isKey =
            Json.field "key" Json.string
                |> Json.andThen decode
    in
    Attribute
        [ { flag = Flag.skip
          , attr =
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs =
                    [ Events.preventDefaultOn "keyup"
                        (Json.map
                            (\fired ->
                                ( fired
                                , True
                                )
                            )
                            isKey
                        )
                    , Attr.tabindex 0
                    ]
                , class = Nothing
                , styles = noStyles
                , nearby = []
                }
          }
        ]


link :
    { newTab : Bool
    , url : String
    , download : Maybe String
    }
    -> Attribute msg
link details =
    Attribute
        [ { flag = Flag.skip
          , attr =
                { node = NodeAsLink
                , additionalInheritance = BitField.none
                , attrs =
                    [ Attr.href details.url
                    , case details.download of
                        Nothing ->
                            Attr.rel "noopener noreferrer"

                        Just _ ->
                            Attr.class ""
                    , case details.download of
                        Nothing ->
                            if details.newTab then
                                Attr.target "_blank"

                            else
                                Attr.class ""

                        Just downloadName ->
                            Attr.download downloadName
                    ]
                , class = Nothing
                , styles = noStyles
                , nearby = []
                }
          }
        ]


nodeAs : Node -> Attribute msg
nodeAs node =
    Attribute
        [ { flag = Flag.skip
          , attr =
                { node = node
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Nothing
                , styles = noStyles
                , nearby = []
                }
          }
        ]


styleList : List ( String, String ) -> Attribute msg
styleList props =
    Attribute
        [ { flag = Flag.skip
          , attr =
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Nothing
                , styles =
                    \_ _ ->
                        props
                , nearby = []
                }
          }
        ]


style : String -> String -> Attribute msg
style name val =
    Attribute
        [ { flag = Flag.skip
          , attr =
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Nothing
                , styles =
                    \_ _ ->
                        [ ( name, val ) ]
                , nearby = []
                }
          }
        ]


styleDynamic : String -> (Inheritance.Encoded -> String) -> Attribute msg
styleDynamic name toVal =
    Attribute
        [ { flag = Flag.skip
          , attr =
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Nothing
                , styles =
                    \inheritance _ ->
                        [ ( name, toVal inheritance ) ]
                , nearby = []
                }
          }
        ]


style2 :
    String
    -> String
    -> String
    -> String
    -> Attribute msg
style2 oneName oneVal twoName twoVal =
    Attribute
        [ { flag = Flag.skip
          , attr =
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Nothing
                , styles =
                    \_ _ ->
                        [ ( oneName, oneVal )
                        , ( twoName, twoVal )
                        ]
                , nearby = []
                }
          }
        ]


style3 :
    String
    -> String
    -> String
    -> String
    -> String
    -> String
    -> Attribute msg
style3 oneName oneVal twoName twoVal threeName threeVal =
    Attribute
        [ { flag = Flag.skip
          , attr =
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Nothing
                , styles =
                    \_ _ ->
                        [ ( oneName, oneVal )
                        , ( twoName, twoVal )
                        , ( threeName, threeVal )
                        ]
                , nearby = []
                }
          }
        ]


styleWith : Flag -> String -> String -> Attribute msg
styleWith flag name val =
    Attribute
        [ { flag = flag
          , attr =
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Nothing
                , styles =
                    \_ _ ->
                        [ ( name, val ) ]
                , nearby = []
                }
          }
        ]


styleAndClass :
    Flag
    ->
        { class : String
        , styleName : String
        , styleVal : String
        }
    -> Attribute msg
styleAndClass flag v =
    Attribute
        [ { flag = flag
          , attr =
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Just v.class
                , styles =
                    \_ _ ->
                        [ ( v.styleName, v.styleVal ) ]
                , nearby = []
                }
          }
        ]


type alias Edges =
    { top : Int
    , right : Int
    , bottom : Int
    , left : Int
    }


type alias Details =
    { fontSize : Int
    , transform : Maybe Transform
    , teleportData : List Json.Value
    }


renderLayout :
    Options msg
    -> List (Attribute msg)
    -> Element msg
    -> Html.Html msg
renderLayout (Options options) attrList content =
    let
        (Element toFinalLayout) =
            element NodeAsDiv
                AsRoot
                (case options.animation of
                    Nothing ->
                        attrList

                    Just anim ->
                        onAnimationStart anim.toMsg
                            :: onAnimationUnmount anim.toMsg
                            :: attrList
                )
                [ Element
                    (\_ ->
                        Html.Keyed.node "div"
                            []
                            [ ( "options", Html.Lazy.lazy renderOptions options )
                            , ( "static"
                              , if options.includeStylesheet then
                                    staticStyles

                                else
                                    Html.text ""
                              )
                            , ( "keyframes"
                              , Html.Lazy.lazy keyframeRules
                                    (case options.animation of
                                        Nothing ->
                                            []

                                        Just anim ->
                                            case anim.state of
                                                State state ->
                                                    state.keyframes
                                    )
                              )
                            , ( "animations"
                              , Html.Lazy.lazy styleRules
                                    (case options.animation of
                                        Nothing ->
                                            []

                                        Just animation ->
                                            case animation.state of
                                                State state ->
                                                    state.rules
                                    )
                              )
                            ]
                    )
                , content
                ]
    in
    toFinalLayout zero


onAnimationStart : (Msg -> msg) -> Attribute msg
onAnimationStart onMsg =
    attribute
        (Events.on "animationstart"
            (Json.field "animationName" Json.string
                |> Json.andThen
                    (\name ->
                        case Teleport.stringToTrigger name of
                            Just trigger ->
                                Json.map (onMsg << Teleported trigger) Teleport.decode

                            Nothing ->
                                Json.fail "Nonmatching animation"
                    )
            )
        )


onAnimationUnmount : (Msg -> msg) -> Attribute msg
onAnimationUnmount onMsg =
    attribute
        (Events.on "animationcancel"
            (Json.field "animationName" Json.string
                |> Json.andThen
                    (\name ->
                        if name == "on-dismount" then
                            Json.map (onMsg << Teleported Teleport.OnDismount) Teleport.decode

                        else
                            Json.fail "Nonmatching animation"
                    )
            )
        )


staticStyles : Html.Html msg
staticStyles =
    Html.div [ Attr.id "elm-ui-static-styles" ]
        [ Html.node "style"
            []
            [ Html.text Style.rules ]
        ]


keyframeRules : List String -> Html.Html msg
keyframeRules styleStr =
    Html.div [ Attr.id "elm-ui-keyframe-rules" ]
        [ Html.node "style"
            []
            [ Html.text (String.join "\n" styleStr) ]
        ]


styleRules : List String -> Html.Html msg
styleRules styleStr =
    Html.div [ Attr.id "elm-ui-dynamic-styles" ]
        [ Html.node "style"
            []
            [ Html.text (String.join "\n" styleStr) ]
        ]


viewBox ( boxId, box ) =
    Html.div
        [ Attr.style "position" "absolute"
        , Attr.style "left" (String.fromFloat box.x ++ "px")
        , Attr.style "top" (String.fromFloat box.y ++ "px")
        , Attr.style "width" (String.fromFloat box.width ++ "px")
        , Attr.style "height" (String.fromFloat box.height ++ "px")
        , Attr.style "z-index" "10"
        , Attr.style "background-color" "rgba(255,0,0,0.1)"
        , Attr.style "border-radius" "3px"
        , Attr.style "border" "3px dashed rgba(255,0,0,0.2)"
        , Attr.style "box-sizing" "border-box"
        , Attr.style "pointer-events" "none"
        ]
        [--Html.text (Debug.toString id)
        ]


element :
    Node
    -> Layout
    -> List (Attribute msg)
    -> List (Element msg)
    -> Element msg
element node layout attrList children =
    Element
        (\parentBits ->
            let
                flattened =
                    flatten attrList []

                myBaseBits =
                    Inheritance.clearParentValues parentBits
                        |> (case layout of
                                AsRow ->
                                    BitField.flip Inheritance.isRow True

                                AsColumn ->
                                    BitField.flip Inheritance.isColumn True

                                AsParagraph ->
                                    BitField.flip Inheritance.isTextLayout True

                                AsTextColumn ->
                                    BitField.flip Inheritance.isTextLayout True

                                _ ->
                                    identity
                           )

                ( analyzedBits, myBits, iHave ) =
                    analyze Flag.none BitField.init myBaseBits flattened

                htmlAttrs =
                    if BitField.has Inheritance.isTextLayout parentBits && BitField.has Flag.xAlign iHave then
                        let
                            spacingX =
                                BitField.get Inheritance.spacingX parentBits

                            spacingY =
                                BitField.get Inheritance.spacingY parentBits

                            margin =
                                Attr.style "margin"
                                    (String.fromInt spacingY
                                        ++ "px"
                                        ++ " "
                                        ++ String.fromInt spacingX
                                        ++ "px"
                                    )
                        in
                        toAttrs parentBits myBits Flag.none [ margin ] flattened

                    else
                        toAttrs parentBits myBits Flag.none [] flattened

                styleAttrs =
                    if BitField.has AnalyzeBits.cssVars analyzedBits then
                        toStyleAsEncodedProperty parentBits
                            myBits
                            analyzedBits
                            Flag.none
                            (contextClasses layout)
                            htmlAttrs
                            ""
                            flattened

                    else
                        toStyle parentBits
                            myBits
                            analyzedBits
                            Flag.none
                            htmlAttrs
                            (contextClasses layout)
                            flattened

                finalChildren =
                    toChildren myBits analyzedBits flattened children
            in
            if node == NodeAsImage then
                Html.img styleAttrs finalChildren

            else if BitField.has AnalyzeBits.isLink analyzedBits then
                Html.a styleAttrs finalChildren

            else if BitField.has AnalyzeBits.isButton analyzedBits then
                Html.button styleAttrs finalChildren

            else
                case node of
                    NodeAsDiv ->
                        Html.div styleAttrs finalChildren

                    NodeAsSpan ->
                        Html.span styleAttrs finalChildren

                    NodeAsLink ->
                        Html.a styleAttrs finalChildren

                    NodeAsParagraph ->
                        Html.p styleAttrs finalChildren

                    NodeAsButton ->
                        Html.button styleAttrs finalChildren

                    NodeAsTable ->
                        Html.table styleAttrs finalChildren

                    NodeAsTableHead ->
                        Html.thead styleAttrs finalChildren

                    NodeAsTableHeaderCell ->
                        Html.th styleAttrs finalChildren

                    NodeAsTableRow ->
                        Html.tr styleAttrs finalChildren

                    NodeAsTableBody ->
                        Html.tbody styleAttrs finalChildren

                    NodeAsTableD ->
                        Html.td styleAttrs finalChildren

                    NodeAsTableFoot ->
                        Html.tfoot styleAttrs finalChildren

                    NodeAsLabel ->
                        Html.label styleAttrs finalChildren

                    NodeAsInput ->
                        Html.input styleAttrs finalChildren

                    NodeAsTextArea ->
                        Html.textarea styleAttrs finalChildren

                    NodeAsImage ->
                        Html.img styleAttrs finalChildren

                    NodeAsH1 ->
                        Html.h1 styleAttrs finalChildren

                    NodeAsH2 ->
                        Html.h2 styleAttrs finalChildren

                    NodeAsH3 ->
                        Html.h3 styleAttrs finalChildren

                    NodeAsH4 ->
                        Html.h4 styleAttrs finalChildren

                    NodeAsH5 ->
                        Html.h5 styleAttrs finalChildren

                    NodeAsH6 ->
                        Html.h6 styleAttrs finalChildren

                    NodeAsNav ->
                        Html.nav styleAttrs finalChildren

                    NodeAsMain ->
                        Html.main_ styleAttrs finalChildren

                    NodeAsAside ->
                        Html.aside styleAttrs finalChildren

                    NodeAsSection ->
                        Html.section styleAttrs finalChildren

                    NodeAsArticle ->
                        Html.article styleAttrs finalChildren

                    NodeAsFooter ->
                        Html.footer styleAttrs finalChildren

                    NodeAsNumberedList ->
                        Html.ol styleAttrs finalChildren

                    NodeAsBulletedList ->
                        Html.ul styleAttrs finalChildren

                    NodeAsListItem ->
                        Html.li styleAttrs finalChildren

                    NodeAs nodeName ->
                        Html.node nodeName styleAttrs finalChildren
        )


toChildren :
    Inheritance.Encoded
    -> AnalyzeBits.Encoded
    -> List (FlaggedAttr msg)
    -> List (Element msg)
    -> List (Html.Html msg)
toChildren myBits analyzedBits attrList children =
    if BitField.has AnalyzeBits.nearbys analyzedBits then
        let
            behind =
                toBehindElements myBits [] attrList

            after =
                toNearbyElements myBits [] attrList
        in
        behind ++ List.map (\(Element toChild) -> toChild myBits) children ++ after

    else
        List.map (\(Element toChild) -> toChild myBits) children


elementKeyed :
    Node
    -> Layout
    -> List (Attribute msg)
    -> List ( String, Element msg )
    -> Element msg
elementKeyed node layout attrList children =
    Element
        (\parentBits ->
            let
                flattened =
                    flatten attrList []

                myBaseBits =
                    Inheritance.clearParentValues parentBits
                        |> (case layout of
                                AsRow ->
                                    BitField.flip Inheritance.isRow True

                                AsColumn ->
                                    BitField.flip Inheritance.isColumn True

                                AsParagraph ->
                                    BitField.flip Inheritance.isTextLayout True

                                AsTextColumn ->
                                    BitField.flip Inheritance.isTextLayout True

                                _ ->
                                    identity
                           )

                ( analyzedBits, myBits, iHave ) =
                    analyze Flag.none BitField.init myBaseBits flattened

                htmlAttrs =
                    if BitField.has Inheritance.isTextLayout parentBits && BitField.has Flag.xAlign iHave then
                        let
                            spacingX =
                                BitField.get Inheritance.spacingX parentBits

                            spacingY =
                                BitField.get Inheritance.spacingY parentBits

                            margin =
                                Attr.style "margin"
                                    (String.fromInt spacingY
                                        ++ "px"
                                        ++ " "
                                        ++ String.fromInt spacingX
                                        ++ "px"
                                    )
                        in
                        toAttrs parentBits myBits Flag.none [ margin ] flattened

                    else
                        toAttrs parentBits myBits Flag.none [] flattened

                styleAttrs =
                    if BitField.has AnalyzeBits.cssVars analyzedBits then
                        toStyleAsEncodedProperty parentBits myBits analyzedBits Flag.none (contextClasses layout) htmlAttrs "" flattened

                    else
                        toStyle parentBits myBits analyzedBits Flag.none htmlAttrs (contextClasses layout) flattened

                finalChildren =
                    toChildrenKeyed myBits analyzedBits flattened children
            in
            if BitField.has AnalyzeBits.isLink analyzedBits then
                Html.Keyed.node "a" styleAttrs finalChildren

            else if BitField.has AnalyzeBits.isButton analyzedBits then
                Html.Keyed.node "button" styleAttrs finalChildren

            else
                case node of
                    NodeAsDiv ->
                        Html.Keyed.node "div" styleAttrs finalChildren

                    NodeAsSpan ->
                        Html.Keyed.node "span" styleAttrs finalChildren

                    NodeAsLink ->
                        Html.Keyed.node "a" styleAttrs finalChildren

                    NodeAsParagraph ->
                        Html.Keyed.node "p" styleAttrs finalChildren

                    NodeAsButton ->
                        Html.Keyed.node "button" styleAttrs finalChildren

                    NodeAsTable ->
                        Html.Keyed.node "table" styleAttrs finalChildren

                    NodeAsTableHead ->
                        Html.Keyed.node "thead" styleAttrs finalChildren

                    NodeAsTableHeaderCell ->
                        Html.Keyed.node "th" styleAttrs finalChildren

                    NodeAsTableRow ->
                        Html.Keyed.node "tr" styleAttrs finalChildren

                    NodeAsTableBody ->
                        Html.Keyed.node "tbody" styleAttrs finalChildren

                    NodeAsTableD ->
                        Html.Keyed.node "td" styleAttrs finalChildren

                    NodeAsTableFoot ->
                        Html.Keyed.node "tfoot" styleAttrs finalChildren

                    NodeAsLabel ->
                        Html.Keyed.node "label" styleAttrs finalChildren

                    NodeAsInput ->
                        Html.Keyed.node "input" styleAttrs finalChildren

                    NodeAsTextArea ->
                        Html.Keyed.node "textarea" styleAttrs finalChildren

                    NodeAsImage ->
                        Html.Keyed.node "img" styleAttrs finalChildren

                    NodeAsH1 ->
                        Html.Keyed.node "h1" styleAttrs finalChildren

                    NodeAsH2 ->
                        Html.Keyed.node "h2" styleAttrs finalChildren

                    NodeAsH3 ->
                        Html.Keyed.node "h3" styleAttrs finalChildren

                    NodeAsH4 ->
                        Html.Keyed.node "h4" styleAttrs finalChildren

                    NodeAsH5 ->
                        Html.Keyed.node "h5" styleAttrs finalChildren

                    NodeAsH6 ->
                        Html.Keyed.node "h6" styleAttrs finalChildren

                    NodeAsNav ->
                        Html.Keyed.node "nav" styleAttrs finalChildren

                    NodeAsMain ->
                        Html.Keyed.node "main" styleAttrs finalChildren

                    NodeAsAside ->
                        Html.Keyed.node "aside" styleAttrs finalChildren

                    NodeAsSection ->
                        Html.Keyed.node "section" styleAttrs finalChildren

                    NodeAsArticle ->
                        Html.Keyed.node "article" styleAttrs finalChildren

                    NodeAsFooter ->
                        Html.Keyed.node "footer" styleAttrs finalChildren

                    NodeAsNumberedList ->
                        Html.Keyed.node "ol" styleAttrs finalChildren

                    NodeAsBulletedList ->
                        Html.Keyed.node "ul" styleAttrs finalChildren

                    NodeAsListItem ->
                        Html.Keyed.node "li" styleAttrs finalChildren

                    NodeAs nodeName ->
                        Html.Keyed.node nodeName styleAttrs finalChildren
        )


toChildrenKeyed :
    Inheritance.Encoded
    -> AnalyzeBits.Encoded
    -> List (FlaggedAttr msg)
    -> List ( String, Element msg )
    -> List ( String, Html.Html msg )
toChildrenKeyed myBits analyzedBits attrList children =
    if BitField.has AnalyzeBits.nearbys analyzedBits then
        let
            behind =
                toBehindElements myBits [] attrList
                    |> List.map (Tuple.pair "behind")

            after =
                toNearbyElements myBits [] attrList
                    |> List.map (Tuple.pair "after")
        in
        behind
            ++ List.map (\( key, Element toChild ) -> ( key, toChild myBits )) children
            ++ after

    else
        List.map (\( key, Element toChild ) -> ( key, toChild myBits )) children


fontSizeAdjusted : Int -> Float -> Float
fontSizeAdjusted size height =
    toFloat size * (1 / height)


shouldAlwaysRender : Flag -> Bool
shouldAlwaysRender bits =
    -- We skip padding here as well because
    --  1. it's supposed to accumulate, e.g. you set padding-left/padding-right and they should stack
    --  2. But we can't use `skip` because we want to identify stuff by flag
    --      to pull it out to use in multiline inputs.  See Ui.Input.multiline
    BitField.fieldEqual bits Flag.skip || BitField.fieldEqual bits Flag.padding


{-| This flattens and reverses the list

    [ one, two, [ three, four ], five ]

Will turn into

    [ five
    , four
    , three
    , two
    , one
    ]

-}
flatten :
    List (Attribute msg)
    -> List (FlaggedAttr msg)
    -> List (FlaggedAttr msg)
flatten attrList gathered =
    case attrList of
        [] ->
            gathered

        (Attribute []) :: remain ->
            flatten remain gathered

        (Attribute [ attr ]) :: remain ->
            flatten remain (attr :: gathered)

        (Attribute attrDetailsList) :: remain ->
            let
                newGathered =
                    List.foldl
                        (\attr innerGathered ->
                            attr :: innerGathered
                        )
                        gathered
                        attrDetailsList
            in
            flatten remain newGathered


{-|

    1. What nodes are we rendering?
    2. Do any attributes use css variables?
    3. Are there any transforms?

-}
analyze :
    Flag.Field
    -> AnalyzeBits.Encoded
    -> Inheritance.Encoded
    -> List (FlaggedAttr msg)
    -> ( AnalyzeBits.Encoded, Inheritance.Encoded, Flag.Field )
analyze has encoded inheritance attrList =
    case attrList of
        [] ->
            ( encoded
                |> BitField.flipIf AnalyzeBits.cssVars
                    (BitField.has Flag.fontGradient has)
            , inheritance
                |> BitField.flipIf Inheritance.hasTextModification
                    (BitField.has Flag.fontGradient has
                        || BitField.has Flag.fontEllipsis has
                    )
            , has
            )

        { flag, attr } :: remain ->
            let
                previouslyRendered =
                    -- We skip padding here as well because
                    --  1. it's supposed to accumulate, e.g. you set padding-left/padding-right and they should stack
                    --  2. But we can't use `skip` because we want to identify stuff by flag
                    --      to pull it out to use in multiline inputs.  See Ui.Input.multiline
                    if shouldAlwaysRender flag then
                        False

                    else
                        BitField.has flag has
            in
            if previouslyRendered then
                analyze has encoded inheritance remain

            else
                let
                    newEncoded =
                        encoded
                            |> BitField.flipIf AnalyzeBits.nearbys (attr.nearby /= [])
                            |> BitField.flipIf AnalyzeBits.isLink
                                (NodeAsLink == attr.node)
                            |> BitField.flipIf AnalyzeBits.isButton
                                (NodeAsButton == attr.node)

                    newInheritance =
                        inheritance
                            |> BitField.merge attr.additionalInheritance
                in
                analyze (Flag.add flag has) newEncoded newInheritance remain


toAttrs :
    Inheritance.Encoded
    -> Inheritance.Encoded
    -> Flag.Field
    -> List (VirtualDom.Attribute msg)
    -> List (FlaggedAttr msg)
    -> List (Html.Attribute msg)
toAttrs parentBits myBits has htmlAttrs attrList =
    case attrList of
        [] ->
            htmlAttrs

        { flag, attr } :: remain ->
            let
                previouslyRendered =
                    if shouldAlwaysRender flag then
                        False

                    else
                        BitField.has flag has
            in
            if previouslyRendered then
                toAttrs parentBits myBits has htmlAttrs remain

            else
                case attr.attrs of
                    [] ->
                        toAttrs parentBits myBits has htmlAttrs remain

                    _ ->
                        let
                            newAttrs =
                                case attr.attrs of
                                    [] ->
                                        htmlAttrs

                                    [ single ] ->
                                        single :: htmlAttrs

                                    [ first, second ] ->
                                        first :: second :: htmlAttrs

                                    list ->
                                        list ++ htmlAttrs
                        in
                        toAttrs parentBits myBits (Flag.add flag has) newAttrs remain


toBehindElements :
    Inheritance.Encoded
    -> List (Html.Html msg)
    -> List (FlaggedAttr msg)
    -> List (Html.Html msg)
toBehindElements inheritance foundElems attrList =
    case attrList of
        [] ->
            foundElems

        { attr } :: remain ->
            case attr.nearby of
                [] ->
                    toBehindElements inheritance foundElems remain

                [ ( Behind, behindElem ) ] ->
                    toBehindElements inheritance (nearbyToHtml inheritance Behind behindElem :: foundElems) remain

                [ ( Trigger, triggerElem ) ] ->
                    toBehindElements inheritance (nearbyToHtml inheritance Trigger triggerElem :: foundElems) remain

                [ ( _, _ ) ] ->
                    toBehindElements inheritance foundElems remain

                nearbys ->
                    let
                        renderedNearbys =
                            List.filterMap
                                (\( location, nearbyElem ) ->
                                    if location == Behind || location == Trigger then
                                        Just (nearbyToHtml inheritance location nearbyElem)

                                    else
                                        Nothing
                                )
                                nearbys
                    in
                    toBehindElements inheritance (renderedNearbys ++ foundElems) remain


toNearbyElements :
    Inheritance.Encoded
    -> List (Html.Html msg)
    -> List (FlaggedAttr msg)
    -> List (Html.Html msg)
toNearbyElements inheritance foundElems attrList =
    case attrList of
        [] ->
            foundElems

        { attr } :: remain ->
            case attr.nearby of
                [] ->
                    toNearbyElements inheritance foundElems remain

                [ ( Behind, _ ) ] ->
                    toNearbyElements inheritance foundElems remain

                [ ( Trigger, _ ) ] ->
                    toNearbyElements inheritance foundElems remain

                [ ( location, nearbyElem ) ] ->
                    toNearbyElements inheritance (nearbyToHtml inheritance location nearbyElem :: foundElems) remain

                nearbys ->
                    let
                        renderedNearbys =
                            List.filterMap
                                (\( location, nearbyElem ) ->
                                    if location == Behind || location == Trigger then
                                        Nothing

                                    else
                                        Just (nearbyToHtml inheritance location nearbyElem)
                                )
                                nearbys
                    in
                    toNearbyElements inheritance (renderedNearbys ++ foundElems) remain


toStyle :
    Inheritance.Encoded
    -> Inheritance.Encoded
    -> AnalyzeBits.Encoded
    -> Flag.Field
    -> List (VirtualDom.Attribute msg)
    -> String
    -> List (FlaggedAttr msg)
    -> List (Html.Attribute msg)
toStyle parentBits myBits analyzedBits has htmlAttrs classes attrList =
    case attrList of
        [] ->
            if BitField.has AnalyzeBits.nearbys analyzedBits then
                Attr.class (classes ++ " " ++ Style.classes.hasNearby) :: htmlAttrs

            else
                Attr.class classes :: htmlAttrs

        { flag, attr } :: remain ->
            let
                previouslyRendered =
                    if shouldAlwaysRender flag then
                        False

                    else
                        BitField.has flag has
            in
            if previouslyRendered then
                toStyle parentBits myBits analyzedBits has htmlAttrs classes remain

            else
                let
                    newClasses =
                        case attr.class of
                            Nothing ->
                                classes

                            Just classStr ->
                                classes ++ " " ++ classStr
                in
                case attr.styles parentBits analyzedBits of
                    [] ->
                        toStyle parentBits myBits analyzedBits (Flag.add flag has) htmlAttrs newClasses remain

                    [ ( name, val ) ] ->
                        toStyle parentBits myBits analyzedBits (Flag.add flag has) (Attr.style name val :: htmlAttrs) newClasses remain

                    [ ( name, val ), ( twoName, twoVal ) ] ->
                        toStyle parentBits myBits analyzedBits (Flag.add flag has) (Attr.style name val :: Attr.style twoName twoVal :: htmlAttrs) newClasses remain

                    list ->
                        toStyle parentBits myBits analyzedBits (Flag.add flag has) (addStyles list htmlAttrs) newClasses remain


addStyles : List ( String, String ) -> List (Html.Attribute msg) -> List (Html.Attribute msg)
addStyles styles attrList =
    case styles of
        [] ->
            attrList

        ( name, val ) :: remain ->
            addStyles remain
                (Attr.style name val :: attrList)


toStyleAsEncodedProperty :
    Inheritance.Encoded
    -> Inheritance.Encoded
    -> AnalyzeBits.Encoded
    -> Flag.Field
    -> String
    -> List (VirtualDom.Attribute msg)
    -> String
    -> List (FlaggedAttr msg)
    -> List (Html.Attribute msg)
toStyleAsEncodedProperty parentBits myBits analyzed has classesString htmlAttrs str attrList =
    case attrList of
        [] ->
            (if BitField.has AnalyzeBits.nearbys analyzed then
                Attr.class (classesString ++ " " ++ Style.classes.hasNearby)

             else
                Attr.class classesString
            )
                :: Attr.property "style"
                    (Encode.string str)
                :: htmlAttrs

        { flag, attr } :: remain ->
            let
                previouslyRendered =
                    if shouldAlwaysRender flag then
                        False

                    else
                        BitField.has flag has
            in
            if previouslyRendered then
                toStyleAsEncodedProperty parentBits myBits analyzed has classesString htmlAttrs str remain

            else
                let
                    newClasses =
                        case attr.class of
                            Nothing ->
                                classesString

                            Just moreClasses ->
                                classesString ++ " " ++ moreClasses
                in
                case attr.styles parentBits analyzed of
                    [] ->
                        toStyleAsEncodedProperty parentBits myBits analyzed (Flag.add flag has) newClasses htmlAttrs str remain

                    [ ( name, val ) ] ->
                        toStyleAsEncodedProperty parentBits myBits analyzed (Flag.add flag has) newClasses htmlAttrs (name ++ ":" ++ val ++ ";" ++ str) remain

                    [ ( name, val ), ( twoName, twoVal ) ] ->
                        toStyleAsEncodedProperty parentBits myBits analyzed (Flag.add flag has) newClasses htmlAttrs (name ++ ":" ++ val ++ ";" ++ twoName ++ ":" ++ twoVal ++ ";" ++ str) remain

                    list ->
                        toStyleAsEncodedProperty parentBits myBits analyzed (Flag.add flag has) newClasses htmlAttrs (addStylesToString list str) remain


addStylesToString : List ( String, String ) -> String -> String
addStylesToString styles attrList =
    case styles of
        [] ->
            attrList

        ( name, val ) :: remain ->
            addStylesToString remain
                (name ++ ":" ++ val ++ ";" ++ attrList)


{-| -}
onKeyListener : String -> msg -> Html.Attribute msg
onKeyListener desiredCode msg =
    let
        decode code =
            if code == desiredCode then
                Json.succeed msg

            else
                Json.fail "Not the enter key"

        isKey =
            Json.field "key" Json.string
                |> Json.andThen decode
    in
    Events.preventDefaultOn "keyup"
        (Json.map
            (\fired ->
                ( fired, True )
            )
            isKey
        )


nearbyToHtml : Inheritance.Encoded -> Location -> Element msg -> Html.Html msg
nearbyToHtml inheritance location (Element elem) =
    if location == Trigger then
        elem inheritance

    else
        Html.div
            [ Attr.class <|
                Style.classes.nearby
                    ++ (" " ++ Style.classes.el ++ " ")
                    ++ (case location of
                            Above ->
                                Style.classes.above

                            Below ->
                                Style.classes.below

                            OnRight ->
                                Style.classes.onRight

                            OnLeft ->
                                Style.classes.onLeft

                            InFront ->
                                Style.classes.inFront

                            Behind ->
                                Style.classes.behind

                            Trigger ->
                                Style.classes.trigger
                       )
            ]
            [ elem inheritance
            ]


zero : BitField.Bits
zero =
    BitField.init


textElementClasses : String
textElementClasses =
    Style.classes.any
        ++ " "
        ++ Style.classes.text


rootClass : String
rootClass =
    Style.classes.root
        ++ " "
        ++ Style.classes.any
        ++ " "
        ++ Style.classes.el


rowClass =
    Style.classes.any
        ++ " "
        ++ Style.classes.row
        ++ " "
        ++ Style.classes.nowrap


columnClass : String
columnClass =
    Style.classes.any
        ++ " "
        ++ Style.classes.column


singleClass =
    Style.classes.any ++ " " ++ Style.classes.el


gridClass =
    Style.classes.any ++ " " ++ Style.classes.grid


paragraphClass =
    Style.classes.any ++ " " ++ Style.classes.paragraph


textColumnClass =
    Style.classes.any ++ " " ++ Style.classes.page


contextClasses context =
    case context of
        AsRow ->
            rowClass

        AsColumn ->
            columnClass

        AsRoot ->
            rootClass

        AsEl ->
            singleClass

        AsGrid ->
            gridClass

        AsParagraph ->
            paragraphClass

        AsTextColumn ->
            textColumnClass



{- DECODERS -}


type alias Overflow =
    { moreOnLeft : Bool
    , moreOnRight : Bool
    , moreAbove : Bool
    , moreBelow : Bool
    }


defaultOverflow : Overflow
defaultOverflow =
    { moreOnLeft = False
    , moreOnRight = False
    , moreAbove = False
    , moreBelow = False
    }


decodeScrollPosition : Json.Decoder Overflow
decodeScrollPosition =
    Json.field "target"
        (Json.map6
            (\scrollLeft scrollTop clientWidth clientHeight scrollWidth scrollHeight ->
                let
                    onLeftEdge =
                        scrollLeft == 0

                    onRightEdge =
                        abs ((clientWidth + scrollLeft) - scrollWidth) == 0
                in
                { moreOnLeft = not onLeftEdge
                , moreOnRight = not onRightEdge
                , moreAbove = scrollTop /= 0
                , moreBelow = abs ((clientHeight + scrollTop) - scrollHeight) /= 0
                }
            )
            (Json.field "scrollLeft" Json.int)
            (Json.field "scrollTop" Json.int)
            (Json.field "clientWidth" Json.int)
            (Json.field "clientHeight" Json.int)
            (Json.field "scrollWidth" Json.int)
            (Json.field "scrollHeight" Json.int)
        )



{- Responsive: Breakpoints -}


type Breakpoints label
    = Responsive
        { default : label
        , breaks : List ( Int, label )
        , total : Int
        , breakpoints : List Int
        }


{-| -}
type Value
    = Between Int Int
    | Exactly Int


mapResonsive : (Int -> Int) -> Value -> Value
mapResonsive fn resp =
    case resp of
        Between low high ->
            Between (fn low) (fn high)

        Exactly exact ->
            Exactly (fn exact)


responsiveCssValue : Breakpoints label -> (label -> Value) -> String
responsiveCssValue resp toValue =
    calc <|
        foldBreakpoints
            (\i lab str ->
                case str of
                    "" ->
                        calc <| renderResponsiveValue i (toValue lab)

                    _ ->
                        str ++ " + " ++ calc (renderResponsiveValue i (toValue lab))
            )
            ""
            resp


{-| Things to remember when using `calc`

<https://developer.mozilla.org/en-US/docs/Web/CSS/calc()>

1.  Multiplication needs one of the arguments to be a <number>, meaning a literal, with no units!

2.  Division needs the _denominator_ to be a <number>, again literal with no units.

-}
renderResponsiveValue : Int -> Value -> String
renderResponsiveValue i v =
    ("var(" ++ breakpointString i ++ ") * ")
        ++ (case v of
                Exactly val ->
                    String.fromInt val ++ "px"

                Between bottom top ->
                    let
                        diff =
                            top - bottom
                    in
                    calc
                        (calc
                            ("var("
                                ++ breakpointString i
                                ++ "-progress) * "
                                ++ String.fromInt diff
                            )
                            ++ " + "
                            ++ String.fromInt bottom
                            ++ "px"
                        )
           )


breakpointString : Int -> String
breakpointString i =
    "--ui-bp-" ++ String.fromInt i


calc : String -> String
calc str =
    "calc(" ++ str ++ ")"


foldBreakpoints :
    (Int -> label -> result -> result)
    -> result
    -> Breakpoints label
    -> result
foldBreakpoints fn initial (Responsive resp) =
    foldBreakpointsHelper fn (fn 0 resp.default initial) 1 resp.breaks


foldBreakpointsHelper fn cursor i breaks =
    case breaks of
        [] ->
            cursor

        ( _, label ) :: remain ->
            foldBreakpointsHelper fn
                (fn i label cursor)
                (i + 1)
                remain


type alias ResponsiveTransition =
    { duration : Int
    }



{- Rendering -}


toBreakpoints :
    { default : label
    , breaks : List ( Int, label )
    , total : Int
    }
    -> Breakpoints label
toBreakpoints details =
    Responsive
        { default = details.default
        , breaks = details.breaks
        , total = details.total
        , breakpoints = List.map Tuple.first details.breaks
        }


toMediaQuery : List Int -> Html.Html msg
toMediaQuery breaks =
    case breaks of
        [] ->
            Html.text ""

        lowerBound :: remain ->
            Html.text
                (":root {"
                    ++ toRoot breaks
                        1
                        (renderResponsiveCssVars 0 0 lowerBound)
                    ++ " }"
                    ++ toBoundedMediaQuery breaks
                        1
                        (maxWidthMediaQuery 0 lowerBound)
                )


renderResponsiveCssVars : Int -> Int -> Int -> String
renderResponsiveCssVars i lower upper =
    ("--ui-bp-" ++ String.fromInt i ++ ": 0;")
        ++ ("--ui-bp-" ++ String.fromInt i ++ "-lower: " ++ String.fromInt lower ++ "px;")
        ++ ("--ui-bp-" ++ String.fromInt i ++ "-upper: " ++ String.fromInt upper ++ "px;")
        ++ ("--ui-bp-"
                ++ String.fromInt i
                ++ "-progress: calc(calc(100vw - "
                ++ String.fromInt lower
                ++ "px) / "
                ++ String.fromInt (upper - lower)
                ++ ");"
           )


toRoot : List Int -> Int -> String -> String
toRoot breaks i rendered =
    case breaks of
        [] ->
            rendered

        [ upper ] ->
            rendered ++ renderResponsiveCssVars i upper (upper + 1000)

        lower :: ((upper :: _) as tail) ->
            toRoot tail
                (i + 1)
                (rendered ++ renderResponsiveCssVars i lower upper)


toBoundedMediaQuery : List Int -> Int -> String -> String
toBoundedMediaQuery breaks i rendered =
    case breaks of
        [] ->
            rendered

        [ upper ] ->
            rendered ++ minWidthMediaQuery i upper

        lower :: ((upper :: _) as tail) ->
            toBoundedMediaQuery tail
                (i + 1)
                (rendered ++ renderBoundedMediaQuery upper lower i)


minWidthMediaQuery : Int -> Int -> String
minWidthMediaQuery i lowerBound =
    "@media" ++ minWidth lowerBound ++ " { " ++ renderMediaProps i ++ " }"


maxWidthMediaQuery : Int -> Int -> String
maxWidthMediaQuery i upperBound =
    "@media " ++ maxWidth upperBound ++ " { " ++ renderMediaProps i ++ " }"


renderBoundedMediaQuery : Int -> Int -> Int -> String
renderBoundedMediaQuery upper lower i =
    "@media " ++ minWidth lower ++ " and " ++ maxWidth upper ++ " { " ++ renderMediaProps i ++ " }"


maxWidth : Int -> String
maxWidth int =
    "(max-width:" ++ String.fromInt int ++ "px)"


minWidth : Int -> String
minWidth int =
    "(min-width:" ++ String.fromInt (int + 1) ++ "px)"


renderMediaProps : Int -> String
renderMediaProps i =
    (":root {--ui-bp-" ++ String.fromInt i ++ ": 1;}")
        ++ (".s.ui-bp-" ++ String.fromInt i ++ "-hidden {display:none !important;}")
        ++ (".s.r.ui-bp-" ++ String.fromInt i ++ "-as-col {flex-direction: column; align-content: flex-start;}")


{-| -}
renderOptions : OptionDetails msg -> Html.Html msg
renderOptions opts =
    case opts.breakpoints of
        Nothing ->
            Html.text ""

        Just breakpoints ->
            Html.div [ Attr.id "elm-ui-responsiveness" ]
                [ Html.node "style"
                    []
                    [ toMediaQuery breakpoints
                    ]
                ]
