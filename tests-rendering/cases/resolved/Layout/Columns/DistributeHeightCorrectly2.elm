module Other exposing (main)

import Browser
import Element exposing (..)
import Element.Border as Border
import Element.Events as Events
import Html exposing (Html)
import Html.Attributes


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


view : Model -> Html Msg
view model =
    viewElements model
        |> layout []


viewElements : Model -> Element Msg
viewElements model =
    el [ height fill ] <|
        column [ height fill ]
            [ el
                [ height (fillPortion 1)
                ]
              <|
                viewCounter model
            , el
                [ height (fillPortion 2)
                ]
              <|
                viewCounters model
            ]


flexBasisZero : Element.Attribute msg
flexBasisZero =
    htmlAttribute (Html.Attributes.style "flex-basis" "0")


viewCounters : Model -> Element Msg
viewCounters model =
    column [ height fill ]
        (List.repeat model.count model
            |> List.map viewCounter
        )


viewCounter : Model -> Element Msg
viewCounter model =
    column [ width fill, height fill, Border.width 1, Border.dotted ]
        [ el [ Events.onClick Increment, Border.width 1, Border.rounded 3 ] <| text "+1"
        , el [] <| text <| String.fromInt model.count
        , el [ Events.onClick Decrement, Border.width 1, Border.rounded 3 ] <| text "-1"
        ]


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
