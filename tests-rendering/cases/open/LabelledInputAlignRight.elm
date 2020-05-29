module LabelledInputAlignRight exposing (view)

import Testable.Element exposing (..)
import Testable.Element.Input as Input


view =
    layout [] <|
        column [ width fill ]
            [ Input.text
                [ width (px 200)
                , alignRight
                ]
                { onChange = always False
                , text = ""
                , placeholder = Nothing
                , label = Input.labelLeft [] (text "label")
                }
            , Input.text
                [ width (px 200)
                , alignRight
                ]
                { onChange = always False
                , text = ""
                , placeholder = Nothing
                , label = Input.labelHidden "label"
                }
            ]
