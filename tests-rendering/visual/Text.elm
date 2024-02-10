module Text exposing (main)

{-| -}

import Html exposing (Html)
import Html.Attributes as Attr
import Theme
import Ui
import Ui.Font
import Ui.Prose


main : Html msg
main =
    Ui.layout
        [ Ui.Font.family [ Ui.Font.typeface "Garamond EB" ]
        ]
        (Ui.column
            [ Ui.width (Ui.px 600)
            , Ui.centerX
            , Ui.paddingXY 0 100
            , Ui.spacing 100
            ]
            [ Theme.h1 "Text"
            , Ui.text (String.repeat 100 "Text should wrap by default. ")
            , Theme.h1 "Clipping with ellipses with one property"
            , Ui.column [ Ui.spacing 20 ]
                [ Ui.el [ Ui.clipWithEllipsis ]
                    (Ui.text "Not long enough to be clipped ")
                , Ui.el [ Ui.clipWithEllipsis ]
                    (Ui.text (String.repeat 100 "Definitely long enough "))
                ]
            , Theme.h1 "Prose.paragraph"
            , Ui.Prose.paragraph [ Ui.paddingXY 100 0 ]
                [ Ui.text (String.repeat 50 "Text should wrap by default. ") ]
            , Ui.Prose.paragraph [ Ui.paddingXY 100 0, Ui.Font.lineHeight 1.8 ]
                [ Ui.text (String.repeat 50 "Text should wrap by default. ") ]
            , Theme.description """When we set font size, the top and bottom's should be trimmed, but line spacing should be unaffected
The below paragraph has a padding of 40, a font size of 60 and a lineSpacing of 40.       
"""
            , Ui.Prose.paragraph
                [ Ui.padding 40

                -- , Ui.Font.lineHeight 2
                -- , Ui.Font.size 80
                , Theme.garamond

                -- Annotations
                , Theme.rulerLeft 40
                , Theme.rulerTop 40
                , Theme.rulerLeftOffset
                    { height = 60
                    , fromTop = 40
                    }
                , Theme.rulerLeftOffset
                    { height = 40
                    , fromTop = 100
                    }
                , Theme.hr 38
                , Theme.hrFromBottom 38
                , Theme.vr 38
                , Ui.onLeft
                    (Ui.el
                        [ Ui.width (Ui.px 60)
                        , Ui.htmlAttribute (Attr.style "height" "1cap")
                        , Ui.borderWith (Ui.Edges 2 0 2 2)
                        , Ui.borderColor Theme.pink
                        , Ui.onLeft
                            (Ui.el
                                [ Ui.centerY
                                , Ui.Font.size 16
                                , Ui.move (Ui.left 5)
                                ]
                                (Ui.text "1cap")
                            )
                        , Ui.move
                            { z = 0
                            , x = -120
                            , y = 40
                            }
                        ]
                        Ui.none
                    )
                , Ui.onLeft
                    (Ui.el
                        [ Ui.width (Ui.px 60)
                        , Ui.htmlAttribute (Attr.style "height" "1ex")
                        , Ui.borderWith (Ui.Edges 2 0 2 2)
                        , Ui.borderColor Theme.pink
                        , Ui.onLeft
                            (Ui.el
                                [ Ui.centerY
                                , Ui.Font.size 16
                                , Ui.move (Ui.left 5)
                                ]
                                (Ui.text "1ex")
                            )
                        , Ui.move
                            { z = 0
                            , x = -80
                            , y = 55
                            }
                        ]
                        Ui.none
                    )
                ]
                [ Ui.text (String.repeat 4 "Text should wrap by default. ") ]
            , Ui.el
                [ Ui.padding 40
                , Ui.Font.size 80

                -- Annotations
                , Theme.rulerLeft 40
                , Theme.rulerTop 40
                , Theme.rulerLeftOffset
                    { height = 60
                    , fromTop = 40
                    }
                , Theme.rulerLeftOffset
                    { height = 40
                    , fromTop = 100
                    }
                , Theme.hr 38
                , Theme.hrFromBottom 38
                , Theme.vr 38
                , Ui.onLeft
                    (Ui.el
                        [ Ui.width (Ui.px 60)
                        , Ui.htmlAttribute (Attr.style "height" "1cap")
                        , Ui.borderWith (Ui.Edges 2 0 2 2)
                        , Ui.borderColor Theme.pink
                        , Ui.onLeft
                            (Ui.el
                                [ Ui.centerY
                                , Ui.Font.size 16
                                , Ui.move (Ui.left 5)
                                ]
                                (Ui.text "1cap")
                            )
                        , Ui.move
                            { z = 0
                            , x = -120
                            , y = 40
                            }
                        ]
                        Ui.none
                    )
                , Ui.onLeft
                    (Ui.el
                        [ Ui.width (Ui.px 60)
                        , Ui.htmlAttribute (Attr.style "height" "1ex")
                        , Ui.borderWith (Ui.Edges 2 0 2 2)
                        , Ui.borderColor Theme.pink
                        , Ui.onLeft
                            (Ui.el
                                [ Ui.centerY
                                , Ui.Font.size 16
                                , Ui.move (Ui.left 5)
                                ]
                                (Ui.text "1ex")
                            )
                        , Ui.move
                            { z = 0
                            , x = -80
                            , y = 40
                            }
                        ]
                        Ui.none
                    )
                ]
                (Ui.text (String.repeat 4 "Text should wrap by default. "))
            , Theme.h1 "Text gradient"
            , Ui.el
                [ Ui.Font.gradient Theme.gradient ]
                (Ui.text "Gradient!!")
            , Ui.Prose.paragraph
                [ Ui.paddingXY 100 0
                , Ui.Font.gradient Theme.gradient
                ]
                (List.repeat 100 (Ui.el [] (Ui.text "Text should wrap by default. ")))

            -- Text alignment
            , Theme.h1 "Text alignment"
            , Ui.el [ Ui.Font.alignRight ] (Ui.text "This should be aligned to the right")
            , Ui.Prose.paragraph
                [ Ui.paddingXY 100 0
                , Ui.Font.gradient Theme.gradient
                , Ui.Font.alignRight
                ]
                (List.repeat 20 (Ui.el [] (Ui.text "This should be aligned to the right. ")))
            , Ui.Prose.paragraph
                [ Ui.paddingXY 100 0
                , Ui.Font.gradient Theme.gradient
                , Ui.Font.alignLeft
                ]
                (List.repeat 20 (Ui.text "This should be aligned to the right. "))
            , Ui.Prose.paragraph
                [ Ui.paddingXY 100 0
                , Ui.Font.gradient Theme.gradient
                , Ui.Font.center
                ]
                (List.repeat 20 (Ui.el [] (Ui.text "This should be aligned to the center. ")))
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
        , Ui.text "World"
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
            (Ui.text "Max height: 200px")
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
