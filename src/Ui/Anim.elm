module Ui.Anim exposing
    ( layout
    , init, Msg, update, State
    , Animator, updateWith, subscription, watching
    , Animated
    , Duration, ms
    , transition, hovered, focused, pressed
    , opacity, x, y, rotation, scale, scaleX, scaleY
    , backgroundColor, fontColor, borderColor
    , keyframes, hoveredWith, focusedWith, pressedWith
    , set, wait, step
    , loop, loopFor
    , onTimeline, onTimelineWith
    , persistent
    , mapAttribute
    )

{-|


# Getting set up

@docs layout

@docs init, Msg, update, State

@docs Animator, updateWith, subscription, watching


# Animations

@docs Animated

@docs Duration, ms

@docs transition, hovered, focused, pressed


# Properties

@docs opacity, x, y, rotation, scale, scaleX, scaleY

@docs backgroundColor, fontColor, borderColor

-- @docs padding, paddingEach, backgroundColor, border, font, height, width

-- # Premade animations

-- Here are some premade animations.

-- There's nothing special about them, they're just convenient!

-- Check out how they're defined if you want to make your own.

-- @docs spinning, pulsing, bouncing, pinging


# Using Timelines

@docs keyframes, hoveredWith, focusedWith, pressedWith

@docs set, wait, step

@docs loop, loopFor


# Using Timelines

@docs onTimeline, onTimelineWith


# Persistent Elements

@docs persistent


# Mapping

@docs mapAttribute

-}

import Animator
import Animator.Timeline exposing (Timeline)
import Animator.Watcher
import Color
import Html
import Internal.BitEncodings as Bits
import Internal.BitField as BitField
import Internal.Flag as Flag
import Internal.Model2 as Two
import Internal.Style2 as Style
import Internal.Teleport as Teleport
import Internal.Teleport.Persistent as Persistent
import InternalAnim.Css as Css
import Json.Decode as Decode
import Json.Encode as Encode
import Set
import Time
import Ui exposing (Attribute, Color, Element)
import Ui.Events
import Ui.Responsive


{-| -}
type alias Animated =
    Animator.Attribute


{-| -}
persistent : String -> String -> Attribute msg
persistent group instance =
    --  attach a class and a message handler for the animation message
    -- we could also need to gather up any animateable state as well
    Two.teleport
        { trigger = onRenderTrigger
        , class = Teleport.persistentClass group instance
        , style = []
        , data =
            Teleport.persistentId group instance
        }


{-| -}
onTimeline : Timeline state -> (state -> List Animated) -> Attribute msg
onTimeline timeline fn =
    let
        css =
            Animator.css timeline (\state -> ( fn state, [] ))
    in
    Two.teleport
        { trigger = onRenderTrigger
        , class = css.hash
        , style = []
        , data = Teleport.encodeCss css
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


onFocusWithinTrigger : String
onFocusWithinTrigger =
    "on-focused-within"


onActiveTrigger : String
onActiveTrigger =
    "on-pressed"



{- Animation stuff -}


type Trigger
    = Hover
    | Focus
    | Active


transitionWithTrigger : Trigger -> Duration -> List Animated -> Attribute msg
transitionWithTrigger trigger dur attrs =
    let
        css =
            Animator.css
                (Animator.Timeline.init []
                    |> Animator.Timeline.to dur attrs
                    |> Animator.Timeline.update (Time.millisToPosix 1)
                )
                (\animated ->
                    ( animated, [] )
                )

        triggerClass =
            case trigger of
                Hover ->
                    onHoverTrigger

                Focus ->
                    onFocusTrigger

                Active ->
                    onActiveTrigger

        triggerPsuedo =
            case trigger of
                Hover ->
                    ":hover"

                Focus ->
                    ":focus"

                Active ->
                    ":active"
    in
    Two.teleport
        { trigger = triggerClass
        , class = css.hash
        , style = [ ( "transition", css.transition ) ]
        , data =
            css
                |> addPsuedoClass triggerPsuedo
                |> Teleport.encodeCss
        }


addPsuedoClass : String -> Animator.Css -> Animator.Css
addPsuedoClass psuedo css =
    { css
        | hash = css.hash ++ psuedo
    }


{-| -}
transition : Duration -> List Animated -> Attribute msg
transition dur attrs =
    let
        css =
            Animator.css
                (Animator.Timeline.init []
                    |> Animator.Timeline.to dur attrs
                    |> Animator.Timeline.update (Time.millisToPosix 1)
                )
                (\animated ->
                    ( animated, [] )
                )
    in
    Two.styleList css.props


{-| -}
hovered : Duration -> List Animated -> Attribute msg
hovered dur attrs =
    transitionWithTrigger Hover dur attrs


{-| -}
focused : Duration -> List Animated -> Attribute msg
focused dur attrs =
    transitionWithTrigger Focus dur attrs


{-| -}
pressed : Duration -> List Animated -> Attribute msg
pressed dur attrs =
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
    Timeline state
    ->
        (state
         -> ( List Animated, List Step )
        )
    -> Attribute msg
onTimelineWith timeline fn =
    Two.teleport
        { trigger = onRenderTrigger
        , class = onRenderTrigger
        , style = []
        , data =
            Animator.css timeline fn
                |> Teleport.encodeCss
        }


{-| -}
keyframes : List Step -> Attribute msg
keyframes steps =
    let
        css =
            Animator.keyframes steps
                |> Animator.toCss
    in
    Two.teleport
        { trigger = onRenderTrigger
        , class = css.hash
        , style = []
        , data = Teleport.encodeCss css
        }


{-| -}
hoveredWith : List Step -> Attribute msg
hoveredWith steps =
    let
        css =
            Animator.keyframes steps
                |> Animator.toCss
    in
    Two.teleport
        { trigger = onHoverTrigger
        , class = css.hash
        , style = []
        , data = Teleport.encodeCss css
        }


{-| -}
focusedWith : List Step -> Attribute msg
focusedWith steps =
    let
        css =
            Animator.keyframes steps
                |> Animator.toCss
    in
    Two.teleport
        { trigger = onFocusTrigger
        , class = css.hash
        , style = []
        , data = Teleport.encodeCss css
        }


{-| -}
pressedWith : List Step -> Attribute msg
pressedWith steps =
    let
        css =
            Animator.keyframes steps
                |> Animator.toCss
    in
    Two.teleport
        { trigger = onActiveTrigger
        , class = css.hash
        , style = []
        , data = Teleport.encodeCss css
        }



{- SETUP -}


{-| -}
layout :
    { options : List Ui.Option
    , toMsg : Msg -> msg
    , breakpoints : Maybe (Ui.Responsive.Breakpoints label)
    }
    -> State
    -> List (Attribute msg)
    -> Element msg
    -> Html.Html msg
layout opts state attrs els =
    Two.renderLayout
        { options =
            case opts.breakpoints of
                Just (Two.Responsive breakpoints) ->
                    breakpoints.breakpoints :: opts.options

                Nothing ->
                    opts.options
        , includeStaticStylesheet = True
        }
        state
        (onAnimationStart opts.toMsg
            :: onAnimationUnmount opts.toMsg
            :: attrs
        )
        els


onAnimationStart : (Msg -> msg) -> Ui.Attribute msg
onAnimationStart onMsg =
    Ui.Events.on "animationstart"
        (Decode.field "animationName" Decode.string
            |> Decode.andThen
                (\name ->
                    case Teleport.stringToTrigger name of
                        Just trigger ->
                            Decode.map (onMsg << Two.Teleported trigger) Teleport.decode

                        Nothing ->
                            Decode.fail "Nonmatching animation"
                )
        )


onAnimationUnmount : (Msg -> msg) -> Ui.Attribute msg
onAnimationUnmount onMsg =
    Ui.Events.on "animationcancel"
        (Decode.field "animationName" Decode.string
            |> Decode.andThen
                (\name ->
                    if name == "on-dismount" then
                        Decode.map (onMsg << Two.Teleported Teleport.OnDismount) Teleport.decode

                    else
                        Decode.fail "Nonmatching animation"
                )
        )


{-| -}
init : State
init =
    Two.State
        { added = Set.empty
        , rules = []
        , boxes = Persistent.empty
        }


{-| -}
type alias State =
    Two.State


{-| -}
type alias Msg =
    Two.Msg


{-| -}
mapAttribute : (msg -> msg2) -> Attribute msg -> Attribute msg2
mapAttribute =
    Two.mapAttr


{-| -}
update : (Msg -> msg) -> Msg -> State -> ( State, Cmd msg )
update =
    Two.update


{-| -}
updateWith :
    (Msg -> msg)
    -> Msg
    -> State
    ->
        { ui : State -> model
        , timelines : Animator msg model
        }
    -> ( model, Cmd msg )
updateWith =
    Two.updateWith


{-| -}
type alias Animator msg model =
    Two.Animator msg model


{-| -}
subscription : (Msg -> msg) -> State -> Animator msg model -> model -> Sub msg
subscription =
    Two.subscription


{-| -}
watching :
    { get : model -> Animator.Timeline.Timeline state
    , set : Animator.Timeline.Timeline state -> model -> model
    , onStateChange : state -> Maybe msg
    }
    -> Animator msg model
    -> Animator msg model
watching config anim =
    { animator = Animator.Watcher.watching config.get config.set anim.animator
    , onStateChange =
        -- config.onStateChange << config.get
        \model ->
            let
                future =
                    []

                -- TODO: wire this up once elm-animator supports Animator.future
                -- Animator.future (config.get model)
                -- |> List.map (Tuple.mapSecond anim.onStateChange)
            in
            future ++ anim.onStateChange model
    }
