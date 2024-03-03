module Input.Text exposing (main)

{-| -}

import Browser
import Html exposing (Html)
import Html.Attributes as Attr
import Theme
import Ui
import Ui.Font
import Ui.Input
import Ui.Prose


main =
    Browser.document
        { init = \() -> ( { text = "" }, Cmd.none )
        , update = update
        , view =
            \model ->
                { title = "pls"
                , body = [ view model ]
                }
        , subscriptions = \_ -> Sub.none
        }


update msg model =
    case msg of
        TextUpdated text ->
            ( { model | text = text }, Cmd.none )


type Msg
    = TextUpdated String


view model =
    Ui.layout
        [ Ui.Font.family [ Ui.Font.typeface "Garamond EB" ]
        ]
        (Ui.column
            [ Ui.width (Ui.px 600)
            , Ui.centerX
            , Ui.height Ui.fill
            , Ui.paddingXY 0 100
            , Ui.spacing 100
            ]
            [ Theme.h1 "Text"
            , Ui.Input.multiline
                [ Ui.border 5
                , Ui.borderColor (Ui.rgba 0 0 0 1)
                , Ui.rounded 10
                , Ui.height Ui.fill
                ]
                { onChange = TextUpdated
                , text = model.text
                , spellcheck = False
                , placeholder = Just "Type something here..."
                , label =
                    Ui.Input.labelHidden "Type something here..."
                }
            ]
        )
