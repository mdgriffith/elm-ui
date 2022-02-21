module Ui.Responsive exposing
    ( visible
    , Value, value, fluid
    , rowWhen, fontSize, padding
    , height, heightMin, heightMax
    , width, widthMin, widthMax
    , Breakpoints, breakpoints, Breakpoint, breakAt
    , orAbove, orBelow
    )

{-|

@docs visible

@docs Value, value, fluid

@docs rowWhen, fontSize, padding

@docs height, heightMin, heightMax

@docs width, widthMin, widthMax

@docs Breakpoints, breakpoints, Breakpoint, breakAt

    breakpoints : Ui.Responsive.Breakpoints Breakpoints
    breakpoints =
        Ui.Responsive.breakpoints ExtraLarge
            [ Ui.Responsive.breakAt 2400 Large
            , Ui.Responsive.breakAt 1400 Medium
            , Ui.Responsive.breakAt 800 Small
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

@docs orAbove, orBelow

-}

import Html.Attributes as Attr
import Internal.Flag as Flag
import Internal.Model2 as Internal
    exposing
        ( Attribute
        , Element
        , ResponsiveTransition
        )


{-| -}
type alias Breakpoints label =
    Internal.Breakpoints label


{-| -}
type alias Breakpoint label =
    Internal.Breakpoint label


{-| -}
orAbove : label -> Breakpoints label -> List label
orAbove label resp =
    fold
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
    fold
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
breakpoints : label -> List (Breakpoint label) -> Breakpoints label
breakpoints def breaks =
    Internal.Responsive
        { transition = Nothing
        , default = def
        , breaks = List.sortBy ((*) -1 << breakWidth) breaks
        , total = List.length breaks
        }


breakWidth : Breakpoint label -> Int
breakWidth (Internal.Breakpoint at _) =
    at


{-| -}
breakAt : Int -> label -> Breakpoint label
breakAt =
    Internal.Breakpoint


{-| -}
visible : Breakpoints label -> List label -> Attribute msg
visible breaks labels =
    Internal.class
        (fold
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
        (Ui.Responsive.belowOr Medium)
        [ Ui.spacing 20
        ]
        [ text "Hello!"
        , text "World!"
        ]

-}
rowWhen : Breakpoints label -> List label -> List (Attribute msg) -> List (Element msg) -> Element msg
rowWhen breaks labels attrs children =
    Internal.element Internal.AsRow
        (Internal.class
            (fold
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
type Value
    = Between Int Int
    | Exactly Int


{-| -}
fluid : Int -> Int -> Value
fluid low high =
    Between (min low high) (max low high)


{-| -}
value : Int -> Value
value =
    Exactly


{-| -}
fontSize : Breakpoints label -> (label -> Value) -> Attribute msg
fontSize resp toValue =
    varStyle "font-size"
        (calc <| cssValue resp toValue)


{-| -}
padding : Breakpoints label -> (label -> Value) -> Attribute msg
padding resp toValue =
    varStyle "padding"
        (calc <| cssValue resp toValue)


{-| -}
height : Breakpoints label -> (label -> Value) -> Attribute msg
height resp toValue =
    varStyle "height"
        (calc <| cssValue resp toValue)


{-| -}
heightMin : Breakpoints label -> (label -> Value) -> Attribute msg
heightMin resp toValue =
    varStyle "min-height"
        (calc <| cssValue resp toValue)


{-| -}
heightMax : Breakpoints label -> (label -> Value) -> Attribute msg
heightMax resp toValue =
    varStyle "max-height"
        (calc <| cssValue resp toValue)


{-| -}
width : Breakpoints label -> (label -> Value) -> Attribute msg
width resp toValue =
    varStyle "width"
        (calc <| cssValue resp toValue)


{-| -}
widthMin : Breakpoints label -> (label -> Value) -> Attribute msg
widthMin resp toValue =
    varStyle "min-width"
        (calc <| cssValue resp toValue)


{-| -}
widthMax : Breakpoints label -> (label -> Value) -> Attribute msg
widthMax resp toValue =
    varStyle "max-width"
        (calc <| cssValue resp toValue)


calc str =
    "calc(" ++ str ++ ")"


varStyle name val =
    Internal.styleAndClass Flag.skip
        { class = "ui-rs"
        , styleName = name
        , styleVal = val
        }


breakpointString i =
    "--ui-bp-" ++ String.fromInt i


cssValue : Breakpoints label -> (label -> Value) -> String
cssValue resp toValue =
    fold
        (\i lab str ->
            case str of
                "" ->
                    calc <| renderValue i (toValue lab)

                _ ->
                    str ++ " + " ++ calc (renderValue i (toValue lab))
        )
        ""
        resp


{-| Things to remember when using `calc`

<https://developer.mozilla.org/en-US/docs/Web/CSS/calc()>

1.  Multiplication needs one of the arguments to be a <number>, meaning a literal, with no units!

2.  Division needs the _denominator_ to be a <number>, again literal with no units.

-}
renderValue i v =
    ("var(" ++ breakpointString i ++ ") * ")
        ++ (case v of
                Exactly val ->
                    String.fromInt val ++ "px"

                Between bottom top ->
                    let
                        diff =
                            top - bottom
                    in
                    calc
                        (calc
                            ("var("
                                ++ breakpointString i
                                ++ "-progress) * "
                                ++ String.fromInt diff
                            )
                            ++ " + "
                            ++ String.fromInt bottom
                            ++ "px"
                        )
           )



{- Helpers -}


fold : (Int -> label -> result -> result) -> result -> Breakpoints label -> result
fold fn initial (Internal.Responsive resp) =
    foldHelper fn (fn 0 resp.default initial) 1 resp.breaks


foldHelper fn cursor i breaks =
    case breaks of
        [] ->
            cursor

        (Internal.Breakpoint _ label) :: remain ->
            foldHelper fn
                (fn i label cursor)
                (i + 1)
                remain


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

        (Internal.Breakpoint _ top) :: remain ->
            if top == target then
                i

            else
                getIndexHelper (i + 1) target remain
