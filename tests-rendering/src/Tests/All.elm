module Tests.All exposing (main)

{-| -}

import ClippedElInFixedWidthColumn
import ElInFixedHeightColumn
import InFrontSize
import Layout.SafariBugIssue147
import NestedParagraphs
import StackedScrollingColumnsHeight
import Testable.Generator
import Testable.Runner
import Tests.Basic
import Tests.ColumnAlignment
import Tests.ColumnSpacing
import Tests.ElementAlignment
import Tests.Nearby
import Tests.RowAlignment
import Tests.RowSpacing
import Tests.TextWrapping
import Tests.Transparency
import WeirdCentering


main : Testable.Runner.TestableProgram
main =
    (Testable.Runner.program << List.concat)
        [ Testable.Generator.element "Basics"
            []

        -- , Testable.Generator.element "Align "
        --     []
        -- , [ Tuple.pair
        --         "Basic Element"
        --         Tests.Basic.view
        --   , Tuple.pair "Nearby" Tests.Nearby.view
        --   , Tuple.pair "Element Alignment" Tests.ElementAlignment.view
        --   , Tuple.pair "Transparency" Tests.Transparency.view
        --   , Tuple.pair "Column Alignment" Tests.ColumnAlignment.view
        --   -- This has 12k cases, so it runs slow and sometimes crashes IE
        --   , Tuple.pair "Row Alignment" Tests.RowAlignment.view
        --   , Tuple.pair "Column Spacing" Tests.ColumnSpacing.view
        --   , Tuple.pair "Row Spacing"
        --         Tests.RowSpacing.view
        --   ]
        -- , [ Tuple.pair "Paragraph wrapping" Tests.TextWrapping.view
        --   ]
        -- , issues
        ]


issues =
    [ --    Testable.Runner.rename "Weird Centering" WeirdCentering.view
      -- , Testable.Runner.rename "Stacked scrolling columns height" StackedScrollingColumnsHeight.view
      -- ,
      Testable.Runner.rename "Safari bug issue147" Layout.SafariBugIssue147.view

    -- , Testable.Runner.rename "Nested paragraphs" NestedParagraphs.view
    -- , Testable.Runner.rename "In front size" InFrontSize.view
    -- , Testable.Runner.rename "El in fixed height column" ElInFixedHeightColumn.view
    -- , Testable.Runner.rename "Clipped el in fixed width column" ClippedElInFixedWidthColumn.view
    ]
