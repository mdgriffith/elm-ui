module Basic2 exposing (..)

{-| -}

import Element2 exposing (..)
import Element2.Background as Background
import Element2.Border as Border
import Element2.Events as Events
import Element2.Font as Font
import Element2.Keyed
import Element2.Lazy
import Element2.Region



-- import Element2.Input
-- import Element2.Lazy


main =
    layout
        [ Background.color (rgb 0 0 0)
        , Font.color (rgb 255 255 255)
        , Font.italic
        , Font.size 32
        , Border.width 2
        , Border.color (rgb 50 100 0)

        -- , Font.family
        --     [ Font.typeface "EB Garamond"
        --     , Font.sansSerif
        --     ]
        , Font.familyWith
            { name = "EB Garamond"
            , fallback = [ Font.serif ]
            , sizing =
                Font.byCapital
                    { capital = 1.09
                    , lowercase = 0.81
                    , baseline = 0.385
                    , descender = 0.095

                    -- , lineHeight = 1.5
                    }
            , variants =
                []
            }
        ]
        (column [ centerX, centerY, spacing 32 ]
            [ el
                [ behindContent
                    (el
                        [ height (px 32)
                        , width fill
                        , moveLeft 30
                        , Background.color (rgb 60 60 60)
                        ]
                        none
                    )
                ]
                (text "Hello stylish friend!")
            , paragraph
                [ width (px 500)
                , Font.size 24
                , spacing 0
                , behindContent
                    (el
                        [ height (px 24)
                        , width fill
                        , moveLeft 30
                        , Background.color (rgb 60 60 60)
                        ]
                        none
                    )
                ]
                [ text "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum." ]
            ]
        )
