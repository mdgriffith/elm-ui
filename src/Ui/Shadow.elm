module Ui.Shadow exposing (inner, shadows)

{-| -}

import Internal.Model2 as Two
import Internal.Style2 as Style
import Ui exposing (Attribute)


{-| -}
shadows :
    List
        { x : Float
        , y : Float
        , size : Float
        , blur : Float
        , color : Ui.Color
        }
    -> Attribute msg
shadows shades =
    Two.style
        "box-shadow"
        (List.map Style.singleShadow shades
            |> String.join ", "
        )


{-| -}
inner :
    { x : Float
    , y : Float
    , size : Float
    , blur : Float
    , color : Ui.Color
    }
    -> Attribute msg
inner shade =
    Two.style
        "box-shadow"
        ("inset " ++ Style.singleShadow shade)


{-| Do we need this?
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
