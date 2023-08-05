module Basics exposing (main)

import Html exposing (Html)
import Ui
import Ui.Font


pink =
    Ui.rgb 240 0 245


black =
    Ui.rgb 0 0 0


palette =
    { pink =
        Ui.palette
            { background = pink
            , font = black
            , border = black
            }
    }


rulerRight : Int -> Ui.Attribute msg
rulerRight height =
    Ui.onRight
        (Ui.el
            [ Ui.move (Ui.right 5)
            , Ui.width (Ui.px 30)
            , Ui.height (Ui.px height)
            , Ui.borderWith (Ui.Edges 2 2 2 0)
            , Ui.borderColor black
            , Ui.onRight
                (Ui.el [ Ui.centerY, Ui.move (Ui.right 5) ]
                    (Ui.text (String.fromInt height ++ "px"))
                )
            ]
            Ui.none
        )


main : Html msg
main =
    Ui.layout []
        (Ui.column [ Ui.spacing 40, Ui.height Ui.fill ]
            [ Ui.text "Hello"
            , Ui.text "World"
            , Ui.el [ palette.pink ] (Ui.text "default is width fill")
            , Ui.el
                [ Ui.height (Ui.px 200)
                , Ui.width (Ui.px 200)
                , Ui.padding 25
                , rulerRight 200
                , palette.pink
                ]
                (Ui.text "Box:100px w/padding")
            , Ui.el
                [ Ui.height Ui.fill
                , Ui.heightMax 200
                , rulerRight 200
                , Ui.width (Ui.px 200)
                , Ui.padding 25
                , palette.pink
                ]
                (Ui.text "Max height: 100px")
            , Ui.el
                [ Ui.height Ui.fill
                , Ui.heightMax 200
                , rulerRight 200
                , Ui.width Ui.fill
                , Ui.padding 25
                , palette.pink
                , Ui.centerX
                ]
                (Ui.text "Max height: 100px")
            ]
        )
