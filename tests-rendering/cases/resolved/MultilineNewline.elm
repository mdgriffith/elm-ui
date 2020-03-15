module Main exposing (main)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Events


type alias Model =
    { content : String }


initialModel : Model
initialModel =
    { content = "" }


type Msg
    = ContentChanged String


update : Msg -> Model -> Model
update msg model =
    case msg of
        ContentChanged str ->
            { model | content = str }


view : Model -> Html Msg
view model =
    Element.layout [ Font.color (rgb 1 0 0) ]
        (viewInput model)


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }


viewInput model =
    Input.multiline
        [ padding 50
        , height (shrink |> maximum 300)
        , width fill
        , centerX
        , centerY
        ]
        { onChange = ContentChanged
        , text = model.content
        , placeholder = Just (Input.placeholder [] (text "Write your novel, dummy!"))
        , label = Input.labelAbove [] (text "My Input")
        , spellcheck = False
        }
