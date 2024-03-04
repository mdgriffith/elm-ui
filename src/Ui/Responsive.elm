module Ui.Responsive exposing
    ( Breakpoints, breakpoints
    , visible
    , Value, value, fluid
    , rowWhen
    , padding, paddingXY, paddingEach
    , height, heightMin, heightMax
    , width, widthMin, widthMax
    , fontSize
    , orAbove, orBelow
    )

{-|

@docs Breakpoints, breakpoints

    {-| Translates into
        0-800       -> Small
        800-1400   -> Medium
        1400-2400  -> Large
        2400-above -> ExtraLarge
    -}
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

@docs padding, paddingXY, paddingEach

@docs height, heightMin, heightMax

@docs width, widthMin, widthMax

@docs fontSize

@docs orAbove, orBelow

-}

import Internal.Flag as Flag
import Internal.Model2 as Internal
    exposing
        ( Attribute
        , Element
        )


{-| -}
type alias Breakpoints label =
    Internal.Breakpoints label


{-| -}
orAbove : label -> Breakpoints label -> List label
orAbove label resp =
    Internal.foldBreakpoints
        (\_ lab ( capturing, selected ) ->
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
orBelow : label -> Breakpoints label -> List label
orBelow label resp =
    -- The breakpoint fold will start with the first, which is the smallest
    Internal.foldBreakpoints
        (\_ lab ( capturing, selected ) ->
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
breakpoints : label -> List ( Int, label ) -> Breakpoints label
breakpoints def breaks =
    Internal.toBreakpoints
        { default = def
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

    Ui.Reponsive.rowWhen (breakpoints.equal [ Medium ])
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
rowWhen breaks rowBreakPoints attrs children =
    Internal.element Internal.NodeAsDiv
        Internal.AsRow
        (Internal.class
            (Internal.foldBreakpoints
                (\i lab str ->
                    if List.member lab rowBreakPoints then
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


varStyle : String -> String -> Attribute msg
varStyle name val =
    Internal.styleAndClass Flag.skip
        { class = "ui-rs"
        , styleName = name
        , styleVal = val
        }
