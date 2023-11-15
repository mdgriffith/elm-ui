module Internal.Bits.Analyze exposing (Encoded, Field, cssVars, isButton, isLink, nearbys, transforms)

{-| -}

import Internal.BitField as BitField exposing (BitField, Bits)


type Analyze
    = Analyze


type alias Field =
    BitField Analyze


type alias Encoded =
    Bits



{- FIELDS -}


cssVars : Field
cssVars =
    BitField.first 1


transforms : Field
transforms =
    cssVars
        |> BitField.next 1


nearbys : Field
nearbys =
    transforms
        |> BitField.next 1


isLink : Field
isLink =
    nearbys
        |> BitField.next 1


isButton : Field
isButton =
    isLink
        |> BitField.next 1
