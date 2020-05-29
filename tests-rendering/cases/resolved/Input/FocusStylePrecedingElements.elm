module FocusStylePrecedingElements exposing (main)

{-|


# `focused` style applied to an element when any element with a lower tab index is focused

<https://github.com/mdgriffith/elm-ui/issues/198>

When I add a focused attribute, the styles therein are applied not only when
the element is focused, but also when any element with a lower tab index is focused.
This behaviour is not browser-specific.

To reproduce, tab through to the buttons in the Ellie below. As soon as the first
button has focus, the third button (which is the only one with a focused attribute)
is highlighted as well.

I narrowed down the reason for this behaviour to this CSS selector:
.s:focus ~ .fc-250-50-50-255-fs:not(.focus)

Disabling it produces the correct focus behaviour.

-}

import Element exposing (..)
import Element.Font as Font
import Element.Input as Input


main =
    layout [] <|
        column []
            [ Input.button [] { onPress = Nothing, label = text "Button" }
            , Input.button [] { onPress = Nothing, label = text "Button" }
            , Input.button [ focused [ Font.color <| rgb255 250 50 50 ] ] { onPress = Nothing, label = text "Button" }
            , Input.button [] { onPress = Nothing, label = text "Button" }
            , Input.button [] { onPress = Nothing, label = text "Button" }
            ]
