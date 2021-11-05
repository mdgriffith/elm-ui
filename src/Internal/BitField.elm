module Internal.BitField exposing
    ( init, Bits
    , BitField, field, set, get, has, equal
    , getFloat, getPercentage
    , clear, merge, setPercentage, toString
    )

{-|

@docs init, Bits

@docs BitField, field, set, get, has, equal

@docs getFloat, getPercentage

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


clear : BitField -> Bits -> Bits
clear (BitField { offset, top, inverted }) (Bits bits) =
    bits
        -- clear the target section
        |> Bitwise.and inverted
        |> Bits


merge : Bits -> Bits -> Bits
merge (Bits one) (Bits two) =
    Bits (Bitwise.or one two)


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


setPercentage : BitField -> Float -> Bits -> Bits
setPercentage (BitField { offset, top, inverted, length }) percentage (Bits bits) =
    let
        total =
            Bitwise.shiftLeftBy length 1 - 1

        val =
            round (percentage * toFloat total)
    in
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


getFloat : BitField -> Bits -> Float
getFloat (BitField { offset, top }) (Bits bits) =
    bits
        |> Bitwise.shiftRightZfBy offset
        |> Bitwise.and top
        |> toFloat


getPercentage : BitField -> Bits -> Float
getPercentage (BitField { offset, top, length }) (Bits bits) =
    let
        numerator =
            bits
                |> Bitwise.shiftRightZfBy offset
                |> Bitwise.and top
                |> toFloat
    in
    numerator / toFloat (Bitwise.shiftLeftBy length 1 - 1)


toString : Bits -> String
toString (Bits bits) =
    String.fromInt bits


{-| -}
has : BitField -> Bits -> Bool
has (BitField bitField) (Bits base) =
    Bitwise.and bitField.mask base
        == bitField.mask


equal : Bits -> Bits -> Bool
equal (Bits one) (Bits two) =
    one - two == 0
