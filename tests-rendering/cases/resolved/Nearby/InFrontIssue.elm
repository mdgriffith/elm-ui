module Nearby.InFrontIssue exposing (view)

import Browser
import Element as Ui exposing (..)
import Element.Background as Background
import Element.Font as Font
import Html exposing (Html)


view : Html Msg
view =
    let
        a =
            el
                [ width fill
                , height <| px 30
                , Background.color <| rgb 0 1 0
                ]
            <|
                text "A"

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
                [ width <| px 100
                , height <| px 100
                , Background.color <| rgb 0 0 0
                , Font.color <| rgb 1 1 1
                , paddingXY 0 30
                , centerX
                , above d
                , below d
                , onLeft d
                , onRight d
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
            <|
                text "D"
    in
    layout
        [ inFront a
        , paddingXY 0 30
        ]
        b
