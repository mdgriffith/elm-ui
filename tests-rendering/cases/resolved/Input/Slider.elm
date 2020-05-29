module Slider exposing (main)

import Browser
import Element as Element exposing (Element)
import Element.Background as Background
import Element.Input as Input
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)


type alias Model =
    { rangeValue : Float }


initialModel : Model
initialModel =
    { rangeValue = 160.0 }


type Msg
    = UpdateRange Float


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateRange value ->
            { model | rangeValue = value }


viewModal =
    Element.el
        [ Element.width Element.fill
        , Element.height Element.fill
        , Element.paddingEach { top = 100, left = 0, bottom = 0, right = 0 }
        , Background.color <| Element.rgba 0 0 0 0.8
        ]
        (Element.el [] (Element.text "Hello Modal"))


view : Model -> Html Msg
view model =
    Element.layout
        [--Element.inFront viewModal
        ]
    <|
        Input.slider
            [ Element.width Element.fill
            , Element.behindContent <|
                Element.el
                    [ Element.width Element.fill
                    , Element.height (Element.px 2)
                    , Element.centerY
                    , Background.color (Element.rgb 0.5 0.5 0.5)
                    ]
                    Element.none
            ]
            { onChange = UpdateRange
            , label = Input.labelHidden ""
            , min = 60.0
            , max = 280.0
            , value = model.rangeValue
            , thumb = Input.defaultThumb
            , step = Just 1.0
            }


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
