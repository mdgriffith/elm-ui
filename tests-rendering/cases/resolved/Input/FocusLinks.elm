module FocusLinks exposing (main)

import Element exposing (Color, Element, el, focused, layout, link, row, spacing, text)
import Element.Border as Border
import Element.Region as Region
import Html exposing (Html)


main : Html msg
main =
    layout [] links


links : Element msg
links =
    row [ spacing 10 ]
        [ siteLink "Elm website" "https://elm-lang.org/"
        , siteLink "Elm-ui" "https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/Element"
        ]


siteLink : String -> String -> Element msg
siteLink label url =
    link [ focused [ Border.glow blue 2 ] ]
        { url = url
        , label = text label
        }


blue : Color
blue =
    Element.fromRgb255
        { red = 100
        , green = 180
        , blue = 250
        , alpha = 1
        }
