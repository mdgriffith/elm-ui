module Internal.Model exposing (..)

{-| -}

import Html
import Html.Attributes
import Html.Keyed
import Internal.Flag as Flag exposing (Flag)
import Internal.Style exposing (classes, dot)
import Json.Encode as Json
import Set exposing (Set)
import VirtualDom


type Element msg
    = Unstyled (LayoutContext -> VirtualDom.Node msg)
    | Styled
        { styles : List Style
        , html : EmbedStyle -> LayoutContext -> VirtualDom.Node msg
        }
    | Text String
    | Empty


type EmbedStyle
    = NoStyleSheet
    | StaticRootAndDynamic OptionRecord (List Style)
    | OnlyDynamic OptionRecord (List Style)


noStyleSheet : EmbedStyle
noStyleSheet =
    NoStyleSheet


type LayoutContext
    = AsRow
    | AsColumn
    | AsEl
    | AsGrid
    | AsParagraph
    | AsTextColumn


type Aligned
    = Unaligned
    | Aligned (Maybe HAlign) (Maybe VAlign)


type HAlign
    = Left
    | CenterX
    | Right


type VAlign
    = Top
    | CenterY
    | Bottom


type Style
    = Style String (List Property)
      --       class  prop   val
    | FontFamily String (List Font)
    | FontSize Int
      -- classname, prop, value
    | Single String String String
    | Colored String String Color
    | SpacingStyle String Int Int
    | PaddingStyle String Int Int Int Int
    | GridTemplateStyle
        { spacing : ( Length, Length )
        , columns : List Length
        , rows : List Length
        }
    | GridPosition
        { row : Int
        , col : Int
        , width : Int
        , height : Int
        }
    | Transform Transformation
    | PseudoSelector PseudoClass (List Style)
    | Transparency String Float
    | Shadows String String


type Transformation
    = Untransformed
    | Moved XYZ
      --              translate, scale, rotate
    | FullTransform XYZ XYZ XYZ Angle


type PseudoClass
    = Focus
    | Hover
    | Active


type Font
    = Serif
    | SansSerif
    | Monospace
    | Typeface String
    | ImportFont String String


type Property
    = Property String String


type alias XYZ =
    ( Float, Float, Float )


type alias Angle =
    Float


type Attribute aligned msg
    = NoAttribute
    | Attr (VirtualDom.Attribute msg)
    | Describe Description
      -- invalidation key and literal class
    | Class Flag String
      -- invalidation key "border-color" as opposed to "border-color-10-10-10" that will be the key for the class
    | StyleClass Flag Style
    | AlignY VAlign
    | AlignX HAlign
    | Width Length
    | Height Length
    | Nearby Location (Element msg)
    | TransformComponent Flag TransformComponent


type TransformComponent
    = MoveX Float
    | MoveY Float
    | MoveZ Float
    | MoveXYZ XYZ
    | Rotate XYZ Float
    | Scale XYZ


type Description
    = Main
    | Navigation
      -- | Search
    | ContentInfo
    | Complementary
    | Heading Int
    | Label String
    | LivePolite
    | LiveAssertive
    | Button
    | Paragraph


type Length
    = Px Int
    | Content
    | Fill Int
    | Min Int Length
    | Max Int Length


type Axis
    = XAxis
    | YAxis
    | AllAxis


type Location
    = Above
    | Below
    | OnRight
    | OnLeft
    | InFront
    | Behind


{-| -}
type Color
    = Rgba Float Float Float Float


type NodeName
    = Generic
    | NodeName String
    | Embedded String String


div =
    Generic


type alias Gathered msg =
    { node : NodeName
    , attributes : List (VirtualDom.Attribute msg)
    , styles : List Style
    , children : List (VirtualDom.Node msg)
    , has : Flag.Field
    }


htmlClass : String -> Attribute aligned msg
htmlClass cls =
    Attr <| Html.Attributes.class cls


{-| -}
unstyled : VirtualDom.Node msg -> Element msg
unstyled =
    Unstyled << always


finalizeNode has node attributes children embedMode parentContext =
    let
        createNode nodeName attrs =
            case children of
                Keyed keyed ->
                    VirtualDom.keyedNode nodeName
                        attrs
                        (case embedMode of
                            NoStyleSheet ->
                                keyed

                            OnlyDynamic opts styles ->
                                embedKeyed False opts styles keyed

                            StaticRootAndDynamic opts styles ->
                                embedKeyed True opts styles keyed
                        )

                Unkeyed unkeyed ->
                    (case nodeName of
                        "div" ->
                            Html.div

                        "p" ->
                            Html.p

                        _ ->
                            VirtualDom.node nodeName
                    )
                        attrs
                        (case embedMode of
                            NoStyleSheet ->
                                unkeyed

                            OnlyDynamic opts styles ->
                                embedWith False opts styles unkeyed

                            StaticRootAndDynamic opts styles ->
                                embedWith True opts styles unkeyed
                        )

        html =
            case node of
                Generic ->
                    createNode "div" attributes

                NodeName nodeName ->
                    createNode nodeName attributes

                Embedded nodeName internal ->
                    VirtualDom.node nodeName
                        attributes
                        [ createNode internal [ Html.Attributes.class (classes.any ++ " " ++ classes.single) ]
                        ]
    in
    case parentContext of
        AsRow ->
            if Flag.present Flag.widthFill has && not (Flag.present Flag.widthBetween has) then
                html
            else if Flag.present Flag.alignRight has then
                Html.u
                    [ Html.Attributes.class
                        (String.join " "
                            [ classes.any
                            , classes.single
                            , classes.container
                            , classes.contentCenterY
                            , classes.alignContainerRight
                            ]
                        )
                    ]
                    [ html ]
            else if Flag.present Flag.centerX has then
                Html.s
                    [ Html.Attributes.class
                        (String.join " "
                            [ classes.any
                            , classes.single
                            , classes.container
                            , classes.contentCenterY
                            , classes.alignContainerCenterX
                            ]
                        )
                    ]
                    [ html ]
            else
                html

        AsColumn ->
            if Flag.present Flag.heightFill has && not (Flag.present Flag.heightBetween has) then
                html
            else if Flag.present Flag.centerY has then
                Html.s
                    [ Html.Attributes.class
                        (String.join " "
                            [ classes.any
                            , classes.single
                            , classes.container
                            , classes.alignContainerCenterY
                            ]
                        )
                    ]
                    [ html ]
            else if Flag.present Flag.alignBottom has then
                Html.u
                    [ Html.Attributes.class
                        (String.join " "
                            [ classes.any
                            , classes.single
                            , classes.container
                            , classes.alignContainerBottom
                            ]
                        )
                    ]
                    [ html ]
            else
                html

        _ ->
            html


embedWith static opts styles children =
    if static then
        staticRoot
            :: (styles
                    |> List.foldl reduceStyles ( Set.empty, [ renderFocusStyle opts.focus ] )
                    |> Tuple.second
                    -- |> reduceStylesRecursive Set.empty [ ]) --renderFocusStyle opts.focus ]
                    -- |> sortedReduce
                    |> toStyleSheet opts
               )
            :: children
    else
        (styles
            |> List.foldl reduceStyles ( Set.empty, [ renderFocusStyle opts.focus ] )
            |> Tuple.second
            -- |> reduceStylesRecursive Set.empty [ ]) --renderFocusStyle opts.focus ]
            -- |> sortedReduce
            |> toStyleSheet opts
        )
            :: children


embedKeyed static opts styles children =
    if static then
        ( "static-stylesheet", staticRoot )
            :: ( "dynamic-stylesheet"
               , styles
                    |> List.foldl reduceStyles ( Set.empty, [ renderFocusStyle opts.focus ] )
                    |> Tuple.second
                    -- |> reduceStylesRecursive Set.empty [ ]) --renderFocusStyle opts.focus ]
                    -- |> sortedReduce
                    |> toStyleSheet opts
               )
            :: children
    else
        ( "dynamic-stylesheet"
        , styles
            |> List.foldl reduceStyles ( Set.empty, [ renderFocusStyle opts.focus ] )
            |> Tuple.second
            -- |> reduceStylesRecursive Set.empty [ ]) --renderFocusStyle opts.focus ]
            -- |> sortedReduce
            |> toStyleSheet opts
        )
            :: children


reduceStylesRecursive : Set String -> List Style -> List Style -> List Style
reduceStylesRecursive cache found styles =
    case styles of
        [] ->
            found

        head :: remaining ->
            let
                styleName =
                    getStyleName head
            in
            if Set.member styleName cache then
                reduceStylesRecursive cache found remaining
            else
                reduceStylesRecursive (Set.insert styleName cache) (head :: found) remaining


reduceStyles : Style -> ( Set String, List Style ) -> ( Set String, List Style )
reduceStyles style (( cache, existing ) as nevermind) =
    let
        styleName =
            getStyleName style
    in
    if Set.member styleName cache then
        nevermind
    else
        ( Set.insert styleName cache
        , style :: existing
        )


sortedReduce styles =
    styles
        -- |> List.map (\x -> ( getStyleName x, x ))
        |> List.sortBy getStyleName
        |> reduceRecursiveCalcName []


reduceRecursiveCalcName : List Style -> List Style -> List Style
reduceRecursiveCalcName found styles =
    case styles of
        [] ->
            found

        headOfList :: [] ->
            headOfList :: found

        headOfList :: other :: remaining ->
            if headOfList /= other then
                reduceRecursiveCalcName (headOfList :: found) (other :: remaining)
            else
                reduceRecursiveCalcName found (other :: remaining)


reduceRecursive : List Style -> List ( String, Style ) -> List Style
reduceRecursive found styles =
    case styles of
        [] ->
            found

        ( _, headOfList ) :: [] ->
            headOfList :: found

        ( headOfListName, headOfList ) :: ( otherName, other ) :: remaining ->
            if headOfListName /= otherName then
                reduceRecursive (headOfList :: found) (( otherName, other ) :: remaining)
            else
                reduceRecursive found (( otherName, other ) :: remaining)


addNodeName : String -> NodeName -> NodeName
addNodeName newNode old =
    case old of
        Generic ->
            NodeName newNode

        NodeName name ->
            Embedded name newNode

        Embedded x y ->
            Embedded x y


alignXName : HAlign -> String
alignXName align =
    case align of
        Left ->
            classes.alignedHorizontally ++ " " ++ classes.alignLeft

        Right ->
            classes.alignedHorizontally ++ " " ++ classes.alignRight

        CenterX ->
            classes.alignedHorizontally ++ " " ++ classes.alignCenterX


alignYName : VAlign -> String
alignYName align =
    case align of
        Top ->
            classes.alignedVertically ++ " " ++ classes.alignTop

        Bottom ->
            classes.alignedVertically ++ " " ++ classes.alignBottom

        CenterY ->
            classes.alignedVertically ++ " " ++ classes.alignCenterY


transformClass transform =
    case transform of
        Untransformed ->
            Nothing

        Moved ( x, y, z ) ->
            Just <|
                "mv-"
                    ++ floatClass x
                    ++ "-"
                    ++ floatClass y
                    ++ "-"
                    ++ floatClass z

        FullTransform ( tx, ty, tz ) ( sx, sy, sz ) ( ox, oy, oz ) angle ->
            Just <|
                "tfrm-"
                    ++ floatClass tx
                    ++ "-"
                    ++ floatClass ty
                    ++ "-"
                    ++ floatClass tz
                    ++ "-"
                    ++ floatClass sx
                    ++ "-"
                    ++ floatClass sy
                    ++ "-"
                    ++ floatClass sz
                    ++ "-"
                    ++ floatClass ox
                    ++ "-"
                    ++ floatClass oy
                    ++ "-"
                    ++ floatClass oz
                    ++ "-"
                    ++ floatClass angle


transformValue transform =
    case transform of
        Untransformed ->
            Nothing

        Moved ( x, y, z ) ->
            Just <|
                "translate3d("
                    ++ String.fromFloat x
                    ++ "px, "
                    ++ String.fromFloat y
                    ++ "px, "
                    ++ String.fromFloat z
                    ++ "px)"

        FullTransform ( tx, ty, tz ) ( sx, sy, sz ) ( ox, oy, oz ) angle ->
            let
                translate =
                    "translate3d("
                        ++ String.fromFloat tx
                        ++ "px, "
                        ++ String.fromFloat ty
                        ++ "px, "
                        ++ String.fromFloat tz
                        ++ "px)"

                scale =
                    "scale3d("
                        ++ String.fromFloat sx
                        ++ ", "
                        ++ String.fromFloat sy
                        ++ ", "
                        ++ String.fromFloat sz
                        ++ ")"

                rotate =
                    "rotate3d("
                        ++ String.fromFloat ox
                        ++ ", "
                        ++ String.fromFloat oy
                        ++ ", "
                        ++ String.fromFloat oz
                        ++ ", "
                        ++ String.fromFloat angle
                        ++ "rad)"
            in
            Just <| translate ++ " " ++ scale ++ " " ++ rotate


composeTransformation transform component =
    case transform of
        Untransformed ->
            case component of
                MoveX x ->
                    Moved ( x, 0, 0 )

                MoveY y ->
                    Moved ( 0, y, 0 )

                MoveZ z ->
                    Moved ( 0, 0, z )

                MoveXYZ xyz ->
                    Moved xyz

                Rotate xyz angle ->
                    FullTransform ( 0, 0, 0 ) ( 1, 1, 1 ) xyz angle

                Scale xyz ->
                    FullTransform ( 0, 0, 0 ) xyz ( 0, 0, 1 ) 0

        Moved (( x, y, z ) as moved) ->
            case component of
                MoveX newX ->
                    Moved ( newX, y, z )

                MoveY newY ->
                    Moved ( x, newY, z )

                MoveZ newZ ->
                    Moved ( x, y, newZ )

                MoveXYZ xyz ->
                    Moved xyz

                Rotate xyz angle ->
                    FullTransform moved ( 1, 1, 1 ) xyz angle

                Scale scale ->
                    FullTransform moved scale ( 0, 0, 1 ) 0

        FullTransform (( x, y, z ) as moved) scaled origin angle ->
            case component of
                MoveX newX ->
                    FullTransform ( newX, y, z ) scaled origin angle

                MoveY newY ->
                    FullTransform ( x, newY, z ) scaled origin angle

                MoveZ newZ ->
                    FullTransform ( x, y, newZ ) scaled origin angle

                MoveXYZ newMove ->
                    FullTransform newMove scaled origin angle

                Rotate newOrigin newAngle ->
                    FullTransform moved scaled newOrigin newAngle

                Scale newScale ->
                    FullTransform moved newScale origin angle


skippable flag style =
    if flag == Flag.borderWidth then
        case style of
            Single _ _ val ->
                case val of
                    "0px" ->
                        True

                    "1px" ->
                        True

                    "2px" ->
                        True

                    "3px" ->
                        True

                    "4px" ->
                        True

                    "5px" ->
                        True

                    "6px" ->
                        True

                    _ ->
                        False

            _ ->
                False
    else
        case style of
            FontSize i ->
                i >= 8 && i <= 32

            PaddingStyle name t r b l ->
                t == b && t == r && t == l && t >= 0 && t <= 24

            -- SpacingStyle _ _ _ ->
            --     True
            -- FontFamily _ _ ->
            --     True
            _ ->
                False


gatherAttrRecursive : String -> NodeName -> Flag.Field -> Transformation -> List Style -> List (VirtualDom.Attribute msg) -> List (VirtualDom.Node msg) -> List (Attribute aligned msg) -> Gathered msg
gatherAttrRecursive classes node has transform styles attrs children elementAttrs =
    case elementAttrs of
        [] ->
            case transformClass transform of
                Nothing ->
                    { attributes = Html.Attributes.class classes :: attrs
                    , styles = styles
                    , node = node
                    , children = children
                    , has = has
                    }

                Just class ->
                    { attributes = Html.Attributes.class (classes ++ " " ++ class) :: attrs
                    , styles = Transform transform :: styles
                    , node = node
                    , children = children
                    , has = has
                    }

        attribute :: remaining ->
            case attribute of
                NoAttribute ->
                    gatherAttrRecursive classes node has transform styles attrs children remaining

                Class flag exactClassName ->
                    if Flag.present flag has then
                        gatherAttrRecursive classes node has transform styles attrs children remaining
                    else
                        gatherAttrRecursive (exactClassName ++ " " ++ classes) node (Flag.add flag has) transform styles attrs children remaining

                Attr actualAttribute ->
                    gatherAttrRecursive classes node has transform styles (actualAttribute :: attrs) children remaining

                StyleClass flag style ->
                    if Flag.present flag has then
                        gatherAttrRecursive classes node has transform styles attrs children remaining
                    else if skippable flag style then
                        gatherAttrRecursive (getStyleName style ++ " " ++ classes)
                            node
                            (Flag.add flag has)
                            transform
                            styles
                            attrs
                            children
                            remaining
                    else
                        gatherAttrRecursive (getStyleName style ++ " " ++ classes)
                            node
                            (Flag.add flag has)
                            transform
                            (style :: styles)
                            attrs
                            children
                            remaining

                TransformComponent flag component ->
                    gatherAttrRecursive classes
                        node
                        (Flag.add flag has)
                        (composeTransformation transform component)
                        styles
                        attrs
                        children
                        remaining

                Width width ->
                    if Flag.present Flag.width has then
                        gatherAttrRecursive classes node has transform styles attrs children remaining
                    else
                        case width of
                            Px px ->
                                gatherAttrRecursive ((Internal.Style.classes.widthExact ++ " width-px-" ++ String.fromInt px) ++ " " ++ classes)
                                    node
                                    (Flag.add Flag.width has)
                                    transform
                                    (Single ("width-px-" ++ String.fromInt px) "width" (String.fromInt px ++ "px") :: styles)
                                    attrs
                                    children
                                    remaining

                            Content ->
                                gatherAttrRecursive (classes ++ " " ++ Internal.Style.classes.widthContent)
                                    node
                                    (Flag.add Flag.widthContent (Flag.add Flag.width has))
                                    transform
                                    styles
                                    attrs
                                    children
                                    remaining

                            Fill portion ->
                                if portion == 1 then
                                    gatherAttrRecursive (classes ++ " " ++ Internal.Style.classes.widthFill)
                                        node
                                        (Flag.add Flag.widthFill (Flag.add Flag.width has))
                                        transform
                                        styles
                                        attrs
                                        children
                                        remaining
                                else
                                    gatherAttrRecursive (classes ++ " " ++ Internal.Style.classes.widthFillPortion ++ " width-fill-" ++ String.fromInt portion)
                                        node
                                        (Flag.add Flag.widthFill (Flag.add Flag.width has))
                                        transform
                                        (Single
                                            (Internal.Style.classes.any
                                                ++ "."
                                                ++ Internal.Style.classes.row
                                                ++ " > "
                                                ++ (Internal.Style.dot <| "width-fill-" ++ String.fromInt portion)
                                            )
                                            "flex-grow"
                                            (String.fromInt (portion * 100000))
                                            :: styles
                                        )
                                        attrs
                                        children
                                        remaining

                            _ ->
                                let
                                    ( addToFlags, newClass, newStyles ) =
                                        renderWidth width
                                in
                                gatherAttrRecursive (classes ++ " " ++ newClass)
                                    node
                                    (Flag.merge addToFlags has)
                                    transform
                                    (newStyles ++ styles)
                                    attrs
                                    children
                                    remaining

                Height height ->
                    if Flag.present Flag.height has then
                        gatherAttrRecursive classes node has transform styles attrs children remaining
                    else
                        case height of
                            Px px ->
                                let
                                    val =
                                        String.fromInt px ++ "px"

                                    name =
                                        "height-px-" ++ val
                                in
                                gatherAttrRecursive (name ++ " " ++ classes)
                                    node
                                    (Flag.add Flag.height has)
                                    transform
                                    (Single name "height " val :: styles)
                                    attrs
                                    children
                                    remaining

                            Content ->
                                gatherAttrRecursive (Internal.Style.classes.heightContent ++ " " ++ classes)
                                    node
                                    (Flag.add Flag.heightContent (Flag.add Flag.height has))
                                    transform
                                    styles
                                    attrs
                                    children
                                    remaining

                            Fill portion ->
                                if portion == 1 then
                                    gatherAttrRecursive (Internal.Style.classes.heightFill ++ " " ++ classes)
                                        node
                                        (Flag.add Flag.heightFill (Flag.add Flag.height has))
                                        transform
                                        styles
                                        attrs
                                        children
                                        remaining
                                else
                                    gatherAttrRecursive (classes ++ " " ++ (Internal.Style.classes.heightFillPortion ++ " height-fill-" ++ String.fromInt portion))
                                        node
                                        (Flag.add Flag.heightFill (Flag.add Flag.height has))
                                        transform
                                        (Single
                                            (Internal.Style.classes.any
                                                ++ "."
                                                ++ Internal.Style.classes.column
                                                ++ " > "
                                                ++ (Internal.Style.dot <| "height-fill-" ++ String.fromInt portion)
                                            )
                                            "flex-grow"
                                            (String.fromInt (portion * 100000))
                                            :: styles
                                        )
                                        attrs
                                        children
                                        remaining

                            _ ->
                                let
                                    ( addToFlags, newClass, newStyles ) =
                                        renderHeight height
                                in
                                gatherAttrRecursive (classes ++ " " ++ newClass)
                                    node
                                    (Flag.merge addToFlags has)
                                    transform
                                    (newStyles ++ styles)
                                    attrs
                                    children
                                    remaining

                Describe description ->
                    case description of
                        Main ->
                            gatherAttrRecursive classes (addNodeName "main" node) has transform styles attrs children remaining

                        Navigation ->
                            gatherAttrRecursive classes (addNodeName "nav" node) has transform styles attrs children remaining

                        ContentInfo ->
                            gatherAttrRecursive classes (addNodeName "footer" node) has transform styles attrs children remaining

                        Complementary ->
                            gatherAttrRecursive classes (addNodeName "aside" node) has transform styles attrs children remaining

                        Heading i ->
                            if i <= 1 then
                                gatherAttrRecursive classes (addNodeName "h1" node) has transform styles attrs children remaining
                            else if i < 7 then
                                gatherAttrRecursive classes (addNodeName ("h" ++ String.fromInt i) node) has transform styles attrs children remaining
                            else
                                gatherAttrRecursive classes (addNodeName "h6" node) has transform styles attrs children remaining

                        Paragraph ->
                            let
                                newNode =
                                    case node of
                                        Generic ->
                                            NodeName "p"

                                        NodeName name ->
                                            NodeName name

                                        Embedded x y ->
                                            Embedded x y
                            in
                            gatherAttrRecursive classes
                                newNode
                                has
                                transform
                                styles
                                attrs
                                children
                                remaining

                        Button ->
                            gatherAttrRecursive classes node has transform styles (VirtualDom.attribute "role" "button" :: attrs) children remaining

                        Label label ->
                            gatherAttrRecursive classes node has transform styles (VirtualDom.attribute "aria-label" label :: attrs) children remaining

                        LivePolite ->
                            gatherAttrRecursive classes node has transform styles (VirtualDom.attribute "aria-live" "polite" :: attrs) children remaining

                        LiveAssertive ->
                            gatherAttrRecursive classes node has transform styles (VirtualDom.attribute "aria-live" "assertive" :: attrs) children remaining

                Nearby location elem ->
                    let
                        newStyles =
                            case elem of
                                Empty ->
                                    styles

                                Text str ->
                                    styles

                                Unstyled html ->
                                    styles

                                Styled styled ->
                                    styles ++ styled.styles

                        nearbyElement =
                            Html.div
                                [ Html.Attributes.class <|
                                    case location of
                                        Above ->
                                            String.join " "
                                                [ Internal.Style.classes.any
                                                , Internal.Style.classes.single
                                                , Internal.Style.classes.above
                                                ]

                                        Below ->
                                            String.join " "
                                                [ Internal.Style.classes.any
                                                , Internal.Style.classes.single
                                                , Internal.Style.classes.below
                                                ]

                                        OnRight ->
                                            String.join " "
                                                [ Internal.Style.classes.any
                                                , Internal.Style.classes.single
                                                , Internal.Style.classes.onRight
                                                ]

                                        OnLeft ->
                                            String.join " "
                                                [ Internal.Style.classes.any
                                                , Internal.Style.classes.single
                                                , Internal.Style.classes.onLeft
                                                ]

                                        InFront ->
                                            String.join " "
                                                [ Internal.Style.classes.any
                                                , Internal.Style.classes.single
                                                , Internal.Style.classes.inFront
                                                ]

                                        Behind ->
                                            String.join " "
                                                [ Internal.Style.classes.any
                                                , Internal.Style.classes.single
                                                , Internal.Style.classes.behind
                                                ]
                                ]
                                [ case elem of
                                    Empty ->
                                        VirtualDom.text ""

                                    Text str ->
                                        textElement str

                                    Unstyled html ->
                                        html asEl

                                    Styled styled ->
                                        styled.html NoStyleSheet asEl
                                ]

                        newClasses =
                            if location == Behind then
                                Internal.Style.classes.hasBehind ++ " " ++ classes
                            else
                                classes
                    in
                    gatherAttrRecursive newClasses node has transform newStyles attrs (nearbyElement :: children) remaining

                AlignX x ->
                    if Flag.present Flag.xAlign has then
                        gatherAttrRecursive classes node has transform styles attrs children remaining
                    else
                        gatherAttrRecursive (alignXName x ++ " " ++ classes)
                            node
                            (has
                                |> Flag.add Flag.xAlign
                                |> (\flags ->
                                        case x of
                                            CenterX ->
                                                Flag.add Flag.centerX flags

                                            Right ->
                                                Flag.add Flag.alignRight flags

                                            _ ->
                                                flags
                                   )
                            )
                            transform
                            styles
                            attrs
                            children
                            remaining

                AlignY y ->
                    if Flag.present Flag.yAlign has then
                        gatherAttrRecursive classes node has transform styles attrs children remaining
                    else
                        gatherAttrRecursive (alignYName y ++ " " ++ classes)
                            node
                            (Flag.add Flag.yAlign has
                                |> (\flags ->
                                        case y of
                                            CenterY ->
                                                Flag.add Flag.centerY flags

                                            Bottom ->
                                                Flag.add Flag.alignBottom flags

                                            _ ->
                                                flags
                                   )
                            )
                            transform
                            styles
                            attrs
                            children
                            remaining


renderWidth w =
    case w of
        Px px ->
            ( Flag.none
            , Internal.Style.classes.widthExact ++ " width-px-" ++ String.fromInt px
            , [ Single ("width-px-" ++ String.fromInt px) "width" (String.fromInt px ++ "px") ]
            )

        Content ->
            ( Flag.add Flag.widthContent Flag.none
            , Internal.Style.classes.widthContent
            , []
            )

        Fill portion ->
            if portion == 1 then
                ( Flag.add Flag.widthFill Flag.none
                , Internal.Style.classes.widthFill
                , []
                )
            else
                ( Flag.add Flag.widthFill Flag.none
                , Internal.Style.classes.widthFillPortion ++ " width-fill-" ++ String.fromInt portion
                , [ Single
                        (Internal.Style.classes.any
                            ++ "."
                            ++ Internal.Style.classes.row
                            ++ " > "
                            ++ (Internal.Style.dot <| "width-fill-" ++ String.fromInt portion)
                        )
                        "flex-grow"
                        (String.fromInt (portion * 100000))
                  ]
                )

        Min minSize len ->
            let
                cls =
                    "min-width-"
                        ++ String.fromInt minSize

                style =
                    Single
                        cls
                        "min-width"
                        (String.fromInt minSize ++ "px")

                ( newFlag, newAttrs, newStyle ) =
                    renderWidth len
            in
            ( Flag.add Flag.widthBetween newFlag
            , cls ++ " " ++ newAttrs
            , style :: newStyle
            )

        Max maxSize len ->
            let
                cls =
                    "max-width-" ++ String.fromInt maxSize

                style =
                    Single cls
                        "max-width"
                        (String.fromInt maxSize ++ "px")

                ( newFlag, newAttrs, newStyle ) =
                    renderWidth len
            in
            ( Flag.add Flag.widthBetween newFlag
            , cls ++ " " ++ newAttrs
            , style :: newStyle
            )


renderHeight h =
    case h of
        Px px ->
            let
                val =
                    String.fromInt px

                name =
                    "height-px-" ++ val
            in
            ( Flag.none
            , name
            , [ Single name "height" (val ++ "px") ]
            )

        Content ->
            ( Flag.add Flag.heightContent Flag.none
            , Internal.Style.classes.heightContent
            , []
            )

        Fill portion ->
            if portion == 1 then
                ( Flag.add Flag.heightFill Flag.none
                , Internal.Style.classes.heightFill
                , []
                )
            else
                ( Flag.add Flag.heightFill Flag.none
                , Internal.Style.classes.heightFillPortion ++ " height-fill-" ++ String.fromInt portion
                , [ Single
                        (Internal.Style.classes.any
                            ++ "."
                            ++ Internal.Style.classes.row
                            ++ " > "
                            ++ (Internal.Style.dot <| "height-fill-" ++ String.fromInt portion)
                        )
                        "flex-grow"
                        (String.fromInt (portion * 100000))
                  ]
                )

        Min minSize len ->
            let
                cls =
                    "min-height-"
                        ++ String.fromInt minSize

                style =
                    Single
                        cls
                        "min-height"
                        (String.fromInt minSize ++ "px")

                ( newFlag, newAttrs, newStyle ) =
                    renderHeight len
            in
            ( Flag.add Flag.heightBetween newFlag
            , cls ++ " " ++ newAttrs
            , style :: newStyle
            )

        Max maxSize len ->
            let
                cls =
                    "max-height-" ++ String.fromInt maxSize

                style =
                    Single cls
                        "max-height"
                        (String.fromInt maxSize ++ "px")

                ( newFlag, newAttrs, newStyle ) =
                    renderHeight len
            in
            ( Flag.add Flag.heightBetween newFlag
            , cls ++ " " ++ newAttrs
            , style :: newStyle
            )


rowClass =
    classes.any ++ " " ++ classes.row


columnClass =
    classes.any ++ " " ++ classes.column


singleClass =
    classes.any ++ " " ++ classes.single


gridClass =
    classes.any ++ " " ++ classes.grid


paragraphClass =
    classes.any ++ " " ++ classes.paragraph


pageClass =
    classes.any ++ " " ++ classes.page


contextClasses context =
    case context of
        AsRow ->
            rowClass

        AsColumn ->
            columnClass

        AsEl ->
            singleClass

        AsGrid ->
            gridClass

        AsParagraph ->
            paragraphClass

        AsTextColumn ->
            pageClass


element : LayoutContext -> NodeName -> List (Attribute aligned msg) -> Children (Element msg) -> Element msg
element context node attributes children =
    attributes
        |> List.reverse
        |> gatherAttrRecursive (contextClasses context) node Flag.none untransformed [] [] []
        |> createElement context children


untransformed =
    Untransformed



-- space =
--     VirtualDom.text " "
-- keyedSpace =
--     ( " ", space )


createElement : LayoutContext -> Children (Element msg) -> Gathered msg -> Element msg
createElement context children rendered =
    let
        gather child ( htmls, existingStyles ) =
            case child of
                Unstyled html ->
                    if context == asParagraph then
                        ( html context :: htmls
                        , existingStyles
                        )
                    else
                        ( html context :: htmls
                        , existingStyles
                        )

                Styled styled ->
                    if context == asParagraph then
                        ( styled.html NoStyleSheet context :: htmls
                        , if List.isEmpty existingStyles then
                            styled.styles
                          else
                            styled.styles ++ existingStyles
                        )
                    else
                        ( styled.html NoStyleSheet context :: htmls
                        , if List.isEmpty existingStyles then
                            styled.styles
                          else
                            styled.styles ++ existingStyles
                        )

                Text str ->
                    -- TEXT OPTIMIZATION
                    -- You can have raw text if the element is an el, and has `width-content` and `height-content`
                    -- Same if it's a column or row with one child and width-content, height-content
                    -- interferes with css grid
                    -- Maybe we could unpack text elements in a paragraph as well,
                    -- however  embedded style elements that are larger than the line height will overlap with exisitng text.
                    -- I don't think that's what we want.
                    if
                        context
                            == asEl
                            || context
                            == asParagraph
                    then
                        ( VirtualDom.text
                            (if context == asParagraph then
                                str ++ " "
                             else
                                str
                            )
                            :: htmls
                        , existingStyles
                        )
                    else
                        ( textElement
                            (if context == asParagraph then
                                str ++ " "
                             else
                                str
                            )
                            :: htmls
                        , existingStyles
                        )

                Empty ->
                    ( htmls, existingStyles )

        gatherKeyed ( key, child ) ( htmls, existingStyles ) =
            case child of
                Unstyled html ->
                    if context == asParagraph then
                        ( ( key, html context ) :: htmls
                        , existingStyles
                        )
                    else
                        ( ( key, html context ) :: htmls
                        , existingStyles
                        )

                Styled styled ->
                    if context == asParagraph then
                        ( ( key, styled.html NoStyleSheet context )
                            :: htmls
                        , if List.isEmpty existingStyles then
                            styled.styles
                          else
                            styled.styles ++ existingStyles
                        )
                    else
                        ( ( key, styled.html NoStyleSheet context ) :: htmls
                        , if List.isEmpty existingStyles then
                            styled.styles
                          else
                            styled.styles ++ existingStyles
                        )

                Text str ->
                    -- TEXT OPTIMIZATION
                    -- You can have raw text if the element is an el, and has `width-content` and `height-content`
                    -- Same if it's a column or row with one child and width-content, height-content
                    if
                        context
                            == asEl
                            || context
                            == asParagraph
                    then
                        ( ( key
                          , VirtualDom.text
                                (if context == asParagraph then
                                    str ++ " "
                                 else
                                    str
                                )
                          )
                            :: htmls
                        , existingStyles
                        )
                    else
                        ( ( key
                          , textElement
                                (if context == asParagraph then
                                    str ++ " "
                                 else
                                    str
                                )
                          )
                            :: htmls
                        , existingStyles
                        )

                Empty ->
                    ( htmls, existingStyles )
    in
    case children of
        Keyed keyedChildren ->
            case List.foldr gatherKeyed ( [], [] ) keyedChildren of
                ( keyed, styles ) ->
                    let
                        newStyles =
                            if List.isEmpty styles then
                                rendered.styles
                            else
                                rendered.styles ++ styles
                    in
                    case newStyles of
                        [] ->
                            Unstyled
                                (finalizeNode rendered.has
                                    rendered.node
                                    rendered.attributes
                                    (Keyed <| List.map (\x -> ( "nearby-elements-pls", x )) rendered.children ++ keyed)
                                    NoStyleSheet
                                )

                        allStyles ->
                            Styled
                                { styles = allStyles
                                , html =
                                    finalizeNode rendered.has rendered.node rendered.attributes (Keyed (List.map (\x -> ( "nearby-elements-pls", x )) rendered.children ++ keyed))
                                }

        Unkeyed unkeyedChildren ->
            case List.foldr gather ( [], [] ) unkeyedChildren of
                ( unkeyed, styles ) ->
                    let
                        newStyles =
                            if List.isEmpty styles then
                                rendered.styles
                            else
                                rendered.styles ++ styles
                    in
                    case newStyles of
                        [] ->
                            Unstyled
                                (finalizeNode rendered.has
                                    rendered.node
                                    rendered.attributes
                                    (Unkeyed <| rendered.children ++ unkeyed)
                                    NoStyleSheet
                                )

                        allStyles ->
                            Styled
                                { styles = allStyles
                                , html = finalizeNode rendered.has rendered.node rendered.attributes (Unkeyed (rendered.children ++ unkeyed))
                                }


unit =
    0


defaultOptions =
    { hover = AllowHover
    , focus = focusDefaultStyle
    , mode = Layout
    }


staticRoot =
    VirtualDom.node "style" [] [ VirtualDom.text Internal.Style.rules ]


addWhen ifThis x to =
    if ifThis then
        x :: to
    else
        to


{-| TODO:

This doesn't reduce equivalent attributes completely.

-}
filter : List (Attribute aligned msg) -> List (Attribute aligned msg)
filter attrs =
    Tuple.first <|
        List.foldr
            (\x ( found, has ) ->
                case x of
                    NoAttribute ->
                        ( found, has )

                    Class key _ ->
                        ( x :: found, has )

                    Attr attr ->
                        ( x :: found, has )

                    StyleClass _ style ->
                        ( x :: found, has )

                    Width width ->
                        if Set.member "width" has then
                            ( found, has )
                        else
                            ( x :: found, Set.insert "width" has )

                    Height height ->
                        if Set.member "height" has then
                            ( found, has )
                        else
                            ( x :: found, Set.insert "height" has )

                    Describe description ->
                        if Set.member "described" has then
                            ( found, has )
                        else
                            ( x :: found, Set.insert "described" has )

                    Nearby location elem ->
                        ( x :: found, has )

                    AlignX _ ->
                        if Set.member "align-x" has then
                            ( found, has )
                        else
                            ( x :: found, Set.insert "align-x" has )

                    AlignY _ ->
                        if Set.member "align-y" has then
                            ( found, has )
                        else
                            ( x :: found, Set.insert "align-y" has )

                    TransformComponent _ _ ->
                        if Set.member "transform" has then
                            ( found, has )
                        else
                            ( x :: found, Set.insert "transform" has )
            )
            ( [], Set.empty )
            attrs


get : List (Attribute aligned msg) -> (Attribute aligned msg -> Bool) -> List (Attribute aligned msg)
get attrs isAttr =
    attrs
        |> filter
        |> List.foldr
            (\x found ->
                if isAttr x then
                    x :: found
                else
                    found
            )
            []


type Spacing
    = Spaced String Int Int


type Padding
    = Padding String Int Int Int Int


extractSpacingAndPadding : List (Attribute aligned msg) -> ( Maybe Padding, Maybe Spacing )
extractSpacingAndPadding attrs =
    List.foldr
        (\attr ( pad, spacing ) ->
            ( case pad of
                Just x ->
                    pad

                Nothing ->
                    case attr of
                        StyleClass _ (PaddingStyle name t r b l) ->
                            Just (Padding name t r b l)

                        _ ->
                            Nothing
            , case spacing of
                Just x ->
                    spacing

                Nothing ->
                    case attr of
                        StyleClass _ (SpacingStyle name x y) ->
                            Just (Spaced name x y)

                        _ ->
                            Nothing
            )
        )
        ( Nothing, Nothing )
        attrs


getSpacing : List (Attribute aligned msg) -> ( Int, Int ) -> ( Int, Int )
getSpacing attrs default =
    attrs
        |> List.foldr
            (\attr acc ->
                case acc of
                    Just x ->
                        Just x

                    Nothing ->
                        case attr of
                            StyleClass _ (SpacingStyle _ x y) ->
                                Just ( x, y )

                            _ ->
                                Nothing
            )
            Nothing
        |> Maybe.withDefault default


getWidth : List (Attribute aligned msg) -> Maybe Length
getWidth attrs =
    attrs
        |> List.foldr
            (\attr acc ->
                case acc of
                    Just x ->
                        Just x

                    Nothing ->
                        case attr of
                            Width len ->
                                Just len

                            _ ->
                                Nothing
            )
            Nothing


getHeight : List (Attribute aligned msg) -> Maybe Length
getHeight attrs =
    attrs
        |> List.foldr
            (\attr acc ->
                case acc of
                    Just x ->
                        Just x

                    Nothing ->
                        case attr of
                            Height len ->
                                Just len

                            _ ->
                                Nothing
            )
            Nothing


textElement : String -> VirtualDom.Node msg
textElement str =
    Html.div
        [ Html.Attributes.class
            (String.join " "
                [ classes.any
                , classes.text
                , classes.widthContent
                , classes.heightContent
                ]
            )
        ]
        [ Html.text str ]


textElementFill : String -> VirtualDom.Node msg
textElementFill str =
    VirtualDom.node "div"
        [ VirtualDom.property "className"
            (Json.string <|
                String.join " "
                    [ classes.any
                    , classes.text
                    , classes.widthFill
                    , classes.heightFill
                    ]
            )
        ]
        [ VirtualDom.text str ]


type Children x
    = Unkeyed (List x)
    | Keyed (List ( String, x ))



-- toHtml : OptionRecord -> Element msg -> VirtualDom.Node msg


toHtml mode el =
    case el of
        Unstyled html ->
            html asEl

        Styled { styles, html } ->
            html (mode styles) asEl

        Text text ->
            textElement text

        Empty ->
            textElement ""


{-| -}
renderRoot : List Option -> List (Attribute aligned msg) -> Element msg -> VirtualDom.Node msg
renderRoot optionList attributes child =
    let
        options =
            optionsToRecord optionList

        embedStyle =
            case options.mode of
                NoStaticStyleSheet ->
                    OnlyDynamic options

                _ ->
                    StaticRootAndDynamic options
    in
    element asEl div attributes (Unkeyed [ child ])
        |> toHtml embedStyle


type RenderMode
    = Viewport
    | Layout
    | NoStaticStyleSheet
    | WithVirtualCss


type alias OptionRecord =
    { hover : HoverSetting
    , focus : FocusStyle
    , mode : RenderMode
    }


type HoverSetting
    = NoHover
    | AllowHover
    | ForceHover


type Option
    = HoverOption HoverSetting
    | FocusStyleOption FocusStyle
    | RenderModeOption RenderMode


type alias FocusStyle =
    { borderColor : Maybe Color
    , shadow : Maybe Shadow
    , backgroundColor : Maybe Color
    }


type alias Shadow =
    { color : Color
    , offset : ( Int, Int )
    , blur : Int
    , size : Int
    }


rootStyle : List (Attribute aligned msg)
rootStyle =
    let
        families =
            [ Typeface "Open Sans"
            , Typeface "Helvetica"
            , Typeface "Verdana"
            , SansSerif
            ]
    in
    [ StyleClass Flag.bgColor (Colored ("bg-color-" ++ formatColorClass (Rgba 1 1 1 1)) "background-color" (Rgba 1 1 1 1))
    , StyleClass Flag.fontColor (Colored ("font-color-" ++ formatColorClass (Rgba 0 0 0 1)) "color" (Rgba 0 0 0 1))

    -- , StyleClass Flag.fontSize (Single "font-size-20" "font-size" "20px")
    , StyleClass Flag.fontSize (FontSize 20)
    , StyleClass Flag.fontFamily <|
        FontFamily (List.foldl renderFontClassName "font-" families)
            families
    ]


renderFontClassName : Font -> String -> String
renderFontClassName font current =
    current
        ++ (case font of
                Serif ->
                    "serif"

                SansSerif ->
                    "sans-serif"

                Monospace ->
                    "monospace"

                Typeface name ->
                    name
                        |> String.toLower
                        |> String.words
                        |> String.join "-"

                ImportFont name url ->
                    name
                        |> String.toLower
                        |> String.words
                        |> String.join "-"
           )


renderFocusStyle :
    FocusStyle
    -> Style
renderFocusStyle focus =
    Style (Internal.Style.dot classes.any ++ ":focus .focusable, " ++ Internal.Style.dot classes.any ++ ".focusable:focus")
        (List.filterMap identity
            [ Maybe.map (\color -> Property "border-color" (formatColor color)) focus.borderColor
            , Maybe.map (\color -> Property "background-color" (formatColor color)) focus.backgroundColor
            , Maybe.map
                (\shadow ->
                    Property "box-shadow"
                        (formatBoxShadow
                            { color = shadow.color
                            , offset =
                                shadow.offset
                                    |> Tuple.mapFirst toFloat
                                    |> Tuple.mapSecond toFloat
                            , inset = False
                            , blur = toFloat shadow.blur
                            , size = toFloat shadow.size
                            }
                        )
                )
                focus.shadow
            , Just <| Property "outline" "none"
            ]
        )


focusDefaultStyle : { backgroundColor : Maybe Color, borderColor : Maybe Color, shadow : Maybe Shadow }
focusDefaultStyle =
    { backgroundColor = Nothing
    , borderColor = Nothing
    , shadow =
        Just
            { color =
                Rgba (155 / 255) (203 / 255) 1 1
            , offset = ( 0, 0 )
            , blur = 3
            , size = 3
            }
    }


optionsToRecord : List Option -> OptionRecord
optionsToRecord options =
    let
        combine opt record =
            case opt of
                HoverOption hoverable ->
                    case record.hover of
                        Nothing ->
                            { record | hover = Just hoverable }

                        _ ->
                            record

                FocusStyleOption focusStyle ->
                    case record.focus of
                        Nothing ->
                            { record | focus = Just focusStyle }

                        _ ->
                            record

                RenderModeOption renderMode ->
                    case record.mode of
                        Nothing ->
                            { record | mode = Just renderMode }

                        _ ->
                            record

        andFinally record =
            { hover =
                case record.hover of
                    Nothing ->
                        AllowHover

                    Just hoverable ->
                        hoverable
            , focus =
                case record.focus of
                    Nothing ->
                        focusDefaultStyle

                    Just focusable ->
                        focusable
            , mode =
                case record.mode of
                    Nothing ->
                        Layout

                    Just actualMode ->
                        actualMode
            }
    in
    andFinally <|
        List.foldr combine
            { hover = Nothing
            , focus = Nothing
            , mode = Nothing
            }
            options


renderFont : List Font -> String
renderFont families =
    let
        fontName font =
            case font of
                Serif ->
                    "serif"

                SansSerif ->
                    "sans-serif"

                Monospace ->
                    "monospace"

                Typeface name ->
                    "\"" ++ name ++ "\""

                ImportFont name url ->
                    "\"" ++ name ++ "\""
    in
    families
        |> List.map fontName
        |> String.join ", "


toStyleSheet : OptionRecord -> List Style -> VirtualDom.Node msg
toStyleSheet options styleSheet =
    VirtualDom.node "style" [] [ VirtualDom.text (toStyleSheetString options styleSheet) ]


toStyleSheetString : OptionRecord -> List Style -> String
toStyleSheetString options stylesheet =
    let
        renderTopLevels rule =
            case rule of
                FontFamily name typefaces ->
                    let
                        getImports font =
                            case font of
                                ImportFont _ url ->
                                    Just ("@import url('" ++ url ++ "');")

                                _ ->
                                    Nothing
                    in
                    typefaces
                        |> List.filterMap getImports
                        |> String.join "\n"
                        |> Just

                _ ->
                    Nothing

        renderProps force (Property key val) existing =
            if force then
                existing ++ "\n  " ++ key ++ ": " ++ val ++ " !important;"
            else
                existing ++ "\n  " ++ key ++ ": " ++ val ++ ";"

        renderStyle maybePseudo selector props =
            case maybePseudo of
                Nothing ->
                    selector ++ "{" ++ List.foldl (renderProps False) "" props ++ "\n}"

                Just pseudo ->
                    case pseudo of
                        Hover ->
                            case options.hover of
                                NoHover ->
                                    ""

                                ForceHover ->
                                    selector ++ "-hv {" ++ List.foldl (renderProps True) "" props ++ "\n}"

                                AllowHover ->
                                    selector ++ "-hv:hover {" ++ List.foldl (renderProps False) "" props ++ "\n}"

                        Focus ->
                            let
                                renderedProps =
                                    List.foldl (renderProps False) "" props
                            in
                            String.join "\n"
                                [ selector
                                    ++ "-fs:focus {"
                                    ++ renderedProps
                                    ++ "\n}"
                                , "."
                                    ++ classes.any
                                    ++ ":focus ~ "
                                    ++ selector
                                    ++ "-fs:not(.focus)  {"
                                    ++ renderedProps
                                    ++ "\n}"
                                , "."
                                    ++ classes.any
                                    ++ ":focus "
                                    ++ selector
                                    ++ "-fs  {"
                                    ++ renderedProps
                                    ++ "\n}"
                                , ".focusable-parent:focus ~ "
                                    ++ "."
                                    ++ classes.any
                                    ++ " "
                                    ++ selector
                                    ++ "-fs {"
                                    ++ renderedProps
                                    ++ "\n}"
                                ]

                        Active ->
                            selector ++ "-act:active {" ++ List.foldl (renderProps False) "" props ++ "\n}"

        renderStyleRule rule maybePseudo =
            case rule of
                Style selector props ->
                    renderStyle maybePseudo selector props

                Shadows name prop ->
                    renderStyle
                        maybePseudo
                        ("." ++ name)
                        [ Property "box-shadow" prop
                        ]

                Transparency name transparency ->
                    let
                        opacity =
                            (1 - transparency)
                                |> min 1
                                |> max 0
                    in
                    renderStyle
                        maybePseudo
                        ("." ++ name)
                        [ Property "opacity" (String.fromFloat opacity)
                        ]

                FontSize i ->
                    renderStyle
                        maybePseudo
                        (".font-size-" ++ String.fromInt i)
                        [ Property "font-size" (String.fromInt i ++ "px")
                        ]

                FontFamily name typefaces ->
                    renderStyle
                        maybePseudo
                        ("." ++ name)
                        [ Property "font-family" (renderFont typefaces)
                        ]

                Single class prop val ->
                    renderStyle
                        maybePseudo
                        ("." ++ class)
                        [ Property prop val
                        ]

                Colored class prop color ->
                    renderStyle
                        maybePseudo
                        ("." ++ class)
                        [ Property prop (formatColor color)
                        ]

                SpacingStyle cls x y ->
                    let
                        class =
                            "." ++ cls

                        xPx =
                            String.fromInt x ++ "px"

                        yPx =
                            String.fromInt y ++ "px"

                        row =
                            "." ++ Internal.Style.classes.row

                        wrappedRow =
                            "." ++ Internal.Style.classes.wrapped ++ row

                        column =
                            "." ++ Internal.Style.classes.column

                        page =
                            "." ++ Internal.Style.classes.page

                        paragraph =
                            "." ++ Internal.Style.classes.paragraph

                        left =
                            "." ++ Internal.Style.classes.alignLeft

                        right =
                            "." ++ Internal.Style.classes.alignRight

                        any =
                            "." ++ Internal.Style.classes.any

                        single =
                            "." ++ Internal.Style.classes.single
                    in
                    String.concat
                        [ renderStyle maybePseudo (class ++ row ++ " > " ++ any) [ Property "margin-right" xPx ]

                        -- margins don't apply to last element of normal, unwrapped rows
                        , renderStyle maybePseudo (class ++ row ++ " > " ++ any ++ ":last-child") [ Property "margin" "0" ]

                        -- For wrapped rows, margins always apply because we handle "canceling out" the other margins manually in the element.
                        , renderStyle maybePseudo
                            (class ++ wrappedRow ++ " > " ++ any)
                            [ Property "margin" ("0 " ++ xPx ++ " " ++ yPx ++ " 0")
                            ]
                        , renderStyle maybePseudo
                            (class ++ wrappedRow ++ " > " ++ any ++ ":last-child")
                            [ Property "margin-right" "0"
                            ]

                        -- columns
                        , renderStyle maybePseudo (class ++ column ++ " > " ++ any ++ " + " ++ any) [ Property "margin-top" yPx ]
                        , renderStyle maybePseudo (class ++ page ++ " > " ++ any ++ " + " ++ any) [ Property "margin-top" yPx ]
                        , renderStyle maybePseudo (class ++ page ++ " > " ++ left) [ Property "margin-right" xPx ]
                        , renderStyle maybePseudo (class ++ page ++ " > " ++ right) [ Property "margin-left" xPx ]
                        , renderStyle
                            maybePseudo
                            (class ++ paragraph)
                            [ Property "line-height" ("calc(1em + " ++ String.fromInt y ++ "px)")
                            ]
                        , renderStyle
                            maybePseudo
                            ("textarea" ++ class)
                            [ Property "line-height" ("calc(1em + " ++ String.fromInt y ++ "px)")
                            ]

                        -- , renderStyle
                        --     maybePseudo
                        --     (class ++ paragraph ++ " > " ++ any)
                        --     [ Property "margin-right" xPx
                        --     , Property "margin-bottom" yPx
                        --     ]
                        , renderStyle
                            maybePseudo
                            (class ++ paragraph ++ " > " ++ left)
                            [ Property "margin-right" xPx
                            ]
                        , renderStyle
                            maybePseudo
                            (class ++ paragraph ++ " > " ++ right)
                            [ Property "margin-left" xPx
                            ]
                        , renderStyle
                            maybePseudo
                            (class ++ paragraph ++ "::after")
                            [ Property "content" "''"
                            , Property "display" "block"
                            , Property "height" "0"
                            , Property "width" "0"
                            , Property "margin-top" (String.fromInt (-1 * (y // 2)) ++ "px")
                            ]
                        , renderStyle
                            maybePseudo
                            (class ++ paragraph ++ "::before")
                            [ Property "content" "''"
                            , Property "display" "block"
                            , Property "height" "0"
                            , Property "width" "0"
                            , Property "margin-bottom" (String.fromInt (-1 * (y // 2)) ++ "px")
                            ]
                        ]

                PaddingStyle cls top right bottom left ->
                    let
                        class =
                            "."
                                ++ cls
                    in
                    renderStyle
                        maybePseudo
                        class
                        [ Property "padding"
                            (String.fromInt top
                                ++ "px "
                                ++ String.fromInt right
                                ++ "px "
                                ++ String.fromInt bottom
                                ++ "px "
                                ++ String.fromInt left
                                ++ "px"
                            )
                        ]

                GridTemplateStyle template ->
                    let
                        class =
                            ".grid-rows-"
                                ++ String.join "-" (List.map lengthClassName template.rows)
                                ++ "-cols-"
                                ++ String.join "-" (List.map lengthClassName template.columns)
                                ++ "-space-x-"
                                ++ lengthClassName (Tuple.first template.spacing)
                                ++ "-space-y-"
                                ++ lengthClassName (Tuple.second template.spacing)

                        ySpacing =
                            toGridLength (Tuple.second template.spacing)

                        xSpacing =
                            toGridLength (Tuple.first template.spacing)

                        toGridLength x =
                            toGridLengthHelper Nothing Nothing x

                        toGridLengthHelper minimum maximum x =
                            case x of
                                Px px ->
                                    String.fromInt px ++ "px"

                                Content ->
                                    case ( minimum, maximum ) of
                                        ( Nothing, Nothing ) ->
                                            "max-content"

                                        ( Just minSize, Nothing ) ->
                                            "minmax(" ++ String.fromInt minSize ++ "px, " ++ "max-content)"

                                        ( Nothing, Just maxSize ) ->
                                            "minmax(max-content, " ++ String.fromInt maxSize ++ "px)"

                                        ( Just minSize, Just maxSize ) ->
                                            "minmax(" ++ String.fromInt minSize ++ "px, " ++ String.fromInt maxSize ++ "px)"

                                Fill i ->
                                    case ( minimum, maximum ) of
                                        ( Nothing, Nothing ) ->
                                            String.fromInt i ++ "fr"

                                        ( Just minSize, Nothing ) ->
                                            "minmax(" ++ String.fromInt minSize ++ "px, " ++ String.fromInt i ++ "fr" ++ "fr)"

                                        ( Nothing, Just maxSize ) ->
                                            "minmax(max-content, " ++ String.fromInt maxSize ++ "px)"

                                        ( Just minSize, Just maxSize ) ->
                                            "minmax(" ++ String.fromInt minSize ++ "px, " ++ String.fromInt maxSize ++ "px)"

                                Min m len ->
                                    toGridLengthHelper (Just m) maximum len

                                Max m len ->
                                    toGridLengthHelper minimum (Just m) len

                        msColumns =
                            template.columns
                                |> List.map toGridLength
                                |> String.join ySpacing
                                |> (\x -> "-ms-grid-columns: " ++ x ++ ";")

                        msRows =
                            template.columns
                                |> List.map toGridLength
                                |> String.join ySpacing
                                |> (\x -> "-ms-grid-rows: " ++ x ++ ";")

                        base =
                            class ++ "{" ++ msColumns ++ msRows ++ "}"

                        columns =
                            template.columns
                                |> List.map toGridLength
                                |> String.join " "
                                |> (\x -> "grid-template-columns: " ++ x ++ ";")

                        rows =
                            template.rows
                                |> List.map toGridLength
                                |> String.join " "
                                |> (\x -> "grid-template-rows: " ++ x ++ ";")

                        gapX =
                            "grid-column-gap:" ++ toGridLength (Tuple.first template.spacing) ++ ";"

                        gapY =
                            "grid-row-gap:" ++ toGridLength (Tuple.second template.spacing) ++ ";"

                        modernGrid =
                            class ++ "{" ++ columns ++ rows ++ gapX ++ gapY ++ "}"

                        supports =
                            "@supports (display:grid) {" ++ modernGrid ++ "}"
                    in
                    base ++ supports

                GridPosition position ->
                    let
                        class =
                            ".grid-pos-"
                                ++ String.fromInt position.row
                                ++ "-"
                                ++ String.fromInt position.col
                                ++ "-"
                                ++ String.fromInt position.width
                                ++ "-"
                                ++ String.fromInt position.height

                        msPosition =
                            String.join " "
                                [ "-ms-grid-row: "
                                    ++ String.fromInt position.row
                                    ++ ";"
                                , "-ms-grid-row-span: "
                                    ++ String.fromInt position.height
                                    ++ ";"
                                , "-ms-grid-column: "
                                    ++ String.fromInt position.col
                                    ++ ";"
                                , "-ms-grid-column-span: "
                                    ++ String.fromInt position.width
                                    ++ ";"
                                ]

                        base =
                            class ++ "{" ++ msPosition ++ "}"

                        modernPosition =
                            String.join " "
                                [ "grid-row: "
                                    ++ String.fromInt position.row
                                    ++ " / "
                                    ++ String.fromInt (position.row + position.height)
                                    ++ ";"
                                , "grid-column: "
                                    ++ String.fromInt position.col
                                    ++ " / "
                                    ++ String.fromInt (position.col + position.width)
                                    ++ ";"
                                ]

                        modernGrid =
                            class ++ "{" ++ modernPosition ++ "}"

                        supports =
                            "@supports (display:grid) {" ++ modernGrid ++ "}"
                    in
                    base ++ supports

                PseudoSelector class styles ->
                    let
                        renderPseudoRule style =
                            renderStyleRule style (Just class)
                    in
                    List.map renderPseudoRule styles
                        |> String.join " "

                Transform transform ->
                    let
                        val =
                            transformValue transform

                        class =
                            transformClass transform
                    in
                    case ( class, val ) of
                        ( Just cls, Just v ) ->
                            renderStyle
                                maybePseudo
                                ("." ++ cls)
                                [ Property "transform"
                                    v
                                ]

                        _ ->
                            ""

        combine style rendered =
            { rendered
                | rules = rendered.rules ++ renderStyleRule style Nothing
                , topLevel =
                    case renderTopLevels style of
                        Nothing ->
                            rendered.topLevel

                        Just topLevel ->
                            rendered.topLevel ++ topLevel
            }
    in
    case List.foldl combine { rules = "", topLevel = "" } stylesheet of
        { topLevel, rules } ->
            topLevel ++ rules


lengthClassName : Length -> String
lengthClassName x =
    case x of
        Px px ->
            String.fromInt px ++ "px"

        Content ->
            "auto"

        Fill i ->
            String.fromInt i ++ "fr"

        Min min len ->
            "min" ++ String.fromInt min ++ lengthClassName len

        Max max len ->
            "max" ++ String.fromInt max ++ lengthClassName len


formatDropShadow shadow =
    String.join " "
        [ String.fromFloat (Tuple.first shadow.offset) ++ "px"
        , String.fromFloat (Tuple.second shadow.offset) ++ "px"
        , String.fromFloat shadow.blur ++ "px"
        , formatColor shadow.color
        ]


formatTextShadow shadow =
    String.join " "
        [ String.fromFloat (Tuple.first shadow.offset) ++ "px"
        , String.fromFloat (Tuple.second shadow.offset) ++ "px"
        , String.fromFloat shadow.blur ++ "px"
        , formatColor shadow.color
        ]


textShadowName shadow =
    String.concat
        [ "txt"
        , String.fromFloat (Tuple.first shadow.offset) ++ "px"
        , String.fromFloat (Tuple.second shadow.offset) ++ "px"
        , String.fromFloat shadow.blur ++ "px"
        , formatColorClass shadow.color
        ]


formatBoxShadow shadow =
    String.join " " <|
        List.filterMap identity
            [ if shadow.inset then
                Just "inset"
              else
                Nothing
            , Just <| String.fromFloat (Tuple.first shadow.offset) ++ "px"
            , Just <| String.fromFloat (Tuple.second shadow.offset) ++ "px"
            , Just <| String.fromFloat shadow.blur ++ "px"
            , Just <| String.fromFloat shadow.size ++ "px"
            , Just <| formatColor shadow.color
            ]


boxShadowName shadow =
    String.concat <|
        [ if shadow.inset then
            "box-inset"
          else
            "box-"
        , String.fromFloat (Tuple.first shadow.offset) ++ "px"
        , String.fromFloat (Tuple.second shadow.offset) ++ "px"
        , String.fromFloat shadow.blur ++ "px"
        , String.fromFloat shadow.size ++ "px"
        , formatColorClass shadow.color
        ]


floatClass : Float -> String
floatClass x =
    String.fromInt (round (x * 255))


formatColor : Color -> String
formatColor (Rgba red green blue alpha) =
    "rgba("
        ++ String.fromInt (round (red * 255))
        ++ ("," ++ String.fromInt (round (green * 255)))
        ++ ("," ++ String.fromInt (round (blue * 255)))
        ++ ("," ++ String.fromFloat alpha ++ ")")


formatColorClass : Color -> String
formatColorClass (Rgba red green blue alpha) =
    floatClass red
        ++ "-"
        ++ floatClass green
        ++ "-"
        ++ floatClass blue
        ++ "-"
        ++ floatClass alpha


spacingName x y =
    "spacing-" ++ String.fromInt x ++ "-" ++ String.fromInt y


paddingName top right bottom left =
    "pad-"
        ++ String.fromInt top
        ++ "-"
        ++ String.fromInt right
        ++ "-"
        ++ String.fromInt bottom
        ++ "-"
        ++ String.fromInt left


getStyleName : Style -> String
getStyleName style =
    case style of
        Shadows name _ ->
            name

        Transparency name o ->
            name

        Style class _ ->
            class

        FontFamily name _ ->
            name

        FontSize i ->
            "font-size-" ++ String.fromInt i

        Single class _ _ ->
            class

        Colored class _ _ ->
            class

        SpacingStyle cls x y ->
            cls

        PaddingStyle cls top right bottom left ->
            cls

        GridTemplateStyle template ->
            "grid-rows-"
                ++ String.join "-" (List.map lengthClassName template.rows)
                ++ "-cols-"
                ++ String.join "-" (List.map lengthClassName template.columns)
                ++ "-space-x-"
                ++ lengthClassName (Tuple.first template.spacing)
                ++ "-space-y-"
                ++ lengthClassName (Tuple.second template.spacing)

        GridPosition pos ->
            "gp grid-pos-"
                ++ String.fromInt pos.row
                ++ "-"
                ++ String.fromInt pos.col
                ++ "-"
                ++ String.fromInt pos.width
                ++ "-"
                ++ String.fromInt pos.height

        PseudoSelector selector subStyle ->
            let
                name =
                    case selector of
                        Focus ->
                            "fs"

                        Hover ->
                            "hv"

                        Active ->
                            "act"
            in
            List.map
                (\sty ->
                    case getStyleName sty of
                        "" ->
                            ""

                        styleName ->
                            styleName ++ "-" ++ name
                )
                subStyle
                |> String.join " "

        Transform x ->
            Maybe.withDefault "" (transformClass x)



{- Constants -}


asGrid : LayoutContext
asGrid =
    AsGrid


asRow : LayoutContext
asRow =
    AsRow


asColumn : LayoutContext
asColumn =
    AsColumn


asEl : LayoutContext
asEl =
    AsEl


asParagraph : LayoutContext
asParagraph =
    AsParagraph


asTextColumn : LayoutContext
asTextColumn =
    AsTextColumn



{- Mapping -}


map : (msg -> msg1) -> Element msg -> Element msg1
map fn el =
    case el of
        Styled styled ->
            Styled
                { styles = styled.styles
                , html = \add context -> VirtualDom.map fn <| styled.html add context
                }

        Unstyled html ->
            Unstyled (VirtualDom.map fn << html)

        Text str ->
            Text str

        Empty ->
            Empty


mapAttr : (msg -> msg1) -> Attribute aligned msg -> Attribute aligned msg1
mapAttr fn attr =
    case attr of
        NoAttribute ->
            NoAttribute

        Describe description ->
            Describe description

        AlignX x ->
            AlignX x

        AlignY y ->
            AlignY y

        Width x ->
            Width x

        Height x ->
            Height x

        Class x y ->
            Class x y

        StyleClass flag style ->
            StyleClass flag style

        Nearby location elem ->
            Nearby location (map fn elem)

        Attr htmlAttr ->
            Attr (VirtualDom.mapAttribute fn htmlAttr)

        TransformComponent fl trans ->
            TransformComponent fl trans


mapAttrFromStyle : (msg -> msg1) -> Attribute Never msg -> Attribute () msg1
mapAttrFromStyle fn attr =
    case attr of
        NoAttribute ->
            NoAttribute

        Describe description ->
            Describe description

        AlignX x ->
            AlignX x

        AlignY y ->
            AlignY y

        Width x ->
            Width x

        Height x ->
            Height x

        -- invalidation key "border-color" as opposed to "border-color-10-10-10" that will be the key for the class
        Class x y ->
            Class x y

        StyleClass flag style ->
            StyleClass flag style

        Nearby location elem ->
            Nearby location (map fn elem)

        Attr htmlAttr ->
            Attr (VirtualDom.mapAttribute fn htmlAttr)

        TransformComponent fl trans ->
            TransformComponent fl trans


unwrapDecorations : List (Attribute Never Never) -> List Style
unwrapDecorations attrs =
    case List.foldl unwrapDecsHelper ( [], Untransformed ) attrs of
        ( styles, transform ) ->
            Transform transform :: styles


unwrapDecsHelper attr ( styles, trans ) =
    case removeNever attr of
        StyleClass _ style ->
            ( style :: styles, trans )

        TransformComponent flag component ->
            ( styles, composeTransformation trans component )

        _ ->
            ( styles, trans )


removeNever : Attribute Never Never -> Attribute () msg
removeNever style =
    mapAttrFromStyle Basics.never style


tag : String -> Style -> Style
tag label style =
    case style of
        Single class prop val ->
            Single (label ++ "-" ++ class) prop val

        Colored class prop val ->
            Colored (label ++ "-" ++ class) prop val

        Style class props ->
            Style (label ++ "-" ++ class) props

        Transparency class o ->
            Transparency (label ++ "-" ++ class) o

        x ->
            x


onlyStyles : Attribute aligned msg -> Maybe Style
onlyStyles attr =
    case attr of
        StyleClass _ style ->
            Just style

        _ ->
            Nothing
