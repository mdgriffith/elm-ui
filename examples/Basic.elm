module Main exposing (..)

{-| -}

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input
import Element.Lazy


main =
    Element.layout
        [ Background.color (rgba 0 0 0 1)
        , Font.color (rgba 1 1 1 1)
        , Font.italic
        , Font.size 32
        , Font.family
            [ Font.external
                { url = "https://fonts.googleapis.com/css?family=EB+Garamond"
                , name = "EB Garamond"
                }
            , Font.sansSerif
            ]
        ]
    <|
        el
            [ centerX, centerY ]
            (text "Hello stylish friend!")
