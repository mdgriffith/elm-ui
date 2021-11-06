module Ui.Background exposing
    ( color
    , gradient
    , gradients
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
import Internal.Flag as Flag
import Internal.Model2 as Two
import Internal.Style2 as Style
import Ui exposing (Attribute, Color)
import Ui.Gradient


{-| -}
color : Color -> Attribute msg
color clr =
    Two.attributeWith Flag.background
        (Attr.style "background-color"
            (Style.color clr)
        )


{-| Resize the image to fit the containing element while maintaining proportions and cropping the overflow.
-}
image : String -> Attribute msg
image src =
    Two.attributeWith Flag.background
        (Attr.style "background"
            ("url(\"" ++ src ++ "\") center / cover no-repeat")
        )


{-| A centered background image that keeps its natural proportions, but scales to fit the space.
-}
uncropped : String -> Attribute msg
uncropped src =
    Two.attributeWith Flag.background
        (Attr.style "background"
            ("url(\"" ++ src ++ "\") center / contain no-repeat")
        )


{-| Tile an image in the x and y axes.
-}
tiled : String -> Attribute msg
tiled src =
    Two.attributeWith Flag.background
        (Attr.style "background"
            ("url(\"" ++ src ++ "\") center / repeat")
        )


{-| Tile an image in the x axis.
-}
tiledX : String -> Attribute msg
tiledX src =
    Two.attributeWith Flag.background
        (Attr.style "background"
            ("url(\"" ++ src ++ "\") center / repeat-x")
        )


{-| Tile an image in the y axis.
-}
tiledY : String -> Attribute msg
tiledY src =
    Two.attributeWith Flag.background
        (Attr.style "background"
            ("url(\"" ++ src ++ "\") center / repeat-y")
        )


{-|

    Ui.Background.gradient <|
        Ui.Gradient.linear Ui.right
            [ Ui.Gradient.percent 0 blue
            , Ui.Gradient.percent 100 purple
            ]

-}
gradient :
    Ui.Gradient.Gradient
    -> Attribute msg
gradient grad =
    Two.attributeWith Flag.background
        (Attr.style "background-image"
            (Style.toCssGradient grad)
        )


{-| -}
gradients : List Ui.Gradient.Gradient -> Attribute msg
gradients grads =
    case grads of
        [] ->
            Two.noAttr

        _ ->
            Two.attributeWith Flag.background
                (Attr.style "background-image"
                    (List.map Style.toCssGradient grads
                        |> String.join ", "
                    )
                )
