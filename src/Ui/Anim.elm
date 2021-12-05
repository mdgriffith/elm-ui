module Ui.Anim exposing
    ( Animated
    , Duration, ms
    , transition, hovered, focused, pressed
    , opacity, x, y, rotation, scale, scaleX, scaleY
    , onTimeline, onTimelineWith
    , set, wait, step
    , loop, loopFor
    , keyframes, hoveredWith, focusedWith, pressedWith
    , id
    )

{-|


# Animations

@docs Animated

@docs Duration, ms

@docs transition, hovered, focused, pressed


# Properties

@docs opacity, x, y, rotation, scale, scaleX, scaleY

@docs padding, paddingEach, background, border, font, height, width


# Premade animations

Here are some premade animations.

There's nothing special about them, they're just convenient!

Check out how they're defined if you want to make your own.

@docs spinning, pulsing, bouncing, pinging


# Using Timelines

@docs onTimeline, onTimelineWith

@docs set, wait, step

@docs loop, loopFor

@docs keyframes, hoveredWith, focusedWith, pressedWith


# Persistent Elements

@docs id

-}

import Animator
import Animator.Timeline exposing (Timeline)
import Internal.BitEncodings as Bits
import Internal.BitField as BitField
import Internal.Flag as Flag
import Internal.Model2 as Two
import Time
import Ui exposing (Attribute, Element, Msg)


type alias Animated =
    Animator.Attribute


type alias Personality =
    Two.Personality


{-| -}
id : (Msg msg -> msg) -> String -> String -> Attribute msg
id toMsg group instance =
    --  attach a class and a message handler for the animation message
    -- we could also need to gather up any animateable state as well
    Two.Attribute
        { flag = Flag.skip
        , attr = Two.Animated toMsg (Two.Id group instance)
        }


{-| -}
onTimeline : (Msg msg -> msg) -> Timeline state -> (state -> List Animated) -> Attribute msg
onTimeline toMsg timeline fn =
    Two.Attribute
        { flag = Flag.skip
        , attr =
            Two.Transition2
                { toMsg = toMsg
                , trigger = Two.OnIf True
                , css =
                    Animator.css
                        timeline
                        (\state -> ( fn state, [] ))
                }
        }


type alias Step =
    Animator.Step


{-| -}
set : List Animated -> Step
set =
    Animator.set


{-| -}
wait : Duration -> Step
wait =
    Animator.wait


{-| -}
step : Duration -> List Animated -> Step
step =
    Animator.step


{-| -}
loop : List Step -> Step
loop =
    Animator.loop


{-| -}
loopFor : Int -> List Step -> Step
loopFor =
    Animator.loopFor


{-| -}
transition : (Msg msg -> msg) -> Duration -> List Animated -> Attribute msg
transition toMsg dur attrs =
    Two.Attribute
        { flag = Flag.skip
        , attr =
            Two.Transition2
                { toMsg = toMsg
                , trigger = Two.OnIf True
                , css =
                    Animator.css
                        (Animator.Timeline.init []
                            |> Animator.Timeline.to dur attrs
                            |> Animator.Timeline.update (Time.millisToPosix 1)
                         -- |> Animator.Timeline.update (Time.millisToPosix 2)
                        )
                        (\animated ->
                            ( animated, [] )
                        )
                }
        }


{-| -}
hovered : (Msg msg -> msg) -> Duration -> List Animated -> Attribute msg
hovered toMsg dur attrs =
    Two.Attribute
        { flag = Flag.skip
        , attr =
            Two.Transition2
                { toMsg = toMsg
                , trigger = Two.OnHovered
                , css =
                    Animator.css
                        (Animator.Timeline.init []
                            |> Animator.Timeline.to dur attrs
                            |> Animator.Timeline.update (Time.millisToPosix 1)
                            -- |> Animator.Timeline.update (Time.millisToPosix 1000)
                            |> Debug.log "TIMELINE"
                        )
                        (\animated ->
                            ( animated, [] )
                        )
                        |> Debug.log "SOURCE CSS"
                }
        }


{-| -}
focused : (Msg msg -> msg) -> Duration -> List Animated -> Attribute msg
focused toMsg dur attrs =
    Two.Attribute
        { flag = Flag.skip
        , attr =
            Two.Transition2
                { toMsg = toMsg
                , trigger = Two.OnFocused
                , css =
                    Animator.css
                        (Animator.Timeline.init []
                            |> Animator.Timeline.to dur attrs
                            |> Animator.Timeline.update (Time.millisToPosix 1)
                            |> Animator.Timeline.update (Time.millisToPosix 2)
                        )
                        (\animated ->
                            ( animated, [] )
                        )
                }
        }


{-| -}
pressed : (Msg msg -> msg) -> Duration -> List Animated -> Attribute msg
pressed toMsg dur attrs =
    Two.Attribute
        { flag = Flag.skip
        , attr =
            Two.Transition2
                { toMsg = toMsg
                , trigger = Two.OnPressed
                , css =
                    Animator.css
                        (Animator.Timeline.init []
                            |> Animator.Timeline.to dur attrs
                            |> Animator.Timeline.update (Time.millisToPosix 1)
                            |> Animator.Timeline.update (Time.millisToPosix 2)
                        )
                        (\animated ->
                            ( animated, [] )
                        )
                }
        }


{-| The style we are just as the element is created.

_NOTE_ this may be unreliable

-}
intro : (Msg msg -> msg) -> List Animated -> Attribute msg
intro toMsg attrs =
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


{-| -}
opacity : Float -> Animated
opacity =
    Animator.opacity


{-| -}
scale : Float -> Animated
scale =
    Animator.scale


{-| -}
scaleX : Float -> Animated
scaleX =
    Animator.scaleX


{-| -}
scaleY : Float -> Animated
scaleY =
    Animator.scaleY


{-| -}
rotation : Float -> Animated
rotation =
    Animator.rotation


{-| -}
x : Float -> Animated
x =
    Animator.x


{-| -}
y : Float -> Animated
y =
    Animator.y


{-| -}
padding : Int -> Animated
padding p =
    Animator.int "padding" (toFloat p)



-- paddingEach : { top : Int, right : Int, bottom : Int, left : Int } -> Animated
-- paddingEach edges =
--     Two.Anim
--         ("pad-"
--             ++ String.fromInt edges.top
--             ++ " "
--             ++ String.fromInt edges.right
--             ++ " "
--             ++ String.fromInt edges.bottom
--             ++ " "
--             ++ String.fromInt edges.left
--         )
--         linear
--         "padding"
--         (Two.AnimQuad
--             { one = toFloat edges.top
--             , oneUnit = "px"
--             , two = toFloat edges.right
--             , twoUnit = "px"
--             , three = toFloat edges.bottom
--             , threeUnit = "px"
--             , four = toFloat edges.left
--             , fourUnit = "px"
--             }
--         )
-- width =
--     { px =
--         \i ->
--             Two.Anim
--                 ("w-" ++ String.fromInt i)
--                 linear
--                 "width"
--                 (Two.AnimFloat (toFloat i) "px")
--     }
-- height =
--     { px =
--         \i ->
--             Two.Anim
--                 ("h-" ++ String.fromInt i)
--                 linear
--                 "height"
--                 (Two.AnimFloat (toFloat i) "px")
--     }
-- font =
--     { size =
--         \i ->
--             -- NOTE!  We still need to do a font adjustment for this value
--             Two.Anim
--                 ("fs-" ++ String.fromInt i)
--                 linear
--                 "font-size"
--                 (Two.AnimFloat (toFloat i) "px")
--     , color =
--         \((Style.Rgb red green blue) as fcColor) ->
--             let
--                 redStr =
--                     String.fromInt red
--                 greenStr =
--                     String.fromInt green
--                 blueStr =
--                     String.fromInt blue
--             in
--             Two.Anim
--                 ("fc-" ++ redStr ++ "-" ++ greenStr ++ "-" ++ blueStr)
--                 linear
--                 "color"
--                 (Two.AnimColor fcColor)
--     , letterSpacing =
--         \i ->
--             Two.Anim
--                 ("ls-" ++ String.fromInt i)
--                 linear
--                 "letter-spacing"
--                 (Two.AnimFloat (toFloat i) "px")
--     , wordSpacing =
--         \i ->
--             Two.Anim
--                 ("ws-" ++ String.fromInt i)
--                 linear
--                 "word-spacing"
--                 (Two.AnimFloat (toFloat i) "px")
--     }
-- background =
--     { color =
--         \((Style.Rgb red green blue) as bgColor) ->
--             let
--                 redStr =
--                     String.fromInt red
--                 greenStr =
--                     String.fromInt green
--                 blueStr =
--                     String.fromInt blue
--             in
--             Two.Anim
--                 ("bg-" ++ redStr ++ "-" ++ greenStr ++ "-" ++ blueStr)
--                 linear
--                 "background-color"
--                 (Two.AnimColor bgColor)
--     , position = 0
--     }
-- border =
--     { width =
--         \i ->
--             Two.Anim
--                 ("bw-" ++ String.fromInt i)
--                 linear
--                 "border-width"
--                 (Two.AnimFloat (toFloat i) "px")
--     , widthEach =
--         \edges ->
--             Two.Anim
--                 ("bw-"
--                     ++ String.fromInt edges.top
--                     ++ " "
--                     ++ String.fromInt edges.right
--                     ++ " "
--                     ++ String.fromInt edges.bottom
--                     ++ " "
--                     ++ String.fromInt edges.left
--                 )
--                 linear
--                 "border-width"
--                 (Two.AnimQuad
--                     { one = toFloat edges.top
--                     , oneUnit = "px"
--                     , two = toFloat edges.right
--                     , twoUnit = "px"
--                     , three = toFloat edges.bottom
--                     , threeUnit = "px"
--                     , four = toFloat edges.left
--                     , fourUnit = "px"
--                     }
--                 )
--     , rounded =
--         \i ->
--             Two.Anim
--                 ("br-" ++ String.fromInt i)
--                 linear
--                 "border-radius"
--                 (Two.AnimFloat (toFloat i) "px")
--     , roundedEach =
--         \edges ->
--             Two.Anim
--                 ("pad-"
--                     ++ String.fromInt edges.topLeft
--                     ++ " "
--                     ++ String.fromInt edges.topRight
--                     ++ " "
--                     ++ String.fromInt edges.bottomRight
--                     ++ " "
--                     ++ String.fromInt edges.bottomLeft
--                 )
--                 linear
--                 "border-radius"
--                 (Two.AnimQuad
--                     { one = toFloat edges.top
--                     , oneUnit = "px"
--                     , two = toFloat edges.topRight
--                     , twoUnit = "px"
--                     , three = toFloat edges.bottomRight
--                     , threeUnit = "px"
--                     , four = toFloat edges.bottomLeft
--                     , fourUnit = "px"
--                     }
--                 )
--     }
{- DURATIONS! -}


{-| -}
type alias Duration =
    Animator.Duration


{-| -}
ms : Float -> Duration
ms =
    Animator.ms



{- Advanced -}


{-| -}
onTimelineWith :
    (Msg msg -> msg)
    -> Timeline state
    ->
        (state
         -> ( List Animated, List Step )
        )
    -> Attribute msg
onTimelineWith toMsg timeline fn =
    Two.Attribute
        { flag = Flag.skip
        , attr =
            Two.Transition2
                { toMsg = toMsg
                , trigger = Two.OnIf True
                , css =
                    Animator.css
                        timeline
                        fn
                }
        }


{-| -}
keyframes : (Msg msg -> msg) -> List Step -> Attribute msg
keyframes toMsg steps =
    Two.Attribute
        { flag = Flag.skip
        , attr =
            Two.Transition2
                { toMsg = toMsg
                , trigger = Two.OnIf True
                , css =
                    Animator.css
                        (Animator.Timeline.init []
                            |> Animator.Timeline.to (Animator.ms 0) steps
                            |> Animator.Timeline.update (Time.millisToPosix 1)
                            |> Animator.Timeline.update (Time.millisToPosix 2)
                        )
                        (\mySteps ->
                            ( [], mySteps )
                        )
                }
        }


{-| -}
hoveredWith : (Msg msg -> msg) -> List Step -> Attribute msg
hoveredWith toMsg steps =
    Two.Attribute
        { flag = Flag.skip
        , attr =
            Two.Transition2
                { toMsg = toMsg
                , trigger = Two.OnHovered
                , css =
                    Animator.css
                        (Animator.Timeline.init []
                            |> Animator.Timeline.to (Animator.ms 0) steps
                            |> Animator.Timeline.update (Time.millisToPosix 1)
                            |> Animator.Timeline.update (Time.millisToPosix 2)
                        )
                        (\mySteps ->
                            ( [], mySteps )
                        )
                }
        }


{-| -}
focusedWith : (Msg msg -> msg) -> List Step -> Attribute msg
focusedWith toMsg steps =
    Two.Attribute
        { flag = Flag.skip
        , attr =
            Two.Transition2
                { toMsg = toMsg
                , trigger = Two.OnFocused
                , css =
                    Animator.css
                        (Animator.Timeline.init []
                            |> Animator.Timeline.to (Animator.ms 0) steps
                            |> Animator.Timeline.update (Time.millisToPosix 1)
                            |> Animator.Timeline.update (Time.millisToPosix 2)
                        )
                        (\mySteps ->
                            ( [], mySteps )
                        )
                }
        }


{-| -}
pressedWith : (Msg msg -> msg) -> List Step -> Attribute msg
pressedWith toMsg steps =
    Two.Attribute
        { flag = Flag.skip
        , attr =
            Two.Transition2
                { toMsg = toMsg
                , trigger = Two.OnPressed
                , css =
                    Animator.css
                        (Animator.Timeline.init []
                            |> Animator.Timeline.to (Animator.ms 0) steps
                            |> Animator.Timeline.update (Time.millisToPosix 1)
                            |> Animator.Timeline.update (Time.millisToPosix 2)
                        )
                        (\mySteps ->
                            ( [], mySteps )
                        )
                }
        }
