port module View.Results exposing (main)

import Browser
import Color
import Html
import Html.Attributes exposing (class)
import LineChart as LineChart
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Axis.Intersection as Intersection
import LineChart.Colors as Colors
import LineChart.Container as Container
import LineChart.Dots as Dots
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Interpolation as Interpolation
import LineChart.Junk as Junk exposing (..)
import LineChart.Legends as Legends
import LineChart.Line as Line


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
                        ([ viewNodes model.data
                         , viewFps model.data
                         , viewTimeToPaint model.data
                         ]
                            ++ List.map viewTimeDistribution model.data
                        )
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



-- DATA


port worldToElm : (List Data -> msg) -> Sub msg


type alias Model =
    { data : List Data }


type alias Data =
    { name : String
    , results : List Render
    }


type alias Render =
    { count : Float
    , fps : Float
    , timeToFirstPaintMS : Float
    , nodes : Float
    , layoutSeconds : Float
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


viewFps : List Data -> Html.Html msg
viewFps datums =
    LineChart.viewCustom
        { y = Axis.default 800 "FPS" .fps
        , x = Axis.default 1400 "Base Count" .count
        , container = Container.styled "line-chart-1" [ ( "font-family", "monospace" ) ]
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
        { y = Axis.default 800 "First Paint" (max 0 << .timeToFirstPaintMS)
        , x = Axis.default 1400 "Base Count" .count
        , container = Container.styled "line-chart-1" [ ( "font-family", "monospace" ) ]
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
        { y = Axis.default 800 "Nodes" .nodes
        , x = Axis.default 1400 "Base Count" .count
        , container = Container.styled "line-chart-1" [ ( "font-family", "monospace" ) ]
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


viewTimeDistribution : Data -> Html.Html msg
viewTimeDistribution data =
    let
        sorted =
            List.sortBy .count data.results
    in
    LineChart.viewCustom
        { y = Axis.default 800 (data.name ++ "(s)") .seconds
        , x = Axis.default 1400 "Base Count" .count
        , container = Container.styled "line-chart-1" [ ( "font-family", "monospace" ) ]
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
                    { seconds = x.layoutSeconds
                    , count = x.count
                    }
                )
                sorted
            )
        , LineChart.line (getColor 1)
            (getShape 1)
            "RecalcStyle"
            (List.map
                (\x ->
                    { seconds = x.recalcStyleSeconds
                    , count = x.count
                    }
                )
                sorted
            )
        , LineChart.line (getColor 2)
            (getShape 2)
            "Script"
            (List.map
                (\x ->
                    { seconds = x.scriptDurationSeconds
                    , count = x.count
                    }
                )
                sorted
            )
        ]
