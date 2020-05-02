module WeirdCentering exposing (main)

import Html exposing (Html)
import Testable.Element exposing (..)
import Testable.Element.Background as Background


main =
    layout [] <|
        column []
            [ text "Example with centerX:"
            , row
                [ width fill ]
                [ row [ centerX, Background.color <| rgb 0 1 0 ]
                    [ paragraph [ width shrink ] [ text "Hello world" ]
                    , paragraph [ width shrink ] [ text "Hello world" ]
                    ]
                ]
            , text "Example without centerX:"
            , row
                [ width fill ]
                [ row [ Background.color <| rgb 0 1 0 ]
                    [ paragraph [ width shrink ] [ text "Hello world" ]
                    , paragraph [ width shrink ] [ text "Hello world" ]
                    ]
                ]
            ]
