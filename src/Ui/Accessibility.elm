module Ui.Accessibility exposing
    ( mainContent, info
    , navigation, aside
    , h1, h2, h3, h4, h5, h6
    , description
    , announce, announceUrgently
    )

{-| This module is meant to make accessibility easy!

These are sign posts that accessibility software like screen readers can use to navigate your app.

All you have to do is add them to elements in your app where you see fit.

Here's an example of annotating your navigation region:

    import Element exposing (row)
    import Ui.Accessibility

    myNavigation =
        row [ Ui.Accessibility.navigation ]
            [-- ..your navigation links
            ]

@docs mainContent, info

@docs navigation, aside

@docs h1, h2, h3, h4, h5, h6

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
    Two.nodeAs Two.NodeAsMain


{-| -}
aside : Attribute msg
aside =
    Two.nodeAs Two.NodeAsAside


{-| -}
navigation : Attribute msg
navigation =
    Two.nodeAs Two.NodeAsNav



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
    Two.attribute (Html.Attributes.attribute "role" "contentinfo")


{-| -}
h1 : Attribute msg
h1 =
    Two.nodeAs Two.NodeAsH1


{-| -}
h2 : Attribute msg
h2 =
    Two.nodeAs Two.NodeAsH2


{-| -}
h3 : Attribute msg
h3 =
    Two.nodeAs Two.NodeAsH3


{-| -}
h4 : Attribute msg
h4 =
    Two.nodeAs Two.NodeAsH4


{-| -}
h5 : Attribute msg
h5 =
    Two.nodeAs Two.NodeAsH5


{-| -}
h6 : Attribute msg
h6 =
    Two.nodeAs Two.NodeAsH6


{-| Screen readers will announce changes to this element and potentially interrupt any other announcement.
-}
announceUrgently : Attribute msg
announceUrgently =
    Two.attribute (Html.Attributes.attribute "aria-live" "assertive")


{-| Screen readers will announce when changes to this element are made.
-}
announce : Attribute msg
announce =
    Two.attribute (Html.Attributes.attribute "aria-live" "polite")


{-| Adds an `aria-label`, which is used by accessibility software to identity otherwise unlabeled elements.

A common use for this would be to label buttons that only have an icon.

-}
description : String -> Attribute msg
description label =
    Two.attribute (Html.Attributes.attribute "aria-label" label)
