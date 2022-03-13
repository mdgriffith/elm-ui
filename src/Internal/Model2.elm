module Internal.Model2 exposing (..)

import Animator
import Animator.Timeline
import Animator.Watcher
import Browser.Dom
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Html.Keyed
import Html.Lazy
import Internal.BitEncodings as Bits
import Internal.BitField as BitField exposing (BitField)
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
    = Element (BitField.Bits Bits.Inheritance -> Html.Html msg)


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

        AnimationAdd trigger css ->
            AnimationAdd trigger css

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
    | AnimationAdd Trigger Animator.Css
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

        AnimationAdd trigger css ->
            let
                _ =
                    Debug.log "CSS " css
            in
            if Set.member css.hash details.added then
                ( unchanged, Cmd.none )

            else
                let
                    newClass =
                        ("." ++ css.hash ++ phaseName trigger ++ phasePseudoClass trigger ++ " {")
                            ++ renderProps css.props ""
                            ++ "}"
                in
                ( State
                    { rules = css.keyframes :: newClass :: details.rules
                    , added = Set.insert css.hash details.added
                    , boxes = details.boxes
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

                    new =
                        ("." ++ classString ++ phasePseudoClass trigger ++ " {")
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

                    phasePseudoClassStr =
                        case phase of
                            Focused ->
                                ":focus"

                            Hovered ->
                                ":hover"

                            Pressed ->
                                ":active"

                    new =
                        ("." ++ classStr ++ phasePseudoClassStr ++ " {")
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


renderProps : List ( String, String ) -> String -> String
renderProps props str =
    case props of
        [] ->
            str

        ( name, val ) :: remain ->
            renderProps remain
                (str ++ name ++ ":" ++ val ++ ";")


phaseName : Trigger -> String
phaseName trigger =
    case trigger of
        OnFocused ->
            "-focus"

        OnHovered ->
            "-hover"

        OnPressed ->
            "-active"

        OnIf on ->
            ""


phasePseudoClass : Trigger -> String
phasePseudoClass trigger =
    case trigger of
        OnFocused ->
            ":focus"

        OnHovered ->
            ":hover"

        OnPressed ->
            ":active"

        OnIf on ->
            ""


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
                        BitField.get Bits.duration approach.durDelay

                    delay =
                        BitField.get Bits.delay approach.durDelay

                    curve =
                        "cubic-bezier("
                            ++ (String.fromFloat (BitField.getPercentage Bits.bezOne approach.curve) ++ ", ")
                            ++ (String.fromFloat
                                    (BitField.getPercentage Bits.bezTwo approach.curve)
                                    ++ ", "
                               )
                            ++ (String.fromFloat
                                    (BitField.getPercentage Bits.bezThree approach.curve)
                                    ++ ", "
                               )
                            ++ (String.fromFloat
                                    (BitField.getPercentage Bits.bezFour approach.curve)
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
                    BitField.get Bits.duration transition.arriving.durDelay

                delay =
                    BitField.get Bits.delay transition.arriving.durDelay

                curve =
                    "cubic-bezier("
                        ++ (String.fromFloat (BitField.getPercentage Bits.bezOne transition.arriving.curve) ++ ", ")
                        ++ (String.fromFloat (BitField.getPercentage Bits.bezTwo transition.arriving.curve) ++ ", ")
                        ++ (String.fromFloat (BitField.getPercentage Bits.bezThree transition.arriving.curve) ++ ", ")
                        ++ (String.fromFloat (BitField.getPercentage Bits.bezFour transition.arriving.curve) ++ " ")
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
    BitField.toString transition.arriving.durDelay
        ++ "-"
        ++ BitField.toString transition.arriving.curve
        ++ "-"
        ++ BitField.toString transition.departing.durDelay
        ++ "-"
        ++ BitField.toString transition.departing.curve


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

                OnKey event ->
                    OnKey (Attr.map fn event)

                Spacing x y ->
                    Spacing x y

                Padding edges ->
                    Padding edges

                Attr a ->
                    Attr (Attr.map fn a)

                Link link ->
                    Link link

                Class cls ->
                    Class cls

                Style styleDetails ->
                    Style styleDetails

                Nearby loc el ->
                    Nearby loc (map fn el)

                Transition2 t ->
                    Transition2
                        { toMsg = uiFn
                        , trigger = t.trigger
                        , css = t.css
                        }

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
    | OnKey (Html.Attribute msg)
    | Attr (Html.Attribute msg)
    | Link
        { newTab : Bool
        , url : String
        , download : Maybe String
        }
    | WidthFill Int
    | HeightFill Int
    | Font
        { family : String
        , adjustments :
            Maybe (BitField.Bits Bits.Inheritance)
        , variants : String
        , smallCaps : Bool
        , weight : String
        , size : String
        }
    | FontSize Int
    | Spacing Int Int
    | Padding Edges
    | TransformPiece TransformSlot Float
    | Class String
    | Style
        { class : String
        , styleName : String
        , styleVal : String
        }
    | Nearby Location (Element msg)
    | Transition2
        { toMsg : Msg msg -> msg
        , trigger : Trigger
        , css : Animator.Css
        }
    | Animated (Msg msg -> msg) Id


type ResponsiveInt
    = StaticInt Int
    | ResponsiveInt String


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
    { durDelay : BitField.Bits Bits.Transition
    , curve : BitField.Bits Bits.Bezier
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


hasFlags flags (Attribute attr) =
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
    | ResponsiveBreakpoints String


type Transition
    = Transition
        { arriving :
            Approach
        , departing :
            Approach
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
        Maybe Style.Shadow
    }


focusDefaultStyle : FocusStyle
focusDefaultStyle =
    { backgroundColor = Nothing
    , borderColor = Nothing
    , shadow =
        Just
            { x = 0
            , y = 0
            , color =
                Style.Rgb 155 203 255
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
    { fontSize = -1
    , transform = Nothing
    , animEvents = []
    }


unwrap : BitField.Bits Bits.Inheritance -> Element msg -> Html.Html msg
unwrap s el =
    case el of
        Element html ->
            html s


unwrapKeyed : BitField.Bits Bits.Inheritance -> ( String, Element msg ) -> ( String, Html.Html msg )
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
            if BitField.equal encoded Bits.row || BitField.equal encoded Bits.column then
                Html.span [ Attr.class textElementClasses ] [ Html.text str ]

            else
                let
                    height =
                        encoded
                            |> BitField.getPercentage Bits.fontHeight

                    offset =
                        encoded
                            |> BitField.getPercentage Bits.fontOffset

                    spacingY =
                        encoded
                            |> BitField.get Bits.spacingY

                    spacingX =
                        encoded
                            |> BitField.get Bits.spacingX

                    attrs =
                        [ Attr.class textElementClasses
                        ]

                    attrsWithParentSpacing =
                        if height == 1 && offset == 0 then
                            Attr.style "margin"
                                (String.fromInt spacingY ++ "px " ++ String.fromInt spacingX ++ "px")
                                :: attrs

                        else
                            let
                                -- This doesn't totally make sense to me, but it works :/
                                -- I thought that the top margin should have a smaller negative margin than the bottom
                                -- however it seems evenly distributing the empty space works out.
                                topVal =
                                    offset

                                bottomVal =
                                    (1 - height) - offset

                                even =
                                    (topVal + bottomVal) / 2

                                margin =
                                    "-"
                                        ++ String.fromFloat (even + 0.25)
                                        ++ "em "
                                        ++ (String.fromInt spacingX ++ "0px ")
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


attrIf bool attr =
    if bool then
        attr

    else
        noAttr


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


attributeWith flag a =
    Attribute
        { flag = flag
        , attr = Attr a
        }


style : String -> String -> Attribute msg
style name val =
    Attribute
        { flag = Flag.skip
        , attr =
            Style
                { class = ""
                , styleName = name
                , styleVal = val
                }
        }


styleWith : Flag -> String -> String -> Attribute msg
styleWith flag name val =
    Attribute
        { flag = flag
        , attr =
            Style
                { class = ""
                , styleName = name
                , styleVal = val
                }
        }


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
        { flag = flag
        , attr =
            Style
                v
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
    { fontSize : Int
    , transform : Maybe Transform
    , animEvents : List (Json.Decoder msg)
    }


spacerTop : Float -> Html.Html msg
spacerTop space =
    Html.div
        [ Attr.style "margin-top"
            ("calc(var(--vacuum-top) * (1em/var(--font-size-factor)) + "
                ++ String.fromFloat space
                ++ "px)"
            )
        ]
        []


spacerBottom : Float -> Html.Html msg
spacerBottom space =
    Html.div
        [ Attr.style "margin-top"
            ("calc(var(--vacuum-bottom) * (1em/var(--font-size-factor)) + "
                ++ String.fromFloat space
                ++ "px)"
            )
        ]
        []


renderLayout :
    { options : List Option }
    -> State
    -> List (Attribute msg)
    -> Element msg
    -> Html.Html msg
renderLayout { options } (State state) attrs content =
    unwrap zero <|
        element AsRoot
            attrs
            [ Element
                (\_ ->
                    Html.Keyed.node "div"
                        []
                        [ ( "options", Html.Lazy.lazy renderOptions options )
                        , ( "static", staticStyles )
                        , ( "animations", Html.Lazy.lazy styleRules state.rules )
                        , ( "boxes"
                          , Html.div [] (List.map viewBox state.boxes)
                          )
                        ]
                )
            , content
            ]


staticStyles : Html.Html msg
staticStyles =
    Html.div []
        [ Html.node "style"
            []
            [ Html.text Style.rules ]
        ]


styleRules : List String -> Html.Html msg
styleRules styleStr =
    Html.div []
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
        ]
        [--Html.text (Debug.toString id)
        ]


element :
    Layout
    -> List (Attribute msg)
    -> List (Element msg)
    -> Element msg
element layout attrs children =
    Element
        (\parentBits ->
            let
                myBits =
                    Bits.clearSpacing parentBits
                        |> (if layout == AsRow then
                                BitField.set Bits.isRow 1

                            else
                                BitField.set Bits.isRow 0
                           )

                rendered =
                    renderAttrs
                        parentBits
                        myBits
                        layout
                        emptyDetails
                        (ElemChildren children emptyNearbys)
                        Flag.none
                        []
                        -- the "" below is the starting class
                        -- though we want some defaults based on the layout
                        (contextClasses layout)
                        (List.reverse attrs)

                finalAttrs =
                    if Flag.present Flag.hasCssVars rendered.fields then
                        let
                            styleStr =
                                renderInlineStylesToString
                                    parentBits
                                    myBits
                                    layout
                                    rendered.details
                                    rendered.fields
                                    ""
                                    (List.reverse attrs)
                                    |> Debug.log "STYLE"
                        in
                        Attr.property "style"
                            (Json.Encode.string
                                styleStr
                            )
                            :: rendered.attrs

                    else
                        rendered.attrs
            in
            case rendered.children of
                Children finalChildren ->
                    if Flag.present Flag.isLink rendered.fields then
                        Html.a finalAttrs finalChildren

                    else
                        Html.div finalAttrs finalChildren

                _ ->
                    Html.div finalAttrs []
        )


elementAs :
    (List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg)
    -> Layout
    -> List (Attribute msg)
    -> List (Element msg)
    -> Element msg
elementAs toNode layout attrs children =
    Element
        (\parentBits ->
            let
                myBits =
                    Bits.clearSpacing parentBits
                        |> (if layout == AsRow then
                                BitField.set Bits.isRow 1

                            else
                                BitField.set Bits.isRow 0
                           )

                rendered =
                    renderAttrs
                        parentBits
                        myBits
                        layout
                        emptyDetails
                        (ElemChildren children emptyNearbys)
                        Flag.none
                        []
                        -- the "" below is the starting class
                        -- though we want some defaults based on the layout
                        (contextClasses layout)
                        (List.reverse attrs)

                finalAttrs =
                    if Flag.present Flag.hasCssVars rendered.fields then
                        let
                            styleStr =
                                renderInlineStylesToString
                                    parentBits
                                    myBits
                                    layout
                                    rendered.details
                                    rendered.fields
                                    ""
                                    (List.reverse attrs)
                        in
                        Attr.property "style"
                            (Json.Encode.string
                                styleStr
                            )
                            :: rendered.attrs

                    else
                        rendered.attrs
            in
            case rendered.children of
                Children finalChildren ->
                    if Flag.present Flag.isLink rendered.fields then
                        Html.a finalAttrs finalChildren

                    else
                        toNode finalAttrs finalChildren

                _ ->
                    toNode finalAttrs []
        )


emptyNearbys =
    { behind = []
    , inFront = []
    }


elementKeyed :
    String
    -> Layout
    -> List (Attribute msg)
    -> List ( String, Element msg )
    -> Element msg
elementKeyed name layout attrs children =
    Element
        (\parentBits ->
            let
                rendered =
                    renderAttrs
                        parentBits
                        (Bits.clearSpacing parentBits
                            |> (if layout == AsRow then
                                    BitField.set Bits.isRow 1

                                else
                                    BitField.set Bits.isRow 0
                               )
                        )
                        layout
                        emptyDetails
                        (ElemKeyed children emptyKeyedNearbys)
                        Flag.none
                        []
                        -- the "" below is the starting class
                        -- though we want some defaults based on the layout
                        (contextClasses layout)
                        (List.reverse attrs)

                finalAttrs =
                    if Flag.present Flag.hasCssVars rendered.fields then
                        let
                            styleStr =
                                renderInlineStylesToString
                                    parentBits
                                    rendered.myBits
                                    layout
                                    rendered.details
                                    rendered.fields
                                    ""
                                    (List.reverse attrs)
                        in
                        Attr.property "style"
                            (Json.Encode.string
                                styleStr
                            )
                            :: rendered.attrs

                    else
                        rendered.attrs
            in
            case rendered.children of
                Keyed finalChildren ->
                    Html.Keyed.node
                        (if Flag.present Flag.isLink rendered.fields then
                            "a"

                         else
                            name
                        )
                        finalAttrs
                        finalChildren

                _ ->
                    Html.div finalAttrs []
        )


emptyKeyedNearbys =
    { behind = []
    , inFront = []
    }


type ElemChildren msg
    = ElemChildren
        (List (Element msg))
        { behind : List (Element msg)
        , inFront : List (Element msg)
        }
    | ElemKeyed
        (List ( String, Element msg ))
        { behind : List ( String, Element msg )
        , inFront : List ( String, Element msg )
        }


type Children msg
    = Children (List (Html.Html msg))
    | Keyed (List ( String, Html.Html msg ))


fontSizeAdjusted : Int -> Float -> Float
fontSizeAdjusted size height =
    toFloat size * (1 / height)


{-| We track a number of things in the function and it can be difficult to remember exactly why.

A lot of these questions essentially fall to, "do we do the work or do we count on the browser to do it."

So, let's try to give an overview of all the systems:

  - In order to render Font.gradient, (possibly) TextColumn spacing, and Responsive.value/fluid, we need to maintain css variables
    This means detecting if we need to render a css variable, and at the end, rerender styles as a `Property` instead of `style`.

-}
renderAttrs :
    BitField.Bits Bits.Inheritance
    -> BitField.Bits Bits.Inheritance
    -> Layout
    -> Details msg
    -> ElemChildren msg
    -> Flag.Field
    -> List (VirtualDom.Attribute msg)
    -> String
    -> List (Attribute msg)
    ->
        { fields : Flag.Field
        , myBits : BitField.Bits Bits.Inheritance
        , details : Details msg
        , attrs : List (Html.Attribute msg)
        , children : Children msg
        }
renderAttrs parentBits myBits layout details children has htmlAttrs classes attrs =
    case attrs of
        [] ->
            let
                attrsWithParentSpacing =
                    if Bits.hasSpacing parentBits && (layout == AsParagraph || layout == AsTextColumn) then
                        Attr.style "margin"
                            ((parentBits
                                |> BitField.get Bits.spacingY
                                |> String.fromInt
                             )
                                ++ "px "
                                ++ (parentBits
                                        |> BitField.get Bits.spacingX
                                        |> String.fromInt
                                   )
                                ++ "px"
                            )
                            :: htmlAttrs

                    else
                        htmlAttrs

                attrsWithTransform =
                    case details.transform of
                        Nothing ->
                            attrsWithParentSpacing

                        Just trans ->
                            Attr.style "transform"
                                (transformToString trans)
                                :: attrsWithParentSpacing

                adjustmentNotSet =
                    not (Flag.present Flag.fontAdjustment has)

                -- {-
                --    no fontsize or adjustment -> skip
                --    if fontsize is set, not adjustment:
                --        -> set fontsize px
                --    adjsutment, not fontsize
                --        -> set font size (em
                --    if both are set
                --        -> fontsize px
                -- -}
                -- attrsWithFontSize =
                --     if details.fontSize == -1 && adjustmentNotSet then
                --         -- no fontsize or adjustment set
                --         attrsWithTransform
                --     else if adjustmentNotSet then
                --         -- font size is set, not adjustment
                --         -- set font size, adjust via inherited value
                --         let
                --             height =
                --                 parentBits
                --                     |> BitField.getPercentage Bits.fontHeight
                --         in
                --         Attr.style "font-size"
                --             (String.fromFloat
                --                 (toFloat details.fontSize * (1 / height))
                --                 ++ "px"
                --             )
                --             :: attrsWithTransform
                --     else if details.fontSize /= -1 then
                --         -- a font size is set as well as an adjustment
                --         -- set font size from details
                --         let
                --             fontHeight =
                --                 myBits
                --                     |> BitField.getPercentage Bits.fontHeight
                --         in
                --         Attr.style "font-size"
                --             (String.fromFloat
                --                 (toFloat details.fontSize * (1 / fontHeight))
                --                 ++ "px"
                --             )
                --             :: attrsWithTransform
                --     else
                --         -- a font size is NOT set, but we have an adjustment
                --         -- operate on `em`
                --         let
                --             fontHeight =
                --                 myBits
                --                     |> BitField.getPercentage Bits.fontHeight
                --         in
                --         Attr.style "font-size"
                --             (String.fromFloat
                --                 (1 / fontHeight)
                --                 ++ "em"
                --             )
                --             :: attrsWithTransform
                attrsWithAnimations =
                    case details.animEvents of
                        [] ->
                            attrsWithTransform

                        animEvents ->
                            Events.on "animationstart"
                                (Json.oneOf details.animEvents)
                                :: attrsWithTransform

                attrsWithWidthFill =
                    if Flag.present Flag.width has then
                        -- we know we've set the width to fill
                        attrsWithAnimations

                    else if
                        not
                            (Flag.present Flag.borderWidth has
                                || Flag.present Flag.background has
                                || Flag.present Flag.event has
                            )
                            && not (BitField.has Bits.isRow parentBits)
                    then
                        Attr.class Style.classes.widthFill
                            :: attrsWithAnimations

                    else
                        -- we are not widthFill, we set it to widthContent
                        Attr.class Style.classes.widthContent
                            :: attrsWithAnimations

                finalAttrs =
                    if Flag.present Flag.height has then
                        -- we know we've set the width to fill
                        Attr.class classes
                            :: attrsWithWidthFill

                    else if
                        not
                            (Flag.present Flag.borderWidth has
                                || Flag.present Flag.background has
                                || Flag.present Flag.event has
                            )
                            && BitField.has Bits.isRow parentBits
                    then
                        Attr.class (classes ++ " " ++ Style.classes.heightFill)
                            :: attrsWithWidthFill

                    else
                        Attr.class (classes ++ " " ++ Style.classes.heightContent)
                            :: attrsWithWidthFill

                {- RENDER NEARBY CHILDREN -}
                renderedChildren =
                    case children of
                        ElemChildren elems nearby ->
                            Children <|
                                (List.map (unwrap myBits) nearby.behind
                                    ++ List.map (unwrap myBits) elems
                                    ++ List.map (unwrap myBits) nearby.inFront
                                )

                        ElemKeyed keyedElems nearby ->
                            Keyed <|
                                List.map
                                    (unwrapKeyed myBits)
                                    nearby.behind
                                    ++ List.map (unwrapKeyed myBits) keyedElems
                                    ++ List.map
                                        (unwrapKeyed myBits)
                                        nearby.inFront

                spacingY =
                    BitField.get Bits.spacingY myBits

                finalChildren =
                    case renderedChildren of
                        Keyed keyedChilds ->
                            case layout of
                                AsParagraph ->
                                    Keyed <|
                                        if Flag.present Flag.id has then
                                            ( "ui-movable", Html.Keyed.node "div" (Attr.class "ui-movable" :: finalAttrs) keyedChilds )
                                                :: ( "top-spacer", spacerTop (toFloat spacingY / -2) )
                                                :: keyedChilds
                                                ++ [ ( "bottom-spacer", spacerBottom (toFloat spacingY / -2) ) ]

                                        else
                                            ( "top-spacer", spacerTop (toFloat spacingY / -2) )
                                                :: keyedChilds
                                                ++ [ ( "bottom-spacer", spacerBottom (toFloat spacingY / -2) ) ]

                                _ ->
                                    if Flag.present Flag.id has then
                                        (( "ui-movable", Html.Keyed.node "div" (Attr.class "ui-movable" :: finalAttrs) keyedChilds )
                                            :: keyedChilds
                                        )
                                            |> Keyed

                                    else
                                        renderedChildren

                        Children childs ->
                            case layout of
                                AsParagraph ->
                                    Children <|
                                        if Flag.present Flag.id has then
                                            Html.div (Attr.class "ui-movable" :: finalAttrs) childs
                                                :: spacerTop (toFloat spacingY / -2)
                                                :: childs
                                                ++ [ spacerBottom (toFloat spacingY / -2) ]

                                        else
                                            spacerTop (toFloat spacingY / -2)
                                                :: childs
                                                ++ [ spacerBottom (toFloat spacingY / -2) ]

                                _ ->
                                    if Flag.present Flag.id has then
                                        (Html.div (Attr.class "ui-movable" :: finalAttrs) childs
                                            :: childs
                                        )
                                            |> Children

                                    else
                                        renderedChildren
            in
            { fields = has
            , myBits = myBits
            , attrs =
                finalAttrs
            , children = finalChildren
            , details = details
            }

        (Attribute { flag, attr }) :: remain ->
            let
                alwaysRender =
                    case flag of
                        Flag.Flag f ->
                            f == 0

                previouslyRendered =
                    if alwaysRender then
                        False

                    else
                        Flag.present flag has
            in
            if previouslyRendered then
                renderAttrs parentBits myBits layout details children has htmlAttrs classes remain

            else
                case attr of
                    NoAttribute ->
                        renderAttrs parentBits myBits layout details children has htmlAttrs classes remain

                    FontSize size ->
                        renderAttrs parentBits
                            myBits
                            layout
                            details
                            children
                            (Flag.add flag has)
                            (Attr.style "font-size"
                                (String.fromFloat
                                    (fontSizeAdjusted size
                                        (parentBits
                                            |> BitField.getPercentage Bits.fontHeight
                                        )
                                    )
                                    ++ "px"
                                )
                                :: htmlAttrs
                            )
                            classes
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
                        renderAttrs parentBits
                            (case font.adjustments of
                                Nothing ->
                                    myBits

                                Just adj ->
                                    myBits
                                        |> BitField.copy Bits.fontHeight adj
                                        |> BitField.copy Bits.fontOffset adj
                            )
                            layout
                            { fontSize =
                                details.fontSize
                            , transform = details.transform
                            , animEvents = details.animEvents
                            }
                            children
                            (case font.adjustments of
                                Nothing ->
                                    has

                                Just _ ->
                                    Flag.add Flag.fontAdjustment has
                            )
                            (Attr.style "font-family" font.family
                                :: Attr.style "font-size" font.size
                                :: Attr.style "font-weight" font.weight
                                :: withFeatures
                            )
                            classes
                            remain

                    TransformPiece slot val ->
                        renderAttrs parentBits
                            myBits
                            layout
                            { details | transform = Just (upsertTransform slot val details.transform) }
                            children
                            (Flag.add flag has)
                            htmlAttrs
                            classes
                            remain

                    Attr htmlAttr ->
                        renderAttrs parentBits
                            myBits
                            layout
                            details
                            children
                            (Flag.add flag has)
                            (htmlAttr :: htmlAttrs)
                            classes
                            remain

                    OnPress msg ->
                        -- Make focusable
                        -- Attach keyboard handler
                        -- Attach click handler
                        renderAttrs parentBits
                            myBits
                            layout
                            details
                            children
                            (Flag.add flag has)
                            (Events.stopPropagationOn "pointerdown"
                                (Json.succeed ( msg, True ))
                                :: onKey "Enter" msg
                                :: Attr.tabindex 0
                                :: htmlAttrs
                            )
                            (Style.classes.cursorPointer
                                ++ " "
                                ++ classes
                            )
                            remain

                    OnKey handler ->
                        renderAttrs parentBits
                            myBits
                            layout
                            details
                            children
                            (Flag.add flag has)
                            (handler
                                :: Attr.tabindex 0
                                :: htmlAttrs
                            )
                            classes
                            remain

                    Link link ->
                        renderAttrs parentBits
                            myBits
                            layout
                            details
                            children
                            (Flag.add flag has)
                            (Attr.href link.url
                                :: Attr.rel "noopener noreferrer"
                                :: (case link.download of
                                        Nothing ->
                                            Attr.target
                                                (if link.newTab then
                                                    "_blank"

                                                 else
                                                    "_self"
                                                )

                                        Just downloadName ->
                                            Attr.download downloadName
                                   )
                                :: htmlAttrs
                            )
                            classes
                            remain

                    Style styleDetails ->
                        let
                            isVar =
                                String.startsWith "--" styleDetails.styleName
                        in
                        renderAttrs parentBits
                            myBits
                            layout
                            details
                            children
                            (if isVar then
                                has
                                    |> Flag.add flag
                                    |> Flag.add Flag.hasCssVars

                             else
                                Flag.add flag has
                            )
                            (if isVar then
                                htmlAttrs

                             else
                                Attr.style styleDetails.styleName styleDetails.styleVal :: htmlAttrs
                            )
                            (case styleDetails.class of
                                "" ->
                                    classes

                                newClass ->
                                    newClass ++ " " ++ classes
                            )
                            remain

                    Class str ->
                        renderAttrs parentBits
                            myBits
                            layout
                            details
                            children
                            (Flag.add flag has)
                            htmlAttrs
                            (str ++ " " ++ classes)
                            remain

                    Nearby location elem ->
                        renderAttrs parentBits
                            myBits
                            layout
                            details
                            (addNearbyElement location elem children)
                            has
                            htmlAttrs
                            classes
                            remain

                    Spacing x y ->
                        renderAttrs parentBits
                            (if layout == AsTextColumn || layout == AsParagraph then
                                myBits
                                    |> BitField.set Bits.spacingX x
                                    |> BitField.set Bits.spacingY y

                             else
                                myBits
                            )
                            layout
                            details
                            children
                            (Flag.add flag has)
                            (if layout == AsParagraph then
                                Attr.style "line-height"
                                    ("calc(1em + " ++ String.fromInt y ++ "px")
                                    :: htmlAttrs

                             else
                                Attr.style "gap"
                                    (String.fromInt y
                                        ++ "px "
                                        ++ String.fromInt x
                                        ++ "px"
                                    )
                                    :: htmlAttrs
                            )
                            (Style.classes.spacing ++ " " ++ classes)
                            remain

                    Padding padding ->
                        -- This is tracked because we're doing something weird with Input rendering.
                        -- Myabe it's not necessary if we get smarter about how the Text input is rendered?
                        renderAttrs parentBits
                            myBits
                            layout
                            details
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
                            remain

                    HeightFill i ->
                        renderAttrs parentBits
                            myBits
                            layout
                            details
                            children
                            (Flag.add flag has)
                            -- we're in a column
                            (if i > 1 && not (BitField.has Bits.isRow parentBits) then
                                Attr.style "flex-grow" (String.fromInt (i * 100000))
                                    :: htmlAttrs

                             else
                                htmlAttrs
                            )
                            (if i <= 0 then
                                classes

                             else
                                Style.classes.heightFill
                                    ++ " "
                                    ++ classes
                            )
                            remain

                    WidthFill i ->
                        renderAttrs parentBits
                            myBits
                            layout
                            details
                            children
                            (Flag.add flag has)
                            (if i > 1 && BitField.has Bits.isRow parentBits then
                                Attr.style "flex-grow" (String.fromInt (i * 100000))
                                    :: htmlAttrs

                             else
                                htmlAttrs
                            )
                            (if i <= 0 then
                                classes

                             else
                                Style.classes.widthFill
                                    ++ " "
                                    ++ classes
                            )
                            remain

                    Transition2 { toMsg, trigger, css } ->
                        let
                            triggerClass =
                                triggerName trigger

                            styleClass =
                                css.hash ++ phaseName trigger

                            event =
                                Json.field "animationName" Json.string
                                    |> Json.andThen
                                        (\name ->
                                            if name == triggerClass then
                                                Json.succeed
                                                    (toMsg
                                                        (AnimationAdd trigger css)
                                                    )

                                            else
                                                Json.fail "Nonmatching animation"
                                        )
                        in
                        renderAttrs parentBits
                            myBits
                            layout
                            details
                            children
                            has
                            (Events.on "animationstart" event
                                :: htmlAttrs
                            )
                            (triggerClass ++ " " ++ styleClass ++ " " ++ classes)
                            remain

                    Animated toMsg id ->
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
                        renderAttrs parentBits
                            myBits
                            layout
                            { fontSize =
                                details.fontSize
                            , transform = details.transform
                            , animEvents = event :: details.animEvents
                            }
                            children
                            (Flag.add Flag.id has)
                            (Attr.id (toCssId id) :: htmlAttrs)
                            ("on-rendered ui-placeholder " ++ toCssClass id ++ " " ++ classes)
                            remain


{-| In order to make css variables work, we need to gather all styles into a `Attribute.property "style"`

However, that method is slower than calling `Html.Attributes.style` directly,
because it requires the browser to parse the string instead of setting styles directly via style.setProperty or whatever.

This does mean we only want to use css variables sparingly.

-}
renderInlineStylesToString :
    BitField.Bits Bits.Inheritance
    -> BitField.Bits Bits.Inheritance
    -> Layout
    -> Details msg
    -> Flag.Field
    -> String
    -> List (Attribute msg)
    -> String
renderInlineStylesToString parentBits myBits layout details has vars attrs =
    case attrs of
        [] ->
            let
                varsWithParentSpacing =
                    if Bits.hasSpacing parentBits && (layout == AsParagraph || layout == AsTextColumn) then
                        "margin: "
                            ++ ((parentBits
                                    |> BitField.get Bits.spacingY
                                    |> String.fromInt
                                )
                                    ++ "px "
                                    ++ (parentBits
                                            |> BitField.get Bits.spacingX
                                            |> String.fromInt
                                       )
                                    ++ "px;"
                               )
                            ++ vars

                    else
                        vars

                varsWithTransform =
                    case details.transform of
                        Nothing ->
                            varsWithParentSpacing

                        Just trans ->
                            "transform: "
                                ++ transformToString trans
                                ++ ";"
                                ++ varsWithParentSpacing

                adjustmentNotSet =
                    not (Flag.present Flag.fontAdjustment has)

                {-
                   no fontsize or adjustment -> skip
                   if fontsize is set, not adjustment:
                       -> set fontsize px

                   adjsutment, not fontsize
                       -> set font size (em
                   if both are set
                       -> fontsize px


                -}
                varsWithFontSize =
                    if details.fontSize == -1 && adjustmentNotSet then
                        -- no fontsize or adjustment set
                        varsWithTransform

                    else if adjustmentNotSet then
                        -- font size is set, not adjustment
                        -- set font size, adjust via inherited value
                        let
                            height =
                                parentBits
                                    |> BitField.getPercentage Bits.fontHeight
                        in
                        "font-size: "
                            ++ (String.fromFloat
                                    (toFloat details.fontSize * (1 / height))
                                    ++ "px;"
                               )
                            ++ varsWithTransform

                    else if details.fontSize /= -1 then
                        -- a font size is set as well as an adjustment
                        -- set font size from details
                        let
                            fontHeight =
                                myBits
                                    |> BitField.getPercentage Bits.fontHeight
                        in
                        "font-size: "
                            ++ (String.fromFloat
                                    (toFloat details.fontSize * (1 / fontHeight))
                                    ++ "px;"
                               )
                            ++ varsWithTransform

                    else
                        -- a font size is NOT set, but we have an adjustment
                        -- operate on `em`
                        let
                            fontHeight =
                                myBits
                                    |> BitField.getPercentage Bits.fontHeight
                        in
                        "font-size: "
                            ++ (String.fromFloat
                                    (1 / fontHeight)
                                    ++ "em;"
                               )
                            ++ varsWithTransform
            in
            Debug.log "AS STRING" varsWithFontSize

        (Attribute { flag, attr }) :: remain ->
            let
                alwaysRender =
                    case flag of
                        Flag.Flag f ->
                            f == 0

                previouslyRendered =
                    if alwaysRender then
                        False

                    else
                        Flag.present flag has
            in
            if previouslyRendered then
                renderInlineStylesToString parentBits myBits layout details has vars remain

            else
                case attr of
                    FontSize size ->
                        renderInlineStylesToString parentBits
                            myBits
                            layout
                            details
                            (Flag.add flag has)
                            (vars
                                ++ ("font-size: "
                                        ++ String.fromFloat
                                            (fontSizeAdjusted size
                                                (parentBits
                                                    |> BitField.getPercentage Bits.fontHeight
                                                )
                                            )
                                        ++ "px;"
                                   )
                            )
                            remain

                    Font font ->
                        let
                            withSmallcaps =
                                if font.smallCaps then
                                    vars ++ "font-variant-caps: small-caps;"

                                else
                                    vars

                            withFeatures =
                                if font.variants == "" then
                                    vars

                                else
                                    vars ++ "font-feature-settings: " ++ font.variants ++ ";"
                        in
                        renderInlineStylesToString parentBits
                            myBits
                            layout
                            details
                            (Flag.add flag has)
                            (withFeatures
                                ++ ("font-family:" ++ font.family ++ ";")
                                ++ ("font-size:" ++ font.size ++ ";")
                                ++ ("font-weight:" ++ font.weight ++ ";")
                            )
                            remain

                    Style styleDetails ->
                        renderInlineStylesToString parentBits
                            myBits
                            layout
                            details
                            (Flag.add flag has)
                            (vars ++ styleDetails.styleName ++ ":" ++ styleDetails.styleVal ++ ";")
                            remain

                    Spacing x y ->
                        renderInlineStylesToString parentBits
                            myBits
                            layout
                            details
                            (Flag.add flag has)
                            (if layout == AsParagraph then
                                vars
                                    ++ "line-height:"
                                    ++ ("calc(1em + " ++ String.fromInt y ++ "px;")

                             else
                                vars
                                    ++ "gap:"
                                    ++ (String.fromInt y
                                            ++ "px "
                                            ++ String.fromInt x
                                            ++ "px;"
                                       )
                            )
                            remain

                    Padding padding ->
                        renderInlineStylesToString parentBits
                            myBits
                            layout
                            details
                            (Flag.add flag has)
                            (if padding.top == padding.right && padding.top == padding.left && padding.top == padding.bottom then
                                vars
                                    ++ "padding: "
                                    ++ (String.fromInt padding.top ++ "px;")

                             else
                                vars
                                    ++ "padding: "
                                    ++ ((String.fromInt padding.top ++ "px ")
                                            ++ (String.fromInt padding.right ++ "px ")
                                            ++ (String.fromInt padding.bottom ++ "px ")
                                            ++ (String.fromInt padding.left ++ "px;")
                                       )
                            )
                            remain

                    HeightFill i ->
                        renderInlineStylesToString parentBits
                            myBits
                            layout
                            details
                            (Flag.add flag has)
                            (if i > 1 && not (BitField.has Bits.isRow parentBits) then
                                vars
                                    ++ "flex-grow: "
                                    ++ String.fromInt (i * 100000)
                                    ++ ";"

                             else
                                vars
                            )
                            remain

                    WidthFill i ->
                        renderInlineStylesToString parentBits
                            myBits
                            layout
                            details
                            (Flag.add flag has)
                            (if i > 1 && BitField.has Bits.isRow parentBits then
                                vars
                                    ++ "flex-grow: "
                                    ++ String.fromInt (i * 100000)
                                    ++ ";"

                             else
                                vars
                            )
                            remain

                    _ ->
                        renderInlineStylesToString parentBits
                            myBits
                            layout
                            details
                            (Flag.add flag has)
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


addNearbyElement : Location -> Element msg -> ElemChildren msg -> ElemChildren msg
addNearbyElement location elem existing =
    let
        nearby =
            nearbyElement location elem
    in
    case existing of
        ElemChildren children near ->
            case location of
                Behind ->
                    ElemChildren children
                        { behind = nearby :: near.behind
                        , inFront = near.inFront
                        }

                _ ->
                    ElemChildren children
                        { behind = near.behind
                        , inFront = nearby :: near.inFront
                        }

        ElemKeyed children near ->
            case location of
                Behind ->
                    ElemKeyed children
                        { behind = ( "bh", nearby ) :: near.behind
                        , inFront = near.inFront
                        }

                _ ->
                    ElemKeyed children
                        { behind = near.behind
                        , inFront = ( "if", nearby ) :: near.inFront
                        }


nearbyElement : Location -> Element msg -> Element msg
nearbyElement location (Element elem) =
    Element
        (\parent ->
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
                [ elem parent
                ]
        )


zero =
    BitField.init


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
    Json.field "currentTarget"
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



{- Responsive: Breakpoints -}


type Breakpoints label
    = Responsive
        { transition : Maybe Transition
        , default : label
        , breaks : List ( Int, label )
        , total : Int
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


toMediaQuery : Breakpoints label -> String
toMediaQuery (Responsive details) =
    case details.breaks of
        [] ->
            ""

        ( lowerBound, _ ) :: remain ->
            ":root {"
                ++ toRoot details.breaks
                    1
                    (renderResponsiveCssVars 0 0 lowerBound)
                ++ " }"
                ++ toBoundedMediaQuery details.breaks
                    1
                    (maxWidthMediaQuery 0 lowerBound)


renderRoot : Int -> String
renderRoot breakpointCounts =
    ":root {" ++ renderRootItem breakpointCounts "" ++ "}"


renderRootItem : Int -> String -> String
renderRootItem count rendered =
    if count <= 0 then
        rendered

    else
        renderRootItem (count - 1)
            (rendered ++ "--ui-bp-" ++ String.fromInt (count - 1) ++ ": 0;")


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


toRoot : List ( Int, label ) -> Int -> String -> String
toRoot breaks i rendered =
    case breaks of
        [] ->
            rendered

        [ ( upper, _ ) ] ->
            rendered ++ renderResponsiveCssVars i upper (upper + 1000)

        ( lower, _ ) :: ((( upper, _ ) :: _) as tail) ->
            toRoot tail
                (i + 1)
                (rendered ++ renderResponsiveCssVars i lower upper)


toBoundedMediaQuery : List ( Int, label ) -> Int -> String -> String
toBoundedMediaQuery breaks i rendered =
    case breaks of
        [] ->
            rendered

        [ ( upper, _ ) ] ->
            rendered ++ minWidthMediaQuery i upper

        ( lower, _ ) :: ((( upper, _ ) :: _) as tail) ->
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
        ++ (".ui-bp-" ++ String.fromInt i ++ "-hidden {display:none !important;}")
        ++ (".ui-bp-" ++ String.fromInt i ++ "-as-col {flex-direction: column;}")


{-| -}
renderOptions : List Option -> Html.Html msg
renderOptions opts =
    Html.node "style"
        []
        [ Html.text (renderOptionItem { breakpoints = False, focus = False } "" opts) ]


renderOptionItem alreadyRendered renderedStr opts =
    case opts of
        [] ->
            renderedStr

        (FocusStyleOption focus) :: remain ->
            if alreadyRendered.focus then
                renderOptionItem alreadyRendered
                    renderedStr
                    remain

            else
                renderOptionItem { alreadyRendered | focus = True }
                    (renderedStr ++ renderFocusStyle focus)
                    remain

        (ResponsiveBreakpoints mediaQueryStr) :: remain ->
            if alreadyRendered.breakpoints then
                renderOptionItem alreadyRendered
                    renderedStr
                    remain

            else
                renderOptionItem { alreadyRendered | breakpoints = True }
                    (renderedStr ++ mediaQueryStr)
                    remain


maybeString fn maybeStr =
    case maybeStr of
        Nothing ->
            ""

        Just str ->
            fn str


andAdd one two =
    two ++ one


dot str =
    "." ++ str


renderFocusStyle :
    FocusStyle
    -> String
renderFocusStyle focus =
    let
        focusProps =
            "outline: none;"
                |> andAdd (maybeString (\color -> "border-color: " ++ Style.color color ++ ";") focus.borderColor)
                |> andAdd
                    (maybeString (\color -> "background-color: " ++ Style.color color ++ ";") focus.backgroundColor)
                |> andAdd
                    (maybeString
                        (\shadow ->
                            "box-shadow: "
                                ++ (Style.singleShadow shadow
                                    -- { color = shadow.color
                                    -- , offset =
                                    --     shadow.offset
                                    --         |> Tuple.mapFirst toFloat
                                    --         |> Tuple.mapSecond toFloat
                                    -- , inset = False
                                    -- , blur =
                                    --     toFloat shadow.blur
                                    -- , size =
                                    --     toFloat shadow.size
                                    -- }
                                   )
                                ++ ";"
                        )
                        focus.shadow
                    )
    in
    String.append
        (String.append
            (dot Style.classes.focusedWithin ++ ":focus-within")
            focusProps
        )
        (String.append
            (dot Style.classes.any ++ ":focus .focusable, " ++ dot Style.classes.any ++ ".focusable:focus")
            focusProps
        )
