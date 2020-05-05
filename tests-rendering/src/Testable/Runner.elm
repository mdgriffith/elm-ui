port module Testable.Runner exposing (Msg, TestableProgram, program, show)

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


palette =
    { white = Element.rgb 1 1 1
    , red = Element.rgb 1 0 0
    , green = Element.rgb 0 1 0
    , black = Element.rgb 0 0 0
    , lightGrey = Element.rgb 0.7 0.7 0.7
    }


program : List ( String, Testable.Element Msg ) -> TestableProgram
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
                  , highlightDomId = Nothing
                  }
                , Task.perform (always Analyze)
                    (Process.sleep 32
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
    , highlightDomId : Maybe String
    }


type alias WithResults thing =
    { element : thing
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
    | HighlightDomID (Maybe String)
    | RefreshBoundingBox
        (List
            { id : String
            , bbox : Testable.BoundingBox
            , style : List ( String, String )
            , isVisible : Bool
            , textMetrics : List TextMetrics
            }
        )


runTest : Dict String Testable.Found -> String -> Testable.Element msg -> WithResults (Testable.Element msg)
runTest boxes label element =
    let
        results =
            Testable.runTests boxes element
    in
    { element = element
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
                              }
                            )

                        foundData =
                            boxes
                                |> List.map toTuple
                                |> Dict.fromList

                        currentResults =
                            runTest foundData label current
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
                                (Process.sleep 32
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
                case model.finished of
                    [] ->
                        Element.layout [] <|
                            Element.column
                                [ Element.spacing 20
                                , Element.padding 20
                                , Element.width (Element.px 800)
                                ]
                                [ Element.none ]

                    finished :: remaining ->
                        Element.layout
                            [ Font.size 16
                            , Element.inFront (Element.html (viewElementHighlight model))
                            ]
                        <|
                            Element.row [ Element.width Element.fill ]
                                [ Element.el
                                    [ Element.width Element.fill
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
                                        (Testable.toElement finished.element)
                                    )
                                , Element.column
                                    [ Element.spacing 20
                                    , Element.padding 20
                                    , Element.width Element.fill
                                    ]
                                    (List.map viewResult (finished :: remaining))
                                ]

            else
                Html.text ""

        Just ( label, current ) ->
            Testable.toHtml current


viewElementHighlight model =
    case model.highlightDomId of
        Nothing ->
            Html.text ""

        Just highlightDomId ->
            let
                elementHighlight =
                    highlightDomId ++ " { outline: solid;  }"

                testId =
                    highlightDomId
                        |> String.dropLeft 1
                        |> String.append "#tests-"

                testHighlight =
                    testId ++ " { outline: dashed;  }"

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


viewResult : WithResults (Testable.Element Msg) -> Element.Element Msg
viewResult testable =
    let
        isExpectationPassing result =
            case result of
                Testable.Todo label ->
                    True

                Testable.Expect details ->
                    details.result

        isPassing layoutTest =
            List.any isExpectationPassing layoutTest.expectations

        ( passing, failing ) =
            List.partition isPassing testable.results
    in
    Element.column
        [ Element.alignLeft
        , Element.spacing 16
        ]
        [ Element.el [ Font.size 24 ] (Element.text testable.label)
        , Element.column
            [ Element.alignLeft, Element.spacing 16 ]
            (testable.results
                |> groupBy .elementDomId
                |> List.map viewLayoutTestGroup
            )
        ]


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
        [ Element.el [ Font.color palette.lightGrey ] (Element.text group.id)
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
        , textMetrics : List TextMetrics
        }
     -> msg
    )
    -> Sub msg


type alias TextMetrics =
    { actualBoundingBoxAscent : Float
    , actualBoundingBoxDescent : Float
    , actualBoundingBoxLeft : Float
    , actualBoundingBoxRight : Float
    , width : Float
    }
