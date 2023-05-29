module BitfieldBench exposing (..)

import Benchmark exposing (Benchmark)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Bitwise
import Dict
import Html
import Html.Attributes
import Internal.BitField as BitField exposing (BitField)
import Internal.Bits.Analyze as AnalyzeBits
import Internal.Flag as Flag
import Json.Encode
import Set


main : BenchmarkProgram
main =
    program <|
        Benchmark.describe "sample"
            [ flagOperations
            , analyze
            ]


flagOperations =
    Benchmark.describe "Flag Operations"
        [ Benchmark.benchmark "check if present" <|
            \_ ->
                Flag.present Flag.height Flag.none
        , Benchmark.benchmark "add to flag" <|
            \_ ->
                Flag.add Flag.height Flag.none
        ]


analyze =
    Benchmark.describe "Bitfield - Analyze"
        [ Benchmark.benchmark "Check many" <|
            \_ ->
                BitField.init
                    |> BitField.flipIf AnalyzeBits.transforms True
                    |> BitField.flipIf AnalyzeBits.nearbys False
                    |> BitField.flipIf AnalyzeBits.cssVars
                        False
                    |> BitField.flipIf AnalyzeBits.isLink
                        True
                    |> BitField.flipIf AnalyzeBits.isButton
                        (True
                            && not (BitField.has AnalyzeBits.isLink BitField.init)
                        )

        {-

           first
               |> Bitwise.or (Bitwise.and (fromBool True)  AnalyzeBits.transforms )



        -}
        , Benchmark.benchmark "Check in one go" <|
            \_ ->
                -- BitField.init
                0
                    |> Bitwise.or
                        (if True then
                            exampleField

                         else
                            zero
                        )
                    |> Bitwise.or
                        (if True then
                            exampleField

                         else
                            zero
                        )
                    |> Bitwise.or
                        (if True then
                            exampleField

                         else
                            zero
                        )
                    |> Bitwise.or
                        (if True then
                            exampleField

                         else
                            zero
                        )
                    |> Bitwise.or
                        (if True then
                            exampleField

                         else
                            zero
                        )

        -- |> BitField.flipIf AnalyzeBits.transforms True
        -- |> BitField.flipIf AnalyzeBits.nearbys False
        -- |> BitField.flipIf AnalyzeBits.cssVars
        --     False
        -- |> BitField.flipIf AnalyzeBits.isLink
        --     True
        -- |> BitField.flipIf AnalyzeBits.isButton
        --     (True
        --         && not (BitField.has AnalyzeBits.isLink BitField.init)
        --     )
        ]


exampleField =
    45


zero =
    0
