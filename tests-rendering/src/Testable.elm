module Testable exposing
    ( Attr(..)
    , BoundingBox
    , Element(..)
    , Found
    , LayoutContext(..)
    , LayoutExpectation(..)
    , LayoutTest
    , Location(..)
    , Style
    , Surroundings
    , compareFormattedColor
    , equal
    , formatColor
    , formatColorWithAlpha
    , getIds
    , getSpacing
    , runTests
    , toElement
    , toHtml
    , todo
    , true
    )

{-| -}

import Dict exposing (Dict)
import Element exposing (Color)
import Html exposing (Html)
import Html.Attributes
import Internal.Model as Internal
import Test exposing (Test)


type Element msg
    = El (List (Attr msg)) (Element msg)
    | Row (List (Attr msg)) (List (Element msg))
    | Column (List (Attr msg)) (List (Element msg))
    | TextColumn (List (Attr msg)) (List (Element msg))
    | Paragraph (List (Attr msg)) (List (Element msg))
    | Text String
    | Empty


type Attr msg
    = Attr (Element.Attribute msg)
    | AttrTest
        { test : Surroundings -> List LayoutExpectation
        , label : String
        }
    | Batch (List (Attr msg))
    | Spacing Int
    | Nearby
        { location : Location
        , element : Element msg
        , test : Surroundings -> List LayoutExpectation
        , label : String
        }
    | LabeledTest
        { test : Surroundings -> List LayoutExpectation
        , label : String
        , attr : Element.Attribute msg
        }


type Location
    = Above
    | Below
    | OnRight
    | OnLeft
    | InFront
    | Behind


type LayoutContext
    = IsNearby Location
    | InRow
    | InEl
    | InColumn


type alias Surroundings =
    { siblings : List Found
    , parent : Found
    , children : List Found
    , self : Found

    -- These values are needed to perform some types of tests.
    , location : LayoutContext
    , parentSpacing : Int
    }


type alias Found =
    { bbox : BoundingBox
    , style : Style
    , isVisible : Bool
    }


{-| -}
type alias Style =
    Dict String String


type alias BoundingBox =
    { width : Float
    , height : Float
    , left : Float
    , top : Float
    , right : Float
    , bottom : Float
    , padding :
        { left : Float
        , right : Float
        , top : Float
        , bottom : Float
        }
    }


type LayoutExpectation
    = Expect
        { description : String
        , result : Bool
        }
    | Todo String


type alias LayoutTest =
    { elementDomId : String
    , label : String
    , expectations : List LayoutExpectation
    }



{- Expectations -}


equal : a -> a -> LayoutExpectation
equal one two =
    Expect
        { description = "Are equal"
        , result = one == two
        }


true : String -> Bool -> LayoutExpectation
true label passing =
    Expect
        { description = label
        , result = passing
        }


todo : String -> LayoutExpectation
todo =
    Todo



{- Retrieve Ids -}


getIds : Element msg -> List String
getIds el =
    "se-0" :: getElementId [ 0, 0 ] el


getElementId : List Int -> Element msg -> List String
getElementId level el =
    let
        id =
            levelToString level

        attrID attrIndex attr =
            case attr of
                Nearby nearby ->
                    getElementId (attrIndex :: -1 :: level) nearby.element

                _ ->
                    []

        attributeIDs attrs =
            attrs
                |> List.indexedMap attrID
                |> List.concat

        childrenIDs children =
            List.concat <| List.indexedMap (\i -> getElementId (i :: level)) children
    in
    case el of
        El attrs child ->
            id :: getElementId (0 :: level) child ++ attributeIDs attrs

        Row attrs children ->
            id :: childrenIDs children ++ attributeIDs attrs

        Column attrs children ->
            id :: childrenIDs children ++ attributeIDs attrs

        TextColumn attrs children ->
            id :: childrenIDs children ++ attributeIDs attrs

        Paragraph attrs children ->
            id :: childrenIDs children ++ attributeIDs attrs

        Empty ->
            []

        Text _ ->
            []



{- Render as Html -}


toElement : Element msg -> Element.Element msg
toElement el =
    renderElement [ 0, 0 ] el


toHtml : Element msg -> Html msg
toHtml el =
    Element.layout [ idAttr "0" ] <|
        renderElement [ 0, 0 ] el


idAttr : String -> Element.Attribute msg
idAttr id =
    Element.htmlAttribute (Html.Attributes.id ("se-" ++ id))


renderElement : List Int -> Element msg -> Element.Element msg
renderElement level el =
    let
        id =
            level
                |> List.map String.fromInt
                |> String.join "-"
                |> idAttr

        makeAttributes attrs =
            attrs
                |> List.indexedMap (renderAttribute level)
                |> List.concat
    in
    case el of
        El attrs child ->
            Element.el
                (id :: makeAttributes attrs)
                (renderElement (0 :: level) child)

        Row attrs children ->
            Element.row
                (id :: makeAttributes attrs)
                (List.indexedMap (\i -> renderElement (i :: level)) children)

        Column attrs children ->
            Element.column
                (id :: makeAttributes attrs)
                (List.indexedMap (\i -> renderElement (i :: level)) children)

        TextColumn attrs children ->
            Element.textColumn
                (id :: makeAttributes attrs)
                (List.indexedMap (\i -> renderElement (i :: level)) children)

        Paragraph attrs children ->
            Element.paragraph
                (id :: makeAttributes attrs)
                (List.indexedMap (\i -> renderElement (i :: level)) children)

        Empty ->
            Element.none

        Text str ->
            Element.text str


renderAttribute : List Int -> Int -> Attr msg -> List (Element.Attribute msg)
renderAttribute level attrIndex attr =
    case attr of
        Attr attribute ->
            [ attribute ]

        AttrTest _ ->
            []

        Spacing _ ->
            []

        Nearby { location, element } ->
            case location of
                Above ->
                    [ Element.above (renderElement (attrIndex :: -1 :: level) element) ]

                Below ->
                    [ Element.below (renderElement (attrIndex :: -1 :: level) element) ]

                OnRight ->
                    [ Element.onRight (renderElement (attrIndex :: -1 :: level) element) ]

                OnLeft ->
                    [ Element.onLeft (renderElement (attrIndex :: -1 :: level) element) ]

                InFront ->
                    [ Element.inFront (renderElement (attrIndex :: -1 :: level) element) ]

                Behind ->
                    [ Element.behindContent (renderElement (attrIndex :: -1 :: level) element) ]

        Batch batch ->
            List.indexedMap (renderAttribute (attrIndex :: level)) batch
                |> List.concat

        LabeledTest tested ->
            [ tested.attr ]



{- Convert to Test -}


runTests : Dict String Found -> Element msg -> List LayoutTest
runTests harvested el =
    let
        maybeFound =
            Dict.get "se-0" harvested
    in
    case maybeFound of
        Nothing ->
            [ { elementDomId = "se-0"
              , label = "Finding root element"
              , expectations =
                    [ Expect
                        { description = "Locating root element for rendering tests"
                        , result = False
                        }
                    ]
              }
            ]

        Just root ->
            createTest
                { siblings = []
                , parent = root
                , cache = harvested
                , parentSpacing = 0
                , level = [ 0, 0 ]
                , element = el
                , location = InEl
                }


levelToString : List Int -> String
levelToString level =
    level
        |> List.map String.fromInt
        |> String.join "-"
        |> (\x -> "se-" ++ x)


createTest :
    { siblings : List Found
    , parent : Found
    , cache : Dict String Found
    , level : List Int
    , element : Element msg
    , location : LayoutContext
    , parentSpacing : Int
    }
    -> List LayoutTest
createTest { siblings, parent, cache, level, element, location, parentSpacing } =
    let
        spacing =
            getSpacing element
                |> Maybe.withDefault 0

        id =
            levelToString level

        testChildren : Found -> List (Element msg) -> List LayoutTest
        testChildren found children =
            let
                childrenFound =
                    -- Should check that this lookup doesn't fail.
                    -- Thoug if it does, it'll fail when the element itself is tested
                    List.filterMap
                        (\x ->
                            Dict.get (levelToString (x :: level)) cache
                        )
                        (List.range 0 (List.length children))
            in
            List.foldl (applyChildTest found)
                { index = 0
                , upcoming = childrenFound
                , previous = []
                , tests = []
                }
                children
                |> .tests

        applyChildTest :
            Found
            -> Element msg
            ->
                { a
                    | index : Int
                    , previous : List Found
                    , tests : List LayoutTest
                    , upcoming : List Found
                }
            ->
                { index : Int
                , previous : List Found
                , tests : List LayoutTest
                , upcoming : List Found
                }
        applyChildTest found child childTest =
            -- { index, upcoming, previous, tests }
            let
                surroundingChildren =
                    case childTest.upcoming of
                        [] ->
                            childTest.previous

                        x :: remaining ->
                            remaining ++ childTest.previous

                childrenTests =
                    createTest
                        { siblings = surroundingChildren
                        , parent = found
                        , cache = cache
                        , level = childTest.index :: level
                        , element = child
                        , parentSpacing = spacing
                        , location =
                            case element of
                                El _ _ ->
                                    InEl

                                Row _ _ ->
                                    InRow

                                Column _ _ ->
                                    InColumn

                                TextColumn _ _ ->
                                    InColumn

                                Paragraph _ _ ->
                                    InRow

                                Text _ ->
                                    InEl

                                Empty ->
                                    InEl
                        }
            in
            { index = childTest.index + 1
            , tests = childTest.tests ++ childrenTests
            , previous =
                case childTest.upcoming of
                    [] ->
                        childTest.previous

                    x :: _ ->
                        x :: childTest.previous
            , upcoming =
                case childTest.upcoming of
                    [] ->
                        []

                    _ :: rest ->
                        rest
            }

        tests : Found -> List (Attr msg) -> List (Element msg) -> List LayoutTest
        tests self attributes children =
            let
                findBBox elem ( i, gathered ) =
                    case elem of
                        Empty ->
                            ( i + 1
                            , gathered
                            )

                        Text _ ->
                            ( i + 1
                            , gathered
                            )

                        _ ->
                            case Dict.get (levelToString (i :: level)) cache of
                                Nothing ->
                                    let
                                        _ =
                                            Debug.log "el failed to find" elem

                                        _ =
                                            Debug.log "Failed to find child" (levelToString (i :: level))
                                    in
                                    ( i + 1
                                    , gathered
                                    )

                                Just found ->
                                    ( i + 1
                                    , found :: gathered
                                    )

                childrenFoundData =
                    List.foldl findBBox ( 0, [] ) children
                        |> Tuple.second

                attributeTests =
                    attributes
                        |> List.indexedMap
                            -- Found -> Dict String Found -> List Int -> Int -> Surroundings -> Attr msg -> List Test
                            (\i attr ->
                                createAttributeTest self
                                    cache
                                    level
                                    i
                                    { siblings = siblings
                                    , parent = parent
                                    , self = self
                                    , children = childrenFoundData
                                    , location = location
                                    , parentSpacing = parentSpacing
                                    }
                                    attr
                            )
                        |> List.concat
            in
            attributeTests
                ++ testChildren self children
    in
    case Dict.get id cache of
        Nothing ->
            case element of
                Empty ->
                    []

                Text _ ->
                    []

                _ ->
                    [ { elementDomId = id
                      , label = "Finding element in DOM"
                      , expectations =
                            [ Expect
                                { description = "Locating element for rendering test"
                                , result = False
                                }
                            ]
                      }
                    ]

        Just self ->
            case element of
                El attrs child ->
                    tests self attrs [ child ]

                Row attrs children ->
                    tests self attrs children

                Column attrs children ->
                    tests self attrs children

                TextColumn attrs children ->
                    tests self attrs children

                Paragraph attrs children ->
                    tests self attrs children

                Empty ->
                    []

                Text str ->
                    []


createAttributeTest :
    Found
    -> Dict String Found
    -> List Int
    -> Int
    -> Surroundings
    -> Attr msg
    -> List LayoutTest
createAttributeTest parent cache level attrIndex surroundings attr =
    let
        domId =
            "#" ++ levelToString level
    in
    case attr of
        Attr _ ->
            []

        Spacing _ ->
            []

        AttrTest details ->
            [ { elementDomId = domId
              , label = details.label
              , expectations = details.test surroundings
              }
            ]

        Nearby nearby ->
            createTest
                { siblings = []
                , parent = parent
                , cache = cache
                , parentSpacing = 0
                , level = attrIndex :: -1 :: level
                , location = IsNearby nearby.location
                , element =
                    addAttribute
                        (AttrTest
                            { label = nearby.label
                            , test =
                                nearby.test
                            }
                        )
                        nearby.element
                }

        Batch batch ->
            batch
                |> List.indexedMap (\i attribute -> createAttributeTest parent cache (attrIndex :: level) i surroundings attribute)
                |> List.concat

        LabeledTest { label, test } ->
            [ { elementDomId = domId
              , label = label
              , expectations = test surroundings
              }
            ]


addAttribute : Attr msg -> Element msg -> Element msg
addAttribute attr el =
    case el of
        El attrs child ->
            El (attr :: attrs) child

        Row attrs children ->
            Row (attr :: attrs) children

        Column attrs children ->
            Column (attr :: attrs) children

        TextColumn attrs children ->
            TextColumn (attr :: attrs) children

        Paragraph attrs children ->
            Paragraph (attr :: attrs) children

        Empty ->
            Empty

        Text str ->
            Text str



-- runTests :
--     Random.Seed
--     -> Test
--     ->
--         List
--             ( String
--             , Maybe
--                 { given : Maybe String
--                 , description : String
--                 , reason : Test.Runner.Failure.Reason
--                 }
--             )
-- runTests seed tests =
--     let
--         run runner =
--             let
--                 ran =
--                     List.map Test.Runner.getFailureReason (runner.run ())
--             in
--             List.map2 Tuple.pair runner.labels ran
--         results =
--             case Test.Runner.fromTest 100 seed tests of
--                 Test.Runner.Plain rnrs ->
--                     List.map run rnrs
--                 Test.Runner.Only rnrs ->
--                     List.map run rnrs
--                 Test.Runner.Skipping rnrs ->
--                     List.map run rnrs
--                 Test.Runner.Invalid invalid ->
--                     let
--                         _ =
--                             Debug.log "Invalid tests" invalid
--                     in
--                     []
--     in
--     List.concat results


compareFormattedColor : Color -> String -> Bool
compareFormattedColor color expected =
    formatColor color == expected || formatColorWithAlpha color == expected


formatColorWithAlpha : Color -> String
formatColorWithAlpha (Internal.Rgba red green blue alpha) =
    if alpha == 1 then
        ("rgba(" ++ String.fromInt (round (red * 255)))
            ++ (", " ++ String.fromInt (round (green * 255)))
            ++ (", " ++ String.fromInt (round (blue * 255)))
            ++ ", 1"
            ++ ")"

    else
        ("rgba(" ++ String.fromInt (round (red * 255)))
            ++ (", " ++ String.fromInt (round (green * 255)))
            ++ (", " ++ String.fromInt (round (blue * 255)))
            ++ (", " ++ String.fromFloat alpha ++ ")")


formatColor : Color -> String
formatColor (Internal.Rgba red green blue alpha) =
    if alpha == 1 then
        ("rgb(" ++ String.fromInt (round (red * 255)))
            ++ (", " ++ String.fromInt (round (green * 255)))
            ++ (", " ++ String.fromInt (round (blue * 255)))
            ++ ")"

    else
        ("rgb(" ++ String.fromInt (round (red * 255)))
            ++ (", " ++ String.fromInt (round (green * 255)))
            ++ (", " ++ String.fromInt (round (blue * 255)))
            ++ ")"


getSpacing : Element msg -> Maybe Int
getSpacing el =
    let
        getSpacingAttr attr found =
            if found /= Nothing then
                found

            else
                case attr of
                    Spacing i ->
                        Just i

                    Batch attrs ->
                        List.foldr getSpacingAttr Nothing attrs

                    _ ->
                        Nothing

        filterAttrs attrs =
            List.foldr getSpacingAttr Nothing attrs
    in
    case el of
        El attrs _ ->
            filterAttrs attrs

        Row attrs _ ->
            filterAttrs attrs

        Column attrs _ ->
            filterAttrs attrs

        TextColumn attrs _ ->
            filterAttrs attrs

        Paragraph attrs _ ->
            filterAttrs attrs

        Empty ->
            Nothing

        Text _ ->
            Nothing
