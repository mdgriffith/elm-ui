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


default =
    { capital = 1.15
    , lowercase = 0.96
    , baseline = 0.465
    , descender = 0.245
    , lineHeight = 1.5
    }


init =
    { adjustment =
        default
    , converted =
        convertAdjustment default
    }


update msg model =
    case msg of
        UpdateAdjustment adj ->
            { model
                | adjustment = adj
                , converted = convertAdjustment adj
            }


main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }


view model =
    Element.layout
        [ Background.color (rgba 1 1 1 1)
        , Font.color (rgba 0 0 0 1)
        , Font.family
            [ -- Font.external
              -- { url = "https://fonts.googleapis.com/css?family=EB+Garamond"
              -- , name = "EB Garamond"
              -- }
              Font.external
                { url = "https://fonts.googleapis.com/css?family=Catamaran"
                , name = "Catamaran"
                }
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


fontSize pixels lineHeight up =
    [ Font.size pixels

    -- , htmlAttribute (Html.Attributes.style "line-height" lineHeight)
    -- , Background.color (rgb 0 0.8 0.9)
    -- , onLeft
    --     (el
    --         [ Background.color (rgb 0 0 0)
    --         , width (px 20)
    --         , height (px pixels)
    --         , moveUp up
    --         ]
    --         none
    --     )
    ]


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
        [ row
            [ spacing 32
            , Font.size 120
            , above (text "hi")
            ]
            [ el
                [ Background.color (rgb 0 0.8 0.9)
                , style "line-height" "normal"
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
        , row
            [ spacing 32
            , Font.size 120
            ]
            [ corrected adjustment.full "corrected"
            , corrected adjustment.capital "corrected capital"
            ]
        , paragraph [ Font.size 25, spacing 5, width (px 200) ]
            [ el [ Font.size 55, alignLeft ] (text "L")
            , text "orem Ipsum is simply dummy text of the printing and typesetting industry."
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

            -- , moveUp (0.125 * toFloat size)
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
                { label = Input.labelAbove [ Font.size 18 ] (text "")
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
                        , Border.color (Color.rgb 0.5 0.5 0.5)
                        , Background.color (Color.rgb 1 1 1)

                        -- , onRight
                        --     (el
                        --         [ height (px 0)
                        --         , width (px 1200)
                        --         , moveDown 8
                        --         , Border.color (rgb 0 0 0)
                        --         , Border.dashed
                        --         , Border.widthEach
                        --             { top = 1
                        --             , right = 0
                        --             , bottom = 0
                        --             , left = 0
                        --             }
                        --         ]
                        --         none
                        --     )
                        ]
                , value = adjustment
                }
        )
