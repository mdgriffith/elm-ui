module Nearby.ZIndexRegression exposing (main)

import Element exposing (..)
import Element.Background as Background
import Html exposing (Html)


main : Html msg
main =
    layout [] <|
        column [ width fill, height fill ]
            [ el
                [ width fill
                , height (px 100)
                , Background.color (rgb 0 0 1)
                , inFront menu
                ]
                none
            , el
                [ width fill
                , height fill
                , inFront menu
                ]
                none
            ]


menu : Element msg
menu =
    el
        [ transparent True
        , mouseOver [ transparent False ]
        , width fill
        , height fill
        , below <|
            el
                [ width fill
                , height (px 500)
                , Background.color (rgb 1 0 0)
                ]
                none
        ]
        none
