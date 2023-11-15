module Internal.BitEncodings exposing (..)

{-| -}

import Internal.BitField as BitField exposing (BitField, Bits)


{-| These are bits that are passed from parent to child in the rendering pipeline
-}
type Inheritance
    = Inheritance



{- Node State -}


row : Bits
row =
    BitField.init


column : Bits
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


   New fields

       - isRow                1bit
       - isColumn             1bit
       - hasTextModification  1bit  (text gradient, text ellipsis)

       - # font height adjustment
       - fontHeight           7bits

       - # only used for spacing in paragraphs/textColumns
       - spacingX             10bits
       - spacingY             10bits







-}


clearSpacing : Bits -> Bits
clearSpacing bits =
    bits
        |> BitField.clear spacingX
        |> BitField.clear spacingY


{-| -}
hasSpacing : Bits -> Bool
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


isRow : BitField Inheritance
isRow =
    spacingY
        |> BitField.next 1


isParagraph : BitField Inheritance
isParagraph =
    isRow
        |> BitField.next 1


fontHeight : BitField Inheritance
fontHeight =
    isParagraph
        |> BitField.next 5


fontOffset : BitField Inheritance
fontOffset =
    fontHeight
        |> BitField.next 5


{-| -}
hasFontAdjustment : Bits -> Bool
hasFontAdjustment bits =
    (bits |> BitField.has fontHeight)
        || (bits |> BitField.has fontOffset)



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


defaultCurve : Bits
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
