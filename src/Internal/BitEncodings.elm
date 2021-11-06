module Internal.BitEncodings exposing (..)

{-| -}

import Internal.BitField as BitField exposing (BitField, Bits)



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

-}


{-| Compound field
-}
spacing : BitField
spacing =
    BitField.range
        spacingX
        spacingY


spacingX : BitField
spacingX =
    BitField.field
        { offset = 0
        , length = 12
        }


spacingY : BitField
spacingY =
    spacingX
        |> BitField.after
            { length = 6
            }


{-| The compound font adjustment
-}
fontAdjustment : BitField
fontAdjustment =
    BitField.range
        fontHeight
        fontOffset


fontHeight : BitField
fontHeight =
    spacingY
        |> BitField.after
            { length = 6
            }


fontOffset : BitField
fontOffset =
    fontHeight
        |> BitField.after
            { length = 5
            }


isRow : BitField
isRow =
    fontOffset
        |> BitField.after
            { length = 1
            }



{- Transition Duration/Delay -}


duration : BitField
duration =
    BitField.field
        { offset = 0
        , length = 16
        }


delay : BitField
delay =
    BitField.field
        { offset = 16
        , length = 16
        }



{- Bezier curves -}


defaultCurve : Bits
defaultCurve =
    -- REPLACE THIS WITH THE REAL DEFAULT CURVE
    BitField.init


bezOne : BitField
bezOne =
    BitField.field
        { offset = 0
        , length = 8
        }


bezTwo : BitField
bezTwo =
    BitField.field
        { offset = 8
        , length = 16
        }


bezThree : BitField
bezThree =
    BitField.field
        { offset = 16
        , length = 24
        }


bezFour : BitField
bezFour =
    BitField.field
        { offset = 24
        , length = 32
        }
