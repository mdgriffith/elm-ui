module ImageSizing exposing (main)

{-| <https://github.com/mdgriffith/elm-ui/issues/62>
-}

import Element as E exposing (column, el, px, row, text)
import Element.Border as Border
import Element.Font as Font
import Html exposing (Html)


main : Html ()
main =
    E.layout [ E.height E.fill, Border.width 5, E.explain Debug.todo ] <|
        E.image
            [ -- E.height (E.px 500)
              -- ,
              -- E.width E.fill
              E.height E.fill
            ]
            -- <| px 500 ]
            { src = "http://bburdette.github.io/music-reader.png"
            , description = "music-reader screenshot"
            }
