port module Testable.Runner exposing
    ( Msg
    , Testable
    , TestableProgram
    , program
    , rename
    , show
    , testable
    )

{-| -}

import Browser
import Dict exposing (Dict)
import Element
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Html exposing (Html)
import Html.Attributes
import Process
import Task
import Testable
import Time


show : Testable.Element msg -> Html msg
show =
    Testable.toHtml


type alias TestableProgram =
    Program () (Model Msg) Msg


{-| This should be a real type, but I'm too busy atm.
-}
type alias Testable =
    ( String, Testable.Element Msg )


rename : String -> Testable -> Testable
rename newName ( _, el ) =
    ( newName, el )


testable : String -> Testable.Element Msg -> Testable
testable =
    Tuple.pair


palette =
    { white = Element.rgb 1 1 1
    , red = Element.rgb 1 0 0
    , green = Element.rgb 0 1 0
    , black = Element.rgb 0 0 0
    , lightGrey = Element.rgb 0.7 0.7 0.7
    }


program : List Testable -> TestableProgram
program tests =
    let
        ( current, upcoming ) =
            case tests of
                [] ->
                    ( Nothing, [] )

                cur :: remaining ->
                    ( Just cur, remaining )
    in
    Browser.element
        { init =
            always
                ( { current = current
                  , upcoming = upcoming
                  , finished = []
                  , selected = 0
                  , highlightDomId = Nothing
                  }
                , Task.perform (always Analyze)
                    (Process.sleep 64
                        |> Task.andThen
                            (always Time.now)
                    )
                )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model Msg -> Sub Msg
subscriptions model =
    Sub.batch
        [ styles RefreshBoundingBox
        ]


type alias Model msg =
    { current : Maybe ( String, Testable.Element msg )
    , upcoming : List ( String, Testable.Element msg )
    , finished : List (WithResults (Testable.Element msg))
    , selected : Int
    , highlightDomId : Maybe String
    }


type alias WithResults thing =
    { index : Int
    , element : thing
    , label : String
    , results :
        List Testable.LayoutTest
    }


encodeForReport :
    List (WithResults (Testable.Element msg))
    ->
        List
            { label : String
            , results :
                List
                    { description : String
                    , passing : Bool
                    , todo : Bool
                    }
            }
encodeForReport withResults =
    let
        prepareExpectation layoutTest exp =
            case exp of
                Testable.Todo description ->
                    { description = description
                    , passing = False
                    , todo = True
                    }

                Testable.Expect details ->
                    { description = details.description
                    , passing = details.result
                    , todo = False
                    }

        prepareNode layoutTest =
            List.map (prepareExpectation layoutTest) layoutTest.expectations

        prepare { label, results } =
            { label = label
            , results = List.concatMap prepareNode results
            }
    in
    List.map prepare withResults


type Msg
    = NoOp
    | Analyze
    | Select Int
    | HighlightDomID (Maybe String)
    | RefreshBoundingBox
        (List
            { id : String
            , bbox : Testable.BoundingBox
            , style : List ( String, String )
            , isVisible : Bool
            , textMetrics : List Testable.TextMetrics
            }
        )


runTest : Int -> Dict String Testable.Found -> String -> Testable.Element msg -> WithResults (Testable.Element msg)
runTest index boxes label element =
    let
        results =
            Testable.runTests boxes element
    in
    { index = index
    , element = element
    , label = label
    , results = results
    }


update : Msg -> Model Msg -> ( Model Msg, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        HighlightDomID newId ->
            ( { model | highlightDomId = newId }
            , Cmd.none
            )

        Select index ->
            ( { model | selected = index }
            , Cmd.none
            )

        RefreshBoundingBox boxes ->
            case model.current of
                Nothing ->
                    ( model
                    , Cmd.none
                    )

                Just ( label, current ) ->
                    let
                        toTuple box =
                            ( box.id
                            , { style = Dict.fromList box.style
                              , bbox = box.bbox
                              , isVisible = box.isVisible
                              , textMetrics = box.textMetrics
                              }
                            )

                        foundData =
                            boxes
                                |> List.map toTuple
                                |> Dict.fromList

                        currentResults =
                            runTest (List.length model.finished) foundData label current
                    in
                    case model.upcoming of
                        [] ->
                            ( { model
                                | current = Nothing
                                , finished = model.finished ++ [ currentResults ]
                              }
                            , report (encodeForReport (currentResults :: model.finished))
                            )

                        newCurrent :: remaining ->
                            ( { model
                                | finished = model.finished ++ [ currentResults ]
                                , current = Just newCurrent
                                , upcoming = remaining
                              }
                            , Task.perform (always Analyze)
                                (Process.sleep 64
                                    |> Task.andThen
                                        (always Time.now)
                                )
                            )

        Analyze ->
            case model.current of
                Nothing ->
                    ( model
                    , Cmd.none
                    )

                Just ( label, current ) ->
                    ( model
                    , analyze (Testable.getIds current)
                    )


view : Model Msg -> Html.Html Msg
view model =
    case model.current of
        Nothing ->
            if List.isEmpty model.upcoming then
                let
                    selected =
                        getByIndex model.selected model.finished
                in
                Element.layout
                    [ Font.size 16
                    , Element.inFront (Element.html (viewElementHighlight model))
                    , Element.height Element.fill
                    ]
                <|
                    Element.row [ Element.width Element.fill, Element.height Element.fill ]
                        [ Element.el
                            [ Element.width
                                (Element.fill
                                    |> Element.maximum 900
                                )
                            , Element.alignTop
                            , Element.height Element.fill
                            , Element.scrollbars
                            ]
                            (Element.el
                                [ Element.centerX
                                , Element.padding 100
                                , Border.dashed
                                , Border.width 2
                                , Border.color palette.lightGrey
                                , Font.size 20
                                , Element.inFront
                                    (Element.el
                                        [ Font.size 14
                                        , Font.color palette.lightGrey
                                        ]
                                        (Element.text "test case")
                                    )
                                ]
                                (case selected of
                                    Nothing ->
                                        Element.text "nothing selected"

                                    Just sel ->
                                        Testable.toElement sel.element
                                )
                            )
                        , Element.column
                            [ Element.spacing 20
                            , Element.padding 20
                            , Element.width Element.fill
                            , Element.height Element.fill
                            , Element.scrollbarY
                            ]
                            (model.finished
                                |> List.sortBy hasFailure
                                |> List.map (viewResult model.selected)
                            )
                        ]

            else
                Html.text ""

        Just ( label, current ) ->
            Testable.toHtml current


getByIndex i ls =
    List.foldl
        (\elem ( index, found ) ->
            if i == index then
                ( index + 1, Just elem )

            else
                ( index + 1, found )
        )
        ( 0, Nothing )
        ls
        |> Tuple.second


viewElementHighlight model =
    case model.highlightDomId of
        Nothing ->
            Html.text ""

        Just highlightDomId ->
            let
                elementHighlight =
                    highlightDomId ++ " { outline: solid black;  }"

                testId =
                    highlightDomId
                        |> String.dropLeft 1
                        |> String.append "#tests-"

                testHighlight =
                    testId ++ " { outline: dashed black;  }"

                styleSheet =
                    String.join "\n"
                        [ elementHighlight
                        , testHighlight
                        ]
            in
            Html.node "style"
                []
                [ Html.text styleSheet
                ]


hasFailure : WithResults (Testable.Element Msg) -> Int
hasFailure myTest =
    if
        List.any
            (not << isPassing)
            myTest.results
    then
        0

    else
        1


isExpectationPassing result =
    case result of
        Testable.Todo label ->
            True

        Testable.Expect details ->
            details.result


isPassing layoutTest =
    List.all isExpectationPassing layoutTest.expectations


viewResult : Int -> WithResults (Testable.Element Msg) -> Element.Element Msg
viewResult selectedIndex myTest =
    if myTest.index == selectedIndex then
        Element.column
            [ Element.alignLeft
            , Element.spacing 16
            ]
            [ Element.el [ Font.size 24 ] (Element.text myTest.label)
            , Element.column
                [ Element.alignLeft, Element.spacing 16 ]
                (myTest.results
                    |> groupBy .elementDomId
                    |> List.map (expandDetails >> viewLayoutTestGroup)
                )
            ]

    else
        let
            ( passing, failing ) =
                List.partition isPassing myTest.results
        in
        Element.column
            [ Element.alignLeft
            , Element.spacing 16
            , Element.pointer
            , Events.onClick (Select myTest.index)
            ]
            [ Element.row [ Element.spacing 16 ]
                [ Element.el [ Font.size 16 ] (Element.text myTest.label)
                , Element.text (String.fromInt (List.length passing) ++ " passing")
                , let
                    failingCount =
                        List.length failing
                  in
                  if failingCount == 0 then
                    Element.none

                  else
                    Element.text (String.fromInt (List.length failing) ++ " failing")
                ]
            ]


expandDetails group =
    case group.members of
        [] ->
            { id = group.id
            , elementType = Testable.EmptyType
            , members = group.members
            }

        top :: _ ->
            { id = group.id
            , elementType = top.elementType
            , members = group.members
            }


groupBy fn list =
    groupWhile (\one two -> fn one == fn two) list
        |> List.map
            (\( fst, remaining ) ->
                { id = fn fst
                , members = fst :: remaining
                }
            )


groupWhile : (a -> a -> Bool) -> List a -> List ( a, List a )
groupWhile isSameGroup items =
    List.foldr
        (\x acc ->
            case acc of
                [] ->
                    [ ( x, [] ) ]

                ( y, restOfGroup ) :: groups ->
                    if isSameGroup x y then
                        ( x, y :: restOfGroup ) :: groups

                    else
                        ( x, [] ) :: acc
        )
        []
        items


viewLayoutTestGroup group =
    let
        testId =
            group.id
                |> String.dropLeft 1
                |> String.append "tests-"
    in
    Element.column
        [ Element.spacing 8
        , Element.htmlAttribute (Html.Attributes.id testId)
        , Events.onMouseEnter (HighlightDomID (Just group.id))
        , Events.onMouseLeave (HighlightDomID Nothing)
        , Element.htmlAttribute (Html.Attributes.style "user-select" "none")
        ]
        [ Element.row [ Element.spacing 16 ]
            [ Element.el [] (Element.text (Testable.elementTypeToString group.elementType))
            , Element.el [ Font.color palette.lightGrey ] (Element.text group.id)
            ]
        , Element.column
            [ Element.spacing 8
            , Element.paddingXY 32 0
            ]
            (List.map viewLayoutTest group.members)
        ]


type alias Grouped thing =
    { id : String
    , members : List thing
    }


viewLayoutTest layoutTest =
    Element.column
        [ Element.spacing 8
        ]
        [ Element.row [ Element.spacing 8 ]
            [ Element.el [ Font.bold ] (Element.text layoutTest.label)

            -- , Element.el [ Font.color palette.lightGrey ] (Element.text layoutTest.elementDomId)
            ]
        , Element.column [ Element.spacing 8 ]
            (List.map viewLayoutExpectation layoutTest.expectations)
        ]


viewLayoutExpectation expectation =
    case expectation of
        Testable.Todo label ->
            Element.row [ Element.spacing 4 ]
                [ todo, Element.text label ]

        Testable.Expect details ->
            if details.result then
                Element.row [ Element.spacing 4 ]
                    [ pass, Element.text details.description ]

            else
                Element.row [ Element.spacing 4 ]
                    [ fail, Element.text details.description ]


badge color text =
    Element.el
        [ Background.color color
        , Font.color palette.black
        , Element.paddingXY 4 8
        , Border.rounded 2
        ]
        (Element.text text)


todo =
    badge palette.lightGrey "todo"


pass =
    badge palette.green "pass"


fail =
    badge palette.red "fail"


formatKeyValue : String -> String -> String
formatKeyValue key val =
    key ++ ": " ++ val


port report :
    List
        { label : String
        , results :
            List
                { description : String
                , passing : Bool
                , todo : Bool
                }
        }
    -> Cmd msg


port test : String -> Cmd msg


port analyze : List String -> Cmd msg


port styles :
    (List
        { id : String
        , bbox : Testable.BoundingBox
        , style : List ( String, String )
        , isVisible : Bool
        , textMetrics : List Testable.TextMetrics
        }
     -> msg
    )
    -> Sub msg
