module Ui.Prose exposing
    ( paragraph, column
    , numbered, bulleted, item
    , orderedList, unorderedList
    , ListIcon, decimal, disc, circle, markerUrl, markerString, custom
    , noBreak, softHyphen
    , enDash, emDash
    , quote, singleQuote, apostrophe
    )

{-|


# Text Layout

@docs paragraph, column


# Lists

@docs numbered, bulleted, item

@docs orderedList, unorderedList

@docs ListIcon, decimal, disc, circle, markerUrl, markerString, custom


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

    import Ui
    import Ui.Font
    import Ui.Prose

    view =
        Ui.Prose.paragraph []
            [ Ui.text "lots of text ...."
            , Ui.el [ Ui.Font.bold ] (Ui.text "this is bold")
            , Ui.text "lots of text ...."
            ]

This is really useful when you want to markup text by having some parts be bold, or some be links, or whatever you so desire.

Also, if a child element has `alignLeft` or `alignRight`, then it will be moved to that side and the text will flow around it, (ah yes, `float` behavior).

This makes it particularly easy to do something like a [dropped capital](https://en.wikipedia.org/wiki/Initial).

    import Ui
    import Ui.Prose

    view =
        Ui.Prose.paragraph []
            [ Ui.el
                [ Ui.alignLeft
                , Ui.padding 5
                ]
                (Ui.text "S")
            , Ui.text "o much text ...."
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


{-| Create a list item whose children use standard text-column flow.

List items can contain inline text, paragraphs, nested lists, and other block
content. The item owns that layout directly so native list markers align with
the first line of content.

-}
type Item msg
    = Item (List (Attribute msg)) (List (Element msg))


{-| Create a list item with text-column children.
-}
item : List (Attribute msg) -> List (Element msg) -> Item msg
item =
    Item


unwrapItem : Item msg -> Element msg
unwrapItem (Item attrs children) =
    Two.element Two.NodeAsListItem
        Two.AsTextColumn
        attrs
        children


{-| A native CSS list marker description.
-}
type ListIcon
    = DecimalMarker
    | DiscMarker
    | CircleMarker
    | UrlMarker String
    | StringMarker String
    | CustomCssMarker String


{-| -}
decimal : ListIcon
decimal =
    DecimalMarker


{-| -}
disc : ListIcon
disc =
    DiscMarker


{-| -}
circle : ListIcon
circle =
    CircleMarker


{-| Use an image URL as the native list marker.
-}
markerUrl : String -> ListIcon
markerUrl =
    UrlMarker


{-| Use a string, such as a Unicode glyph, as the native list marker.
-}
markerString : String -> ListIcon
markerString =
    StringMarker


{-| Use a raw CSS `list-style` value.

Prefer `markerUrl` or `markerString` for those common cases.

-}
custom : String -> ListIcon
custom =
    CustomCssMarker


iconToString : ListIcon -> String
iconToString icon =
    case icon of
        DecimalMarker ->
            "decimal"

        DiscMarker ->
            "disc"

        CircleMarker ->
            "circle"

        UrlMarker source ->
            "url(" ++ cssQuotedString source ++ ")"

        StringMarker marker ->
            cssQuotedString marker

        CustomCssMarker value ->
            value


cssQuotedString : String -> String
cssQuotedString value =
    "\"" ++ String.foldr escapeCssStringChar "" value ++ "\""


escapeCssStringChar : Char -> String -> String
escapeCssStringChar char escaped =
    case char of
        '\\' ->
            "\\\\" ++ escaped

        '"' ->
            "\\\"" ++ escaped

        '\n' ->
            "\\A " ++ escaped

        '\u{000D}' ->
            "\\D " ++ escaped

        '\u{000C}' ->
            "\\C " ++ escaped

        '\u{0000}' ->
            "�" ++ escaped

        _ ->
            String.fromChar char ++ escaped


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
