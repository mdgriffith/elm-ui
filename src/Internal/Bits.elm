module Internal.Bits exposing (..)

{-| -}

import Internal.BitField as BitField



{- Node State -}


row : Bits
row =
    BitField.init


column : Bits
column =
    row
        |> BitField.set rowOrColumn 1



-- fields


spacingX : BitField.BitField
spacingX =
    BitField.field
        { offset = 0
        , length = 10
        }


spacingY : BitField.BitField
spacingY =
    BitField.field
        { offset = 10
        , length = 10
        }


fontHeight : BitField.BitField
fontHeight =
    BitField.field
        { offset = 20
        , length = 6
        }


fontOffset : BitField.BitField
fontOffset =
    BitField.field
        { offset = 26
        , length = 5
        }


rowOrColumn : BitField.BitField
rowOrColumn =
    BitField.field
        { offset = 31
        , length = 1
        }


{--}
