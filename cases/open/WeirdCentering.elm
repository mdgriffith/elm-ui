module Main exposing (main)

import Browser
import Element
import Element.Background as Background
import Element.Input as Input
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)


main : Html msg
main =
    Element.layout [] <|
        Element.column []
            [ Element.text "Example with centerX:"
            , Element.row
                [ Element.width Element.fill ]
                [ Element.row [ Element.centerX, Background.color <| Element.rgb255 0 200 0 ]
                    [ Element.paragraph [ Element.width Element.shrink ] [ Element.text "Hello world" ]
                    , Element.paragraph [ Element.width Element.shrink ] [ Element.text "Hello world" ]
                    ]
                ]
            , Element.text "Example without centerX:"
            , Element.row
                [ Element.width Element.fill ]
                [ Element.row [ Background.color <| Element.rgb255 0 200 0 ]
                    [ Element.paragraph [ Element.width Element.shrink ] [ Element.text "Hello world" ]
                    , Element.paragraph [ Element.width Element.shrink ] [ Element.text "Hello world" ]
                    ]
                ]
            ]
