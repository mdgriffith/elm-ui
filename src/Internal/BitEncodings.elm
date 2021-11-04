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


{-| Compound field
-}
spacing : BitField
spacing =
    BitField.field
        { offset = 0
        , length = 20
        }


spacingX : BitField
spacingX =
    BitField.field
        { offset = 0
        , length = 10
        }


spacingY : BitField
spacingY =
    BitField.field
        { offset = 10
        , length = 10
        }


{-| The compound font adjustment
-}
fontAdjustment : BitField
fontAdjustment =
    BitField.field
        { offset = 20
        , length = 11
        }


fontHeight : BitField
fontHeight =
    BitField.field
        { offset = 20
        , length = 6
        }


fontOffset : BitField
fontOffset =
    BitField.field
        { offset = 26
        , length = 5
        }


isRow : BitField
isRow =
    BitField.field
        { offset = 31
        , length = 1
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
        , length = 32
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
