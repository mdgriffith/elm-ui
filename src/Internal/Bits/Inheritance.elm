module Internal.Bits.Inheritance exposing
    ( Encoded, Field
    , isRow, isColumn, isTextLayout
    , hasTextModification, fontHeight, spacingX, spacingY
    , clearParentValues
    )

{-|

@docs Encoded, Field

@docs isRow, isColumn, isTextLayout

@docs hasTextModification, fontHeight, spacingX, spacingY

@docs clearParentValues

This module is all the information that is inherited from one node to another, within elm-ui.

    - isRow                1bit
    - isColumn             1bit
    - isTextLayout         1bit
    - hasTextModification  1bit  (text gradient, text ellipsis)

    - # font height adjustment
    - fontHeight           7bits

    - # only used for spacing in paragraphs/textColumns
    - spacingX             9bits
    - spacingY             9bits

-}

import Internal.BitField as BitField exposing (BitField, Bits)


type Inheritance
    = Inheritance


type alias Field =
    BitField Inheritance


type alias Encoded =
    Bits



{- FIELDS -}


isRow : Field
isRow =
    BitField.first 1


isColumn : Field
isColumn =
    isRow
        |> BitField.next 1


isTextLayout : Field
isTextLayout =
    isColumn
        |> BitField.next 1


hasTextModification : Field
hasTextModification =
    isTextLayout
        |> BitField.next 1


fontHeight : Field
fontHeight =
    hasTextModification
        |> BitField.next 7


spacingX : Field
spacingX =
    fontHeight
        |> BitField.next 9


spacingY : Field
spacingY =
    spacingX
        |> BitField.next 9



{- HELPERS -}


clearParentValues : Encoded -> Encoded
clearParentValues bits =
    bits
        |> BitField.clear spacingX
        |> BitField.clear spacingY
        |> BitField.clear isRow
        |> BitField.clear isColumn
        |> BitField.clear isTextLayout
