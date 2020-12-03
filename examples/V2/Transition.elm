module Transition exposing (..)

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



main =
    Browser.document
        { init = init
        , view = 
            \model -> 
                { title = "Transitions"
                , body = [view model]
                }
        , update = update
        , subscriptions = \_ -> Sub.none
        }

init () = 
    ({ focus = Detail
    , ui = Element2.init
    }, Cmd.none)



type Id = One Int




id val =
    case val of 
        One i ->
            Animated.id UI "one" (String.fromInt i)




type Msg 
    = UI (Element2.Msg Msg)
    | Focus Focus


type Focus = Mini | Detail

update msg model =
    case msg of
        UI uiMsg ->
            let 
                (newUI, cmd) = Element2.update UI uiMsg model.ui
            in
            ({ model | ui = newUI }
            , cmd
            )

        Focus focus ->
             ({model | focus = focus }
             , Cmd.none
             )

      
view model =
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
        , Element2.Events.onClick 
            (Element2.transition UI 
                (Focus 
                    (case model.focus of 
                        Detail -> Mini
                        Mini -> Detail
                    )
                )
            )
        ]
        (row 
            [ centerX
            
            , spacing 64 
            , height fill
            
            ]
            [ row [height fill, width (px 500)] 
                [ if model.focus == Mini then
                    viewData model.focus
                else 
                    none
                ]
            , row [height fill, width (px 500), padding 80, spacing 200] 
                [ if model.focus == Detail then
                    viewData model.focus
                else 
                    none
                , text "yooo"
                ]


            ]
        )



viewData : Focus ->  Element Msg
viewData focus  =
    case focus of 
        Mini ->
            el 
                [ id (One 0)
                , width fill
                , padding 24 
                , Background.color (rgb 255 255 255)
                , Border.rounded 3
                , Border.width 3
                , Border.dashed
                ]
                (text "Mini")

        Detail ->
            column
                [ id (One 1)
                , width fill
                , height fill
                , padding 24 
                , Background.color (rgb 0 255 255)
                , Border.rounded 3
                ]
                [ el [] (text "Details")
                , el [] (text "so many details")
                ]


