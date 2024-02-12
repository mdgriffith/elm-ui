module Ui.Font exposing
    ( size, color, gradient
    , Font
    , family, typeface, serif, sansSerif, monospace
    , alignLeft, alignRight, center, justify
    , exactWhitespace, noWrap
    , lineHeight, letterSpacing, wordSpacing
    , font
    , underline, strike, italic
    , weight
    , Weight, heavy, extraBold, bold, semiBold, medium, regular, light, extraLight, hairline
    , variants, Variant, smallCaps, slashedZero, ligatures, ordinal, tabularNumbers, stackedFractions, diagonalFractions, swash, feature, indexed
    )

{-|

@docs size, color, gradient


## Typefaces

@docs Font

@docs family, typeface, serif, sansSerif, monospace


## Alignment and Spacing

@docs alignLeft, alignRight, center, justify

@docs exactWhitespace, noWrap

@docs lineHeight, letterSpacing, wordSpacing


## Font

@docs font


## Font Styles

@docs underline, strike, italic


## Font Weight

@docs weight

@docs Weight, heavy, extraBold, bold, semiBold, medium, regular, light, extraLight, hairline


## Variants

@docs variants, Variant, smallCaps, slashedZero, ligatures, ordinal, tabularNumbers, stackedFractions, diagonalFractions, swash, feature, indexed

-}

import Internal.BitField as BitField
import Internal.Bits.Inheritance as Inheritance
import Internal.Flag as Flag
import Internal.Font
import Internal.Model2 as Internal
import Internal.Style2 as Style
import Ui exposing (Attribute, Color)
import Ui.Gradient


{-| -}
type alias Font =
    Internal.Font.Font


{-| -}
color : Color -> Attribute msg
color fontColor =
    Internal.style "color" (Style.color fontColor)


{-| -}
gradient :
    Ui.Gradient.Gradient
    -> Attribute msg
gradient grad =
    Internal.styleAndClass Flag.fontGradient
        { class = Style.classes.textGradient
        , styleName = "background-image"
        , styleVal = Style.toCssGradient grad
        }


{-|

    import Ui
    import Ui.Font

    myElement =
        Ui.el
            [ Ui.Font.family
                [ Ui.Font.typeface "Helvetica"
                , Ui.Font.sansSerif
                ]
            ]
            (Ui.text "Hello!")

-}
family : List Font -> Attribute msg
family typefaces =
    Internal.style "font-family" (Internal.Font.render typefaces "")


{-| -}
serif : Font
serif =
    Internal.Font.Serif


{-| -}
sansSerif : Font
sansSerif =
    Internal.Font.SansSerif


{-| -}
monospace : Font
monospace =
    Internal.Font.Monospace


{-| -}
typeface : String -> Font
typeface =
    Internal.Font.Typeface


{-|

    Ui.Font.font
        { name = "EB Garamond"
        , fallback = [ Ui.Font.serif ]
        , variants = []
        , weight = Ui.Font.bold
        , size = 16
        , lineSpacing = 8
        , capitalSizeRatio = 0.7
        }

  - Capital size ratio is the ratio of the capital size to the font size.
    If this is set to something other than 1, then the font size will be adjusted to match the capital size.

-}
font :
    { name : String
    , fallback : List Font
    , variants : List Variant
    , weight : Weight
    , size : Int
    , lineSpacing : Int
    , capitalSizeRatio : Float
    }
    -> Attribute msg
font details =
    let
        fontSize =
            max 1 details.size

        actualFontSize =
            if details.capitalSizeRatio <= 0 then
                toFloat fontSize

            else
                toFloat fontSize / details.capitalSizeRatio

        actualLineHeight =
            --  Example calculation
            -- 16px font size
            -- 8px line spacing
            -- 12px capital size, so capitalSizeRatio is 12/16 = 0.75
            -- So, actual font size is 16/0.75 = 21.3333
            -- A line-height of 1 is going to be 21.3333px
            -- We want the line-height to be 16px + 8px = 24px
            -- (fontSize + lineSpacing) / actualFontSize
            -- Line height should be 8/21.3333 = 0.375 + 1
            -- line-height should be 1.375
            (toFloat fontSize + toFloat (max 0 details.lineSpacing))
                / actualFontSize
    in
    Internal.Attribute
        { flag = Flag.fontAdjustment
        , attr =
            Internal.Attr
                { node = Internal.NodeAsDiv
                , additionalInheritance = BitField.none
                , attrs = []
                , class = Nothing
                , styles =
                    \_ _ ->
                        listIf
                            [ ( True
                              , ( "font-family"
                                , details.name
                                    |> Internal.Font.render details.fallback
                                )
                              )
                            , ( True
                              , ( "font-size"
                                , toFontPixels actualFontSize
                                )
                              )
                            , ( True
                              , ( "font-weight"
                                , case details.weight of
                                    Internal.Font.Weight wght ->
                                        String.fromInt wght
                                )
                              )
                            , ( True
                              , ( "line-height"
                                , String.fromFloat actualLineHeight
                                )
                              )
                            , ( not (List.isEmpty details.variants)
                              , ( "font-feature-settings"
                                , Internal.Font.renderVariants details.variants ""
                                )
                              )
                            , ( Internal.Font.hasSmallCaps details.variants
                              , ( "font-variant-caps", "small-caps" )
                              )
                            ]
                , nearby = Nothing
                }
        }


toFontPixels : Float -> String
toFontPixels f =
    let
        rem =
            f / 16
    in
    String.fromFloat rem ++ "rem"


{-| -}
variants : List Variant -> Attribute msg
variants variantList =
    Internal.style "font-feature-settings" (Internal.Font.renderVariants variantList "")


listIf : List ( Bool, a ) -> List a
listIf list =
    List.filterMap
        (\( first, item ) ->
            if first then
                Just item

            else
                Nothing
        )
        list


{-| Font sizes are always given as a web-pixel size.

**Note:** Behind the scenes this is rendered as `rem` units, so that the font size can be adjusted by the user's browser settings.

-}
size : Int -> Attribute msg
size i =
    Internal.styleDynamic
        "font-size"
        (\inheritance ->
            let
                baseSize =
                    toFloat i

                modificationInt =
                    BitField.get Inheritance.fontHeight inheritance

                modification =
                    (toFloat modificationInt / 100) * baseSize
            in
            toFontPixels (baseSize - modification)
        )


{-| -}
lineHeight : Float -> Attribute msg
lineHeight height =
    Internal.style "line-height" (String.fromFloat height)


{-| -}
exactWhitespace : Attribute msg
exactWhitespace =
    Internal.style "white-space" "pre"


{-| -}
noWrap : Attribute msg
noWrap =
    Internal.style "white-space" "nowrap"


{-| In `px`.
-}
letterSpacing : Float -> Attribute msg
letterSpacing offset =
    Internal.style "letter-spacing" (String.fromFloat offset ++ "px")


{-| In `px`.
-}
wordSpacing : Float -> Attribute msg
wordSpacing offset =
    Internal.style "word-spacing" (String.fromFloat offset ++ "px")


{-| Align the font to the left.
-}
alignLeft : Attribute msg
alignLeft =
    Internal.classWith Flag.fontAlignment Style.classes.textLeft


{-| Align the font to the right.
-}
alignRight : Attribute msg
alignRight =
    Internal.classWith Flag.fontAlignment Style.classes.textRight


{-| Center align the font.
-}
center : Attribute msg
center =
    Internal.classWith Flag.fontAlignment Style.classes.textCenter


{-| -}
justify : Attribute msg
justify =
    Internal.classWith Flag.fontAlignment Style.classes.textJustify



-- {-| -}
-- justifyAll : Attribute msg
-- justifyAll =
--     Internal.class Style.classesTextJustifyAll


{-| -}
underline : Attribute msg
underline =
    Internal.class Style.classes.underline


{-| -}
strike : Attribute msg
strike =
    Internal.class Style.classes.strike


{-| -}
italic : Attribute msg
italic =
    Internal.class Style.classes.italic


{-| -}
type alias Weight =
    Internal.Font.Weight


{-| -}
weight : Weight -> Attribute msg
weight (Internal.Font.Weight i) =
    Internal.style "font-weight" (String.fromInt i)


{-| -}
bold : Weight
bold =
    Internal.Font.Weight 700


{-| -}
light : Weight
light =
    Internal.Font.Weight 300


{-| -}
hairline : Weight
hairline =
    Internal.Font.Weight 100


{-| -}
extraLight : Weight
extraLight =
    Internal.Font.Weight 200


{-| -}
regular : Weight
regular =
    Internal.Font.Weight 400


{-| -}
semiBold : Weight
semiBold =
    Internal.Font.Weight 600


{-| -}
medium : Weight
medium =
    Internal.Font.Weight 500


{-| -}
extraBold : Weight
extraBold =
    Internal.Font.Weight 800


{-| -}
heavy : Weight
heavy =
    Internal.Font.Weight 900



{- Variants -}


{-| -}
type alias Variant =
    Internal.Font.Variant


{-| [Small caps](https://en.wikipedia.org/wiki/Small_caps) are rendered using uppercase glyphs, but at the size of lowercase glyphs.
-}
smallCaps : Variant
smallCaps =
    Internal.Font.VariantActive "smcp"


{-| Add a slash when rendering `0`
-}
slashedZero : Variant
slashedZero =
    Internal.Font.VariantActive "zero"


{-| -}
ligatures : Variant
ligatures =
    Internal.Font.VariantActive "liga"


{-| Oridinal markers like `1st` and `2nd` will receive special glyphs.
-}
ordinal : Variant
ordinal =
    Internal.Font.VariantActive "ordn"


{-| Number figures will each take up the same space, allowing them to be easily aligned, such as in tables.
-}
tabularNumbers : Variant
tabularNumbers =
    Internal.Font.VariantActive "tnum"


{-| Render fractions with the numerator stacked on top of the denominator.
-}
stackedFractions : Variant
stackedFractions =
    Internal.Font.VariantActive "afrc"


{-| Render fractions
-}
diagonalFractions : Variant
diagonalFractions =
    Internal.Font.VariantActive "frac"


{-| -}
swash : Int -> Variant
swash =
    Internal.Font.VariantIndexed "swsh"


{-| Set a feature by name and whether it should be on or off.

Feature names are four-letter names as defined in the [OpenType specification](https://docs.microsoft.com/en-us/typography/opentype/spec/featurelist).

-}
feature : String -> Bool -> Variant
feature name on =
    if on then
        Internal.Font.VariantIndexed name 1

    else
        Internal.Font.VariantIndexed name 0


{-| A font variant might have multiple versions within the font.

In these cases we need to specify the index of the version we want.

-}
indexed : String -> Int -> Variant
indexed name on =
    Internal.Font.VariantIndexed name on
