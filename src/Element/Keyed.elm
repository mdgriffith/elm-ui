module Element.Keyed exposing (el, column, row)

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

import Element exposing (Attribute, Element, fill, height, shrink, width)
import Internal.Model as Internal
import Internal.Style exposing (classes)


{-| -}
el : List (Attribute msg) -> ( String, Element msg ) -> Element msg
el attrs child =
    Internal.element
        Internal.asEl
        Internal.div
        (width shrink
            :: height shrink
            :: attrs
        )
        (Internal.Keyed [ child ])


{-| -}
row : List (Attribute msg) -> List ( String, Element msg ) -> Element msg
row attrs children =
    Internal.element
        Internal.asRow
        Internal.div
        (Internal.htmlClass (classes.contentLeft ++ " " ++ classes.contentCenterY)
            :: width shrink
            :: height shrink
            :: attrs
        )
        (Internal.Keyed children)


{-| -}
column : List (Attribute msg) -> List ( String, Element msg ) -> Element msg
column attrs children =
    Internal.element
        Internal.asColumn
        Internal.div
        (Internal.htmlClass
            (classes.contentTop
                ++ " "
                ++ classes.contentLeft
            )
            :: height shrink
            :: width shrink
            :: attrs
        )
        (Internal.Keyed children)
