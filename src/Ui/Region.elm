module Ui.Region exposing
    ( mainContent, info
    , navigation, heading, aside
    , description
    , announce, announceUrgently
    )

{-| This module is meant to make accessibility easy!

These are sign posts that accessibility software like screen readers can use to navigate your app.

All you have to do is add them to elements in your app where you see fit.

Here's an example of annotating your navigation region:

    import Element exposing (row)
    import Ui.Region as Region

    myNavigation =
        row [ Region.navigation ]
            [-- ..your navigation links
            ]

@docs mainContent, info

@docs navigation, heading, aside

@docs description

@docs announce, announceUrgently

-}

import Html
import Html.Attributes
import Internal.Model2 as Two
import Ui exposing (Attribute)


{-| **Note** - You should only have _one_ of these on a given page.
-}
mainContent : Attribute msg
mainContent =
    Two.Attr (Html.Attributes.attribute "role" "main")


{-| -}
aside : Attribute msg
aside =
    -- TODO! if there is more than one of these on a page, it should be labeled.
    Two.Attr (Html.Attributes.attribute "role" "complementary")


{-| -}
navigation : Attribute msg
navigation =
    -- TODO! if there is more than one of these, it should be labeled.
    Two.Attr (Html.Attributes.attribute "role" "navigation")



-- form : Attribute msg
-- form =
--     Internal.Describe Form
-- search : Attribute msg
-- search =
--     Internal.Describe Search


{-| This region is meant to communicate common information on all pages such as copyright information, and privacy statements.

This is very commonly the footer of the page.

**Note** - You should only have _one_ of these on a given page.

-}
info : Attribute msg
info =
    -- VoiceOver does NOT recognize `footer` elements
    -- https://bugs.webkit.org/show_bug.cgi?id=146930
    -- this has been open for 5 years.
    Two.Attr (Html.Attributes.attribute "role" "contentinfo")


{-| This will mark an element as `h1`, `h2`, etc where possible.

Though it's also smart enough to not conflict with existing nodes.

So, this code

    el
        [ Region.heading 1
        , link "http://fruits.com"
        ]
        (text "Best site ever")

will generate

    <a href="http://fruits.com">
        <h1>Best site ever</h1>
    </a>

-}
heading : Int -> Attribute msg
heading level =
    -- Internal.Describe << Heading
    -- TODO: add heading level!!
    Two.Attr (Html.Attributes.attribute "role" "header")


{-| Screen readers will announce changes to this element and potentially interrupt any other announcement.
-}
announceUrgently : Attribute msg
announceUrgently =
    Two.Attr (Html.Attributes.attribute "aria-live" "assertive")


{-| Screen readers will announce when changes to this element are made.
-}
announce : Attribute msg
announce =
    Two.Attr (Html.Attributes.attribute "aria-live" "polite")


{-| Adds an `aria-label`, which is used by accessibility software to identity otherwise unlabeled elements.

A common use for this would be to label buttons that only have an icon.

-}
description : String -> Attribute msg
description label =
    Two.Attr (Html.Attributes.attribute "aria-label" label)
