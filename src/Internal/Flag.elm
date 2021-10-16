module Internal.Flag exposing (..)
{-| THIS FILE IS GENERATED, NOT TOUCHY -}


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

type Flag
    = Flag Int

none : Field
none =
    Field 0


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

{-| Generally you want to use add, which keeps a distinction between Fields and Flags.

Merging will combine two fields

-}
merge : Field -> Field -> Field
merge (Field one) (Field three) =
    Field (Bitwise.or one three)


equal : Flag -> Flag -> Bool
equal (Flag one) (Flag two) =
    one - two == 0


flag : Int -> Flag
flag i =
    Flag
        (Bitwise.shiftLeftBy i 1)




skip : Flag
skip =
    flag 0


padding : Flag
padding =
    flag 1


spacing : Flag
spacing =
    flag 2


fontSize : Flag
fontSize =
    flag 3


fontFamily : Flag
fontFamily =
    flag 4


width : Flag
width =
    flag 5


height : Flag
height =
    flag 6


fontAlignment : Flag
fontAlignment =
    flag 7


fontWeight : Flag
fontWeight =
    flag 8


fontColor : Flag
fontColor =
    flag 9


fontAdjustment : Flag
fontAdjustment =
    flag 10


id : Flag
id =
    flag 11


txtShadows : Flag
txtShadows =
    flag 12


shadows : Flag
shadows =
    flag 13


overflow : Flag
overflow =
    flag 14


cursor : Flag
cursor =
    flag 15


transform : Flag
transform =
    flag 16


borderWidth : Flag
borderWidth =
    flag 17


yAlign : Flag
yAlign =
    flag 18


xAlign : Flag
xAlign =
    flag 19


focus : Flag
focus =
    flag 20


active : Flag
active =
    flag 21


hover : Flag
hover =
    flag 22


gridTemplate : Flag
gridTemplate =
    flag 23


gridPosition : Flag
gridPosition =
    flag 24


widthBetween : Flag
widthBetween =
    flag 25


heightBetween : Flag
heightBetween =
    flag 26


isLink : Flag
isLink =
    flag 27


