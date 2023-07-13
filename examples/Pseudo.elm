module Pseudo exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font


main =
    Element.layout
        [ Background.color (rgba 0 0 0 1)
        , Font.color (rgba 1 1 1 1)
        , Font.italic
        , Font.size 32
        , Font.family
            [ Font.sansSerif ]
        ]
    <|
        column [ centerX, centerY ]
            [ el
                [ mouseOver [ Background.color <| rgb255 255 0 0 ]
                , mouseDown [ Background.color <| rgb255 0 0 255 ]
                ]
              <|
                text "The following priority of pseudo classes is fixed"
            , el
                [ mouseDown [ Background.color <| rgb255 0 0 255 ]
                , mouseOver [ Background.color <| rgb255 255 0 0 ]
                ]
              <|
                text "hover < focused < active"
            ]
