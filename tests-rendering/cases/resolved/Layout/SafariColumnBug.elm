module SafariColumnBug exposing (main)

import Browser
import Element exposing (column, el, fill, height, layout, scrollbarY, text)
import Html exposing (Html)


main =
    layout [ height fill ] <|
        column
            [ height fill ]
            [ el [] <| text "Element that Safari gives height 0, if inside an el and not just text."
            , text "Text below the el above"
            ]
