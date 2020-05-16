module ElInFixedHeightColumn exposing (view)

{-| el inside a fixed height column is rendered with zero height in Safari

<https://github.com/mdgriffith/elm-ui/issues/190>

If I put an el into a column of fixed height, the el is rendered with zero height
in Safari:

    layout [] <|
        column
            [ width fill
            , height <| px 200
            ]
            [ el [ Border.width 3, Border.color <| rgb255 0 0 0 ] <| text "an element" ]

Adding htmlAttribute <| Attr.style "flex-basis" "auto" to the el is a workaround
that fixes the problem in this instance.

Expected behavior

Element should be rendered the same as in Firefox & Chrome, with the border going
around the text.

-}

import Testable.Element exposing (..)
import Testable.Element.Border as Border


view =
    layout [] <|
        column
            [ width fill
            , height <| px 200
            ]
            [ el
                []
              <|
                text "an element"
            ]
