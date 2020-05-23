module Layout.SafariBugIssue147 exposing (view)

{-|


# Safari bug for `el` heigh calculation in combination with `height fill`

The problem appears to be that the height of the first el is 0, and therefore the second
text is rendered on the first.

Versions

OS: macOS Mojave 10.14.5
Browser: Safari
Browser Version: 12.1.1 (14607.2.6.1.1)
Elm Version: 0.19
Elm UI Version: 1.1.5

<https://github.com/mdgriffith/elm-ui/issues/147>

I was able to pinpoint the issue using git bisect to this fd08f1a commit, which lines up.

<https://github.com/mdgriffith/elm-ui/commit/fd08f1a953484ba96f2d05037d4f208eab351514>

-}

import Testable.Element exposing (..)


view =
    layout [ height fill ] <|
        el [ height fill ] <|
            column
                [ height fill ]
                [ el [] <| text "Element that Safari gives height 0, if inside an el and not just text."
                , text "Text below the el above"
                ]
