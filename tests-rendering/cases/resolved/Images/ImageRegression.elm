module ImageRegression exposing (main)

{-| <https://github.com/mdgriffith/elm-ui/issues/232>
-}

import Browser
import Element exposing (Element, centerX, clipX, el, image, px, rgb255, row, shrink, width)
import Element.Background as Background
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)


type alias Model =
    Int


type Msg
    = NoOp


update : Msg -> Model -> Model
update msg model =
    model


view : Model -> Html Msg
view model =
    Element.layout [] <|
        row
            [ centerX
            , width shrink
            , Background.color <| rgb255 255 255 255
            ]
            [ viewCard "qs" True
            , viewCard "ah" False
            ]


main : Program () Model Msg
main =
    Browser.sandbox
        { init = 0
        , view = view
        , update = update
        }


viewCard : String -> Bool -> Element Msg
viewCard card bool =
    let
        source =
            "https://hearts-bawolk.herokuapp.com/static/cards/" ++ card ++ ".png"

        overlapStyles =
            if bool then
                [ width (px 50)
                , clipX
                ]

            else
                []
    in
    el overlapStyles (image [] { src = source, description = "" })
