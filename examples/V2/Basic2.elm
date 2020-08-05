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
        , Font.color (rgb 1 1 1)
        , Font.italic
        , Font.size 32
        , Font.family
            [ Font.typeface "EB Garamond"
            , Font.sansSerif
            ]
        ]
        (el
            [ centerX, centerY ]
            (text "Hello stylish friend!")
        )
