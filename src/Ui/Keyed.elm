module Ui.Keyed exposing (el, column, row)

{-| Notes from the `Html.Keyed` on how keyed works:

---

A keyed node helps optimize cases where children are getting added, moved, removed, etc. Common examples include:

  - The user can delete items from a list.
  - The user can create new items in a list.
  - You can sort a list based on name or date or whatever.

When you use a keyed node, every child is paired with a string identifier. This makes it possible for the underlying diffing algorithm to reuse nodes more efficiently.

This means if a key is changed between renders, then the diffing step will be skipped and the node will be forced to rerender.

---

@docs el, column, row

-}

import Internal.Model2 as Two
import Ui exposing (Attribute, Element)


{-| -}
el : List (Attribute msg) -> ( String, Element msg ) -> Element msg
el attrs child =
    Two.elementKeyed Two.NodeAsDiv Two.AsEl attrs [ child ]


{-| -}
row : List (Attribute msg) -> List ( String, Element msg ) -> Element msg
row attrs children =
    Two.elementKeyed Two.NodeAsDiv Two.AsRow attrs children


{-| -}
column : List (Attribute msg) -> List ( String, Element msg ) -> Element msg
column attrs children =
    Two.elementKeyed Two.NodeAsDiv Two.AsColumn attrs children
