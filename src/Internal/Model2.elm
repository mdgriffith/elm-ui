module Internal.Model2 exposing (..)

import Animator
import Animator.Timeline
import Animator.Watcher
import Bitwise
import Browser.Dom
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Html.Keyed
import Internal.BitMask as Bits
import Internal.Flag as Flag exposing (Flag)
import Internal.Style2 as Style
import Json.Decode as Json
import Json.Encode
import Set exposing (Set)
import Task
import Time
import VirtualDom


{-| Data to potentially pass down.

1.  SpacingX, spacingY (could be 16 bits each if we use bitwise to split things)
2.  Layout that we're in to know where spacing goes.
3.  Id context?
4.  Browser window size? (again using 16 bits for each.)
5.  Width fill?

(could encode this as a string...or at least the stuff that isn't used much)

-}
type Element msg
    = Element (Int -> Html.Html msg)


map : (a -> b) -> Element a -> Element b
map fn el =
    case el of
        Element elem ->
            Element
                (\s ->
                    Html.map fn (elem s)
                )


mapUIMsg : (a -> b) -> Msg a -> Msg b
mapUIMsg fn msg =
    case msg of
        Tick time ->
            Tick time

        RuleNew str ->
            RuleNew str

        Trans phase str detailList ->
            Trans phase str detailList

        BoxNew id box ->
            BoxNew id box

        RefreshBoxesAndThen externalMsg ->
            RefreshBoxesAndThen (fn externalMsg)

        Animate maybeBox trigger classString props ->
            Animate maybeBox trigger classString props

        BoxesNew externalMsg newBoxes ->
            BoxesNew (fn externalMsg) newBoxes


type Msg msg
    = Tick Time.Posix
    | RuleNew String
    | Trans Phase String (List TransitionDetails)
    | BoxNew Id Box
    | RefreshBoxesAndThen msg
    | BoxesNew msg (List ( Id, Box ))
    | Animate
        (Maybe
            { id : Id
            , box : Box
            }
        )
        Trigger
        String
        (List Animated)


type State
    = State
        { added : Set String
        , rules : List String
        , boxes : List ( Id, Box )
        }


type alias Box =
    { x : Float
    , y : Float
    , width : Float
    , height : Float
    }


{-| refreshed means this new box will completely replace an existing one.
-}
matchBox :
    Id
    -> List ( Id, Box )
    ->
        Maybe
            { box : Box
            , transition : Bool
            , others : List ( Id, Box )
            }
matchBox id boxes =
    matchBoxHelper id boxes []


matchBoxHelper ((Id identifier instance) as id) boxes passed =
    case boxes of
        [] ->
            Nothing

        ( (Id topIdentifier topInstance) as topId, topBox ) :: others ->
            if topIdentifier == identifier then
                Just
                    { box = topBox
                    , transition = instance /= topInstance
                    , others = passed ++ others
                    }

            else
                matchBoxHelper id others (( topId, topBox ) :: passed)


moveAnimationFixed className previous current =
    let
        from =
            bboxCss previous

        to =
            bboxCss current

        keyframes =
            "@keyframes " ++ className ++ " { from { " ++ from ++ " } to { " ++ to ++ "} }"

        classRule =
            "." ++ className ++ "{ position:fixed; animation: " ++ className ++ " 2000ms !important; animation-fill-mode: both !important; }"
    in
    keyframes ++ classRule


bboxCss box =
    "left:"
        ++ String.fromFloat box.x
        ++ "px; top: "
        ++ String.fromFloat box.y
        ++ "px; width:"
        ++ String.fromFloat box.width
        ++ "px; height:"
        ++ String.fromFloat box.height
        ++ "px;"


bboxTransform box =
    "transform:translate("
        ++ String.fromFloat box.x
        ++ "px, "
        ++ String.fromFloat box.y
        ++ "px); width:"
        ++ String.fromFloat box.width
        ++ "px; height:"
        ++ String.fromFloat box.height
        ++ "px;"


moveAnimation className previous current =
    let
        from =
            bboxTransform
                { x = previous.x - current.x
                , y = previous.y - current.y
                , width = previous.width
                , height = previous.height
                }

        to =
            bboxTransform
                { x = 0
                , y = 0
                , width = current.width
                , height = current.height
                }

        keyframes =
            "@keyframes " ++ className ++ " { from { " ++ from ++ " } to { " ++ to ++ "} }"

        classRule =
            ".ui-movable."
                ++ className
                ++ "{ animation: "
                ++ className
                ++ " 2000ms !important; animation-fill-mode: both !important; }"
    in
    keyframes ++ classRule


type alias Animator msg model =
    { animator : Animator.Watcher.Watching model
    , onStateChange : model -> List ( Time.Posix, msg )
    }


updateWith :
    (Msg msg -> msg)
    -> Msg msg
    -> State
    ->
        { ui : State -> model
        , timelines : Animator msg model
        }
    -> ( model, Cmd msg )
updateWith toAppMsg msg state config =
    let
        ( newState, stateCmd ) =
            update toAppMsg msg state
    in
    ( case msg of
        Tick newTime ->
            config.ui newState
                |> Animator.Watcher.update newTime config.timelines.animator

        _ ->
            config.ui newState
    , Cmd.batch
        [ stateCmd
        ]
    )


subscription : (Msg msg -> msg) -> State -> Animator msg model -> model -> Sub msg
subscription toAppMsg state animator model =
    Animator.Watcher.toSubscription (toAppMsg << Tick) model animator.animator


update : (Msg msg -> msg) -> Msg msg -> State -> ( State, Cmd msg )
update toAppMsg msg ((State details) as unchanged) =
    case msg of
        Tick _ ->
            ( unchanged, Cmd.none )

        RuleNew new ->
            if Set.member new details.added then
                ( unchanged, Cmd.none )

            else
                ( State
                    { rules = new :: details.rules
                    , added = Set.insert new details.added
                    , boxes = details.boxes
                    }
                , Cmd.none
                )

        BoxNew id box ->
            -- if this id matches an existing box in the cache
            -- it means this box was previously rendered at the position found
            case matchBox id details.boxes of
                Nothing ->
                    ( State
                        { rules = details.rules
                        , added = details.added
                        , boxes = ( id, box ) :: details.boxes
                        }
                    , Cmd.none
                    )

                Just found ->
                    ( State
                        { rules =
                            if found.transition then
                                let
                                    previous =
                                        found.box

                                    current =
                                        box
                                in
                                moveAnimation (toCssClass id) previous current
                                    :: details.rules

                            else
                                details.rules
                        , added = details.added
                        , boxes = ( id, box ) :: found.others
                        }
                    , Cmd.none
                    )

        Animate maybeId trigger classString props ->
            if Set.member classString details.added then
                ( unchanged, Cmd.none )

            else
                let
                    arrivingTransitionStr =
                        transitionFor .arriving False props

                    departingTransitionStr =
                        transitionFor .departing False props

                    stylesStr =
                        renderTargetAnimatedStyle Nothing props

                    phaseStr =
                        case trigger of
                            OnFocused ->
                                ":focus"

                            OnHovered ->
                                ":hover"

                            OnPressed ->
                                ":active"

                            OnIf on ->
                                ""

                    new =
                        ("." ++ classString ++ phaseStr ++ " {")
                            ++ ("transition:" ++ arrivingTransitionStr ++ ";\n")
                            ++ stylesStr
                            ++ "}"

                    newReturn =
                        ("." ++ classString ++ " {")
                            ++ ("transition:" ++ departingTransitionStr ++ ";")
                            ++ "}"
                in
                ( State
                    { rules = new :: newReturn :: details.rules
                    , added = Set.insert classString details.added
                    , boxes = details.boxes
                    }
                , Cmd.none
                )

        Trans phase classStr transition ->
            if Set.member classStr details.added then
                ( unchanged, Cmd.none )

            else
                let
                    arrivingTransitionStr =
                        renderArrivingTransitionString transition

                    departingTransitionStr =
                        renderDepartingTransitionString transition

                    stylesStr =
                        renderStylesString transition

                    phaseStr =
                        case phase of
                            Focused ->
                                ":focus"

                            Hovered ->
                                ":hover"

                            Pressed ->
                                ":active"

                    new =
                        ("." ++ classStr ++ phaseStr ++ " {")
                            ++ ("transition:" ++ arrivingTransitionStr ++ ";\n")
                            ++ stylesStr
                            ++ "}"

                    newReturn =
                        ("." ++ classStr ++ " {")
                            ++ ("transition:" ++ departingTransitionStr ++ ";")
                            ++ "}"
                in
                ( State
                    { rules = new :: newReturn :: details.rules
                    , added = Set.insert classStr details.added
                    , boxes = details.boxes
                    }
                , Cmd.none
                )

        RefreshBoxesAndThen uiMsg ->
            ( unchanged
            , requestBoundingBoxes details.boxes
                |> Task.perform
                    (toAppMsg << BoxesNew uiMsg)
            )

        BoxesNew uiMsg newBoxes ->
            -- we've received new boxes
            -- This represents ground truth for the moment
            ( State
                { details
                    | boxes = newBoxes
                }
            , Task.succeed uiMsg
                |> Task.perform identity
            )


requestBoundingBoxes boxes =
    Task.succeed []
        |> requestBoundingBoxesHelper boxes


requestBoundingBoxesHelper boxes task =
    case boxes of
        [] ->
            task

        ( topId, topBox ) :: remaining ->
            let
                newTask =
                    task
                        |> Task.andThen
                            (\list ->
                                Browser.Dom.getElement (toCssId topId)
                                    |> Task.map
                                        (\newBox ->
                                            ( topId, newBox.element ) :: list
                                        )
                                    |> Task.onError
                                        (\_ -> Task.succeed list)
                            )
            in
            requestBoundingBoxesHelper remaining newTask


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


transformToString : Transform -> String
transformToString trans =
    "translate("
        ++ String.fromFloat trans.x
        ++ "px, "
        ++ String.fromFloat trans.y
        ++ "px) rotate("
        ++ String.fromFloat trans.rotation
        ++ "rad) scale("
        ++ String.fromFloat trans.scale
        ++ ") !important;"


renderTargetAnimatedStyle : Maybe Transform -> List Animated -> String
renderTargetAnimatedStyle transform props =
    case props of
        [] ->
            case transform of
                Nothing ->
                    ""

                Just details ->
                    "transform: "
                        ++ transformToString details

        (Anim _ _ name (AnimFloat val unit)) :: remaining ->
            if name == "rotate" then
                case transform of
                    Nothing ->
                        renderTargetAnimatedStyle
                            (Just
                                { scale = 1
                                , x = 0
                                , y = 0
                                , rotation = val
                                }
                            )
                            remaining

                    Just trans ->
                        renderTargetAnimatedStyle
                            (Just
                                { scale = trans.scale
                                , x = trans.x
                                , y = trans.y
                                , rotation = val
                                }
                            )
                            remaining

            else if name == "scale" then
                case transform of
                    Nothing ->
                        renderTargetAnimatedStyle
                            (Just
                                { scale = val
                                , x = 0
                                , y = 0
                                , rotation = 0
                                }
                            )
                            remaining

                    Just trans ->
                        renderTargetAnimatedStyle
                            (Just
                                { scale = val
                                , x = trans.x
                                , y = trans.y
                                , rotation = trans.rotation
                                }
                            )
                            remaining

            else
                renderTargetAnimatedStyle transform remaining
                    ++ name
                    ++ ":"
                    ++ String.fromFloat val
                    ++ unit
                    ++ " !important;"

        (Anim _ _ name (AnimTwo details)) :: remaining ->
            if name == "position" then
                case transform of
                    Nothing ->
                        renderTargetAnimatedStyle
                            (Just
                                { scale = 1
                                , x = details.one
                                , y = details.two
                                , rotation = 0
                                }
                            )
                            remaining

                    Just trans ->
                        renderTargetAnimatedStyle
                            (Just
                                { scale = trans.scale
                                , x = details.one
                                , y = details.two
                                , rotation = trans.rotation
                                }
                            )
                            remaining

            else
                renderTargetAnimatedStyle transform remaining
                    ++ name
                    ++ ":"
                    ++ String.fromFloat details.one
                    ++ details.oneUnit
                    ++ " "
                    ++ String.fromFloat details.two
                    ++ details.twoUnit
                    ++ " !important;"

        (Anim _ _ name (AnimQuad details)) :: remaining ->
            renderTargetAnimatedStyle transform remaining
                ++ name
                ++ ":"
                ++ String.fromFloat details.one
                ++ details.oneUnit
                ++ " "
                ++ String.fromFloat details.two
                ++ details.twoUnit
                ++ " "
                ++ String.fromFloat details.three
                ++ details.threeUnit
                ++ " "
                ++ String.fromFloat details.four
                ++ details.fourUnit
                ++ " !important;"

        (Anim _ _ name (AnimColor (Style.Rgb red green blue))) :: remaining ->
            let
                redStr =
                    String.fromInt red

                greenStr =
                    String.fromInt green

                blueStr =
                    String.fromInt blue
            in
            renderTargetAnimatedStyle transform remaining
                ++ name
                ++ (":rgb(" ++ redStr)
                ++ ("," ++ greenStr)
                ++ ("," ++ blueStr)
                ++ ") !important;"


renderStylesString : List TransitionDetails -> String
renderStylesString transitions =
    case transitions of
        [] ->
            ""

        top :: remaining ->
            renderStylesString remaining ++ top.prop ++ ":" ++ top.val ++ " !important;"


transitionFor : (Personality -> Approach) -> Bool -> List Animated -> String
transitionFor toApproach transformRendered animated =
    case animated of
        [] ->
            ""

        (Anim _ transition propName _) :: remaining ->
            let
                isTransform =
                    propName == "rotate" || propName == "scale" || propName == "position"
            in
            if isTransform && transformRendered then
                transitionFor toApproach transformRendered remaining

            else
                let
                    prop =
                        if isTransform then
                            "transform"

                        else
                            propName

                    approach =
                        toApproach transition

                    duration =
                        Bitwise.and Bits.duration approach.durDelay

                    delay =
                        Bitwise.and Bits.delay approach.durDelay

                    curve =
                        "cubic-bezier("
                            ++ (String.fromFloat (toFloat (Bitwise.and Bits.bezierOne approach.curve) / 255) ++ ", ")
                            ++ (String.fromFloat
                                    (toFloat
                                        (Bitwise.shiftRightZfBy Bits.bezierTwoOffset
                                            (Bitwise.and Bits.bezierTwo approach.curve)
                                        )
                                        / 255
                                    )
                                    ++ ", "
                               )
                            ++ (String.fromFloat
                                    (toFloat
                                        (Bitwise.shiftRightZfBy Bits.bezierThreeOffset
                                            (Bitwise.and Bits.bezierThree approach.curve)
                                        )
                                        / 255
                                    )
                                    ++ ", "
                               )
                            ++ (String.fromFloat
                                    (toFloat
                                        (Bitwise.shiftRightZfBy
                                            Bits.bezierFourOffset
                                            (Bitwise.and Bits.bezierFour approach.curve)
                                        )
                                        / 255
                                    )
                                    ++ " "
                               )
                            ++ ")"

                    transitionStr =
                        prop ++ " " ++ String.fromInt duration ++ "ms " ++ curve ++ String.fromInt delay ++ "ms"
                in
                -- transition: <property> <duration> <timing-function> <delay>;
                case remaining of
                    [] ->
                        transitionStr

                    _ ->
                        transitionFor toApproach (isTransform || transformRendered) remaining ++ ", " ++ transitionStr


renderArrivingTransitionString : List TransitionDetails -> String
renderArrivingTransitionString transitions =
    case transitions of
        [] ->
            ""

        top :: remaining ->
            let
                transition =
                    case top.transition of
                        Transition deets ->
                            deets

                duration =
                    Bitwise.and Bits.duration transition.arriving.durDelay

                delay =
                    Bitwise.and Bits.delay transition.arriving.durDelay

                curve =
                    "cubic-bezier("
                        ++ (String.fromFloat (toFloat (Bitwise.and Bits.bezierOne transition.arriving.curve) / 255) ++ ", ")
                        ++ (String.fromFloat (toFloat (Bitwise.and Bits.bezierTwo transition.arriving.curve) / 255) ++ ", ")
                        ++ (String.fromFloat (toFloat (Bitwise.and Bits.bezierThree transition.arriving.curve) / 255) ++ ", ")
                        ++ (String.fromFloat (toFloat (Bitwise.and Bits.bezierFour transition.arriving.curve) / 255) ++ " ")
                        ++ ") "

                transitionStr =
                    top.prop ++ " " ++ String.fromInt duration ++ "ms " ++ curve ++ String.fromInt delay ++ "ms"
            in
            -- transition: <property> <duration> <timing-function> <delay>;
            case remaining of
                [] ->
                    transitionStr

                _ ->
                    renderArrivingTransitionString remaining ++ ", " ++ transitionStr


renderDepartingTransitionString : List TransitionDetails -> String
renderDepartingTransitionString transitions =
    case transitions of
        [] ->
            ""

        top :: remaining ->
            renderDepartingTransitionString remaining ++ top.prop ++ " 200ms"


transitionDetailsToClass : TransitionDetails -> String
transitionDetailsToClass details =
    transitionToClass details.transition


transitionToClass : Transition -> String
transitionToClass (Transition transition) =
    String.fromInt transition.arriving.durDelay
        ++ "-"
        ++ String.fromInt transition.arriving.curve
        ++ "-"
        ++ String.fromInt transition.departing.durDelay
        ++ "-"
        ++ String.fromInt transition.departing.curve


mapAttr : (Msg b -> b) -> (a -> b) -> Attribute a -> Attribute b
mapAttr uiFn fn (Attribute attr) =
    Attribute
        { flag = attr.flag
        , attr =
            case attr.attr of
                NoAttribute ->
                    NoAttribute

                WidthFill i ->
                    WidthFill i

                HeightFill i ->
                    HeightFill i

                Font a ->
                    Font a

                FontSize i ->
                    FontSize i

                TransformPiece s t ->
                    TransformPiece s t

                OnPress msg ->
                    OnPress (fn msg)

                Spacing x y ->
                    Spacing x y

                Padding edges ->
                    Padding edges

                BorderWidth edges ->
                    BorderWidth edges

                Attr a ->
                    Attr (Attr.map fn a)

                Link target url ->
                    Link target url

                Download url filename ->
                    Download url filename

                NodeName name ->
                    NodeName name

                -- invalidation key and literal class
                Class cls ->
                    Class cls

                -- When using a css variable we want to attach the variable itself
                -- and a class that implements the rule.
                --               class  var       value
                ClassAndStyle cls name val ->
                    ClassAndStyle cls name val

                ClassAndVar cls name val ->
                    ClassAndVar cls name val

                Nearby loc el ->
                    Nearby loc (map fn el)

                When toMsg when ->
                    When uiFn
                        { phase = when.phase
                        , class = when.class
                        , transition = when.transition
                        , prop = when.prop
                        , val = when.val
                        }

                WhenAll toMsg trigger classStr props ->
                    WhenAll
                        uiFn
                        trigger
                        classStr
                        props

                Animated toMsg id ->
                    Animated uiFn id
        }


type Layout
    = AsRow
    | AsWrappedRow
    | AsColumn
    | AsEl
    | AsGrid
    | AsParagraph
    | AsTextColumn
    | AsRoot


{-| -}
type Id
    = Id String String


toCssClass : Id -> String
toCssClass (Id one two) =
    one ++ "_" ++ two


toCssId : Id -> String
toCssId (Id one two) =
    one ++ "_" ++ two


class : String -> Attribute msg
class cls =
    Attribute
        { flag = Flag.skip
        , attr = Attr (Attr.class cls)
        }


classWith : Flag -> String -> Attribute msg
classWith flag cls =
    Attribute
        { flag = flag
        , attr = Attr (Attr.class cls)
        }


type alias TransformSlot =
    Int


type Attribute msg
    = Attribute
        { flag : Flag
        , attr : Attr msg
        }


type Attr msg
    = NoAttribute
    | OnPress msg
    | Attr (Html.Attribute msg)
    | Link Bool String
    | Download String String
    | WidthFill Int
    | HeightFill Int
    | Font
        { family : String
        , adjustments :
            Maybe
                { offset : Int
                , height : Int
                }
        , variants : String
        , smallCaps : Bool
        }
    | FontSize Int
    | NodeName String
    | Spacing Int Int
    | Padding Edges
    | BorderWidth Edges
    | TransformPiece TransformSlot Float
      -- invalidation key and literal class
    | Class String
      -- When using a css variable we want to attach the variable itself
      -- and a class that implements the rule.
      --                 class  prop  value
    | ClassAndStyle String String String
      --                 class  var    val
    | ClassAndVar String String String
    | Nearby Location (Element msg)
    | When (Msg msg -> msg) TransitionDetails
    | WhenAll (Msg msg -> msg) Trigger String (List Animated)
    | Animated (Msg msg -> msg) Id


type Trigger
    = OnHovered
    | OnPressed
    | OnFocused
    | OnIf Bool


type Animated
    = Anim String Personality String AnimValue


type AnimValue
    = AnimFloat Float String
    | AnimColor Style.Color
    | AnimTwo
        { one : Float
        , oneUnit : String
        , two : Float
        , twoUnit : String
        }
    | AnimQuad
        { one : Float
        , oneUnit : String
        , two : Float
        , twoUnit : String
        , three : Float
        , threeUnit : String
        , four : Float
        , fourUnit : String
        }


type alias Approach =
    -- durDelay is duration and delay in one int
    -- likewise bitwise encoded
    { durDelay : Int

    -- this is a cubic bezier curve
    -- bitwise encoded as a single int
    , curve : Int
    }


type alias Personality =
    { arriving : Approach
    , departing : Approach
    , wobble : Float
    }


type alias TransitionDetails =
    { phase : Phase
    , class : String
    , transition : Transition
    , prop : String
    , val : String
    }


hasFlags flags attr =
    List.any (Flag.equal attr.flag) flags


type Location
    = Above
    | Below
    | OnRight
    | OnLeft
    | InFront
    | Behind


type Option
    = FocusStyleOption FocusStyle


type Transition
    = Transition
        { arriving :
            -- durDelay is duration and delay in one int
            -- likewise bitwise encoded
            { durDelay : Int

            -- this is a cubic bezier curve
            -- bitwise encoded as a single int
            , curve : Int
            }
        , departing :
            -- durDelay is duration and delay in one int
            -- likewise bitwise encoded
            { durDelay : Int

            -- this is a cubic bezier curve
            -- bitwise encoded as a single int
            , curve : Int
            }
        }


type Phase
    = Hovered
    | Focused
    | Pressed


{-| -}
type alias FocusStyle =
    { borderColor : Maybe Style.Color
    , backgroundColor : Maybe Style.Color
    , shadow :
        Maybe
            { color : Style.Color
            , offset : ( Int, Int )
            , blur : Int
            , size : Int
            }
    }


focusDefaultStyle : FocusStyle
focusDefaultStyle =
    { backgroundColor = Nothing
    , borderColor = Nothing
    , shadow =
        Just
            { color =
                Style.Rgb 155 203 255
            , offset = ( 0, 0 )
            , blur = 0
            , size = 3
            }
    }


type NearbyChildren msg
    = NoNearbyChildren
    | ChildrenBehind (List (Html.Html msg))
    | ChildrenInFront (List (Html.Html msg))
    | ChildrenBehindAndInFront (List (Html.Html msg)) (List (Html.Html msg))


emptyPair : ( Int, Int )
emptyPair =
    ( 0, 0 )


emptyEdges =
    { top = 0
    , left = 0
    , bottom = 0
    , right = 0
    }


emptyDetails : Details msg
emptyDetails =
    { name = "div"
    , node = 0
    , spacingX = 0
    , spacingY = 0
    , padding = emptyEdges
    , borders = emptyEdges
    , heightFill = 0
    , widthFill = 0
    , fontOffset = 0
    , fontHeight = 63
    , fontSize = -1
    , transform = Nothing
    , animEvents = []
    , hover = Nothing
    , focus = Nothing
    , active = Nothing
    }



-- elementKeyed : Layout -> List (Attribute msg) -> List ( String, Element msg ) -> Element msg
-- elementKeyed layout attrs children =
--     renderKeyed layout
--         0
--         children
--         "div"
--         Flag.none
--         ""
--         []
--         (contextClasses layout)
--         NoNearbyChildren
--         (List.reverse attrs)


unwrap : Int -> Element msg -> Html.Html msg
unwrap s el =
    case el of
        Element html ->
            html s


wrapText s el =
    case el of
        Element html ->
            html s


text : String -> Element msg
text str =
    Element
        (\encoded ->
            if encoded - defaultRowBits == 0 || encoded - defaultColBits == 0 then
                Html.span [ Attr.class textElementClasses ] [ Html.text str ]

            else
                let
                    height =
                        encoded
                            |> Bitwise.shiftRightZfBy 20
                            |> Bitwise.and bitsFontHeight
                            |> toFloat

                    offset =
                        encoded
                            |> Bitwise.shiftRightZfBy 26
                            |> Bitwise.and bitsFontOffset
                            |> toFloat

                    spacingY =
                        encoded
                            |> Bitwise.shiftRightZfBy 10
                            |> Bitwise.and bitsSpacingY

                    spacingX =
                        ones
                            |> Bitwise.shiftRightZfBy 22
                            |> Bitwise.and encoded

                    attrs =
                        [ Attr.class textElementClasses
                        ]

                    attrsWithParentSpacing =
                        if height == 63 && offset == 0 then
                            Attr.style "margin"
                                (String.fromInt spacingY ++ "px " ++ String.fromInt spacingX ++ "px")
                                :: attrs

                        else
                            let
                                -- This doesn't totally make sense to me, but it works :/
                                -- I thought that the top margin should have a smaller negative margin than the bottom
                                -- however it seems evenly distributing the empty space works out.
                                topVal =
                                    offset / 31

                                bottomVal =
                                    (1 - (height / 63)) - (offset / 31)

                                even =
                                    (topVal + bottomVal) / 2

                                margin =
                                    "-" ++ String.fromFloat (even + 0.25) ++ "em " ++ (String.fromInt spacingX ++ "px ")
                            in
                            Attr.style "margin"
                                margin
                                :: Attr.style "padding" "0.25em calc((1/32) * 1em) 0.25em 0px"
                                :: attrs
                in
                Html.span
                    attrsWithParentSpacing
                    [ Html.text str ]
        )


none : Element msg
none =
    Element (\_ -> Html.text "")


type alias Rendered msg =
    { name : String
    , htmlAttrs : List (VirtualDom.Attribute msg)
    , nearby : NearbyChildren msg
    , wrapped : List Wrapped
    }


type Wrapped
    = InLink String


noAttr =
    Attribute
        { flag = Flag.skip
        , attr = NoAttribute
        }


attribute a =
    Attribute
        { flag = Flag.skip
        , attr = Attr a
        }


wrappedRowAttributes ((Attribute inner) as attr) =
    case inner.attr of
        Spacing x y ->
            [ attr
            , Attribute
                { flag = Flag.skip
                , attr = Attr (Attr.style "margin-right" (Style.px (-1 * x)))
                }
            , Attribute
                { flag = Flag.skip
                , attr = Attr (Attr.style "margin-bottom" (Style.px (-1 * y)))
                }
            ]

        _ ->
            []


type alias Edges =
    { top : Int
    , right : Int
    , bottom : Int
    , left : Int
    }


type alias Details msg =
    -- Node reprsents html node like `div` or `a`.
    -- right now `0: div` and `1:
    { name : String
    , node : Int
    , spacingX : Int
    , spacingY : Int
    , padding : Edges
    , borders : Edges
    , heightFill : Int
    , widthFill : Int
    , fontOffset : Int
    , fontHeight : Int
    , fontSize : Int
    , transform : Maybe Transform
    , animEvents : List (Json.Decoder msg)
    , hover :
        Maybe
            { toMsg : Msg msg -> msg
            , class : String
            , transitions : List TransitionDetails
            }
    , focus :
        Maybe
            { toMsg : Msg msg -> msg
            , class : String
            , transitions : List TransitionDetails
            }
    , active :
        Maybe
            { toMsg : Msg msg -> msg
            , class : String
            , transitions : List TransitionDetails
            }
    }


spacerTop : Float -> Html.Html msg
spacerTop space =
    Html.div
        [ Attr.style "margin-top" ("calc(var(--vacuum-top) * (1em/var(--font-size-factor)) + " ++ String.fromFloat space ++ "px)")
        ]
        []


spacerBottom : Float -> Html.Html msg
spacerBottom space =
    Html.div
        [ Attr.style "margin-top" ("calc(var(--vacuum-bottom) * (1em/var(--font-size-factor)) + " ++ String.fromFloat space ++ "px)")
        ]
        []



{- Useful bitmasks -}


ones : Int
ones =
    Bitwise.complement 0


top10 : Int
top10 =
    Bitwise.shiftRightZfBy (32 - 10) ones


top6 : Int
top6 =
    Bitwise.shiftRightZfBy (32 - 6) ones


top5 : Int
top5 =
    Bitwise.shiftRightZfBy (32 - 5) ones


bitsSpacingY : Int
bitsSpacingY =
    Bitwise.shiftRightZfBy (32 - 10) ones


bitsFontHeight : Int
bitsFontHeight =
    Bitwise.shiftRightZfBy (32 - 6) ones


bitsFontOffset : Int
bitsFontOffset =
    Bitwise.shiftRightZfBy (32 - 5) ones


bitsFontAdjustments : Int
bitsFontAdjustments =
    Bitwise.shiftRightZfBy (32 - 11) ones
        |> Bitwise.shiftLeftBy 20


defaultRowBits : Int
defaultRowBits =
    Bitwise.and top10 emptyDetails.spacingX
        |> Bitwise.or
            (Bitwise.shiftLeftBy 10 (Bitwise.and top10 emptyDetails.spacingY))
        |> Bitwise.or
            (Bitwise.shiftLeftBy 20 (Bitwise.and top6 emptyDetails.fontHeight))
        |> Bitwise.or
            (Bitwise.shiftLeftBy 26 (Bitwise.and top5 emptyDetails.fontOffset))
        |> Bitwise.or
            rowBits


defaultColBits : Int
defaultColBits =
    Bitwise.and top10 emptyDetails.spacingX
        |> Bitwise.or
            (Bitwise.shiftLeftBy 10 (Bitwise.and top10 emptyDetails.spacingY))
        |> Bitwise.or
            (Bitwise.shiftLeftBy 20 (Bitwise.and top6 emptyDetails.fontHeight))
        |> Bitwise.or
            (Bitwise.shiftLeftBy 26 (Bitwise.and top5 emptyDetails.fontOffset))
        |> Bitwise.or
            nonRowBits


rowBits : Int
rowBits =
    Bitwise.shiftLeftBy 31 1


nonRowBits : Int
nonRowBits =
    Bitwise.shiftLeftBy 31 0


element :
    Layout
    -> List (Attribute msg)
    -> List (Element msg)
    -> Element msg
element layout attrs children =
    Element
        (\parentEncoded ->
            renderAttrs
                parentEncoded
                layout
                emptyDetails
                children
                Flag.none
                []
                -- the "" below is the starting class
                -- though we want some defaults based on the layout
                (contextClasses layout)
                NoNearbyChildren
                ""
                (List.reverse attrs)
        )


renderAttrs :
    Int
    -> Layout
    -> Details msg
    -> List (Element msg)
    -> Flag.Field
    -> List (VirtualDom.Attribute msg)
    -> String
    -> NearbyChildren msg
    -> String
    -> List (Attribute msg)
    -> Html.Html msg
renderAttrs parentEncoded layout details children has htmlAttrs classes nearby vars attrs =
    case attrs of
        [] ->
            let
                encoded =
                    if
                        (details.spacingX == 0)
                            && (details.spacingY == 0)
                            && (details.fontOffset == 0)
                            && (details.fontHeight == 63)
                    then
                        case layout of
                            AsRow ->
                                Bitwise.and bitsFontAdjustments parentEncoded
                                    |> Bitwise.or rowBits

                            _ ->
                                Bitwise.and bitsFontAdjustments parentEncoded
                                    |> Bitwise.or nonRowBits

                    else if Flag.present Flag.fontAdjustment has then
                        -- font adjustment is present on this element, encode it
                        Bitwise.and top10 details.spacingX
                            |> Bitwise.or
                                (Bitwise.shiftLeftBy 10 (Bitwise.and top10 details.spacingY))
                            |> Bitwise.or
                                (Bitwise.shiftLeftBy 20 (Bitwise.and top6 details.fontHeight))
                            |> Bitwise.or
                                (Bitwise.shiftLeftBy 26 (Bitwise.and top5 details.fontOffset))
                            |> Bitwise.or
                                (case layout of
                                    AsRow ->
                                        rowBits

                                    _ ->
                                        nonRowBits
                                )

                    else
                        -- font adjustment is NOT present on this element
                        -- propagate existing font adjustments
                        Bitwise.and bitsFontAdjustments parentEncoded
                            |> Bitwise.or
                                (Bitwise.and top10 details.spacingX)
                            |> Bitwise.or
                                (Bitwise.shiftLeftBy 10 (Bitwise.and top10 details.spacingY))
                            |> Bitwise.or
                                (case layout of
                                    AsRow ->
                                        rowBits

                                    _ ->
                                        nonRowBits
                                )

                renderedChildren =
                    case nearby of
                        NoNearbyChildren ->
                            List.map (unwrap encoded) children

                        ChildrenBehind behind ->
                            behind ++ List.map (unwrap encoded) children

                        ChildrenInFront inFront ->
                            List.map (unwrap encoded) children ++ inFront

                        ChildrenBehindAndInFront behind inFront ->
                            behind ++ List.map (unwrap encoded) children ++ inFront

                attrsWithParentSpacing =
                    if parentEncoded == 0 then
                        htmlAttrs

                    else
                        Attr.style "margin"
                            ((parentEncoded
                                |> Bitwise.shiftRightZfBy 10
                                |> Bitwise.and bitsSpacingY
                                |> String.fromInt
                             )
                                ++ "px "
                                ++ String.fromInt
                                    (ones
                                        |> Bitwise.shiftRightZfBy 22
                                        |> Bitwise.and parentEncoded
                                    )
                                ++ "px"
                            )
                            :: htmlAttrs

                attrsWithSpacing =
                    if Flag.present Flag.spacing has && layout == AsParagraph then
                        Attr.style "line-height"
                            ("calc(1em + " ++ String.fromInt details.spacingY ++ "px")
                            :: attrsWithParentSpacing

                    else
                        attrsWithParentSpacing

                attrsWithTransform =
                    if Flag.present Flag.transform has then
                        case details.transform of
                            Nothing ->
                                attrsWithSpacing

                            Just trans ->
                                Attr.style "transform"
                                    (transformToString trans)
                                    :: attrsWithSpacing

                    else
                        attrsWithSpacing

                adjustmentNotSet =
                    details.fontOffset == 0 && details.fontHeight == 63

                {-
                   no fontsize or adjustment -> skip
                   if fontsize is set, not adjustment:
                       -> set fontsize px

                   adjsutment, not fontsize
                       -> set font size (em
                   if both are set
                       -> fontsize px


                -}
                attrsWithFontSize =
                    if details.fontSize == -1 && adjustmentNotSet then
                        -- no fontsize or adjustment set
                        attrsWithTransform

                    else if adjustmentNotSet then
                        -- font size is set, not adjustment
                        -- set font size, adjust via inherited value
                        let
                            height =
                                parentEncoded
                                    |> Bitwise.shiftRightZfBy 20
                                    |> Bitwise.and bitsFontHeight
                        in
                        Attr.style "font-size"
                            (String.fromFloat
                                (toFloat details.fontSize * (1 / (toFloat height / 63)))
                                ++ "px"
                            )
                            :: attrsWithTransform

                    else if details.fontSize /= -1 then
                        -- a font size is set as well as an adjustment
                        -- set font size from details
                        Attr.style "font-size"
                            (String.fromFloat
                                (toFloat details.fontSize * (1 / (toFloat details.fontHeight / 63)))
                                ++ "px"
                            )
                            :: attrsWithTransform

                    else
                        -- a font size is NOT set, but we have an adjustment
                        -- operate on `em`
                        Attr.style "font-size"
                            (String.fromFloat
                                (1 / (toFloat details.fontHeight / 63))
                                ++ "em"
                            )
                            :: attrsWithTransform

                attrsWithWidth =
                    if details.widthFill == 0 then
                        attrsWithFontSize

                    else if Bitwise.and rowBits parentEncoded /= 0 then
                        -- we're within a row, our flex-grow can be set
                        Attr.class Style.classes.widthFill
                            :: Attr.style "flex-grow" (String.fromInt (details.widthFill * 100000))
                            :: attrsWithFontSize

                    else
                        Attr.class Style.classes.widthFill
                            :: attrsWithFontSize

                attrsWithHeight =
                    if details.heightFill == 0 then
                        attrsWithWidth

                    else if details.heightFill == 1 then
                        Attr.class Style.classes.heightFill
                            :: attrsWithWidth

                    else if Bitwise.and rowBits parentEncoded == 0 then
                        -- we're within a column, our flex-grow can be set safely
                        Attr.class Style.classes.heightFill
                            :: Attr.style "flex-grow" (String.fromInt (details.heightFill * 100000))
                            :: attrsWithFontSize

                    else
                        Attr.class Style.classes.heightFill
                            :: attrsWithWidth

                attrsWithHover =
                    case details.hover of
                        Nothing ->
                            attrsWithHeight

                        Just transition ->
                            Events.onMouseEnter
                                (transition.toMsg
                                    (Trans Hovered transition.class transition.transitions)
                                )
                                :: Attr.class transition.class
                                :: attrsWithHeight

                attrsWithFocus =
                    case details.focus of
                        Nothing ->
                            attrsWithHover

                        Just transition ->
                            Events.onFocus
                                (transition.toMsg
                                    (Trans Focused transition.class transition.transitions)
                                )
                                :: Attr.class transition.class
                                :: attrsWithHover

                attrsWithActive =
                    case details.active of
                        Nothing ->
                            attrsWithFocus

                        Just transition ->
                            Events.onMouseDown
                                (transition.toMsg
                                    (Trans Pressed transition.class transition.transitions)
                                )
                                :: Attr.class transition.class
                                :: attrsWithFocus

                attrsWithAnimations =
                    case details.animEvents of
                        [] ->
                            attrsWithActive

                        animEvents ->
                            Events.on "animationstart"
                                (Json.oneOf details.animEvents)
                                :: attrsWithActive

                attributes =
                    case vars of
                        "" ->
                            Attr.class classes
                                :: attrsWithAnimations

                        _ ->
                            Attr.property "style" (Json.Encode.string vars)
                                :: Attr.class classes
                                :: attrsWithAnimations

                finalChildren =
                    case layout of
                        AsParagraph ->
                            if Flag.present Flag.id has then
                                Html.div (Attr.class "ui-movable" :: attributes) renderedChildren
                                    :: spacerTop (toFloat details.spacingY / -2)
                                    :: renderedChildren
                                    ++ [ spacerBottom (toFloat details.spacingY / -2) ]

                            else
                                spacerTop (toFloat details.spacingY / -2)
                                    :: renderedChildren
                                    ++ [ spacerBottom (toFloat details.spacingY / -2) ]

                        _ ->
                            if Flag.present Flag.id has then
                                Html.div (Attr.class "ui-movable" :: attributes) renderedChildren
                                    :: renderedChildren

                            else
                                renderedChildren

                finalAttributes =
                    if Flag.present Flag.id has then
                        Attr.class "ui-placeholder" :: attributes

                    else
                        attributes
            in
            case details.node of
                0 ->
                    -- Note: these functions (div, a) are ever so slightly faster than `Html.node`
                    -- because they can skip elm's built in security check for `script`
                    Html.div
                        finalAttributes
                        finalChildren

                1 ->
                    Html.a
                        finalAttributes
                        finalChildren

                2 ->
                    Html.input
                        finalAttributes
                        finalChildren

                _ ->
                    Html.node details.name
                        finalAttributes
                        finalChildren

        (Attribute { flag, attr }) :: remain ->
            let
                present =
                    case flag of
                        Flag.Flag f ->
                            f - 0 == 0
            in
            if not present || not (Flag.present flag has) then
                renderAttrs parentEncoded layout details children has htmlAttrs classes nearby vars remain

            else
                case attr of
                    NoAttribute ->
                        renderAttrs parentEncoded layout details children has htmlAttrs classes nearby vars remain

                    FontSize size ->
                        renderAttrs parentEncoded
                            layout
                            { name = details.name
                            , node = details.node
                            , spacingX = details.spacingX
                            , spacingY = details.spacingY
                            , fontOffset = details.fontOffset
                            , fontHeight =
                                details.fontHeight
                            , fontSize =
                                size
                            , heightFill = details.heightFill
                            , widthFill = details.widthFill
                            , padding = details.padding
                            , borders = details.borders
                            , transform = details.transform
                            , animEvents = details.animEvents
                            , hover = details.hover
                            , focus = details.focus
                            , active = details.active
                            }
                            children
                            has
                            htmlAttrs
                            classes
                            nearby
                            vars
                            remain

                    Font font ->
                        let
                            withSmallcaps =
                                if font.smallCaps then
                                    Attr.style "font-variant-caps" "small-caps"
                                        :: htmlAttrs

                                else
                                    htmlAttrs

                            withFeatures =
                                if font.variants == "" then
                                    withSmallcaps

                                else
                                    Attr.style "font-feature-settings" font.variants
                                        :: withSmallcaps
                        in
                        renderAttrs parentEncoded
                            layout
                            { name = details.name
                            , node = details.node
                            , spacingX = details.spacingX
                            , spacingY = details.spacingY
                            , fontOffset =
                                case font.adjustments of
                                    Nothing ->
                                        details.fontOffset

                                    Just adj ->
                                        adj.offset
                            , fontHeight =
                                case font.adjustments of
                                    Nothing ->
                                        details.fontHeight

                                    Just adj ->
                                        adj.height
                            , fontSize =
                                details.fontSize
                            , heightFill = details.heightFill
                            , widthFill = details.widthFill
                            , padding = details.padding
                            , borders = details.borders
                            , transform = details.transform
                            , animEvents = details.animEvents
                            , hover = details.hover
                            , focus = details.focus
                            , active = details.active
                            }
                            children
                            (case font.adjustments of
                                Nothing ->
                                    has

                                Just _ ->
                                    Flag.add Flag.fontAdjustment has
                            )
                            (Attr.style "font-family" font.family
                                :: withFeatures
                            )
                            classes
                            nearby
                            vars
                            remain

                    TransformPiece slot val ->
                        renderAttrs parentEncoded
                            layout
                            { details | transform = Just (upsertTransform slot val details.transform) }
                            children
                            (Flag.add Flag.transform has)
                            htmlAttrs
                            classes
                            nearby
                            vars
                            remain

                    Attr htmlAttr ->
                        renderAttrs parentEncoded
                            layout
                            details
                            children
                            has
                            (htmlAttr :: htmlAttrs)
                            classes
                            nearby
                            vars
                            remain

                    OnPress press ->
                        -- Make focusable
                        -- Attach keyboard handler
                        -- Attach click handler
                        renderAttrs parentEncoded
                            layout
                            details
                            children
                            has
                            (Attr.style "tabindex" "0"
                                :: Events.onClick press
                                :: onKey "Enter" press
                                :: htmlAttrs
                            )
                            classes
                            nearby
                            vars
                            remain

                    Link targetBlank url ->
                        renderAttrs parentEncoded
                            layout
                            { details | node = 1 }
                            children
                            has
                            (Attr.href url
                                :: Attr.rel "noopener noreferrer"
                                :: Attr.target
                                    (if targetBlank then
                                        "_blank"

                                     else
                                        "_self"
                                    )
                                :: htmlAttrs
                            )
                            classes
                            nearby
                            vars
                            remain

                    Download url downloadName ->
                        renderAttrs parentEncoded
                            layout
                            { details | node = 1 }
                            children
                            has
                            (Attr.href url
                                :: Attr.download downloadName
                                :: htmlAttrs
                            )
                            classes
                            nearby
                            vars
                            remain

                    NodeName nodeName ->
                        renderAttrs parentEncoded
                            layout
                            { details | name = nodeName, node = 4 }
                            children
                            has
                            htmlAttrs
                            classes
                            nearby
                            vars
                            remain

                    Class str ->
                        renderAttrs parentEncoded
                            layout
                            details
                            children
                            (Flag.add flag has)
                            htmlAttrs
                            (str ++ " " ++ classes)
                            nearby
                            vars
                            remain

                    ClassAndStyle cls styleName styleVal ->
                        renderAttrs parentEncoded
                            layout
                            details
                            children
                            (Flag.add flag has)
                            (Attr.style styleName styleVal :: htmlAttrs)
                            (cls ++ " " ++ classes)
                            nearby
                            vars
                            remain

                    ClassAndVar cls varName varVal ->
                        renderAttrs parentEncoded
                            layout
                            details
                            children
                            (Flag.add flag has)
                            htmlAttrs
                            (cls ++ " " ++ classes)
                            nearby
                            (vars ++ "--" ++ varName ++ ":" ++ varVal ++ ";")
                            remain

                    Nearby location elem ->
                        renderAttrs parentEncoded
                            layout
                            details
                            children
                            has
                            htmlAttrs
                            classes
                            (addNearbyElement location elem nearby)
                            vars
                            remain

                    Spacing x y ->
                        if layout == AsEl then
                            renderAttrs parentEncoded
                                layout
                                details
                                children
                                has
                                htmlAttrs
                                classes
                                nearby
                                vars
                                remain

                        else
                            renderAttrs parentEncoded
                                layout
                                { details | spacingX = x, spacingY = y }
                                children
                                (Flag.add flag has)
                                htmlAttrs
                                (Style.classes.spacing ++ " " ++ classes)
                                nearby
                                vars
                                remain

                    Padding padding ->
                        renderAttrs parentEncoded
                            layout
                            { name = details.name
                            , node = details.node
                            , spacingX = details.spacingX
                            , spacingY = details.spacingY
                            , fontSize = details.fontSize
                            , fontOffset = details.fontOffset
                            , fontHeight =
                                details.fontHeight
                            , heightFill = details.heightFill
                            , widthFill = details.widthFill
                            , padding = padding
                            , borders = details.borders
                            , transform = details.transform
                            , animEvents = details.animEvents
                            , hover = details.hover
                            , focus = details.focus
                            , active = details.active
                            }
                            children
                            (Flag.add flag has)
                            (if padding.top == padding.right && padding.top == padding.left && padding.top == padding.bottom then
                                Attr.style "padding"
                                    (String.fromInt padding.top ++ "px")
                                    :: htmlAttrs

                             else
                                Attr.style "padding"
                                    ((String.fromInt padding.top ++ "px ")
                                        ++ (String.fromInt padding.right ++ "px ")
                                        ++ (String.fromInt padding.bottom ++ "px ")
                                        ++ (String.fromInt padding.left ++ "px")
                                    )
                                    :: htmlAttrs
                            )
                            classes
                            nearby
                            vars
                            remain

                    BorderWidth borders ->
                        renderAttrs parentEncoded
                            layout
                            { name = details.name
                            , node = details.node
                            , spacingX = details.spacingX
                            , spacingY = details.spacingY
                            , fontOffset = details.fontOffset
                            , fontHeight =
                                details.fontHeight
                            , fontSize =
                                details.fontSize
                            , heightFill = details.heightFill
                            , widthFill = details.widthFill
                            , padding = details.padding
                            , borders = borders
                            , transform = details.transform
                            , animEvents = details.animEvents
                            , hover = details.hover
                            , focus = details.focus
                            , active = details.active
                            }
                            children
                            (Flag.add flag has)
                            (if borders.top == borders.right && borders.top == borders.left && borders.top == borders.bottom then
                                Attr.style "border-width"
                                    (String.fromInt borders.top ++ "px")
                                    :: htmlAttrs

                             else
                                Attr.style "border-width"
                                    ((String.fromInt borders.top ++ "px ")
                                        ++ (String.fromInt borders.right ++ "px  ")
                                        ++ (String.fromInt borders.bottom ++ "px ")
                                        ++ (String.fromInt borders.left ++ "px")
                                    )
                                    :: htmlAttrs
                            )
                            classes
                            nearby
                            vars
                            remain

                    HeightFill i ->
                        -- if Flag.present Flag.height has then
                        --     renderAttrs parentEncoded
                        --         layout
                        --         details
                        --         children
                        --         has
                        --         htmlAttrs
                        --         classes
                        --         nearby
                        --         vars
                        --         remain
                        -- else
                        renderAttrs parentEncoded
                            layout
                            { name = details.name
                            , node = details.node
                            , spacingX = details.spacingX
                            , spacingY = details.spacingY
                            , fontOffset = details.fontOffset
                            , fontHeight =
                                details.fontHeight
                            , fontSize =
                                details.fontSize
                            , heightFill = i
                            , widthFill = details.widthFill
                            , padding = details.padding
                            , borders = details.borders
                            , transform = details.transform
                            , animEvents = details.animEvents
                            , hover = details.hover
                            , focus = details.focus
                            , active = details.active
                            }
                            children
                            (Flag.add Flag.height has)
                            htmlAttrs
                            classes
                            nearby
                            vars
                            remain

                    WidthFill i ->
                        -- if Flag.present Flag.width has then
                        --     renderAttrs parentEncoded
                        --         layout
                        --         details
                        --         children
                        --         has
                        --         htmlAttrs
                        --         classes
                        --         nearby
                        --         vars
                        --         remain
                        -- else
                        renderAttrs parentEncoded
                            layout
                            { name = details.name
                            , node = details.node
                            , spacingX = details.spacingX
                            , spacingY = details.spacingY
                            , fontOffset = details.fontOffset
                            , fontHeight =
                                details.fontHeight
                            , fontSize =
                                details.fontSize
                            , heightFill = details.heightFill
                            , widthFill = i
                            , padding = details.padding
                            , borders = details.borders
                            , transform = details.transform
                            , animEvents = details.animEvents
                            , hover = details.hover
                            , focus = details.focus
                            , active = details.active
                            }
                            children
                            (Flag.add Flag.width has)
                            htmlAttrs
                            classes
                            nearby
                            vars
                            remain

                    When toMsg when ->
                        renderAttrs parentEncoded
                            layout
                            { name = details.name
                            , node = details.node
                            , spacingX = details.spacingX
                            , spacingY = details.spacingY
                            , fontOffset = details.fontOffset
                            , fontHeight =
                                details.fontHeight
                            , fontSize =
                                details.fontSize
                            , heightFill = details.heightFill
                            , widthFill = details.widthFill
                            , padding = details.padding
                            , borders = details.borders
                            , transform = details.transform
                            , animEvents = details.animEvents
                            , hover =
                                case when.phase of
                                    Hovered ->
                                        case details.hover of
                                            Nothing ->
                                                Just
                                                    { toMsg = toMsg
                                                    , class = when.class
                                                    , transitions = [ when ]
                                                    }

                                            Just transition ->
                                                Just
                                                    { toMsg = toMsg
                                                    , class = when.class ++ "-" ++ transition.class
                                                    , transitions = when :: transition.transitions
                                                    }

                                    _ ->
                                        details.hover
                            , focus =
                                case when.phase of
                                    Focused ->
                                        case details.focus of
                                            Nothing ->
                                                Just
                                                    { toMsg = toMsg
                                                    , class = when.class
                                                    , transitions = [ when ]
                                                    }

                                            Just transition ->
                                                Just
                                                    { toMsg = toMsg
                                                    , class = when.class ++ "-" ++ transition.class
                                                    , transitions = when :: transition.transitions
                                                    }

                                    _ ->
                                        details.focus
                            , active =
                                case when.phase of
                                    Pressed ->
                                        case details.active of
                                            Nothing ->
                                                Just
                                                    { toMsg = toMsg
                                                    , class = when.class
                                                    , transitions = [ when ]
                                                    }

                                            Just transition ->
                                                Just
                                                    { toMsg = toMsg
                                                    , class = when.class ++ "-" ++ transition.class
                                                    , transitions = when :: transition.transitions
                                                    }

                                    _ ->
                                        details.active
                            }
                            children
                            has
                            htmlAttrs
                            classes
                            nearby
                            vars
                            remain

                    WhenAll toMsg trigger classStr props ->
                        let
                            triggerClass =
                                triggerName trigger

                            event =
                                Json.field "animationName" Json.string
                                    |> Json.andThen
                                        (\name ->
                                            if name == triggerClass then
                                                Json.succeed
                                                    (toMsg
                                                        (Animate Nothing trigger classStr props)
                                                    )

                                            else
                                                Json.fail "Nonmatching animation"
                                        )
                        in
                        renderAttrs parentEncoded
                            layout
                            { name = details.name
                            , node = details.node
                            , spacingX = details.spacingX
                            , spacingY = details.spacingY
                            , fontOffset = details.fontOffset
                            , fontHeight =
                                details.fontHeight
                            , fontSize =
                                details.fontSize
                            , heightFill = details.heightFill
                            , widthFill = details.widthFill
                            , padding = details.padding
                            , borders = details.borders
                            , transform = details.transform
                            , animEvents = event :: details.animEvents
                            , hover =
                                details.focus
                            , focus =
                                details.focus
                            , active =
                                details.active
                            }
                            children
                            has
                            htmlAttrs
                            (classStr ++ " " ++ triggerClass ++ " " ++ classes)
                            nearby
                            vars
                            remain

                    Animated toMsg id ->
                        -- if Flag.present Flag.id has then
                        --     renderAttrs parentEncoded
                        --         layout
                        --         details
                        --         children
                        --         has
                        --         htmlAttrs
                        --         classes
                        --         nearby
                        --         vars
                        --         remain
                        -- else
                        let
                            event =
                                Json.map2
                                    (\_ box ->
                                        toMsg (BoxNew id box)
                                    )
                                    (Json.field "animationName" Json.string
                                        |> Json.andThen
                                            (\name ->
                                                if name == "on-rendered" then
                                                    Json.succeed ()

                                                else
                                                    Json.fail "Nonmatching animation"
                                            )
                                    )
                                    decodeBoundingBox
                        in
                        renderAttrs parentEncoded
                            layout
                            { name = details.name
                            , node = details.node
                            , spacingX = details.spacingX
                            , spacingY = details.spacingY
                            , fontOffset = details.fontOffset
                            , fontHeight =
                                details.fontHeight
                            , fontSize =
                                details.fontSize
                            , heightFill = details.heightFill
                            , widthFill = details.widthFill
                            , padding = details.padding
                            , borders = details.borders
                            , transform = details.transform
                            , animEvents = event :: details.animEvents
                            , hover = details.hover
                            , focus = details.focus
                            , active = details.active
                            }
                            children
                            (Flag.add Flag.id has)
                            (Attr.id (toCssId id) :: htmlAttrs)
                            ("on-rendered " ++ toCssClass id ++ " " ++ classes)
                            nearby
                            vars
                            remain


triggerName : Trigger -> String
triggerName trigger =
    case trigger of
        OnHovered ->
            "on-hovered"

        OnPressed ->
            "on-pressed"

        OnFocused ->
            "on-focused"

        OnIf bool ->
            -- Note, could trigger this via attribute index
            ""


{-| -}
onKey : String -> msg -> Html.Attribute msg
onKey desiredCode msg =
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
        (Json.map (\fired -> ( fired, True )) isKey)


upsertTransform : Int -> Float -> Maybe Transform -> Transform
upsertTransform slot val maybeTransform =
    let
        t =
            Maybe.withDefault emptyTransform maybeTransform
    in
    { scale =
        if slot - 3 == 0 then
            val

        else
            t.scale
    , x =
        if slot - 0 == 0 then
            val

        else
            t.x
    , y =
        if slot - 1 == 0 then
            val

        else
            t.y
    , rotation =
        if slot - 2 == 0 then
            val

        else
            t.rotation
    }



-- renderKeyed :
--     Layout
--     -> Int
--     -> List ( String, Element msg )
--     -> String
--     -> Flag.Field
--     -> String
--     -> List (VirtualDom.Attribute msg)
--     -> String
--     -> NearbyChildren msg
--     -> List (Attribute msg)
--     -> Element msg
-- renderKeyed layout spacing children name has styles htmlAttrs classes nearby attrs =
--     case attrs of
--         [] ->
--             let
--                 finalSpacing =
--                     toFloat spacing
--                 renderedChildren =
--                     case nearby of
--                         NoNearbyChildren ->
--                             List.map (Tuple.mapSecond (unwrap finalSpacing)) children
--                         ChildrenBehind behind ->
--                             List.map (Tuple.pair "keyed") behind ++ List.map (Tuple.mapSecond (unwrap finalSpacing)) children
--                         ChildrenInFront inFront ->
--                             List.map (Tuple.mapSecond (unwrap finalSpacing)) children ++ List.map (Tuple.pair "keyed") inFront
--                         ChildrenBehindAndInFront behind inFront ->
--                             List.map (Tuple.pair "keyed") behind
--                                 ++ List.map (Tuple.mapSecond (unwrap finalSpacing)) children
--                                 ++ List.map (Tuple.pair "keyed") inFront
--             in
--             Element
--                 (\space ->
--                     let
--                         finalStyles =
--                             if space == 0 then
--                                 styles
--                             else
--                                 styles ++ Style.prop "margin" (Style.spacingAsMargin space)
--                     in
--                     Html.Keyed.node
--                         name
--                         (Attr.class classes
--                             :: Attr.property "style" (Json.Encode.string finalStyles)
--                             :: htmlAttrs
--                         )
--                         renderedChildren
--                 )
--         NoAttribute :: remain ->
--             renderKeyed layout spacing children name has styles htmlAttrs classes nearby remain
--         (Attr attr) :: remain ->
--             renderKeyed layout spacing children name has styles (attr :: htmlAttrs) classes nearby remain
--         (Link targetBlank url) :: remain ->
--             renderKeyed layout
--                 spacing
--                 children
--                 "a"
--                 has
--                 styles
--                 (Attr.href url
--                     :: Attr.rel "noopener noreferrer"
--                     :: (if targetBlank then
--                             Attr.target "_blank"
--                         else
--                             Attr.target "_self"
--                        )
--                     :: htmlAttrs
--                 )
--                 classes
--                 nearby
--                 remain
--         (Download url downloadName) :: remain ->
--             renderKeyed layout
--                 spacing
--                 children
--                 "a"
--                 has
--                 styles
--                 (Attr.href url
--                     :: Attr.download downloadName
--                     :: htmlAttrs
--                 )
--                 classes
--                 nearby
--                 remain
--         (NodeName nodeName) :: remain ->
--             renderKeyed layout spacing children nodeName has styles htmlAttrs classes nearby remain
--         (Class flag str) :: remain ->
--             if Flag.present flag has then
--                 renderKeyed layout spacing children name has styles htmlAttrs classes nearby remain
--             else
--                 renderKeyed layout spacing children name (Flag.add flag has) styles htmlAttrs (str ++ " " ++ classes) nearby remain
--         (Style flag str) :: remain ->
--             if Flag.present flag has then
--                 renderKeyed layout spacing children name has styles htmlAttrs classes nearby remain
--             else
--                 renderKeyed layout spacing children name (Flag.add flag has) (str ++ styles) htmlAttrs classes nearby remain
--         (ClassAndStyle flag cls sty) :: remain ->
--             if Flag.present flag has then
--                 renderKeyed layout spacing children name has styles htmlAttrs classes nearby remain
--             else
--                 renderKeyed layout
--                     spacing
--                     children
--                     name
--                     (Flag.add flag has)
--                     (sty ++ styles)
--                     htmlAttrs
--                     (cls ++ " " ++ classes)
--                     nearby
--                     remain
--         (Nearby location elem) :: remain ->
--             renderKeyed
--                 layout
--                 spacing
--                 children
--                 name
--                 has
--                 styles
--                 htmlAttrs
--                 classes
--                 (addNearbyElement location elem nearby)
--                 remain
--         (Spacing flag s) :: remain ->
--             if Flag.present flag has then
--                 renderKeyed
--                     layout
--                     spacing
--                     children
--                     name
--                     has
--                     styles
--                     htmlAttrs
--                     classes
--                     nearby
--                     remain
--             else
--                 renderKeyed
--                     layout
--                     s
--                     children
--                     name
--                     (Flag.add flag has)
--                     styles
--                     htmlAttrs
--                     classes
--                     nearby
--                     remain
--         (Padding flag x y) :: remain ->
--             if Flag.present flag has then
--                 renderKeyed
--                     layout
--                     spacing
--                     children
--                     name
--                     has
--                     styles
--                     htmlAttrs
--                     classes
--                     nearby
--                     remain
--             else
--                 renderKeyed
--                     layout
--                     spacing
--                     children
--                     name
--                     (Flag.add flag has)
--                     styles
--                     htmlAttrs
--                     classes
--                     nearby
--                     remain
--         (BorderWidth flag x y) :: remain ->
--             if Flag.present flag has then
--                 renderKeyed
--                     layout
--                     spacing
--                     children
--                     name
--                     has
--                     styles
--                     htmlAttrs
--                     classes
--                     nearby
--                     remain
--             else
--                 renderKeyed
--                     layout
--                     spacing
--                     children
--                     name
--                     (Flag.add flag has)
--                     styles
--                     htmlAttrs
--                     classes
--                     nearby
--                     remain


addNearbyElement : Location -> Element msg -> NearbyChildren msg -> NearbyChildren msg
addNearbyElement location elem existing =
    let
        nearby =
            nearbyElement location elem
    in
    case existing of
        NoNearbyChildren ->
            case location of
                Behind ->
                    ChildrenBehind [ nearby ]

                _ ->
                    ChildrenInFront [ nearby ]

        ChildrenBehind existingBehind ->
            case location of
                Behind ->
                    ChildrenBehind (nearby :: existingBehind)

                _ ->
                    ChildrenBehindAndInFront existingBehind [ nearby ]

        ChildrenInFront existingInFront ->
            case location of
                Behind ->
                    ChildrenBehindAndInFront [ nearby ] existingInFront

                _ ->
                    ChildrenInFront (nearby :: existingInFront)

        ChildrenBehindAndInFront existingBehind existingInFront ->
            case location of
                Behind ->
                    ChildrenBehindAndInFront (nearby :: existingBehind) existingInFront

                _ ->
                    ChildrenBehindAndInFront existingBehind (nearby :: existingInFront)


nearbyElement : Location -> Element msg -> Html.Html msg
nearbyElement location elem =
    Html.div
        [ Attr.class <|
            case location of
                Above ->
                    String.join " "
                        [ Style.classes.nearby
                        , Style.classes.single
                        , Style.classes.above
                        ]

                Below ->
                    String.join " "
                        [ Style.classes.nearby
                        , Style.classes.single
                        , Style.classes.below
                        ]

                OnRight ->
                    String.join " "
                        [ Style.classes.nearby
                        , Style.classes.single
                        , Style.classes.onRight
                        ]

                OnLeft ->
                    String.join " "
                        [ Style.classes.nearby
                        , Style.classes.single
                        , Style.classes.onLeft
                        ]

                InFront ->
                    String.join " "
                        [ Style.classes.nearby
                        , Style.classes.single
                        , Style.classes.inFront
                        ]

                Behind ->
                    String.join " "
                        [ Style.classes.nearby
                        , Style.classes.single
                        , Style.classes.behind
                        ]
        ]
        [ unwrap zero elem
        ]


zero =
    0


textElementClasses : String
textElementClasses =
    Style.classes.any
        ++ " "
        ++ Style.classes.text
        ++ " "
        ++ Style.classes.widthContent
        ++ " "
        ++ Style.classes.heightContent


rootClass =
    Style.classes.root
        ++ " "
        ++ Style.classes.any
        ++ " "
        ++ Style.classes.single


rowClass =
    Style.classes.any
        ++ " "
        ++ Style.classes.row
        ++ " "
        ++ Style.classes.nowrap
        ++ " "
        ++ Style.classes.contentLeft
        ++ " "
        ++ Style.classes.contentCenterY


wrappedRowClass =
    Style.classes.any ++ " " ++ Style.classes.row ++ " " ++ Style.classes.wrapped


columnClass =
    Style.classes.any
        ++ " "
        ++ Style.classes.column
        ++ " "
        ++ Style.classes.contentTop
        ++ " "
        ++ Style.classes.contentLeft


singleClass =
    Style.classes.any ++ " " ++ Style.classes.single


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

        AsWrappedRow ->
            wrappedRowClass

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


decodeBoundingBox2 =
    Json.field "target"
        (Json.map4
            Box
            (Json.field "clientLeft" Json.float)
            (Json.field "clientTop" Json.float)
            (Json.field "clientWidth" Json.float)
            (Json.field "clientHeight" Json.float)
        )


decodeBoundingBox : Json.Decoder Box
decodeBoundingBox =
    Json.field "target"
        (Json.map3
            (\w h ( top, left ) ->
                -- Debug.log "final"
                { width = w
                , height = h
                , x = left
                , y = top
                }
            )
            (Json.field "offsetWidth" Json.float)
            (Json.field "offsetHeight" Json.float)
            (decodeElementPosition True 0 0)
        )


type alias ElementBox =
    { clientLeft : Float
    , clientTop : Float
    , offsetLeft : Float
    , offsetTop : Float
    }


decodeInitialElementPosition =
    Json.map4 ElementBox
        (Json.field "clientLeft" Json.float)
        (Json.field "clientTop" Json.float)
        (Json.field "offsetLeft" Json.float)
        (Json.field "offsetTop" Json.float)


{-| -}
decodeElementPosition : Bool -> Float -> Float -> Json.Decoder ( Float, Float )
decodeElementPosition ignoreBorders top left =
    Json.oneOf
        [ Json.field "offsetParent" (Json.nullable (Json.succeed ()))
            |> Json.andThen
                (\maybeNull ->
                    case maybeNull of
                        Nothing ->
                            -- there is no offset parent
                            Json.map4
                                (\clientLeft clientTop offsetLeft offsetTop ->
                                    let
                                        newTop =
                                            if ignoreBorders then
                                                top + offsetTop

                                            else
                                                top + (offsetTop + clientTop)

                                        newLeft =
                                            if ignoreBorders then
                                                left + offsetLeft

                                            else
                                                left + (offsetLeft + clientLeft)
                                    in
                                    ( newTop, newLeft )
                                )
                                (Json.field "clientLeft" Json.float)
                                (Json.field "clientTop" Json.float)
                                (Json.field "offsetLeft" Json.float)
                                (Json.field "offsetTop" Json.float)

                        Just () ->
                            -- there is an offset parent
                            Json.map4
                                (\clientLeft clientTop offsetLeft offsetTop ->
                                    let
                                        newTop =
                                            if ignoreBorders then
                                                top + offsetTop

                                            else
                                                top + (offsetTop + clientTop)

                                        newLeft =
                                            if ignoreBorders then
                                                left + offsetLeft

                                            else
                                                left + (offsetLeft + clientLeft)
                                    in
                                    ( newTop, newLeft )
                                )
                                (Json.field "clientLeft" Json.float)
                                (Json.field "clientTop" Json.float)
                                (Json.field "offsetLeft" Json.float)
                                (Json.field "offsetTop" Json.float)
                                |> Json.andThen
                                    (\( newTop, newLeft ) ->
                                        Json.field "offsetParent"
                                            (Json.lazy
                                                (\_ ->
                                                    decodeElementPosition
                                                        False
                                                        newTop
                                                        newLeft
                                                )
                                            )
                                    )
                )
        , Json.succeed ( top, left )
        ]


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
