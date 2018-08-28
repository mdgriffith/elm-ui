module Main exposing (..)

import Element exposing (..)
import Html
import Palette


{- First, Define our Palette

   Usually this would be in a different file.

-}


type alias MyColorPalette =
    { primary : Palette.Protected Color
    , secondary : Palette.Protected Color
    }

myColors : Palette.Colors MyColorPalette
myColors =
    Palette.colors MyColorPalette
        |> Palette.color (rgb 1 0 0)
        |> Palette.color (rgb 1 0 1)

main =
    Palette.layout myColors
        []
        (Palette.Element
            [ 
                -- Palette.bgColor red
                --
              Palette.bgColor .primary
            --   Palette.bgColor (Palette.dynamic (rgb 0 1 0))
            ]
            []
        )
