module Ui.Animated exposing
    ( Animated
    , animated, hovered, focused, pressed
    , immediately, veryQuickly, quickly, slowly, verySlowly
    , wobble, delay
    , id
    , onTimeline
    , opacity, position, rotation, scale
    , padding, paddingEach, background, border, font, height, width
    )

{-|

@docs Animated

@docs animated, hovered, focused, pressed

@docs immediately, veryQuickly, quickly, slowly, verySlowly

@docs wobble, delay


# Persistent Eleents

@docs id

@docs onTimeline

---


# Properties

@docs opacity, position, rotation, scale

@docs padding, paddingEach, background, border, font, height, width

-}

import Animator
import Animator.Timeline exposing (Timeline)
import Internal.BitEncodings as Bits
import Internal.BitField as BitField
import Internal.Flag as Flag
import Internal.Model2 as Two
import Internal.Style2 as Style
import Ui exposing (Attribute, Element, Msg)


type alias Animated =
    Two.Animated


type alias Personality =
    Two.Personality



-- duration : Int -> Animated -> Animated
-- duration dur (Two.Anim cls personality name val) =
--     Two.Anim cls
--         { arriving =
--             { durDelay =
--                 Bitwise.or
--                     (Bitwise.and dur Bits.top16)
--                     (Bitwise.and Bits.delay personality.arriving.durDelay)
--             , curve = personality.arriving.curve
--             }
--         , departing =
--             { durDelay =
--                 Bitwise.or
--                     (Bitwise.and dur Bits.top16)
--                     (Bitwise.and Bits.delay personality.departing.durDelay)
--             , curve = personality.departing.curve
--             }
--         , wobble = personality.wobble
--         }
--         name
--         val


delay : Int -> Animated -> Animated
delay dly (Two.Anim cls personality name val) =
    Two.Anim cls
        { arriving =
            { durDelay =
                personality.arriving.durDelay
                    |> BitField.set Bits.delay dly
            , curve = personality.arriving.curve
            }
        , departing =
            { durDelay =
                personality.departing.durDelay
                    |> BitField.set Bits.delay dly
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


onTimeline : (Msg msg -> msg) -> Timeline state -> (state -> List Animated) -> Attribute msg
onTimeline toMsg timeline fn =
    Debug.todo ""


{-| -}
id : (Msg msg -> msg) -> String -> String -> Attribute msg
id toMsg group instance =
    --  attach a class and a message handler for the animation message
    -- we could also need to gather up any animateable state as well
    Two.Attribute
        { flag = Flag.skip
        , attr = Two.Animated toMsg (Two.Id group instance)
        }



-- animatedWith :
--     (Msg msg -> msg)
--     -> state
--     -> (state -> List (Step step))
--     -> (step -> List Animated.Property)
--     -> Attribute msg
-- animatedWith =
--     Debug.todo ""


{-| -}
animated : (Msg msg -> msg) -> Duration -> List Animated -> Attribute msg
animated toMsg dur attrs =
    Two.Attribute
        { flag = Flag.skip
        , attr =
            Two.WhenAll
                toMsg
                (Two.OnIf True)
                (className attrs)
                attrs
        }


{-| -}
hovered : (Msg msg -> msg) -> Duration -> List Animated -> Attribute msg
hovered toMsg dur attrs =
    Two.Attribute
        { flag = Flag.skip
        , attr =
            Two.WhenAll
                toMsg
                Two.OnHovered
                (className attrs)
                attrs
        }


{-| -}
focused : (Msg msg -> msg) -> Duration -> List Animated -> Attribute msg
focused toMsg dur attrs =
    Two.Attribute
        { flag = Flag.skip
        , attr =
            Two.WhenAll
                toMsg
                Two.OnFocused
                (className attrs)
                attrs
        }


{-| -}
pressed : (Msg msg -> msg) -> Duration -> List Animated -> Attribute msg
pressed toMsg dur attrs =
    Two.Attribute
        { flag = Flag.skip
        , attr =
            Two.WhenAll
                toMsg
                Two.OnPressed
                (className attrs)
                attrs
        }


className : List Two.Animated -> String
className attrs =
    case attrs of
        [] ->
            ""

        (Two.Anim cls _ _ _) :: [] ->
            cls

        (Two.Anim cls _ _ _) :: remain ->
            className remain ++ "_" ++ cls


{-| The style we are just as the element is created.

_NOTE_ this may be unreliable

-}
created : (Msg msg -> msg) -> List Animated -> Attribute msg
created toMsg attrs =
    Debug.todo ""



{- Default transitions -}


{-| -}
linearCurve : BitField.Bits Bits.Bezier
linearCurve =
    encodeBezier 0 0 1 1


{-| cubic-bezier(0.4, 0.0, 0.2, 1);
Standard curve as given here: <https://material.io/design/motion/speed.html#easing>
-}
standardCurve : BitField.Bits Bits.Bezier
standardCurve =
    encodeBezier 0.4 0 0.2 1


encodeBezier : Float -> Float -> Float -> Float -> BitField.Bits Bits.Bezier
encodeBezier one two three four =
    BitField.init
        |> BitField.setPercentage Bits.bezOne one
        |> BitField.setPercentage Bits.bezTwo two
        |> BitField.setPercentage Bits.bezThree three
        |> BitField.setPercentage Bits.bezFour four


{-| 250ms, linear, no delay, no wobble
-}
linear : Personality
linear =
    { arriving =
        { durDelay =
            BitField.init
                |> BitField.set Bits.duration 250
        , curve = linearCurve
        }
    , departing =
        { durDelay =
            BitField.init
                |> BitField.set Bits.duration 200
        , curve = linearCurve
        }
    , wobble = 0
    }


{-| 250ms, linear, no delay, no wobble
-}
default : Personality
default =
    { arriving =
        { durDelay =
            BitField.init
                |> BitField.set Bits.duration 250
        , curve = standardCurve
        }
    , departing =
        { durDelay =
            BitField.init
                |> BitField.set Bits.duration 200
        , curve = standardCurve
        }
    , wobble = 0
    }


opacity : Float -> Animated
opacity o =
    Two.Anim ("o-" ++ String.fromFloat o) linear "opacity" (Two.AnimFloat o "")


scale : Float -> Two.Animated
scale f =
    Two.Anim
        ("scale-" ++ String.fromInt (round (f * 100)))
        linear
        "scale"
        (Two.AnimFloat f "")


rotation : Float -> Two.Animated
rotation f =
    Two.Anim
        ("rotate-" ++ String.fromInt (round (f * 100)))
        linear
        "rotate"
        (Two.AnimFloat f "rad")


position : Int -> Int -> Two.Animated
position x y =
    Two.Anim
        ("xy-" ++ String.fromInt x ++ "-" ++ String.fromInt y)
        linear
        "position"
        (Two.AnimTwo
            { one = toFloat x
            , oneUnit = "px"
            , two = toFloat y
            , twoUnit = "px"
            }
        )


padding : Int -> Animated
padding i =
    Two.Anim
        ("pad-" ++ String.fromInt i)
        linear
        "padding"
        (Two.AnimFloat (toFloat i) "px")


paddingEach : { top : Int, right : Int, bottom : Int, left : Int } -> Animated
paddingEach edges =
    Two.Anim
        ("pad-"
            ++ String.fromInt edges.top
            ++ " "
            ++ String.fromInt edges.right
            ++ " "
            ++ String.fromInt edges.bottom
            ++ " "
            ++ String.fromInt edges.left
        )
        linear
        "padding"
        (Two.AnimQuad
            { one = toFloat edges.top
            , oneUnit = "px"
            , two = toFloat edges.right
            , twoUnit = "px"
            , three = toFloat edges.bottom
            , threeUnit = "px"
            , four = toFloat edges.left
            , fourUnit = "px"
            }
        )


width =
    { px =
        \i ->
            Two.Anim
                ("w-" ++ String.fromInt i)
                linear
                "width"
                (Two.AnimFloat (toFloat i) "px")
    }


height =
    { px =
        \i ->
            Two.Anim
                ("h-" ++ String.fromInt i)
                linear
                "height"
                (Two.AnimFloat (toFloat i) "px")
    }


font =
    { size =
        \i ->
            -- NOTE!  We still need to do a font adjustment for this value
            Two.Anim
                ("fs-" ++ String.fromInt i)
                linear
                "font-size"
                (Two.AnimFloat (toFloat i) "px")
    , color =
        \((Style.Rgb red green blue) as fcColor) ->
            let
                redStr =
                    String.fromInt red

                greenStr =
                    String.fromInt green

                blueStr =
                    String.fromInt blue
            in
            Two.Anim
                ("fc-" ++ redStr ++ "-" ++ greenStr ++ "-" ++ blueStr)
                linear
                "color"
                (Two.AnimColor fcColor)
    , letterSpacing =
        \i ->
            Two.Anim
                ("ls-" ++ String.fromInt i)
                linear
                "letter-spacing"
                (Two.AnimFloat (toFloat i) "px")
    , wordSpacing =
        \i ->
            Two.Anim
                ("ws-" ++ String.fromInt i)
                linear
                "word-spacing"
                (Two.AnimFloat (toFloat i) "px")
    }


background =
    { color =
        \((Style.Rgb red green blue) as bgColor) ->
            let
                redStr =
                    String.fromInt red

                greenStr =
                    String.fromInt green

                blueStr =
                    String.fromInt blue
            in
            Two.Anim
                ("bg-" ++ redStr ++ "-" ++ greenStr ++ "-" ++ blueStr)
                linear
                "background-color"
                (Two.AnimColor bgColor)
    , position = 0
    }


border =
    { width =
        \i ->
            Two.Anim
                ("bw-" ++ String.fromInt i)
                linear
                "border-width"
                (Two.AnimFloat (toFloat i) "px")
    , widthEach =
        \edges ->
            Two.Anim
                ("bw-"
                    ++ String.fromInt edges.top
                    ++ " "
                    ++ String.fromInt edges.right
                    ++ " "
                    ++ String.fromInt edges.bottom
                    ++ " "
                    ++ String.fromInt edges.left
                )
                linear
                "border-width"
                (Two.AnimQuad
                    { one = toFloat edges.top
                    , oneUnit = "px"
                    , two = toFloat edges.right
                    , twoUnit = "px"
                    , three = toFloat edges.bottom
                    , threeUnit = "px"
                    , four = toFloat edges.left
                    , fourUnit = "px"
                    }
                )
    , rounded =
        \i ->
            Two.Anim
                ("br-" ++ String.fromInt i)
                linear
                "border-radius"
                (Two.AnimFloat (toFloat i) "px")
    , roundedEach =
        \edges ->
            Two.Anim
                ("pad-"
                    ++ String.fromInt edges.topLeft
                    ++ " "
                    ++ String.fromInt edges.topRight
                    ++ " "
                    ++ String.fromInt edges.bottomRight
                    ++ " "
                    ++ String.fromInt edges.bottomLeft
                )
                linear
                "border-radius"
                (Two.AnimQuad
                    { one = toFloat edges.top
                    , oneUnit = "px"
                    , two = toFloat edges.topRight
                    , twoUnit = "px"
                    , three = toFloat edges.bottomRight
                    , threeUnit = "px"
                    , four = toFloat edges.bottomLeft
                    , fourUnit = "px"
                    }
                )
    }



{- DURATIONS! -}


{-| -}
type Duration
    = Duration Int


{-| -}
ms : Int -> Duration
ms =
    Duration


{-| 0ms
-}
immediately : Duration
immediately =
    ms 0


{-| _100ms_.
-}
veryQuickly : Duration
veryQuickly =
    ms 100


{-| _200ms_ - Likely a good place to start!
-}
quickly : Duration
quickly =
    ms 200


{-| _400ms_.
-}
slowly : Duration
slowly =
    ms 400


{-| _500ms_.
-}
verySlowly : Duration
verySlowly =
    ms 500
