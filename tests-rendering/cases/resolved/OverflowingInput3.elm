module Main exposing (main)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)


type alias Model =
    { count : Int }


initialModel : Model
initialModel =
    { count = 0 }


type Msg
    = Increment
    | Decrement


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            { model | count = model.count + 1 }

        Decrement ->
            { model | count = model.count - 1 }


blue =
    rgb 0 0 1


red =
    rgb 1 0 0


view : Model -> Html Msg
view model =
    layout [ width fill, padding 5 ] <|
        column [ width fill, spacing 10 ]
            [ row [ width fill, height <| px 100 ]
                [ link [ height fill, width <| fillPortion 1, Background.color blue ]
                    { url = "https://github.com/mdgriffith/elm-ui/issues"
                    , label = paragraph [ Font.center ] [ text "Hello!" ]
                    }
                , el [ height fill, width <| fillPortion 2, Background.color red ] none
                ]
            , row [ width fill, height <| px 100 ]
                [ el [ height fill, width <| fillPortion 1, Background.color blue ] (text "Hello!")
                , el [ height fill, width <| fillPortion 2, Background.color red ] none
                ]
            ]


button : String -> Element Msg
button label =
    el
        [ Border.rounded 2
        , Border.width 1
        , Border.color black
        , Background.color white
        , Font.color black
        , padding 5
        , mouseOver
            [ Font.color white
            , Background.color black
            ]
        ]
        (text label)


black : Color
black =
    rgb 0 0 0


white : Color
white =
    rgb 255 255 255


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
