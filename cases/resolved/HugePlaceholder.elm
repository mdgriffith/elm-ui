module Main exposing (main)

import Browser
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Input as Input
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)


main =
    Element.layout [] sscce


sscce =
    Input.text
        [ Border.width 1
        , Element.width <| Element.px 50
        ]
        { onChange = always ()
        , text = ""
        , placeholder = Just <| Input.placeholder [] <| Element.text "this is a very long place holder ......................"
        , label = Input.labelHidden ""
        }
