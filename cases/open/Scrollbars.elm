module Main exposing (main)

import Element exposing (..)
import Element.Background as Background
import Html.Attributes
import Lorem as Lorem


main =
    layout [ height fill ] <|
        column
            [ width fill
            , Background.color (rgba 0.8 0 0 0.5)
            , height fill
            ]
            [ row
                [ padding 15
                , width fill
                , Background.color (rgba 0.8 0.2 0 0.5)
                ]
                [ text "this row should always be visible" ]
            , row
                [ width fill

                --, height (px 700)
                -- Don't know why it doesn't work with `height fill`
                , height fill
                , clip

                --, htmlAttribute (Html.Attributes.style "flex-shrink" "1")
                , Element.explain Debug.todo
                ]
                [ column
                    [ spacing 15
                    , scrollbarY
                    , height fill
                    , width fill
                    , padding 10
                    ]
                    (List.map (\p -> paragraph [] [ text p ]) <| Lorem.paragraphs 10)
                , column
                    [ spacing 15
                    , scrollbarY
                    , width fill
                    , height fill
                    , padding 10
                    ]
                    (List.map (\p -> paragraph [] [ text p ]) <| Lorem.paragraphs 10)
                ]
            ]
