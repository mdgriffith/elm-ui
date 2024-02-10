module Ui.Gradient exposing
    ( color
    , Gradient, linear, conic, radial, circle
    , Step, px, percent
    , center, top, bottom, left, right, topLeft, topRight, bottomLeft, bottomRight, offset
    )

{-|

@docs color

@docs Gradient, linear, conic, radial, circle

@docs Step, px, percent

@docs center, top, bottom, left, right, topLeft, topRight, bottomLeft, bottomRight, offset

-}

import Internal.Style2 as Style
import Ui exposing (Angle, Color)


{-| -}
type alias Gradient =
    Style.Gradient


{-| -}
type alias Step =
    Style.Step


{-| -}
color : Color -> Gradient
color =
    Style.SingleColor


{-| -}
percent : Int -> Color -> Step
percent =
    Style.Percent


{-| -}
px : Int -> Color -> Step
px =
    Style.Pixel


{-| -}
linear :
    Angle
    -> List Step
    -> Gradient
linear angle steps =
    case steps of
        [ single ] ->
            color (Style.stepToColor single)

        _ ->
            Style.Linear angle steps


{-| -}
conic : Anchor -> Angle -> List ( Angle, Color ) -> Gradient
conic anchor angle steps =
    case steps of
        [ ( _, single ) ] ->
            color single

        _ ->
            Style.Conic anchor angle steps


{-| -}
radial :
    Anchor
    -> List Step
    -> Gradient
radial anchor steps =
    case steps of
        [ single ] ->
            color (Style.stepToColor single)

        _ ->
            Style.Radial False anchor steps


{-| This is _also_ a type of radial gradient, but where the base is circular instead of elliptical.
-}
circle :
    Anchor
    -> List Step
    -> Gradient
circle =
    Style.Radial True


{-| -}
type alias Anchor =
    Style.Anchor


{-| -}
center : Anchor
center =
    Style.Anchor Style.CenterX Style.CenterY 0 0


{-| -}
top : Anchor
top =
    Style.Anchor Style.CenterX Style.Top 0 0


{-| -}
bottom : Anchor
bottom =
    Style.Anchor Style.CenterX Style.Bottom 0 0


{-| -}
left : Anchor
left =
    Style.Anchor Style.Left Style.CenterY 0 0


{-| -}
right : Anchor
right =
    Style.Anchor Style.Right Style.CenterY 0 0


{-| -}
topLeft : Anchor
topLeft =
    Style.Anchor Style.Left Style.Top 0 0


{-| -}
topRight : Anchor
topRight =
    Style.Anchor Style.Right Style.Top 0 0


{-| -}
bottomLeft : Anchor
bottomLeft =
    Style.Anchor Style.Left Style.Bottom 0 0


{-| -}
bottomRight : Anchor
bottomRight =
    Style.Anchor Style.Right Style.Bottom 0 0


{-| -}
offset : Int -> Int -> Anchor -> Anchor
offset x y (Style.Anchor ax ay _ _) =
    Style.Anchor ax ay x y
