module Internal.Flag exposing
    ( Field(..)
    , Flag(..)
    , active
    , add
    , alignBottom
    , alignRight
    , behind
    , bgColor
    , bgGradient
    , bgImage
    , borderColor
    , borderRound
    , borderStyle
    , borderWidth
    , centerX
    , centerY
    , cursor
    , flag
    , focus
    , fontAlignment
    , fontColor
    , fontFamily
    , fontSize
    , fontVariant
    , fontWeight
    , gridPosition
    , gridTemplate
    , height
    , heightBetween
    , heightContent
    , heightFill
    , heightTextAreaContent
    , hover
    , letterSpacing
    , merge
    , moveX
    , moveY
    , none
    , overflow
    , padding
    , present
    , rotate
    , scale
    , shadows
    , spacing
    , transparency
    , txtShadows
    , value
    , width
    , widthBetween
    , widthContent
    , widthFill
    , wordSpacing
    , xAlign
    , yAlign
    )

{-| -}

import Bitwise


type Field
    = Field Int Int


type Flag
    = Flag Int
    | Second Int


none : Field
none =
    Field 0 0


value myFlag =
    case myFlag of
        Flag first ->
            round (logBase 2 (toFloat first))

        Second second ->
            round (logBase 2 (toFloat second)) + 32


{-| If the query is in the truth, return True
-}
present : Flag -> Field -> Bool
present myFlag (Field fieldOne fieldTwo) =
    case myFlag of
        Flag first ->
            Bitwise.and first fieldOne == first

        Second second ->
            Bitwise.and second fieldTwo == second


{-| Add a flag to a field.
-}
add : Flag -> Field -> Field
add myFlag (Field one two) =
    case myFlag of
        Flag first ->
            Field (Bitwise.or first one) two

        Second second ->
            Field one (Bitwise.or second two)


{-| Generally you want to use `add`, which keeps a distinction between Fields and Flags.

Merging will combine two fields

-}
merge : Field -> Field -> Field
merge (Field one two) (Field three four) =
    Field (Bitwise.or one three) (Bitwise.or two four)


flag : Int -> Flag
flag i =
    if i > 31 then
        Second
            (Bitwise.shiftLeftBy (i - 32) 1)

    else
        Flag
            (Bitwise.shiftLeftBy i 1)



{- Used for Style invalidation -}


transparency =
    flag 0


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


bgColor =
    flag 8


bgImage =
    flag 9


bgGradient =
    flag 10


borderStyle =
    flag 11


fontAlignment =
    flag 12


fontWeight =
    flag 13


fontColor =
    flag 14


wordSpacing =
    flag 15


letterSpacing =
    flag 16


borderRound =
    flag 17


txtShadows =
    flag 18


shadows =
    flag 19


overflow =
    flag 20


cursor =
    flag 21


scale =
    flag 23


rotate =
    flag 24


moveX =
    flag 25


moveY =
    flag 26


borderWidth =
    flag 27


borderColor =
    flag 28


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


heightContent =
    flag 36


heightFill =
    flag 37


widthContent =
    flag 38


widthFill =
    flag 39


alignRight =
    flag 40


alignBottom =
    flag 41


centerX =
    flag 42


centerY =
    flag 43


widthBetween =
    flag 44


heightBetween =
    flag 45


behind =
    flag 46


heightTextAreaContent =
    flag 47


fontVariant =
    flag 48
