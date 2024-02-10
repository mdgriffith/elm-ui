module Layout exposing (main)

{-| -}

import Html exposing (Html)
import Theme
import Ui
import Ui.Font


main : Html msg
main =
    Ui.layout []
        (Ui.column
            [ Ui.width (Ui.px 800)
            , Ui.centerX
            , Ui.padding 100
            , Ui.spacing 100
            ]
            [ Theme.h1 "Row"
            , Theme.description "Hello"
            , Ui.el [ Theme.palette.pink ]
                (Ui.text "El's should be width fill by default")
            , Ui.row [ Theme.palette.pink ]
                [ Ui.text "Rows should be filled by default" ]
            , Theme.h2 "Wrapped row"
            , Ui.row [ Ui.spacing 20, Ui.wrap ]
                (List.repeat 100 smallBox)
            , row
            , row2
            , Theme.h1 "Column"
            , column
            , column2
            , Ui.column [ Theme.palette.pink ]
                [ Ui.text "Columns should be filled by default" ]
            , Theme.h2 "Wrapped column"
            , Ui.column [ Ui.spacing 20, Ui.wrap, Ui.heightMax 600 ]
                (List.repeat 100 smallBox)
            , centered
            ]
        )


smallBox =
    Ui.el
        [ Ui.width (Ui.px 20)
        , Ui.height (Ui.px 20)
        , Theme.palette.pink
        ]
        Ui.none


row =
    Ui.row [ Ui.spacing 80, Ui.height Ui.fill ]
        [ Ui.text "Hello"
        , Ui.el [ Theme.palette.pink ] (Ui.text "default is width fill")
        , Ui.el
            [ Ui.height (Ui.px 200)
            , Ui.width (Ui.px 200)
            , Ui.padding 25
            , Theme.rulerRight 200
            , Theme.rulerTop 200
            , Theme.palette.pink
            ]
            (Ui.text "Box:200px w/padding")
        , Ui.el
            [ Ui.height Ui.fill
            , Ui.heightMax 200
            , Theme.rulerRight 200
            , Ui.width (Ui.px 200)
            , Ui.padding 25
            , Theme.palette.pink
            ]
            (Ui.text "Height: fill, Max: 200px")
        , Ui.el
            [ Ui.height Ui.fill
            , Ui.heightMax 500
            , Theme.rulerRight 500
            , Ui.widthMax 800
            , Ui.padding 25
            , Theme.palette.pink
            , Ui.alignTop
            ]
            (Ui.text "Max height: 500px")
        ]


row2 =
    Ui.row
        [ Ui.spacing 80
        , Ui.height Ui.fill
        , Ui.padding 50
        , Ui.border 2
        ]
        [ Ui.text "Hello"
        , Ui.el
            [ Ui.height (Ui.px 200)
            , Ui.width (Ui.px 20)
            , Ui.padding 25
            , Theme.rulerRight 200
            , Theme.palette.pink
            ]
            (Ui.text "Height: 200px")
        , Ui.el
            [ Ui.height Ui.fill

            -- , Theme.rulerRight 500
            -- , Ui.widthMax 800
            -- , Ui.width (Ui.px 200)
            , Ui.padding 25
            , Theme.palette.pink
            ]
            (Ui.text "Height fill")
        ]


column =
    Ui.column [ Ui.spacing 40, Ui.height (Ui.px 1500) ]
        [ Ui.text "Hello"
        , Ui.text "World"
        , Ui.el [ Theme.palette.pink ] (Ui.text "default is width fill")
        , Ui.el
            [ Ui.height (Ui.px 200)
            , Ui.width (Ui.px 200)
            , Ui.padding 25
            , Theme.rulerRight 200
            , Theme.palette.pink
            ]
            (Ui.text "Box:100px w/padding")
        , Ui.el [ Theme.rulerRight 200, Ui.width Ui.shrink ] <|
            Ui.clipped
                [ Ui.width (Ui.px 200)
                , Ui.height (Ui.px 200)
                , Ui.padding 40
                , Theme.palette.pink
                ]
                (Ui.el
                    [ Ui.width (Ui.px 400)
                    , Ui.height (Ui.px 800)
                    ]
                    (Ui.text "Clipped at 200px X and Y")
                )
        , Ui.el
            [ Ui.height Ui.fill
            , Ui.heightMax 200
            , Theme.rulerRight 200
            , Ui.width (Ui.px 200)
            , Ui.padding 25
            , Theme.palette.pink
            ]
            (Ui.text "Max height: 200px")
        , Ui.el
            [ Ui.height Ui.fill
            , Theme.rulerTop 400
            , Ui.widthMax 400
            , Ui.padding 25
            , Theme.palette.pink
            , Ui.centerX
            ]
            (Ui.text "Height fill, Centered X, and width max of 400")
        ]


column2 =
    Ui.column [ Ui.spacing 40, Ui.padding 50, Ui.border 2 ]
        [ Ui.text "Hello"
        , Ui.text "World"
        , Ui.el [ Theme.palette.pink ] (Ui.text "default is width fill")
        , Ui.el
            [ Ui.height (Ui.px 200)
            , Ui.width (Ui.px 400)
            , Ui.padding 25
            , Theme.rulerRight 200
            , Theme.palette.pink
            ]
            (Ui.text "Width: 600 + 25 padding")
        , Ui.el
            [ Theme.palette.pink
            ]
            (Ui.text "Width fill")
        , Ui.el
            [ Theme.palette.pink
            , Ui.centerX
            ]
            (Ui.text "Width fill")
        , Ui.el
            [ Theme.palette.pink
            , Ui.width Ui.shrink
            ]
            (Ui.text "Width fill")
        ]


centered =
    Ui.row
        [ Ui.centerX
        , Ui.spacing 50
        ]
        [ Ui.el
            []
            (Ui.text "Our software completes the Retrofit Assessment process, minimising the need for costly and time consuming surveys.")
        , Ui.el
            [ Ui.width (Ui.px 400)
            , Ui.height (Ui.px 400)
            , Theme.palette.pink
            ]
            Ui.none
        ]
