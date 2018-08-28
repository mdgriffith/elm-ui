module Element.Lazy exposing (lazy, lazy2, lazy3, lazy4, lazy5)

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

import Internal.Model exposing (..)
import VirtualDom


{-| -}
lazy : (a -> Element msg) -> a -> Element msg
lazy fn a =
    Unstyled <| VirtualDom.lazy3 apply1 fn a


{-| -}
lazy2 : (a -> b -> Element msg) -> a -> b -> Element msg
lazy2 fn a b =
    Unstyled <| VirtualDom.lazy4 apply2 fn a b


{-| -}
lazy3 : (a -> b -> c -> Element msg) -> a -> b -> c -> Element msg
lazy3 fn a b c =
    Unstyled <| VirtualDom.lazy5 apply3 fn a b c


{-| -}
lazy4 : (a -> b -> c -> d -> Element msg) -> a -> b -> c -> d -> Element msg
lazy4 fn a b c d =
    Unstyled <| VirtualDom.lazy6 apply4 fn a b c d


{-| -}
lazy5 : (a -> b -> c -> d -> e -> Element msg) -> a -> b -> c -> d -> e -> Element msg
lazy5 fn a b c d e =
    Unstyled <| VirtualDom.lazy7 apply5 fn a b c d e


apply1 fn a =
    embed (fn a)


apply2 fn a b =
    embed (fn a b)


apply3 fn a b c =
    embed (fn a b c)


apply4 fn a b c d =
    embed (fn a b c d)


apply5 fn a b c d e =
    embed (fn a b c d e)


{-| -}
embed : Element msg -> LayoutContext -> VirtualDom.Node msg
embed x =
    case x of
        Unstyled html ->
            html

        Styled styled ->
            styled.html
                (Internal.Model.OnlyDynamic
                    { hover = AllowHover
                    , focus =
                        { borderColor = Nothing
                        , shadow = Nothing
                        , backgroundColor = Nothing
                        }
                    , mode = Layout
                    }
                    styled.styles
                )

        -- -- (Just
        -- --     (toStyleSheetString
        --         { hover = AllowHover
        --         , focus =
        --             { borderColor = Nothing
        --             , shadow = Nothing
        --             , backgroundColor = Nothing
        --             }
        --         , mode = Layout
        --         }
        -- --         styled.styles
        -- --     )
        -- -- )
        Text text ->
            always (VirtualDom.text text)

        Empty ->
            always (VirtualDom.text "")
