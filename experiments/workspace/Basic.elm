module Main exposing (main)

{-| -}

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font


box =
    el [ height (px 30), width (px 200), Background.color (rgb 0 0.8 0.9) ] none


main =
    Element.layout
        [ Background.color (rgba 1 1 1 1)
        , Font.color (rgba 1 1 1 1)
        , Font.size 64
        , Font.family
            [ Font.external
                { url = "https://fonts.googleapis.com/css?family=EB+Garamond"
                , name = "EB Garamond"
                }
            , Font.sansSerif
            ]
        ]
    <|
        column
            [ spacing 40
            , Background.color (rgb 1 1 1)
            , centerX
            , inFront
                (el
                    [ Background.color (rgb 1 0 0)
                    , width (px 20)
                    , height (px 20)
                    ]
                    (text "in front of everything")
                )
            , behindContent
                (el
                    [ Background.color (rgb 0.5 0.7 0)
                    , Font.color (rgb 1 1 1)
                    , moveDown 30
                    ]
                    (text "hi there")
                )
            ]
            [ el
                [ Background.color (rgba 0 0.9 0.8 1)
                , Font.color (rgb 0 0 0)
                , behindContent
                    (el
                        [ Background.color (rgb 0.9 0.9 0)
                        , Font.color (rgb 1 1 1)
                        ]
                        (text "hi there")
                    )
                , inFront
                    (el [ Background.color (rgb 0.9 0.9 0.5) ] (text "in front of stuff, behind one"))

                -- , Font.sizeByCapital
                -- , Font.variant Font.smallCaps
                -- , Font.variant Font.ligatures
                -- , Font.variant Font.diagonalFractions
                ]
                (text "Quality 1st Hello stylish friend! ofl 123456  1/3")
            , row
                [ Background.color (rgba 0 0.9 0.8 1)
                , Font.color (rgb 0 0 0)
                , spacing 87
                , behindContent
                    (el [ Background.color (rgb 0.9 0.9 0), Font.color (rgb 1 1 1) ] (text "hi there"))
                , inFront
                    (el [ Background.color (rgb 0.9 0.9 0.5) ] (text "yo"))

                -- , Font.sizeByCapital
                -- , Font.variant Font.smallCaps
                -- , Font.variant Font.ligatures
                -- , Font.variant Font.diagonalFractions
                ]
                [ text "Quality 1st Hello stylish friend! ofl 123456  1/3"
                ]
            , el
                [ Background.color (rgb 0.1 0.1 0.1)
                , width (px 200)
                , height (px 200)

                -- , below
                --     (el
                --         [ Background.color (rgb 1 0 0)
                --         , width (px 20)
                --         , height (px 20)
                --         , moveDown 30
                --         ]
                --         none
                --     )
                , below
                    (el
                        [ Background.color (rgb 0.1 0.1 0.6)
                        , width (px 150)
                        , height (px 150)

                        -- , alignBottom
                        ]
                        none
                    )
                ]
                none
            , el
                [ Background.color (rgb 0.1 0.1 0.1)
                , width (px 200)
                , height (px 200)
                , above
                    (el
                        [ Background.color (rgb 1 0 0)
                        , width (px 20)
                        , height (px 20)

                        -- , moveUp 30
                        ]
                        none
                    )
                , onRight
                    (el
                        [ Background.color (rgb 1 0 0)
                        , width (px 20)
                        , height fill

                        -- , moveUp 30
                        ]
                        none
                    )

                -- , inFront
                --     (el
                --         [ Background.color (rgb 0.1 0.1 0.6)
                --         , width (px 150)
                --         , height (px 150)
                --         ]
                --         none
                --     )
                -- , above
                --     (el
                --         [ Background.color (rgb 1 0 0)
                --         , width (px 20)
                --         , height (px 20)
                --         , moveUp 30
                --         ]
                --         none
                --     )
                ]
                none
            , el
                [ Background.color (rgb 0.1 0.1 0.1)
                , width (px 200)
                , height (px 200)
                , below
                    (el
                        [ Background.color (rgb 1 0 0)
                        , width fill
                        , height (px 20)
                        ]
                        none
                    )
                , above
                    (el
                        [ Background.color (rgb 1 0 0)
                        , width fill
                        , height (px 20)
                        ]
                        none
                    )
                , onLeft
                    (el
                        [ Background.color (rgb 1 0 0)
                        , width (px 20)
                        , height fill
                        ]
                        none
                    )
                , onRight
                    (el
                        [ Background.color (rgb 1 0 0)
                        , width (px 20)
                        , height fill
                        ]
                        none
                    )
                ]
                none
            , el
                [ Background.color (rgb 0.1 0.1 0.1)
                , width (px 200)
                , height (px 200)
                , inFront
                    (el
                        [ Background.color (rgb 1 0 0)
                        , width fill
                        , height fill
                        ]
                        none
                    )
                ]
                none
            ]



-- row
--     [ --width (px 420)
--       padding 0
--     , spacing 20
--     , Background.color (rgb 0.2 0.2 0.3)
--     ]
--     [ box
--     , box
--     , box
--     -- , box
--     -- , box
--     ]
-- wrappedRow
--     [ width (px 420)
--     , padding 10
--     , spacing 20
--     , Background.color (rgb 0.2 0.2 0.3)
--     ]
--     [ box
--     , box
--     , box
--     , box
--     , box
--     ]
