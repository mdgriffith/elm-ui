module Internal.BitField exposing
    ( init, Bits
    , BitField, field, set, get, has
    )

{-|

@docs init, Bits

@docs BitField, field, set, get, has

-}

import Bitwise


{-| We have a few useful values.

Let's say we have a value that is offset 2, length 2

    - top, where the top `length` values are flipped and the rest are 0s
        11000000000000000000000000000000

    - mask, where the section is inverted
        00110000000000000000000000000000

    -invertedMask
        11001111111111111111111111111111

-}
type BitField
    = BitField
        { offset : Int
        , length : Int
        , top : Int
        , mask : Int
        , inverted : Int
        }


type Bits
    = Bits Int


{-| -}
init : Bits
init =
    Bits 0


view : Bits -> String
view (Bits i) =
    viewBitsHelper i 32


viewBitsHelper : Int -> Int -> String
viewBitsHelper f slot =
    if slot <= 0 then
        ""

    else if Bitwise.and slot f - slot == 0 then
        viewBitsHelper f (slot - 1) ++ "1"

    else
        viewBitsHelper f (slot - 1) ++ "0"


zero : Int
zero =
    Bitwise.complement ones


ones : Int
ones =
    Bitwise.complement 0


field :
    { offset : Int
    , length : Int
    }
    -> BitField
field details =
    let
        top =
            Bitwise.shiftRightZfBy (32 - details.length) ones

        mask =
            top
                |> Bitwise.shiftLeftBy details.offset
    in
    BitField
        { offset = details.offset
        , length = details.length
        , top = top
        , mask =
            mask
        , inverted =
            Bitwise.complement mask
        }


set : BitField -> Int -> Bits -> Bits
set (BitField { offset, top, inverted }) val (Bits bits) =
    bits
        -- clear the target section
        |> Bitwise.and inverted
        -- Add the new data
        |> Bitwise.or
            (Bitwise.shiftLeftBy offset
                (Bitwise.and top val)
            )
        |> Bits


get : BitField -> Bits -> Int
get (BitField { offset, top }) (Bits bits) =
    bits
        |> Bitwise.shiftRightZfBy offset
        |> Bitwise.and top


{-| -}
has : Int -> Bits -> Bool
has target (Bits base) =
    (Bitwise.and target base - 0) == 0
