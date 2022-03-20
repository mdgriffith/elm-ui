module BasicWithNonce exposing (..)

{-| -}

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input
import Element.Lazy


main =
    Element.layoutWith
        { options = [ Element.nonce "12345" ]
        }
        [ Background.color (rgba 0 0 0 1)
        , Font.color (rgba 1 1 1 1)
        , Font.italic
        , Font.size 32
        , Font.family
            [ Font.external
                { url = "https://fonts.googleapis.com/css?family=EB+Garamond"
                , name = "EB Garamond"
                }
            , Font.sansSerif
            ]
        ]
    <|
        Element.column [ centerX, centerY ]
            [ el
                []
                (text "Hello stylish friend!")
            , Element.Lazy.lazy viewSignature "Matt"
            ]


viewSignature : String -> Element msg
viewSignature name =
    el
        []
        (text ("— " ++ name))
