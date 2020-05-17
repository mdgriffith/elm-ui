module ClippedElInFixedWidthColumn exposing (..)

{-| el [ clip ] inside a fixed-width column rendered with 0px height in Chrome & Firefox

<https://github.com/mdgriffith/elm-ui/issues/191>

If an el [ clip ] is placed inside a fixed-width column which is inside a layout
with [ width fill, height fill ], then the element is rendered with 0px height in Chrome:

layout [ width fill, height fill ] <|
column [ width <| px 300 ][ el [ clip ] <| text "The quick brown fox" ]

In Firefox, the element is initially rendered correctly, but is resized to 0px height
on viewport resize. In Safari, the element is displayed correctly.

The above seems to be the minimal reproduction:

Removing attributes from layout or from column or from el makes the issue disappear.
Replacing column [ width <| px 300 ] with column [ width fill ] makes the issue disappear.
Replacing column with el also makes the issue disappear.
Adding htmlAttribute <| Attr.style "flex-basis" "auto" to clipped el is a workaround.

-}

import Testable.Element exposing (..)


view =
    layout [ width fill, height fill ] <|
        column [ width <| px 300 ]
            [ el [ clip ] <| text "The quick brown fox" ]
