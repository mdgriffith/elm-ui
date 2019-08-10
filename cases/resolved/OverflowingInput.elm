module Main exposing (main)

import Browser
import Element exposing (..)
import Element.Input as Input
import Html exposing (Html)


type alias Model =
    {}


type Msg
    = OnInput String


update : Msg -> Model -> Model
update msg model =
    model


view : Model -> Html Msg
view model =
    layout [] <|
        row
            [ width (px 200)
            , padding 8
            , spacing 16
            ]
            [ Input.text
                [ padding 4
                , width fill
                ]
                { onChange = OnInput
                , text = "text"
                , placeholder = Nothing
                , label = Input.labelHidden "label"
                }
            ]


main : Program () Model Msg
main =
    Browser.sandbox
        { init = {}
        , view = view
        , update = update
        }
