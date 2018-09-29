module Tests.Palette exposing (black, blue, darkCharcoal, darkGrey, green, grey, lightGrey, red, rgba, white)

{-| -}

import Element


rgba r g b a =
    Element.rgba (r / 255) (g / 255) (b / 255) a


black =
    Element.rgb 0 0 0


darkGrey =
    Element.rgb 0.8 0.8 0.8


darkCharcoal =
    Element.rgb 0.9 0.9 0.9


lightGrey =
    Element.rgb 0.5 0.5 0.5


grey =
    darkGrey


red =
    Element.rgb 1 0 0


green =
    Element.rgb 0 1 0


white =
    Element.rgb 1 1 1


blue =
    Element.rgb 0 0 1
