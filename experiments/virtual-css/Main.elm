module Main exposing (main)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Events as Events
import Element.Font as Font
import Html
import Internal.Model as Internal


main =
    Browser.sandbox
        { init = 0
        , update = update
        , view = view
        }


update msg model =
    case msg of
        Click ->
            model + 1


type Msg
    = Click


view model =
    Element.layoutWith
        { options =
            [ Internal.RenderModeOption
                Internal.WithVirtualCss
            ]
        }
        [ Events.onClick Click ]
        (el
            [ padding 10
            , Background.color (rgb 0 0 0.8)
            , Font.color (rgb 1 1 1)
            , centerX
            , centerY
            ]
            (text ("hello!" ++ String.fromInt model))
        )
