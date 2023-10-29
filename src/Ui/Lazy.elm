module Ui.Lazy exposing (lazy, lazy2, lazy3, lazy4, lazy5, lazy6)

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

@docs lazy, lazy2, lazy3, lazy4, lazy5, lazy6

-}

import Html
import Html.Lazy
import Internal.Bits.Inheritance as Inheritance
import Internal.Model2 as Internal
import Ui exposing (Element)


{-| -}
lazy : (a -> Element msg) -> a -> Element msg
lazy fn a =
    Internal.Element (\s -> Html.Lazy.lazy3 apply1 fn a s)


{-| -}
lazy2 : (a -> b -> Element msg) -> a -> b -> Element msg
lazy2 fn a b =
    Internal.Element (\s -> Html.Lazy.lazy4 apply2 fn a b s)


{-| -}
lazy3 : (a -> b -> c -> Element msg) -> a -> b -> c -> Element msg
lazy3 fn a b c =
    Internal.Element (\s -> Html.Lazy.lazy5 apply3 fn a b c s)


{-| -}
lazy4 : (a -> b -> c -> d -> Element msg) -> a -> b -> c -> d -> Element msg
lazy4 fn a b c d =
    Internal.Element (\s -> Html.Lazy.lazy6 apply4 fn a b c d s)


{-| -}
lazy5 : (a -> b -> c -> d -> e -> Element msg) -> a -> b -> c -> d -> e -> Element msg
lazy5 fn a b c d e =
    Internal.Element (\s -> Html.Lazy.lazy7 apply5 fn a b c d e s)


{-| -}
lazy6 : (a -> b -> c -> d -> e -> f -> Element msg) -> a -> b -> c -> d -> e -> f -> Element msg
lazy6 fn a b c d e f =
    Internal.Element (\s -> Html.Lazy.lazy8 apply6 fn a b c d e f s)


apply1 : (a -> Element msg) -> a -> Inheritance.Encoded -> Html.Html msg
apply1 fn a s =
    Internal.unwrap s (fn a)


apply2 : (a -> b -> Element msg) -> a -> b -> Inheritance.Encoded -> Html.Html msg
apply2 fn a b s =
    Internal.unwrap s (fn a b)


apply3 : (a -> b -> c -> Element msg) -> a -> b -> c -> Inheritance.Encoded -> Html.Html msg
apply3 fn a b c s =
    Internal.unwrap s (fn a b c)


apply4 : (a -> b -> c -> d -> Element msg) -> a -> b -> c -> d -> Inheritance.Encoded -> Html.Html msg
apply4 fn a b c d s =
    Internal.unwrap s (fn a b c d)


apply5 : (a -> b -> c -> d -> e -> Element msg) -> a -> b -> c -> d -> e -> Inheritance.Encoded -> Html.Html msg
apply5 fn a b c d e s =
    Internal.unwrap s (fn a b c d e)


apply6 : (a -> b -> c -> d -> e -> f -> Element msg) -> a -> b -> c -> d -> e -> f -> Inheritance.Encoded -> Html.Html msg
apply6 fn a b c d e f s =
    Internal.unwrap s (fn a b c d e f)
