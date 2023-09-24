module Ui.Prose exposing
    ( column, paragraph
    , numbered, bulleted, item
    , orderedList, unorderedList
    , ListIcon, decimal, disc, circle, custom
    , noBreak, softHyphen
    , enDash, emDash
    , quote, singleQuote, apostrophe
    )

{-|


# Text Layout

@docs column, paragraph


# Lists

@docs numbered, bulleted, item

@docs orderedList, unorderedList

@docs ListIcon, decimal, disc, circle, custom


# Special text handling

@docs noBreak, softHyphen

@docs enDash, emDash

@docs quote, singleQuote, apostrophe

-}

import Internal.Model2 as Two
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



{- Text formatting -}


{-|

     "&shy;"

The "shy" hyphen. This is a hyphen that will only show up if the word is broken across lines.

-}
softHyphen : String
softHyphen =
    -- Needs  word-break: break-word;
    -- hyphens: auto;
    "&shy;"


{-|

    "\u{00A0}"

The classic, yet sometimes misunderstood "non-breaking space".

This is useful for things like

    "Mr. Griff"

Where you don't want the "Mr." to be on one line and the "Griff" to be on the next.

-}
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
numbered : List (Attribute msg) -> List (Item msg) -> Element msg
numbered =
    orderedList decimal


{-| -}
bulleted : List (Attribute msg) -> List (Item msg) -> Element msg
bulleted =
    unorderedList disc


{-| -}
type Item msg
    = Item (List (Attribute msg)) (Element msg)


{-| -}
item : List (Attribute msg) -> Element msg -> Item msg
item =
    Item


unwrapItem : Item msg -> Element msg
unwrapItem (Item attrs child) =
    Two.element Two.NodeAsListItem
        Two.AsEl
        attrs
        [ child ]


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


iconToString : ListIcon -> String
iconToString (ListIcon str) =
    str


{-| -}
orderedList : ListIcon -> List (Attribute msg) -> List (Item msg) -> Element msg
orderedList icon attrs children =
    Two.element Two.NodeAsNumberedList
        Two.AsColumn
        (Two.style "list-style" (iconToString icon) :: attrs)
        (List.map unwrapItem children)


{-| -}
unorderedList : ListIcon -> List (Attribute msg) -> List (Item msg) -> Element msg
unorderedList icon attrs children =
    Two.element Two.NodeAsBulletedList
        Two.AsColumn
        (Two.style "list-style" (iconToString icon) :: attrs)
        (List.map unwrapItem children)
