module Tests exposing (suite)

{-| Direct tests of production Internal.BitField behaviour.

These tests replace the old test-local encoder replicas with assertions against
the real BitField API so that any production regression is caught here.

-}

import Bitwise
import Expect
import Fuzz
import Internal.BitField as BitField exposing (BitField, Bits)
import Test exposing (Test)


suite : Test
suite =
    Test.describe "Internal.BitField"
        [ knownValueTests
        , isolationTests
        , clampingTests
        , clearTests
        , copyTests
        , booleanTests
        , boundaryTests
        , percentageTests
        ]



-- ─── Field definitions used throughout ───────────────────────────────────────


type TestEncoding
    = TestEncoding


{-| 4-bit field at offset 0 (bits 0-3)
-}
low4 : BitField TestEncoding
low4 =
    BitField.first 4


{-| 4-bit field at offset 4 (bits 4-7)
-}
mid4 : BitField TestEncoding
mid4 =
    BitField.next 4 low4


{-| 8-bit field at offset 8 (bits 8-15)
-}
high8 : BitField TestEncoding
high8 =
    BitField.next 8 mid4


{-| 1-bit boolean flag at offset 16
-}
flag1 : BitField TestEncoding
flag1 =
    BitField.next 1 high8


{-| A second 1-bit flag at offset 17
-}
flag2 : BitField TestEncoding
flag2 =
    BitField.next 1 flag1



-- ─── Known-value tests ────────────────────────────────────────────────────────


knownValueTests : Test
knownValueTests =
    Test.describe "Known values"
        [ Test.test "get returns 0 on init" <|
            \_ ->
                Expect.equal 0 (BitField.get low4 BitField.init)
        , Test.test "set low4 to 5 and get it back" <|
            \_ ->
                BitField.init
                    |> BitField.set low4 5
                    |> BitField.get low4
                    |> Expect.equal 5
        , Test.test "set mid4 to 9 and get it back" <|
            \_ ->
                BitField.init
                    |> BitField.set mid4 9
                    |> BitField.get mid4
                    |> Expect.equal 9
        , Test.test "set high8 to 200 and get it back" <|
            \_ ->
                BitField.init
                    |> BitField.set high8 200
                    |> BitField.get high8
                    |> Expect.equal 200
        , Test.test "two fields round-trip without interference (low4=7, mid4=3)" <|
            \_ ->
                let
                    bits =
                        BitField.init
                            |> BitField.set low4 7
                            |> BitField.set mid4 3
                in
                Expect.equal ( 7, 3 )
                    ( BitField.get low4 bits, BitField.get mid4 bits )
        , Test.test "three fields round-trip (low4=15, mid4=1, high8=42)" <|
            \_ ->
                let
                    bits =
                        BitField.init
                            |> BitField.set low4 15
                            |> BitField.set mid4 1
                            |> BitField.set high8 42
                in
                Expect.equal ( 15, 1, 42 )
                    ( BitField.get low4 bits
                    , BitField.get mid4 bits
                    , BitField.get high8 bits
                    )
        ]



-- ─── Isolation tests ─────────────────────────────────────────────────────────


isolationTests : Test
isolationTests =
    Test.describe "Field isolation"
        [ Test.test "setting low4 does not change mid4" <|
            \_ ->
                let
                    bits =
                        BitField.init
                            |> BitField.set mid4 6
                            |> BitField.set low4 15
                in
                Expect.equal 6 (BitField.get mid4 bits)
        , Test.test "setting mid4 does not change low4" <|
            \_ ->
                let
                    bits =
                        BitField.init
                            |> BitField.set low4 3
                            |> BitField.set mid4 7
                in
                Expect.equal 3 (BitField.get low4 bits)
        , Test.test "setting high8 does not disturb low or mid fields" <|
            \_ ->
                let
                    bits =
                        BitField.init
                            |> BitField.set low4 5
                            |> BitField.set mid4 2
                            |> BitField.set high8 255
                in
                Expect.equal ( 5, 2 )
                    ( BitField.get low4 bits, BitField.get mid4 bits )
        , Test.fuzz3
            (Fuzz.intRange 0 15)
            (Fuzz.intRange 0 15)
            (Fuzz.intRange 0 255)
            "Fuzz: all three fields round-trip independently"
          <|
            \a b c ->
                let
                    bits =
                        BitField.init
                            |> BitField.set low4 a
                            |> BitField.set mid4 b
                            |> BitField.set high8 c
                in
                Expect.equal ( a, b, c )
                    ( BitField.get low4 bits
                    , BitField.get mid4 bits
                    , BitField.get high8 bits
                    )
        ]



-- ─── Clamping tests ───────────────────────────────────────────────────────────


clampingTests : Test
clampingTests =
    Test.describe "Clamping"
        [ Test.test "set clamps negative value to 0" <|
            \_ ->
                BitField.init
                    |> BitField.set low4 -5
                    |> BitField.get low4
                    |> Expect.equal 0
        , Test.test "set clamps value exceeding max to field max (low4 max = 15)" <|
            \_ ->
                BitField.init
                    |> BitField.set low4 999
                    |> BitField.get low4
                    |> Expect.equal 15
        , Test.test "set clamps value exceeding high8 max (255)" <|
            \_ ->
                BitField.init
                    |> BitField.set high8 1000
                    |> BitField.get high8
                    |> Expect.equal 255
        , Test.test "setPercentage clamps negative to 0" <|
            \_ ->
                BitField.init
                    |> BitField.setPercentage low4 -0.5
                    |> BitField.getPercentage low4
                    |> Expect.within (Expect.Absolute 0.001) 0.0
        , Test.test "setPercentage clamps above 1.0 to 1.0" <|
            \_ ->
                BitField.init
                    |> BitField.setPercentage low4 2.0
                    |> BitField.getPercentage low4
                    |> Expect.within (Expect.Absolute 0.001) 1.0
        ]



-- ─── Clear tests ─────────────────────────────────────────────────────────────


clearTests : Test
clearTests =
    Test.describe "Clear"
        [ Test.test "clear zeroes the target field" <|
            \_ ->
                BitField.init
                    |> BitField.set low4 12
                    |> BitField.clear low4
                    |> BitField.get low4
                    |> Expect.equal 0
        , Test.test "clear does not disturb adjacent field" <|
            \_ ->
                let
                    bits =
                        BitField.init
                            |> BitField.set low4 5
                            |> BitField.set mid4 9
                            |> BitField.clear low4
                in
                Expect.equal ( 0, 9 )
                    ( BitField.get low4 bits, BitField.get mid4 bits )
        ]



-- ─── Copy tests ──────────────────────────────────────────────────────────────


copyTests : Test
copyTests =
    Test.describe "Copy"
        [ Test.test "copy moves a field from source to destination" <|
            \_ ->
                let
                    src =
                        BitField.init |> BitField.set low4 11

                    dst =
                        BitField.init |> BitField.set low4 0
                in
                BitField.copy low4 src dst
                    |> BitField.get low4
                    |> Expect.equal 11
        , Test.test "copy does not disturb other fields in destination" <|
            \_ ->
                let
                    src =
                        BitField.init |> BitField.set low4 7

                    dst =
                        BitField.init |> BitField.set mid4 13
                in
                let
                    result =
                        BitField.copy low4 src dst
                in
                Expect.equal ( 7, 13 )
                    ( BitField.get low4 result, BitField.get mid4 result )
        ]



-- ─── Boolean / flag tests ────────────────────────────────────────────────────


booleanTests : Test
booleanTests =
    Test.describe "Boolean flags"
        [ Test.test "flipIf True sets the flag" <|
            \_ ->
                BitField.init
                    |> BitField.flipIf flag1 True
                    |> BitField.has flag1
                    |> Expect.equal True
        , Test.test "flipIf False leaves the flag unset" <|
            \_ ->
                BitField.init
                    |> BitField.flipIf flag1 False
                    |> BitField.has flag1
                    |> Expect.equal False
        , Test.test "flip True sets the flag" <|
            \_ ->
                BitField.init
                    |> BitField.flip flag1 True
                    |> BitField.has flag1
                    |> Expect.equal True
        , Test.test "flip False clears a previously set flag" <|
            \_ ->
                BitField.init
                    |> BitField.flip flag1 True
                    |> BitField.flip flag1 False
                    |> BitField.has flag1
                    |> Expect.equal False
        , Test.test "setting flag1 does not set flag2" <|
            \_ ->
                BitField.init
                    |> BitField.flipIf flag1 True
                    |> BitField.has flag2
                    |> Expect.equal False
        , Test.test "setting flag2 does not set flag1" <|
            \_ ->
                BitField.init
                    |> BitField.flipIf flag2 True
                    |> BitField.has flag1
                    |> Expect.equal False
        , Test.test "both flags can be set independently" <|
            \_ ->
                let
                    bits =
                        BitField.init
                            |> BitField.flipIf flag1 True
                            |> BitField.flipIf flag2 True
                in
                Expect.equal ( True, True )
                    ( BitField.has flag1 bits, BitField.has flag2 bits )
        , Test.test "has returns False on init" <|
            \_ ->
                BitField.init
                    |> BitField.has flag1
                    |> Expect.equal False
        , Test.test "isZeroLength: flag1 (length 1) is not zero-length" <|
            \_ ->
                BitField.isZeroLength flag1
                    |> Expect.equal False
        , Test.test "isZeroLength: first 0 is zero-length" <|
            \_ ->
                BitField.first 0
                    |> BitField.isZeroLength
                    |> Expect.equal True
        ]



-- ─── Boundary tests ───────────────────────────────────────────────────────────


boundaryTests : Test
boundaryTests =
    Test.describe "Boundary conditions"
        [ Test.test "init equals none" <|
            \_ ->
                Expect.equal BitField.init BitField.none
        , Test.test "toInt (fromInt n) == n for 0" <|
            \_ ->
                Expect.equal 0 (BitField.toInt (BitField.fromInt 0))
        , Test.test "toInt (fromInt n) == n for 42" <|
            \_ ->
                Expect.equal 42 (BitField.toInt (BitField.fromInt 42))
        , Test.test "equal: same value is equal" <|
            \_ ->
                Expect.equal True (BitField.equal 7 7)
        , Test.test "equal: different values are not equal" <|
            \_ ->
                Expect.equal False (BitField.equal 7 8)
        , Test.test "fieldEqual: same field is equal to itself" <|
            \_ ->
                Expect.equal True (BitField.fieldEqual low4 low4)
        , Test.test "fieldEqual: different fields are not equal" <|
            \_ ->
                Expect.equal False (BitField.fieldEqual low4 mid4)
        , Test.test "merge ORs two bit sets" <|
            \_ ->
                let
                    a =
                        BitField.init |> BitField.set low4 5

                    b =
                        BitField.init |> BitField.set mid4 3
                in
                Expect.equal
                    (BitField.get low4 (BitField.merge a b))
                    5
        , Test.test "first 32 produces a full 32-bit mask (set clamps to max)" <|
            \_ ->
                let
                    full =
                        BitField.first 32
                in
                -- set to max value of a 32-bit field; result should be all ones (as unsigned)
                -- Elm uses signed 32-bit ints so we check the raw int via toInt
                BitField.init
                    |> BitField.set full 0x7FFFFFFF
                    |> BitField.get full
                    |> Expect.equal 0x7FFFFFFF
        , Test.fuzz (Fuzz.intRange 0 255) "set/get round-trips for all values in high8" <|
            \v ->
                BitField.init
                    |> BitField.set high8 v
                    |> BitField.get high8
                    |> Expect.equal v
        ]



-- ─── Percentage round-trip tests ──────────────────────────────────────────────


percentageTests : Test
percentageTests =
    Test.describe "Percentage round-trip"
        [ Test.test "setPercentage 0.0 then getPercentage returns ~0" <|
            \_ ->
                BitField.init
                    |> BitField.setPercentage high8 0.0
                    |> BitField.getPercentage high8
                    |> Expect.within (Expect.Absolute 0.005) 0.0
        , Test.test "setPercentage 1.0 then getPercentage returns ~1" <|
            \_ ->
                BitField.init
                    |> BitField.setPercentage high8 1.0
                    |> BitField.getPercentage high8
                    |> Expect.within (Expect.Absolute 0.005) 1.0
        , Test.test "setPercentage 0.5 then getPercentage returns ~0.5" <|
            \_ ->
                BitField.init
                    |> BitField.setPercentage high8 0.5
                    |> BitField.getPercentage high8
                    |> Expect.within (Expect.Absolute 0.005) 0.5
        , Test.fuzz (Fuzz.floatRange 0.0 1.0) "Fuzz percentage round-trips within 8-bit precision" <|
            \pct ->
                BitField.init
                    |> BitField.setPercentage high8 pct
                    |> BitField.getPercentage high8
                    |> Expect.within (Expect.Absolute 0.005) pct
        ]
