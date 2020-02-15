module Element.Font exposing
    ( color, size
    , family, Font, typeface, serif, sansSerif, monospace
    , external
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

@docs external


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

import Element exposing (Attr, Attribute, Color)
import Internal.Flag as Flag
import Internal.Model as Internal
import Internal.Style exposing (classes)


{-| -}
type alias Font =
    Internal.Font


{-| -}
color : Color -> Attr decorative msg
color fontColor =
    Internal.StyleClass
        Flag.fontColor
        (Internal.Colored
            ("fc-" ++ Internal.formatColorClass fontColor)
            "color"
            fontColor
        )


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
family families =
    Internal.StyleClass
        Flag.fontFamily
        (Internal.FontFamily
            (List.foldl Internal.renderFontClassName "ff-" families)
            families
        )


{-| -}
serif : Font
serif =
    Internal.Serif


{-| -}
sansSerif : Font
sansSerif =
    Internal.SansSerif


{-| -}
monospace : Font
monospace =
    Internal.Monospace


{-| -}
typeface : String -> Font
typeface =
    Internal.Typeface


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
    Internal.FontWith


{-| -}
sizeByCapital : Attribute msg
sizeByCapital =
    Internal.htmlClass classes.sizeByCapital


{-| -}
full : Attribute msg
full =
    Internal.htmlClass classes.fullSize


{-| **Note** it's likely that `Font.external` will cause a flash on your page on loading.

To bypass this, import your fonts using a separate stylesheet and just use `Font.typeface`.

It's likely that `Font.external` will be removed or redesigned in the future to avoid the flashing.

`Font.external` can be used to import font files. Let's say you found a neat font on <http://fonts.google.com>:

    import Element
    import Element.Font as Font

    view =
        Element.el
            [ Font.family
                [ Font.external
                    { name = "Roboto"
                    , url = "https://fonts.googleapis.com/css?family=Roboto"
                    }
                , Font.sansSerif
                ]
            ]
            (Element.text "Woohoo, I'm stylish text")

-}
external : { url : String, name : String } -> Font
external { url, name } =
    Internal.ImportFont name url


{-| Font sizes are always given as `px`.
-}
size : Int -> Attr decorative msg
size i =
    Internal.StyleClass Flag.fontSize (Internal.FontSize i)


{-| In `px`.
-}
letterSpacing : Float -> Attribute msg
letterSpacing offset =
    Internal.StyleClass Flag.letterSpacing <|
        Internal.Single
            ("ls-" ++ Internal.floatClass offset)
            "letter-spacing"
            (String.fromFloat offset ++ "px")


{-| In `px`.
-}
wordSpacing : Float -> Attribute msg
wordSpacing offset =
    Internal.StyleClass Flag.wordSpacing <|
        Internal.Single ("ws-" ++ Internal.floatClass offset) "word-spacing" (String.fromFloat offset ++ "px")


{-| Align the font to the left.
-}
alignLeft : Attribute msg
alignLeft =
    Internal.Class Flag.fontAlignment classes.textLeft


{-| Align the font to the right.
-}
alignRight : Attribute msg
alignRight =
    Internal.Class Flag.fontAlignment classes.textRight


{-| Center align the font.
-}
center : Attribute msg
center =
    Internal.Class Flag.fontAlignment classes.textCenter


{-| -}
justify : Attribute msg
justify =
    Internal.Class Flag.fontAlignment classes.textJustify



-- {-| -}
-- justifyAll : Attribute msg
-- justifyAll =
--     Internal.class classesTextJustifyAll


{-| -}
underline : Attribute msg
underline =
    Internal.htmlClass classes.underline


{-| -}
strike : Attribute msg
strike =
    Internal.htmlClass classes.strike


{-| -}
italic : Attribute msg
italic =
    Internal.htmlClass classes.italic


{-| -}
bold : Attribute msg
bold =
    Internal.Class Flag.fontWeight classes.bold


{-| -}
light : Attribute msg
light =
    Internal.Class Flag.fontWeight classes.textLight


{-| -}
hairline : Attribute msg
hairline =
    Internal.Class Flag.fontWeight classes.textThin


{-| -}
extraLight : Attribute msg
extraLight =
    Internal.Class Flag.fontWeight classes.textExtraLight


{-| -}
regular : Attribute msg
regular =
    Internal.Class Flag.fontWeight classes.textNormalWeight


{-| -}
semiBold : Attribute msg
semiBold =
    Internal.Class Flag.fontWeight classes.textSemiBold


{-| -}
medium : Attribute msg
medium =
    Internal.Class Flag.fontWeight classes.textMedium


{-| -}
extraBold : Attribute msg
extraBold =
    Internal.Class Flag.fontWeight classes.textExtraBold


{-| -}
heavy : Attribute msg
heavy =
    Internal.Class Flag.fontWeight classes.textHeavy


{-| This will reset bold and italic.
-}
unitalicized : Attribute msg
unitalicized =
    Internal.htmlClass classes.textUnitalicized


{-| -}
shadow :
    { offset : ( Float, Float )
    , blur : Float
    , color : Color
    }
    -> Attr decorative msg
shadow shade =
    Internal.StyleClass Flag.txtShadows <|
        Internal.Single (Internal.textShadowClass shade) "text-shadow" (Internal.formatTextShadow shade)


{-| A glow is just a simplified shadow.
-}
glow : Color -> Float -> Attr decorative msg
glow clr i =
    let
        shade =
            { offset = ( 0, 0 )
            , blur = i * 2
            , color = clr
            }
    in
    Internal.StyleClass Flag.txtShadows <|
        Internal.Single (Internal.textShadowClass shade) "text-shadow" (Internal.formatTextShadow shade)



{- Variants -}


{-| -}
type alias Variant =
    Internal.Variant


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
        Internal.VariantActive name ->
            Internal.Class Flag.fontVariant ("v-" ++ name)

        Internal.VariantOff name ->
            Internal.Class Flag.fontVariant ("v-" ++ name ++ "-off")

        Internal.VariantIndexed name index ->
            Internal.StyleClass Flag.fontVariant <|
                Internal.Single ("v-" ++ name ++ "-" ++ String.fromInt index)
                    "font-feature-settings"
                    ("\"" ++ name ++ "\" " ++ String.fromInt index)


isSmallCaps x =
    case x of
        Internal.VariantActive feat ->
            feat == "smcp"

        _ ->
            False


{-| -}
variantList : List Variant -> Attribute msg
variantList vars =
    let
        features =
            vars
                |> List.map Internal.renderVariant

        hasSmallCaps =
            List.any isSmallCaps vars

        name =
            if hasSmallCaps then
                vars
                    |> List.map Internal.variantName
                    |> String.join "-"
                    |> (\x -> x ++ "-sc")

            else
                vars
                    |> List.map Internal.variantName
                    |> String.join "-"

        featureString =
            String.join ", " features
    in
    Internal.StyleClass Flag.fontVariant <|
        Internal.Style ("v-" ++ name)
            [ Internal.Property "font-feature-settings" featureString
            , Internal.Property "font-variant"
                (if hasSmallCaps then
                    "small-caps"

                 else
                    "normal"
                )
            ]


{-| [Small caps](https://en.wikipedia.org/wiki/Small_caps) are rendered using uppercase glyphs, but at the size of lowercase glyphs.
-}
smallCaps : Variant
smallCaps =
    Internal.VariantActive "smcp"


{-| Add a slash when rendering `0`
-}
slashedZero : Variant
slashedZero =
    Internal.VariantActive "zero"


{-| -}
ligatures : Variant
ligatures =
    Internal.VariantActive "liga"


{-| Oridinal markers like `1st` and `2nd` will receive special glyphs.
-}
ordinal : Variant
ordinal =
    Internal.VariantActive "ordn"


{-| Number figures will each take up the same space, allowing them to be easily aligned, such as in tables.
-}
tabularNumbers : Variant
tabularNumbers =
    Internal.VariantActive "tnum"


{-| Render fractions with the numerator stacked on top of the denominator.
-}
stackedFractions : Variant
stackedFractions =
    Internal.VariantActive "afrc"


{-| Render fractions
-}
diagonalFractions : Variant
diagonalFractions =
    Internal.VariantActive "frac"


{-| -}
swash : Int -> Variant
swash =
    Internal.VariantIndexed "swsh"


{-| Set a feature by name and whether it should be on or off.

Feature names are four-letter names as defined in the [OpenType specification](https://docs.microsoft.com/en-us/typography/opentype/spec/featurelist).

-}
feature : String -> Bool -> Variant
feature name on =
    if on then
        Internal.VariantIndexed name 1

    else
        Internal.VariantIndexed name 0


{-| A font variant might have multiple versions within the font.

In these cases we need to specify the index of the version we want.

-}
indexed : String -> Int -> Variant
indexed name on =
    Internal.VariantIndexed name on
