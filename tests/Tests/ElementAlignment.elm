module Tests.ElementAlignment exposing (..)

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


box : List (Testable.Attr msg) -> Testable.Element msg
box attrs =
    el
        ([ width (px 50)
         , height (px 50)
         , Background.color blue
         ]
            ++ attrs
        )
        none


container : Testable.Element msg -> Testable.Element msg
container =
    el
        [ width (px 200)
        , height (px 200)
        , Background.color lightGrey
        ]


view : Testable.Element msg
view =
    column []
        [ el [] (text "Alignment Within an El")
        , container <|
            box []
        , text "alignLeft, centerX, alignRight"
        , column [ spacing 20 ] <|
            Generator.sizes
                (\resizeable ->
                    row [ spacing 20 ]
                        [ container <|
                            resizeable [ Background.color blue, alignLeft ] none
                        , container <|
                            resizeable [ Background.color blue, centerX ] none
                        , container <|
                            resizeable [ Background.color blue, alignRight ] none
                        ]
                )
        , text "top, centerY, bottom"
        , column [ spacing 20 ] <|
            Generator.sizes
                (\resizeable ->
                    row [ spacing 20 ]
                        [ container <|
                            resizeable [ alignTop ] none
                        , container <|
                            resizeable [ centerY ] none
                        , container <|
                            resizeable [ alignBottom ] none
                        ]
                )
        , text "align top ++ alignments"
        , column [ spacing 20 ] <|
            Generator.sizes
                (\resizeable ->
                    row [ spacing 20 ]
                        [ container <|
                            resizeable [ alignTop, alignLeft ] none
                        , container <|
                            resizeable [ alignTop, centerX ] none
                        , container <|
                            resizeable [ alignTop, alignRight ] none
                        ]
                )
        , text "centerY ++ alignments"
        , column [ spacing 20 ] <|
            Generator.sizes
                (\resizeable ->
                    row [ spacing 20 ]
                        [ container <|
                            resizeable [ centerY, alignLeft ] none
                        , container <|
                            resizeable [ centerY, centerX ] none
                        , container <|
                            resizeable [ centerY, alignRight ] none
                        ]
                )
        , text "alignBottom ++ alignments"
        , column [ spacing 20 ] <|
            Generator.sizes
                (\resizeable ->
                    row [ spacing 20 ]
                        [ container <|
                            resizeable [ alignBottom, alignLeft ] none
                        , container <|
                            resizeable [ alignBottom, centerX ] none
                        , container <|
                            resizeable [ alignBottom, alignRight ] none
                        ]
                )
        ]
