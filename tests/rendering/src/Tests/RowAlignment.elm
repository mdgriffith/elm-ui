module Tests.RowAlignment exposing (..)

import Generator
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


view =
    let
        rowContainer attrs children =
            row
                ([ spacing 20
                 , height (px 100)
                 , Background.color lightGrey
                 ]
                    ++ attrs
                )
                children
    in
    column [ width (px 500), spacing 20 ]
        [ el [] (text "Alignment Within a Row")
        , column [ spacing 20 ] <|
            Generator.sizes <|
                \resizeable ->
                    rowContainer
                        [ label "single child" ]
                        [ resizeable [] none ]
        , column [ spacing 20 ] <|
            Generator.sizes <|
                \resizeable ->
                    rowContainer
                        [ label "single child" ]
                        [ resizeable [ centerX ] none ]
        , column [ spacing 20 ] <|
            Generator.sizes <|
                \resizeable ->
                    rowContainer [ label "single child" ]
                        [ resizeable [ alignRight ] none ]
        , column [ spacing 20 ] <|
            Generator.sizes <|
                \resizeable ->
                    rowContainer []
                        [ resizeable [] none
                        , resizeable [] none
                        , resizeable [] none
                        ]
        , column [ spacing 20 ] <|
            Generator.sizes <|
                \resizeable ->
                    rowContainer []
                        [ resizeable [] none
                        , resizeable [] none
                        , resizeable [ alignRight, label "Right Child in Row" ] none
                        ]
        , column [ spacing 20 ] <|
            Generator.sizes <|
                \resizeable ->
                    rowContainer
                        []
                        [ resizeable [] none
                        , resizeable [ alignRight, label "Middle Child in Row" ] none
                        , resizeable [] none
                        ]
        , column [ spacing 20 ] <|
            Generator.sizes <|
                \resizeable ->
                    rowContainer []
                        [ resizeable [ alignRight, label "Left Child in Row" ] none
                        , resizeable [] none
                        , resizeable [] none
                        ]
        , text "center X"
        , column [ spacing 20 ] <|
            Generator.sizes <|
                \resizeable ->
                    rowContainer []
                        [ resizeable [ centerX, label "Left Child in Row" ] none
                        , resizeable [] none
                        , resizeable [] none
                        ]
        , column [ spacing 20 ] <|
            Generator.sizes <|
                \resizeable ->
                    rowContainer []
                        [ resizeable [] none
                        , resizeable [ centerX, label "Middle Child in Row" ] none
                        , resizeable [] none
                        ]
        , column [ spacing 20 ] <|
            Generator.sizes <|
                \resizeable ->
                    rowContainer []
                        [ resizeable [] none
                        , resizeable [] none
                        , resizeable [ centerX, label "Right Child in Row" ] none
                        ]
        , column [ spacing 20 ] <|
            Generator.sizes <|
                \resizeable ->
                    rowContainer []
                        [ resizeable [] none
                        , resizeable [] none
                        , resizeable [ centerX, label "Middle-Right Child in Row" ] none
                        , resizeable [] none
                        ]
        , column [ spacing 20 ] <|
            Generator.sizes <|
                \resizeable ->
                    rowContainer []
                        [ resizeable [] none
                        , resizeable [] none
                        , resizeable [ centerX, label "Middle-Right Child in Row" ] none
                        , resizeable [ centerX, label "Middle-Right Child in Row" ] none
                        , resizeable [] none
                        ]
        , column [ spacing 20 ] <|
            Generator.sizes <|
                \resizeable ->
                    rowContainer []
                        [ resizeable [] none
                        , resizeable [] none
                        , resizeable [ centerX, label "Middle-Right Child in Row" ] none
                        , resizeable [ centerX, label "Middle-Right Child in Row" ] none
                        , resizeable [ centerX, label "Middle-Right Child in Row" ] none
                        , resizeable [] none
                        ]
        , text "left x right"
        , column [ spacing 20 ] <|
            Generator.sizes <|
                \resizeable ->
                    rowContainer []
                        [ resizeable [ alignLeft, label "Left Child in Row" ] none
                        , resizeable [] none
                        , resizeable [ alignRight, label "Right Child in Row" ] none
                        ]
        , text "left center right"
        , column [ spacing 20 ] <|
            Generator.sizes <|
                \resizeable ->
                    rowContainer []
                        [ resizeable [ alignLeft, label "Left Child in Row" ] none
                        , resizeable [ centerX, label "Middle Child in Row" ] none
                        , resizeable [ alignRight, label "Right Child in Row" ] none
                        ]
        , text "vertical alignment"
        , column [ spacing 20 ] <|
            Generator.sizes <|
                \resizeable ->
                    rowContainer []
                        [ resizeable [ alignTop, label "Left Child in Row" ] none
                        , resizeable [ centerY, label "Middle Child in Row" ] none
                        , resizeable [ alignBottom, label "Right Child in Row" ] none
                        ]
        , text "x and y alignments"
        , column [ spacing 20 ] <|
            Generator.sizes <|
                \resizeable ->
                    rowContainer []
                        [ resizeable [ alignLeft, alignTop, label "Left Child" ] none
                        , resizeable [ centerX, centerY, label "Middle Child" ] none
                        , resizeable [ alignRight, alignBottom, label "Right Child" ] none
                        ]
        , text "align Top and X alignments "
        , column [ spacing 20 ] <|
            Generator.sizes <|
                \resizeable ->
                    rowContainer []
                        [ resizeable [ alignLeft, alignTop, label "Left Child" ] none
                        , resizeable [ centerX, alignTop, label "Middle Child" ] none
                        , resizeable [ alignRight, alignTop, label "Right Child" ] none
                        ]
        , text "align Bottom and X alignments "
        , column [ spacing 20 ] <|
            Generator.sizes <|
                \resizeable ->
                    rowContainer []
                        [ resizeable [ alignLeft, alignBottom, label "Left Child" ] none
                        , resizeable [ centerX, alignBottom, label "Middle Child" ] none
                        , resizeable [ alignRight, alignBottom, label "Right Child" ] none
                        ]
        , text "centerY and X alignments "
        , column [ spacing 20 ] <|
            Generator.sizes <|
                \resizeable ->
                    rowContainer []
                        [ resizeable [ alignLeft, centerY, label "Left Child" ] none
                        , resizeable [ centerX, centerY, label "Middle Child" ] none
                        , resizeable [ alignRight, centerY, label "Right Child" ] none
                        ]
        ]
