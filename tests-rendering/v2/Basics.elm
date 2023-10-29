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
    Ui.layout [ Ui.height (Ui.px 8000) ]
        column


row =
    Ui.row [ Ui.spacing 40, Ui.height Ui.fill, Ui.padding 200 ]
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

            -- , Ui.alignTop
            -- , Ui.alignBottom
            ]
            (Ui.text "Max height: 200px")
        , Ui.el
            [ Ui.height Ui.fill
            , Ui.heightMax 500
            , rulerRight 200
            , Ui.widthMax 800
            , Ui.padding 25
            , palette.pink
            , Ui.alignTop
            ]
            (Ui.text "Max height: 200px")
        ]


column =
    Ui.column [ Ui.spacing 40, Ui.height Ui.fill, Ui.padding 200 ]
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
        , Ui.clipped
            [ Ui.width (Ui.px 100)
            , Ui.height (Ui.px 400)
            , Ui.background (Ui.rgb 100 100 100)
            ]
            (Ui.el [ Ui.width (Ui.px 800), Ui.background (Ui.rgb 200 100 100) ]
                Ui.none
            )
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
            , rulerRight 200
            , Ui.widthMax 400
            , Ui.padding 25
            , palette.pink
            , Ui.centerX
            ]
            (Ui.text "Max height: 100px")
        ]
