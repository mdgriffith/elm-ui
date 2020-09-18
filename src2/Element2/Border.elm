module Element2.Border exposing
    ( color
    , width, widthXY, widthEach
    , solid, dashed, dotted
    , rounded, roundEach
    , glow, innerGlow, shadow, innerShadow
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

@docs glow, innerGlow, shadow, innerShadow

-}

import Element2 exposing (Attribute, Color)
import Internal.Flag2 as Flag
import Internal.Model2 as Two
import Internal.Style2 as Style


{-| -}
color : Color -> Attribute msg
color clr =
    Two.Style Flag.borderColor ("border-color:" ++ Style.color clr ++ ";")


{-| -}
width : Int -> Attribute msg
width v =
    Two.BorderWidth Flag.borderWidth v v


{-| Set horizontal and vertical borders.
-}
widthXY : Int -> Int -> Attribute msg
widthXY x y =
    Two.BorderWidth Flag.borderWidth x y


{-| -}
widthEach :
    { bottom : Int
    , left : Int
    , right : Int
    , top : Int
    }
    -> Attribute msg
widthEach { bottom, top, left, right } =
    Two.BorderWidth Flag.borderWidth top right


{-| -}
solid : Attribute msg
solid =
    Two.Style Flag.borderStyle "border-style:solid;"


{-| -}
dashed : Attribute msg
dashed =
    Two.Style Flag.borderStyle "border-style:dashed;"


{-| -}
dotted : Attribute msg
dotted =
    Two.Style Flag.borderStyle "border-style:dotted;"


{-| Round all corners.
-}
rounded : Int -> Attribute msg
rounded radius =
    Two.Style Flag.borderRound
        ("border-radius:"
            ++ Style.px radius
            ++ ";"
        )


{-| -}
roundEach :
    { topLeft : Int
    , topRight : Int
    , bottomLeft : Int
    , bottomRight : Int
    }
    -> Attribute msg
roundEach { topLeft, topRight, bottomLeft, bottomRight } =
    Two.Style Flag.borderRound
        ("border-radius:"
            ++ Style.quad (Style.px topLeft)
                (Style.px topRight)
                (Style.px bottomRight)
                (Style.px bottomLeft)
            ++ ";"
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
shadow :
    { x : Float
    , y : Float
    , size : Float
    , blur : Float
    , color : Color
    }
    -> Attribute msg
shadow shade =
    Two.Style Flag.shadows
        ("box-shadow:"
            ++ Style.singleShadow shade
            ++ ";"
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
    Two.Style Flag.shadows
        ("box-shadow:"
            ++ ("inset " ++ Style.singleShadow shade)
            ++ ";"
        )
