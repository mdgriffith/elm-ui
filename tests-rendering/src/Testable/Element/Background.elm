module Testable.Element.Background exposing (color)

{-| -}

import Dict
import Element exposing (Color)
import Element.Background as Background
import Testable


color : Color -> Testable.Attr msg
color clr =
    Testable.LabeledTest
        { label = "background color"
        , attr = Background.color clr
        , id = Testable.NoId
        , test =
            \context ->
                let
                    selfBackgroundColor =
                        context.self.style
                            |> Dict.get "background-color"
                            |> Maybe.withDefault "notfound"
                in
                [ Testable.true ("expected " ++ (Testable.formatColor clr ++ ", found " ++ selfBackgroundColor))
                    (Testable.compareFormattedColor clr selfBackgroundColor)
                ]
        }
