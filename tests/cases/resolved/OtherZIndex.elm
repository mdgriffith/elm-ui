module Main exposing (main)

import Browser
import Html exposing (Html)
import Element as Ui exposing (..)
import Element.Background as Background
import Element.Font as Font


type alias Model =
    {}


initialModel : Model
initialModel =
    {}


type Msg
    = NoOp


update : Msg -> Model -> Model
update msg model =
    model


view : Model -> Html Msg
view model =
    let
        a =
            el
                [ width fill
                , height <| px 30
                , Background.color <| rgb 0 1 0
                ]
            <| text "A"
            
        b =
            column
                [ width fill
                , height <| px 5000
                , Background.color <| rgb 1 0 1
                , spacing 60
                ]
                [ text "B"
                , c
                ]
                
        c =
            el
                [ width fill
                , height <| px 100
                , Background.color <| rgb 0 0 0
                , Font.color <| rgb 1 1 1
                , paddingXY 0 30
                , inFront d
                ]
              <|
                text "C"
                
        d =
            el
                [ width <| px 100
                , height <| px 100
                , centerX
                , Background.color <| rgb 1 1 1
                , Font.color <| rgb 0 0 0
                ]
              <| text "D"
    in
        layout
            [ inFront a
            , paddingXY 0 30
            ]
            b


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
