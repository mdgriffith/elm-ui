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
    , clip
    , column
    , el
    , expectRoundedEquality
    , fill
    , height
    , inFront
    , isVisible
    , label
    , layout
    , link
    , moveDown
    , moveLeft
    , moveRight
    , moveUp
    , none
    , onLeft
    , onRight
    , padding
    , paddingXY
    , paragraph
    , portion
    , px
    , rgb
    , row
    , shrink
    , spacing
    , text
    , textColumn
    , toProgram
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
import Html.Attributes
import Testable
import Testable.Runner


{-| This is used when we want to run all tests in a test suite instead of one at a time.
-}
toProgram : Testable.Runner.Testable -> Testable.Runner.TestableProgram
toProgram testable =
    Testable.Runner.program [ testable ]


layout : List (Testable.Attr msg) -> Testable.Element Testable.Runner.Msg -> Testable.Runner.Testable
layout attrs elem =
    Testable.Runner.testable "Test" elem


text : String -> Testable.Element msg
text =
    Testable.Text


el : List (Testable.Attr msg) -> Testable.Element msg -> Testable.Element msg
el attrs =
    Testable.El (implicitWidthHeightShrink attrs)


row : List (Testable.Attr msg) -> List (Testable.Element msg) -> Testable.Element msg
row attrs =
    Testable.Row (implicitWidthHeightShrink attrs)


column : List (Testable.Attr msg) -> List (Testable.Element msg) -> Testable.Element msg
column attrs =
    Testable.Column (implicitWidthHeightShrink attrs)


none : Testable.Element msg
none =
    Testable.Empty


paragraph : List (Testable.Attr msg) -> List (Testable.Element msg) -> Testable.Element msg
paragraph attrs =
    let
        withImplicits =
            implicitTest (widthHelper Shrink)
                :: implicitTest (heightHelper Shrink)
                :: attrs
    in
    Testable.Paragraph (skipOverridden withImplicits)


textColumn : List (Testable.Attr msg) -> List (Testable.Element msg) -> Testable.Element msg
textColumn attrs =
    let
        withImplicits =
            implicitTest (widthHelper Shrink)
                :: implicitTest (heightHelper Shrink)
                :: attrs
    in
    Testable.TextColumn (skipOverridden withImplicits)


clip =
    Testable.Attr Element.clip


link details =
    Testable.Attr (Element.link details)



-- {-| -}
-- scrollbars : Testable.Attr msg
-- scrollbars =
--     Testable.Attr Element.scrollbars
-- {-| -}
-- scrollbarY : Testable.Attr msg
-- scrollbarY =
--     Testable.Attr Element.scrollbarY
-- {-| -}
-- scrollbarX : Testable.Attr msg
-- scrollbarX =
--     Testable.Attr Element.scrollbarX


{-| Old labeling mechanism that i removed to hastily
-}
label str =
    Testable.Batch []


moveUp x =
    Testable.Attr (Element.moveUp x)


moveDown x =
    Testable.Attr (Element.moveDown x)


moveRight x =
    Testable.Attr (Element.moveRight x)


moveLeft x =
    Testable.Attr (Element.moveLeft x)


type Length
    = Px Int
    | Fill Int
    | Shrink


rgb : Int -> Int -> Int -> Element.Color
rgb =
    Element.rgb


px : Int -> Length
px =
    Px


fill : Length
fill =
    Fill 1


shrink : Length
shrink =
    Shrink


portion : Int -> Length
portion =
    Fill


transparent : Bool -> Testable.Attr msg
transparent on =
    Testable.LabeledTest
        { label =
            if on then
                "transparent"

            else
                "opaque"
        , attr = Element.transparent on
        , id = Testable.NoId
        , test =
            \context ->
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
                [ Testable.equal value selfTransparency ]
        }


{-| -}
isVisible : Testable.Attr msg
isVisible =
    Testable.AttrTest
        { label = "is-visible"
        , id = Testable.NoId
        , test =
            \context ->
                [ Testable.equal context.self.isVisible True ]
        }


{-| -}
alpha : Float -> Testable.Attr msg
alpha a =
    Testable.LabeledTest
        { label = "alpha-" ++ String.fromFloat a
        , attr = Element.alpha a
        , id = Testable.NoId
        , test =
            \context ->
                let
                    selfTransparency =
                        context.self.style
                            |> Dict.get "opacity"
                            |> Maybe.withDefault "notfound"
                in
                [ Testable.equal (String.fromFloat a) selfTransparency ]
        }


{-| -}
padding : Int -> Testable.Attr msg
padding pad =
    Testable.LabeledTest
        { label = "padding " ++ String.fromInt pad
        , attr = Element.padding pad
        , id = Testable.NoId
        , test =
            \found ->
                [ Testable.true ("Padding " ++ String.fromInt pad ++ " is present")
                    (List.all ((==) pad)
                        [ floor found.self.bbox.padding.left
                        , floor found.self.bbox.padding.right
                        , floor found.self.bbox.padding.top
                        , floor found.self.bbox.padding.bottom
                        ]
                    )
                ]
        }


{-| -}
paddingXY : Int -> Int -> Testable.Attr msg
paddingXY x y =
    Testable.LabeledTest
        { label = "paddingXY " ++ String.fromInt x ++ ", " ++ String.fromInt y
        , attr = Element.paddingXY x y
        , id = Testable.NoId
        , test =
            \found ->
                [ Testable.true ("PaddingXY (" ++ String.fromInt x ++ ", " ++ String.fromInt y ++ ") is present")
                    (List.all ((==) x)
                        [ floor found.self.bbox.padding.left
                        , floor found.self.bbox.padding.right
                        ]
                        && List.all ((==) y)
                            [ floor found.self.bbox.padding.top
                            , floor found.self.bbox.padding.bottom
                            ]
                    )
                ]
        }


listIf ls =
    List.filter Tuple.first ls
        |> List.map Tuple.second


widthHelper len =
    case len of
        Px val ->
            -- Pixel values should ignore min and max?
            Testable.LabeledTest
                { label = "width " ++ String.fromInt val ++ "px"
                , id = Testable.IsWidth
                , attr =
                    Element.width
                        (Element.px val)
                , test =
                    \found ->
                        [ expectRoundedEquality
                            { expected = toFloat val
                            , found = found.self.bbox.width
                            }
                        ]
                }

        Fill p ->
            Testable.LabeledTest
                { label =
                    if p == 1 then
                        "width fill"

                    else
                        "width fill-" ++ String.fromInt p
                , id = Testable.IsWidth
                , attr =
                    Element.width
                        (Element.portion p)
                , test =
                    \context ->
                        if List.member context.parentLayout [ Testable.IsNearby Testable.OnRight, Testable.IsNearby Testable.OnLeft ] then
                            [ Testable.true "width fill doesn't apply to onright/onleft elements" True ]

                        else
                            let
                                parentAvailableWidth =
                                    context.parent.bbox.width - (context.self.bbox.padding.left + context.self.bbox.padding.right)
                            in
                            List.concat
                                [ case context.parentLayout of
                                    Testable.IsNearby _ ->
                                        [ Testable.true "Nearby Element has fill width"
                                            (floor context.parent.bbox.width == floor context.self.bbox.width)
                                        ]

                                    Testable.InColumn ->
                                        [ Testable.true "Element within column has fill width"
                                            (floor parentAvailableWidth == floor context.self.bbox.width)
                                        ]

                                    Testable.InEl ->
                                        [ Testable.true "Element within element has fill width" <|
                                            (floor parentAvailableWidth == floor context.self.bbox.width)
                                        ]

                                    _ ->
                                        let
                                            spacePerPortion =
                                                parentAvailableWidth / toFloat (List.length context.siblings + 1)
                                        in
                                        [ Testable.true "element has fill width" <|
                                            (floor spacePerPortion == floor context.self.bbox.width)
                                        ]
                                , [ Testable.lessThanOrEqual "not larger than parent"
                                        context.self.bbox.width
                                        context.parent.bbox.width
                                  ]
                                , case context.selfElement of
                                    Testable.Paragraph _ _ ->
                                        -- A paragraph with width fill
                                        -- we want to test for correct text wrapping here.
                                        --
                                        let
                                            childWidth child =
                                                child.bbox.width

                                            totalChildren =
                                                context.children
                                                    |> List.map childWidth
                                                    |> List.append (List.map .width context.self.textMetrics)
                                                    |> List.sum

                                            horizontalPadding =
                                                context.self.bbox.padding.left + context.self.bbox.padding.right

                                            totalCalculatedWidth =
                                                totalChildren + horizontalPadding

                                            expectedLines =
                                                if boxChildrenHeight > 20 then
                                                    ceiling (boxChildrenHeight / 20)

                                                else
                                                    ceiling (totalCalculatedWidth / context.self.bbox.width)

                                            boxChildrenHeight =
                                                context.children
                                                    |> List.map
                                                        (\c ->
                                                            c.bbox.height
                                                        )
                                                    |> List.sum
                                        in
                                        [ Testable.true "text wrapping, checking height"
                                            -- all we're doing here is testing if wrapping is occurring
                                            -- not the exact height, which is a little tricky to calculate perfectly without more information.
                                            (if expectedLines > 1 then
                                                context.self.bbox.height >= (20 * 2)

                                             else
                                                -- then it's less than 2 ~ line heights
                                                -- there's some weird variance here which makes it hard to be exact.
                                                context.self.bbox.height < (20 * 2)
                                            )
                                        ]

                                    _ ->
                                        []
                                ]
                }

        Shrink ->
            Testable.LabeledTest
                { label = "width shrink"
                , attr =
                    -- This is now the default for all elements
                    -- so we're just attaching a test here
                    Element.htmlAttribute (Html.Attributes.class "")
                , id = Testable.IsWidth
                , test =
                    \context ->
                        case context.selfElement of
                            Testable.El _ _ ->
                                let
                                    childWidth child =
                                        child.bbox.width

                                    totalChildren =
                                        context.children
                                            |> List.map childWidth
                                            |> List.append (List.map .width context.self.textMetrics)
                                            |> List.sum

                                    horizontalPadding =
                                        context.self.bbox.padding.left + context.self.bbox.padding.right
                                in
                                listIf
                                    [ ( (context.parentLayout /= Testable.InParagraph)
                                            && (context.parentLayout /= Testable.InTextCol)
                                      , Testable.rounded "equals children"
                                            { expected = totalChildren + horizontalPadding
                                            , found = context.self.bbox.width
                                            }
                                      )
                                    , ( context.parentLayout /= Testable.AtRoot
                                      , Testable.lessThanOrEqual "not larger than parent"
                                            context.self.bbox.width
                                            context.parent.bbox.width
                                      )
                                    ]

                            Testable.Row rowAttrs _ ->
                                -- width of row is the sum of all children widths
                                -- both text elements and others.
                                let
                                    childWidth child =
                                        child.bbox.width

                                    totalChildren =
                                        context.children
                                            |> List.map childWidth
                                            |> List.append (List.map .width context.self.textMetrics)
                                            |> List.sum

                                    horizontalPadding =
                                        context.self.bbox.padding.left + context.self.bbox.padding.right

                                    spacingAmount =
                                        Testable.getSpacingFromAttributes rowAttrs

                                    totalSpacing =
                                        toFloat spacingAmount * (toFloat (List.length context.children) - 1)
                                in
                                listIf
                                    [ ( True
                                      , expectRoundedEquality
                                            { expected = totalChildren + horizontalPadding + totalSpacing
                                            , found = context.self.bbox.width
                                            }
                                      )
                                    , ( context.parentLayout /= Testable.AtRoot
                                      , Testable.lessThanOrEqual "not larger than parent"
                                            context.self.bbox.width
                                            context.parent.bbox.width
                                      )
                                    ]

                            Testable.Column _ _ ->
                                -- The width of the column is the width of the widest child.
                                let
                                    childWidth child =
                                        child.bbox.width
                                            + context.self.bbox.padding.left
                                            + context.self.bbox.padding.right

                                    textChildren =
                                        List.map
                                            (\txt ->
                                                txt.width
                                                    + context.self.bbox.padding.left
                                                    + context.self.bbox.padding.right
                                            )
                                            context.self.textMetrics

                                    allChildren =
                                        context.children
                                            |> List.map childWidth
                                            |> List.append textChildren
                                in
                                listIf
                                    [ ( True
                                      , expectRoundedEquality
                                            { expected = Maybe.withDefault 0 (List.maximum allChildren)
                                            , found = context.self.bbox.width
                                            }
                                      )
                                    , ( context.parentLayout /= Testable.AtRoot
                                      , Testable.lessThanOrEqual "not larger than parent"
                                            context.self.bbox.width
                                            context.parent.bbox.width
                                      )
                                    ]

                            Testable.TextColumn _ _ ->
                                -- The width of the column is the width of the widest child.
                                let
                                    childWidth child =
                                        child.bbox.width
                                            + context.self.bbox.padding.left
                                            + context.self.bbox.padding.right

                                    textChildren =
                                        List.map
                                            (\txt ->
                                                txt.width
                                                    + context.self.bbox.padding.left
                                                    + context.self.bbox.padding.right
                                            )
                                            context.self.textMetrics

                                    allChildren =
                                        context.children
                                            |> List.map childWidth
                                            |> List.append textChildren
                                in
                                listIf
                                    [ ( True
                                      , expectRoundedEquality
                                            { expected = Maybe.withDefault 0 (List.maximum allChildren)
                                            , found = context.self.bbox.width
                                            }
                                      )
                                    , ( context.parentLayout /= Testable.AtRoot
                                      , Testable.lessThanOrEqual "not larger than parent"
                                            context.self.bbox.width
                                            context.parent.bbox.width
                                      )
                                    ]

                            Testable.Paragraph _ _ ->
                                -- This should be the size it's text,
                                -- unless it takes up all available space, in which case it should wrap.
                                let
                                    childWidth child =
                                        child.bbox.width

                                    totalChildren =
                                        context.children
                                            |> List.map childWidth
                                            |> List.append (List.map .width context.self.textMetrics)
                                            |> List.sum

                                    horizontalPadding =
                                        context.self.bbox.padding.left + context.self.bbox.padding.right
                                in
                                listIf
                                    [ ( True
                                      , expectRoundedEquality
                                            { expected = totalChildren + horizontalPadding
                                            , found = context.self.bbox.width
                                            }
                                      )
                                    , ( context.parentLayout /= Testable.AtRoot
                                      , Testable.lessThanOrEqual "not larger than parent"
                                            context.self.bbox.width
                                            context.parent.bbox.width
                                      )
                                    ]

                            Testable.Text _ ->
                                []

                            Testable.Empty ->
                                []
                }


heightHelper : Length -> Testable.Attr msg
heightHelper len =
    case len of
        Px val ->
            -- Pixel values should ignore min and max?
            Testable.LabeledTest
                { label = "height " ++ String.fromInt val ++ "px"
                , attr =
                    Element.height
                        (Element.px val)
                , id = Testable.IsHeight
                , test =
                    \found ->
                        [ expectRoundedEquality
                            { expected = toFloat val
                            , found = found.self.bbox.height
                            }
                        ]
                }

        Fill p ->
            Testable.LabeledTest
                { label = "height fill-" ++ String.fromInt p
                , attr =
                    Element.height
                        (Element.portion p)
                , id = Testable.IsHeight
                , test =
                    \context ->
                        [ if List.member context.parentLayout [ Testable.IsNearby Testable.Above, Testable.IsNearby Testable.Below ] then
                            Testable.true "height fill doesn't apply to above/below elements" True

                          else
                            let
                                parentAvailableHeight =
                                    context.parent.bbox.height - (context.self.bbox.padding.top + context.self.bbox.padding.bottom)
                            in
                            case context.parentLayout of
                                Testable.IsNearby _ ->
                                    Testable.true "Nearby Element has fill height"
                                        (floor context.parent.bbox.height == floor context.self.bbox.height)

                                Testable.InColumn ->
                                    Testable.true "Element within column has fill height"
                                        (floor parentAvailableHeight == floor context.self.bbox.height)

                                Testable.InEl ->
                                    Testable.true "Element within el has fill height" <|
                                        (floor parentAvailableHeight == floor context.self.bbox.height)

                                _ ->
                                    let
                                        spacePerPortion =
                                            parentAvailableHeight / toFloat (List.length context.siblings + 1)
                                    in
                                    Testable.true "el has fill height" <|
                                        (floor spacePerPortion == floor context.self.bbox.height)
                        ]
                }

        Shrink ->
            Testable.LabeledTest
                { label = "height shrink"
                , attr =
                    -- This is now the default for all elements
                    -- so we're just attaching a test here
                    Element.htmlAttribute (Html.Attributes.class "")
                , id = Testable.IsHeight
                , test =
                    \context ->
                        case context.selfElement of
                            Testable.El _ _ ->
                                let
                                    childHeight child =
                                        child.bbox.height
                                in
                                if List.isEmpty context.children then
                                    -- context.self.textMetrics
                                    --     |> List.map Testable.textHeight
                                    --     |> List.sum
                                    -- TODO: apparently the font metrics we have are for the literal characters rendered
                                    -- not for the font itself.
                                    [ Testable.todo "calculate height from actual text metrics"
                                    ]

                                else
                                    [ expectRoundedEquality
                                        { expected =
                                            context.children
                                                |> List.map childHeight
                                                |> List.sum
                                                |> (\h -> h + context.self.bbox.padding.top + context.self.bbox.padding.bottom)
                                        , found = context.self.bbox.height
                                        }
                                    , Testable.lessThanOrEqual "not larger than parent"
                                        context.self.bbox.height
                                        context.parent.bbox.height
                                    ]

                            Testable.Row _ _ ->
                                let
                                    childHeight child =
                                        child.bbox.height
                                in
                                if List.isEmpty context.children then
                                    -- context.self.textMetrics
                                    --     |> List.map Testable.textHeight
                                    --     |> List.sum
                                    -- TODO: apparently the font metrics we have are for the literal characters rendered
                                    -- not for the font itself.
                                    [ Testable.todo "calculate height from actual text metrics" ]

                                else
                                    [ expectRoundedEquality
                                        { expected =
                                            context.children
                                                |> List.map childHeight
                                                |> List.maximum
                                                |> Maybe.withDefault 0
                                                |> (\h -> h + context.self.bbox.padding.top + context.self.bbox.padding.bottom)
                                        , found = context.self.bbox.height
                                        }
                                    , Testable.lessThanOrEqual "not larger than parent"
                                        context.self.bbox.height
                                        context.parent.bbox.height
                                    ]

                            Testable.Column colAttrs _ ->
                                let
                                    childHeight child =
                                        child.bbox.height

                                    totalChildren =
                                        context.children
                                            |> List.map childHeight
                                            |> List.append (List.map Testable.textHeight context.self.textMetrics)
                                            |> List.sum

                                    verticalPadding =
                                        context.self.bbox.padding.top + context.self.bbox.padding.bottom

                                    spacingAmount =
                                        Testable.getSpacingFromAttributes colAttrs

                                    totalSpacing =
                                        toFloat spacingAmount * (toFloat (List.length context.children) - 1)
                                in
                                [ expectRoundedEquality
                                    { expected = totalChildren + verticalPadding + totalSpacing
                                    , found = context.self.bbox.height
                                    }
                                , Testable.lessThanOrEqual "not larger than parent"
                                    context.self.bbox.height
                                    context.parent.bbox.height
                                ]

                            Testable.TextColumn _ _ ->
                                []

                            Testable.Paragraph _ _ ->
                                []

                            Testable.Text _ ->
                                []

                            Testable.Empty ->
                                []
                }


width : Length -> Testable.Attr msg
width len =
    widthHelper len


widthMax : Int -> Testable.Attr msg
widthMax m =
    Testable.LabeledTest
        { label = "width max " ++ String.fromInt m ++ "px"
        , id = Testable.NoId
        , attr =
            Element.widthMax m
        , test =
            \found ->
                [ Testable.true "max width is upheld"
                    (floor found.self.bbox.width <= m)
                ]
        }


widthMin : Int -> Testable.Attr msg
widthMin m =
    Testable.LabeledTest
        { label = "width min " ++ String.fromInt m ++ "px"
        , id = Testable.NoId
        , attr =
            Element.widthMax m
        , test =
            \found ->
                [ Testable.true "min width is upheld"
                    (floor found.self.bbox.width >= m)
                ]
        }


height : Length -> Testable.Attr msg
height len =
    heightHelper len


spacing : Int -> Testable.Attr msg
spacing space =
    Testable.Batch
        [ Testable.Spacing space
        , Testable.LabeledTest
            { label = "spacing: " ++ String.fromInt space
            , attr = Element.spacing space
            , id = Testable.NoId
            , test =
                \found ->
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
                    [ Testable.true
                        ("All children are at least "
                            ++ String.fromInt space
                            ++ " pixels apart."
                            ++ Debug.toString allAreSpaced
                            ++ " are not though"
                        )
                        (allAreSpaced == [])
                    ]
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
        , id = Testable.NoId
        , test =
            \found ->
                [ if List.member found.parentLayout [ Testable.IsNearby Testable.OnLeft, Testable.IsNearby Testable.OnRight ] then
                    Testable.true "alignLeft doesn't apply to elements that are onLeft or onRight" True

                  else if
                    List.member found.parentLayout
                        [ Testable.IsNearby Testable.InFront
                        , Testable.IsNearby Testable.Behind
                        , Testable.IsNearby Testable.Above
                        , Testable.IsNearby Testable.Below
                        ]
                  then
                    expectRoundedEquality
                        { found = found.self.bbox.left
                        , expected = found.parent.bbox.left
                        }

                  else if List.length found.siblings == 0 then
                    expectRoundedEquality
                        { found = found.self.bbox.left
                        , expected = found.parent.bbox.left + found.parent.bbox.padding.left
                        }

                  else
                    case found.parentLayout of
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
                                { found = found.self.bbox.left
                                , expected = found.parent.bbox.left + (found.parent.bbox.padding.left + widthsOnLeft + spacings)
                                }

                        _ ->
                            expectRoundedEquality
                                { found = found.self.bbox.left
                                , expected = found.parent.bbox.left + found.parent.bbox.padding.left
                                }
                ]
        }


{-| -}
centerX : Testable.Attr msg
centerX =
    Testable.LabeledTest
        { label = "centerX"
        , attr = Element.centerX
        , id = Testable.NoId
        , test =
            \found ->
                let
                    selfCenter : Float
                    selfCenter =
                        found.self.bbox.left + (found.self.bbox.width / 2)

                    parentCenter : Float
                    parentCenter =
                        found.parent.bbox.left + (found.parent.bbox.width / 2)
                in
                if List.member found.parentLayout [ Testable.IsNearby Testable.OnRight, Testable.IsNearby Testable.OnLeft ] then
                    [ Testable.true "centerX doesn't apply to elements that are onLeft or onRight" True ]

                else if List.length found.siblings == 0 then
                    [ expectRoundedEquality
                        { found = selfCenter
                        , expected = parentCenter
                        }
                    ]

                else
                    case found.parentLayout of
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
                            [ expectRoundedEquality
                                { found = selfCenter
                                , expected = expectedCenter
                                }
                            ]

                        _ ->
                            [ expectRoundedEquality
                                { found = selfCenter
                                , expected = parentCenter
                                }
                            ]
        }


{-| -}
alignRight : Testable.Attr msg
alignRight =
    Testable.LabeledTest
        { label = "alignRight"
        , attr = Element.alignRight
        , id = Testable.NoId
        , test =
            \found ->
                if List.member found.parentLayout [ Testable.IsNearby Testable.OnLeft, Testable.IsNearby Testable.OnRight ] then
                    [ Testable.true "alignRight doesn't apply to elements that are onLeft or onRight" True ]

                else if
                    List.member found.parentLayout
                        [ Testable.IsNearby Testable.InFront
                        , Testable.IsNearby Testable.Behind
                        , Testable.IsNearby Testable.Above
                        , Testable.IsNearby Testable.Below
                        ]
                then
                    [ expectRoundedEquality
                        { found = found.self.bbox.right
                        , expected = found.parent.bbox.right
                        }
                    ]

                else if List.length found.siblings == 0 then
                    [ expectRoundedEquality
                        { found = found.self.bbox.right
                        , expected = found.parent.bbox.right + found.parent.bbox.padding.right
                        }
                    ]

                else
                    case found.parentLayout of
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
                            [ expectRoundedEquality
                                { found = found.self.bbox.right
                                , expected = found.parent.bbox.right - (found.parent.bbox.padding.right + widthsOnRight + spacings)
                                }
                            ]

                        _ ->
                            [ expectRoundedEquality
                                { found = found.self.bbox.right
                                , expected = found.parent.bbox.right + found.parent.bbox.padding.right
                                }
                            ]
        }


{-| -}
alignTop : Testable.Attr msg
alignTop =
    Testable.LabeledTest
        { label = "alignTop"
        , attr = Element.alignTop
        , id = Testable.NoId
        , test =
            \found ->
                if List.member found.parentLayout [ Testable.IsNearby Testable.Above, Testable.IsNearby Testable.Below ] then
                    [ Testable.true "alignTop doesn't apply to elements that are above or below" True ]

                else if
                    List.member found.parentLayout
                        [ Testable.IsNearby Testable.InFront
                        , Testable.IsNearby Testable.Behind
                        , Testable.IsNearby Testable.OnRight
                        , Testable.IsNearby Testable.OnLeft
                        ]
                then
                    [ expectRoundedEquality
                        { found = found.self.bbox.top
                        , expected = found.parent.bbox.top
                        }
                    ]

                else if List.length found.siblings == 0 then
                    [ expectRoundedEquality
                        { found = found.self.bbox.top
                        , expected = found.parent.bbox.top + found.parent.bbox.padding.top
                        }
                    ]

                else
                    case found.parentLayout of
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
                            [ expectRoundedEquality
                                { found = found.self.bbox.top
                                , expected = found.parent.bbox.top + (found.parent.bbox.padding.top + heightsAbove + spacings)
                                }
                            ]

                        _ ->
                            [ expectRoundedEquality
                                { found = found.self.bbox.top
                                , expected = found.parent.bbox.top
                                }
                            ]
        }


{-| -}
alignBottom : Testable.Attr msg
alignBottom =
    Testable.LabeledTest
        { label = "alignBottom"
        , attr = Element.alignBottom
        , id = Testable.NoId
        , test =
            \found ->
                if List.member found.parentLayout [ Testable.IsNearby Testable.Above, Testable.IsNearby Testable.Below ] then
                    [ Testable.true "alignBottom doesn't apply to elements that are above or below" True ]

                else if
                    List.member found.parentLayout
                        [ Testable.IsNearby Testable.InFront
                        , Testable.IsNearby Testable.Behind
                        , Testable.IsNearby Testable.OnRight
                        , Testable.IsNearby Testable.OnLeft
                        ]
                then
                    [ expectRoundedEquality
                        { found = found.self.bbox.bottom
                        , expected = found.parent.bbox.bottom
                        }
                    ]

                else if List.length found.siblings == 0 then
                    [ expectRoundedEquality
                        { found = found.self.bbox.bottom
                        , expected = found.parent.bbox.bottom + found.parent.bbox.padding.bottom
                        }
                    ]

                else
                    case found.parentLayout of
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
                            [ expectRoundedEquality
                                { found = found.self.bbox.bottom
                                , expected = found.parent.bbox.bottom - (found.parent.bbox.padding.bottom + heightsBelow + spacings)
                                }
                            ]

                        _ ->
                            [ expectRoundedEquality
                                { found = found.self.bbox.bottom
                                , expected = found.parent.bbox.bottom + found.parent.bbox.padding.bottom
                                }
                            ]
        }


expectRoundedEquality : { expected : Float, found : Float } -> Testable.LayoutExpectation
expectRoundedEquality { expected, found } =
    Testable.true
        ("expected " ++ floatToString expected ++ ", found " ++ floatToString found)
        (abs (expected - found) < 1)


floatToString : Float -> String
floatToString x =
    String.fromFloat (toFloat (round (x * 100)) / 100)


{-| -}
centerY : Testable.Attr msg
centerY =
    Testable.LabeledTest
        { label = "centerY"
        , attr = Element.centerY
        , id = Testable.NoId
        , test =
            \found ->
                let
                    selfCenter =
                        found.self.bbox.top + (found.self.bbox.height / 2)

                    parentCenter =
                        found.parent.bbox.top + (found.parent.bbox.height / 2)
                in
                if List.member found.parentLayout [ Testable.IsNearby Testable.Above, Testable.IsNearby Testable.Below ] then
                    [ Testable.true "centerY doesn't apply to elements that are above or below" True ]

                else if List.length found.siblings == 0 then
                    [ expectRoundedEquality
                        { found = selfCenter
                        , expected = parentCenter
                        }
                    ]

                else
                    case found.parentLayout of
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
                            [ expectRoundedEquality
                                { found = selfCenter
                                , expected = expectedCenter
                                }
                            ]

                        _ ->
                            [ expectRoundedEquality
                                { found = selfCenter
                                , expected = parentCenter
                                }
                            ]
        }


{-| -}
above : Testable.Element msg -> Testable.Attr msg
above element =
    Testable.Nearby
        { location = Testable.Above
        , element = element
        , label = "above"
        , test =
            \found ->
                [ expectRoundedEquality
                    { found = found.self.bbox.bottom
                    , expected = found.parent.bbox.top
                    }
                ]
        }


{-| -}
below : Testable.Element msg -> Testable.Attr msg
below element =
    Testable.Nearby
        { location = Testable.Below
        , element = element
        , label = "below"
        , test =
            \found ->
                [ expectRoundedEquality
                    { found = found.self.bbox.top
                    , expected = found.parent.bbox.bottom
                    }
                ]
        }


{-| -}
onRight : Testable.Element msg -> Testable.Attr msg
onRight element =
    Testable.Nearby
        { location = Testable.OnRight
        , element = element
        , label = "onRight"
        , test =
            \found ->
                [ expectRoundedEquality
                    { found = found.self.bbox.left
                    , expected = found.parent.bbox.right
                    }
                ]
        }


{-| -}
onLeft : Testable.Element msg -> Testable.Attr msg
onLeft element =
    Testable.Nearby
        { location = Testable.OnLeft
        , element = element
        , label = "onLeft"
        , test =
            \found ->
                [ expectRoundedEquality
                    { found = found.self.bbox.right
                    , expected = found.parent.bbox.left
                    }
                ]
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
            \found ->
                [ withinHelper found ]
        }


withinHelper found =
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
    Testable.true "within the confines of the parent"
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
            \found ->
                [ withinHelper found ]
        }



{- Implicit width/height calcualtions -}


implicitWidthHeightShrink attrs =
    let
        withImplicits =
            implicitTest (widthHelper Shrink)
                :: implicitTest (heightHelper Shrink)
                :: attrs
    in
    skipOverridden withImplicits


attrId attr =
    case attr of
        Testable.LabeledTest details ->
            details.id

        Testable.AttrTest details ->
            details.id

        _ ->
            Testable.NoId


skipOverridden ls =
    List.foldr
        (\attr ( found, caught ) ->
            let
                ( skip, has ) =
                    case attrId attr of
                        Testable.NoId ->
                            ( False, found )

                        Testable.IsWidth ->
                            ( found.hasWidth
                            , { hasWidth = True
                              , hasHeight = found.hasHeight
                              }
                            )

                        Testable.IsHeight ->
                            ( found.hasHeight
                            , { hasWidth = found.hasWidth
                              , hasHeight = True
                              }
                            )
            in
            ( has
            , if skip then
                caught

              else
                attr :: caught
            )
        )
        ( { hasWidth = False
          , hasHeight = False
          }
        , []
        )
        ls
        |> Tuple.second
        |> List.reverse


{-| This is taking a normal test and rmoving its ability to attach a real `Element` attribute.
-}
implicitTest attr =
    case attr of
        Testable.LabeledTest details ->
            Testable.AttrTest
                { test = details.test
                , label = "Implicit -> " ++ details.label
                , id = details.id
                }

        otherwise ->
            otherwise
