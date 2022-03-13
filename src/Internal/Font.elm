module Internal.Font exposing
    ( Adjustment
    , Font(..)
    , Sizing(..)
    , Variant(..)
    , Weight(..)
    , hasSmallCaps
    , render
    , renderVariants
    )

{-| -}


type Font
    = Serif
    | SansSerif
    | Monospace
    | Typeface String


render : List Font -> String -> String
render faces str =
    case faces of
        [] ->
            str

        Serif :: remain ->
            case str of
                "" ->
                    render remain "serif"

                _ ->
                    render remain (str ++ ", serif")

        SansSerif :: remain ->
            case str of
                "" ->
                    render remain "sans-serif"

                _ ->
                    render remain (str ++ ", sans-serif")

        Monospace :: remain ->
            case str of
                "" ->
                    render remain "monospace"

                _ ->
                    render remain (str ++ ", monospace")

        (Typeface name) :: remain ->
            case str of
                "" ->
                    render remain ("\"" ++ name ++ "\"")

                _ ->
                    render remain (str ++ ", \"" ++ name ++ "\"")


{-| -}
type alias Adjustment =
    { offset : Float
    , height : Float
    }


type Sizing
    = Full
    | ByCapital Adjustment


{-| -}
type Variant
    = VariantActive String
    | VariantOff String
    | VariantIndexed String Int


hasSmallCaps : List Variant -> Basics.Bool
hasSmallCaps variants =
    case variants of
        [] ->
            False

        (VariantActive "smcp") :: remain ->
            True

        _ :: remain ->
            hasSmallCaps remain


renderVariants : List Variant -> String -> String
renderVariants variants str =
    let
        withComma =
            case str of
                "" ->
                    ""

                _ ->
                    str ++ ", "
    in
    case variants of
        [] ->
            str

        (VariantActive "smcp") :: remain ->
            -- skip smallcaps, which is rendered by renderSmallCaps
            renderVariants remain str

        (VariantActive name) :: remain ->
            renderVariants remain (withComma ++ "\"" ++ name ++ "\"")

        (VariantOff name) :: remain ->
            renderVariants remain (withComma ++ "\"" ++ name ++ "\" 0")

        (VariantIndexed name index) :: remain ->
            renderVariants remain (withComma ++ "\"" ++ name ++ "\" " ++ String.fromInt index)


{-| -}
type Weight
    = Weight Int
