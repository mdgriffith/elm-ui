module Transition exposing (..)

{-| -}

import Browser
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode
import Ui exposing (..)
import Ui.Anim
import Ui.Background as Background
import Ui.Border as Border
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
      }
    , Cmd.none
    )


type Id
    = One Int


id val =
    case val of
        One i ->
            Ui.Anim.persistent Ui "one" (String.fromInt i)


type Msg
    = Ui (Ui.Anim.Msg Msg)
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
    Ui.Responsive.layout
        { options = []
        , breakpoints = breakpoints
        }
        model.ui
        [ Ui.Font.italic
        , Ui.Font.size 32
        , Ui.Font.gradient
            (Ui.Gradient.linear Ui.right
                [ Ui.Gradient.percent 0 (rgb 0 255 255)
                , Ui.Gradient.percent 20 (rgb 255 255 255)
                , Ui.Gradient.percent 100 (rgb 255 255 255)
                ]
            )
        , Ui.Font.font
            { name = "EB Garamond"
            , fallback = [ Ui.Font.serif ]
            , sizing =
                Ui.Font.byCapital
                    { offset = 0.045
                    , height = 0.73
                    }
            , variants =
                []
            , weight = Ui.Font.regular
            , size = 16
            }
        , Ui.Events.onClick
            (Ui.Anim.withTransition Ui
                (Focus
                    (case model.focus of
                        Detail ->
                            Mini

                        Mini ->
                            Detail
                    )
                )
            )
        ]
        (row
            [ centerX
            , spacing 64
            , height fill
            ]
            [ row [ height (px 800), width (px 500), explain Debug.todo ]
                [ if model.focus == Mini then
                    viewData model.focus

                  else
                    none
                ]
            , row [ height (px 800), width (px 500), padding 80, spacing 10, explain Debug.todo ]
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
