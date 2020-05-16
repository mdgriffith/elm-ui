module NestedParagraphs exposing (view)

{-| Paragraph with children more than one level deep breaks flow

<https://github.com/mdgriffith/elm-ui/issues/173>

First of all, thanks for such a pleasant library to use! It's been awesome not having to use CSS.

The problem I ran into is that paragraph only seems correctly flow text in children a single level deep. As an example, I made an Ellie demonstrating this with an el within a link within a paragraph:

<https://ellie-app.com/7JcgLRNprF7a1>

This might be a regression, as the resolved #50 and #103 seem to refer to the same problem.

Expected behavior
Text should flow with no breaks in the paragraph.

Versions

    OS: macOS
    Browser: Firefox
    Browser Version: 71.0
    Elm Version: 0.19.1
    Elm UI Version: 1.1.5

-}

import Testable.Element as Element exposing (..)
import Testable.Element.Font as Font


view =
    layout [] <|
        column []
            [ paragraph []
                [ text "This is a paragraph with a "
                , el [ Font.bold ] <| text "child"
                , text " of depth one."
                ]
            , paragraph []
                [ text "This is a paragraph with a "
                , link []
                    { label =
                        el [ Font.bold ] <|
                            text "child"
                    , url = "http://example.com"
                    }
                , text " of depth two."
                ]
            ]
