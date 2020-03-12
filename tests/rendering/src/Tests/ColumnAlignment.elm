module Tests.ColumnAlignment exposing (..)

import Html
import Testable
import Testable.Element as Element exposing (..)
import Testable.Element.Background as Background
import Testable.Element.Font as Font
import Testable.Runner
import Tests.Palette as Palette exposing (..)


{-| -}
main : Html.Html msg
main =
    Testable.Runner.show view


box attrs =
    el
        ([ width (px 50)
         , height (px 50)
         , Background.color blue
         ]
            ++ attrs
        )
        none


container =
    el [ width (px 100), height (px 100) ]


view =
    let
        colContainer attrs children =
            column ([ Background.color lightGrey, spacing 20, width (px 100), height (px 500) ] ++ attrs) children

        tallContainer attrs children =
            column ([ Background.color lightGrey, spacing 20, width (px 100), height fill ] ++ attrs) children
    in
    column
        [ width fill, spacing 20 ]
        [ el [] (text "Alignment Within a Column")
        , row [ spacing 20 ]
            [ colContainer []
                [ box [] ]
            , colContainer []
                [ box [ centerY ]
                ]
            , colContainer []
                [ box [ alignBottom, label "first" ]
                ]
            ]
        , row [ spacing 20 ]
            [ colContainer []
                [ box [] ]
            , colContainer []
                [ box []
                , box []
                , box []
                ]
            , colContainer []
                [ box [ alignLeft, label "first" ]
                , box [ centerX, label "second" ]
                , box [ alignRight, label "third" ]
                ]
            ]
        , row [ spacing 20 ]
            [ colContainer []
                [ box []
                , box []
                , box []
                ]
            , colContainer []
                [ box []
                , box []
                , box [ alignBottom, label "third" ]
                ]
            , colContainer []
                [ box []
                , box [ alignBottom, label "second" ]
                , box []
                ]
            , colContainer []
                [ box [ alignBottom, label "first" ]
                , box []
                , box []
                ]
            ]
        , text "centerY"
        , row [ spacing 20 ]
            [ colContainer [ height fill ]
                [ box [ centerY, label "solo" ]
                ]
            , colContainer []
                [ box []
                , box [ centerY, label "middle" ]
                , box []
                ]
            , colContainer []
                [ box []
                , box []
                , box [ centerY, label "last" ]
                ]
            ]
        , text "multiple centerY"
        , row [ height (px 800), spacing 20 ]
            [ tallContainer []
                [ box []
                , box [ centerY ]
                , box [ centerY ]
                , box [ centerY ]
                , box [ centerY ]
                , box [ alignBottom ]
                ]
            , tallContainer []
                [ box []
                , box [ centerY ]
                , box []
                ]
            , tallContainer []
                [ box []
                , box []
                , box [ centerY ]
                ]
            ]
        , text "top, center, bottom"
        , row [ spacing 20 ]
            [ colContainer []
                [ box [ alignTop, label "first" ]
                , box []
                , box [ alignBottom, label "last" ]
                ]
            , colContainer []
                [ box [ alignTop ]
                , box [ centerY ]
                , box [ alignBottom ]
                ]
            , colContainer []
                [ box [ alignLeft, alignTop ]
                , box [ centerX, centerY ]
                , box [ alignRight, alignBottom ]
                ]
            ]
        , el [ width fill ] (text "Column in a Row")
        , row [ width fill, spacing 20, label "row" ]
            [ box [ alignLeft, alignTop, label "box" ]
            , column
                [ alignLeft
                , alignTop
                , spacing 20
                , label "column"
                , Background.color lightGrey
                ]
                [ box []
                , box []
                , box []
                ]
            , column
                [ spacing 20
                , width (px 100)
                , alignLeft
                , alignTop
                , Background.color lightGrey
                ]
                [ box []
                , box []
                , box []
                ]
            , colContainer []
                [ box [ alignRight ]
                , box [ centerX ]
                , box [ alignLeft ]
                ]
            ]
        ]
