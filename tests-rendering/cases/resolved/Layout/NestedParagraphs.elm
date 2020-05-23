module Layout.NestedParagraphs exposing (view)

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
import Testable.Generator


view =
    layout [] <|
        column [ spacing 48 ]
            [ paragraph []
                [ text "This is a paragraph with a "
                , el [ Font.bold ] <| text "child"
                , text " of depth one."
                ]
            , paragraph []
                [ text "This is a paragraph with a "
                , link []
                    { label =
                        el [ Font.bold ]
                            (text Testable.Generator.lorem)
                    , url = "http://example.com"
                    }
                , text " of depth two."
                ]
            , el [ Font.size 32 ] (text "Many nested els")
            , paragraph []
                [ text "This is a paragraph with a "
                , link []
                    { label =
                        el [ Font.bold ]
                            (text Testable.Generator.lorem)
                    , url = "http://example.com"
                    }
                , text " of depth two."
                , el [] (el [] (el [] (text Testable.Generator.lorem)))
                , el [] (el [] (el [] (el [] (text Testable.Generator.lorem))))
                ]
            , el [ Font.size 32 ] (text "NestedParas in els")
            , paragraph []
                [ text "This is a paragraph with a "
                , link []
                    { label =
                        el [ Font.bold ]
                            (text Testable.Generator.lorem)
                    , url = "http://example.com"
                    }
                , text " of depth two."
                , el [] (el [] (el [] (text Testable.Generator.lorem)))
                , el []
                    (paragraph []
                        [ el []
                            (el [] (text Testable.Generator.lorem))
                        ]
                    )
                ]
            , el [ Font.size 32 ] (text "Nested with link")
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
            , el [ Font.size 32 ] (text "Para with boxes")
            , paragraph []
                [ text Testable.Generator.short
                , Testable.Generator.box
                , text Testable.Generator.short

                -- , text Testable.Generator.lorem
                , Testable.Generator.box
                ]
            , el [ Font.size 32 ] (text "Row with boxes")
            , paragraph []
                [ text Testable.Generator.short
                , row [ spacing 25 ]
                    [ Testable.Generator.box
                    , text Testable.Generator.short
                    , Testable.Generator.box

                    -- , text Testable.Generator.lorem
                    ]
                , text Testable.Generator.short

                -- , text Testable.Generator.lorem
                , Testable.Generator.box
                , paragraph []
                    [ text "This is a paragraph with a "
                    , el [ Font.bold ] <| text "child"
                    , text " of depth one."
                    ]
                ]
            , el [ Font.size 32 ] (text "Row with boxes and lots of content")
            , paragraph []
                [ column [ alignLeft ]
                    [ Testable.Generator.box, Testable.Generator.box, Testable.Generator.box ]
                , text Testable.Generator.short
                , row [ spacing 25 ]
                    [ Testable.Generator.box
                    , text Testable.Generator.lorem
                    , Testable.Generator.box

                    -- , text Testable.Generator.lorem
                    ]
                , text Testable.Generator.short

                -- , text Testable.Generator.lorem
                , Testable.Generator.box
                , paragraph []
                    [ text "This is a paragraph with a "
                    , el [ Font.bold ] <| text "child"
                    , text " of depth one."
                    ]
                ]
            , el [ Font.size 32 ] (text "Row with boxes")
            , paragraph []
                [ text Testable.Generator.short
                , row []
                    [ Testable.Generator.box

                    -- , text Testable.Generator.lorem
                    , Testable.Generator.box

                    -- , text Testable.Generator.lorem
                    ]
                , text Testable.Generator.short

                -- , text Testable.Generator.lorem
                , Testable.Generator.box
                , paragraph []
                    [ text "This is a paragraph with a "
                    , el [ Font.bold ] <| text "child"
                    , text " of depth one."
                    ]
                ]
            ]
