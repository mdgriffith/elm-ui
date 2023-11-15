module Internal.Flag exposing (..)
{-| THIS FILE IS GENERATED, NO TOUCHY 

This file is generated via 'npm run stylesheet' in the elm-ui repository
  
-}


import Internal.BitField as BitField exposing (BitField, Bits)


type IsFlag = IsFlag


type alias Field
    = Bits


type alias Flag
    = BitField IsFlag


none : Field
none =
    BitField.init


{-| Add a flag to a field.
-}
add : Flag -> Field -> Field
add myFlag myField =
   BitField.flipIf myFlag True myField


skip : Flag 
skip =
    BitField.first 0



padding : Flag
padding =
    BitField.next 1 skip


spacing : Flag
spacing =
    BitField.next 1 padding


fontSize : Flag
fontSize =
    BitField.next 1 spacing


fontFamily : Flag
fontFamily =
    BitField.next 1 fontSize


width : Flag
width =
    BitField.next 1 fontFamily


height : Flag
height =
    BitField.next 1 width


fontAlignment : Flag
fontAlignment =
    BitField.next 1 height


fontWeight : Flag
fontWeight =
    BitField.next 1 fontAlignment


fontColor : Flag
fontColor =
    BitField.next 1 fontWeight


fontGradient : Flag
fontGradient =
    BitField.next 1 fontColor


fontAdjustment : Flag
fontAdjustment =
    BitField.next 1 fontGradient


fontEllipsis : Flag
fontEllipsis =
    BitField.next 1 fontAdjustment


id : Flag
id =
    BitField.next 1 fontEllipsis


txtShadows : Flag
txtShadows =
    BitField.next 1 id


shadows : Flag
shadows =
    BitField.next 1 txtShadows


overflow : Flag
overflow =
    BitField.next 1 shadows


cursor : Flag
cursor =
    BitField.next 1 overflow


transform : Flag
transform =
    BitField.next 1 cursor


borderWidth : Flag
borderWidth =
    BitField.next 1 transform


yAlign : Flag
yAlign =
    BitField.next 1 borderWidth


xAlign : Flag
xAlign =
    BitField.next 1 yAlign


xContentAlign : Flag
xContentAlign =
    BitField.next 1 xAlign


yContentAlign : Flag
yContentAlign =
    BitField.next 1 xContentAlign


focus : Flag
focus =
    BitField.next 1 yContentAlign


active : Flag
active =
    BitField.next 1 focus


hover : Flag
hover =
    BitField.next 1 active


gridTemplate : Flag
gridTemplate =
    BitField.next 1 hover


gridPosition : Flag
gridPosition =
    BitField.next 1 gridTemplate


widthBetween : Flag
widthBetween =
    BitField.next 1 gridPosition


heightBetween : Flag
heightBetween =
    BitField.next 1 widthBetween


background : Flag
background =
    BitField.next 1 heightBetween


event : Flag
event =
    BitField.next 1 background


