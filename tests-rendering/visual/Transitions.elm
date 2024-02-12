module Transitions exposing (main)

{-| -}

import Browser
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode
import Theme
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
    | Log String


type Focus
    = Mini
    | Detail


update msg model =
    case Debug.log "MSG" msg of
        Ui uiMsg ->
            let
                ( newUI, cmd ) =
                    Ui.Anim.update Ui uiMsg model.ui
            in
            ( { model | ui = newUI }
            , cmd
            )

        Log str ->
            ( model, Cmd.none )

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

        -- , Ui.Events.onClick
        --     (Focus
        --         (case model.focus of
        --             Detail ->
        --                 Mini
        --             Mini ->
        --                 Detail
        --         )
        --     )
        ]
        (column [ spacing 64, centerX, centerY ]
            [ row
                [ spacing 64
                , height fill
                ]
                [ box
                , box
                ]
            , row
                [ spacing 64
                , height fill
                ]
                [ boxLooping
                , boxLooping
                ]
            , row
                [ spacing 64
                , height fill
                ]
                [ boxSpinning
                , boxSpinning
                ]
            ]
        )


box : Ui.Element Msg
box =
    Ui.el
        [ Theme.palette.pink
        , Ui.width (Ui.px 100)
        , Ui.height (Ui.px 100)
        , Ui.Anim.hovered (Ui.Anim.ms 500)
            [ Ui.Anim.backgroundColor Theme.black
            ]
        , Ui.Events.onClick (Log "Clicked")
        ]
        Ui.none


boxLooping : Ui.Element msg
boxLooping =
    Ui.el
        [ Theme.palette.pink
        , Ui.width (Ui.px 100)
        , Ui.height (Ui.px 100)
        , Ui.Anim.keyframes
            [ Ui.Anim.loop
                [ Ui.Anim.set
                    [ Ui.Anim.backgroundColor Theme.pink ]
                , Ui.Anim.step (Ui.Anim.ms 500)
                    [ Ui.Anim.backgroundColor Theme.black ]
                , Ui.Anim.step (Ui.Anim.ms 500)
                    [ Ui.Anim.backgroundColor Theme.pink ]
                ]
            ]
        ]
        Ui.none


boxSpinning : Ui.Element msg
boxSpinning =
    Ui.el
        [ Theme.palette.pink
        , Ui.width (Ui.px 100)
        , Ui.height (Ui.px 100)
        , Ui.Anim.keyframes
            [ Ui.Anim.loop
                [ Ui.Anim.set
                    [ Ui.Anim.rotation 0 ]
                , Ui.Anim.step (Ui.Anim.ms 2000)
                    [ Ui.Anim.rotation 1 ]
                ]
            ]
        ]
        Ui.none
