module Internal.Bits.Inheritance exposing
    ( Encoded, Field
    , isRow, isColumn, hasTextModification, fontHeight, spacingX, spacingY
    , clearSpacing
    )

{-|

@docs Encoded, Field

@docs isRow, isColumn, hasTextModification, fontHeight, spacingX, spacingY

@docs clearSpacing

This module is all the information that is inherited from one node to another, within elm-ui.

    - isRow                1bit
    - isColumn             1bit
    - hasTextModification  1bit  (text gradient, text ellipsis)

    - # font height adjustment
    - fontHeight           7bits

    - # only used for spacing in paragraphs/textColumns
    - spacingX             10bits
    - spacingY             10bits

-}

import Internal.BitField as BitField exposing (BitField, Bits)


type Inheritance
    = Inheritance


type alias Field =
    BitField Inheritance


type alias Encoded =
    Bits Inheritance



{- FIELDS -}


isRow : Field
isRow =
    BitField.first 1


isColumn : Field
isColumn =
    isRow
        |> BitField.next 1


hasTextModification : Field
hasTextModification =
    isColumn
        |> BitField.next 1


fontHeight : Field
fontHeight =
    hasTextModification
        |> BitField.next 7


spacingX : Field
spacingX =
    fontHeight
        |> BitField.next 10


spacingY : Field
spacingY =
    spacingX
        |> BitField.next 10



{- HELPERS -}


clearSpacing : Encoded -> Encoded
clearSpacing bits =
    bits
        |> BitField.clear spacingX
        |> BitField.clear spacingY
