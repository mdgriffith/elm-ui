module Tests.Palette exposing (black, blue, darkCharcoal, darkGrey, green, grey, lightGrey, red, rgba, white)

{-| -}

import Element


rgba r g b a =
    Color.rgba (r / 255) (g / 255) (b / 255) a


black =
    Color.rgb 0 0 0


darkGrey =
    Color.rgb 0.8 0.8 0.8


darkCharcoal =
    Color.rgb 0.9 0.9 0.9


lightGrey =
    Color.rgb 0.5 0.5 0.5


grey =
    darkGrey


red =
    Color.rgb 1 0 0


green =
    Color.rgb 0 1 0


white =
    Color.rgb 1 1 1


blue =
    Color.rgb 0 0 1
