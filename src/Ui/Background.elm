module Ui.Background exposing
    ( color
    , gradient
    , gradients, Gradient, linear, conic, radial, circle, Step, px, percent
    , center, top, bottom, left, right, topLeft, topRight, bottomLeft, bottomRight, offset
    , image, uncropped, tiled, tiledX, tiledY
    )

{-|

@docs color

@docs gradient

@docs gradients, Gradient, linear, conic, radial, circle, Step, px, percent

@docs center, top, bottom, left, right, topLeft, topRight, bottomLeft, bottomRight, offset


# Images

@docs image, uncropped, tiled, tiledX, tiledY

**Note** if you want more control over a background image than is provided here, you should try just using a normal `Ui.image` with something like `Ui.behindContent`.

-}

import Html.Attributes as Attr
import Internal.Model2 as Two
import Internal.Style2 as Style
import Ui exposing (Angle, Attribute, Color)


{-| -}
color : Color -> Two.Attribute msg
color clr =
    Two.Attr
        (Attr.style "background-color"
            (Style.color clr)
        )


{-| Resize the image to fit the containing element while maintaining proportions and cropping the overflow.
-}
image : String -> Attribute msg
image src =
    Two.Attr
        (Attr.style "background"
            ("url(\"" ++ src ++ "\") center / cover no-repeat")
        )


{-| A centered background image that keeps its natural proportions, but scales to fit the space.
-}
uncropped : String -> Attribute msg
uncropped src =
    Two.Attr
        (Attr.style "background"
            ("url(\"" ++ src ++ "\") center / contain no-repeat")
        )


{-| Tile an image in the x and y axes.
-}
tiled : String -> Attribute msg
tiled src =
    Two.Attr
        (Attr.style "background"
            ("url(\"" ++ src ++ "\") center / repeat")
        )


{-| Tile an image in the x axis.
-}
tiledX : String -> Attribute msg
tiledX src =
    Two.Attr
        (Attr.style "background"
            ("url(\"" ++ src ++ "\") center / repeat-x")
        )


{-| Tile an image in the y axis.
-}
tiledY : String -> Attribute msg
tiledY src =
    Two.Attr
        (Attr.style "background"
            ("url(\"" ++ src ++ "\") center / repeat-y")
        )


type Step
    = Percent Int Color
    | Pixel Int Color


{-| -}
percent : Int -> Color -> Step
percent =
    Percent


{-| -}
px : Int -> Color -> Step
px =
    Pixel


{-| A linear gradient.

First you need to specify what direction the gradient is going by providing an angle in radians. `0` is up and `pi` is down.

The colors will be evenly spaced.

-}
gradient :
    Angle
    -> List Color
    -> Attribute msg
gradient angle steps =
    case steps of
        [] ->
            Two.NoAttribute

        [ clr ] ->
            Two.Attr
                (Attr.style "background-color"
                    (Style.color clr)
                )

        _ ->
            Two.Attr
                (Attr.style "background-image"
                    ("linear-gradient("
                        ++ ((String.fromFloat (Style.toRadians angle) ++ "rad")
                                :: List.map Style.color steps
                                |> String.join ", "
                           )
                        ++ ")"
                    )
                )


{-| -}
gradients : List Gradient -> Attribute msg
gradients grads =
    case grads of
        [] ->
            Two.NoAttribute

        _ ->
            Two.Attr
                (Attr.style "background-image"
                    (List.map toCssGradient grads
                        |> String.join ", "
                    )
                )


type Gradient
    = Linear Angle (List Step)
    | Radial Bool Anchor (List Step)
    | Conic Anchor Angle (List ( Angle, Color ))


toCssGradient : Gradient -> String
toCssGradient grad =
    case grad of
        Linear angle steps ->
            "repeating-linear-gradient("
                ++ ((String.fromFloat (Style.toRadians angle) ++ "rad")
                        :: List.map renderStep steps
                        |> String.join ", "
                   )
                ++ ")"

        Radial circle anchor steps ->
            "repeating-radial-gradient("
                ++ (if circle then
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
                ++ ((String.fromFloat (Style.toRadians angle) ++ "rad")
                        :: anchorToString anchor
                        :: List.map
                            (\( ang, clr ) ->
                                Style.color clr
                                    ++ " "
                                    ++ String.fromFloat
                                        (Style.toRadians ang)
                                    ++ "rad"
                            )
                            steps
                        |> String.join ", "
                   )
                ++ ")"


{-| -}
linear :
    Angle
    -> List Step
    -> Gradient
linear =
    Linear


{-| -}
renderStep : Step -> String
renderStep step =
    case step of
        Percent perc clr ->
            Style.color clr ++ " " ++ String.fromInt perc ++ "%"

        Pixel pixel clr ->
            Style.color clr ++ " " ++ String.fromInt pixel ++ "px"


{-| -}
conic : Anchor -> Angle -> List ( Angle, Color ) -> Gradient
conic =
    Conic


{-| -}
radial :
    Anchor
    -> List Step
    -> Gradient
radial =
    Radial False


{-| -}
circle :
    Anchor
    -> List Step
    -> Gradient
circle =
    Radial True


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
center : Anchor
center =
    Anchor CenterX CenterY 0 0


{-| -}
top : Anchor
top =
    Anchor CenterX Top 0 0


{-| -}
bottom : Anchor
bottom =
    Anchor CenterX Bottom 0 0


{-| -}
left : Anchor
left =
    Anchor Left CenterY 0 0


{-| -}
right : Anchor
right =
    Anchor Right CenterY 0 0


{-| -}
topLeft : Anchor
topLeft =
    Anchor Left Top 0 0


{-| -}
topRight : Anchor
topRight =
    Anchor Right Top 0 0


{-| -}
bottomLeft : Anchor
bottomLeft =
    Anchor Left Bottom 0 0


{-| -}
bottomRight : Anchor
bottomRight =
    Anchor Right Bottom 0 0


{-| -}
offset : Int -> Int -> Anchor -> Anchor
offset x y (Anchor ax ay _ _) =
    Anchor ax ay x y
