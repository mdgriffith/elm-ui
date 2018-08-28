module Testable.Element.Font exposing (color)

{-| -}

import Dict
import Element exposing (Color)
import Element.Font as Font
import Expect
import Testable


color : Color -> Testable.Attr msg
color clr =
    Testable.LabeledTest
        { label = "font color-" ++ Testable.formatColor clr
        , attr = Font.color clr
        , test =
            \context _ ->
                let
                    selfFontColor =
                        context.self.style
                            |> Dict.get "color"
                            |> Maybe.withDefault "notfound"
                in
                Expect.true ("Color Match - " ++ (Testable.formatColor clr ++ " vs " ++ selfFontColor))
                    (Testable.compareFormattedColor clr selfFontColor)
        }


size : Int -> Testable.Attr msg
size i =
    Testable.LabeledTest
        { label = "font size-" ++ String.fromInt i
        , attr = Font.size i
        , test =
            \context _ ->
                let
                    selfFontSize =
                        context.self.style
                            |> Dict.get "fontsize"
                            |> Maybe.withDefault "notfound"

                    formattedInt =
                        String.fromInt i
                in
                Expect.true ("Size Match - " ++ (formattedInt ++ " vs " ++ selfFontSize))
                    (formattedInt == selfFontSize)
        }
