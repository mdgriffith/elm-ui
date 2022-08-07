module Ui.Layout exposing
    ( grid
    , gridWith, Width, byContent, px, fill, portion, bounded
    , row, column
    , AlignX, left, centerY, right
    , AlignY, top, centerX, bottom
    )

{-| The vast majority of layouts should be covered by `Ui.column` and `Ui.row`. Reach for those first before coming here!

However, sometimes you might need a bit more nuance.


# Grid

@docs grid

@docs gridWith, Width, byContent, px, fill, portion, bounded


# Advanced Rows and Columns

@docs row, column

@docs AlignX, left, centerY, right

@docs AlignY, top, centerX, bottom

-}

import Internal.Model2 as Two
import Ui exposing (Attribute, Element)


{-| -}
type AlignX
    = CenterX
    | Left
    | Right


{-| -}
type AlignY
    = CenterY
    | Top
    | Bottom


{-| -}
centerX : AlignX
centerX =
    CenterX


{-| -}
left : AlignX
left =
    Left


{-| -}
right : AlignX
right =
    Right


{-| -}
centerY : AlignY
centerY =
    CenterY


{-| -}
top : AlignY
top =
    Top


{-| -}
bottom : AlignY
bottom =
    Bottom


{-| -}
row : { wrap : Bool, align : ( AlignX, AlignY ) } -> List (Attribute msg) -> List (Element msg) -> Element msg
row options attrs children =
    let
        wrapped =
            if options.wrap then
                Two.style "flex-wrap" "wrap"

            else
                Ui.noAttr

        alignmentX =
            case Tuple.first options.align of
                Left ->
                    Two.style "justify-content" "flex-start"

                CenterX ->
                    Two.style "justify-content" "center"

                Right ->
                    Two.style "justify-content" "flex-end"

        alignmentY =
            case Tuple.second options.align of
                Top ->
                    Two.style "align-items" "flex-start"

                CenterY ->
                    Two.style "align-items" "center"

                Bottom ->
                    Two.style "align-items" "flex-end"
    in
    Two.element Two.AsRow
        (wrapped
            :: alignmentX
            :: alignmentY
            :: attrs
        )
        children


{-| -}
column : { wrap : Bool, align : ( AlignX, AlignY ) } -> List (Attribute msg) -> List (Element msg) -> Element msg
column options attrs children =
    let
        wrapped =
            if options.wrap then
                Two.style "flex-wrap" "wrap"

            else
                Ui.noAttr

        alignmentX =
            case Tuple.first options.align of
                Left ->
                    Two.style "align-items" "flex-start"

                CenterX ->
                    Two.style "align-items" "center"

                Right ->
                    Two.style "align-items" "flex-end"

        alignmentY =
            case Tuple.second options.align of
                Top ->
                    Two.style "justify-content" "flex-start"

                CenterY ->
                    Two.style "justify-content" "center"

                Bottom ->
                    Two.style "justify-content" "flex-end"
    in
    Two.element Two.AsColumn
        (wrapped
            :: alignmentX
            :: alignmentY
            :: attrs
        )
        children


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

        first :: remain ->
            let
                col =
                    case first of
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
