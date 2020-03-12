module Tests.Transparency exposing (..)

import Html
import Testable
import Testable.Element exposing (..)
import Testable.Element.Background as Background
import Testable.Element.Font as Font
import Testable.Runner
import Tests.Palette as Palette exposing (..)


box attrs =
    el
        ([ width (px 50)
         , height (px 50)
         , Background.color blue
         ]
            ++ attrs
        )
        none


{-| -}
main : Html.Html msg
main =
    Testable.Runner.show view


view =
    column [ paddingXY 0 100, spacing 16 ]
        [ text "transparency"
        , row [ spacing 16 ]
            [ box [ transparent True ]
            , box [ transparent False ]
            ]
        , text "transparency with hover"
        , row [ spacing 16 ]
            [ box
                [ transparent True

                -- , mouseOver [ Background.color green ]
                ]
            , box
                [ transparent False

                -- , mouseOver [ Background.color green ]
                ]
            ]
        , text "all opacities"
        , row [ spacing 16 ]
            [ box [ alpha 0 ]
            , box [ alpha 0.25 ]
            , box [ alpha 0.5 ]
            , box [ alpha 0.75 ]
            , box [ alpha 1.0 ]
            ]
        ]
