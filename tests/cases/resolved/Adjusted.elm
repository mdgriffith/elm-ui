module Main exposing (main)

{-| -}

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Html.Attributes


myFont =
    Font.with
        { url = Just "https://fonts.googleapis.com/css?family=Catamaran"
        , name = "Catamaran"
        , adjustment =
            { capital = 1.15
            , lowercase = 0.96
            , baseline = 0.465
            , descender = 0.245
            }
        }


main =
    Element.layout
        [ Background.color (rgba 0 0.8 0.9 1)
        , Font.color (rgba 1 1 1 1)
        , Font.size 32
        , Font.family [ myFont ]

        -- , Font.family
        --     [ Font.external
        --         { url = "https://fonts.googleapis.com/css?family=EB+Garamond"
        --         , name = "EB Garamond"
        --         }
        -- , Font.sansSerif
        -- ]
        ]
    <|
        column [ centerX, centerY, spacing 20, padding 100, htmlAttribute (Html.Attributes.style "display" "block") ]
            [ el
                []
                (text "Hello stylish friend!")
            , el
                [ Font.family
                    [ Font.external
                        { url = "https://fonts.googleapis.com/css?family=EB+Garamond"
                        , name = "EB Garamond"
                        }
                    ]
                ]
              <|
                el
                    [ Font.sizeByCapital
                    , Background.color (rgba 1 1 1 1)
                    , Font.color (rgba 0 0 0 1)
                    ]
                    (text "Hello stylish friend!")
            , el
                [ Font.sizeByCapital
                , Background.color (rgba 1 1 1 1)
                , Font.color (rgba 0 0 0 1)
                ]
                (text "Hello stylish friend!")
            , el
                [ Background.color (rgba 1 1 1 1)
                , Font.color (rgba 0 0 0 1)
                ]
                (text "Hello stylish friend!")
            ]
