module Main exposing (main)

import Element exposing (..)
import Element.Background as Bg
import Element.Font as Font
import Element.Input as Input


large =
    """Hi
Hello
                        -->

    World!"""


empty =
    ""


singleLine =
    "Hello   World!  ->"


placeholder =
    "placeholder"


main =
    Element.layout [ width fill, height fill, Font.color (rgb 1 0 0) ] <|
        column [ width fill, height fill ]
            [ Input.multiline
                [ centerX
                , spacing 20

                -- , height (px 100)
                , width shrink
                ]
                { onChange = always ()
                , text = empty
                , placeholder = Just (Input.placeholder [] (text "hello"))
                , label = Input.labelAbove [] none
                , spellcheck = False
                }
            , el
                [ width <| px 500
                , height <| px 20
                , Bg.color <| rgb255 0 0 0
                , centerX
                ]
                none
            , Input.text
                [ centerX
                , spacing 5

                -- , height (px 100)
                -- , width shrink
                -- , height shrink
                , width (px 200)
                ]
                { onChange = always ()
                , text = empty
                , placeholder = Just (Input.placeholder [] (text placeholder))
                , label = Input.labelAbove [] (text "labeled")
                }
            , Input.text
                [ centerX
                , spacing 5

                -- , height (px 100)
                -- , width shrink
                -- , height shrink
                , width (px 200)
                ]
                { onChange = always ()
                , text = "Filled Content"
                , placeholder = Just (Input.placeholder [] (text placeholder))
                , label = Input.labelBelow [] (text "labeled")
                }
            ]
