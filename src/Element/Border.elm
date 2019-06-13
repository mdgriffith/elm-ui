module Element.Border exposing
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

import Element exposing (Attr, Attribute, Color)
import Internal.Flag as Flag
import Internal.Model as Internal
import Internal.Style as Style exposing (classes)


{-| -}
color : Color -> Attr decorative msg
color clr =
    Internal.StyleClass
        Flag.borderColor
        (Internal.Colored
            ("bc-" ++ Internal.formatColorClass clr)
            "border-color"
            clr
        )


{-| -}
width : Int -> Attribute msg
width v =
    Internal.StyleClass
        Flag.borderWidth
        (Internal.BorderWidth
            ("b-" ++ String.fromInt v)
            v
            v
            v
            v
        )


{-| Set horizontal and vertical borders.
-}
widthXY : Int -> Int -> Attribute msg
widthXY x y =
    Internal.StyleClass
        Flag.borderWidth
        (Internal.BorderWidth
            ("b-"
                ++ String.fromInt x
                ++ "-"
                ++ String.fromInt y
            )
            y
            x
            y
            x
        )


{-| -}
widthEach :
    { bottom : Int
    , left : Int
    , right : Int
    , top : Int
    }
    -> Attribute msg
widthEach { bottom, top, left, right } =
    if top == bottom && left == right then
        if top == right then
            width top

        else
            widthXY left top

    else
        Internal.StyleClass Flag.borderWidth
            (Internal.BorderWidth
                ("b-"
                    ++ String.fromInt top
                    ++ "-"
                    ++ String.fromInt right
                    ++ "-"
                    ++ String.fromInt bottom
                    ++ "-"
                    ++ String.fromInt left
                )
                top
                right
                bottom
                left
            )



-- {-| No Borders
-- -}
-- none : Attribute msg
-- none =
--     Class "border" "border-none"


{-| -}
solid : Attribute msg
solid =
    Internal.Class Flag.borderStyle classes.borderSolid


{-| -}
dashed : Attribute msg
dashed =
    Internal.Class Flag.borderStyle classes.borderDashed


{-| -}
dotted : Attribute msg
dotted =
    Internal.Class Flag.borderStyle classes.borderDotted


{-| Round all corners.
-}
rounded : Int -> Attribute msg
rounded radius =
    Internal.StyleClass
        Flag.borderRound
        (Internal.Single
            ("br-" ++ String.fromInt radius)
            "border-radius"
            (String.fromInt radius ++ "px")
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
    Internal.StyleClass Flag.borderRound
        (Internal.Single
            ("br-"
                ++ String.fromInt topLeft
                ++ "-"
                ++ String.fromInt topRight
                ++ String.fromInt bottomLeft
                ++ "-"
                ++ String.fromInt bottomRight
            )
            "border-radius"
            (String.fromInt topLeft
                ++ "px "
                ++ String.fromInt topRight
                ++ "px "
                ++ String.fromInt bottomRight
                ++ "px "
                ++ String.fromInt bottomLeft
                ++ "px"
            )
        )


{-| A simple glow by specifying the color and size.
-}
glow : Color -> Float -> Attr decorative msg
glow clr size =
    shadow
        { offset = ( 0, 0 )
        , size = size
        , blur = size * 2
        , color = clr
        }


{-| -}
innerGlow : Color -> Float -> Attr decorative msg
innerGlow clr size =
    innerShadow
        { offset = ( 0, 0 )
        , size = size
        , blur = size * 2
        , color = clr
        }


{-| -}
shadow :
    { offset : ( Float, Float )
    , size : Float
    , blur : Float
    , color : Color
    }
    -> Attr decorative msg
shadow almostShade =
    let
        shade =
            { inset = False
            , offset = almostShade.offset
            , size = almostShade.size
            , blur = almostShade.blur
            , color = almostShade.color
            }
    in
    Internal.StyleClass Flag.shadows <|
        Internal.Single
            (Internal.boxShadowClass shade)
            "box-shadow"
            (Internal.formatBoxShadow shade)


{-| -}
innerShadow :
    { offset : ( Float, Float )
    , size : Float
    , blur : Float
    , color : Color
    }
    -> Attr decorative msg
innerShadow almostShade =
    let
        shade =
            { inset = True
            , offset = almostShade.offset
            , size = almostShade.size
            , blur = almostShade.blur
            , color = almostShade.color
            }
    in
    Internal.StyleClass Flag.shadows <|
        Internal.Single
            (Internal.boxShadowClass shade)
            "box-shadow"
            (Internal.formatBoxShadow shade)



-- {-| -}
-- shadow :
--     { offset : ( Float, Float )
--     , blur : Float
--     , size : Float
--     , color : Color
--     }
--     -> Attr decorative msg
-- shadow shade =
--     Internal.BoxShadow
--         { inset = False
--         , offset = shade.offset
--         , size = shade.size
--         , blur = shade.blur
--         , color = shade.color
--         }
