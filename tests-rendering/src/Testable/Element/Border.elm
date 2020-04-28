module Testable.Element.Border exposing (..)

{-| -}

import Dict
import Element exposing (Color)
import Element.Border as Border
import Element.Font as Font
import Expect
import Testable


color : Color -> Testable.Attr msg
color clr =
    Testable.Attr (Border.color clr)


width : Int -> Testable.Attr msg
width i =
    Testable.Attr (Border.width i)
