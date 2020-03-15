module Main exposing (main)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Input as Input
import Html exposing (Html)
import Html.Events exposing (onClick)


type alias Model =
    String


type Msg
    = Type String


update : Msg -> Model -> Model
update msg model =
    case msg of
        Type s ->
            s


view : Model -> Html Msg
view model =
    Element.layout [] <|
        column [ width fill, height fill ]
            [ Input.multiline
                [ height (maximum 200 shrink)
                ]
                { onChange = Type
                , text = model
                , placeholder = Nothing
                , label = Input.labelAbove [] <| text "only one line!"
                , spellcheck = False
                }
            , Input.multiline []
                { onChange = Type
                , text = model
                , placeholder = Nothing
                , label = Input.labelAbove [] <| text "expanded to multi lines."
                , spellcheck = False
                }
            ]


main : Program () Model Msg
main =
    Browser.sandbox
        { init = "yes\nno\nmaybe"
        , view = view
        , update = update
        }


sscce : Element msg
sscce =
    Element.text "sscce"
