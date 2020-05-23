module LabelAlignBaseline exposing (..)

import Element exposing (Element, alignRight, centerY, el, fill, padding, rgb255, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input


type Msg
    = Msg


main =
    Element.layout [] <|
        Element.column []
            [ Element.row []
                [ Element.text "dissociated label"
                , Input.text []
                    { text = "input"
                    , label = Input.labelHidden "hidden"
                    , onChange = \_ -> Msg
                    , placeholder = Nothing
                    }
                ]
            , Element.row []
                [ Input.text []
                    { text = "input"
                    , label = Input.labelLeft [] <| Element.text "associated label"
                    , onChange = \_ -> Msg
                    , placeholder = Nothing
                    }
                ]
            ]
