module Internal.Style2 exposing (..)

{-| This module is used to generate the actual base stylesheet for elm-ui.
-}

import Internal.Style.Generated as Gen


rules =
    Gen.stylesheet


classes =
    Gen.classes


vars =
    Gen.vars


type Color
    = Rgb Int Int Int


{--}
set : Gen.Var -> String -> String
set (Gen.Var v) val =
    "--" ++ v ++ ":" ++ val ++ ";"


{-| TODO: a compact quad here is actually two numbers where we extract 4 numbers.

We're treatnig each as two numbers, each with an accuracy of 16bits.

-}
compactQuad : Int -> Int -> String
compactQuad x y =
    px y ++ " " ++ px x


color : Color -> String
color (Rgb red green blue) =
    "rgb("
        ++ String.fromInt red
        ++ ("," ++ String.fromInt green)
        ++ ("," ++ String.fromInt blue)
        ++ ")"


pair : String -> String -> String
pair one two =
    one ++ " " ++ two


triple : String -> String -> String -> String
triple one two three =
    one ++ " " ++ two ++ " " ++ three


quad : String -> String -> String -> String -> String
quad one two three four =
    one ++ " " ++ two ++ " " ++ three ++ " " ++ four


pent : String -> String -> String -> String -> String -> String
pent one two three four five =
    one ++ " " ++ two ++ " " ++ three ++ " " ++ four ++ " " ++ five


prop : String -> String -> String
prop name val =
    name ++ ":" ++ val ++ ";"


px : Int -> String
px x =
    String.fromInt x ++ "px"


floatPx : Float -> String
floatPx x =
    String.fromFloat x ++ "px"


rad : Float -> String
rad x =
    String.fromFloat x ++ "rad"


type alias Shadow =
    { x : Float
    , y : Float
    , size : Float
    , blur : Float
    , color : Color
    }


innerShadows : List Shadow -> String
innerShadows shades =
    List.foldl joinInnerShadows "" shades


joinInnerShadows shadow rendered =
    if String.isEmpty rendered then
        "inset " ++ singleShadow shadow

    else
        rendered ++ ", inset" ++ singleShadow shadow


shadows : List Shadow -> String
shadows shades =
    List.foldl joinShadows "" shades


joinShadows shadow rendered =
    if String.isEmpty rendered then
        singleShadow shadow

    else
        rendered ++ "," ++ singleShadow shadow


singleShadow : Shadow -> String
singleShadow shadow =
    pent
        (floatPx shadow.x)
        (floatPx shadow.y)
        (floatPx shadow.blur)
        (floatPx shadow.size)
        (color shadow.color)
