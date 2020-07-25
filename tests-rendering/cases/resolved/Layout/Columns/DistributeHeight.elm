module DistributeHeight exposing (main)

import Browser
import Element exposing (column, el, fill, fillPortion, height, minimum, none, px, rgb, row, text, width)
import Element.Background as Bg
import Html as Html exposing (Html)


type alias Model =
    ()


update : msg -> Model -> Model
update _ model =
    model


view : model -> Html msg
view _ =
    Element.layout [ height fill, width fill ] <|
        column [ height fill, width fill ]
            [ row
                [ height
                    fill
                , width fill
                , Bg.color <| rgb 1 0 0
                ]
                [ el
                    [ height <| px 200
                    , width fill
                    , Bg.color <| rgb 1 0 1
                    ]
                    (text "Helloooo!")
                ]
            , row [ height fill, width fill, Bg.color <| rgb 0 1 0 ]
                [ none ]
            ]


main : Program () Model msg
main =
    Browser.sandbox
        { init = ()
        , view = view
        , update = update
        }
