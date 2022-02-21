module Ui.Layout exposing
    ( grid
    , gridWith, Width, byContent, px, fill, portion, bounded
    )

{-| The vast majority of layouts should be covered by `Ui.column` and `Ui.row`. Reach for those first before coming here!

However, sometimes you might need a bit more nuance.

@docs grid

@docs gridWith, Width, byContent, px, fill, portion, bounded

-}

import Internal.Model2 as Two
import Ui exposing (Attribute, Element)


{-| -}
grid : Int -> List (Attribute msg) -> List (Element msg) -> Element msg
grid cols attrs children =
    Two.element Two.AsGrid
        (Two.style "grid-template-columns"
            ("repeat(" ++ String.fromInt cols ++ ", minmax(0, 1fr))")
            :: attrs
        )
        children


{-| -}
type Width
    = Bounded
        { min : Maybe Int
        , max : Maybe Int
        }
    | Px Int
    | Fill Int
    | FromContent


{-| -}
byContent : Width
byContent =
    FromContent


{-| -}
px : Int -> Width
px =
    Px


{-| -}
fill : Width
fill =
    Fill 1


{-| -}
portion : Int -> Width
portion =
    Fill


{-| -}
bounded :
    { min : Maybe Int
    , max : Maybe Int
    }
    -> Width
bounded =
    Bounded


{-| -}
gridWith : List Width -> List (Attribute msg) -> List (Element msg) -> Element msg
gridWith cols attrs children =
    Two.element Two.AsGrid
        (Two.style "grid-template-columns"
            (gridTemplate cols "")
            :: attrs
        )
        children


gridTemplate : List Width -> String -> String
gridTemplate widths rendered =
    case widths of
        [] ->
            rendered

        top :: remain ->
            let
                col =
                    case top of
                        Px p ->
                            String.fromInt p ++ "px"

                        FromContent ->
                            "minmax(min-content, max-content)"

                        Fill f ->
                            String.fromInt f ++ "fr"

                        Bounded b ->
                            case ( b.min, b.max ) of
                                ( Nothing, Nothing ) ->
                                    "1fr"

                                ( Just minimum, Nothing ) ->
                                    "minmax(" ++ String.fromInt minimum ++ "px, 1fr)"

                                ( Nothing, Just maximum ) ->
                                    "fit-content(" ++ String.fromInt maximum ++ "px)"

                                ( Just minimum, Just maximum ) ->
                                    "minmax("
                                        ++ String.fromInt minimum
                                        ++ "px, "
                                        ++ String.fromInt maximum
                                        ++ "px)"
            in
            gridTemplate remain
                (case rendered of
                    "" ->
                        col

                    _ ->
                        rendered ++ " " ++ col
                )
