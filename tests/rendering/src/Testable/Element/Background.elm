module Testable.Element.Background exposing (color)

{-| -}

import Dict
import Element exposing (Color)
import Element.Background as Background
import Expect
import Testable


color : Color -> Testable.Attr msg
color clr =
    Testable.LabeledTest
        { label = "background color-" ++ Testable.formatColor clr
        , attr = Background.color clr
        , test =
            \context _ ->
                let
                    selfBackgroundColor =
                        context.self.style
                            |> Dict.get "background-color"
                            |> Maybe.withDefault "notfound"
                in
                Expect.true ("Expected color: " ++ (Testable.formatColor clr ++ " vs found:" ++ selfBackgroundColor))
                    (Testable.compareFormattedColor clr selfBackgroundColor)
        }
