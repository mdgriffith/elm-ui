module Internal.BitField exposing
    ( init, Bits, toInt, fromInt, toString
    , BitField, first, next
    , set, setPercentage, copy, clear
    , get, getPercentage
    , has, equal
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

@docs init, Bits, toInt, fromInt, toString

@docs BitField, first, next

@docs set, setPercentage, copy, clear

@docs get, getPercentage

@docs has, equal

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
    = BitField Int


{-| -}
type Bits encoding
    = Bits Int


{-| -}
init : Bits encoding
init =
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

        encodedOffset =
            offset

        encodedLength =
            Bitwise.shiftLeftBy 16 length
    in
    BitField
        (Bitwise.or encodedOffset encodedLength)



-- {-| Create a new bitfield that spans 2 existing bitfields.
-- It will start at the lowest offset and end at the farthest point described.
-- -}
-- between : BitField encoding -> BitField encoding -> BitField encoding
-- between (BitField one) (BitField two) =
--     let
--         oneOffset =
--             one
--                 |> Bitwise.and first16
--         oneLength =
--             one
--                 |> Bitwise.shiftRightZfBy 16
--         twoOffset =
--             two
--                 |> Bitwise.and first16
--         twoLength =
--             two
--                 |> Bitwise.shiftRightZfBy 16
--         lowest =
--             min oneOffset twoOffset
--         highest =
--             max
--                 (oneOffset + oneLength)
--                 (twoOffset + twoLength)
--     in
--     custom
--         { length =
--             highest - lowest
--         , offset = lowest
--         }


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
next nextLength (BitField bitfield) =
    let
        offset =
            bitfield
                |> Bitwise.and first16

        length =
            bitfield
                |> Bitwise.shiftRightZfBy 16
    in
    custom
        { length = nextLength
        , offset =
            offset + length
        }


{-| -}
clear : BitField encoding -> Bits encoding -> Bits encoding
clear (BitField bitfield) (Bits bits) =
    let
        offset =
            bitfield
                |> Bitwise.and first16

        length =
            bitfield
                |> Bitwise.shiftRightZfBy 16
    in
    bits
        -- clear the target section
        |> Bitwise.and
            (ones
                -- calculate top
                |> Bitwise.shiftRightZfBy (32 - length)
                -- mask
                |> Bitwise.shiftLeftBy offset
                -- inverse
                |> Bitwise.complement
            )
        |> Bits


{-| Copy a specific bitfield from one set of bits to another.
-}
copy : BitField encoding -> Bits encoding -> Bits encoding -> Bits encoding
copy (BitField bitfield) (Bits one) (Bits destination) =
    let
        offset =
            bitfield
                |> Bitwise.and first16

        length =
            bitfield
                |> Bitwise.shiftRightZfBy 16

        mask =
            ones
                -- calculate top
                |> Bitwise.shiftRightZfBy (32 - length)
                -- mask
                |> Bitwise.shiftLeftBy offset

        newSection =
            one
                |> Bitwise.and mask
    in
    destination
        -- clear the target section
        |> Bitwise.and (Bitwise.complement mask)
        -- Combine the two
        |> Bitwise.or newSection
        |> Bits


{-| -}
set : BitField encoding -> Int -> Bits encoding -> Bits encoding
set (BitField bitfield) unboundedVal (Bits bits) =
    let
        offset =
            bitfield
                |> Bitwise.and first16

        length =
            bitfield
                |> Bitwise.shiftRightZfBy 16

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
            (top
                -- mask
                |> Bitwise.shiftLeftBy offset
                -- inverse
                |> Bitwise.complement
            )
        -- Add the new data
        |> Bitwise.or
            (Bitwise.shiftLeftBy offset
                (Bitwise.and top val)
            )
        |> Bits


{-| -}
setPercentage : BitField encoding -> Float -> Bits encoding -> Bits encoding
setPercentage (BitField bitfield) unboundedVal (Bits bits) =
    let
        percentage =
            min 1 (max 0 unboundedVal)

        offset =
            bitfield
                |> Bitwise.and first16

        length =
            bitfield
                |> Bitwise.shiftRightZfBy 16

        top =
            ones
                -- calculate top
                |> Bitwise.shiftRightZfBy (32 - length)

        inverted =
            top
                -- mask
                |> Bitwise.shiftLeftBy offset
                -- inverted
                |> Bitwise.complement

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


{-| -}
get : BitField encoding -> Bits encoding -> Int
get (BitField bitfield) (Bits bits) =
    let
        offset =
            bitfield
                |> Bitwise.and first16

        length =
            bitfield
                |> Bitwise.shiftRightZfBy 16

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
getPercentage (BitField bitfield) (Bits bits) =
    let
        offset =
            bitfield
                |> Bitwise.and first16

        length =
            bitfield
                |> Bitwise.shiftRightZfBy 16

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
has (BitField bitfield) (Bits base) =
    let
        offset =
            bitfield
                |> Bitwise.and first16

        length =
            bitfield
                |> Bitwise.shiftRightZfBy 16

        mask =
            ones
                -- calculate top
                |> Bitwise.shiftRightZfBy (32 - length)
                -- mask
                |> Bitwise.shiftLeftBy offset
    in
    Bitwise.and mask base /= 0


{-| -}
equal : Bits encoding -> Bits encoding -> Bool
equal (Bits one) (Bits two) =
    one - two == 0
