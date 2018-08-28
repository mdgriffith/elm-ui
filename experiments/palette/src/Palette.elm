module Palette exposing (..)

{-| With palettes, we want the dev to be able to

  - specify some colors
  - those colors then need to be rendered by the layout
  - those colors can then be referred to by name in the layout
      - A lookup is done to retrieve the classname

-}

import Element exposing (Color)
import Html exposing (Html)
import Html.Attributes
import Internal.Model as Internal


{- Declare a Palette of Colors (or any value, but colors for not) -}
{- -}


layout : Colors colors -> List (Attribute colors msg) -> Element colors msg -> Html msg
layout colorPalette attrs child =
    -- Render a "stylesheet"
    let
        ( html, dynamicStyles ) =
            renderPaletteElement colorPalette (Element attrs [ child ])
    in
    Html.div [ Html.Attributes.class "root" ]
        [ Html.text "static stylesheet"
        , Html.div
            [ Html.Attributes.style "padding" "20px"
            , Html.Attributes.style "whitespace" "pre"
            , Html.Attributes.style "border-radius" "4px"
            , Html.Attributes.style "background-color" "#CCDDCC"
            , Html.Attributes.style "font-family" "Open Sans"
            ]
            [ Html.text (String.join "\n" (renderColorPalette colorPalette)) ]
        , Html.node "style"
            []
            [ Html.text ("html,body,.root {width: 100%; height: 100%;}.ui {min-width:100px; min-height: 100px;}" ++ String.join "\n" (renderColorPalette colorPalette))
            ]
        , Html.text "dynamic stylesheet"
        , Html.div
            [ Html.Attributes.style "padding" "20px"
            , Html.Attributes.style "whitespace" "pre"
            , Html.Attributes.style "border-radius" "4px"
            , Html.Attributes.style "background-color" "#FFDDCC"
            , Html.Attributes.style "font-family" "Open Sans"
            ]
            [ Html.text (String.join "\n" dynamicStyles) ]
        , Html.node "style" [] [ Html.text (String.join "\n" dynamicStyles) ]
        , Html.text "content:"
        , html
        ]


renderColor clr =
    Internal.formatColor clr


colorRule clr =
    ".bg-clr-"
        ++ Internal.formatColorClass clr
        ++ "{ background-color:"
        ++ Internal.formatColor clr
        ++ " }"


renderColorPalette : Colors colors -> List String
renderColorPalette (Colors palette) =
    List.map
        colorRule
        palette.values


renderPaletteElement : Colors colors -> InternalElement (colors -> Protected Color) msg -> ( Html msg, List String )
renderPaletteElement colorPalette (Element attrs children) =
    let
        gatherAttr attr ( attributes, myAttrStyles ) =
            let
                ( cls, style ) =
                    renderPaletteAttribute colorPalette attr
            in
            ( cls ++ " " ++ attributes, style :: myAttrStyles )

        ( classes, attrStyles ) =
            List.foldl gatherAttr ( "", [] ) attrs

        ( renderedChildren, styles ) =
            List.foldr gather ( [], attrStyles ) children

        gather child ( rendered, existingStyles ) =
            let
                ( childHtml, childStyles ) =
                    renderPaletteElement colorPalette child
            in
            ( childHtml :: rendered, childStyles ++ existingStyles )
    in
    ( Html.div [ Html.Attributes.class ("ui " ++ classes) ]
        renderedChildren
    , styles
    )


renderPaletteAttribute : Colors colors -> InternalAttribute (colors -> Protected Color) msg -> ( String, String )
renderPaletteAttribute (Colors palette) attribute =
    case attribute of
        InternalAttribute ->
            ( "ui", "" )

        ColorStyle colorLookup ->
            case colorLookup palette.protected of
                Dynamic clr ->
                    ( "bg-clr-" ++ Internal.formatColorClass clr, colorRule clr )

                Protected clr ->
                    ( "bg-clr-" ++ Internal.formatColorClass clr, "" )


renderAttribute : Colors color -> InternalAttribute Color msg -> String
renderAttribute (Colors palette) attribute =
    case attribute of
        InternalAttribute ->
            ""

        ColorStyle clr ->
            "dynamic clr"


bgColor : color -> InternalAttribute color msg
bgColor clr =
    ColorStyle clr


{-| Concrete Values
-}
type alias Attr msg =
    InternalAttribute Color msg


{-| Palette based attributes
-}
type alias Attribute colors msg =
    InternalAttribute (colors -> Protected Color) msg


type alias Element colors msg =
    InternalElement (colors -> Protected Color) msg


type alias El msg =
    InternalElement Color msg


type InternalAttribute color msg
    = InternalAttribute
    | ColorStyle color


type InternalElement color msg
    = Element (List (InternalAttribute color msg)) (List (InternalElement color msg))


{-| This is how we keep track of something that's already rendered, (Protected), or needs to be rendered
-}
type Protected thing
    = Protected thing
    | Dynamic thing



-- dynamic : Color -> Colors colors -> Protected Color


dynamic value palette =
    Dynamic value



{- COLORS -}


type Colors a
    = Colors
        { protected : a
        , values : List Color
        }


colors : a -> Colors a
colors a =
    Colors
        { protected = a
        , values = []
        }


color : Color -> Colors (Protected Color -> a) -> Colors a
color clr pal =
    let
        addColor p =
            { protected = p.protected (Protected clr)
            , values = clr :: p.values
            }
    in
    map addColor pal


map : ({ protected : a, values : List Color } -> { protected : a1, values : List Color }) -> Colors a -> Colors a1
map fn pal =
    case pal of
        Colors a ->
            Colors (fn a)
