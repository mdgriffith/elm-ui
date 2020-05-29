module NearbyElementBordersOverlap exposing (view)

{-| Elements placed with onLeft, onRight, above & below overlap main element's border


# inFront elements with width fill are contained within the parent's border

<https://github.com/mdgriffith/elm-ui/issues/223>

In addition to the overlap, it affects layout in unexpected ways: eg if the elements
are the same height, onLeft and onRight elements will be vertically offset
from the main element.

-}

import Testable.Element exposing (..)
import Testable.Element.Border as Border


blue =
    rgb 0 0 1


green =
    rgb 0 1 0


grey =
    rgb 0.5 0.5 0.5


view =
    layout [ width fill, height fill ] <|
        el
            [ centerX
            , centerY
            , Border.width 10
            , Border.color green
            , padding 50
            , above <| el [ Border.color grey, Border.width 10 ] <| text "above"
            , below <| el [ Border.color grey, Border.width 10 ] <| text "below"
            , onRight <| el [ Border.color blue, Border.width 10 ] <| text "onRight"
            , onLeft <| el [ Border.color blue, Border.width 10 ] <| text "onLeft"
            ]
        <|
            text "Centre"
