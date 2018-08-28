module Main exposing (main)

import Tests.Palette as Palette exposing (..)
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)


main : Html msg
main =
    layout
        [ Font.size 20
        , Font.lineHeight 1.3
        , Font.color darkCharcoal
        ]
    <|
        textColumn
            [ spacing 56 ]
            [ paragraph []
                [ el
                    [ alignLeft
                    , Font.size 60
                    , Font.lineHeight 0.8
                    , moveUp 5
                    , paddingEach
                        { right = 5
                        , top = 0
                        , bottom = 0
                        , left = 0
                        }
                    ]
                    (text "S")
                , text "tylish elephants are on the loose.  By day they prowl, by night they sleep."
                , text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam dictum turpis sem, sed commodo felis blandit quis. Etiam gravida velit a felis accumsan, ut finibus risus bibendum. Donec eget augue lorem. Curabitur neque sem, fermentum sed nisl at, semper feugiat nibh. Morbi mollis tempor turpis. Suspendisse est urna, sodales sed molestie semper, rhoncus eu nisl. Fusce ultrices leo sit amet arcu maximus, in scelerisque ante egestas. Suspendisse dictum augue eu venenatis molestie. Duis ullamcorper magna ut ex placerat fringilla. In mollis efficitur tellus, sit amet tincidunt mauris accumsan non. Morbi vel dapibus velit. Nullam quam sem, mattis vel feugiat et, sagittis vulputate libero. Maecenas posuere dui semper mollis hendrerit. Sed sit amet dolor tempus, tristique enim in, porttitor sem. Ut lobortis egestas lorem ut ornare."
                ]
            , paragraph []
                [ text "Vivamus luctus ex eros, ac accumsan lectus ornare eget. Phasellus mattis dapibus tortor, ut rutrum dolor pulvinar eget. Sed vulputate metus vel sapien dignissim, ac ornare justo porta. Praesent dolor leo, varius id nisl ut, pretium dapibus purus. Curabitur at dolor et augue accumsan venenatis et non urna. Aenean rutrum augue nulla, a tempus sapien aliquam vel. Cras sodales nulla sed dolor mollis, ac consectetur lorem consectetur." ]
            , paragraph []
                [ text "Maecenas ultricies felis ipsum, quis rhoncus libero malesuada eget. Maecenas sagittis quis ipsum at convallis. Suspendisse potenti. Donec feugiat ligula nunc, id pellentesque erat tristique sed. In hac habitasse platea dictumst. Sed rutrum, urna vel efficitur pretium, lacus risus blandit turpis, sed finibus nisi odio pretium diam. Etiam elementum ante non nibh semper, quis gravida elit fermentum."
                ]
            ]
