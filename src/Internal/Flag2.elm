module Internal.Flag2 exposing
    ( Field(..)
    , Flag(..)
    , active
    , add
    , borderWidth
    , cursor
    , equal
    , flag
    , focus
    , fontAdjustment
    , fontAlignment
    , fontColor
    , fontFamily
    , fontSize
    , fontWeight
    , gridPosition
    , gridTemplate
    , height
    , heightBetween
    , hover
    , id
    , merge
    , none
    , overflow
    , padding
    , present
    , shadows
    , spacing
    , transform
    , txtShadows
    , value
    , viewBits
    , viewBitsHelper
    , width
    , widthBetween
    , xAlign
    , yAlign
    )

{-| -}

import Bitwise


viewBits : Int -> String
viewBits i =
    String.fromInt i ++ ":" ++ viewBitsHelper i 32


viewBitsHelper : Int -> Int -> String
viewBitsHelper field slot =
    if slot <= 0 then
        ""

    else if Bitwise.and slot field - slot == 0 then
        viewBitsHelper field (slot - 1) ++ "1"

    else
        viewBitsHelper field (slot - 1) ++ "0"


type Field
    = Field Int



--  Int


type Flag
    = Flag Int



-- | Second Int


none : Field
none =
    Field 0



-- 0


value myFlag =
    case myFlag of
        Flag first ->
            round (logBase 2 (toFloat first))



-- Second second ->
--     round (logBase 2 (toFloat second)) + 32


{-| If the query is in the truth, return True
-}
present : Flag -> Field -> Bool
present (Flag first) (Field fieldOne) =
    Bitwise.and first fieldOne - first == 0


{-| Add a flag to a field.
-}
add : Flag -> Field -> Field
add myFlag (Field one) =
    case myFlag of
        Flag first ->
            Field (Bitwise.or first one)



-- Second second ->
--     Field one (Bitwise.or second two)


{-| Generally you want to use `add`, which keeps a distinction between Fields and Flags.

Merging will combine two fields

-}
merge : Field -> Field -> Field
merge (Field one) (Field three) =
    Field (Bitwise.or one three)


equal (Flag one) (Flag two) =
    one - two == 0


flag : Int -> Flag
flag i =
    -- if i > 31 then
    --     Second
    --         (Bitwise.shiftLeftBy (i - 32) 1)
    -- else
    Flag
        (Bitwise.shiftLeftBy i 1)



{- Used for Style invalidation -}


padding =
    flag 2


spacing =
    flag 3


fontSize =
    flag 4


fontFamily =
    flag 5


width =
    flag 6


height =
    flag 7


fontAlignment =
    flag 12


fontWeight =
    flag 13


fontColor =
    flag 14


fontAdjustment =
    flag 15


id =
    flag 16


txtShadows =
    flag 18


shadows =
    flag 19


overflow =
    flag 20


cursor =
    flag 21


transform =
    flag 23


borderWidth =
    flag 27


yAlign =
    flag 29


xAlign =
    flag 30


focus =
    flag 31


active =
    flag 32


hover =
    flag 33


gridTemplate =
    flag 34


gridPosition =
    flag 35



{- Notes -}


widthBetween =
    flag 44


heightBetween =
    flag 45
