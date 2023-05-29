module Internal.Flag exposing (..)
{-| THIS FILE IS GENERATED, NO TOUCHY -}


import Bitwise


value : Field -> Int
value (Field int) =
    int


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


fontGradient : Flag
fontGradient =
    flag 9


fontAdjustment : Flag
fontAdjustment =
    flag 10


fontEllipsis : Flag
fontEllipsis =
    flag 11


id : Flag
id =
    flag 12


txtShadows : Flag
txtShadows =
    flag 13


shadows : Flag
shadows =
    flag 14


overflow : Flag
overflow =
    flag 15


cursor : Flag
cursor =
    flag 16


transform : Flag
transform =
    flag 17


borderWidth : Flag
borderWidth =
    flag 18


yAlign : Flag
yAlign =
    flag 19


xAlign : Flag
xAlign =
    flag 20


focus : Flag
focus =
    flag 21


active : Flag
active =
    flag 22


hover : Flag
hover =
    flag 23


gridTemplate : Flag
gridTemplate =
    flag 24


gridPosition : Flag
gridPosition =
    flag 25


widthBetween : Flag
widthBetween =
    flag 26


heightBetween : Flag
heightBetween =
    flag 27


background : Flag
background =
    flag 28


event : Flag
event =
    flag 29


