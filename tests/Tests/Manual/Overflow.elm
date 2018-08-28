module Main exposing (main)

import Tests.Palette as Palette
import Element exposing (..)
import Element.Background as Bg
import Html exposing (Html)


main : Html msg
main =
    layout [ height Element.shrink ] <|
        row [ height fill ]
            [ Element.el [ scrollbarY, width fill, height fill ] <| column [ height <| px 1000, Bg.color Color.red ] []
            , Element.el [ scrollbarY, width fill, height fill ] <| column [ height <| px 1500, Bg.color Color.green ] []
            , Element.el [ scrollbarY, width fill, height fill ] <| column [ height <| px 2000, Bg.color Color.blue ] []
            ]
