module Main exposing (main)

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
            [ centerX
            , centerY
            , Background.color (rgba 0 0.8 0.9 1)
            , behindContent
                (el [ height (px 20), width (px 100), Background.color (rgba 0.9 0.8 0 1) ] none)
            ]
            (text "Hello stylish friend!")
