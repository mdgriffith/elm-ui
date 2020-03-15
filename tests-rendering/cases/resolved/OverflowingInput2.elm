module Main exposing (main)

import Browser
import Element
import Element.Background as Background
import Element.Input as Input
import Html exposing (Html)


type alias Model =
    {}


type Msg
    = TextUpdated String


update : Msg -> Model -> Model
update msg model =
    case msg of
        TextUpdated _ ->
            model


view : Model -> Html Msg
view model =
    Element.layout
        []
        (Element.row
            [ Element.width (Element.px 100)
            , Element.padding 10
            , Background.color (Element.rgb 1 0 0)
            ]
            [ Input.text
                [ Element.width (Element.fillPortion 2)

                --   Element.width Element.fill
                ]
                { onChange = TextUpdated
                , text = ""
                , placeholder = Nothing
                , label = Input.labelHidden ""
                }
            ]
        )


main : Program () Model Msg
main =
    Browser.sandbox
        { init = {}
        , view = view
        , update = update
        }
