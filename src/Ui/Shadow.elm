module Ui.Shadow exposing
    ( shadows, inner
    , font
    )

{-|

@docs shadows, inner

@docs font

-}

import Internal.Model2 as Internal
import Internal.Style2 as Style
import Ui exposing (Attribute, Color)


{-| -}
font :
    { offset : ( Float, Float )
    , blur : Float
    , color : Color
    }
    -> Attribute msg
font shade =
    Internal.style "text-shadow"
        ((String.fromFloat (Tuple.first shade.offset) ++ "px ")
            ++ (String.fromFloat (Tuple.second shade.offset) ++ "px ")
            ++ (String.fromFloat shade.blur ++ "px ")
            ++ Style.color shade.color
        )


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
    Internal.style
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
    , color : Color
    }
    -> Attribute msg
inner shade =
    Internal.style
        "box-shadow"
        ("inset " ++ Style.singleShadow shade)
