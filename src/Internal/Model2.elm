module Internal.Model2 exposing (..)

import Animator
import Animator.Timeline
import Animator.Watcher
import Browser.Dom
import Color
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Html.Keyed
import Html.Lazy
import Internal.BitEncodings as Bits
import Internal.BitField as BitField exposing (BitField)
import Internal.Bits.Analyze as AnalyzeBits
import Internal.Bits.Inheritance as Inheritance
import Internal.Flag as Flag exposing (Flag)
import Internal.Style.Generated as Generated
import Internal.Style2 as Style
import Internal.Teleport as Teleport
import Internal.Teleport.Persistent as Persistent
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



-- | BoxNew Id Box


type State
    = State
        { added : Set String
        , rules : List String
        , boxes : Persistent.Persistent Box
        }


type alias Box =
    { x : Float
    , y : Float
    , width : Float
    , height : Float
    }


moveAnimationFixed : String -> Box -> Box -> String
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


bboxCss : Box -> String
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


bboxTransform : Box -> String
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
    (Msg -> msg)
    -> Msg
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


subscription : (Msg -> msg) -> State -> Animator msg model -> model -> Sub msg
subscription toAppMsg state animator model =
    Animator.Watcher.toSubscription (toAppMsg << Tick) model animator.animator


update : (Msg -> msg) -> Msg -> State -> ( State, Cmd msg )
update toAppMsg msg ((State details) as unchanged) =
    case msg of
        Tick _ ->
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


applyTeleported : Teleport.Event -> Teleport.Data -> ( State, List (Cmd Msg) ) -> ( State, List (Cmd Msg) )
applyTeleported event data ( (State state) as untouched, cmds ) =
    case data of
        Teleport.Persistent group instance ->
            let
                id =
                    Persistent.id group instance
            in
            -- if this id matches an existing box in the cache
            -- it means this box was previously rendered at the position found
            case List.head <| Persistent.getOthersInGroup id state.boxes of
                Nothing ->
                    ( State
                        { state
                            | boxes =
                                state.boxes
                                    |> Persistent.insert id event.box
                        }
                    , cmds
                    )

                Just firstFound ->
                    let
                        newBox =
                            event.box

                        newCss =
                            moveAnimationFixed
                                (Teleport.persistentClass group instance)
                                firstFound.value
                                newBox
                    in
                    ( State
                        { state
                            | rules =
                                state.rules
                                    |> addRule newCss
                            , boxes =
                                state.boxes
                                    |> Persistent.insert id event.box
                        }
                    , cmds
                    )

        Teleport.Css css ->
            if Set.member css.hash state.added then
                ( untouched, cmds )

            else
                let
                    cssClass =
                        "." ++ css.hash ++ "{" ++ addStylesToString css.props "" ++ "}"
                in
                ( State
                    { state
                        | rules =
                            state.rules
                                |> addRule cssClass
                                |> addRule css.keyframes
                        , added = Set.insert css.hash state.added
                    }
                , cmds
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
mapAttr fn (Attribute attr) =
    Attribute
        { flag = attr.flag
        , attr =
            case attr.attr of
                Attr a ->
                    Attr
                        { node = a.node
                        , additionalInheritance = a.additionalInheritance
                        , attrs = List.map (Attr.map fn) a.attrs
                        , class = a.class
                        , styles = a.styles
                        , nearby =
                            Maybe.map (\( loc, elem ) -> ( loc, map fn elem )) a.nearby
                        , teleport = a.teleport
                        }
        }


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
        { flag = Flag.skip
        , attr =
            Attr
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Nothing
                , styles = noStyles
                , nearby = Nothing
                , teleport = Nothing
                }
        }


justFlag : Flag -> Attribute msg
justFlag flag =
    Attribute
        { flag = flag
        , attr =
            Attr
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Nothing
                , styles = noStyles
                , nearby = Nothing
                , teleport = Nothing
                }
        }


nearby : Location -> Element msg -> Attribute msg
nearby loc el =
    Attribute
        { flag = Flag.skip
        , attr =
            Attr
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Just Style.classes.hasNearby
                , styles = noStyles
                , nearby = Just ( loc, el )
                , teleport = Nothing
                }
        }


teleport :
    { class : String
    , style : List ( String, String )
    , data : Encode.Value
    }
    -> Attribute msg
teleport options =
    Attribute
        { flag = Flag.skip
        , attr =
            Attr
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Just options.class
                , styles =
                    \_ _ ->
                        options.style
                , nearby = Nothing
                , teleport = Just options.data
                }
        }


noStyles :
    Inheritance.Encoded
    -> AnalyzeBits.Encoded
    -> List ( String, String )
noStyles inheritance encoded =
    []


class : String -> Attribute msg
class cls =
    Attribute
        { flag = Flag.skip
        , attr =
            Attr
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Just cls
                , styles = noStyles
                , nearby = Nothing
                , teleport = Nothing
                }
        }


classWith : Flag -> String -> Attribute msg
classWith flag cls =
    Attribute
        { flag = flag
        , attr =
            Attr
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Just cls
                , styles = noStyles
                , nearby = Nothing
                , teleport = Nothing
                }
        }


type alias TransformSlot =
    Int


toOnlyStyle : Attribute msg -> Attribute msg
toOnlyStyle (Attribute { flag, attr }) =
    Attribute
        { flag = flag
        , attr =
            case attr of
                Attr details ->
                    Attr
                        { details
                            | attrs = []
                        }
        }


ifFlag : (Flag -> Bool) -> Attribute msg -> Bool
ifFlag isPassing (Attribute { flag }) =
    isPassing flag


type Attribute msg
    = Attribute
        { flag : Flag
        , attr : Attr msg
        }


type Attr msg
    = Attr
        { node : Node
        , additionalInheritance : Inheritance.Encoded
        , attrs : List (Html.Attribute msg)
        , class : Maybe String
        , styles :
            Inheritance.Encoded
            -> AnalyzeBits.Encoded
            -> List ( String, String )
        , nearby : Maybe ( Location, Element msg )
        , teleport : Maybe Encode.Value
        }


type Node
    = NodeAsDiv
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


type Option
    = FocusStyleOption FocusStyle
    | ResponsiveBreakpoints String
    | FontAdjustment
        { family : String
        , offset : Float
        , height : Float
        }


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
                Color.rgb255 155 203 255
            , blur = 0
            , size = 3
            }
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
            if
                BitField.has Inheritance.isRow encoded
                    || BitField.has Inheritance.isColumn encoded
                    || BitField.has Inheritance.hasTextModification encoded
            then
                Html.span [ Attr.class textElementClasses ] [ Html.text str ]

            else
                Html.text str
         -- if BitField.equal encoded Bits.row || BitField.equal encoded Bits.column then
         --     Html.span [ Attr.class textElementClasses ] [ Html.text str ]
         -- else
         --     let
         --         height =
         --             encoded
         --                 |> BitField.getPercentage Bits.fontHeight
         --         offset =
         --             encoded
         --                 |> BitField.getPercentage Bits.fontOffset
         --         spacingY =
         --             encoded
         --                 |> BitField.get Bits.spacingY
         --         spacingX =
         --             encoded
         --                 |> BitField.get Bits.spacingX
         --         attrs =
         --             [ Attr.class textElementClasses
         --             ]
         --         attrsWithParentSpacing =
         --             -- if height == 1 && offset == 0 then
         --             --     Attr.style "margin"
         --             --         (String.fromInt spacingY ++ "px " ++ String.fromInt spacingX ++ "px")
         --             --         ::
         --             --         attrs
         --             -- else
         --             --     let
         --             --         -- This doesn't totally make sense to me, but it works :/
         --             --         -- I thought that the top margin should have a smaller negative margin than the bottom
         --             --         -- however it seems evenly distributing the empty space works out.
         --             --         topVal =
         --             --             offset
         --             --         bottomVal =
         --             --             (1 - height) - offset
         --             --         even =
         --             --             (topVal + bottomVal) / 2
         --             --         margin =
         --             --             "-"
         --             --                 ++ String.fromFloat (even + 0.25)
         --             --                 ++ "em "
         --             --                 ++ (String.fromInt spacingX ++ "0px ")
         --             --     in
         --             --     Attr.style "margin"
         --             --         margin
         --             --         :: Attr.style "padding" "0.25em calc((1/32) * 1em) 0.25em 0px"
         --             --         :: attrs
         --             attrs
         --     in
         --     Html.span
         --         attrsWithParentSpacing
         --         [ Html.text str ]
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
        { flag = Flag.skip
        , attr =
            Attr
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = [ a ]
                , class = Nothing
                , styles = noStyles
                , nearby = Nothing
                , teleport = Nothing
                }
        }


attributeWith : Flag -> Html.Attribute msg -> Attribute msg
attributeWith flag a =
    Attribute
        { flag = flag
        , attr =
            Attr
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = [ a ]
                , class = Nothing
                , styles = noStyles
                , nearby = Nothing
                , teleport = Nothing
                }
        }


onPress :
    msg
    -> Attribute msg
onPress msg =
    Attribute
        { flag = Flag.skip
        , attr =
            Attr
                { node = NodeAsButton
                , additionalInheritance = BitField.none
                , attrs =
                    [ Events.onClick msg

                    --     Events.stopPropagationOn "pointerdown"
                    --     (Json.succeed ( msg, True ))
                    -- , onKeyListener "Enter"
                    --     msg
                    -- , Attr.tabindex
                    --     0
                    ]
                , class = Just Style.classes.cursorPointer
                , styles = noStyles
                , nearby = Nothing
                , teleport = Nothing
                }
        }


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
        { flag = Flag.skip
        , attr =
            Attr
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
                , nearby = Nothing
                , teleport = Nothing
                }
        }


link :
    { newTab : Bool
    , url : String
    , download : Maybe String
    }
    -> Attribute msg
link details =
    Attribute
        { flag = Flag.skip
        , attr =
            Attr
                { node = NodeAsLink
                , additionalInheritance = BitField.none
                , attrs =
                    [ Attr.href details.url
                    , Attr.rel "noopener noreferrer"
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
                , nearby = Nothing
                , teleport = Nothing
                }
        }


nodeAs : Node -> Attribute msg
nodeAs node =
    Attribute
        { flag = Flag.skip
        , attr =
            Attr
                { node = node
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Nothing
                , styles = noStyles
                , nearby = Nothing
                , teleport = Nothing
                }
        }


style : String -> String -> Attribute msg
style name val =
    Attribute
        { flag = Flag.skip
        , attr =
            Attr
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Nothing
                , styles =
                    \_ _ ->
                        [ ( name, val ) ]
                , nearby = Nothing
                , teleport = Nothing
                }
        }


styleDynamic : String -> (Inheritance.Encoded -> String) -> Attribute msg
styleDynamic name toVal =
    Attribute
        { flag = Flag.skip
        , attr =
            Attr
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Nothing
                , styles =
                    \inheritance _ ->
                        [ ( name, toVal inheritance ) ]
                , nearby = Nothing
                , teleport = Nothing
                }
        }


style2 :
    String
    -> String
    -> String
    -> String
    -> Attribute msg
style2 oneName oneVal twoName twoVal =
    Attribute
        { flag = Flag.skip
        , attr =
            Attr
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Nothing
                , styles =
                    \_ _ ->
                        [ ( oneName, oneVal )
                        , ( twoName, twoVal )
                        ]
                , nearby = Nothing
                , teleport = Nothing
                }
        }


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
        { flag = Flag.skip
        , attr =
            Attr
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
                , nearby = Nothing
                , teleport = Nothing
                }
        }


styleWith : Flag -> String -> String -> Attribute msg
styleWith flag name val =
    Attribute
        { flag = flag
        , attr =
            Attr
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Nothing
                , styles =
                    \_ _ ->
                        [ ( name, val ) ]
                , nearby = Nothing
                , teleport = Nothing
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
            Attr
                { node = NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Just v.class
                , styles =
                    \_ _ ->
                        [ ( v.styleName, v.styleVal ) ]
                , nearby = Nothing
                , teleport = Nothing
                }
        }


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
    { options : List Option
    , includeStatisStylesheet : Bool
    }
    -> State
    -> List (Attribute msg)
    -> Element msg
    -> Html.Html msg
renderLayout { options, includeStatisStylesheet } (State state) attrs content =
    let
        rendered =
            element NodeAsDiv
                AsRoot
                attrs
                [ Element
                    (\_ ->
                        Html.Keyed.node "div"
                            []
                            [ ( "options", Html.Lazy.lazy renderOptions options )
                            , ( "static"
                              , if includeStatisStylesheet then
                                    staticStyles

                                else
                                    Html.text ""
                              )
                            , ( "animations", Html.Lazy.lazy styleRules state.rules )

                            -- , ( "boxes"
                            --   , Html.div [] (List.map viewBox state.boxes)
                            --   )
                            ]
                    )
                , content
                ]
    in
    case rendered of
        Element toFinalLayout ->
            toFinalLayout zero


staticStyles : Html.Html msg
staticStyles =
    Html.div []
        [ Html.node "style"
            [ Attr.id "elm-ui-static-styles" ]
            [ Html.text Style.rules ]
        ]


styleRules : List String -> Html.Html msg
styleRules styleStr =
    Html.div []
        [ Html.node "style"
            [ Attr.id "elm-ui-dynamic-styles" ]
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
element node layout attrs children =
    Element
        (\parentBits ->
            let
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
                    analyze Flag.none BitField.init myBaseBits attrs

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
                        toAttrs parentBits myBits Flag.none [ margin ] [] attrs

                    else
                        toAttrs parentBits myBits Flag.none [] [] attrs

                styleAttrs =
                    if BitField.has AnalyzeBits.cssVars analyzedBits then
                        toStyleAsEncodedProperty parentBits myBits analyzedBits Flag.none (contextClasses layout) htmlAttrs "" (List.reverse attrs)

                    else
                        toStyle parentBits myBits analyzedBits Flag.none htmlAttrs (contextClasses layout) (List.reverse attrs)

                finalChildren =
                    toChildren myBits analyzedBits attrs children
            in
            if BitField.has AnalyzeBits.isLink analyzedBits then
                Html.a styleAttrs finalChildren

            else if BitField.has AnalyzeBits.isButton analyzedBits then
                Html.button styleAttrs finalChildren

            else
                case node of
                    NodeAsDiv ->
                        Html.div styleAttrs finalChildren

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
        )


toChildren :
    Inheritance.Encoded
    -> AnalyzeBits.Encoded
    -> List (Attribute msg)
    -> List (Element msg)
    -> List (Html.Html msg)
toChildren myBits analyzedBits attrs children =
    if BitField.has AnalyzeBits.nearbys analyzedBits then
        let
            behind =
                toBehindElements myBits [] attrs

            after =
                toNearbyElements myBits [] attrs
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
elementKeyed node layout attrs children =
    Element
        (\parentBits ->
            let
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
                    analyze Flag.none BitField.init myBaseBits attrs

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
                        toAttrs parentBits myBits Flag.none [ margin ] [] attrs

                    else
                        toAttrs parentBits myBits Flag.none [] [] attrs

                styleAttrs =
                    if BitField.has AnalyzeBits.cssVars analyzedBits then
                        toStyleAsEncodedProperty parentBits myBits analyzedBits Flag.none (contextClasses layout) htmlAttrs "" (List.reverse attrs)

                    else
                        toStyle parentBits myBits analyzedBits Flag.none htmlAttrs (contextClasses layout) (List.reverse attrs)

                finalChildren =
                    toChildrenKeyed myBits analyzedBits attrs children
            in
            if BitField.has AnalyzeBits.isLink analyzedBits then
                Html.Keyed.node "a" styleAttrs finalChildren

            else if BitField.has AnalyzeBits.isButton analyzedBits then
                Html.Keyed.node "button" styleAttrs finalChildren

            else
                case node of
                    NodeAsDiv ->
                        Html.Keyed.node "div" styleAttrs finalChildren

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
        )


toChildrenKeyed :
    Inheritance.Encoded
    -> AnalyzeBits.Encoded
    -> List (Attribute msg)
    -> List ( String, Element msg )
    -> List ( String, Html.Html msg )
toChildrenKeyed myBits analyzedBits attrs children =
    if BitField.has AnalyzeBits.nearbys analyzedBits then
        let
            behind =
                toBehindElements myBits [] attrs
                    |> List.map (Tuple.pair "behind")

            after =
                toNearbyElements myBits [] attrs
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


{-|

    1. What nodes are we rendering?
    2. Do any attributes use css variables?
    3. Are there any transforms?

-}
analyze :
    Flag.Field
    -> AnalyzeBits.Encoded
    -> Inheritance.Encoded
    -> List (Attribute msg)
    -> ( AnalyzeBits.Encoded, Inheritance.Encoded, Flag.Field )
analyze has encoded inheritance attrs =
    case attrs of
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

        (Attribute { flag, attr }) :: remain ->
            let
                previouslyRendered =
                    if BitField.fieldEqual flag Flag.skip then
                        False

                    else
                        BitField.has flag has
            in
            if previouslyRendered then
                analyze has encoded inheritance remain

            else
                case attr of
                    Attr details ->
                        let
                            newEncoded =
                                encoded
                                    |> BitField.flipIf AnalyzeBits.nearbys (details.nearby /= Nothing)
                                    |> BitField.flipIf AnalyzeBits.isLink
                                        (NodeAsLink == details.node)
                                    |> BitField.flipIf AnalyzeBits.isButton
                                        (NodeAsButton == details.node)

                            newInheritance =
                                inheritance
                                    |> BitField.merge details.additionalInheritance
                        in
                        analyze (Flag.add flag has) newEncoded newInheritance remain


toAttrs :
    Inheritance.Encoded
    -> Inheritance.Encoded
    -> Flag.Field
    -> List (VirtualDom.Attribute msg)
    -> List Json.Value
    -> List (Attribute msg)
    -> List (Html.Attribute msg)
toAttrs parentBits myBits has htmlAttrs teleported attrs =
    case attrs of
        [] ->
            case teleported of
                [] ->
                    htmlAttrs

                _ ->
                    Attr.property "data-elm-ui" (Encode.list identity teleported) :: htmlAttrs

        (Attribute { flag, attr }) :: remain ->
            let
                previouslyRendered =
                    if BitField.fieldEqual flag Flag.skip then
                        False

                    else
                        BitField.has flag has
            in
            if previouslyRendered then
                toAttrs parentBits myBits has htmlAttrs teleported remain

            else
                case attr of
                    Attr details ->
                        case details.attrs of
                            [] ->
                                let
                                    newTeleported =
                                        case details.teleport of
                                            Nothing ->
                                                teleported

                                            Just newTele ->
                                                newTele :: teleported
                                in
                                toAttrs parentBits myBits has htmlAttrs newTeleported remain

                            _ ->
                                let
                                    newAttrs =
                                        case details.attrs of
                                            [] ->
                                                htmlAttrs

                                            [ single ] ->
                                                single :: htmlAttrs

                                            [ first, second ] ->
                                                first :: second :: htmlAttrs

                                            list ->
                                                list ++ htmlAttrs

                                    newTeleported =
                                        case details.teleport of
                                            Nothing ->
                                                teleported

                                            Just newTele ->
                                                newTele :: teleported
                                in
                                toAttrs parentBits myBits (Flag.add flag has) newAttrs newTeleported remain


toBehindElements :
    Inheritance.Encoded
    -> List (Html.Html msg)
    -> List (Attribute msg)
    -> List (Html.Html msg)
toBehindElements inheritance foundElems attrs =
    case attrs of
        [] ->
            foundElems

        (Attribute { attr }) :: remain ->
            case attr of
                Attr details ->
                    case details.nearby of
                        Just ( Behind, behindElem ) ->
                            toBehindElements inheritance (nearbyToHtml inheritance Behind behindElem :: foundElems) remain

                        _ ->
                            toBehindElements inheritance foundElems remain


toNearbyElements :
    Inheritance.Encoded
    -> List (Html.Html msg)
    -> List (Attribute msg)
    -> List (Html.Html msg)
toNearbyElements inheritance foundElems attrs =
    case attrs of
        [] ->
            foundElems

        (Attribute { attr }) :: remain ->
            case attr of
                Attr details ->
                    case details.nearby of
                        Nothing ->
                            toNearbyElements inheritance foundElems remain

                        Just ( Behind, _ ) ->
                            toNearbyElements inheritance foundElems remain

                        Just ( location, nearbyElem ) ->
                            toNearbyElements inheritance (nearbyToHtml inheritance location nearbyElem :: foundElems) remain


toStyle :
    Inheritance.Encoded
    -> Inheritance.Encoded
    -> AnalyzeBits.Encoded
    -> Flag.Field
    -> List (VirtualDom.Attribute msg)
    -> String
    -> List (Attribute msg)
    -> List (Html.Attribute msg)
toStyle parentBits myBits analyzedBits has htmlAttrs classes attrs =
    case attrs of
        [] ->
            Attr.class classes :: htmlAttrs

        (Attribute { flag, attr }) :: remain ->
            let
                previouslyRendered =
                    if BitField.fieldEqual flag Flag.skip then
                        False

                    else
                        BitField.has flag has
            in
            if previouslyRendered then
                toStyle parentBits myBits analyzedBits has htmlAttrs classes remain

            else
                case attr of
                    Attr details ->
                        let
                            newClasses =
                                case details.class of
                                    Nothing ->
                                        classes

                                    Just classStr ->
                                        classes ++ " " ++ classStr
                        in
                        case details.styles parentBits analyzedBits of
                            [] ->
                                toStyle parentBits myBits analyzedBits (Flag.add flag has) htmlAttrs newClasses remain

                            [ ( name, val ) ] ->
                                toStyle parentBits myBits analyzedBits (Flag.add flag has) (Attr.style name val :: htmlAttrs) newClasses remain

                            [ ( name, val ), ( twoName, twoVal ) ] ->
                                toStyle parentBits myBits analyzedBits (Flag.add flag has) (Attr.style name val :: Attr.style twoName twoVal :: htmlAttrs) newClasses remain

                            list ->
                                toStyle parentBits myBits analyzedBits (Flag.add flag has) (addStyles list htmlAttrs) newClasses remain


addStyles : List ( String, String ) -> List (Html.Attribute msg) -> List (Html.Attribute msg)
addStyles styles attrs =
    case styles of
        [] ->
            attrs

        ( name, val ) :: remain ->
            addStyles remain
                (Attr.style name val :: attrs)


toStyleAsEncodedProperty :
    Inheritance.Encoded
    -> Inheritance.Encoded
    -> AnalyzeBits.Encoded
    -> Flag.Field
    -> String
    -> List (VirtualDom.Attribute msg)
    -> String
    -> List (Attribute msg)
    -> List (Html.Attribute msg)
toStyleAsEncodedProperty parentBits myBits analyzed has classesString htmlAttrs str attrs =
    case attrs of
        [] ->
            Attr.class classesString
                :: Attr.property "style"
                    (Encode.string str)
                :: htmlAttrs

        (Attribute { flag, attr }) :: remain ->
            let
                previouslyRendered =
                    if BitField.fieldEqual flag Flag.skip then
                        False

                    else
                        BitField.has flag has
            in
            if previouslyRendered then
                toStyleAsEncodedProperty parentBits myBits analyzed has classesString htmlAttrs str remain

            else
                case attr of
                    Attr details ->
                        let
                            newClasses =
                                case details.class of
                                    Nothing ->
                                        classesString

                                    Just moreClasses ->
                                        classesString ++ " " ++ moreClasses
                        in
                        case details.styles parentBits analyzed of
                            [] ->
                                toStyleAsEncodedProperty parentBits myBits analyzed (Flag.add flag has) newClasses htmlAttrs str remain

                            [ ( name, val ) ] ->
                                toStyleAsEncodedProperty parentBits myBits analyzed (Flag.add flag has) newClasses htmlAttrs (name ++ ":" ++ val ++ ";" ++ str) remain

                            [ ( name, val ), ( twoName, twoVal ) ] ->
                                toStyleAsEncodedProperty parentBits myBits analyzed (Flag.add flag has) newClasses htmlAttrs (name ++ ":" ++ val ++ ";" ++ twoName ++ ":" ++ twoVal ++ ";" ++ str) remain

                            list ->
                                toStyleAsEncodedProperty parentBits myBits analyzed (Flag.add flag has) newClasses htmlAttrs (addStylesToString list str) remain


addStylesToString : List ( String, String ) -> String -> String
addStylesToString styles attrs =
    case styles of
        [] ->
            attrs

        ( name, val ) :: remain ->
            addStylesToString remain
                (name ++ ":" ++ val ++ ";" ++ attrs)


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
        ++ " "
        ++ Style.classes.widthContent
        ++ " "
        ++ Style.classes.heightContent


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
        { default : label
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
        [ Attr.id "elm-ui-responsiveness" ]
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

        (FontAdjustment adjustment) :: remain ->
            renderOptionItem alreadyRendered
                (renderedStr ++ renderFontAdjustment adjustment)
                remain


renderFontAdjustment :
    { family : String
    , offset : Float
    , height : Float
    }
    -> String
renderFontAdjustment adjustment =
    let
        fontid =
            adjustment.family

        sizeAdjustmentRule =
            ("." ++ fontid)
                ++ curlyBrackets
                    [ "font-size:" ++ String.fromFloat adjustment.height ++ "%;"
                    ]
    in
    sizeAdjustmentRule
        ++ (List.map
                (\i ->
                    let
                        -- offset would be 5 if the line-height is 1.05
                        offsetInt =
                            i * 5

                        body =
                            curlyBrackets
                                [ "margin-top:" ++ Generated.lineHeightAdjustment i ++ ";"
                                , "margin-bottom:" ++ Generated.lineHeightAdjustment i ++ ";"
                                ]
                    in
                    (("." ++ fontid ++ " .lh-" ++ String.fromInt offsetInt ++ " .s.p ") ++ body)
                        ++ (("." ++ fontid ++ " .lh-" ++ String.fromInt offsetInt ++ " .s.t ") ++ body)
                )
                (List.range 1 20)
                |> String.concat
           )


curlyBrackets : List String -> String
curlyBrackets lines =
    "{" ++ String.concat lines ++ "}"


maybeString : (a -> String) -> Maybe a -> String
maybeString fn maybeStr =
    case maybeStr of
        Nothing ->
            ""

        Just str ->
            fn str


andAdd : appendable -> appendable -> appendable
andAdd one two =
    two ++ one


dot : String -> String
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
