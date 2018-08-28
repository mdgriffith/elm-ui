module Accumulation exposing (..)

{-| -}

import Set


type Style
    = Color String Float Float Float Float
    | Spacing String Float
    | Font String (List String)


key style =
    case style of
        Color k _ _ _ _ ->
            k

        Spacing k _ ->
            k

        Font k _ ->
            k


type Element
    = Element (List Style) (List Element)
    | None


render element =
    case element of
        None ->
            []

        Element styles children ->
            let
                childrenStyles =
                    List.foldr render [] children
            in
            styles ++ childrenStyles


finalize styles =
    List.foldl deduplicate ( Set.empty, [] ) styles


deduplicate style ( cached, styles ) =
    if Set.member (key style) then
        ( cached, styles )
    else
        ( Set.insert (key style), style :: styles )


toHtml element =
    render element
        |> finalize
