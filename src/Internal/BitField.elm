module Internal.BitField exposing
    ( init, none, Bits, toInt, fromInt, toString
    , BitField, first, next
    , set, setPercentage, flipIf, flip, copy, clear, merge
    , get, getPercentage
    , has, equal
    , fieldEqual
    , isZeroLength
    )

{-|

    type Rgba
        = Rgba

    red : BitField Rgba
    red =
        BitField.first 8

    green : BitField Rgba
    green =
        red |> Bitfield.next 8

    blue : BitField Rgba
    blue =
        green |> Bitfield.next 8

    alpha : BitField Rgba
    alpha =
        blue |> Bitfield.next 8

    myColor : BitField.Bits Rgba
    myColor =
        BitField.init
            |> BitField.set red 255
            |> BitField.set green 255
            |> BitField.set blue 100
            |> BitField.setPercentage alpha 1

    myRed =
        myColor
            |> BitField.get red

@docs init, none, Bits, toInt, fromInt, toString

@docs BitField, first, next

@docs set, setPercentage, flipIf, flip, copy, clear, merge

@docs get, getPercentage

@docs has, equal

@docs fieldEqual

@docs isZeroLength

-}

import Bitwise



{-
   A Bitfield itself, is a bitfield.

   it captures 2 numbers, offset and length, which are both 32 values


       we retrieve offset by doing

           bitfield
               |> Bitwise.and first16

       and we retrieve offset via

           bitfield
               |> Bitwise.shiftRightZfBy 16



-}


{-| -}
type BitField encoding
    = BitField
        { offset : Int
        , length : Int
        , mask : Int
        , inverseMask : Int
        }


isZeroLength : BitField encoding -> Bool
isZeroLength (BitField { length }) =
    length - 0 == 0


getFieldMask : BitField encoding -> Int
getFieldMask (BitField { mask }) =
    mask


{-| -}
type Bits encoding
    = Bits Int


{-| -}
init : Bits encoding
init =
    Bits 0


{-| -}
none : Bits encoding
none =
    Bits 0


{-| -}
toString : Bits encoding -> String
toString (Bits i) =
    viewBitsHelper i 0 ""


viewBitsHelper : Int -> Int -> String -> String
viewBitsHelper f slotIndex str =
    if slotIndex >= 32 then
        str

    else if Bitwise.and (slot slotIndex) f == 0 then
        viewBitsHelper f (slotIndex + 1) ("0" ++ str)

    else
        viewBitsHelper f (slotIndex + 1) ("1" ++ str)


{-| -}
slot : Int -> Int
slot slotIndex =
    1 |> Bitwise.shiftLeftBy slotIndex


{-| -}
zero : Int
zero =
    Bitwise.complement ones


{-| -}
ones : Int
ones =
    Bitwise.complement 0


{-| -}
first16 : Int
first16 =
    Bitwise.shiftLeftBy 16 1 - 1


{-| -}
custom :
    { offset : Int
    , length : Int
    }
    -> BitField encoding
custom details =
    let
        offset =
            min (max 0 details.offset) 31

        length =
            if details.length + offset > 32 then
                32 - offset

            else
                details.length

        mask =
            ones
                -- calculate top
                |> Bitwise.shiftRightZfBy (32 - length)
                -- mask
                |> Bitwise.shiftLeftBy offset
    in
    BitField
        { offset = offset
        , length = length
        , mask = mask
        , inverseMask = Bitwise.complement mask
        }


{-| -}
first : Int -> BitField encoding
first len =
    custom
        { length = len
        , offset = 0
        }


{-| Create a new Bitfield that comes immediately after a given one.

This is really useful so you don't make a simple addition mistake!

-}
next : Int -> BitField encoding -> BitField encoding
next nextLength (BitField existing) =
    custom
        { length = nextLength
        , offset =
            existing.offset + existing.length
        }


{-| -}
clear : BitField encoding -> Bits encoding -> Bits encoding
clear (BitField { inverseMask }) (Bits bits) =
    bits
        -- clear the target section
        |> Bitwise.and
            inverseMask
        |> Bits


{-| Copy a specific bitfield from one set of bits to another.
-}
copy : BitField encoding -> Bits encoding -> Bits encoding -> Bits encoding
copy (BitField { mask, inverseMask }) (Bits one) (Bits destination) =
    let
        newSection =
            one
                |> Bitwise.and mask
    in
    destination
        -- clear the target section
        |> Bitwise.and inverseMask
        -- Combine the two
        |> Bitwise.or newSection
        |> Bits


flipIf : BitField encoding -> Bool -> Bits encoding -> Bits encoding
flipIf (BitField { mask }) bool ((Bits innerBits) as bits) =
    if bool then
        Bits (Bitwise.or innerBits mask)

    else
        bits


flip : BitField encoding -> Bool -> Bits encoding -> Bits encoding
flip (BitField { mask, inverseMask }) bool (Bits innerBits) =
    if bool then
        Bits
            (Bitwise.or innerBits
                mask
            )

    else
        Bits
            (Bitwise.and innerBits
                inverseMask
            )


{-| -}
set : BitField encoding -> Int -> Bits encoding -> Bits encoding
set (BitField { inverseMask, offset, length }) unboundedVal (Bits bits) =
    let
        top =
            ones
                -- calculate top
                |> Bitwise.shiftRightZfBy (32 - length)

        val =
            min ((2 ^ length) - 1) (max 0 unboundedVal)
    in
    bits
        -- clear the target section
        |> Bitwise.and
            inverseMask
        -- Add the new data
        |> Bitwise.or
            (Bitwise.shiftLeftBy offset
                (Bitwise.and top val)
            )
        |> Bits


{-| -}
setPercentage : BitField encoding -> Float -> Bits encoding -> Bits encoding
setPercentage (BitField { offset, length, inverseMask }) unboundedVal (Bits bits) =
    let
        percentage =
            min 1 (max 0 unboundedVal)

        -- offset =
        --     bitfield
        --         |> Bitwise.and first16
        -- length =
        --     bitfield
        --         |> Bitwise.shiftRightZfBy 16
        top =
            ones
                -- calculate top
                |> Bitwise.shiftRightZfBy (32 - length)

        -- inverted =
        --     top
        --         -- mask
        --         |> Bitwise.shiftLeftBy offset
        --         -- inverted
        --         |> Bitwise.complement
        total =
            Bitwise.shiftLeftBy length 1 - 1

        val =
            round (percentage * toFloat total)
    in
    bits
        -- clear the target section
        |> Bitwise.and inverseMask
        -- Add the new data
        |> Bitwise.or
            (Bitwise.shiftLeftBy offset
                (Bitwise.and top val)
            )
        |> Bits


{-| -}
get : BitField encoding -> Bits encoding -> Int
get (BitField { length, offset }) (Bits bits) =
    let
        top =
            ones
                -- calculate top
                |> Bitwise.shiftRightZfBy (32 - length)
    in
    bits
        |> Bitwise.shiftRightZfBy offset
        |> Bitwise.and top


{-| -}
getPercentage : BitField encoding -> Bits encoding -> Float
getPercentage (BitField { offset, length }) (Bits bits) =
    let
        top =
            ones
                -- calculate top
                |> Bitwise.shiftRightZfBy (32 - length)

        numerator =
            bits
                |> Bitwise.shiftRightZfBy offset
                |> Bitwise.and top
                |> toFloat
    in
    numerator / toFloat (Bitwise.shiftLeftBy length 1 - 1)


{-| -}
toInt : Bits encoding -> Int
toInt (Bits bits) =
    bits


{-| -}
fromInt : Int -> Bits encoding
fromInt =
    Bits


{-| -}
has : BitField encoding -> Bits encoding -> Bool
has (BitField { mask }) (Bits base) =
    Bitwise.and mask base /= 0


{-| -}
equal : Bits encoding -> Bits encoding -> Bool
equal (Bits one) (Bits two) =
    one - two == 0


fieldEqual : BitField encoding -> BitField encoding -> Bool
fieldEqual (BitField one) (BitField two) =
    (one.offset == two.offset)
        && (one.length == two.length)


merge : Bits encoding -> Bits encoding -> Bits encoding
merge (Bits one) (Bits two) =
    Bits (Bitwise.or one two)
