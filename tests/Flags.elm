module Flags exposing (suite)

{-| -}

import Expect
import Generated.Inventories exposing (allFlags)
import Internal.BitField as BitField
import Internal.Flag as Flag
import Test


suite =
    Test.describe "Flag Operations"
        [ Test.test "Can be set to true" <|
            \_ ->
                Expect.equal True
                    (List.all
                        (\flag ->
                            BitField.has flag (Flag.add flag Flag.none)
                        )
                        allFlags
                    )
        , Test.test "All Flags don't interfere with each other" <|
            \_ ->
                Expect.equal True (List.all (doesntInvalidateOthers allFlags) allFlags)
        , Test.test "Other flags aren't set by setting one flag" <|
            \_ ->
                Expect.equal True (List.all (isolated allFlags) allFlags)
        , Test.test "Flipping a zero length flag doesn't flip others" <|
            \_ ->
                Expect.equal True (isolated allFlags Flag.skip)
        ]


isolated others flag =
    let
        othersNotThisOne =
            List.filter (not << BitField.fieldEqual flag) others

        withFlag =
            Flag.none
                |> BitField.flipIf flag True

        -- |> Flag.add flag
    in
    List.all
        (\otherFlag ->
            not (BitField.has otherFlag withFlag)
        )
        othersNotThisOne


doesntInvalidateOthers others flag =
    let
        withFlag =
            Flag.none
                |> Flag.add flag
    in
    List.all
        (\otherFlag ->
            let
                withBoth =
                    Flag.add otherFlag withFlag
            in
            BitField.has otherFlag withBoth
                && BitField.has flag withBoth
        )
        others
