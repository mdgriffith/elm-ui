module Main exposing (main, myElement, sidebar)

import Element exposing (Element, alignRight, centerY, column, el, fill, height, padding, px, rgb255, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font


main =
    Element.layout [ height fill ] <|
        row [ width fill, height fill ]
            [ sidebar
            ]


sidebar =
    column [ width fill, height fill, spacing 30 ]
        [ myElement
        , column [ width fill, height fill ]
            [ column [ width (px 350), height fill, Element.scrollbarY, Element.clip, Border.width 1 ]
                [ column [ width fill ] <|
                    el [] (text "this should scroll indepedendently")
                        :: List.map (always myElement) (List.range 0 100)
                ]
            , el [] (text "this should be at the bottom of the screen")
            ]
        ]


myElement : Element msg
myElement =
    el
        [ Background.color (rgb255 240 0 245)
        , Font.color (rgb255 255 255 255)
        , Border.rounded 3
        , padding 30
        , width fill
        ]
        (text "stylish!")
