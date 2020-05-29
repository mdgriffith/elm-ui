module Tests.Alignment exposing (view)

{-| Testing nearby elements such as those defined with `above`, `below`, etc.
-}

import Testable
import Testable.Element exposing (..)
import Testable.Element.Background as Background
import Testable.Element.Font as Font
import Testable.Generator
import Tests.Palette as Palette exposing (..)


box attrs =
    el
        ([ width (px 50)
         , height (px 50)
         , Background.color blue
         ]
            ++ attrs
        )
        none


{-| -}
view : List ( String, Testable.Element msg )
view =
    List.concat
        [ Testable.Generator.generate "Alignments"
            (\layout element alignment ->
                layout
                    [ width (px 800)
                    , height (px 800)
                    , Background.color lightGrey
                    ]
                    (element
                        ([ width (px 200)
                         , height (px 200)
                         , Background.color red
                         ]
                            ++ alignment
                        )
                        none
                    )
            )
            |> Testable.Generator.with Testable.Generator.allLayouts
            |> Testable.Generator.with Testable.Generator.allElements
            |> Testable.Generator.with Testable.Generator.allAlignments
        ]
