module Testable.Element.Font exposing (bold, color, size)

{-| -}

import Dict
import Element exposing (Color)
import Element.Font as Font
import Testable


bold : Testable.Attr msg
bold =
    Testable.Attr Font.bold


color : Color -> Testable.Attr msg
color clr =
    Testable.LabeledTest
        { label = "font color-" ++ Testable.formatColor clr
        , attr = Font.color clr
        , id = Testable.NoId
        , test =
            \context ->
                let
                    selfFontColor =
                        context.self.style
                            |> Dict.get "color"
                            |> Maybe.withDefault "notfound"
                in
                [ Testable.true ("Color Match - " ++ (Testable.formatColor clr ++ " vs " ++ selfFontColor))
                    (Testable.compareFormattedColor clr selfFontColor)
                ]
        }


size : Int -> Testable.Attr msg
size i =
    Testable.LabeledTest
        { label = "font size-" ++ String.fromInt i
        , attr = Font.size i
        , id = Testable.NoId
        , test =
            \context ->
                let
                    selfFontSize =
                        context.self.style
                            |> Dict.get "fontsize"
                            |> Maybe.withDefault "notfound"

                    formattedInt =
                        String.fromInt i
                in
                [ Testable.true ("Size Match - " ++ (formattedInt ++ " vs " ++ selfFontSize))
                    (formattedInt == selfFontSize)
                ]
        }
