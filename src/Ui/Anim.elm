module Ui.Anim exposing
    ( init, update
    , transition, intro, hovered, focused, focusedByKeyboard, active
    , Duration, ms
    , Animated, opacity
    , x, y, z
    , rotation, rotationAround
    , scale, scaleX, scaleY, scaleZ
    , backgroundColor, fontColor, borderColor
    , Transition, withTransition, withStepTransition
    , linear, spring, bezier
    , spinning, pulsing, bouncing, pinging
    , keyframes, hoveredWith, focusedWith, focusedByKeyboardWith, activeWith
    , Step, set, wait, step
    , loop, loopFor
    , onHover, onFocus, onActive
    , Timeline, onTimeline, onTimelineWith
    , mapAttribute
    )

{-|


# Getting set up

@docs init, update


# Animations

@docs transition, intro, hovered, focused, focusedByKeyboard, active

@docs Duration, ms


# Properties

@docs Animated, opacity

@docs x, y, z

@docs rotation, rotationAround

@docs scale, scaleX, scaleY, scaleZ

@docs backgroundColor, fontColor, borderColor


# Transitions

@docs Transition, withTransition, withStepTransition

@docs linear, spring, bezier


# Premade animations

Here are some premade animations.

There's nothing special about them, they're just convenient!

Check out how they're defined if you want to make your own.

@docs spinning, pulsing, bouncing, pinging


# Keyframes

@docs keyframes, hoveredWith, focusedWith, focusedByKeyboardWith, activeWith

@docs Step, set, wait, step

@docs loop, loopFor


# Parent triggers

@docs onHover, onFocus, onActive


# Timelines

@docs Timeline, onTimeline, onTimelineWith


# Mapping

@docs mapAttribute

-}

import Animator
import Animator.Timeline
import Animator.Transition
import Internal.BitEncodings as Bits
import Internal.BitField as BitField
import Internal.Model2 as Two
import Internal.Teleport as Teleport
import Set
import Ui exposing (Attribute, Color, Element)


{-| -}
type alias Animated =
    Animator.Attribute


{-| -}
type alias Transition =
    Animator.Transition.Transition


{-| -}
linear : Transition
linear =
    Animator.Transition.linear


{-| -}
spring :
    { wobble : Float
    , quickness : Float
    }
    -> Transition
spring =
    Animator.Transition.spring


{-| -}
bezier : Float -> Float -> Float -> Float -> Transition
bezier one two three four =
    Animator.Transition.bezier one two three four


{-| -}
withTransition : Transition -> Animated -> Animated
withTransition =
    Animator.withTransition


{-| -}
withStepTransition : Transition -> Step -> Step
withStepTransition =
    Animator.withStepTransition


{-| -}
type alias Timeline state =
    Animator.Timeline.Timeline state


{-| -}
onTimeline : Timeline state -> (state -> List Animated) -> Attribute msg
onTimeline timeline fn =
    Animator.css timeline (\state -> ( fn state, [] ))
        |> toAttr OnRender


{-| -}
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



{- Triggers -}


onRenderTrigger : String
onRenderTrigger =
    "on-rendered"


onHoverTrigger : String
onHoverTrigger =
    "on-hovered"


onFocusTrigger : String
onFocusTrigger =
    "on-focused"


onFocusByKeyboardTrigger : String
onFocusByKeyboardTrigger =
    "on-focused-by-keyboard"


onFocusWithinTrigger : String
onFocusWithinTrigger =
    "on-focused-within"


onActiveTrigger : String
onActiveTrigger =
    "on-activated"



{- Animation stuff -}


type Trigger
    = Hover
    | Focus
    | FocusByKeyboard
    | Active
    | OnRender


triggerClass : Trigger -> String
triggerClass trigger =
    case trigger of
        Hover ->
            onHoverTrigger

        Focus ->
            onFocusTrigger

        FocusByKeyboard ->
            onFocusByKeyboardTrigger

        Active ->
            onActiveTrigger

        OnRender ->
            onRenderTrigger


triggerPsuedo : Trigger -> String
triggerPsuedo trigger =
    case trigger of
        Hover ->
            ":hover"

        Focus ->
            ":focus"

        FocusByKeyboard ->
            ":focus-visible"

        Active ->
            ":active"

        OnRender ->
            ""


addTriggerToCssClass : Trigger -> Animator.Css -> Animator.Css
addTriggerToCssClass trigger css =
    { css
        | hash =
            triggerClass trigger ++ css.hash
    }


toAttr : Trigger -> Animator.Css -> Attribute msg
toAttr trigger incomingCss =
    let
        css =
            incomingCss
                |> addTriggerToCssClass trigger

        props =
            if css.transition == "" then
                []

            else
                [ ( "transition", css.transition ) ]
    in
    Two.teleport
        { trigger = triggerClass trigger
        , class = css.hash
        , style =
            case trigger of
                OnRender ->
                    incomingCss.props ++ props

                _ ->
                    props
        , data =
            css
                |> Teleport.encodeCss (triggerPsuedo trigger) incomingCss.hash
        }


transitionWithTrigger : Trigger -> Duration -> List Animated -> Attribute msg
transitionWithTrigger trigger dur attrs =
    Animator.transition dur attrs
        |> Animator.toCss
        |> toAttr trigger


{-| -}
transition : Duration -> List Animated -> Attribute msg
transition dur attrs =
    Animator.transition dur attrs
        |> Animator.toCss
        |> .props
        |> Two.styleList


{-| -}
intro :
    Duration
    ->
        { start : List Animated
        , to : List Animated
        }
    -> Attribute msg
intro dur attrs =
    -- we do this because we have to render css keyframes
    Animator.keyframes
        [ Animator.set attrs.start
        , Animator.step dur attrs.to
        ]
        |> Animator.toCss
        |> toAttr OnRender


{-| -}
hovered : Duration -> List Animated -> Attribute msg
hovered dur attrs =
    transitionWithTrigger Hover dur attrs


{-| -}
focused : Duration -> List Animated -> Attribute msg
focused dur attrs =
    transitionWithTrigger Focus dur attrs


{-| Style focus when the browser decides a focus indicator should be shown.

This is usually due to keyboard navigation. Behind the scenes, this uses
`:focus-visible`, which you can read more about on
[MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/:focus-visible).

-}
focusedByKeyboard : Duration -> List Animated -> Attribute msg
focusedByKeyboard dur attrs =
    transitionWithTrigger FocusByKeyboard dur attrs


{-| -}
active : Duration -> List Animated -> Attribute msg
active dur attrs =
    transitionWithTrigger Active dur attrs



{- Default transitions -}


{-| -}
linearCurve : BitField.Bits
linearCurve =
    encodeBezier 0 0 1 1


{-| cubic-bezier(0.4, 0.0, 0.2, 1);
Standard curve as given here: <https://material.io/design/motion/speed.html#easing>
-}
standardCurve : BitField.Bits
standardCurve =
    encodeBezier 0.4 0 0.2 1


encodeBezier : Float -> Float -> Float -> Float -> BitField.Bits
encodeBezier one two three four =
    BitField.init
        |> BitField.setPercentage Bits.bezOne one
        |> BitField.setPercentage Bits.bezTwo two
        |> BitField.setPercentage Bits.bezThree three
        |> BitField.setPercentage Bits.bezFour four


{-| -}
fontColor : Color -> Animated
fontColor clr =
    Animator.color "color" clr


{-| -}
backgroundColor : Color -> Animated
backgroundColor clr =
    Animator.color "background-color" clr


{-| -}
borderColor : Color -> Animated
borderColor clr =
    Animator.color "border-color" clr


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
scaleZ : Float -> Animated
scaleZ =
    Animator.scaleZ


{-| -}
rotation : Float -> Animated
rotation =
    Animator.rotation


{-| -}
rotationAround :
    { x : Float
    , y : Float
    , z : Float
    }
    -> Float
    -> Animated
rotationAround =
    Animator.rotationAround


{-| -}
x : Float -> Animated
x =
    Animator.x


{-| -}
y : Float -> Animated
y =
    Animator.y


{-| -}
z : Float -> Animated
z =
    Animator.z



{- DURATIONS! -}


{-| -}
type alias Duration =
    Animator.Duration


{-| -}
ms : Float -> Duration
ms =
    Animator.ms


{-| -}
spinning : Duration -> Attribute msg
spinning dur =
    Animator.spinning dur
        |> Animator.toCss
        |> toAttr OnRender


{-| -}
pulsing : Duration -> Attribute msg
pulsing dur =
    Animator.pulsing dur
        |> Animator.toCss
        |> toAttr OnRender


{-| -}
bouncing : Duration -> Float -> Attribute msg
bouncing dur distance =
    Animator.bouncing dur distance
        |> Animator.toCss
        |> toAttr OnRender


{-| -}
pinging : Duration -> Attribute msg
pinging dur =
    Animator.pinging dur
        |> Animator.toCss
        |> toAttr OnRender



{- Advanced -}


{-| -}
onTimelineWith :
    Timeline state
    ->
        (state
         -> ( List Animated, List Step )
        )
    -> Attribute msg
onTimelineWith timeline fn =
    Animator.css timeline fn
        |> toAttr OnRender


{-| -}
onHover :
    String
    ->
        { onHover : Attribute msg
        , keyframes : List Step -> Attribute msg
        }
onHover identifier =
    { onHover =
        Two.teleportTrigger
            { trigger = onHoverTrigger
            , identifierClass = identifier
            }
    , keyframes =
        \steps ->
            Animator.keyframes steps
                |> Animator.toCss
                |> toReactionAttr identifier Hover
    }


{-| -}
onFocus :
    String
    ->
        { onFocus : Attribute msg
        , keyframes : List Step -> Attribute msg
        }
onFocus identifier =
    { onFocus =
        Two.teleportTrigger
            { trigger = onFocusTrigger
            , identifierClass = identifier
            }
    , keyframes =
        \steps ->
            Animator.keyframes steps
                |> Animator.toCss
                |> toReactionAttr identifier Focus
    }


{-| -}
onActive :
    String
    ->
        { onActive : Attribute msg
        , keyframes : List Step -> Attribute msg
        }
onActive identifier =
    { onActive =
        Two.teleportTrigger
            { trigger = onActiveTrigger
            , identifierClass = identifier
            }
    , keyframes =
        \steps ->
            Animator.keyframes steps
                |> Animator.toCss
                |> toReactionAttr identifier Active
    }


toReactionAttr : String -> Trigger -> Animator.Css -> Attribute msg
toReactionAttr identifier trigger incomingCss =
    let
        css =
            incomingCss
                |> addTriggerToCssClass trigger

        props =
            if css.transition == "" then
                []

            else
                [ ( "transition", css.transition ) ]
    in
    Two.teleportReaction
        { trigger = triggerClass trigger
        , identifierClass = identifier
        , class = css.hash
        , style =
            List.filter (\( name, _ ) -> name /= "animation") incomingCss.props
                ++ props
        , data =
            css
                |> Teleport.encodeChildReaction (triggerPsuedo trigger) identifier incomingCss.hash
        }


{-| -}
keyframes : List Step -> Attribute msg
keyframes steps =
    Animator.keyframes steps
        |> Animator.toCss
        |> toAttr OnRender


{-| -}
hoveredWith : List Step -> Attribute msg
hoveredWith steps =
    Animator.keyframes steps
        |> Animator.toCss
        |> toAttr Hover


{-| -}
focusedWith : List Step -> Attribute msg
focusedWith steps =
    Animator.keyframes steps
        |> Animator.toCss
        |> toAttr Focus


{-| Run keyframes when the browser decides a focus indicator should be shown.

This is usually due to keyboard navigation. Behind the scenes, this uses
`:focus-visible`, which you can read more about on
[MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/:focus-visible).

-}
focusedByKeyboardWith : List Step -> Attribute msg
focusedByKeyboardWith steps =
    Animator.keyframes steps
        |> Animator.toCss
        |> toAttr FocusByKeyboard


{-| -}
activeWith : List Step -> Attribute msg
activeWith steps =
    Animator.keyframes steps
        |> Animator.toCss
        |> toAttr Active



{- SETUP -}


{-| -}
init : Ui.State
init =
    Two.State
        { added = Set.empty
        , rules = []
        , keyframes = []
        }


{-| -}
mapAttribute : (msg -> msg2) -> Attribute msg -> Attribute msg2
mapAttribute =
    Two.mapAttr


{-| -}
update : (Ui.Msg -> msg) -> Ui.Msg -> Ui.State -> ( Ui.State, Cmd msg )
update =
    Two.update



{- -}


{-| -}
type View msg
    = View (ViewDetails msg)


{-| -}
type alias ViewDetails msg =
    { key : String
    , visible : Bool
    , content : Element msg
    , beforeFocus : List Animated
    , afterFocus : List Animated
    }


{-| -}
fluid :
    List (Attribute msg)
    ->
        { id : String
        , options : List (View msg)
        }
    -> Element msg
fluid attrs { id, options } =
    Two.element Two.NodeAsDiv
        Two.AsEl
        (Ui.width Ui.fill :: attrs)
        (List.map
            (\(View viewOptions) ->
                Ui.el [] viewOptions.content
            )
            options
        )


{-| -}
view : Bool -> String -> Element msg -> View msg
view visible key content =
    View
        { key = key
        , visible = visible
        , content = content
        , beforeFocus = []
        , afterFocus = []
        }
