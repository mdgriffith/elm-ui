module Tests.Nearby exposing (view)

{-| Testing nearby elements such as those defined with `above`, `below`, etc.
-}

import Html
import Testable
import Testable.Element exposing (..)
import Testable.Element.Background as Background
import Testable.Element.Font as Font
import Testable.Runner
import Tests.Palette as Palette exposing (..)


box attrs =
    el
        ([ width (px 50)
         , height (px 50)
         , Background.color blue
         ]
            ++ attrs
        )
        none


justBox size color attrs =
    el
        ([ width (px size)
         , height (px size)
         , Background.color color
         ]
            ++ attrs
        )
        none


littleBox name attrs =
    el
        ([ label name
         , width (px 5)
         , height (px 5)
         ]
            ++ attrs
        )
        none


p attrs =
    paragraph
        ([ Background.color blue
         , Font.color white
         , padding 20
         ]
            ++ attrs
        )
        [ text "Lorem Ipsum or something or other." ]


{-| -}
main : Html.Html msg
main =
    Testable.Runner.show view


{-| -}
view : Testable.Element msg
view =
    let
        transparentBox attrs =
            el
                ([ Font.color white
                 , width (px 50)
                 , height (px 50)
                 , Background.color (rgba 52 101 164 0.8)
                 ]
                    ++ attrs
                )
                (text "hi")

        -- single location name box =
        --     row [ height (px 100), width fill, spacing 50 ]
        --         [ box
        --             [ location
        --                 (el
        --                     [ width (px 20)
        --                     , height (px 20)
        --                     , Background.color darkCharcoal
        --                     ]
        --                     none
        --                 )
        --             ]
        --         , box
        --             [ location
        --                 (el
        --                     [ width (px 20)
        --                     , height (px 20)
        --                     , alignLeft
        --                     , Background.color darkCharcoal
        --                     ]
        --                     none
        --                 )
        --             ]
        --         ]
        little name attrs =
            el
                ([ label name
                 , width (px 5)
                 , height (px 5)
                 , Background.color darkCharcoal
                 ]
                    ++ attrs
                )
                none

        nearby location name render =
            column [ spacing 32, label "column" ]
                [ el [ padding 20, Background.color green, Font.color white ] (text name)
                , row [ height (px 100), width fill, spacing 50 ]
                    [ render
                        [ location
                            (el
                                [ label name
                                , width (px 20)
                                , height (px 20)
                                , Background.color darkCharcoal
                                ]
                                none
                            )
                        ]
                    , render
                        [ location
                            (el
                                [ label name
                                , width (px 20)
                                , height (px 20)
                                , alignLeft
                                , Background.color darkCharcoal
                                ]
                                none
                            )
                        ]
                    , render
                        [ location
                            (el
                                [ label name
                                , width (px 20)
                                , height (px 20)
                                , centerX
                                , Background.color darkCharcoal
                                ]
                                none
                            )
                        ]
                    , render
                        [ location
                            (el
                                [ label name
                                , width (px 20)
                                , height (px 20)
                                , alignRight
                                , Background.color darkCharcoal
                                ]
                                none
                            )
                        ]
                    , render
                        [ location
                            (el
                                [ label name
                                , width (px 20)
                                , height (px 20)
                                , alignTop
                                , Background.color darkCharcoal
                                ]
                                none
                            )
                        ]
                    , render
                        [ location
                            (el
                                [ label name
                                , width (px 20)
                                , height (px 20)
                                , centerY
                                , Background.color darkCharcoal
                                ]
                                none
                            )
                        ]
                    , render
                        [ location
                            (el
                                [ label name
                                , width (px 20)
                                , height (px 20)
                                , alignBottom
                                , Background.color darkCharcoal
                                ]
                                none
                            )
                        ]
                    ]
                , text "widths/heights"
                , row [ height (px 100), width fill, spacing 50, label "Row" ]
                    [ render
                        [ location
                            (el
                                [ label name
                                , width fill
                                , height fill
                                , Background.color darkCharcoal
                                ]
                                none
                            )
                        ]
                    , render
                        [ location
                            (el
                                [ label name
                                , width (px 20)
                                , height fill
                                , Background.color darkCharcoal
                                ]
                                none
                            )
                        ]
                    , render
                        [ label "render"
                        , location
                            (el
                                [ label name
                                , width fill
                                , height (px 20)
                                , Background.color darkCharcoal
                                ]
                                none
                            )
                        ]
                    , render
                        [ location
                            (el
                                [ label name
                                , width (px 20)
                                , height shrink
                                , Background.color darkCharcoal
                                , Font.color white
                                ]
                                (text "h-shrink")
                            )
                        ]
                    , render
                        [ location
                            (el
                                [ label name
                                , width shrink
                                , height (px 20)
                                , Background.color darkCharcoal
                                , Font.color white
                                ]
                                (text "w-shrink")
                            )
                        ]
                    ]
                , text "on paragraph"
                , row [ width fill, spacing 50, label "Row" ]
                    [ p
                        [ location
                            (el
                                [ label name
                                , width (px 20)
                                , height (px 20)
                                , Background.color darkCharcoal
                                ]
                                none
                            )
                        ]
                    , p
                        [ location
                            (el
                                [ label name
                                , width (px 20)
                                , height (px 20)
                                , alignLeft
                                , Background.color darkCharcoal
                                ]
                                none
                            )
                        ]
                    , p
                        [ location
                            (el
                                [ label name
                                , width (px 20)
                                , height (px 20)
                                , centerX
                                , Background.color darkCharcoal
                                ]
                                none
                            )
                        ]
                    , p
                        [ location
                            (el
                                [ label name
                                , width (px 20)
                                , height (px 20)
                                , alignRight
                                , Background.color darkCharcoal
                                ]
                                none
                            )
                        ]
                    , p
                        [ location
                            (el
                                [ label name
                                , width (px 20)
                                , height (px 20)
                                , alignTop
                                , Background.color darkCharcoal
                                ]
                                none
                            )
                        ]
                    , p
                        [ location
                            (el
                                [ label name
                                , width (px 20)
                                , height (px 20)
                                , centerY
                                , Background.color darkCharcoal
                                ]
                                none
                            )
                        ]
                    , p
                        [ location
                            (el
                                [ label name
                                , width (px 20)
                                , height (px 20)
                                , alignBottom
                                , Background.color darkCharcoal
                                ]
                                none
                            )
                        ]
                    ]
                ]

        master =
            el [ padding 20 ] <|
                box
                    [ above (little "above-left" [ alignLeft ])
                    , above (little "above-center" [ centerX ])
                    , above (little "above-right" [ alignRight ])
                    , below (little "below-left" [ alignLeft ])
                    , below (little "below-center" [ centerX ])
                    , below (little "below-right" [ alignRight ])
                    , onRight (little "onRight-left" [ alignTop ])
                    , onRight (little "onRight-center" [ centerY ])
                    , onRight (little "onRight-right" [ alignBottom ])
                    , onLeft (little "onLeft-left" [ alignTop ])
                    , onLeft (little "onLeft-center" [ centerY ])
                    , onLeft (little "onLeft-right" [ alignBottom ])
                    , inFront (little "infront-left-top" [ alignTop, alignLeft ])
                    , inFront (little "infront-center-top" [ alignTop, centerX ])
                    , inFront (little "infront-right-top" [ alignTop, alignRight ])
                    , inFront (little "infront-left-center" [ centerY, alignLeft ])
                    , inFront (little "infront-center-center" [ centerY, centerX ])
                    , inFront (little "infront-right-center" [ centerY, alignRight ])
                    , inFront (little "infront-left-bottom" [ alignBottom, alignLeft ])
                    , inFront (little "infront-center-bottom" [ alignBottom, centerX ])
                    , inFront (little "infront-right-bottom" [ alignBottom, alignRight ])
                    ]

        masterParagraph =
            el [ padding 20 ] <|
                p
                    [ above (little "above-left" [ alignLeft ])
                    , above (little "above-center" [ centerX ])
                    , above (little "above-right" [ alignRight ])
                    , below (little "below-left" [ alignLeft ])
                    , below (little "below-center" [ centerX ])
                    , below (little "below-right" [ alignRight ])
                    , onRight (little "onRight-left" [ alignTop ])
                    , onRight (little "onRight-center" [ centerY ])
                    , onRight (little "onRight-right" [ alignBottom ])
                    , onLeft (little "onLeft-left" [ alignTop ])
                    , onLeft (little "onLeft-center" [ centerY ])
                    , onLeft (little "onLeft-right" [ alignBottom ])
                    , inFront (little "infront-left-top" [ alignTop, alignLeft ])
                    , inFront (little "infront-center-top" [ alignTop, centerX ])
                    , inFront (little "infront-right-top" [ alignTop, alignRight ])
                    , inFront (little "infront-left-center" [ centerY, alignLeft ])
                    , inFront (little "infront-center-center" [ centerY, centerX ])
                    , inFront (little "infront-right-center" [ centerY, alignRight ])
                    , inFront (little "infront-left-bottom" [ alignBottom, alignLeft ])
                    , inFront (little "infront-center-bottom" [ alignBottom, centerX ])
                    , inFront (little "infront-right-bottom" [ alignBottom, alignRight ])
                    ]
    in
    column
        [ centerX, label "Nearby Elements", spacing 100 ]
        [ layeredVisibility
        , overlappingChildren

        -- Note: visibility checks like the above
        -- need to be at the top so they're in the viewport
        , master
        , masterParagraph
        , nearby above "above" box
        , nearby below "below" box
        , nearby inFront "inFront" box
        , nearby onRight "onRight" box
        , nearby onLeft "onLeft" box
        , nearby behindContent "behindContent" transparentBox
        ]


layeredVisibility =
    el
        [ centerX
        , inFront (justBox 40 red [ isVisible ])
        ]
        (el [ inFront (justBox 30 green []) ]
            (justBox 50 blue [])
        )


overlappingChildren =
    row [ centerX ]
        [ el [ inFront (justBox 40 green []) ]
            (justBox 40 darkGrey [])
        , el [ onLeft (littleBox "overlapping" [ isVisible, Background.color red ]) ]
            (justBox 40 darkGrey [])
        ]
