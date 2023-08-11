module Ui.Prose exposing
    ( column, paragraph
    , h1, h2, h3, h4, h5, h6
    , noBreak, softHyphen
    , enDash, emDash
    , quote, singleQuote, apostrophe
    )

{-|


# Text Layout

@docs column, paragraph

@docs h1, h2, h3, h4, h5, h6


# Special text handling

@docs noBreak, softHyphen

@docs enDash, emDash

@docs quote, singleQuote, apostrophe

-}

import Internal.Flag as Flag exposing (Flag)
import Internal.Model2 as Two
import Internal.Style2 as Style
import Ui exposing (Attribute, Element, fill, width)


{-| Now that we have a paragraph, we need some way to attach a bunch of paragraph's together.

To do that we can use a `Ui.Prose.column`.

The main difference between a `Ui.column` and a `Ui.Prose.column` is that `Ui.Prose.column` will flow the text around elements that have `alignRight` or `alignLeft`, just like we just saw with paragraph.

In the following example, we have a `Ui.Prose.column` where one child has `alignLeft`.

    Ui.Prose.column [ spacing 10, padding 10 ]
        [ Ui.Prose.paragraph [] [ Ui.text "lots of text ...." ]
        , Ui.el [ alignLeft ] none
        , Ui.Prose.paragraph [] [ Ui.text "lots of text ...." ]
        ]

Which will result in something like:

![A text layout where an image is on the left.](https://mdgriffith.gitbooks.io/style-elements/content/assets/Screen%20Shot%202017-08-25%20at%208.42.39%20PM.png)

-}
column : List (Attribute msg) -> List (Element msg) -> Element msg
column attrs children =
    Two.element Two.NodeAsDiv
        Two.AsTextColumn
        attrs
        children


{-| A paragraph will layout all children as wrapped, inline elements.

    import Element exposing (el, paragraph, text)
    import Ui.Font as Font

    view =
        paragraph []
            [ text "lots of text ...."
            , el [ Font.bold ] (text "this is bold")
            , text "lots of text ...."
            ]

This is really useful when you want to markup text by having some parts be bold, or some be links, or whatever you so desire.

Also, if a child element has `alignLeft` or `alignRight`, then it will be moved to that side and the text will flow around it, (ah yes, `float` behavior).

This makes it particularly easy to do something like a [dropped capital](https://en.wikipedia.org/wiki/Initial).

    import Element exposing (alignLeft, el, padding, paragraph, text)
    import Ui.Font as Font

    view =
        paragraph []
            [ el
                [ alignLeft
                , padding 5
                ]
                (text "S")
            , text "o much text ...."
            ]

Which will look something like

![A paragraph where the first letter is twice the height of the others](https://mdgriffith.gitbooks.io/style-elements/content/assets/Screen%20Shot%202017-08-25%20at%209.41.52%20PM.png)

**Note** `spacing` on a paragraph will set the pixel spacing between lines.

-}
paragraph : List (Attribute msg) -> List (Element msg) -> Element msg
paragraph attrs children =
    Two.element Two.NodeAsParagraph
        Two.AsParagraph
        (width fill :: attrs)
        children


{-| -}
h1 : List (Attribute msg) -> String -> Element msg
h1 attrs str =
    Two.element Two.NodeAsH1
        Two.AsEl
        (width fill :: attrs)
        [ Ui.text str ]


{-| -}
h2 : List (Attribute msg) -> String -> Element msg
h2 attrs str =
    Two.element Two.NodeAsH2
        Two.AsEl
        (width fill :: attrs)
        [ Ui.text str ]


{-| -}
h3 : List (Attribute msg) -> String -> Element msg
h3 attrs str =
    Two.element Two.NodeAsH3
        Two.AsEl
        (width fill :: attrs)
        [ Ui.text str ]


{-| -}
h4 : List (Attribute msg) -> String -> Element msg
h4 attrs str =
    Two.element Two.NodeAsH4
        Two.AsEl
        (width fill :: attrs)
        [ Ui.text str ]


{-| -}
h5 : List (Attribute msg) -> String -> Element msg
h5 attrs str =
    Two.element Two.NodeAsH5
        Two.AsEl
        (width fill :: attrs)
        [ Ui.text str ]


{-| -}
h6 : List (Attribute msg) -> String -> Element msg
h6 attrs str =
    Two.element Two.NodeAsH6
        Two.AsEl
        (width fill :: attrs)
        [ Ui.text str ]



{- Text formatting -}


{-| -}
softHyphen : String
softHyphen =
    -- Needs  word-break: break-word;
    -- hyphens: auto;
    "&shy;"


{-| -}
noBreak : String
noBreak =
    "\u{00A0}"


{-| Wrap in curly double quotes.

<https://practicaltypography.com/straight-and-curly-quotes.html>

-}
quote : String -> String
quote str =
    "“" ++ str ++ "”"


{-| -}
singleQuote : String -> String
singleQuote str =
    "‘" ++ str ++ "’"


{-| -}
apostrophe : String
apostrophe =
    "’"


{-| -}
enDash : String
enDash =
    "–"


{-| -}
emDash : String
emDash =
    "—"



{- LISTS

-}


{-| -}
numbered : List (Attribute msg) -> List (Element msg) -> Element msg
numbered =
    orderedList decimal


{-| -}
bulleted : List (Attribute msg) -> List (Element msg) -> Element msg
bulleted =
    unorderedList disc


{-| -}
type ListIcon
    = ListIcon String


{-| -}
decimal : ListIcon
decimal =
    ListIcon "decimal"


{-| -}
disc : ListIcon
disc =
    ListIcon "disc"


{-| -}
circle : ListIcon
circle =
    ListIcon "disc"


{-| -}
custom : String -> ListIcon
custom =
    ListIcon


{-| -}
orderedList : ListIcon -> List (Attribute msg) -> List (Element msg) -> Element msg
orderedList icon attrs children =
    Debug.todo "Lists"


{-| -}
unorderedList : ListIcon -> List (Attribute msg) -> List (Element msg) -> Element msg
unorderedList icon attrs children =
    Debug.todo "Lists"
