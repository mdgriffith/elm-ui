module Scroll exposing (main)

import Browser
import Element exposing (Element, alignTop, centerX, centerY, column, el, fill, fillPortion, height, inFront, layoutWith, none, padding, px, row, scrollbarY, spacing, text, width, wrappedRow)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input exposing (button)
import Html exposing (Html)
import Html.Attributes


type alias Model =
    ()


type alias Msg =
    ()


field i =
    text <| "Scrolling text " ++ String.fromInt i


view : Model -> Html Msg
view model =
    layoutWith { options = [] } [ height fill ] <|
        row
            [ height fill ]
            [ column
                [ height fill
                , scrollbarY

                -- The width fill is required, when using scrollbarY above
                -- else the width is set to 0.
                --, width fill
                ]
                (List.map field (List.range 1 100))
            , text "Non scrolling text"
            ]


main : Program () Model Msg
main =
    Browser.sandbox
        { init = ()
        , view = view
        , update = \msg model -> model
        }
