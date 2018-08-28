module Main exposing (main)

import Tests.Palette as Palette
import Element as El exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Html exposing (Html)


main : Html msg
main =
    El.layout [ El.height El.shrink ] <|
        El.column
            [--El.height El.fill
            ]
            [ header
            , content
            ]


header =
    El.el
        [ El.height (El.px 80)
        , Background.color Color.red
        , El.width El.fill
        ]
        El.none


content =
    El.column
        [ --El.height El.fill
          El.scrollbarY
        ]
        [ item
        , item
        , item
        , item
        , item
        , item
        , item
        , item
        ]


item =
    El.column
        [ El.alignLeft
        , Background.color Color.green
        , El.paddingXY 10 0
        ]
        [ El.el
            [ El.height (El.px 500)
            ]
            (El.text "some content")
        ]
