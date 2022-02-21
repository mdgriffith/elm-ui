module Ui.Border exposing
    ( color
    , width, widthXY, widthEach
    , solid, dashed, dotted
    , rounded, roundEach
    , glow, innerGlow, shadows, innerShadow
    , lights
    )

{-|

@docs color


## Border Widths

@docs width, widthXY, widthEach


## Border Styles

@docs solid, dashed, dotted


## Rounded Corners

@docs rounded, roundEach


## Shadows

@docs glow, innerGlow, shadows, innerShadow

-}

import Html.Attributes as Attr
import Internal.Flag as Flag
import Internal.Model2 as Two
import Internal.Style2 as Style
import Ui exposing (Attribute, Color)


{-| -}
color : Color -> Attribute msg
color clr =
    Two.style "border-color" (Style.color clr)


{-| -}
width : Int -> Attribute msg
width x =
    Two.styleWith Flag.borderWidth
        "border-width"
        (String.fromInt x ++ "px")


{-| Set horizontal and vertical borders.
-}
widthXY : Int -> Int -> Attribute msg
widthXY x y =
    Two.styleWith Flag.borderWidth
        "border-width"
        (String.fromInt y ++ "px " ++ String.fromInt x ++ "px")


{-| -}
widthEach :
    { bottom : Int
    , left : Int
    , right : Int
    , top : Int
    }
    -> Attribute msg
widthEach border =
    Two.styleWith Flag.borderWidth
        "border-width"
        ((String.fromInt border.top ++ "px ")
            ++ (String.fromInt border.right ++ "px ")
            ++ (String.fromInt border.bottom ++ "px ")
            ++ (String.fromInt border.left ++ "px")
        )


{-| -}
solid : Attribute msg
solid =
    Two.style "border-style" "solid"


{-| -}
dashed : Attribute msg
dashed =
    Two.style "border-style" "dashed"


{-| -}
dotted : Attribute msg
dotted =
    Two.style "border-style" "dotted"


{-| Round all corners.
-}
rounded : Int -> Attribute msg
rounded radius =
    Two.style "border-radius" (String.fromInt radius ++ "px")


{-| -}
roundEach :
    { topLeft : Int
    , topRight : Int
    , bottomLeft : Int
    , bottomRight : Int
    }
    -> Attribute msg
roundEach { topLeft, topRight, bottomLeft, bottomRight } =
    Two.style "border-radius"
        ((String.fromInt topLeft ++ "px ")
            ++ (String.fromInt topRight ++ "px ")
            ++ (String.fromInt bottomRight ++ "px ")
            ++ (String.fromInt bottomLeft ++ "px")
        )


{-| A simple glow by specifying the color and size.
-}
glow : Color -> Float -> Attribute msg
glow clr size =
    -- shadow
    --     { offset = ( 0, 0 )
    --     , size = size
    --     , blur = size * 2
    --     , color = clr
    --     }
    Two.class "DO we really need glow?"


{-| -}
innerGlow : Color -> Float -> Attribute msg
innerGlow clr size =
    -- innerShadow
    --     { offset = ( 0, 0 )
    --     , size = size
    --     , blur = size * 2
    --     , color = clr
    --     }
    Two.class "DO we really need glow?"


{-| -}
shadows :
    List
        { x : Float
        , y : Float
        , size : Float
        , blur : Float
        , color : Color
        }
    -> Attribute msg
shadows shades =
    Two.style
        "box-shadow"
        (List.map Style.singleShadow shades
            |> String.join ", "
        )


{-| -}
innerShadow :
    { x : Float
    , y : Float
    , size : Float
    , blur : Float
    , color : Color
    }
    -> Attribute msg
innerShadow shade =
    Two.style
        "box-shadow"
        ("inset " ++ Style.singleShadow shade)


{-| direction: 0 is up, 0.5 is down
-}
lights :
    { elevation : Float
    , lights :
        List
            { direction : Float
            , elevation : Float
            , hardness : Float
            }
    }
    -> Attribute msg
lights details =
    Two.style "box-shadow"
        (List.map (renderLight details.elevation) details.lights
            |> String.join ", "
        )


renderLight elevation light =
    let
        ( x, y ) =
            fromPolar ( elevation, turns (0.25 + light.direction) )
    in
    Style.quad
        (Style.floatPx x)
        (Style.floatPx y)
        -- blur
        (Style.floatPx light.hardness)
        -- size
        -- (Style.floatPx (10 * light.elevation))
        ("rgba(0,0,0," ++ String.fromFloat ((100 - elevation) / 500) ++ ")")
