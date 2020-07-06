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
import Internal.Flag as Flag
import Internal.Model2 as Two
import Internal.StyleGenerator as Style


{-| -}
color : Color -> Attribute msg
color clr =
    -- Internal.StyleClass
    --     Flag.borderColor
    --     (Internal.Colored
    --         ("bc-" ++ Internal.formatColorClass clr)
    --         "border-color"
    --         clr
    --     )
    Two.Style Flag.borderColor (Style.prop "border-color" (Style.color clr))


{-| -}
width : Int -> Attribute msg
width v =
    Two.Style Flag.borderWidth (Style.prop "border-color" (Style.px v))


{-| Set horizontal and vertical borders.
-}
widthXY : Int -> Int -> Attribute msg
widthXY x y =
    Two.Style Flag.borderWidth (Style.prop "border-color" (Style.pair (Style.px y) (Style.px x)))


{-| -}
widthEach :
    { bottom : Int
    , left : Int
    , right : Int
    , top : Int
    }
    -> Attribute msg
widthEach { bottom, top, left, right } =
    Two.Style Flag.borderWidth
        (Style.prop "border-color"
            (Style.quad (Style.px top)
                (Style.px right)
                (Style.px bottom)
                (Style.px left)
            )
        )


{-| -}
solid : Attribute msg
solid =
    Two.Style Flag.borderStyle (Style.prop "border-style" "solid")


{-| -}
dashed : Attribute msg
dashed =
    Two.Style Flag.borderStyle (Style.prop "border-style" "dashed")


{-| -}
dotted : Attribute msg
dotted =
    Two.Style Flag.borderStyle (Style.prop "border-style" "dotted")


{-| Round all corners.
-}
rounded : Int -> Attribute msg
rounded radius =
    Two.Style Flag.borderRound
        (Style.prop "border-radius"
            (Style.px radius)
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
        (Style.prop "border-radius"
            (Style.quad (Style.px topLeft)
                (Style.px topRight)
                (Style.px bottomRight)
                (Style.px bottomLeft)
            )
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
    Debug.todo "DO we really need glow?"


{-| -}
innerGlow : Color -> Float -> Attribute msg
innerGlow clr size =
    -- innerShadow
    --     { offset = ( 0, 0 )
    --     , size = size
    --     , blur = size * 2
    --     , color = clr
    --     }
    Debug.todo "DO we really need glow?"


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
        (Style.prop "box-shadow"
            (Style.singleShadow shade)
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
        (Style.prop "box-shadow"
            ("inset " ++ Style.singleShadow shade)
        )
