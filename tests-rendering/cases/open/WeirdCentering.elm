module WeirdCentering exposing (view)

import Testable.Element exposing (..)
import Testable.Element.Background as Background


view =
    layout [] <|
        column []
            [ text "Example with centerX:"
            , row
                [ width fill ]
                [ row
                    [ centerX
                    , Background.color <| rgb 0 1 0
                    ]
                    [ paragraph
                        [ width shrink
                        ]
                        [ text "Hello world" ]
                    , paragraph
                        [ width shrink
                        ]
                        [ text "Hello world" ]
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
