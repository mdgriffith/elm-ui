module Element2.Font exposing
    ( size, color, gradient
    , family, with, Font, typeface, serif, sansSerif, monospace
    , Sizing, full, byCapital, Adjustment
    , alignLeft, alignRight, center, justify, letterSpacing, wordSpacing
    , underline, strike, italic, unitalicized
    , heavy, extraBold, bold, semiBold, medium, regular, light, extraLight, hairline
    , Variant, smallCaps, slashedZero, ligatures, ordinal, tabularNumbers, stackedFractions, diagonalFractions, swash, feature, indexed
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

@docs size, color, gradient


## Typefaces

@docs family, with, Font, typeface, serif, sansSerif, monospace

@docs Sizing, full, byCapital, Adjustment


## Alignment and Spacing

@docs alignLeft, alignRight, center, justify, letterSpacing, wordSpacing


## Font Styles

@docs underline, strike, italic, unitalicized


## Font Weight

@docs heavy, extraBold, bold, semiBold, medium, regular, light, extraLight, hairline


## Variants

@docs Variant, smallCaps, slashedZero, ligatures, ordinal, tabularNumbers, stackedFractions, diagonalFractions, swash, feature, indexed


## Shadows

@docs glow, shadow

-}

import Element2 exposing (Attribute, Color)
import Internal.Flag2 as Flag
import Internal.Model2 as Two
import Internal.Style2 as Style


{-| -}
type Font
    = Serif
    | SansSerif
    | Monospace
    | Typeface String


{-| -}
color : Color -> Two.Attribute msg
color fontColor =
    Two.Style Flag.fontColor ("color:" ++ Style.color fontColor ++ ";")


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
    Two.Style Flag.fontFamily ("font-family:" ++ renderFont typefaces "" ++ ";")


renderFont : List Font -> String -> String
renderFont faces str =
    case faces of
        [] ->
            str

        Serif :: remain ->
            case str of
                "" ->
                    renderFont remain "serif"

                _ ->
                    renderFont remain (str ++ ", serif")

        SansSerif :: remain ->
            case str of
                "" ->
                    renderFont remain "sans-serif"

                _ ->
                    renderFont remain (str ++ ", sans-serif")

        Monospace :: remain ->
            case str of
                "" ->
                    renderFont remain "monospace"

                _ ->
                    renderFont remain (str ++ ", monospace")

        (Typeface name) :: remain ->
            case str of
                "" ->
                    renderFont remain ("\"" ++ name ++ "\"")

                _ ->
                    renderFont remain (str ++ ", \"" ++ name ++ "\"")


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


type Sizing
    = Full
    | ByCapital Adjustment


{-| -}
full : Sizing
full =
    Full


{-| -}
byCapital : Adjustment -> Sizing
byCapital =
    ByCapital



{- FONT ADJUSTMENTS -}


{-|

    Font.with
        { name = "ED Garamond"
        , fallback = [ Font.serif ]
        , sizing =
            Font.byCapital
                {}
        , variants =
            []
        }

-}
with :
    { name : String
    , fallback : List Font
    , sizing : Sizing
    , variants : List Variant
    }
    -> Attribute msg
with details =
    case details.sizing of
        Full ->
            Two.Style Flag.fontFamily
                ("font-family:"
                    ++ renderFont details.fallback ("\"" ++ details.name ++ "\"")
                    ++ ";"
                    ++ renderVariants details.variants ""
                    ++ renderSmallcaps details.variants ""
                )

        ByCapital adjustment ->
            Two.ClassAndStyle Flag.fontFamily
                Style.classes.fontAdjusted
                ("font-family:"
                    ++ renderFont details.fallback ("\"" ++ details.name ++ "\"")
                    ++ ";"
                    ++ convertAdjustment adjustment
                    ++ renderVariants details.variants ""
                    ++ renderSmallcaps details.variants ""
                )


renderSmallcaps : List Variant -> String -> String
renderSmallcaps variants str =
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
            case str of
                "" ->
                    ""

                _ ->
                    "font-variant:" ++ str ++ ";"

        (VariantActive "smcp") :: remain ->
            renderVariants remain (withComma ++ "small-caps")

        _ :: remain ->
            renderVariants remain ""


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
            case str of
                "" ->
                    ""

                _ ->
                    "font-feature-settings:" ++ str ++ ";"

        (VariantActive "smcp") :: remain ->
            -- skip smallcaps, which is rendered by renderSmallCaps
            renderVariants remain str

        (VariantActive name) :: remain ->
            renderVariants remain (withComma ++ "\"" ++ name ++ "\"")

        (VariantOff name) :: remain ->
            renderVariants remain (withComma ++ "\"" ++ name ++ "\" 0")

        (VariantIndexed name index) :: remain ->
            renderVariants remain (withComma ++ "\"" ++ name ++ "\" " ++ String.fromInt index)



-- fontAdjusted
{-
     We need to set an adjustment of `line-height`, `vertical-align` and `font-size`



         <text> ->
             line-height: 1
             vertical-align: default;
             font-size: inherited;

     --
         <p> ->
             line-height: 1 + 5px;
             vertical-align: default;
             font-size: inherited;

     Vertical align and line-height are likely fine.
         -> Ensure that line-height is set once at the root.
         -> not overwritten on every element.

     Font size, we need to communicate a factor down the heirarchy and then do `calc(factor * desiredFontSize)`

         -- if we required `Font.familyWith` at the root, then we could use `rem` behind the scenes as the factor and do `calc(1rem * 10px)`

         -- or we can just use a css variable.




   IN order to adjust things correctly, we need to set these values on the `text` element.

          margin-top: -7px;
          margin-bottom: -14px;
          overflow: hidden;
          padding-top: 5px;
          padding-bottom: 8px;



      line-height: 0.497025
      size-factor: 1.4184397163120566

      32px
          -> 45.376 (actual font size)
          -> 15.9 (new line height)



      For each text element,


-}


convertAdjustment : Adjustment -> String
convertAdjustment adjustment =
    let
        lineHeight =
            1.5

        base =
            lineHeight

        normalDescender =
            (lineHeight - 1)
                / 2

        oldMiddle =
            lineHeight / 2

        newCapitalMiddle =
            ((ascender - newBaseline) / 2) + newBaseline

        newFullMiddle =
            ((ascender - descender) / 2) + descender

        lines =
            [ adjustment.capital
            , adjustment.baseline
            , adjustment.descender
            , adjustment.lowercase
            ]

        ascender =
            Maybe.withDefault adjustment.capital (List.maximum lines)

        descender =
            Maybe.withDefault adjustment.descender (List.minimum lines)

        newBaseline =
            lines
                |> List.filter (\x -> x /= descender)
                |> List.minimum
                |> Maybe.withDefault adjustment.baseline

        capitalVertical =
            1 - ascender

        capitalSize =
            1 / (ascender - newBaseline)

        vacuumTop =
            ((ascender - newBaseline) / capitalSize) / -2

        vacuumBottom =
            vacuumTop

        visibleTop =
            ascender - adjustment.capital

        visibleBottom =
            newBaseline - descender
    in
    ("--font-size-factor: " ++ String.fromFloat capitalSize ++ ";")
        ++ ("--vacuum-top: " ++ String.fromFloat vacuumTop ++ ";")
        ++ ("--vacuum-bottom: " ++ String.fromFloat vacuumBottom ++ ";")
        ++ ("--visible-top: " ++ String.fromFloat visibleTop ++ ";")
        ++ ("--visible-bottom: " ++ String.fromFloat visibleBottom ++ ";")


{-| Font sizes are always given as `px`.
-}
size : Int -> Two.Attribute msg
size i =
    Two.Style Flag.fontSize
        ("font-size:"
            ++ String.fromInt i
            ++ "px;font-size:calc("
            ++ String.fromInt i
            ++ "px * var(--font-size-factor));"
        )


{-| In `px`.
-}
letterSpacing : Float -> Attribute msg
letterSpacing offset =
    Two.Style Flag.letterSpacing ("letter-spacing:" ++ Style.floatPx offset ++ ";")


{-| In `px`.
-}
wordSpacing : Float -> Two.Attribute msg
wordSpacing offset =
    Two.Style Flag.wordSpacing ("word-spacing:" ++ Style.floatPx offset ++ ";")


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
    Two.Style Flag.fontWeight "font-weight:700;"


{-| -}
light : Attribute msg
light =
    Two.Style Flag.fontWeight "font-weight:300;"


{-| -}
hairline : Attribute msg
hairline =
    Two.Style Flag.fontWeight "font-weight:100;"


{-| -}
extraLight : Attribute msg
extraLight =
    Two.Style Flag.fontWeight "font-weight:200;"


{-| -}
regular : Attribute msg
regular =
    Two.Style Flag.fontWeight "font-weight:400;"


{-| -}
semiBold : Attribute msg
semiBold =
    Two.Style Flag.fontWeight "font-weight:600;"


{-| -}
medium : Attribute msg
medium =
    Two.Style Flag.fontWeight "font-weight:500;"


{-| -}
extraBold : Attribute msg
extraBold =
    Two.Style Flag.fontWeight "font-weight:800;"


{-| -}
heavy : Attribute msg
heavy =
    Two.Style Flag.fontWeight "font-weight:900;"


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
    Two.Style Flag.txtShadows
        ("text-shadow:"
            ++ (String.fromFloat (Tuple.first shade.offset) ++ "px ")
            ++ (String.fromFloat (Tuple.second shade.offset) ++ "px ")
            ++ (String.fromFloat shade.blur ++ "px ")
            ++ Style.color shade.color
            ++ ";"
        )


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
    Two.Style Flag.txtShadows
        ("text-shadow:"
            ++ (String.fromFloat (Tuple.first shade.offset) ++ "px ")
            ++ (String.fromFloat (Tuple.second shade.offset) ++ "px ")
            ++ (String.fromFloat shade.blur ++ "px ")
            ++ Style.color shade.color
            ++ ";"
        )



{- Variants -}


{-| -}
type Variant
    = VariantActive String
    | VariantOff String
    | VariantIndexed String Int


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


{-| Color your text as a gradient.
-}
gradient :
    { angle : Float
    , steps : List Color
    }
    -> Attribute msg
gradient details =
    Two.ClassAndStyle Flag.fontColor
        Style.classes.textGradient
        ("--text-gradient:linear-gradient(" ++ renderGradient (details.angle + (0.5 * pi)) details.steps ++ ");")


renderGradient : Float -> List Color -> String
renderGradient angle steps =
    String.join ", " <| (String.fromFloat angle ++ "rad") :: List.map Style.color steps
