module Ui.Events exposing
    ( onClick
    , onDoubleClick, onMouseDown, onMouseUp, onMouseEnter, onMouseLeave, onMouseMove
    , onFocus, onLoseFocus
    , onKey
    , Key, enter, space, up, down, left, right, backspace, key
    , on, stopPropagationOn, preventDefaultOn, custom
    )

{-|


# Mouse

@docs onClick

@docs onDoubleClick, onMouseDown, onMouseUp, onMouseEnter, onMouseLeave, onMouseMove


# Focus

@docs onFocus, onLoseFocus


# Keyboard

@docs onKey

@docs Key, enter, space, up, down, left, right, backspace, key


# Custom

@docs on, stopPropagationOn, preventDefaultOn, custom

-}

import Html.Events
import Internal.Flag as Flag
import Internal.Model2 as Two
import Json.Decode as Json exposing (Decoder)
import Ui exposing (Attribute)



-- MOUSE EVENTS


{-| -}
onClick : msg -> Attribute msg
onClick msg =
    Two.onPress msg


{-| -}
onDoubleClick : msg -> Attribute msg
onDoubleClick =
    Two.attribute << Html.Events.onDoubleClick


{-| -}
onMouseEnter : msg -> Attribute msg
onMouseEnter =
    Two.attribute << Html.Events.onMouseEnter


{-| -}
onMouseLeave : msg -> Attribute msg
onMouseLeave =
    Two.attribute << Html.Events.onMouseLeave


{-| -}
onMouseMove : msg -> Attribute msg
onMouseMove msg =
    on "mousemove" (Json.succeed msg)


{-| -}
onMouseDown : msg -> Attribute msg
onMouseDown =
    Two.attribute << Html.Events.onMouseDown


{-| -}
onMouseUp : msg -> Attribute msg
onMouseUp =
    Two.attribute << Html.Events.onMouseUp



-- onClickWith
--     { button = primary
--     , send = localCoords Button
--     }
-- type alias Click =
--     { button : Button
--     , send : Track
--     }
-- type Button = Primary | Secondary
-- type Track
--     = ElementCoords
--     | PageCoords
--     | ScreenCoords
-- |


{-| -}
onClickCoords : (Coords -> msg) -> Attribute msg
onClickCoords msg =
    on "click" (Json.map msg localCoords)


{-| -}
onClickScreenCoords : (Coords -> msg) -> Attribute msg
onClickScreenCoords msg =
    on "click" (Json.map msg screenCoords)


{-| -}
onClickPageCoords : (Coords -> msg) -> Attribute msg
onClickPageCoords msg =
    on "click" (Json.map msg pageCoords)


{-| -}
onMouseCoords : (Coords -> msg) -> Attribute msg
onMouseCoords msg =
    on "mousemove" (Json.map msg localCoords)


{-| -}
onMouseScreenCoords : (Coords -> msg) -> Attribute msg
onMouseScreenCoords msg =
    on "mousemove" (Json.map msg screenCoords)


{-| -}
onMousePageCoords : (Coords -> msg) -> Attribute msg
onMousePageCoords msg =
    on "mousemove" (Json.map msg pageCoords)


type alias Coords =
    { x : Int
    , y : Int
    }


screenCoords : Json.Decoder Coords
screenCoords =
    Json.map2 Coords
        (Json.field "screenX" Json.int)
        (Json.field "screenY" Json.int)


{-| -}
localCoords : Json.Decoder Coords
localCoords =
    Json.map2 Coords
        (Json.field "offsetX" Json.int)
        (Json.field "offsetY" Json.int)


pageCoords : Json.Decoder Coords
pageCoords =
    Json.map2 Coords
        (Json.field "pageX" Json.int)
        (Json.field "pageY" Json.int)



-- FOCUS EVENTS


{-| -}
onLoseFocus : msg -> Attribute msg
onLoseFocus =
    Two.attribute << Html.Events.onBlur


{-| -}
onFocus : msg -> Attribute msg
onFocus =
    Two.attribute << Html.Events.onFocus



-- {-| Same as `on` but you can set a few options.
-- -}
-- onWithOptions : String -> Html.Events.Options -> Json.Decoder msg -> Attribute msg
-- onWithOptions event options decode =
--     Two.Attr <| Html.Events.onWithOptions event options decode
-- COMMON DECODERS


{-| A `Json.Decoder` for grabbing `event.target.value`. We use this to define
`onInput` as follows:

    import Json.Decode as Json

    onInput : (String -> msg) -> Attribute msg
    onInput tagger =
        on "input" (Json.map tagger targetValue)

You probably will never need this, but hopefully it gives some insights into
how to make custom event handlers.

-}
targetValue : Json.Decoder String
targetValue =
    Json.at [ "target", "value" ] Json.string


{-| A `Json.Decoder` for grabbing `event.target.checked`. We use this to define
`onCheck` as follows:

    import Json.Decode as Json

    onCheck : (Bool -> msg) -> Attribute msg
    onCheck tagger =
        on "input" (Json.map tagger targetChecked)

-}
targetChecked : Json.Decoder Bool
targetChecked =
    Json.at [ "target", "checked" ] Json.bool


{-| A `Json.Decoder` for grabbing `event.keyCode`. This helps you define
keyboard listeners like this:

    import Json.Decode as Json

    onKeyUp : (Int -> msg) -> Attribute msg
    onKeyUp tagger =
        on "keyup" (Json.map tagger keyCode)

**Note:** It looks like the spec is moving away from `event.keyCode` and
towards `event.key`. Once this is supported in more browsers, we may add
helpers here for `onKeyUp`, `onKeyDown`, `onKeyPress`, etc.

-}
keyCode : Json.Decoder Int
keyCode =
    Json.field "keyCode" Json.int



{- Keyboard -}


{-| -}
onKey : Key -> msg -> Attribute msg
onKey desiredKey msg =
    Two.onKey
        { key = toCodeString desiredKey
        , msg = msg
        }



-- {-| -}
-- onKeyWith :
--     ({ key : Key
--      , ctrl : Bool
--      , alt : Bool
--      , shift : Bool
--      , meta : Bool
--      }
--      -> Maybe msg
--     )
--     -> Attribute msg
-- onKeyWith toMsg =
--     Two.Attribute
--         { flag = Flag.event
--         , attr =
--             Two.OnKey
--                 (Html.Events.preventDefaultOn "keyup"
--                     (decodeKeyboardEvent
--                         |> Json.map2 Tuple.pair decodeIMEComposition
--                         |> Json.andThen
--                             (\( isComposing, keyDetails ) ->
--                                 case toMsg keyDetails of
--                                     Nothing ->
--                                         Json.fail "Ignored"
--                                     Just msg ->
--                                         if isComposing then
--                                             Json.fail "IME composing is ignored"
--                                         else
--                                             Json.succeed ( msg, True )
--                             )
--                     )
--                 )
--         }


decodeKeyboardEvent :
    Json.Decoder
        { key : Key
        , ctrl : Bool
        , alt : Bool
        , shift : Bool
        , meta : Bool
        }
decodeKeyboardEvent =
    Json.map5
        (\keyStr ctrl alt shift meta ->
            { key = toKey keyStr
            , ctrl = ctrl
            , alt = alt
            , shift = shift
            , meta = meta
            }
        )
        (Json.field "key" Json.string)
        (Json.field "ctrlKey" Json.bool)
        (Json.field "altKey" Json.bool)
        (Json.field "shiftKey" Json.bool)
        (Json.field "metaKey" Json.bool)


{-| This property is true if the user is using IME to craft something like a Korean character.

I _think_ for this usecase that means we want to ignore the character.

But am not totally sure :/ If you run into a case where this is not true, please let me know!

<https://developer.mozilla.org/en-US/docs/Web/API/Document/keyup_event#ignoring_keyup_during_ime_composition>

-}
decodeIMEComposition : Json.Decoder Bool
decodeIMEComposition =
    Json.field "isComposing" Json.bool


{-| -}
type Key
    = Enter
    | Space
    | Up
    | Down
    | Left
    | Right
    | Backspace
    | Key String


{-| -}
enter : Key
enter =
    Enter


{-| -}
space : Key
space =
    Space


{-| -}
up : Key
up =
    Up


{-| -}
down : Key
down =
    Down


{-| -}
left : Key
left =
    Left


{-| -}
right : Key
right =
    Right


{-| -}
backspace : Key
backspace =
    Backspace


{-| -}
key : String -> Key
key =
    Key


toKey : String -> Key
toKey str =
    case str of
        "Enter" ->
            Enter

        "Space" ->
            Space

        "ArrowUp" ->
            Up

        "ArrowDown" ->
            Down

        "ArrowLeft" ->
            Left

        "ArrowRight" ->
            Right

        "Backspace" ->
            Backspace

        _ ->
            Key str


toCodeString : Key -> String
toCodeString myKey =
    case myKey of
        Enter ->
            "Enter"

        Space ->
            "Space"

        Up ->
            "ArrowUp"

        Down ->
            "ArrowDown"

        Left ->
            "ArrowLeft"

        Right ->
            "ArrowRight"

        Backspace ->
            "Backspace"

        Key str ->
            str



{- Custom -}


{-| -}
on : String -> Decoder msg -> Attribute msg
on name decoder =
    Two.attribute (Html.Events.on name decoder)


{-| -}
stopPropagationOn : String -> Decoder ( msg, Bool ) -> Attribute msg
stopPropagationOn name decoder =
    Two.attribute (Html.Events.stopPropagationOn name decoder)


{-| -}
preventDefaultOn : String -> Decoder ( msg, Bool ) -> Attribute msg
preventDefaultOn name decoder =
    Two.attribute (Html.Events.preventDefaultOn name decoder)


{-| -}
custom :
    String
    ->
        Decoder
            { message : msg
            , stopPropagation : Bool
            , preventDefault : Bool
            }
    -> Attribute msg
custom name decoder =
    Two.attribute (Html.Events.custom name decoder)


{-| Decodes a given
[`Event`](http://developer.mozilla.org/en-US/docs/Web/API/Event) into a `Bool`
which indicates whether or not the the event's
[`target`](http://developer.mozilla.org/en-US/docs/Web/API/Event/target) is a
child of the `HTMLElement`s identified by the given
[`id`](http://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/id)s.

Implementation adapted from
<https://dev.to/margaretkrutikova/elm-dom-node-decoder-to-detect-click-outside-3ioh>.

-}
isOutsideTargetDecoder : List String -> Decoder Bool
isOutsideTargetDecoder htmlIds =
    htmlIds
        |> isOutsideElementsDecoder
        |> Json.field "target"


isOutsideElementsDecoder : List String -> Decoder Bool
isOutsideElementsDecoder htmlIds =
    Json.oneOf
        [ Json.field "id" Json.string
            |> Json.andThen
                (\htmlId_ ->
                    if List.member htmlId_ htmlIds then
                        Json.succeed False

                    else
                        Json.fail "check parent node"
                )
        , Json.lazy (\_ -> isOutsideElementsDecoder htmlIds |> Json.field "parentNode")
        , Json.succeed True
        ]
