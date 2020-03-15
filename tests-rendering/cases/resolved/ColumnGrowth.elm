module Main exposing (main)

import Browser
import Element exposing (column, fill, fillPortion, height, minimum, paddingXY, px, rgb, row, shrink, spacing, width)
import Element.Background as Back
import Element.Border as Border
import Html exposing (Html)


main : Html m
main =
    let
        box =
            row
                [ Border.solid
                , Border.width 2
                , Back.color (rgb 1 1 1)
                , width (px 80)
                , height (fillPortion 1)
                ]
                []

        grower =
            column
                [ width fill

                -- fillPortion is not being applied here unless we set it to 1.
                -- It will also resume working if we delete the minimum bound.
                , height
                    (fillPortion 2
                        |> minimum 20
                    )
                ]
                []
    in
    Element.layout
        [ Back.color (rgb 0.9 1 0.8)
        , paddingXY 20 20
        ]
        (column [ height fill ] [ box, grower, box ])
