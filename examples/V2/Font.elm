module Font exposing (main)

import Element2 exposing (..)
import Element2.Background as Background
import Element2.Border as Border
import Element2.Font as Font
import Html


main : Html.Html msg
main =
    layout
        [ -- Font.familyWith
          --   { name = "EB Garamond"
          --   , fallback = [ Font.serif ]
          --   , sizing =
          --       Font.byCapital
          --           { capital = 1.09
          --           , lowercase = 0.81
          --           , baseline = 0.385
          --           , descender = 0.095
          --           -- , lineHeight = 1.5
          --           }
          --   , variants =
          --       []
          --   }
          Font.size 20
        ]
    <|
        row
            [ spacing 20
            , Border.width 1
            , width (px 500)
            , centerY
            , centerX
            , Border.rounded 3
            , Font.size 30
            ]
            [ el
                [ Background.color <| rgb 255 135 255
                , padding 20

                -- NOTE, setting family width needs to set font size in a overrideable way
                -- something like font-size: calc(1em * --font-adjustment-factor)
                , Font.familyWith
                    { name = "EB Garamond"
                    , fallback = [ Font.serif ]
                    , sizing =
                        Font.byCapital
                            { capital = 1.09
                            , lowercase = 0.81
                            , baseline = 0.385
                            , descender = 0.095
                            }
                    , variants =
                        []
                    }
                ]
              <|
                text "This is a test"
            , el
                [ Background.color <| rgb 255 135 255
                , padding 20
                ]
              <|
                text "This is a test, unadjusted"
            ]
