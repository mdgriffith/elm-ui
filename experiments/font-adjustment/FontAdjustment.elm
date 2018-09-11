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
    { capital : Adjustment
    , lowercase : Adjustment
    , baseline : Adjustment
    , descender : Adjustment
    }


type alias Adjustment =
    Float


type Msg
    = UpdateAdjustment FontAdjustment


edges =
    { top = 0, right = 0, bottom = 0, left = 0 }


init =
    { adjustment =
        { capital = 0.07
        , lowercase = 0.57
        , baseline = 0.265
        , descender = 0.755
        }
    }


update msg model =
    case msg of
        UpdateAdjustment adj ->
            { model | adjustment = adj }


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
            [ Font.external
                { url = "https://fonts.googleapis.com/css?family=EB+Garamond"
                , name = "EB Garamond"
                }
            , Font.sansSerif
            ]
        ]
    <|
        adjustor 240 model.adjustment


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


viewAdjustment label adjustment size left updateWith =
    onLeft
        (el [ moveLeft left, moveUp (0.25 * toFloat size), height (px (round (toFloat size * 1.5))) ] <|
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
                , height (px (round (toFloat size * 1.5)))
                , width (px 1)
                , Background.color charcoal
                , below (el [ centerX ] (text (String.fromFloat adjustment)))
                ]
                { label = Input.labelAbove [ Font.size 18 ] (text "")
                , max = 1.0
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
                        , onRight
                            (el
                                [ height (px 0)
                                , width (px 1200)
                                , moveDown 8
                                , Border.color charcoal
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
                , value = adjustment
                }
        )


adjustor size adjustment =
    let
        labels =
            [ viewAdjustment "Type Height" adjustment.capital size 180 (\capital -> { adjustment | capital = capital })
            , viewAdjustment "Lowercase Height" adjustment.lowercase size 60 (\lowercase -> { adjustment | lowercase = lowercase })
            , viewAdjustment "Baseline" adjustment.baseline size 120 (\baseline -> { adjustment | baseline = baseline })
            , viewAdjustment "Descender" adjustment.descender size 0 (\descender -> { adjustment | descender = descender })
            ]
    in
    el
        ([ centerX, centerY ] ++ labels ++ fontSize size "1.0" 0)
        (text "Typography")
