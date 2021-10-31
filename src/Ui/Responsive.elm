module Ui.Responsive exposing
    ( visible
    , Value, value, fluid
    , rowWhen, fontSize, padding
    , height, heightMin, heightMax
    , width, widthMin, widthMax
    , breakpoints, breakAt
    , orAbove, orBelow
    , toMediaQuery
    )

{-|

@docs visible

@docs Value, value, fluid

@docs rowWhen, fontSize, padding

@docs height, heightMin, heightMax

@docs width, widthMin, widthMax

@docs breakpoints, breakAt

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
import Ui exposing (Attribute, Element)


type Breakpoints label
    = Responsive
        { transition : Maybe Transition
        , default : label
        , breaks : List (Breakpoint label)
        , total : Int
        }


type Breakpoint label
    = Breakpoint Int label


type alias Transition =
    { duration : Int
    }


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
    Responsive
        { transition = Nothing
        , default = def
        , breaks = List.sortBy ((*) -1 << breakWidth) breaks
        , total = List.length breaks
        }


breakWidth : Breakpoint label -> Int
breakWidth (Breakpoint at _) =
    at


{-| -}
breakAt : Int -> label -> Breakpoint label
breakAt =
    Breakpoint


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
    Ui.row
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
    Internal.Attribute
        { flag = Flag.skip
        , attr = Internal.ClassAndVarStyle "ui-rs" (name ++ ":" ++ val)
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
fold fn initial (Responsive resp) =
    foldHelper fn (fn 0 resp.default initial) 1 resp.breaks


foldHelper fn cursor i breaks =
    case breaks of
        [] ->
            cursor

        (Breakpoint _ label) :: remain ->
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
getIndex target (Responsive details) =
    if target == details.default then
        0

    else
        getIndexHelper 1 target details.breaks


getIndexHelper i target breaks =
    case breaks of
        [] ->
            i

        (Breakpoint _ top) :: remain ->
            if top == target then
                i

            else
                getIndexHelper (i + 1) target remain



{- Rendering -}


toMediaQuery : Breakpoints label -> String
toMediaQuery (Responsive details) =
    case details.breaks of
        [] ->
            ""

        (Breakpoint lowerBound _) :: remain ->
            ":root {"
                ++ toRoot details.breaks
                    1
                    (upperRootItem lowerBound)
                ++ " }"
                ++ toBoundedMediaQuery details.breaks
                    1
                    (renderUpper lowerBound)


renderRoot : Int -> String
renderRoot breakpointCounts =
    ":root {" ++ renderRootItem breakpointCounts "" ++ "}"


renderRootItem : Int -> String -> String
renderRootItem count rendered =
    if count <= 0 then
        rendered

    else
        renderRootItem (count - 1)
            (rendered ++ "--ui-bp-" ++ String.fromInt (count - 1) ++ ": 0;")


rootItem i upper lower =
    ("--ui-bp-" ++ String.fromInt i ++ ": 0;")
        ++ ("--ui-bp-" ++ String.fromInt i ++ "-upper: " ++ String.fromInt upper ++ "px;")
        ++ ("--ui-bp-" ++ String.fromInt i ++ "-lower: " ++ String.fromInt lower ++ "px;")
        ++ ("--ui-bp-"
                ++ String.fromInt i
                ++ "-progress: calc(calc(100vw - "
                ++ String.fromInt lower
                ++ "px) / "
                ++ String.fromInt (upper - lower)
                ++ ");"
           )


upperRootItem : Int -> String
upperRootItem lower =
    rootItem 0 (lower + 1000) lower


lowerRootItem : Int -> Int -> String
lowerRootItem i upper =
    rootItem i upper 0


toRoot : List (Breakpoint label) -> Int -> String -> String
toRoot breaks i rendered =
    case breaks of
        [] ->
            rendered

        [ Breakpoint upper _ ] ->
            rendered ++ lowerRootItem i upper

        (Breakpoint upper _) :: (((Breakpoint lower _) :: _) as tail) ->
            toRoot tail
                (i + 1)
                (rendered ++ rootItem i upper lower)


toBoundedMediaQuery : List (Breakpoint label) -> Int -> String -> String
toBoundedMediaQuery breaks i rendered =
    case breaks of
        [] ->
            rendered

        [ Breakpoint upper _ ] ->
            rendered ++ renderLower upper i

        (Breakpoint upper _) :: (((Breakpoint lower _) :: _) as tail) ->
            toBoundedMediaQuery tail
                (i + 1)
                (rendered ++ renderBounded upper lower i)


renderUpper : Int -> String
renderUpper lowerBound =
    "@media" ++ minWidth lowerBound ++ " { " ++ renderMediaProps 0 ++ " }"


renderLower : Int -> Int -> String
renderLower upperBound i =
    "@media " ++ maxWidth upperBound ++ " { " ++ renderMediaProps i ++ " }"


renderBounded : Int -> Int -> Int -> String
renderBounded upper lower i =
    "@media " ++ minWidth lower ++ " and " ++ maxWidth upper ++ " { " ++ renderMediaProps i ++ " }"


maxWidth : Int -> String
maxWidth int =
    "(max-width:" ++ String.fromInt int ++ "px)"


minWidth : Int -> String
minWidth int =
    "(min-width:" ++ String.fromInt (int + 1) ++ "px)"


renderMediaProps : Int -> String
renderMediaProps i =
    (":root {--ui-bp-" ++ String.fromInt i ++ ": 1;}")
        ++ (".ui-bp-" ++ String.fromInt i ++ "-hidden {display:none !important;}")
        ++ (".ui-bp-" ++ String.fromInt i ++ "-as-col: flex-direction: column;")
