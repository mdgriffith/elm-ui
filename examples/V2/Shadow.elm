module Shadow exposing (..)

{-| -}

import Element2 exposing (..)
import Element2.Background as Background
import Element2.Border as Border
import Element2.Events
import Element2.Font as Font
import Element2.Keyed
import Element2.Lazy
import Element2.Region
import Browser
import Element2.Input as Input
import Html.Events as Events
import Json.Decode
import Html
import Html.Attributes as Attr
import Element2.Animated as Animated


on str decoder = 
    htmlAttribute <| Events.on str decoder

-- import Element2.Lazy


main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }

init = 
    { elevation = 5
    , light1 = 
        { direction = 0.1
        , elevation = 0.8
        , hardness = 5
        }
    , light2 =
        { direction = 0.1
        , elevation = 0.8
        , hardness = 5
        }
    , light3 =
        { direction = 0.1
        , elevation = 0.8
        , hardness = 5
        }
    , x = 20
    , y = 20
    , size = 20
    , blur = 20
    , color = rgb 0 0 0
    , ui = Element2.init
    }

type alias Light =
    { direction : Float
    , elevation : Float
    , hardness : Float
    }


type Id = One

type Msg =
    LightOne Light
    | LightTwo Light
    | LightThree Light
    | Elevation Float
    | UI (Element2.Msg Id)
    | AnimStart Json.Decode.Value
    | Hello

update msg model =
    case msg of
        LightOne new ->
            {model | light1 = new }

        LightTwo new ->
            {model | light2 = new }

        LightThree new ->
            {model | light3 = new }

        Elevation new ->
            {model | elevation = new}

        UI uiMsg ->
            {model | ui = Element2.update uiMsg model.ui}

        Hello ->
            model

        AnimStart value ->
            let 
                _ = Debug.log "anim"
                   
                   (Json.Decode.decodeValue className
                    value
                   )

            in
            model


className =
    Json.Decode.field "srcElement"
        (Json.Decode.field "className" Json.Decode.string)


view model =
    let 
         ( x, y ) =
            fromPolar ( model.elevation, turns (0.25 + 0.1) )
    in
    layoutWith { options = [] } model.ui
        [ Font.italic
        , Font.size 32
        , Font.with
            { name = "EB Garamond"
            , fallback = [ Font.serif ]
            , sizing =
                Font.byCapital
                   
                    { offset = 0.045
                    , height = 0.73

                    }
            , variants =
                []
            }
        ]
        (column 
            [ centerX
            , centerY
            , spacing 64 
            , behindContent 
                (html 
                    (Html.node "style" 
                        []
                        [Html.text """
.active {
  animation : move 1s 2 alternate;
}
@keyframes move {
  0%{
    left : 0;
  }
  100%{
    left : 1px;
  }
}
                        
                        
                        """]

                    )
                )
            ]
            [ el
                [ padding 42
                -- sends the bounding box up to `update`
                -- , Animated.id One 
                -- we potentially want to control
                --   1. How the bounding box animation interpolates (linear? spring?)
                --   2. animate other aspects like border-width, border-radius as we're transitioning.


                , Border.rounded 3
                , Border.color (rgb 5 5 5)
                , Border.solid
                , Border.dashed
                , Border.width 2
                , Background.color (rgb 255 255 255)
                -- , Background.colorWhen UI hovered (duration 200) (rgb 0 255 255)
                -- , inFront (el 
                --             [ width fill
                --             , height fill
                --             -- , Element2.Events.onMouseEnter Hello
                            
                            
                --             ] none)
                

               , Animated.hovered UI 
                    [ Animated.background.color (rgb 0 255 255)
                    , Animated.font.size 25
                    , Animated.position 100 100
                    ]
               
                -- , htmlAttribute (Attr.class "active")
                , moveDown y
                -- , moveRight x

                -- , on "animationstart" (Json.Decode.map AnimStart Json.Decode.value )
                , Border.lights
                    { elevation = model.elevation
                    , lights = 
                        [ model.light1
                        , model.light2
                        , model.light3
                        ]
                   }
                -- , Border.shadows 
                --     [ { x = model.x
                --         , y = model.y
                --         , size = model.size
                --         , blur = model.blur
                --         , color = model.color
                --         }

                --     ]
                    
                ]
                (text "Hello stylish friend!")

            , Input.sliderX
                [ behindContent
                    (el
                        [ width fill
                        , height (px 2)
                        , centerY
                        , Background.color (rgb 240 240 240)
                        , Border.rounded 2
                        ]
                        none
                    )
                , spacing 12
                
                ]
                { onChange = (Elevation  )
                , label =
                    Input.labelAbove [Font.size 14]
                        (Element2.text
                            ("Elevation " ++ String.fromFloat model.elevation
                                |> String.left 14
                            )
                        )
                , min = 0
                , max = 50
                , step = Nothing
                , value = model.elevation
                , thumb =
                    Input.defaultThumb
                }
            , row [width fill, spacing 8 ] 
                [ editLight LightOne model.light1
                , editLight LightTwo model.light2
                , editLight LightThree model.light3
                ]

            

             
           
            ]
        )




editLight onChange light =
    column [ spacing 16, width fill] 
        [ Input.sliderX
                [ behindContent
                    (el
                        [ width fill
                        , height (px 2)
                        , centerY
                        , Background.color (rgb 240 240 240)
                        , Border.rounded 2
                        ]
                        none
                    )
                , spacing 12
                ]
                { onChange = \direction -> (onChange { light | direction = direction })
                , label =
                    Input.labelAbove [Font.size 14]
                        (Element2.text
                            ("Direction " ++ String.fromFloat light.direction
                                |> String.left 14
                            )
                        )
                , min = 0
                , max = 1
                , step = Nothing
                , value = light.direction
                , thumb =
                    Input.defaultThumb
                }
        , Input.sliderX
                [ behindContent
                    (el
                        [ width fill
                        , height (px 2)
                        , centerY
                        , Background.color (rgb 240 240 240)
                        , Border.rounded 2
                        ]
                        none
                    )
                , spacing 12
                ]
                
                { onChange = \elevation -> onChange { light | elevation = elevation }
                , label =
                    Input.labelAbove [Font.size 14]
                        (Element2.text
                            ("Elevation " ++ String.fromFloat light.elevation
                                |> String.left 14
                            )
                        )
                , min = 0
                , max = 100
                , step = Nothing
                , value = light.elevation
                , thumb =
                    Input.defaultThumb
                }
             , Input.sliderX
                [ behindContent
                    (el
                        [ width fill
                        , height (px 2)
                        , centerY
                        , Background.color (rgb 240 240 240)
                        , Border.rounded 2
                        ]
                        none
                    )
                , spacing 12
                ]
                { onChange = \hardness -> onChange { light | hardness = hardness }
                , label =
                    Input.labelAbove [Font.size 14]
                        (Element2.text
                            ("Hardness " ++ String.fromFloat light.hardness
                                |> String.left 14
                            )
                        )
                , min = 0
                , max = 50
                , step = Nothing
                , value = light.hardness
                , thumb =
                    Input.defaultThumb
                }

            ]

-- x y         blur      color
-- 0 2.74416px 2.74416px rgba(0,0,0,.0274351)
-- 0 5.48831px 5.48831px rgba(0,0,0,.0400741)
-- 0 13.7208px 10.9766px rgba(0,0,0,.0499982)
-- 0 20.5812px 20.5812px rgba(0,0,0,.0596004)
-- 0 41.1623px 41.1623px rgba(0,0,0,.0709366)
-- 0 96.0454px 89.1851px rgba(0,0,0,.09);