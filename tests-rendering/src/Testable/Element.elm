module Testable.Element exposing
    ( Length(..)
    , above
    , alignBottom
    , alignLeft
    , alignRight
    , alignTop
    , alpha
    , behindContent
    , below
    , centerX
    , centerY
    , column
    , el
    , expectRoundedEquality
    , fill
    , fillPortion
    , height
    , inFront
    , isVisible
    , label
    , maximum
    , minimum
    , none
    , onLeft
    , onRight
    , padding
    , paddingXY
    , paragraph
    , px
    , row
    , shrink
    , spacing
    , text
    , textColumn
    , transparent
    , width
    )

{-| This module should mirror the top level `Element` api, with one important distinction.

The resulting `Element msg` structure can either be rendered to Html or transformed into a test suite that can be run.

In order to run the test:

  - render html
  - gather information from the browser
  - generate tests

-}

import Dict
import Element
import Expect
import Html.Attributes
import Testable


text : String -> Testable.Element msg
text =
    Testable.Text


el : List (Testable.Attr msg) -> Testable.Element msg -> Testable.Element msg
el =
    Testable.El


row : List (Testable.Attr msg) -> List (Testable.Element msg) -> Testable.Element msg
row =
    Testable.Row


column : List (Testable.Attr msg) -> List (Testable.Element msg) -> Testable.Element msg
column =
    Testable.Column


none : Testable.Element msg
none =
    Testable.Empty


paragraph : List (Testable.Attr msg) -> List (Testable.Element msg) -> Testable.Element msg
paragraph =
    Testable.Paragraph


textColumn : List (Testable.Attr msg) -> List (Testable.Element msg) -> Testable.Element msg
textColumn =
    Testable.TextColumn


type Length
    = Px Int
    | Fill Int
    | Shrink
    | Minimum Int Length
    | Maximum Int Length


minimum =
    Minimum


maximum =
    Maximum


px : Int -> Length
px =
    Px


fill : Length
fill =
    Fill 1


shrink : Length
shrink =
    Shrink


fillPortion : Int -> Length
fillPortion =
    Fill


label : String -> Testable.Attr msg
label =
    Testable.Label


transparent : Bool -> Testable.Attr msg
transparent on =
    Testable.LabeledTest
        { label =
            if on then
                "transparent"

            else
                "opaque"
        , attr = Element.transparent on
        , test =
            \context _ ->
                let
                    selfTransparency =
                        context.self.style
                            |> Dict.get "opacity"
                            |> Maybe.withDefault "notfound"

                    value =
                        if on then
                            "0"

                        else
                            "1"
                in
                Expect.equal value selfTransparency
        }


{-| -}
isVisible : Testable.Attr msg
isVisible =
    Testable.LabeledTest
        { label = "is-visible"
        , attr = Element.htmlAttribute (Html.Attributes.style "not" "applicable")
        , test =
            \context _ ->
                Expect.equal context.self.isVisible True
        }


{-| -}
alpha : Float -> Testable.Attr msg
alpha a =
    Testable.LabeledTest
        { label = "alpha-" ++ String.fromFloat a
        , attr = Element.alpha a
        , test =
            \context _ ->
                let
                    selfTransparency =
                        context.self.style
                            |> Dict.get "opacity"
                            |> Maybe.withDefault "notfound"
                in
                Expect.equal (String.fromFloat a) selfTransparency
        }


{-| -}
padding : Int -> Testable.Attr msg
padding pad =
    Testable.LabeledTest
        { label = "padding " ++ String.fromInt pad
        , attr = Element.padding pad
        , test =
            \found _ ->
                Expect.true ("Padding " ++ String.fromInt pad ++ " is present")
                    (List.all ((==) pad)
                        [ floor found.self.bbox.padding.left
                        , floor found.self.bbox.padding.right
                        , floor found.self.bbox.padding.top
                        , floor found.self.bbox.padding.bottom
                        ]
                    )
        }


{-| -}
paddingXY : Int -> Int -> Testable.Attr msg
paddingXY x y =
    Testable.LabeledTest
        { label = "paddingXY " ++ String.fromInt x ++ ", " ++ String.fromInt y
        , attr = Element.paddingXY x y
        , test =
            \found _ ->
                Expect.true ("PaddingXY (" ++ String.fromInt x ++ ", " ++ String.fromInt y ++ ") is present")
                    (List.all ((==) x)
                        [ floor found.self.bbox.padding.left
                        , floor found.self.bbox.padding.right
                        ]
                        && List.all ((==) y)
                            [ floor found.self.bbox.padding.top
                            , floor found.self.bbox.padding.bottom
                            ]
                    )
        }


widthHelper maybeMin maybeMax len =
    let
        addMin l =
            case maybeMin of
                Nothing ->
                    l

                Just minPx ->
                    l |> Element.minimum minPx

        addMax l =
            case maybeMax of
                Nothing ->
                    l

                Just maxPx ->
                    l |> Element.maximum maxPx

        minLabel =
            case maybeMin of
                Nothing ->
                    ""

                Just i ->
                    " min:" ++ String.fromInt i

        maxLabel =
            case maybeMax of
                Nothing ->
                    ""

                Just i ->
                    " max:" ++ String.fromInt i

        minMaxTest actualWidth =
            case ( maybeMin, maybeMax ) of
                ( Nothing, Nothing ) ->
                    True

                ( Just lower, Nothing ) ->
                    lower <= actualWidth

                ( Just lower, Just higher ) ->
                    lower <= actualWidth && actualWidth <= higher

                ( Nothing, Just higher ) ->
                    actualWidth <= higher
    in
    case len of
        Minimum m newLen ->
            widthHelper (Just m) maybeMax newLen

        Maximum m newLen ->
            widthHelper maybeMin (Just m) newLen

        Px val ->
            -- Pixel values should ignore min and max?
            Testable.LabeledTest
                { label = "width " ++ String.fromInt val ++ "px" ++ minLabel ++ maxLabel
                , attr =
                    Element.width
                        (Element.px val
                            |> addMin
                            |> addMax
                        )
                , test =
                    \found _ ->
                        Expect.all
                            [ \_ ->
                                Expect.true "exact width is exact" (floor found.self.bbox.width == val)
                            , \_ -> Expect.true "min/max is upheld" (minMaxTest (floor found.self.bbox.width))
                            ]
                            ()
                }

        Fill portion ->
            Testable.LabeledTest
                { label = "width fill-" ++ String.fromInt portion ++ minLabel ++ maxLabel
                , attr =
                    Element.width
                        (Element.fillPortion portion
                            |> addMin
                            |> addMax
                        )
                , test =
                    \context _ ->
                        if List.member context.location [ Testable.IsNearby Testable.OnRight, Testable.IsNearby Testable.OnLeft ] then
                            Expect.true "width fill doesn't apply to onright/onleft elements" True

                        else
                            let
                                parentAvailableWidth =
                                    context.parent.bbox.width - (context.self.bbox.padding.left + context.self.bbox.padding.right)
                            in
                            case context.location of
                                Testable.IsNearby _ ->
                                    Expect.true "Nearby Element has fill width"
                                        ((floor context.parent.bbox.width == floor context.self.bbox.width)
                                            || minMaxTest (floor context.self.bbox.width)
                                        )

                                Testable.InColumn ->
                                    Expect.true "Element within column has fill width"
                                        ((floor parentAvailableWidth == floor context.self.bbox.width)
                                            || minMaxTest (floor context.self.bbox.width)
                                        )

                                Testable.InEl ->
                                    Expect.true "Element within element has fill width" <|
                                        (floor parentAvailableWidth == floor context.self.bbox.width)
                                            || minMaxTest (floor context.self.bbox.width)

                                _ ->
                                    let
                                        spacePerPortion =
                                            parentAvailableWidth / toFloat (List.length context.siblings + 1)
                                    in
                                    Expect.true "element has fill width" <|
                                        (floor spacePerPortion == floor context.self.bbox.width)
                                            || minMaxTest (floor context.self.bbox.width)
                }

        Shrink ->
            Testable.LabeledTest
                { label = "width shrink" ++ minLabel ++ maxLabel
                , attr =
                    Element.width
                        (Element.shrink
                            |> addMin
                            |> addMax
                        )
                , test =
                    \context _ ->
                        let
                            childWidth child =
                                -- TODO: add margin values to widths
                                child.bbox.width

                            totalChildren =
                                context.children
                                    |> List.map childWidth
                                    |> List.sum

                            horizontalPadding =
                                context.self.bbox.padding.left + context.self.bbox.padding.right

                            spacingValue =
                                toFloat context.parentSpacing * (toFloat (List.length context.children) - 1)
                        in
                        if totalChildren == 0 then
                            -- TODO: The issue is that we have a hard time measuring `text` elements
                            -- So if a element has a text child, then it's width isn't going to show up in the system.
                            expectRoundedEquality context.self.bbox.width context.self.bbox.width

                        else
                            -- This fails if this element is actually a column
                            -- So we need to capture what this element is in order to do this calculation.
                            expectRoundedEquality (totalChildren + horizontalPadding + spacingValue) context.self.bbox.width
                }


heightHelper maybeMin maybeMax len =
    let
        addMin l =
            case maybeMin of
                Nothing ->
                    l

                Just minPx ->
                    l |> Element.minimum minPx

        addMax l =
            case maybeMax of
                Nothing ->
                    l

                Just maxPx ->
                    l |> Element.maximum maxPx

        minLabel =
            case maybeMin of
                Nothing ->
                    ""

                Just i ->
                    " min:" ++ String.fromInt i

        maxLabel =
            case maybeMax of
                Nothing ->
                    ""

                Just i ->
                    " max:" ++ String.fromInt i

        minMaxTest actualheight =
            case ( maybeMin, maybeMax ) of
                ( Nothing, Nothing ) ->
                    True

                ( Just lower, Nothing ) ->
                    lower <= actualheight

                ( Just lower, Just higher ) ->
                    lower <= actualheight && actualheight <= higher

                ( Nothing, Just higher ) ->
                    actualheight <= higher
    in
    case len of
        Minimum m newLen ->
            heightHelper (Just m) maybeMax newLen

        Maximum m newLen ->
            heightHelper maybeMin (Just m) newLen

        Px val ->
            -- Pixel values should ignore min and max?
            Testable.LabeledTest
                { label = "height " ++ String.fromInt val ++ "px" ++ minLabel ++ maxLabel
                , attr =
                    Element.height
                        (Element.px val
                            |> addMin
                            |> addMax
                        )
                , test =
                    \found _ ->
                        Expect.all
                            [ \_ ->
                                Expect.true ("exact height is exact: " ++ String.fromInt (floor found.self.bbox.height) ++ "," ++ String.fromInt val)
                                    (floor found.self.bbox.height == val)
                            , \_ ->
                                Expect.true "min/max holds true"
                                    (minMaxTest (floor found.self.bbox.height))
                            ]
                            ()
                }

        Fill portion ->
            Testable.LabeledTest
                { label = "height fill-" ++ String.fromInt portion ++ minLabel ++ maxLabel
                , attr =
                    Element.height
                        (Element.fillPortion portion
                            |> addMin
                            |> addMax
                        )
                , test =
                    \context _ ->
                        if List.member context.location [ Testable.IsNearby Testable.Above, Testable.IsNearby Testable.Below ] then
                            Expect.true "height fill doesn't apply to above/below elements" True

                        else
                            let
                                parentAvailableHeight =
                                    context.parent.bbox.height - (context.self.bbox.padding.top + context.self.bbox.padding.bottom)
                            in
                            case context.location of
                                Testable.IsNearby _ ->
                                    Expect.true "Nearby Element has fill height"
                                        ((floor context.parent.bbox.height == floor context.self.bbox.height)
                                            || minMaxTest (floor context.self.bbox.height)
                                        )

                                Testable.InColumn ->
                                    Expect.true "Element within column has fill height"
                                        ((floor parentAvailableHeight == floor context.self.bbox.height)
                                            || minMaxTest (floor context.self.bbox.height)
                                        )

                                Testable.InEl ->
                                    Expect.true "Element within el has fill height" <|
                                        (floor parentAvailableHeight == floor context.self.bbox.height)
                                            || minMaxTest (floor context.self.bbox.height)

                                _ ->
                                    let
                                        spacePerPortion =
                                            parentAvailableHeight / toFloat (List.length context.siblings + 1)
                                    in
                                    Expect.true "el has fill height" <|
                                        (floor spacePerPortion == floor context.self.bbox.height)
                                            || minMaxTest (floor context.self.bbox.height)
                }

        Shrink ->
            Testable.LabeledTest
                { label = "height shrink" ++ minLabel ++ maxLabel
                , attr =
                    Element.height
                        (Element.shrink
                            |> addMin
                            |> addMax
                        )
                , test =
                    \context _ ->
                        let
                            childWidth child =
                                -- TODO: add margin values to heights
                                child.bbox.height

                            totalChildren =
                                context.children
                                    |> List.map childWidth
                                    |> List.sum

                            verticalPadding =
                                context.self.bbox.padding.top + context.self.bbox.padding.bottom

                            spacingValue =
                                toFloat context.parentSpacing * (toFloat (List.length context.children) - 1)
                        in
                        if totalChildren == 0 then
                            -- TODO: The issue is that we have a hard time measuring `text` elements
                            -- So if a element has a text child, then it's height isn't going to show up in the system.
                            expectRoundedEquality context.self.bbox.height context.self.bbox.height

                        else
                            -- This fails if this element is actually a column
                            -- So we need to capture what this element is in order to do this calculation.
                            expectRoundedEquality (totalChildren + verticalPadding + spacingValue) context.self.bbox.height
                }


width : Length -> Testable.Attr msg
width len =
    widthHelper Nothing Nothing len


height : Length -> Testable.Attr msg
height len =
    heightHelper Nothing Nothing len


spacing : Int -> Testable.Attr msg
spacing space =
    Testable.Batch
        [ Testable.Spacing space
        , Testable.LabeledTest
            { label = "spacing: " ++ String.fromInt space
            , attr = Element.spacing space
            , test =
                \found _ ->
                    let
                        findDistance child total =
                            List.concatMap
                                (\otherChild ->
                                    let
                                        horizontal =
                                            round <|
                                                child.bbox.left
                                                    - otherChild.bbox.right

                                        vertical =
                                            round <|
                                                child.bbox.top
                                                    - otherChild.bbox.bottom
                                    in
                                    [ if horizontal > 0 then
                                        horizontal

                                      else
                                        space
                                    , if vertical > 0 then
                                        vertical

                                      else
                                        space
                                    ]
                                )
                                found.children
                                ++ total

                        distances =
                            List.foldl findDistance [] found.children

                        allAreSpaced =
                            List.foldl
                                (\x wrong ->
                                    if not (x >= space) then
                                        x :: wrong

                                    else
                                        wrong
                                )
                                []
                                distances
                    in
                    Expect.true
                        ("All children are at least "
                            ++ String.fromInt space
                            ++ " pixels apart."
                            ++ Debug.toString allAreSpaced
                            ++ " are not though"
                        )
                        (allAreSpaced == [])
            }
        ]


{-| alignLeft needs to account for

  - parent padding
  - elements to the left
  - spacing value

in order to calculate the expected result.

Also need parent rendering context if this is to work with wrapped rows in the future.

All sibling elements

-}
alignLeft : Testable.Attr msg
alignLeft =
    Testable.LabeledTest
        { label = "alignLeft"
        , attr = Element.alignLeft
        , test =
            \found _ ->
                if List.member found.location [ Testable.IsNearby Testable.OnLeft, Testable.IsNearby Testable.OnRight ] then
                    Expect.true "alignLeft doesn't apply to elements that are onLeft or onRight" True

                else if
                    List.member found.location
                        [ Testable.IsNearby Testable.InFront
                        , Testable.IsNearby Testable.Behind
                        , Testable.IsNearby Testable.Above
                        , Testable.IsNearby Testable.Below
                        ]
                then
                    expectRoundedEquality
                        found.self.bbox.left
                        found.parent.bbox.left

                else if List.length found.siblings == 0 then
                    expectRoundedEquality
                        found.self.bbox.left
                        (found.parent.bbox.left + found.parent.bbox.padding.left)

                else
                    case found.location of
                        Testable.InRow ->
                            let
                                siblingsOnLeft =
                                    List.filter (\x -> x.bbox.right < found.self.bbox.left) found.siblings

                                spacings =
                                    toFloat (List.length siblingsOnLeft * found.parentSpacing)

                                widthsOnLeft =
                                    siblingsOnLeft
                                        |> List.map (.width << .bbox)
                                        |> List.sum
                            in
                            expectRoundedEquality
                                found.self.bbox.left
                                (found.parent.bbox.left + (found.parent.bbox.padding.left + widthsOnLeft + spacings))

                        _ ->
                            expectRoundedEquality
                                found.self.bbox.left
                                (found.parent.bbox.left + found.parent.bbox.padding.left)
        }


{-| -}
centerX : Testable.Attr msg
centerX =
    Testable.LabeledTest
        { label = "centerX"
        , attr = Element.centerX
        , test =
            \found _ ->
                let
                    selfCenter : Float
                    selfCenter =
                        found.self.bbox.left + (found.self.bbox.width / 2)

                    parentCenter : Float
                    parentCenter =
                        found.parent.bbox.left + (found.parent.bbox.width / 2)
                in
                if List.member found.location [ Testable.IsNearby Testable.OnRight, Testable.IsNearby Testable.OnLeft ] then
                    Expect.true "centerX doesn't apply to elements that are onLeft or onRight" True

                else if List.length found.siblings == 0 then
                    expectRoundedEquality
                        selfCenter
                        parentCenter

                else
                    case found.location of
                        Testable.InRow ->
                            let
                                siblingsOnLeft =
                                    List.filter (\x -> x.bbox.right < found.self.bbox.left) found.siblings

                                siblingsOnRight =
                                    List.filter (\x -> x.bbox.left > found.self.bbox.right) found.siblings

                                widthsOnLeft : Float
                                widthsOnLeft =
                                    siblingsOnLeft
                                        |> List.map (.width << .bbox)
                                        |> List.sum
                                        |> (\x -> x + (toFloat (List.length siblingsOnLeft) * toFloat found.parentSpacing))

                                widthsOnRight =
                                    siblingsOnRight
                                        |> List.map (.width << .bbox)
                                        |> List.sum
                                        |> (\x -> x + (toFloat (List.length siblingsOnRight) * toFloat found.parentSpacing))

                                expectedCenter : Float
                                expectedCenter =
                                    found.parent.bbox.left
                                        + widthsOnLeft
                                        + ((found.parent.bbox.width - (widthsOnRight + widthsOnLeft))
                                            / 2
                                          )
                            in
                            expectRoundedEquality
                                selfCenter
                                expectedCenter

                        _ ->
                            expectRoundedEquality selfCenter parentCenter
        }


{-| -}
alignRight : Testable.Attr msg
alignRight =
    Testable.LabeledTest
        { label = "alignRight"
        , attr = Element.alignRight
        , test =
            \found _ ->
                if List.member found.location [ Testable.IsNearby Testable.OnLeft, Testable.IsNearby Testable.OnRight ] then
                    Expect.true "alignRight doesn't apply to elements that are onLeft or onRight" True

                else if
                    List.member found.location
                        [ Testable.IsNearby Testable.InFront
                        , Testable.IsNearby Testable.Behind
                        , Testable.IsNearby Testable.Above
                        , Testable.IsNearby Testable.Below
                        ]
                then
                    expectRoundedEquality
                        found.self.bbox.right
                        found.parent.bbox.right

                else if List.length found.siblings == 0 then
                    expectRoundedEquality
                        found.self.bbox.right
                        (found.parent.bbox.right + found.parent.bbox.padding.right)

                else
                    case found.location of
                        Testable.InRow ->
                            let
                                siblingsOnRight =
                                    List.filter (\x -> x.bbox.left > found.self.bbox.right) found.siblings

                                spacings =
                                    toFloat (List.length siblingsOnRight * found.parentSpacing)

                                widthsOnRight =
                                    siblingsOnRight
                                        |> List.map (.width << .bbox)
                                        |> List.sum
                            in
                            expectRoundedEquality
                                found.self.bbox.right
                                (found.parent.bbox.right - (found.parent.bbox.padding.right + widthsOnRight + spacings))

                        _ ->
                            expectRoundedEquality
                                found.self.bbox.right
                                (found.parent.bbox.right + found.parent.bbox.padding.right)
        }


{-| -}
alignTop : Testable.Attr msg
alignTop =
    Testable.LabeledTest
        { label = "alignTop"
        , attr = Element.alignTop
        , test =
            \found _ ->
                if List.member found.location [ Testable.IsNearby Testable.Above, Testable.IsNearby Testable.Below ] then
                    Expect.true "alignTop doesn't apply to elements that are above or below" True

                else if
                    List.member found.location
                        [ Testable.IsNearby Testable.InFront
                        , Testable.IsNearby Testable.Behind
                        , Testable.IsNearby Testable.OnRight
                        , Testable.IsNearby Testable.OnLeft
                        ]
                then
                    expectRoundedEquality
                        found.self.bbox.top
                        found.parent.bbox.top

                else if List.length found.siblings == 0 then
                    expectRoundedEquality
                        found.self.bbox.top
                        (found.parent.bbox.top + found.parent.bbox.padding.top)

                else
                    case found.location of
                        Testable.InColumn ->
                            let
                                siblingsAbove =
                                    List.filter (\x -> x.bbox.bottom < found.self.bbox.top) found.siblings

                                spacings =
                                    toFloat (List.length siblingsAbove * found.parentSpacing)

                                heightsAbove =
                                    siblingsAbove
                                        |> List.map (.height << .bbox)
                                        |> List.sum
                            in
                            expectRoundedEquality
                                found.self.bbox.top
                                (found.parent.bbox.top + (found.parent.bbox.padding.top + heightsAbove + spacings))

                        _ ->
                            expectRoundedEquality
                                found.self.bbox.top
                                found.parent.bbox.top
        }


{-| -}
alignBottom : Testable.Attr msg
alignBottom =
    Testable.LabeledTest
        { label = "alignBottom"
        , attr = Element.alignBottom
        , test =
            \found _ ->
                if List.member found.location [ Testable.IsNearby Testable.Above, Testable.IsNearby Testable.Below ] then
                    Expect.true "alignBottom doesn't apply to elements that are above or below" True

                else if
                    List.member found.location
                        [ Testable.IsNearby Testable.InFront
                        , Testable.IsNearby Testable.Behind
                        , Testable.IsNearby Testable.OnRight
                        , Testable.IsNearby Testable.OnLeft
                        ]
                then
                    expectRoundedEquality
                        found.self.bbox.bottom
                        found.parent.bbox.bottom

                else if List.length found.siblings == 0 then
                    expectRoundedEquality
                        found.self.bbox.bottom
                        (found.parent.bbox.bottom + found.parent.bbox.padding.bottom)

                else
                    case found.location of
                        Testable.InColumn ->
                            let
                                siblingsBelow =
                                    List.filter (\x -> x.bbox.top > found.self.bbox.bottom) found.siblings

                                spacings =
                                    toFloat (List.length siblingsBelow * found.parentSpacing)

                                heightsBelow =
                                    siblingsBelow
                                        |> List.map (.height << .bbox)
                                        |> List.sum
                            in
                            expectRoundedEquality
                                found.self.bbox.bottom
                                (found.parent.bbox.bottom - (found.parent.bbox.padding.bottom + heightsBelow + spacings))

                        _ ->
                            expectRoundedEquality
                                found.self.bbox.bottom
                                (found.parent.bbox.bottom + found.parent.bbox.padding.bottom)
        }


expectRoundedEquality x y =
    Expect.true ("within 1 of each other " ++ String.fromFloat x ++ ":" ++ String.fromFloat y)
        (abs (x - y) < 1)


{-| -}
centerY : Testable.Attr msg
centerY =
    Testable.LabeledTest
        { label = "centerY"
        , attr = Element.centerY
        , test =
            \found _ ->
                let
                    selfCenter =
                        found.self.bbox.top + (found.self.bbox.height / 2)

                    parentCenter =
                        found.parent.bbox.top + (found.parent.bbox.height / 2)
                in
                if List.member found.location [ Testable.IsNearby Testable.Above, Testable.IsNearby Testable.Below ] then
                    Expect.true "centerY doesn't apply to elements that are above or below" True

                else if List.length found.siblings == 0 then
                    expectRoundedEquality
                        selfCenter
                        parentCenter

                else
                    case found.location of
                        Testable.InColumn ->
                            let
                                siblingsOnTop =
                                    List.filter (\x -> x.bbox.bottom < found.self.bbox.top) found.siblings

                                siblingsBelow =
                                    List.filter (\x -> x.bbox.top > found.self.bbox.bottom) found.siblings

                                heightsAbove : Float
                                heightsAbove =
                                    siblingsOnTop
                                        |> List.map (.height << .bbox)
                                        |> List.sum
                                        |> (\x -> x + (toFloat (List.length siblingsOnTop) * toFloat found.parentSpacing))

                                heightsBelow =
                                    siblingsBelow
                                        |> List.map (.height << .bbox)
                                        |> List.sum
                                        |> (\x -> x + (toFloat (List.length siblingsBelow) * toFloat found.parentSpacing))

                                expectedCenter : Float
                                expectedCenter =
                                    found.parent.bbox.top
                                        + heightsAbove
                                        + ((found.parent.bbox.height - (heightsBelow + heightsAbove))
                                            / 2
                                          )
                            in
                            expectRoundedEquality
                                selfCenter
                                expectedCenter

                        _ ->
                            expectRoundedEquality selfCenter parentCenter
        }


{-| -}
above : Testable.Element msg -> Testable.Attr msg
above element =
    Testable.Nearby
        { location = Testable.Above
        , element = element
        , label = "above"
        , test =
            \found _ ->
                expectRoundedEquality found.self.bbox.bottom found.parent.bbox.top
        }


{-| -}
below : Testable.Element msg -> Testable.Attr msg
below element =
    Testable.Nearby
        { location = Testable.Below
        , element = element
        , label = "below"
        , test =
            \found _ ->
                expectRoundedEquality found.self.bbox.top found.parent.bbox.bottom
        }


{-| -}
onRight : Testable.Element msg -> Testable.Attr msg
onRight element =
    Testable.Nearby
        { location = Testable.OnRight
        , element = element
        , label = "onRight"
        , test =
            \found _ ->
                expectRoundedEquality found.self.bbox.left found.parent.bbox.right
        }


{-| -}
onLeft : Testable.Element msg -> Testable.Attr msg
onLeft element =
    Testable.Nearby
        { location = Testable.OnLeft
        , element = element
        , label = "onLeft"
        , test =
            \found _ ->
                expectRoundedEquality found.self.bbox.right found.parent.bbox.left
        }


compare x vs y =
    vs (round x) (round y) || vs (floor x) (floor y)


{-| -}
inFront : Testable.Element msg -> Testable.Attr msg
inFront element =
    Testable.Nearby
        { location = Testable.InFront
        , element = element
        , label = "inFront"
        , test =
            withinHelper
        }


withinHelper found _ =
    let
        horizontalCheck =
            if found.self.bbox.width > found.parent.bbox.width then
                [ compare found.self.bbox.right (<=) found.parent.bbox.right
                    || compare found.self.bbox.left (>=) found.parent.bbox.left
                ]

            else
                [ compare found.self.bbox.right (<=) found.parent.bbox.right
                , compare found.self.bbox.left (>=) found.parent.bbox.left
                ]

        verticalCheck =
            if found.self.bbox.width > found.parent.bbox.width then
                [ compare found.self.bbox.top (>=) found.parent.bbox.top
                    || compare found.self.bbox.bottom (<=) found.parent.bbox.bottom
                ]

            else
                [ compare found.self.bbox.top (>=) found.parent.bbox.top
                , compare found.self.bbox.bottom (<=) found.parent.bbox.bottom
                ]
    in
    Expect.true "within the confines of the parent"
        (List.all ((==) True)
            (List.concat
                [ horizontalCheck
                , verticalCheck
                ]
            )
        )


{-| -}
behindContent : Testable.Element msg -> Testable.Attr msg
behindContent element =
    Testable.Nearby
        { location = Testable.Behind
        , element = element
        , label = "behindContent"
        , test =
            withinHelper
        }
