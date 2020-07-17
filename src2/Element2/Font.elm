module Element2.Font exposing
    ( color, size
    , family, Font, typeface, serif, sansSerif, monospace
    , alignLeft, alignRight, center, justify, letterSpacing, wordSpacing
    , underline, strike, italic, unitalicized
    , heavy, extraBold, bold, semiBold, medium, regular, light, extraLight, hairline
    , Variant, variant, variantList, smallCaps, slashedZero, ligatures, ordinal, tabularNumbers, stackedFractions, diagonalFractions, swash, feature, indexed
    , glow, shadow
    )

{-|

    import Element
    import Element.Font as Font

    view =
        Element.el
            [ Font.color (Element.rgb 0 0 1)
            , Font.size 18
            , Font.family
                [ Font.typeface "Open Sans"
                , Font.sansSerif
                ]
            ]
            (Element.text "Woohoo, I'm stylish text")

**Note:** `Font.color`, `Font.size`, and `Font.family` are inherited, meaning you can set them at the top of your view and all subsequent nodes will have that value.

**Other Note:** If you're looking for something like `line-height`, it's handled by `Element.spacing` on a `paragraph`.

@docs color, size


## Typefaces

@docs family, Font, typeface, serif, sansSerif, monospace


## Alignment and Spacing

@docs alignLeft, alignRight, center, justify, letterSpacing, wordSpacing


## Font Styles

@docs underline, strike, italic, unitalicized


## Font Weight

@docs heavy, extraBold, bold, semiBold, medium, regular, light, extraLight, hairline


## Variants

@docs Variant, variant, variantList, smallCaps, slashedZero, ligatures, ordinal, tabularNumbers, stackedFractions, diagonalFractions, swash, feature, indexed


## Shadows

@docs glow, shadow

-}

import Element2 exposing (Attribute, Color)
import Internal.Flag as Flag
import Internal.Model2 as Two
import Internal.StyleGenerator as Style


{-| -}
type Font
    = Serif
    | SansSerif
    | Monospace
    | Typeface String
    | ImportFont String String
    | FontWith
        { name : String
        , adjustment : Maybe Adjustment
        , variants : List Variant
        }


fontName : Font -> String
fontName font =
    case font of
        Serif ->
            "serif"

        SansSerif ->
            "sans-serif"

        Monospace ->
            "monospace"

        Typeface name ->
            "\"" ++ name ++ "\""

        ImportFont name url ->
            "\"" ++ name ++ "\""

        FontWith { name } ->
            "\"" ++ name ++ "\""


{-| -}
color : Color -> Two.Attribute msg
color fontColor =
    Two.Style Flag.fontColor (Style.prop "color" (Style.color fontColor))


{-|

    import Element
    import Element.Font as Font

    myElement =
        Element.el
            [ Font.family
                [ Font.typeface "Helvetica"
                , Font.sansSerif
                ]
            ]
            (text "")

-}
family : List Font -> Attribute msg
family typefaces =
    Two.Style Flag.fontFamily (Style.prop "font-family" (List.foldl renderFont "" typefaces))


renderFont : Font -> String -> String
renderFont face str =
    if String.isEmpty str then
        fontName face

    else
        str ++ ", " ++ fontName face


{-| -}
serif : Font
serif =
    Serif


{-| -}
sansSerif : Font
sansSerif =
    SansSerif


{-| -}
monospace : Font
monospace =
    Monospace


{-| -}
typeface : String -> Font
typeface =
    Typeface


{-| -}
type alias Adjustment =
    { capital : Float
    , lowercase : Float
    , baseline : Float
    , descender : Float
    }


{-| -}
with :
    { name : String
    , adjustment : Maybe Adjustment
    , variants : List Variant
    }
    -> Font
with =
    FontWith


{-| -}
sizeByCapital : Attribute msg
sizeByCapital =
    Two.class Style.classes.sizeByCapital


{-| -}
full : Attribute msg
full =
    Two.class Style.classes.fullSize


{-| Font sizes are always given as `px`.
-}
size : Int -> Two.Attribute msg
size i =
    Two.Style Flag.fontSize (Style.prop "font-size" (Style.px i))


{-| In `px`.
-}
letterSpacing : Float -> Attribute msg
letterSpacing offset =
    Two.Style Flag.letterSpacing (Style.prop "letter-spacing" (Style.floatPx offset))


{-| In `px`.
-}
wordSpacing : Float -> Two.Attribute msg
wordSpacing offset =
    Two.Style Flag.wordSpacing (Style.prop "word-spacing" (Style.floatPx offset))


{-| Align the font to the left.
-}
alignLeft : Attribute msg
alignLeft =
    Two.Class Flag.fontAlignment Style.classes.textLeft


{-| Align the font to the right.
-}
alignRight : Attribute msg
alignRight =
    Two.Class Flag.fontAlignment Style.classes.textRight


{-| Center align the font.
-}
center : Attribute msg
center =
    Two.Class Flag.fontAlignment Style.classes.textCenter


{-| -}
justify : Attribute msg
justify =
    Two.Class Flag.fontAlignment Style.classes.textJustify



-- {-| -}
-- justifyAll : Attribute msg
-- justifyAll =
--     Internal.class Style.classesTextJustifyAll


{-| -}
underline : Attribute msg
underline =
    Two.class Style.classes.underline


{-| -}
strike : Attribute msg
strike =
    Two.class Style.classes.strike


{-| -}
italic : Attribute msg
italic =
    Two.class Style.classes.italic


{-| -}
bold : Attribute msg
bold =
    Two.Style Flag.fontWeight (Style.prop "font-weight" "700")


{-| -}
light : Attribute msg
light =
    Two.Style Flag.fontWeight (Style.prop "font-weight" "300")


{-| -}
hairline : Attribute msg
hairline =
    Two.Style Flag.fontWeight (Style.prop "font-weight" "100")


{-| -}
extraLight : Attribute msg
extraLight =
    Two.Style Flag.fontWeight (Style.prop "font-weight" "200")


{-| -}
regular : Attribute msg
regular =
    Two.Style Flag.fontWeight (Style.prop "font-weight" "400")


{-| -}
semiBold : Attribute msg
semiBold =
    Two.Style Flag.fontWeight (Style.prop "font-weight" "600")


{-| -}
medium : Attribute msg
medium =
    Two.Style Flag.fontWeight (Style.prop "font-weight" "500")


{-| -}
extraBold : Attribute msg
extraBold =
    Two.Style Flag.fontWeight (Style.prop "font-weight" "800")


{-| -}
heavy : Attribute msg
heavy =
    Two.Style Flag.fontWeight (Style.prop "font-weight" "900")


{-| This will reset bold and italic.
-}
unitalicized : Attribute msg
unitalicized =
    Two.class Style.classes.textUnitalicized


{-| -}
shadow :
    { offset : ( Float, Float )
    , blur : Float
    , color : Color
    }
    -> Attribute msg
shadow shade =
    -- Internal.StyleClass Flag.txtShadows <|
    --     Internal.Single (Internal.textShadowClass shade) "text-shadow" (Internal.formatTextShadow shade)
    Two.NoAttribute


{-| A glow is just a simplified shadow.
-}
glow : Color -> Float -> Attribute msg
glow clr i =
    let
        shade =
            { offset = ( 0, 0 )
            , blur = i * 2
            , color = clr
            }
    in
    -- Internal.StyleClass Flag.txtShadows <|
    --     Internal.Single (Internal.textShadowClass shade) "text-shadow" (Internal.formatTextShadow shade)
    Two.NoAttribute



{- Variants -}


{-| -}
type Variant
    = VariantActive String
    | VariantOff String
    | VariantIndexed String Int


{-| You can use this to set a single variant on an element itself such as:

    el
        [ Font.variant Font.smallCaps
        ]
        (text "rendered with smallCaps")

**Note** These will **not** stack. If you want multiple variants, you should use `Font.variantList`.

-}
variant : Variant -> Attribute msg
variant var =
    case var of
        VariantActive name ->
            Two.Class Flag.fontVariant ("v-" ++ name)

        VariantOff name ->
            Two.Class Flag.fontVariant ("v-" ++ name ++ "-off")

        VariantIndexed name index ->
            -- Internal.StyleClass Flag.fontVariant <|
            --     Internal.Single ("v-" ++ name ++ "-" ++ String.fromInt index)
            --         "font-feature-settings"
            --         ("\"" ++ name ++ "\" " ++ String.fromI
            Two.NoAttribute


isSmallCaps x =
    case x of
        VariantActive feat ->
            feat == "smcp"

        _ ->
            False


{-| -}
variantList : List Variant -> Attribute msg
variantList vars =
    -- let
    --     features =
    --         vars
    --             |> List.map Internal.renderVariant
    --     hasSmallCaps =
    --         List.any isSmallCaps vars
    --     name =
    --         if hasSmallCaps then
    --             vars
    --                 |> List.map Internal.variantName
    --                 |> String.join "-"
    --                 |> (\x -> x ++ "-sc")
    --         else
    --             vars
    --                 |> List.map Internal.variantName
    --                 |> String.join "-"
    --     featureString =
    --         String.join ", " features
    -- in
    -- Internal.StyleClass Flag.fontVariant <|
    --     Internal.Style ("v-" ++ name)
    --         [ Internal.Property "font-feature-settings" featureString
    --         , Internal.Property "font-variant"
    --             (if hasSmallCaps then
    --                 "small-caps"
    --              else
    --                 "normal"
    --             )
    --         ]
    Two.NoAttribute


{-| [Small caps](https://en.wikipedia.org/wiki/Small_caps) are rendered using uppercase glyphs, but at the size of lowercase glyphs.
-}
smallCaps : Variant
smallCaps =
    VariantActive "smcp"


{-| Add a slash when rendering `0`
-}
slashedZero : Variant
slashedZero =
    VariantActive "zero"


{-| -}
ligatures : Variant
ligatures =
    VariantActive "liga"


{-| Oridinal markers like `1st` and `2nd` will receive special glyphs.
-}
ordinal : Variant
ordinal =
    VariantActive "ordn"


{-| Number figures will each take up the same space, allowing them to be easily aligned, such as in tables.
-}
tabularNumbers : Variant
tabularNumbers =
    VariantActive "tnum"


{-| Render fractions with the numerator stacked on top of the denominator.
-}
stackedFractions : Variant
stackedFractions =
    VariantActive "afrc"


{-| Render fractions
-}
diagonalFractions : Variant
diagonalFractions =
    VariantActive "frac"


{-| -}
swash : Int -> Variant
swash =
    VariantIndexed "swsh"


{-| Set a feature by name and whether it should be on or off.

Feature names are four-letter names as defined in the [OpenType specification](https://docs.microsoft.com/en-us/typography/opentype/spec/featurelist).

-}
feature : String -> Bool -> Variant
feature name on =
    if on then
        VariantIndexed name 1

    else
        VariantIndexed name 0


{-| A font variant might have multiple versions within the font.

In these cases we need to specify the index of the version we want.

-}
indexed : String -> Int -> Variant
indexed name on =
    VariantIndexed name on
