module Main exposing (main)

import Browser
import Element exposing (..)
import Element.Input exposing (labelLeft, multiline)
import Html exposing (Html)
import Html.Events exposing (onClick)


type alias Model =
    { count : Int }


initialModel : Model
initialModel =
    { count = 0 }


type Msg
    = Increment
    | Decrement
    | MLChanged String


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            { model | count = model.count + 1 }

        Decrement ->
            { model | count = model.count - 1 }

        MLChanged s ->
            model


testtxt =
    "orem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.  Why do we use it?"


testtxtnewlines =
    """orem Ipsum is simply dummy text of the printing 
and typesetting industry. Lorem Ipsum has been the industry's 
standard dummy text ever since the 1500s, when an unknown 
printer took a galley of type and scrambled it to make a type specimen book. 
It has survived not only five centuries, but also the leap into electronic 
typesetting
, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.  Why do we use it?"""


view : Model -> Html Msg
view model =
    layout [] <|
        column
            [ width (px 500)
            , spacing 50
            ]
            [ multiline []
                { onChange = MLChanged
                , text = testtxt
                , placeholder = Nothing
                , spellcheck = False
                , label = labelLeft [ width (px 200) ] <| text "Default height"
                }
            , multiline [ height shrink ]
                { onChange = MLChanged
                , text = testtxt
                , placeholder = Nothing
                , spellcheck = False
                , label = labelLeft [ width (px 200) ] <| text "Shrink - no nl"
                }
            , multiline [ height shrink ]
                { onChange = MLChanged
                , text = testtxtnewlines
                , placeholder = Nothing
                , spellcheck = False
                , label = labelLeft [ width (px 200) ] <| text "Shrink - w/nl"
                }
            ]


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
