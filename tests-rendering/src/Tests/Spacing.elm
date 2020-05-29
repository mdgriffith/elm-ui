module Tests.Spacing exposing (view)

{-| Test that spacing works
-}

import Testable
import Testable.Element exposing (..)
import Testable.Element.Background as Background
import Testable.Element.Font as Font
import Testable.Generator
import Tests.Palette as Palette exposing (..)


{-| -}
view : List ( String, Testable.Element msg )
view =
    List.concat
        [ Testable.Generator.generate "Spacing"
            (\layout element ->
                layout
                    [ width (px 800)
                    , height (px 800)
                    , Background.color lightGrey
                    , spacing 20
                    ]
                    (element
                        [ width (px 200)
                        , height (px 200)
                        , Background.color red
                        ]
                        none
                    )
            )
            |> Testable.Generator.with Testable.Generator.allLayouts
            |> Testable.Generator.with Testable.Generator.allElements
        ]
