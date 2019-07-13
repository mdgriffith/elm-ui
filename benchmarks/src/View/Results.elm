port module View.Results exposing (main)

import Browser
import Color
import Html
import Html.Attributes as Attr exposing (class)
import LineChart as LineChart
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Axis.Intersection as Intersection
import LineChart.Axis.Line as AxisLine
import LineChart.Axis.Range as Range
import LineChart.Axis.Ticks as Ticks
import LineChart.Axis.Title as Title
import LineChart.Colors as Colors
import LineChart.Container as Container
import LineChart.Dots as Dots
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Interpolation as Interpolation
import LineChart.Junk as Junk exposing (..)
import LineChart.Legends as Legends
import LineChart.Line as Line


row children =
    Html.div
        [ Attr.style "display" "flex"
        , Attr.style "flex-direction" "row"
        ]
        children


column children =
    Html.div
        [ Attr.style "display" "flex"
        , Attr.style "flex-direction" "column"
        ]
        children


main =
    Browser.document
        { init =
            \() ->
                ( { data = [] }
                , Cmd.none
                )
        , view =
            \model ->
                { title = "Results"
                , body =
                    [ Html.div
                        [ class "container" ]
                        [ column
                            [ Html.h2 [] [ Html.text "Benchmarked Pages" ]
                            , row (List.map viewLinks model.data)
                            ]
                        , row
                            [ -- viewNodes model.data
                              viewFps model.data
                            , viewTimeToPaint model.data
                            ]
                        , row
                            [ column
                                (List.map
                                    (\data ->
                                        viewRenderBreakdown
                                            { get = .coldRender
                                            , getCount = .count
                                            , name = data.name
                                            , flavor = "Cold render"
                                            , range = ( 0, 1.2 )
                                            }
                                            (List.sortBy .count data.results)
                                    )
                                    model.data
                                )
                            , column
                                (List.map
                                    (\data ->
                                        viewRenderBreakdown
                                            { get = .warmRender
                                            , getCount = .count
                                            , name = data.name
                                            , flavor = "Warm render"
                                            , range = ( 0, 1.2 )
                                            }
                                            (List.sortBy .count data.results)
                                    )
                                    model.data
                                )
                            , column
                                (List.map
                                    (\data ->
                                        viewRenderBreakdown
                                            { get = .extendedRender
                                            , getCount = .count
                                            , name = data.name
                                            , flavor = "Long Animation"
                                            , range = ( 0, 5 )
                                            }
                                            (List.sortBy .count data.results)
                                    )
                                    model.data
                                )
                            ]
                        ]
                    ]
                }
        , update =
            update
        , subscriptions =
            \model ->
                Sub.batch
                    [ worldToElm Received
                    ]
        }


type Msg
    = Received (List Data)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Received data ->
            ( { data = data }, Cmd.none )


viewLinks data =
    column
        (Html.h1 [] [ Html.text data.name ]
            :: (data.results
                    |> List.sortBy .link
                    |> List.map viewSingleLink
               )
        )


viewSingleLink result =
    Html.a
        [ Attr.href result.link
        , Html.style "padding-right" "30px"
        ]
        [ Html.text result.name ]



-- DATA


port worldToElm : (List Data -> msg) -> Sub msg


type alias Model =
    { data : List Data }


type alias Data =
    { name : String
    , results : List Render
    }


type alias Render =
    { name : String
    , count : Float
    , fps : Float
    , timeToFirstPaintMS : Float
    , nodes : Float
    , link : String
    , coldRender :
        Breakdown
    , warmRender :
        Breakdown
    , extendedRender :
        Breakdown
    }


type alias Breakdown =
    { layoutSeconds : Float
    , recalcStyleSeconds : Float
    , scriptDurationSeconds : Float
    }



-- Different Views


getColor i =
    case i of
        0 ->
            Colors.green

        1 ->
            Colors.blue

        2 ->
            Colors.pink

        _ ->
            Colors.gold


getShape i =
    Dots.triangle


graphWidth =
    800


graphHeight =
    500


container =
    Container.styled "line-chart-1"
        [ ( "font-family", "monospace" )
        , ( "flex-shrink", "0" )
        ]


viewFps : List Data -> Html.Html msg
viewFps datums =
    LineChart.viewCustom
        { y = Axis.default graphHeight "FPS" .fps
        , x = Axis.default graphWidth "Base Count" .count
        , container = container
        , interpolation =
            -- Try out these different configs!
            -- Interpolation.linear
            Interpolation.monotone

        -- Interpolation.stepped
        , intersection = Intersection.default
        , legends = Legends.default
        , events = Events.default
        , junk = Junk.default
        , grid = Grid.default
        , area = Area.default
        , line = Line.default
        , dots = Dots.default
        }
        (List.indexedMap viewResult datums)


viewResult i data =
    LineChart.line (getColor i) (getShape i) data.name (List.sortBy .count data.results)


viewTimeToPaint : List Data -> Html.Html msg
viewTimeToPaint datums =
    LineChart.viewCustom
        { y = Axis.default graphHeight "First Paint" (max 0 << .timeToFirstPaintMS)
        , x = Axis.default graphWidth "Base Count" .count
        , container = container
        , interpolation =
            -- Try out these different configs!
            -- Interpolation.linear
            Interpolation.monotone

        -- Interpolation.stepped
        , intersection = Intersection.default
        , legends = Legends.default
        , events = Events.default
        , junk = Junk.default
        , grid = Grid.default
        , area = Area.default
        , line = Line.default
        , dots = Dots.default
        }
        (List.indexedMap viewResult datums)


viewNodes : List Data -> Html.Html msg
viewNodes datums =
    LineChart.viewCustom
        { y = Axis.default graphHeight "Nodes" .nodes
        , x = Axis.default graphWidth "Base Count" .count
        , container = container
        , interpolation =
            -- Try out these different configs!
            -- Interpolation.linear
            Interpolation.monotone

        -- Interpolation.stepped
        , intersection = Intersection.default
        , legends = Legends.default
        , events = Events.default
        , junk = Junk.default
        , grid = Grid.default
        , area = Area.default
        , line = Line.default
        , dots = Dots.default
        }
        (List.indexedMap viewResult datums)


viewRenderBreakdown :
    { get : Render -> Breakdown
    , getCount : Render -> Float
    , name : String
    , flavor : String
    , range : ( Float, Float )
    }
    -> List Render
    -> Html.Html msg
viewRenderBreakdown { get, getCount, name, flavor, range } results =
    Html.div []
        [ Html.h2 [] [ Html.text (name ++ ", " ++ flavor) ]
        , LineChart.viewCustom
            { y =
                Axis.custom
                    { title = Title.default (name ++ "(s)")
                    , variable = Just << .seconds
                    , pixels = graphHeight
                    , range = Range.window (Tuple.first range) (Tuple.second range)
                    , axisLine = AxisLine.full Colors.black
                    , ticks = Ticks.default
                    }
            , x = Axis.default graphWidth "Base Count" .count
            , container = container
            , interpolation =
                -- Try out these different configs!
                -- Interpolation.linear
                Interpolation.monotone

            -- Interpolation.stepped
            , intersection = Intersection.default
            , legends = Legends.default
            , events = Events.default
            , junk = Junk.default
            , grid = Grid.default
            , area = Area.stacked 0.5
            , line = Line.default
            , dots = Dots.default
            }
            [ LineChart.line (getColor 0)
                (getShape 0)
                "Layout"
                (List.map
                    (\x ->
                        { seconds = .layoutSeconds (get x)
                        , count = getCount x
                        }
                    )
                    results
                )
            , LineChart.line (getColor 1)
                (getShape 1)
                "RecalcStyle"
                (List.map
                    (\x ->
                        { seconds =
                            .recalcStyleSeconds (get x)
                        , count = getCount x
                        }
                    )
                    results
                )
            , LineChart.line (getColor 2)
                (getShape 2)
                "Script"
                (List.map
                    (\x ->
                        { seconds =
                            .scriptDurationSeconds (get x)
                        , count = getCount x
                        }
                    )
                    results
                )
            ]
        ]
