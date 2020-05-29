module ColumnLayouts exposing (main)

{-| -}

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font


main =
    layout [] <|
        column [ spacing 48 ]
            [ column
                [ width fill
                , height <| px 200
                , spacing 24
                , Border.width 1
                , Border.color pink
                ]
                [ elem
                , elem
                , elem
                ]
            , column
                [ width fill
                , spacing 24
                , Border.width 1
                , Border.color pink
                ]
                [ elem
                , elem
                , elem
                ]
            , el [ height <| px 400 ] <|
                column [ height fill ]
                    [ column
                        [ width fill
                        , height <| px 200
                        , spacing 24
                        , Border.width 1
                        , Border.color pink
                        ]
                        [ elem
                        , elem
                        , el [ alignBottom ] elem
                        ]
                    , el [ alignBottom ] elem
                    ]
            , column
                [ width fill
                , height <| px 200
                , spacing 24
                , Border.width 1
                , Border.color pink
                ]
                [ elem
                , el [] box
                , el [ alignBottom ] elem
                ]
            , column
                [ width fill
                , height <| px 200
                , spacing 24
                , Border.width 1
                , Border.color pink
                ]
                [ elem
                , el [] box
                , filled
                , el [ alignBottom ] elem
                ]
            ]


filled =
    el
        [ width fill
        , height fill
        , Background.color pink
        ]
        (text "an element")


elem =
    el
        [ Background.color pink
        ]
        (text "an element")


box =
    el
        [ width (px 50)
        , height (px 50)
        , Background.color (rgb (240 / 255) 0 (245 / 255))
        , Font.color (rgb 1 1 1)
        ]
        none


pink =
    rgb (240 / 255) 0 (245 / 255)
