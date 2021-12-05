module Internal.BitEncodings exposing (..)

{-| -}

import Internal.BitField as BitField exposing (BitField, Bits)


{-| These are bits that are passed from parent to child in the rendering pipeline
-}
type Inheritance
    = Inheritance



{- Node State -}


row : Bits Inheritance
row =
    BitField.init


column : Bits Inheritance
column =
    row
        |> BitField.set isRow 1



-- fields
{-
   - spacing           12bits
   - spacingRatio       6bits
   - fontHeight         6bits
   - fontAdjustment     5bits
   - isRow              1bit
   - widthFill          1bit
   - heightFill         1bit

-}


clearSpacing : Bits Inheritance -> Bits Inheritance
clearSpacing bits =
    bits
        |> BitField.clear spacingX
        |> BitField.clear spacingY


{-| -}
hasSpacing : Bits Inheritance -> Bool
hasSpacing bits =
    (bits |> BitField.has spacingX)
        || (bits |> BitField.has spacingY)


spacingX : BitField Inheritance
spacingX =
    BitField.first 12


spacingY : BitField Inheritance
spacingY =
    spacingX
        |> BitField.next 6


{-| -}
hasFontAdjustment : Bits Inheritance -> Bool
hasFontAdjustment bits =
    (bits |> BitField.has fontHeight)
        || (bits |> BitField.has fontOffset)


fontHeight : BitField Inheritance
fontHeight =
    spacingY
        |> BitField.next 6


fontOffset : BitField Inheritance
fontOffset =
    fontHeight
        |> BitField.next 5


isRow : BitField Inheritance
isRow =
    fontOffset
        |> BitField.next 1



{- Transition Duration/Delay -}


type Transition
    = Transition


duration : BitField Transition
duration =
    BitField.first 16


delay : BitField Transition
delay =
    duration |> BitField.next 16



{- Bezier curves -}


type Bezier
    = Bezier


defaultCurve : Bits Bezier
defaultCurve =
    -- REPLACE THIS WITH THE REAL DEFAULT CURVE
    BitField.init


bezOne : BitField Bezier
bezOne =
    BitField.first 8


bezTwo : BitField Bezier
bezTwo =
    bezOne |> BitField.next 8


bezThree : BitField Bezier
bezThree =
    bezTwo |> BitField.next 8


bezFour : BitField Bezier
bezFour =
    bezThree |> BitField.next 8
