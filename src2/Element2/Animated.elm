module Element2.Animated exposing (..)

{-| -}

import Animator exposing (Timeline)
import Bitwise
import Element2 exposing (Attribute, Element, Msg)
import Internal.Bits as Bits
import Internal.Model2 as Two


type alias Animated =
    Two.Animated


type alias Personality =
    Two.Personality


duration : Int -> Animated -> Animated
duration dur (Two.Anim cls personality name val) =
    Two.Anim cls
        { arriving =
            { durDelay =
                Bitwise.or
                    (Bitwise.and dur Bits.top16)
                    (Bitwise.and Bits.delay personality.arriving.durDelay)
            , curve = personality.arriving.curve
            }
        , departing =
            { durDelay =
                Bitwise.or
                    (Bitwise.and dur Bits.top16)
                    (Bitwise.and Bits.delay personality.departing.durDelay)
            , curve = personality.departing.curve
            }
        , wobble = personality.wobble
        }
        name
        val


delay : Int -> Animated -> Animated
delay dly (Two.Anim cls personality name val) =
    Two.Anim cls
        { arriving =
            { durDelay =
                Bitwise.or
                    (Bitwise.shiftLeftBy 16 (Bitwise.and dly Bits.top16))
                    (Bitwise.and Bits.duration personality.arriving.durDelay)
            , curve = personality.arriving.curve
            }
        , departing =
            { durDelay =
                Bitwise.or
                    (Bitwise.shiftLeftBy 16 (Bitwise.and dly Bits.top16))
                    (Bitwise.and Bits.duration personality.arriving.durDelay)
            , curve = personality.departing.curve
            }
        , wobble = personality.wobble
        }
        name
        val


wobble : Float -> Animated -> Animated
wobble wob (Two.Anim cls personality name val) =
    Two.Anim cls
        { arriving =
            personality.arriving
        , departing =
            personality.departing
        , wobble = wob
        }
        name
        val


with : (Msg -> msg) -> Timeline state -> (state -> List Animated) -> Attribute msg
with toMsg timeine fn =
    Debug.todo ""


{-| -}
hovered : (Msg -> msg) -> List Animated -> Attribute msg
hovered toMsg attrs =
    Two.WhenAll toMsg
        Two.OnHovered
        (className attrs)
        attrs


className : List Two.Animated -> String
className attrs =
    case attrs of
        [] ->
            ""

        (Two.Anim cls _ _ _) :: [] ->
            cls

        (Two.Anim cls _ _ _) :: remain ->
            className remain ++ "_" ++ cls


{-| -}
focused : (Msg -> msg) -> List Animated -> Attribute msg
focused toMsg attrs =
    Two.WhenAll toMsg
        Two.OnFocused
        (className attrs)
        attrs


{-| -}
pressed : (Msg -> msg) -> List Animated -> Attribute msg
pressed toMsg attrs =
    Two.WhenAll toMsg
        Two.OnPressed
        (className attrs)
        attrs


{-| -}
when : (Msg -> msg) -> Bool -> List Animated -> Attribute msg
when toMsg trigger attrs =
    Two.WhenAll toMsg
        (Two.OnIf trigger)
        (className attrs)
        attrs


{-| The style we are just as the element is created.

_NOTE_ this may be unreliable

-}
created : (Msg -> msg) -> List Animated -> Attribute msg
created toMsg attrs =
    Debug.todo ""



{- Default transitions -}


{-| 250ms, linear, no delay, no wobble
-}
linear : Personality
linear =
    { arriving =
        { durDelay =
            250

        -- TODO, default curves!
        , curve = 0
        }
    , departing =
        { durDelay =
            250
        , curve = 0
        }
    , wobble = 0
    }


opacity : Float -> Animated
opacity o =
    Two.Anim ("o-" ++ String.fromFloat o) linear "opacity" (Two.AnimFloat o)


scale =
    0


rotation =
    0


position =
    0


padding =
    0


paddingEach =
    0


width =
    { px = 0
    , portion = 0
    }


height =
    { px = 0
    , portion = 0
    }


font =
    { size = 0
    , color = 0
    , letterSpacing = 0
    , wordSpacing = 0
    }


background =
    { color = 0
    , position = 0
    }


border =
    { width = 0
    , widthEach = 0
    , rounded = 0
    , roundedEach = 0
    }
