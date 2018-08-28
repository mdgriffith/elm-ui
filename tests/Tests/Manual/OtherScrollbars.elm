module Tests.Manual.OtherScrollbars exposing (main)

import Element exposing (..)
import Element.Background as Bg
import Html exposing (Html)
import Tests.Palette as Palette


main : Html msg
main =
    layout [ height Element.shrink ] <|
        row
            [ height fill
            ]
            [ Element.el [ scrollbarY, width fill, height fill ] <|
                column
                    [ height <| px 1000
                    , Bg.color Color.red
                    , width fill
                    ]
                    []
            , Element.el [ scrollbarY, width fill, height fill ] <|
                column
                    [ height <| px 1500
                    , Bg.color Color.green
                    , width fill
                    ]
                    []
            , Element.el [ scrollbarY, width fill, height fill ] <|
                column
                    [ height <| px 2000
                    , Bg.color Color.blue
                    , width fill
                    ]
                    []
            ]
