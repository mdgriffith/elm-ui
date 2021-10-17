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
    Flag 0




padding : Flag
padding =
    flag 0


spacing : Flag
spacing =
    flag 1


fontSize : Flag
fontSize =
    flag 2


fontFamily : Flag
fontFamily =
    flag 3


width : Flag
width =
    flag 4


height : Flag
height =
    flag 5


fontAlignment : Flag
fontAlignment =
    flag 6


fontWeight : Flag
fontWeight =
    flag 7


fontColor : Flag
fontColor =
    flag 8


fontAdjustment : Flag
fontAdjustment =
    flag 9


id : Flag
id =
    flag 10


txtShadows : Flag
txtShadows =
    flag 11


shadows : Flag
shadows =
    flag 12


overflow : Flag
overflow =
    flag 13


cursor : Flag
cursor =
    flag 14


transform : Flag
transform =
    flag 15


borderWidth : Flag
borderWidth =
    flag 16


yAlign : Flag
yAlign =
    flag 17


xAlign : Flag
xAlign =
    flag 18


focus : Flag
focus =
    flag 19


active : Flag
active =
    flag 20


hover : Flag
hover =
    flag 21


gridTemplate : Flag
gridTemplate =
    flag 22


gridPosition : Flag
gridPosition =
    flag 23


widthBetween : Flag
widthBetween =
    flag 24


heightBetween : Flag
heightBetween =
    flag 25


isLink : Flag
isLink =
    flag 26


