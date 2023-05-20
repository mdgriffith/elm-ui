module Ui.Font exposing
    ( size, color, gradient
    , Font
    , family, typeface, serif, sansSerif, monospace
    , alignLeft, alignRight, center, justify
    , lineHeight, letterSpacing, wordSpacing
    , font
    , fontAdjustment
    , underline, strike, italic
    , weight
    , Weight, heavy, extraBold, bold, semiBold, medium, regular, light, extraLight, hairline
    , Variant, smallCaps, slashedZero, ligatures, ordinal, tabularNumbers, stackedFractions, diagonalFractions, swash, feature, indexed
    , glow, shadow
    )

{-|

    import Ui
    import Ui.Font

    view =
        Ui.el
            [ Ui.Font.color (Ui.rgb 0 0 1)
            , Ui.Font.size 18
            , Ui.Font.family
                [ Ui.Font.typeface "Open Sans"
                , Ui.Font.sansSerif
                ]
            ]
            (Ui.text "Woohoo, I'm stylish text")

**Note:** `Font.color`, `Font.size`, and `Font.family` are inherited, meaning you can set them at the top of your view and all subsequent nodes will have that value.

**Other Note:** If you're looking for something like `line-height`, it's handled by `Ui.spacing` on a `paragraph`.

@docs size, color, gradient


## Typefaces

@docs Font

@docs family, typeface, serif, sansSerif, monospace


## Alignment and Spacing

@docs alignLeft, alignRight, center, justify

@docs lineHeight, letterSpacing, wordSpacing


## Font

@docs font

@docs fontAdjustment


## Font Styles

@docs underline, strike, italic


## Font Weight

@docs weight

@docs Weight, heavy, extraBold, bold, semiBold, medium, regular, light, extraLight, hairline


## Variants

@docs Variant, smallCaps, slashedZero, ligatures, ordinal, tabularNumbers, stackedFractions, diagonalFractions, swash, feature, indexed


## Shadows

@docs glow, shadow

-}

import Internal.BitEncodings as Bits
import Internal.BitField as BitField
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
    Internal.styleAndClass Flag.fontColor
        { class = Style.classes.textGradient
        , styleName = "--text-gradient"
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


{-| -}
type alias Adjustment =
    { offset : Float
    , height : Float
    }


{-| -}
type alias Sizing =
    Internal.Font.Sizing


{-| -}
full : Sizing
full =
    Internal.Font.Full


{-| -}
fontAdjustment :
    { family : String
    , offset : Float
    , height : Float
    }
    -> Ui.Option
fontAdjustment =
    Internal.FontAdjustment



{- FONT ADJUSTMENTS -}
{-



   type FontColor Color = FontColor Color | FontGradient Gradient




-}


{-|

    Ui.Font.font
        { name = "EB Garamond"
        , fallback = [ Ui.Font.serif ]
        , variants = []
        , weight = Ui.Font.bold
        , size = 16
        }

-}
font :
    { name : String
    , fallback : List Font
    , variants : List Variant
    , weight : Weight
    , size : Int
    }
    -> Attribute msg
font details =
    Internal.Attribute
        { flag = Flag.fontAdjustment
        , attr =
            Internal.Font
                { family = Internal.Font.render details.fallback ("\"" ++ details.name ++ "\"")
                , adjustments =
                    Nothing
                , variants =
                    Internal.Font.renderVariants details.variants ""
                , smallCaps =
                    Internal.Font.hasSmallCaps details.variants
                , weight =
                    case details.weight of
                        Internal.Font.Weight wght ->
                            String.fromInt wght
                , size =
                    String.fromInt details.size ++ "px"
                }
        }


{-| Font sizes are always given as `px`.
-}
size : Int -> Attribute msg
size i =
    Internal.Attribute
        { flag = Flag.fontSize
        , attr = Internal.FontSize i
        }


{-| -}
lineHeight : Float -> Attribute msg
lineHeight height =
    Internal.styleAndClass Flag.skip
        { class =
            let
                offset =
                    ((floor (height * 100) - 100) // 5) * 5
            in
            Style.classes.lineHeightPrefix ++ "-" ++ String.fromInt offset
        , styleName = "line-height"
        , styleVal = String.fromFloat height
        }


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


{-| This will reset bold and italic.
-}
unitalicized : Attribute msg
unitalicized =
    Internal.class Style.classes.textUnitalicized


{-| -}
shadow :
    { offset : ( Float, Float )
    , blur : Float
    , color : Color
    }
    -> Attribute msg
shadow shade =
    -- Internal.Style Flag.txtShadows
    --     ("text-shadow:"
    --         ++ (String.fromFloat (Tuple.first shade.offset) ++ "px ")
    --         ++ (String.fromFloat (Tuple.second shade.offset) ++ "px ")
    --         ++ (String.fromFloat shade.blur ++ "px ")
    --         ++ Style.color shade.color
    --         ++ ";"
    --     )
    Internal.style "text-shadow"
        ((String.fromFloat (Tuple.first shade.offset) ++ "px ")
            ++ (String.fromFloat (Tuple.second shade.offset) ++ "px ")
            ++ (String.fromFloat shade.blur ++ "px ")
            ++ Style.color shade.color
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
    Internal.style "text-shadow"
        ((String.fromFloat (Tuple.first shade.offset) ++ "px ")
            ++ (String.fromFloat (Tuple.second shade.offset) ++ "px ")
            ++ (String.fromFloat shade.blur ++ "px ")
            ++ Style.color shade.color
        )



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
