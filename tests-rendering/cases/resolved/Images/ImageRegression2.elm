module ImageRegression2 exposing (main)

{-| <https://github.com/mdgriffith/elm-ui/issues/228>
-}

import Element exposing (..)


main =
    Element.layout []
        (Element.row [ width fill, height fill, explain Debug.todo ]
            [ text "BEFORE"
            , image []
                { src = "https://placekitten.com/300/200"
                , description = "kitten"
                }
            , text "AFTER"
            ]
        )
