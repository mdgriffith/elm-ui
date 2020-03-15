module Main exposing (main)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border exposing (widthEach)
import Element.Font as Font


main =
    Element.layout
        [ height fill
        , width fill
        , padding 5
        ]
    <|
        row
            [ width fill ]
            [ newTabLink
                [ widthEach
                    { bottom = 0
                    , left = 2
                    , right = 0
                    , top = 0
                    }
                , paddingXY 3 0
                ]
                { url = "url.example.com"
                , label =
                    [ text "My news site super cool header" ]
                        |> paragraph []
                }
            ]
