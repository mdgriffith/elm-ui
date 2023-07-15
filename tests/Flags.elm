module Flags exposing (suite)

{-| -}

import Expect
import Internal.BitField as BitField
import Internal.Flag as Flag
import Test


suite =
    Test.describe "Flag Operations"
        [ Test.test "All Flags Invalidate Themselves" <|
            \_ ->
                Expect.equal True (List.all (\flag -> BitField.has flag (Flag.add flag Flag.none)) allFlags)
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
                BitField.has otherFlag (Flag.add otherFlag withFlag)
            )
            others


allFlags =
    [ Flag.padding
    , Flag.spacing
    , Flag.fontSize
    , Flag.fontFamily
    , Flag.width
    , Flag.height
    , Flag.fontAlignment
    , Flag.fontWeight
    , Flag.fontColor
    , Flag.fontGradient
    , Flag.fontAdjustment
    , Flag.fontEllipsis
    , Flag.id
    , Flag.txtShadows
    , Flag.shadows
    , Flag.overflow
    , Flag.cursor
    , Flag.transform
    , Flag.borderWidth
    , Flag.yAlign
    , Flag.xAlign
    , Flag.focus
    , Flag.active
    , Flag.hover
    , Flag.gridTemplate
    , Flag.gridPosition
    , Flag.widthBetween
    , Flag.heightBetween
    , Flag.background
    , Flag.event
    ]
