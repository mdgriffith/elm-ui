module Internal.Style2 exposing (..)

{-| This module is used to generate the actual base stylesheet for elm-ui.
-}

import Color
import Internal.Style.Generated as Gen


rules =
    Gen.stylesheet


classes =
    Gen.classes


vars =
    Gen.vars


type Angle
    = Angle Float


toRadians : Angle -> Float
toRadians (Angle r) =
    r


type alias Color =
    Color.Color


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
color colorDetails =
    Color.toCssString colorDetails


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



{- GRADIENTS -}


type Gradient
    = SingleColor Color
    | Linear Angle (List Step)
    | Radial Bool Anchor (List Step)
    | Conic Anchor Angle (List ( Angle, Color ))


type Step
    = Percent Int Color
    | Pixel Int Color


stepToColor : Step -> Color
stepToColor step =
    case step of
        Percent _ clr ->
            clr

        Pixel _ clr ->
            clr


{-| -}
type Anchor
    = Anchor AnchorX AnchorY Int Int


type AnchorX
    = CenterX
    | Left
    | Right


type AnchorY
    = CenterY
    | Top
    | Bottom


toCssGradient : Gradient -> String
toCssGradient grad =
    case grad of
        SingleColor clr ->
            color clr

        Linear angle steps ->
            "linear-gradient("
                ++ ((String.fromFloat (toRadians angle) ++ "rad")
                        :: List.map renderStep steps
                        |> String.join ", "
                   )
                ++ ")"

        Radial isCircle anchor steps ->
            "repeating-radial-gradient("
                ++ (if isCircle then
                        "circle at "

                    else
                        "ellipse at "
                   )
                ++ (anchorToString anchor
                        :: List.map renderStep steps
                        |> String.join ", "
                   )
                ++ ")"

        Conic anchor angle steps ->
            "repeating-conic-gradient("
                ++ ((String.fromFloat (toRadians angle) ++ "rad")
                        :: anchorToString anchor
                        :: List.map
                            (\( ang, clr ) ->
                                color clr
                                    ++ " "
                                    ++ String.fromFloat
                                        (toRadians ang)
                                    ++ "rad"
                            )
                            steps
                        |> String.join ", "
                   )
                ++ ")"


anchorToString : Anchor -> String
anchorToString anchor =
    case anchor of
        Anchor CenterX CenterY 0 0 ->
            "center"

        Anchor anchorX anchorY x y ->
            anchorXToString anchorX x
                ++ " "
                ++ anchorYToString anchorY y


anchorXToString : AnchorX -> Int -> String
anchorXToString anchorX x =
    case anchorX of
        CenterX ->
            "left calc(50% + " ++ String.fromInt x ++ "px)"

        Left ->
            "left"

        Right ->
            "right"


anchorYToString : AnchorY -> Int -> String
anchorYToString anchorY y =
    case anchorY of
        CenterY ->
            "top calc(50% - " ++ String.fromInt y ++ "px)"

        Top ->
            "top "
                ++ (String.fromInt y ++ "px")

        Bottom ->
            "bottom "
                ++ (String.fromInt y ++ "px")


{-| -}
renderStep : Step -> String
renderStep step =
    case step of
        Percent perc clr ->
            color clr ++ " " ++ String.fromInt perc ++ "%"

        Pixel pixel clr ->
            color clr ++ " " ++ String.fromInt pixel ++ "px"
