module Internal.Bits exposing (..)

{-| -}

import Bitwise


ones : Int
ones =
    Bitwise.complement 0


top10 : Int
top10 =
    Bitwise.shiftRightZfBy (32 - 10) ones


top8 : Int
top8 =
    Bitwise.shiftRightZfBy (32 - 8) ones


top6 : Int
top6 =
    Bitwise.shiftRightZfBy (32 - 6) ones


top5 : Int
top5 =
    Bitwise.shiftRightZfBy (32 - 5) ones


top16 : Int
top16 =
    Bitwise.shiftRightZfBy 16 ones


spacingY : Int
spacingY =
    Bitwise.shiftRightZfBy (32 - 10) ones


fontHeight : Int
fontHeight =
    Bitwise.shiftRightZfBy (32 - 6) ones


fontOffset : Int
fontOffset =
    Bitwise.shiftRightZfBy (32 - 5) ones


fontAdjustments : Int
fontAdjustments =
    Bitwise.shiftRightZfBy (32 - 11) ones
        |> Bitwise.shiftLeftBy 20


row : Int
row =
    Bitwise.shiftLeftBy 31 1


nonRow : Int
nonRow =
    Bitwise.shiftLeftBy 31 0



{- TRANSITIONS -}


duration : Int
duration =
    Bitwise.shiftRightZfBy 16 ones


delay : Int
delay =
    Bitwise.shiftLeftBy 16 ones


bezierOne : Int
bezierOne =
    Bitwise.shiftRightZfBy 24 ones


bezierTwo : Int
bezierTwo =
    Bitwise.and
        (Bitwise.shiftLeftBy 8 ones)
        (Bitwise.shiftRightZfBy 16 ones)


bezierTwoOffset : Int
bezierTwoOffset =
    8


bezierThree : Int
bezierThree =
    Bitwise.and
        (Bitwise.shiftLeftBy 16 ones)
        (Bitwise.shiftRightZfBy 8 ones)


bezierThreeOffset : Int
bezierThreeOffset =
    16


bezierFour : Int
bezierFour =
    Bitwise.shiftLeftBy 24 ones


bezierFourOffset : Int
bezierFourOffset =
    24
