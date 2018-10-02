module Main exposing (main)

{-| Line Height as its specified through CSS doesn't make a whole lot of sense typographically.

We also run into issues with sizing a font. The font size generally refers to the full type size (from the top of ascendors to the bottom of descenders)

However, sometimes we might want to size things from the top of the Capital to the baseline.

Or from the top of the x-height to the baseline.

The main place this shows up is for dropped capitals, and for text on buttons.

-}

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Lazy
import Html
import Html.Attributes


type alias FontAdjustment =
    { lineHeight : Float
    , capital : Line
    , lowercase : Line
    , baseline : Line
    , descender : Line
    }


type alias Line =
    Float


type Msg
    = UpdateAdjustment FontAdjustment


edges =
    { top = 0
    , right = 0
    , bottom = 0
    , left = 0
    }


garamond =
    let
        default =
            { capital = 1.09
            , lowercase = 0.81
            , baseline = 0.385
            , descender = 0.095
            , lineHeight = 1.5
            }
    in
    { adjustment =
        default
    , converted =
        convertAdjustment default
    , font =
        { url = Just "https://fonts.googleapis.com/css?family=EB+Garamond"
        , name = "EB Garamond"
        , variants = []
        , adjustment =
            { capital = default.capital
            , lowercase = default.lowercase
            , baseline = default.baseline
            , descender = default.descender
            }
        }
    }


catamaran =
    let
        default =
            { capital = 1.15
            , lowercase = 0.96
            , baseline = 0.465
            , descender = 0.245
            , lineHeight = 1.5
            }
    in
    { adjustment =
        default
    , converted =
        convertAdjustment default
    , font =
        { url = Just "https://fonts.googleapis.com/css?family=Catamaran"
        , name = "Catamaran"
        , variants = []
        , adjustment =
            { capital = default.capital
            , lowercase = default.lowercase
            , baseline = default.baseline
            , descender = default.descender
            }
        }
    }


poiret =
    let
        default =
            { capital = 1.12
            , lowercase = 0.82
            , baseline = 0.365
            , descender = 0.18
            , lineHeight = 1.5
            }
    in
    { adjustment =
        default
    , converted =
        convertAdjustment default
    , font =
        { url = Just "https://fonts.googleapis.com/css?family=Poiret+One"
        , name = "Poiret One"
        , variants = []
        , adjustment =
            { capital = default.capital
            , lowercase = default.lowercase
            , baseline = default.baseline
            , descender = default.descender
            }
        }
    }


roboto =
    let
        default =
            { capital = 1.115
            , lowercase = 0.93
            , baseline = 0.4
            , descender = 0.19
            , lineHeight = 1.5
            }
    in
    { adjustment =
        default
    , converted =
        convertAdjustment default
    , font =
        { url = Just "https://fonts.googleapis.com/css?family=Roboto"
        , name = "Roboto"
        , adjustment =
            { capital = default.capital
            , lowercase = default.lowercase
            , baseline = default.baseline
            , descender = default.descender
            }
        , variants = []
        }
    }


init =
    -- catamaran
    garamond



-- poiret
-- roboto


update msg model =
    case msg of
        UpdateAdjustment adj ->
            let
                font =
                    model.font
            in
            { model
                | adjustment = adj
                , converted = convertAdjustment adj
                , font =
                    { font
                        | adjustment =
                            { capital = adj.capital
                            , lowercase = adj.lowercase
                            , baseline = adj.baseline
                            , descender = adj.descender
                            }
                    }
            }


main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }


view model =
    Element.layout
        [ above (html (Html.node "style" [] [ Html.text """
.lh-15 .t {
   line-height: 1.5;
}

.lh-norm .t {
    line-height: normal;
}
          
             """ ]))
        , Background.color (rgba 1 1 1 1)
        , padding 100
        , Font.color (rgba 0 0 0 1)
        , Font.family
            [ -- Font.external
              -- { url = "https://fonts.googleapis.com/css?family=EB+Garamond"
              -- , name = "EB Garamond"
              -- }
              --   Font.external
              --     { url = "https://fonts.googleapis.com/css?family=Catamaran"
              --     , name = "Catamaran"
              --     }
              Font.with
                model.font
            , Font.sansSerif
            ]
        ]
    <|
        column [ width fill, height fill, spacing 128 ]
            [ adjustor 120 model.adjustment
            , adjusted 120 model.converted
            ]


style name val =
    htmlAttribute (Html.Attributes.style name val)


class name =
    htmlAttribute (Html.Attributes.class name)


charcoal =
    rgb 0.7 0.7 0.7


adjustor size adjustment =
    let
        labels =
            [ viewAdjustment "Type Height" adjustment.capital size 180 adjustment.lineHeight (\capital -> { adjustment | capital = capital })
            , viewAdjustment "Lowercase Height" adjustment.lowercase size 60 adjustment.lineHeight (\lowercase -> { adjustment | lowercase = lowercase })
            , viewAdjustment "Baseline" adjustment.baseline size 120 adjustment.lineHeight (\baseline -> { adjustment | baseline = baseline })
            , viewAdjustment "Descender" adjustment.descender size 0 adjustment.lineHeight (\descender -> { adjustment | descender = descender })
            ]
    in
    el
        ([ centerX
         , centerY
         , Background.color (rgb 0 0.8 0.9)
         , class "lh-15"
         , style "line-height" (String.fromFloat adjustment.lineHeight)
         , onRight
            (el
                [ centerY
                , width (px 40)

                -- , height (px (round (toFloat size * (1 / 1.5))))
                , height (px size)
                , Background.color (rgb 0.9 0.8 0)
                ]
                none
            )
         , Font.size size
         ]
            ++ labels
        )
        (text "Typography")


adjusted size adjustment =
    column
        [ spacing 48
        , centerX
        , centerY
        ]
        [ el
            [ Font.size 32 ]
            (text "New Adjustments in Els")
        , row
            [ Font.size 85
            , padding 80
            , spacing 48
            ]
            [ el
                [ Font.size 95
                , Font.full
                , Background.color (rgb 0 0.8 0.9)
                , above (el [ Font.size 24, moveUp 6 ] (text "full height"))
                , onLeft <|
                    el
                        [ centerY
                        , width (px 40)
                        , height (px 95)
                        , Background.color (rgb 0.9 0.8 0)
                        ]
                        none
                ]
                (text "Typography")
            , el
                [ Font.sizeByCapital
                , Font.size 85
                , Background.color (rgb 0 0.8 0.9)
                , above (el [ Font.size 24, moveUp 6 ] (text "corrected capital"))
                , onLeft <|
                    el
                        [ centerY
                        , width (px 40)
                        , height (px 85)
                        , Background.color (rgb 0.9 0.8 0)
                        ]
                        none
                ]
                (text "Typography")
            ]
        , el [ Font.size 32 ] (text "Standard Defaults in CSS")
        , row
            [ spacing 32
            , Font.size 120
            ]
            [ el
                [ Background.color (rgb 0 0.8 0.9)
                , style "line-height" "normal"
                , class "lh-norm"
                , above (el [ Font.size 12 ] (text "line-height: normal"))
                ]
                (text "Typography")
            , el
                [ Background.color (rgb 0 0.8 0.9)
                , style "line-height" "1"
                , above (el [ Font.size 12 ] (text "line-height: 1"))
                ]
                (text "Typography")
            ]
        , row [ spacing 120 ]
            [ paragraph
                [ Font.size 25
                , spacing 5
                , width (px 200)
                , Background.color
                    (rgb 0 0.8 0.9)
                , above (el [ Font.size 32, moveUp 32 ] (text "Normal Paragraphs"))
                ]
                [ el [ Font.size 55, alignLeft, Background.color (rgb 0.9 0.8 0) ] (text "L")
                , text "orem Ipsum is simply dummy text of the printing and typesetting industry."
                ]
            , paragraph
                [ Font.size 45
                , spacing 10
                , width (px 600)
                , inFront
                    (el
                        [ width (px 100)
                        , height (px 5)
                        , moveDown 45
                        , alignRight
                        , Background.color (rgba 0.9 0.8 0.2 0.5)
                        ]
                        none
                    )
                , inFront
                    (el
                        [ width (px 100)
                        , height (px 45)
                        , alignRight
                        , Background.color (rgba 0 0 0 0.5)
                        ]
                        none
                    )
                , Background.color
                    (rgb 0 0.8 0.9)
                , above
                    (el [ Font.size 32, moveUp 32 ] (text "Corrected Paragraphs"))
                ]
                [ el
                    [ Font.size 100
                    , alignLeft
                    , Background.color (rgb 0.9 0.8 0)
                    , Font.sizeByCapital
                    ]
                    (text "C")
                , text "ontrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of \"de Finibus Bonorum et Malorum\" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, \"Lorem ipsum dolor sit amet..\", comes from a line in section 1.10.32."
                ]
            ]
        ]


corrected converted label =
    el
        [ Background.color (rgb 0 0.8 0.9)
        , style "display" "block"
        , above (el [ Font.size 12, moveUp 6 ] (text label))
        , style "line-height" (String.fromFloat converted.height)
        , below
            (column [ Font.size 12, spacing 5, moveDown 10 ]
                [ text ("height: " ++ String.left 5 (String.fromFloat converted.height))
                , text ("vertical: " ++ String.left 5 (String.fromFloat converted.vertical))
                ]
            )
        ]
        (el
            [ style "display" "inline-block"
            , style "line-height" (String.fromFloat converted.height)
            , style "vertical-align" (String.fromFloat converted.vertical ++ "em")
            ]
            (text "Typography")
        )


convertAdjustment adjustment =
    let
        base =
            adjustment.lineHeight

        normalDescender =
            (adjustment.lineHeight - 1)
                / 2

        oldMiddle =
            adjustment.lineHeight / 2

        newCapitalMiddle =
            ((ascender - newBaseline) / 2) + newBaseline

        newFullMiddle =
            ((ascender - descender) / 2) + descender

        lines =
            [ adjustment.capital
            , adjustment.baseline
            , adjustment.descender
            , adjustment.lowercase
            ]

        ascender =
            Maybe.withDefault adjustment.capital (List.maximum lines)

        descender =
            Maybe.withDefault adjustment.descender (List.minimum lines)

        newBaseline =
            lines
                |> List.filter (\x -> x /= descender)
                |> List.minimum
                |> Maybe.withDefault adjustment.baseline

        capitalVertical =
            (oldMiddle - newCapitalMiddle) * 2

        fullVertical =
            (oldMiddle - newFullMiddle) * 2
    in
    { full =
        { vertical = fullVertical
        , height =
            (ascender - descender)
                - abs fullVertical
        }
    , capital =
        { vertical = capitalVertical
        , height = (ascender - newBaseline) - abs capitalVertical
        }
    }


viewAdjustment label adjustment size left lineHeight updateWith =
    let
        fullHeight =
            toFloat size * 1.5
    in
    onLeft
        (el
            [ moveLeft left
            , height (px (round (toFloat size * lineHeight)))
            ]
         <|
            Input.slider
                [ Font.size 24
                , Element.behindContent
                    (Element.el
                        [ Element.width (Element.px 1)
                        , Element.height Element.fill
                        , Element.centerY
                        , Background.color charcoal
                        , Border.rounded 2
                        ]
                        Element.none
                    )
                , height (px (round fullHeight))
                , width (px 1)
                , spacing 0
                , Background.color charcoal
                , below (el [ centerX ] (text (String.fromFloat adjustment)))
                , onRight
                    (el
                        [ height (px 0)
                        , width (px 800)
                        , moveRight 10
                        , alignBottom
                        , moveUp (fullHeight * (adjustment / lineHeight))
                        , Border.color (rgb 0 0 0)
                        , Border.dashed
                        , Border.widthEach
                            { top = 1
                            , right = 0
                            , bottom = 0
                            , left = 0
                            }
                        ]
                        none
                    )
                ]
                { label = Input.labelHidden "font adjustment"
                , max = lineHeight
                , min = 0
                , onChange =
                    \x ->
                        UpdateAdjustment
                            (updateWith x)
                , step = Just 0.005
                , thumb =
                    Input.thumb
                        [ Element.width (Element.px 16)
                        , Element.height (Element.px 16)
                        , Border.rounded 8
                        , Border.width 1
                        , Border.color (Element.rgb 0.5 0.5 0.5)
                        , Background.color (Element.rgb 1 1 1)
                        ]
                , value = adjustment
                }
        )
