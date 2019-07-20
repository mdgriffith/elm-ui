port module Tests.Run exposing (main)

{-| -}

import Testable.Runner
import Tests.Basic
import Tests.ColumnAlignment
import Tests.ColumnSpacing
import Tests.ElementAlignment
import Tests.Nearby
import Tests.RowAlignment
import Tests.RowSpacing
import Tests.Transparency


main : Testable.Runner.TestableProgram
main =
    Testable.Runner.program
        [ Tuple.pair "Basic Element" Tests.Basic.view
        , Tuple.pair "Nearby" Tests.Nearby.view
        , Tuple.pair "Element Alignment" Tests.ElementAlignment.view
        , Tuple.pair "Transparency" Tests.Transparency.view
        , Tuple.pair "Column Alignment" Tests.ColumnAlignment.view

        -- This has 12k cases, so it runs slow and sometimes crashes IE
        , Tuple.pair "Row Alignment" Tests.RowAlignment.view
        , Tuple.pair "Column Spacing" Tests.ColumnSpacing.view
        , Tuple.pair "Row Spacing" Tests.RowSpacing.view
        ]
