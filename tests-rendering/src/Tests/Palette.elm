module Tests.Palette exposing (black, blue, darkCharcoal, darkGrey, green, grey, lightGrey, red, white)

{-| -}

import Element


black : Element.Color
black =
    Element.rgb 0 0 0


darkGrey : Element.Color
darkGrey =
    Element.rgb 10 10 10


darkCharcoal : Element.Color
darkCharcoal =
    Element.rgb 20 20 20


lightGrey : Element.Color
lightGrey =
    Element.rgb 30 30 30


grey : Element.Color
grey =
    darkGrey


red : Element.Color
red =
    Element.rgb 255 0 0


green : Element.Color
green =
    Element.rgb 0 255 0


white : Element.Color
white =
    Element.rgb 255 255 255


blue : Element.Color
blue =
    Element.rgb 0 0 255
