module BreaksWithinParagraph exposing (main)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font


main =
    layout [ width fill, height fill ] <|
        paragraph [ Border.width 1, width (px 50) ]
            [ row []
                [ text "Thequick"
                ]
            , text "redfox"
            ]
