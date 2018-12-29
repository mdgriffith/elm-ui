module Flags exposing (suite)

{-| -}

import Expect
import Html
import Internal.Flag as Flag
import Test


suite =
    Test.describe "Flag Operations"
        [ Test.test "All Flags Invalidate Themselves" <|
            \_ ->
                Expect.equal True (List.all (\flag -> Flag.present flag (Flag.add flag Flag.none)) allFlags)
        , Test.test "All Flags don't interfere with each other" <|
            \_ ->
                Expect.equal True (List.all (doesntInvalidateOthers allFlags) allFlags)
        ]


doesntInvalidateOthers others flag =
    let
        withFlag =
            Flag.none
                |> Flag.add flag
    in
    List.all identity <|
        List.map
            (\otherFlag ->
                Flag.present otherFlag (Flag.add otherFlag withFlag)
            )
            others


allFlags =
    [ Flag.transparency
    , Flag.padding
    , Flag.spacing
    , Flag.fontSize
    , Flag.fontFamily
    , Flag.width
    , Flag.height
    , Flag.bgColor
    , Flag.bgImage
    , Flag.bgGradient
    , Flag.borderStyle
    , Flag.fontAlignment
    , Flag.fontWeight
    , Flag.fontColor
    , Flag.wordSpacing
    , Flag.letterSpacing
    , Flag.borderRound
    , Flag.shadows
    , Flag.overflow
    , Flag.cursor
    , Flag.scale
    , Flag.rotate
    , Flag.moveX
    , Flag.moveY
    , Flag.borderWidth
    , Flag.borderColor
    , Flag.yAlign
    , Flag.xAlign
    , Flag.focus
    , Flag.active
    , Flag.hover
    , Flag.gridTemplate
    , Flag.gridPosition
    , Flag.heightContent
    , Flag.heightFill
    , Flag.widthContent
    , Flag.widthFill
    , Flag.alignRight
    , Flag.alignBottom
    , Flag.centerX
    , Flag.centerY
    , Flag.fontVariant
    ]
