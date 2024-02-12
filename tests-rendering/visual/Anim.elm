module Anim exposing (main)

{-| -}

import Browser
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode
import Ui exposing (..)
import Ui.Anim
import Ui.Events
import Ui.Font
import Ui.Gradient
import Ui.Input
import Ui.Keyed
import Ui.Layout
import Ui.Lazy
import Ui.Responsive


on str decoder =
    htmlAttribute <| Events.on str decoder


main =
    Browser.document
        { init = init
        , view =
            \model ->
                { title = "Transitions"
                , body = [ view model ]
                }
        , update = update
        , subscriptions = \_ -> Sub.none
        }


init () =
    ( { focus = Detail
      , ui = Ui.Anim.init
      , checked = False
      , email = ""
      }
    , Cmd.none
    )


type Id
    = One Int


id val =
    case val of
        One i ->
            Ui.Anim.persistent "one" (String.fromInt i)


type Msg
    = Ui Ui.Anim.Msg
    | Focus Focus


type Focus
    = Mini
    | Detail


update msg model =
    case msg of
        Ui uiMsg ->
            let
                ( newUI, cmd ) =
                    Ui.Anim.update Ui uiMsg model.ui
            in
            ( { model | ui = newUI }
            , cmd
            )

        Focus focus ->
            ( { model | focus = focus }
            , Cmd.none
            )


type Breakpoints
    = Small
    | Medium
    | Large


breakpoints =
    Ui.Responsive.breakpoints Small
        [ ( 1200, Medium )
        , ( 2400, Large )
        ]


view model =
    Ui.Anim.layout
        { options = []
        , toMsg = Ui
        , breakpoints = Just breakpoints
        }
        model.ui
        [ Ui.Font.italic
        , Ui.Font.size 32
        , Ui.Font.gradient
            (Ui.Gradient.linear (Ui.turns 0)
                [ Ui.Gradient.percent 0 (rgb 0 255 255)
                , Ui.Gradient.percent 20 (rgb 255 255 255)
                , Ui.Gradient.percent 100 (rgb 255 255 255)
                ]
            )
        , Ui.Font.color (rgb 0 0 0)
        , Ui.Font.font
            { name = "EB Garamond"
            , fallback = [ Ui.Font.serif ]
            , variants =
                []
            , weight = Ui.Font.regular
            , size = 16
            , lineSpacing = 4
            , capitalSizeRatio = 0.7
            }
        , Ui.Events.onClick
            (Focus
                (case model.focus of
                    Detail ->
                        Mini

                    Mini ->
                        Detail
                )
            )
        ]
        (row
            [ centerX
            , spacing 64
            , height fill
            ]
            [ row [ height (px 800), width (px 500) ]
                [ if model.focus == Mini then
                    viewData model.focus

                  else
                    none
                ]
            , row [ height (px 800), width (px 500), padding 80, spacing 10 ]
                [ if model.focus == Detail then
                    viewData model.focus

                  else
                    none
                , text "yooo"
                ]
            ]
        )


viewData : Focus -> Ui.Element Msg
viewData focus =
    case focus of
        Mini ->
            el
                [ id (One 0)
                , width fill
                , padding 24
                , Ui.background (rgb 255 255 255)
                , Ui.rounded 3
                , Ui.border 3
                , Ui.borderColor (rgb 0 0 0)
                ]
                (text "Mini")

        Detail ->
            column
                [ id (One 1)
                , width fill
                , height fill
                , padding 24
                , Ui.background (rgb 0 255 255)
                , Ui.rounded 3
                ]
                [ el [] (text "Details")
                , el [] (text "so many details")
                ]
