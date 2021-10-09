module Tests exposing (main)

{-| This is the main entrypoint for running tests.
-}

import Layout.NestedParagraphs
import Layout.SafariBugIssue147
import Testable.Element exposing (..)
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
        [ --Testable.Generator.elementInLayout "Basics" []
          [ layout [ height fill ] <|
                el [ height fill ] <|
                    column
                        [ height fill ]
                        [ el [] <| text "Element that Safari gives height 0, if inside an el and not just text."
                        , text "Text below the el above"
                        ]
          ]

        -- , Tests.Nearby.view
        -- , Tests.Alignment.view
        -- , Tests.Spacing.view
        -- [
        -- , Tuple.pair "Transparency" Tests.Transparency.view
        -- ]
        -- , [ Tuple.pair "Paragraph wrapping" Tests.TextWrapping.view
        --   ]
        -- , issues
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
