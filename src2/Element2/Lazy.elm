module Element2.Lazy exposing (lazy, lazy2, lazy3, lazy4, lazy5)

{-| Same as `Html.lazy`. In case you're unfamiliar, here's a note from the `Html` library!

---

Since all Elm functions are pure we have a guarantee that the same input
will always result in the same output. This module gives us tools to be lazy
about building `Html` that utilize this fact.

Rather than immediately applying functions to their arguments, the `lazy`
functions just bundle the function and arguments up for later. When diffing
the old and new virtual DOM, it checks to see if all the arguments are equal
by reference. If so, it skips calling the function!

This is a really cheap test and often makes things a lot faster, but definitely
benchmark to be sure!

---

@docs lazy, lazy2, lazy3, lazy4, lazy5

-}

import Element2 exposing (Element)
import Html
import Html.Lazy
import Internal.Model2 as Two


{-| -}
lazy : (a -> Element msg) -> a -> Element msg
lazy fn a =
    Two.Element (Html.Lazy.lazy2 apply1 fn a)


{-| -}
lazy2 : (a -> b -> Element msg) -> a -> b -> Element msg
lazy2 fn a b =
    Two.Element (Html.Lazy.lazy3 apply2 fn a b)


{-| -}
lazy3 : (a -> b -> c -> Element msg) -> a -> b -> c -> Element msg
lazy3 fn a b c =
    Two.Element (Html.Lazy.lazy4 apply3 fn a b c)


{-| -}
lazy4 : (a -> b -> c -> d -> Element msg) -> a -> b -> c -> d -> Element msg
lazy4 fn a b c d =
    Two.Element (Html.Lazy.lazy5 apply4 fn a b c d)


{-| -}
lazy5 : (a -> b -> c -> d -> e -> Element msg) -> a -> b -> c -> d -> e -> Element msg
lazy5 fn a b c d e =
    Two.Element (Html.Lazy.lazy6 apply5 fn a b c d e)


apply1 fn a =
    Two.unwrap (fn a)


apply2 fn a b =
    Two.unwrap (fn a b)


apply3 fn a b c =
    Two.unwrap (fn a b c)


apply4 fn a b c d =
    Two.unwrap (fn a b c d)


apply5 fn a b c d e =
    Two.unwrap (fn a b c d e)
