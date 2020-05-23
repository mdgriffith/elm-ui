module WrapRow exposing (main)

import Browser
import Element exposing (..)


main =
    layout [] <|
        wrappedRow
            [ padding 10
            , spacingXY 6 5
            ]
            [ text "Higher by 1 px" ]
