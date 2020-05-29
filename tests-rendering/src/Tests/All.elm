module Tests.All exposing (main)

{-| -}

import Layout.NestedParagraphs
import Layout.SafariBugIssue147
import Testable.Generator
import Testable.Runner
import Tests.Alignment
import Tests.Nearby
import Tests.Spacing
import Tests.TextWrapping
import Tests.Transparency


main : Testable.Runner.TestableProgram
main =
    (Testable.Runner.program << List.concat)
        [ Testable.Generator.elementInLayout "Basics" []
        , Tests.Nearby.view
        , Tests.Alignment.view
        , Tests.Spacing.view

        -- [
        -- , Tuple.pair "Transparency" Tests.Transparency.view
        -- ]
        -- , [ Tuple.pair "Paragraph wrapping" Tests.TextWrapping.view
        --   ]
        , issues
        ]


issues =
    [ --    Testable.Runner.rename "Weird Centering" WeirdCentering.view
      -- , Testable.Runner.rename "Stacked scrolling columns height" StackedScrollingColumnsHeight.view
      -- ,
      Testable.Runner.rename "Safari bug issue147" Layout.SafariBugIssue147.view
    , Testable.Runner.rename "Nested paragraphs" Layout.NestedParagraphs.view

    -- , Testable.Runner.rename "Issue 22, zIndex" Nearby.Issue22ZIndex.view
    -- , Testable.Runner.rename "inFrontIssue" Nearby.InFrontIssue.view
    -- , Testable.Runner.rename "El in fixed height column" ElInFixedHeightColumn.view
    -- , Testable.Runner.rename "Clipped el in fixed width column" ClippedElInFixedWidthColumn.view
    ]
