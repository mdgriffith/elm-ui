module Main exposing (main)

import Browser
import Element



{- Broken in chrome -}


main =
    Element.layout
        [ Element.inFront
            (Element.column []
                [ Element.column []
                    [ Element.text "1"
                    , Element.text "2"
                    , Element.text "3"
                    ]
                , Element.column []
                    [ Element.text "4"
                    , Element.text "5"
                    , Element.text "6"
                    ]
                , Element.column []
                    [ Element.text "7"
                    , Element.text "8"
                    , Element.text "9"
                    ]
                ]
            )
        ]
        Element.none
