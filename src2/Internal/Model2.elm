module Internal.Model2 exposing (..)

{-| The goal here is:

1.  to be as thin of a wrapper as possible over `Html`
2.  Use css variables instead of propagating up an entire stylesheet.

-}

import Html
import Html.Attributes as Attr
import Html.Keyed
import Internal.Flag as Flag exposing (Flag)
import Internal.StyleGenerator as Style
import Json.Encode
import VirtualDom


type Element msg
    = Element (Html.Html msg)
    | Text String


map : (a -> b) -> Element a -> Element b
map fn el =
    case el of
        Text str ->
            Text str

        Element elem ->
            Element (Html.map fn elem)


mapAttr : (a -> b) -> Attribute a -> Attribute b
mapAttr fn attr =
    case attr of
        NoAttribute ->
            NoAttribute

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

        -- add to the style property
        Style flag style ->
            Style flag style

        -- When using a css variable we want to attach the variable itself
        -- and a class that implements the rule.
        --               class  var       value
        ClassAndStyle flag cls var ->
            ClassAndStyle flag cls var

        Nearby loc el ->
            Nearby loc (map fn el)


type Layout
    = AsRow
    | AsColumn
    | AsEl
    | AsGrid
    | AsParagraph
    | AsTextColumn
    | AsRoot


class cls =
    Attr (Attr.class cls)


type Attribute msg
    = NoAttribute
    | Attr (Html.Attribute msg)
    | Link Bool String
    | Download String String
    | NodeName String
      -- invalidation key and literal class
    | Class Flag String
      -- add to the style property
    | Style Flag String
      -- When using a css variable we want to attach the variable itself
      -- and a class that implements the rule.
      --               class  var       value
    | ClassAndStyle Flag String String
    | Nearby Location (Element msg)


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


element : Layout -> List (Attribute msg) -> List (Element msg) -> Element msg
element layout attrs children =
    render layout
        children
        "div"
        Flag.none
        ""
        []
        (contextClasses layout)
        NoNearbyChildren
        (List.reverse attrs)


elementKeyed : Layout -> List (Attribute msg) -> List ( String, Element msg ) -> Element msg
elementKeyed layout attrs children =
    renderKeyed layout
        children
        "div"
        Flag.none
        ""
        []
        (contextClasses layout)
        NoNearbyChildren
        (List.reverse attrs)


unwrap : Element msg -> Html.Html msg
unwrap el =
    case el of
        Text str ->
            Html.span [ Attr.class textElementClasses ] [ Html.text str ]

        Element html ->
            html


wrapText el =
    case el of
        Text str ->
            Html.text str

        Element html ->
            html


text =
    Text



-- text : String -> Element msg
-- text str =
--     Element (Html.span [ Attr.class textElementClasses ] [ Html.text str ])


none : Element msg
none =
    Element (Html.text "")


type alias Rendered msg =
    { name : String
    , htmlAttrs : List (VirtualDom.Attribute msg)
    , nearby : NearbyChildren msg
    , wrapped : List Wrapped
    }


type Wrapped
    = InLink String


render :
    Layout
    -> List (Element msg)
    -> String
    -> Flag.Field
    -> String
    -> List (VirtualDom.Attribute msg)
    -> String
    -> NearbyChildren msg
    -> List (Attribute msg)
    -> Element msg
render layout children name has styles htmlAttrs classes nearby attrs =
    case attrs of
        [] ->
            let
                renderedChildren =
                    case nearby of
                        NoNearbyChildren ->
                            List.map unwrap children

                        ChildrenBehind behind ->
                            behind ++ List.map unwrap children

                        ChildrenInFront inFront ->
                            List.map unwrap children ++ inFront

                        ChildrenBehindAndInFront behind inFront ->
                            behind ++ List.map unwrap children ++ inFront
            in
            Element
                (Html.node
                    name
                    (Attr.class classes
                        :: Attr.property "style" (Json.Encode.string styles)
                        :: htmlAttrs
                    )
                    renderedChildren
                )

        NoAttribute :: remain ->
            render layout children name has styles htmlAttrs classes nearby remain

        (Attr attr) :: remain ->
            render layout children name has styles (attr :: htmlAttrs) classes nearby remain

        (Link targetBlank url) :: remain ->
            render layout
                children
                "a"
                has
                styles
                (Attr.href url
                    :: Attr.rel "noopener noreferrer"
                    :: (if targetBlank then
                            Attr.target "_blank"

                        else
                            Attr.target "_self"
                       )
                    :: htmlAttrs
                )
                classes
                nearby
                remain

        (Download url downloadName) :: remain ->
            render layout
                children
                "a"
                has
                styles
                (Attr.href url
                    :: Attr.download downloadName
                    :: htmlAttrs
                )
                classes
                nearby
                remain

        (NodeName nodeName) :: remain ->
            render layout children nodeName has styles htmlAttrs classes nearby remain

        (Class flag str) :: remain ->
            if Flag.present flag has then
                render layout children name has styles htmlAttrs classes nearby remain

            else
                render layout children name (Flag.add flag has) styles htmlAttrs (str ++ " " ++ classes) nearby remain

        (Style flag str) :: remain ->
            if Flag.present flag has then
                render layout children name has styles htmlAttrs classes nearby remain

            else
                render layout children name (Flag.add flag has) (str ++ styles) htmlAttrs classes nearby remain

        (ClassAndStyle flag cls sty) :: remain ->
            if Flag.present flag has then
                render layout children name has styles htmlAttrs classes nearby remain

            else
                render layout
                    children
                    name
                    (Flag.add flag has)
                    (sty ++ styles)
                    htmlAttrs
                    (cls ++ " " ++ classes)
                    nearby
                    remain

        (Nearby location elem) :: remain ->
            render
                layout
                children
                name
                has
                styles
                htmlAttrs
                classes
                (addNearbyElement location elem nearby)
                remain


renderKeyed :
    Layout
    -> List ( String, Element msg )
    -> String
    -> Flag.Field
    -> String
    -> List (VirtualDom.Attribute msg)
    -> String
    -> NearbyChildren msg
    -> List (Attribute msg)
    -> Element msg
renderKeyed layout children name has styles htmlAttrs classes nearby attrs =
    case attrs of
        [] ->
            let
                renderedChildren =
                    case nearby of
                        NoNearbyChildren ->
                            List.map (Tuple.mapSecond unwrap) children

                        ChildrenBehind behind ->
                            List.map (Tuple.pair "keyed") behind ++ List.map (Tuple.mapSecond unwrap) children

                        ChildrenInFront inFront ->
                            List.map (Tuple.mapSecond unwrap) children ++ List.map (Tuple.pair "keyed") inFront

                        ChildrenBehindAndInFront behind inFront ->
                            List.map (Tuple.pair "keyed") behind ++ List.map (Tuple.mapSecond unwrap) children ++ List.map (Tuple.pair "keyed") inFront
            in
            Element
                (Html.Keyed.node
                    name
                    (Attr.class classes
                        :: Attr.property "style" (Json.Encode.string styles)
                        :: htmlAttrs
                    )
                    renderedChildren
                )

        NoAttribute :: remain ->
            renderKeyed layout children name has styles htmlAttrs classes nearby remain

        (Attr attr) :: remain ->
            renderKeyed layout children name has styles (attr :: htmlAttrs) classes nearby remain

        (Link targetBlank url) :: remain ->
            renderKeyed layout
                children
                "a"
                has
                styles
                (Attr.href url
                    :: Attr.rel "noopener noreferrer"
                    :: (if targetBlank then
                            Attr.target "_blank"

                        else
                            Attr.target "_self"
                       )
                    :: htmlAttrs
                )
                classes
                nearby
                remain

        (Download url downloadName) :: remain ->
            renderKeyed layout
                children
                "a"
                has
                styles
                (Attr.href url
                    :: Attr.download downloadName
                    :: htmlAttrs
                )
                classes
                nearby
                remain

        (NodeName nodeName) :: remain ->
            renderKeyed layout children nodeName has styles htmlAttrs classes nearby remain

        (Class flag str) :: remain ->
            if Flag.present flag has then
                renderKeyed layout children name has styles htmlAttrs classes nearby remain

            else
                renderKeyed layout children name (Flag.add flag has) styles htmlAttrs (str ++ " " ++ classes) nearby remain

        (Style flag str) :: remain ->
            if Flag.present flag has then
                renderKeyed layout children name has styles htmlAttrs classes nearby remain

            else
                renderKeyed layout children name (Flag.add flag has) (str ++ styles) htmlAttrs classes nearby remain

        (ClassAndStyle flag cls sty) :: remain ->
            if Flag.present flag has then
                renderKeyed layout children name has styles htmlAttrs classes nearby remain

            else
                renderKeyed layout
                    children
                    name
                    (Flag.add flag has)
                    (sty ++ styles)
                    htmlAttrs
                    (cls ++ " " ++ classes)
                    nearby
                    remain

        (Nearby location elem) :: remain ->
            renderKeyed
                layout
                children
                name
                has
                styles
                htmlAttrs
                classes
                (addNearbyElement location elem nearby)
                remain


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
        [ unwrap elem
        ]


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
    String.join " "
        [ Style.classes.root
        , Style.classes.any
        , Style.classes.single
        ]


rowClass =
    Style.classes.any ++ " " ++ Style.classes.row


columnClass =
    Style.classes.any ++ " " ++ Style.classes.column


singleClass =
    Style.classes.any ++ " " ++ Style.classes.single


gridClass =
    Style.classes.any ++ " " ++ Style.classes.grid


paragraphClass =
    Style.classes.any ++ " " ++ Style.classes.paragraph


pageClass =
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
            pageClass
