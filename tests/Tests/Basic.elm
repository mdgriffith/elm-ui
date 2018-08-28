module Tests.Basic exposing (view)

{-| -}

import Element as Actual
import Html
import Testable
import Testable.Element as Element exposing (..)
import Testable.Element.Background as Background
import Testable.Element.Font as Font
import Testable.Runner
import Tests.Palette as Palette


{-| -}
main : Html.Html msg
main =
    Testable.Runner.show view


{-| -}
view : Testable.Element msg
view =
    row [ spacing 50, alignTop ]
        [ el
            [ width (px 200)
            , height (px 200)
            , Background.color Palette.blue
            , Font.color Palette.white
            ]
            (text "Hello!")
        , el
            [ width (px 200)
            , height (px 200)
            , Background.color Palette.blue
            , Font.color Palette.white
            ]
            (text "Hello!")
        , el
            [ width (px 200)
            , height (px 200)
            , Background.color (Actual.rgba 0 0 1 1)
            , Font.color Palette.white
            , below
                (el
                    [ Background.color Palette.grey
                    , width (px 50)
                    , height (px 50)
                    ]
                    none
                )
            ]
            (text "Hello!")
        ]
