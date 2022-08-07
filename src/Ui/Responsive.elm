module Ui.Responsive exposing
    ( layout
    , Breakpoints, breakpoints
    , visible
    , Value, value, fluid
    , rowWhen
    , font
    , padding, paddingXY, paddingEach
    , height, heightMin, heightMax
    , width, widthMin, widthMax
    , orAbove, orBelow
    )

{-|

@docs layout

@docs Breakpoints, breakpoints

    breakpoints : Ui.Responsive.Breakpoints Breakpoints
    breakpoints =
        Ui.Responsive.breakpoints Small
            [ (800, Medium)
            , (1400, Large)
            , (2400, ExtraLarge)
            ]


    el
        [ Ui.Responsive.visible breakpoints
            [ Medium ]
        ]
        (text "only visible at medium")


    el
        [ Ui.Responsive.fontSize breakpoints
            (\breakpoint ->
                case breakpoint of
                    ExtraLarge ->
                        Ui.Responsive.value 35

                    Large ->
                        Ui.Responsive.value 35

                    Medium ->
                        -- scales from 16 to 35 when the window is in the `Medium` range
                        Ui.Responsive.fluid 16 35

                    Small ->
                        Ui.Responsive.value 16
            )
        ]
        (text "Fluid typography")

    -- padding
    el
        [ Ui.Responsive.padding breakpoints
            (\breakpoint ->
                case breakpoint of
                    ExtraLarge ->
                        Ui.Responsive.value 35

                    Large ->
                        Ui.Responsive.value 35

                    Medium ->
                        -- scales from 16 to 35 when the window is in the `Medium` range
                        Ui.Responsive.fluid 16 35

                    Small ->
                        Ui.Responsive.value 16
            )
        ]
        (text "Fluid typography")

@docs visible

@docs Value, value, fluid

@docs rowWhen

@docs font

@docs padding, paddingXY, paddingEach

@docs height, heightMin, heightMax

@docs width, widthMin, widthMax

@docs orAbove, orBelow

-}

import Html
import Html.Attributes as Attr
import Internal.BitEncodings as Bits
import Internal.BitField as BitField
import Internal.Flag as Flag
import Internal.Font
import Internal.Model2 as Internal
    exposing
        ( Attribute
        , Element
        , ResponsiveTransition
        )
import Ui
import Ui.Anim
import Ui.Font


{-| -}
type alias Breakpoints label =
    Internal.Breakpoints label


{-| -}
orAbove : label -> Breakpoints label -> List label
orAbove label resp =
    Internal.foldBreakpoints
        (\i lab ( capturing, selected ) ->
            if label == lab then
                ( False
                , lab :: selected
                )

            else if capturing then
                ( capturing
                , lab :: selected
                )

            else
                ( capturing
                , selected
                )
        )
        ( True
        , []
        )
        resp
        |> Tuple.second


{-| -}
orBelow : label -> Breakpoints label -> List label
orBelow label resp =
    -- indices for breakpoints are descending
    -- i.e. largest first
    -- This gets all indices *above* the current index
    -- which means all breakpoints below
    Internal.foldBreakpoints
        (\i lab ( capturing, selected ) ->
            if capturing then
                ( capturing
                , lab :: selected
                )

            else if label == lab then
                ( True
                , lab :: selected
                )

            else
                ( capturing
                , selected
                )
        )
        ( False
        , []
        )
        resp
        |> Tuple.second


{-| -}
type alias LayoutOption =
    Internal.Option


{-| -}
layout :
    { options : List Ui.Option
    , breakpoints : Breakpoints label
    }
    -> Ui.Anim.State
    -> List (Ui.Attribute msg)
    -> Ui.Element msg
    -> Html.Html msg
layout opts state attrs els =
    Internal.renderLayout
        { options =
            Internal.ResponsiveBreakpoints
                (Internal.toMediaQuery opts.breakpoints)
                :: opts.options
        }
        state
        attrs
        els


layoutBreakpoints : Breakpoints label -> LayoutOption
layoutBreakpoints resp =
    Internal.ResponsiveBreakpoints
        (Internal.toMediaQuery resp)


{-| -}
breakpoints : label -> List ( Int, label ) -> Breakpoints label
breakpoints def breaks =
    Internal.Responsive
        { transition = Nothing
        , default = def
        , breaks = List.sortBy Tuple.first breaks
        , total = List.length breaks
        }


{-| -}
visible : Breakpoints label -> List label -> Attribute msg
visible breaks labels =
    Internal.class
        (Internal.foldBreakpoints
            (\i lab str ->
                if List.member lab labels then
                    str

                else
                    case str of
                        "" ->
                            "ui-bp-" ++ String.fromInt i ++ "-hidden"

                        _ ->
                            str ++ " " ++ "ui-bp-" ++ String.fromInt i ++ "-hidden"
            )
            ""
            breaks
        )


{-| Define a layout that is a row when the page in in the specified breakpoints.

Otherwise, it'll render as a `column`.

    Ui.Reponsive.rowWhen breakpoints
        (Ui.Responsive.orBelow Medium breakpoints)
        [ Ui.spacing 20
        ]
        [ text "Hello!"
        , text "World!"
        ]

-}
rowWhen :
    Breakpoints label
    -> List label
    -> List (Attribute msg)
    -> List (Element msg)
    -> Element msg
rowWhen breaks labels attrs children =
    Internal.element Internal.AsRow
        (Internal.class
            (Internal.foldBreakpoints
                (\i lab str ->
                    if List.member lab labels then
                        str

                    else
                        case str of
                            "" ->
                                "ui-bp-" ++ String.fromInt i ++ "-as-col"

                            _ ->
                                str ++ " " ++ "ui-bp-" ++ String.fromInt i ++ "-as-col"
                )
                ""
                breaks
            )
            :: attrs
        )
        children


{-| -}
font :
    { name : String
    , fallback : List Ui.Font.Font
    , sizing : Ui.Font.Sizing
    , variants : List Ui.Font.Variant
    , breakpoints : Breakpoints breakpoint
    , size : breakpoint -> Value
    , weight : breakpoint -> Ui.Font.Weight
    }
    -> Attribute msg
font details =
    Internal.Attribute
        { flag = Flag.fontAdjustment
        , attr =
            Internal.Font
                { family = Internal.Font.render details.fallback ("\"" ++ details.name ++ "\"")
                , adjustments =
                    case details.sizing of
                        Internal.Font.Full ->
                            Nothing

                        Internal.Font.ByCapital adjustment ->
                            Just
                                (BitField.init
                                    |> BitField.setPercentage Bits.fontHeight adjustment.height
                                    |> BitField.setPercentage Bits.fontOffset adjustment.offset
                                )
                , variants =
                    Internal.Font.renderVariants details.variants ""
                , smallCaps =
                    Internal.Font.hasSmallCaps details.variants
                , weight =
                    Internal.responsiveCssValue
                        details.breakpoints
                        (\bp ->
                            case details.weight bp of
                                Internal.Font.Weight wght ->
                                    Internal.Exactly wght
                        )
                , size =
                    Internal.responsiveCssValue
                        details.breakpoints
                        (\bp ->
                            case details.sizing of
                                Internal.Font.Full ->
                                    details.size bp

                                Internal.Font.ByCapital adjustment ->
                                    Internal.mapResonsive
                                        (\s ->
                                            Internal.fontSizeAdjusted s adjustment.height
                                                |> round
                                        )
                                        (details.size bp)
                        )
                }
        }


{-| -}
type alias Value =
    Internal.Value


{-| -}
fluid : Int -> Int -> Value
fluid low high =
    Internal.Between (min low high) (max low high)


{-| -}
value : Int -> Value
value =
    Internal.Exactly


{-| -}
fontSize : Breakpoints label -> (label -> Value) -> Attribute msg
fontSize resp toValue =
    varStyle "font-size"
        (Internal.responsiveCssValue resp toValue)


{-| -}
padding : Breakpoints label -> (label -> Value) -> Attribute msg
padding resp toValue =
    varStyle "padding"
        (Internal.responsiveCssValue resp toValue)


{-| -}
paddingXY :
    Breakpoints label
    ->
        (label
         ->
            { x : Value
            , y : Value
            }
        )
    -> Attribute msg
paddingXY resp toValue =
    varStyle "padding"
        (Internal.responsiveCssValue resp (toValue >> .y)
            ++ (" " ++ Internal.responsiveCssValue resp (toValue >> .x))
        )


{-| -}
paddingEach :
    Breakpoints label
    ->
        (label
         ->
            { top : Value
            , right : Value
            , bottom : Value
            , left : Value
            }
        )
    -> Attribute msg
paddingEach resp toValue =
    varStyle "padding"
        (Internal.responsiveCssValue resp (toValue >> .top)
            ++ (" " ++ Internal.responsiveCssValue resp (toValue >> .right))
            ++ (" " ++ Internal.responsiveCssValue resp (toValue >> .bottom))
            ++ (" " ++ Internal.responsiveCssValue resp (toValue >> .left))
        )


{-| -}
height : Breakpoints label -> (label -> Value) -> Attribute msg
height resp toValue =
    varStyle "height"
        (Internal.responsiveCssValue resp toValue)


{-| -}
heightMin : Breakpoints label -> (label -> Value) -> Attribute msg
heightMin resp toValue =
    varStyle "min-height"
        (Internal.responsiveCssValue resp toValue)


{-| -}
heightMax : Breakpoints label -> (label -> Value) -> Attribute msg
heightMax resp toValue =
    varStyle "max-height"
        (Internal.responsiveCssValue resp toValue)


{-| -}
width : Breakpoints label -> (label -> Value) -> Attribute msg
width resp toValue =
    varStyle "width"
        (Internal.responsiveCssValue resp toValue)


{-| -}
widthMin : Breakpoints label -> (label -> Value) -> Attribute msg
widthMin resp toValue =
    varStyle "min-width"
        (Internal.responsiveCssValue resp toValue)


{-| -}
widthMax : Breakpoints label -> (label -> Value) -> Attribute msg
widthMax resp toValue =
    varStyle "max-width"
        (Internal.responsiveCssValue resp toValue)


varStyle name val =
    Internal.styleAndClass Flag.skip
        { class = "ui-rs"
        , styleName = name
        , styleVal = val
        }


{-| Index of a label in the list of breakpoints

so for the following

    breakpoints : Ui.Responsive.Breakpoints Breakpoints
    breakpoints =
        Ui.Responsive.breakpoints ExtraLarge
            [ Ui.Responsive.breakAt 2400 Large
            , Ui.Responsive.breakAt 1400 Medium
            , Ui.Responsive.breakAt 800 Small
            ]

    0 -> ExtraLarge
    1 -> Large
    2 -> Medium
    3 -> Small

-}
getIndex : label -> Breakpoints label -> Int
getIndex target (Internal.Responsive details) =
    if target == details.default then
        0

    else
        getIndexHelper 1 target details.breaks


getIndexHelper i target breaks =
    case breaks of
        [] ->
            i

        ( _, top ) :: remain ->
            if top == target then
                i

            else
                getIndexHelper (i + 1) target remain
