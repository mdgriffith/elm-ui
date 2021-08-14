module Tests.Manual.Regions exposing (..)

import Browser
import Element exposing (..)
import Element.Region as Region
import Html
import Html.Attributes


type alias Model =
    {}


init : () -> ( Model, Cmd Msg )
init flags =
    ( {}, Cmd.none )


type Msg
    = NoOp


update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


header =
    el [ Region.header ] (el [ Region.heading 1 ] (text "This is a h1 in a header"))


view model =
    Element.layout [] (Element.column [] [ header ])


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
