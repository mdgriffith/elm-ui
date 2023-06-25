module Ui.Table exposing
    ( Column, column, Cell, cell
    , header, withWidth
    , view, Config, columns
    , withRowKey, onRowClick, withScrollable
    , viewWithState
    , columnWithState, withVisibility, withOrder, withSummary
    , withSort
    )

{-|

    myTable =
        Ui.Table.columns
            [ Ui.Table.column
                { header = Ui.Table.header "Name"
                , view =
                    \row ->
                        Ui.Table.cell []
                            (Ui.text row.name)
                }
            , Ui.Table.column
                { header = Ui.Table.header "Occupation"
                , view =
                    \row ->
                        Ui.Table.cell []
                            (Ui.text row.occupation)
                }
            ]

    viewTable model =
        Ui.Table.view [] myTable model.data


## Column Configuration

@docs Column, column, Cell, cell

@docs header, withWidth


## Table Configuration

@docs view, Config, columns

@docs withRowKey, onRowClick, withScrollable


# Advanced Tables with State

@docs viewWithState

@docs columnWithState, withVisibility, withOrder, withSummary

@docs withSort

-}

import Html
import Html.Attributes as Attr
import Internal.Flag as Flag exposing (Flag)
import Internal.Model2 as Two
import Internal.Style2 as Style
import Ui exposing (Attribute, Element)
import Ui.Events
import Ui.Font
import Ui.Lazy


{-| -}
type alias Config state data msg =
    { toKey : data -> String
    , columns : List (Column state data msg)
    , sort : Maybe (state -> List data -> List data)
    , onRowClick : Maybe (data -> msg)
    , stickHeader : Bool
    , stickRow : data -> Bool
    , stickFirstColumn : Bool
    , scrollable : Bool
    }


{-| -}
columns :
    List (Column state data msg)
    -> Config state data msg
columns cols =
    { toKey = \_ -> "keyed"
    , columns = cols
    , onRowClick = Nothing
    , stickHeader = False
    , stickRow = \_ -> False
    , stickFirstColumn = False
    , scrollable = False
    , sort = Nothing
    }


{-| Adding a `key` to a row will automatically use `Keyed` under the hood.
-}
withRowKey : (data -> String) -> Config state data msg -> Config state data msg
withRowKey toKey cfg =
    { cfg | toKey = toKey }


{-| -}
onRowClick : (data -> msg) -> Config state data msg -> Config state data msg
onRowClick onClick cfg =
    { cfg | onRowClick = Just onClick }


{-| -}
withSort : (state -> List data -> List data) -> Config state data msg -> Config state data msg
withSort sort cfg =
    { cfg | sort = Just sort }


{-| -}
withScrollable :
    { stickFirstColumn : Bool
    }
    -> Config state data msg
    -> Config state data msg
withScrollable input cfg =
    { cfg
        | scrollable = True
        , stickHeader = True
        , stickFirstColumn = input.stickFirstColumn
    }


{-| -}
type Column state data msg
    = Column
        { header : state -> Cell msg
        , width :
            Maybe
                { fill : Bool
                , min : Maybe Int
                , max : Maybe Int
                }
        , view : Int -> state -> data -> Cell msg
        , visible : state -> Bool
        , order : state -> Int
        , summary : Maybe (state -> List data -> Cell msg)
        }


{-| -}
type alias Cell msg =
    { attrs : List (Attribute msg)
    , child : Element msg
    }


{-| -}
cell : List (Attribute msg) -> Element msg -> Cell msg
cell =
    Cell


default =
    { padding = Ui.paddingXY 16 8
    , paddingFirstRow =
        Ui.paddingEach
            { top = 16
            , left = 16
            , right = 16
            , bottom = 8
            }
    , fontAlignment = Ui.Font.alignLeft
    , borderHeader =
        Ui.borderWith
            { color = Ui.rgb 200 200 200
            , width =
                { top = 0
                , left = 0
                , right = 0
                , bottom = 1
                }
            }
    }


{-| A simple header with some default styling.

Feel free to make your own!

This is the same as

    Ui.Table.cell
        [-- some minimal defaults
        ]
        (Ui.text "Header text")

-}
header : String -> Cell msg
header str =
    cell
        [ default.padding
        , default.borderHeader
        , Ui.height Ui.fill
        ]
        (Ui.text str)


{-| -}
column :
    { header : Cell msg
    , view : data -> Cell msg
    }
    -> Column state data msg
column input =
    Column
        { header = \state -> input.header
        , view = \index state data -> input.view data
        , width = Nothing
        , visible = \_ -> True
        , order = \_ -> 0
        , summary = Nothing
        }


{-| -}
columnWithState :
    { header : state -> Cell msg
    , view : Int -> state -> data -> Cell msg
    }
    -> Column state data msg
columnWithState input =
    Column
        { header = input.header
        , view = input.view
        , width = Nothing
        , visible = \_ -> True
        , order = \_ -> 0
        , summary = Nothing
        }


{-| -}
withWidth :
    { fill : Bool
    , min : Maybe Int
    , max : Maybe Int
    }
    -> Column state data msg
    -> Column state data msg
withWidth width (Column col) =
    Column { col | width = Just width }


{-| -}
withSummary : (state -> List data -> Cell msg) -> Column state data msg -> Column state data msg
withSummary toSummaryCell (Column col) =
    Column
        { col
            | summary = Just toSummaryCell
        }


{-| -}
withVisibility : (state -> Bool) -> Column state data msg -> Column state data msg
withVisibility toVisibility (Column col) =
    Column { col | visible = toVisibility }


{-| -}
withOrder : (state -> Int) -> Column state data msg -> Column state data msg
withOrder toOrder (Column col) =
    Column { col | order = toOrder }


{-| -}
view :
    List (Attribute msg)
    -> Config () data msg
    -> List data
    -> Element msg
view attrs config data =
    viewWithState attrs config () data


{-| -}
viewWithState :
    List (Attribute msg)
    -> Config state data msg
    -> state
    -> List data
    -> Element msg
viewWithState attrs config state data =
    let
        headerRow =
            Ui.Lazy.lazy2
                renderHeader
                state
                config

        rows =
            Ui.Lazy.lazy3 renderRows config state data
    in
    Two.element Two.NodeAsTable
        Two.AsColumn
        (Two.style "display" "grid"
            :: Two.attrIf config.scrollable
                (Two.classWith Flag.overflow Style.classes.scrollbars)
            :: Two.style "grid-template-columns"
                (gridTemplate state config.columns "")
            :: attrs
        )
        [ headerRow
        , rows
        , if List.any hasSummary config.columns then
            Ui.Lazy.lazy3 renderSummary config state data

          else
            Ui.none
        ]


hasSummary (Column col) =
    case col.summary of
        Nothing ->
            False

        Just _ ->
            True


gridTemplate : state -> List (Column state data msg) -> String -> String
gridTemplate state cols str =
    case cols of
        [] ->
            str

        (Column col) :: remain ->
            if not (col.visible state) then
                gridTemplate state remain str

            else
                case col.width of
                    Nothing ->
                        gridTemplate state remain (str ++ " minmax(min-content, max-content)")

                    Just w ->
                        case w.min of
                            Nothing ->
                                case w.max of
                                    Nothing ->
                                        if w.fill then
                                            gridTemplate state remain (str ++ " 1fr")

                                        else
                                            gridTemplate state remain (str ++ " min-content")

                                    Just max ->
                                        if w.fill then
                                            gridTemplate state
                                                remain
                                                (str
                                                    ++ " minmax(1fr, "
                                                    ++ String.fromInt max
                                                    ++ "px)"
                                                )

                                        else
                                            gridTemplate state
                                                remain
                                                (str
                                                    ++ " minmax(min-content, "
                                                    ++ String.fromInt max
                                                    ++ "px)"
                                                )

                            Just min ->
                                case w.max of
                                    Nothing ->
                                        if w.fill then
                                            gridTemplate state
                                                remain
                                                (str
                                                    ++ " minmax("
                                                    ++ String.fromInt min
                                                    ++ "px , 1fr)"
                                                )

                                        else
                                            gridTemplate state
                                                remain
                                                (str
                                                    ++ " minmax("
                                                    ++ String.fromInt min
                                                    ++ "px , max-content)"
                                                )

                                    Just max ->
                                        gridTemplate state
                                            remain
                                            (str
                                                ++ " minmax("
                                                ++ String.fromInt min
                                                ++ "px , "
                                                ++ String.fromInt max
                                                ++ ")"
                                            )


renderHeader : state -> Config state data msg -> Element msg
renderHeader state config =
    Two.element Two.NodeAsTableHead
        Two.AsRow
        [ Two.style "display" "contents" ]
        [ Two.element Two.NodeAsTableRow
            Two.AsRow
            [ Two.style "display" "contents"
            ]
            (case List.sortBy (\(Column col) -> col.order state) config.columns of
                [] ->
                    []

                first :: remaining ->
                    renderColumnHeader config state True first
                        :: List.map
                            (renderColumnHeader config state False)
                            remaining
            )
        ]


renderColumnHeader : Config state data msg -> state -> Bool -> Column state data msg -> Element msg
renderColumnHeader cfg state isFirstColumn (Column col) =
    let
        { attrs, child } =
            col.header state

        stickyColumn =
            cfg.stickFirstColumn && isFirstColumn
    in
    Two.element Two.NodeAsTableHeaderCell
        Two.AsRow
        (default.padding
            :: default.fontAlignment
            :: Two.attrIf
                cfg.stickHeader
                (Two.class
                    Style.classes.stickyTop
                )
            :: Two.attrIf
                (not (col.visible state))
                (Two.style "display" "none")
            :: Two.attrIf
                stickyColumn
                (Two.class
                    Style.classes.stickyLeft
                )
            :: Two.attrIf
                (cfg.stickHeader || stickyColumn)
                (Ui.background (Ui.rgb 255 255 255))
            :: Two.attrIf
                (cfg.stickHeader || stickyColumn)
                (if cfg.stickHeader && stickyColumn then
                    Two.style "z-index" "2"

                 else
                    Two.style "z-index" "1"
                )
            :: attrs
        )
        [ child ]


renderRows : Config state data msg -> state -> List data -> Element msg
renderRows config state data =
    let
        sorted =
            case config.sort of
                Nothing ->
                    data

                Just sortFn ->
                    sortFn state data
    in
    Two.elementKeyed "tbody"
        Two.AsRow
        [ Two.style "display" "contents" ]
        (List.indexedMap
            (renderRowWithKey config state)
            sorted
        )


renderRowWithKey : Config state data msg -> state -> Int -> data -> ( String, Element msg )
renderRowWithKey config state index row =
    ( config.toKey row
    , Ui.Lazy.lazy4 renderRow config state row index
    )


renderRow : Config state data msg -> state -> data -> Int -> Element msg
renderRow config state row rowIndex =
    Two.element Two.NodeAsTableRow
        Two.AsRow
        [ Two.style "display" "contents"
        , case config.onRowClick of
            Nothing ->
                Two.noAttr

            Just onClick ->
                Ui.Events.onClick (onClick row)
        ]
        (case List.sortBy (\(Column col) -> col.order state) config.columns of
            [] ->
                []

            first :: remaining ->
                renderColumn config state rowIndex row True first
                    :: List.map
                        (renderColumn config state rowIndex row False)
                        remaining
        )


renderColumn : Config state data msg -> state -> Int -> data -> Bool -> Column state data msg -> Element msg
renderColumn config state rowIndex row isFirstColumn (Column col) =
    let
        { attrs, child } =
            col.view rowIndex state row

        padding =
            if rowIndex == 0 then
                default.paddingFirstRow

            else
                default.padding
    in
    Two.element Two.NodeAsTableD
        Two.AsRow
        (padding
            :: Two.attrIf
                (config.stickFirstColumn && isFirstColumn)
                (Two.class
                    Style.classes.stickyLeft
                )
            :: Two.attrIf
                (not (col.visible state))
                (Two.style "display" "none")
            :: Two.attrIf
                (config.stickFirstColumn && isFirstColumn)
                (Ui.background (Ui.rgb 255 255 255))
            :: Two.attrIf
                (config.stickFirstColumn && isFirstColumn)
                (Two.style "z-index" "1")
            :: attrs
        )
        [ child ]


renderSummary : Config state data msg -> state -> List data -> Element msg
renderSummary config state rows =
    Two.element Two.NodeAsTableFoot
        Two.AsRow
        [ Two.style "display" "contents" ]
        [ Two.element Two.NodeAsTableRow
            Two.AsRow
            [ Two.style "display" "contents"
            ]
            (case List.sortBy (\(Column col) -> col.order state) config.columns of
                [] ->
                    []

                first :: remaining ->
                    renderSummaryColumn config state rows True first
                        :: List.map
                            (renderSummaryColumn config state rows False)
                            remaining
            )
        ]


renderSummaryColumn : Config state data msg -> state -> List data -> Bool -> Column state data msg -> Element msg
renderSummaryColumn config state rows isFirstColumn (Column col) =
    let
        { attrs, child } =
            case col.summary of
                Nothing ->
                    cell [] Ui.none

                Just sum ->
                    sum state rows

        padding =
            default.padding
    in
    Two.element Two.NodeAsTableD
        Two.AsRow
        (padding
            :: Two.attrIf
                config.stickHeader
                (Two.class
                    Style.classes.stickyBottom
                )
            :: Two.attrIf
                (not (col.visible state))
                (Two.style "display" "none")
            :: Two.attrIf
                (config.stickFirstColumn && isFirstColumn)
                (Two.class
                    Style.classes.stickyLeft
                )
            :: Two.attrIf
                config.stickHeader
                (Ui.background (Ui.rgb 255 255 255))
            :: Two.attrIf
                (config.stickFirstColumn && isFirstColumn)
                (Two.style "z-index" "1")
            :: Ui.height Ui.fill
            :: attrs
        )
        [ child ]
