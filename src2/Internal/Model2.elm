module Internal.Model2 exposing (..)

{-| The goal here is:

1.  to be as thin of a wrapper as possible over `Html`
2.  Use css variables instead of propagating up an entire stylesheet.

-}

import Bitwise
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Html.Keyed
import Internal.Flag2 as Flag exposing (Flag)
import Internal.Style2 as Style
import Json.Decode as Json
import Json.Encode
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


mapAttr : (a -> b) -> Attribute a -> Attribute b
mapAttr fn attr =
    case attr of
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

        TranslateX x ->
            TranslateX x

        TranslateY y ->
            TranslateY y

        Rotate r ->
            Rotate r

        Scale s ->
            Scale s

        OnPress msg ->
            OnPress (fn msg)

        Spacing flag x y ->
            Spacing flag x y

        Padding flag edges ->
            Padding flag edges

        BorderWidth flag edges ->
            BorderWidth flag edges

        Attr a ->
            Attr (Attr.map fn a)

        Link target url ->
            Link target url

        Download url filename ->
            Download url filename

        NodeName name ->
            NodeName name

        -- invalidation key and literal class
        Class flag cls ->
            Class flag cls

        -- When using a css variable we want to attach the variable itself
        -- and a class that implements the rule.
        --               class  var       value
        ClassAndStyle flag cls var ->
            ClassAndStyle flag cls var

        Nearby loc el ->
            Nearby loc (map fn el)


type Layout
    = AsRow
    | AsWrappedRow
    | AsColumn
    | AsEl
    | AsGrid
    | AsParagraph
    | AsTextColumn
    | AsRoot


class : String -> Attribute msg
class cls =
    Attr (Attr.class cls)


type Attribute msg
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
                { top : Float
                , bottom : Float
                }
        , variants : String
        , smallCaps : Bool
        }
    | FontSize Int
    | NodeName String
    | Spacing Flag Int Int
    | Padding Flag Edges
    | BorderWidth Flag Edges
    | TranslateX Float
    | TranslateY Float
    | Rotate Float
    | Scale Float
      -- invalidation key and literal class
    | Class Flag String
      -- When using a css variable we want to attach the variable itself
      -- and a class that implements the rule.
      --               class  var       value
    | ClassAndStyle Flag String String
    | Nearby Location (Element msg)


hasFlag flag attr =
    case attr of
        Spacing f _ _ ->
            Flag.equal flag f

        Padding f _ ->
            Flag.equal flag f

        BorderWidth f _ ->
            Flag.equal flag f

        Class f _ ->
            Flag.equal flag f

        ClassAndStyle f _ _ ->
            Flag.equal flag f

        _ ->
            False


hasFlags flags attr =
    case attr of
        Spacing f _ _ ->
            List.any (Flag.equal f) flags

        Padding f _ ->
            List.any (Flag.equal f) flags

        BorderWidth f _ ->
            List.any (Flag.equal f) flags

        Class f _ ->
            List.any (Flag.equal f) flags

        ClassAndStyle f _ _ ->
            List.any (Flag.equal f) flags

        _ ->
            False


type Location
    = Above
    | Below
    | OnRight
    | OnLeft
    | InFront
    | Behind


type Option
    = FocusStyleOption FocusStyle
    | RenderModeOption RenderMode


type RenderMode
    = Layout
    | NoStaticStyleSheet
    | WithVirtualCss


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


element : Layout -> List (Attribute msg) -> List (Element msg) -> Element msg
element layout attrs children =
    render layout
        emptyDetails
        children
        Flag.none
        []
        (contextClasses layout)
        NoNearbyChildren
        (List.reverse attrs)


emptyEdges =
    { top = 0
    , left = 0
    , bottom = 0
    , right = 0
    }


emptyDetails : Details
emptyDetails =
    { name = "div"
    , node = 0
    , spacingX = 0
    , spacingY = 0
    , padding = emptyEdges
    , borders = emptyEdges
    , fontAdjustment = Nothing
    , x = 0
    , y = 0
    , rotate = 0
    , scale = 1
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
        (\space ->
            Html.span [ Attr.class textElementClasses ] [ Html.text str ]
        )


none : Element msg
none =
    Element (always (Html.text ""))


type alias Rendered msg =
    { name : String
    , htmlAttrs : List (VirtualDom.Attribute msg)
    , nearby : NearbyChildren msg
    , wrapped : List Wrapped
    }


type Wrapped
    = InLink String


wrappedRowAttributes attr =
    case attr of
        Spacing flag x y ->
            [ attr
            , Attr (Attr.style "margin-right" (Style.px (-1 * x)))
            , Attr (Attr.style "margin-bottom" (Style.px (-1 * y)))
            ]

        _ ->
            []


type alias Edges =
    { top : Int
    , right : Int
    , bottom : Int
    , left : Int
    }


type alias Details =
    -- Node reprsents html node like `div` or `a`.
    -- right now `0: div` and `1:
    { name : String
    , node : Int
    , spacingX : Int
    , spacingY : Int
    , padding : Edges
    , borders : Edges
    , fontAdjustment : Maybe { top : Float, bottom : Float }
    , x : Float
    , y : Float
    , rotate : Float
    , scale : Float
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


render :
    Layout
    -> Details
    -> List (Element msg)
    -> Flag.Field
    -> List (VirtualDom.Attribute msg)
    -> String
    -> NearbyChildren msg
    -> List (Attribute msg)
    -> Element msg
render layout details children has htmlAttrs classes nearby attrs =
    case attrs of
        [] ->
            Element
                (\parentEncoded ->
                    let
                        encoded =
                            if details.spacingX == 0 && details.spacingY == 0 then
                                0

                            else
                                Bitwise.or
                                    details.spacingX
                                    (Bitwise.shiftLeftBy 16 details.spacingY)

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
                                    ((Bitwise.complement 0
                                        |> Bitwise.shiftRightZfBy 16
                                        |> Bitwise.and parentEncoded
                                        |> String.fromInt
                                     )
                                        ++ "px "
                                        ++ String.fromInt (Bitwise.shiftRightZfBy 16 parentEncoded)
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
                                Attr.style "transform"
                                    ("rotate("
                                        ++ String.fromFloat details.rotate
                                        ++ "rad) translate("
                                        ++ String.fromFloat details.x
                                        ++ "px, "
                                        ++ String.fromFloat details.y
                                        ++ "px) scale("
                                        ++ String.fromFloat details.scale
                                        ++ ")"
                                    )
                                    :: attrsWithSpacing

                            else
                                attrsWithSpacing

                        attributes =
                            Attr.class classes
                                :: attrsWithTransform

                        finalChildren =
                            case layout of
                                AsParagraph ->
                                    spacerTop (toFloat details.spacingY / -2)
                                        :: renderedChildren
                                        ++ [ spacerBottom (toFloat details.spacingY / -2) ]

                                _ ->
                                    renderedChildren
                    in
                    if details.node == 0 then
                        -- calling this function directly is somehow faster
                        -- probably easier for the JIT to guess what's happening
                        Html.div
                            attributes
                            finalChildren

                    else if details.node == 1 then
                        Html.a
                            attributes
                            finalChildren

                    else if details.node == 2 then
                        Html.input
                            attributes
                            finalChildren

                    else
                        (case details.name of
                            -- Note: these functions are ever so slightly faster than `Html.node`
                            -- because they can skip elm's built in security check for `script`
                            "div" ->
                                Html.div

                            "input" ->
                                Html.input

                            "a" ->
                                Html.a

                            _ ->
                                Html.node details.name
                        )
                            attributes
                            finalChildren
                )

        NoAttribute :: remain ->
            render layout details children has htmlAttrs classes nearby remain

        (FontSize size) :: remain ->
            -- TODO:: apply font adjustment!!
            render
                layout
                details
                children
                has
                (Attr.style "font-size" (String.fromInt size ++ "px") :: htmlAttrs)
                classes
                nearby
                remain

        (Font font) :: remain ->
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
            render
                layout
                { name = details.name
                , node = details.node
                , spacingX = details.spacingX
                , spacingY = details.spacingY
                , fontAdjustment =
                    font.adjustments
                , padding = details.padding
                , borders = details.borders
                , x = details.x
                , y = details.y
                , rotate = details.rotate
                , scale = details.scale
                }
                children
                has
                (Attr.style "font-family" font.family
                    :: withFeatures
                )
                classes
                nearby
                remain

        (TranslateX x) :: remain ->
            render
                layout
                { details | x = x }
                children
                (Flag.add Flag.transform has)
                htmlAttrs
                classes
                nearby
                remain

        (TranslateY y) :: remain ->
            render
                layout
                { details | y = y }
                children
                (Flag.add Flag.transform has)
                htmlAttrs
                classes
                nearby
                remain

        (Rotate rad) :: remain ->
            render
                layout
                { details | rotate = rad }
                children
                (Flag.add Flag.transform has)
                htmlAttrs
                classes
                nearby
                remain

        (Scale scale) :: remain ->
            render
                layout
                { details | scale = scale }
                children
                (Flag.add Flag.transform has)
                htmlAttrs
                classes
                nearby
                remain

        (Attr attr) :: remain ->
            render
                layout
                details
                children
                has
                (attr :: htmlAttrs)
                classes
                nearby
                remain

        (OnPress press) :: remain ->
            -- Make focusable
            -- Attach keyboard handler
            -- Attach click handler
            render layout
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
                remain

        (Link targetBlank url) :: remain ->
            render
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
                remain

        (Download url downloadName) :: remain ->
            render
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
                remain

        (NodeName nodeName) :: remain ->
            render
                layout
                { details | name = nodeName, node = 4 }
                children
                has
                htmlAttrs
                classes
                nearby
                remain

        (Class flag str) :: remain ->
            if Flag.present flag has then
                render
                    layout
                    details
                    children
                    has
                    htmlAttrs
                    classes
                    nearby
                    remain

            else
                render
                    layout
                    details
                    children
                    (Flag.add flag has)
                    htmlAttrs
                    (str ++ " " ++ classes)
                    nearby
                    remain

        (ClassAndStyle flag cls sty) :: remain ->
            if Flag.present flag has then
                render
                    layout
                    details
                    children
                    has
                    htmlAttrs
                    classes
                    nearby
                    remain

            else
                render layout
                    details
                    children
                    (Flag.add flag has)
                    htmlAttrs
                    (cls ++ " " ++ classes)
                    nearby
                    remain

        (Nearby location elem) :: remain ->
            render
                layout
                details
                children
                has
                htmlAttrs
                classes
                (addNearbyElement location elem nearby)
                remain

        (Spacing flag x y) :: remain ->
            if Flag.present flag has || layout == AsEl then
                render
                    layout
                    details
                    children
                    has
                    htmlAttrs
                    classes
                    nearby
                    remain

            else
                render
                    layout
                    { details | spacingX = x, spacingY = y }
                    children
                    (Flag.add flag has)
                    htmlAttrs
                    (Style.classes.spacing ++ " " ++ classes)
                    nearby
                    remain

        (Padding flag padding) :: remain ->
            if Flag.present flag has then
                render
                    layout
                    details
                    children
                    has
                    htmlAttrs
                    classes
                    nearby
                    remain

            else
                render
                    layout
                    { name = details.name
                    , node = details.node
                    , spacingX = details.spacingX
                    , spacingY = details.spacingY
                    , fontAdjustment = details.fontAdjustment
                    , padding = padding
                    , borders = details.borders
                    , x = details.x
                    , y = details.y
                    , rotate = details.rotate
                    , scale = details.scale
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
                    remain

        (BorderWidth flag borders) :: remain ->
            if Flag.present flag has then
                render
                    layout
                    details
                    children
                    has
                    htmlAttrs
                    classes
                    nearby
                    remain

            else
                render
                    layout
                    { name = details.name
                    , node = details.node
                    , spacingX = details.spacingX
                    , spacingY = details.spacingY
                    , fontAdjustment = details.fontAdjustment
                    , padding = details.padding
                    , borders = borders
                    , x = details.x
                    , y = details.y
                    , rotate = details.rotate
                    , scale = details.scale
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
                    remain

        (HeightFill i) :: remain ->
            render
                layout
                details
                children
                has
                htmlAttrs
                classes
                nearby
                remain

        (WidthFill i) :: remain ->
            render
                layout
                details
                children
                has
                htmlAttrs
                classes
                nearby
                remain


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
