module Ui.Table exposing
    ( Column, column, Cell, cell
    , header
    , Width, withWidth, defaultWidth
    , view, Config, columns
    , withRowKey, withRowAttributes
    , withScrollable
    , viewWithState
    , columnWithState, withVisibility, withOrder, withSummary
    , columnWithAlignment, columnWithAlignment3
    , withRowState
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

@docs header

@docs Width, withWidth, defaultWidth


## Table Configuration

@docs view, Config, columns

@docs withRowKey, withRowAttributes

@docs withScrollable


# Advanced Tables with State

@docs viewWithState

@docs columnWithState, withVisibility, withOrder, withSummary

@docs columnWithAlignment, columnWithAlignment3

@docs withRowState

@docs withSort

-}

import Internal.Flag as Flag
import Internal.Model2 as Two
import Internal.Style2 as Style
import Ui exposing (Attribute, Element)
import Ui.Font
import Ui.Lazy


{-| -}
type alias Config globalState rowState data msg =
    { toKey : data -> String
    , columns : List (Column globalState rowState data msg)
    , sort : Maybe (globalState -> List data -> List data)

    -- Row config
    , toRowState : Maybe (globalState -> Int -> data -> Maybe rowState)
    , toRowAttrs : Maybe (Maybe rowState -> data -> List (Attribute msg))
    , stickHeader : Bool
    , stickRow : data -> Bool
    , stickFirstColumn : Bool
    , scrollable : Bool
    }


{-| -}
columns :
    List (Column globalState rowState data msg)
    -> Config globalState rowState data msg
columns cols =
    { toKey = \_ -> "keyed"
    , columns = cols
    , toRowState = Nothing
    , toRowAttrs = Nothing
    , stickHeader = False
    , stickRow = \_ -> False
    , stickFirstColumn = False
    , scrollable = False
    , sort = Nothing
    }


{-| Adding a `key` to a row will automatically use `Keyed` under the hood.
-}
withRowKey : (data -> String) -> Config globalState rowState data msg -> Config globalState rowState data msg
withRowKey toKey cfg =
    { cfg | toKey = toKey }


{-| -}
withRowState :
    (globalState -> Int -> data -> Maybe rowState)
    -> Config globalState rowState data msg
    -> Config globalState rowState data msg
withRowState toState cfg =
    { cfg | toRowState = Just toState }


{-| -}
withRowAttributes :
    (Maybe rowState -> data -> List (Attribute msg))
    -> Config globalState rowState data msg
    -> Config globalState rowState data msg
withRowAttributes toRowAttrs cfg =
    { cfg | toRowAttrs = Just toRowAttrs }


{-| -}
withSort :
    (globalState -> List data -> List data)
    -> Config globalState rowState data msg
    -> Config globalState rowState data msg
withSort sort cfg =
    { cfg | sort = Just sort }


{-| -}
withScrollable :
    { stickFirstColumn : Bool
    }
    -> Config globalState rowState data msg
    -> Config globalState rowState data msg
withScrollable input cfg =
    { cfg
        | scrollable = True
        , stickHeader = True
        , stickFirstColumn = input.stickFirstColumn
    }


{-| -}
type Column globalState rowState data msg
    = Column (ColumnDetails globalState rowState data msg)


type alias ColumnDetails globalState rowState data msg =
    { header : globalState -> Cell msg
    , columnSpan : Int
    , widths :
        List
            { fill : Bool
            , min : Maybe Int
            , max : Maybe Int
            }
    , view : Int -> Maybe rowState -> data -> List (Cell msg)
    , visible : Maybe (globalState -> Bool)
    , order : Maybe (globalState -> Int)
    , summary : Maybe (globalState -> List data -> Cell msg)
    }


{-| -}
type alias Cell msg =
    { attrs : List (Attribute msg)
    , children : List (Element msg)
    }


{-| -}
cell : List (Attribute msg) -> Element msg -> Cell msg
cell attrs child =
    Cell attrs [ child ]


default :
    { padding : Attribute msg
    , paddingFirstRow : Attribute msg
    , fontAlignment : Attribute msg
    , borderHeader : Attribute msg
    }
default =
    { padding =
        Ui.paddingXY 16 8
    , paddingFirstRow =
        Ui.paddingWith
            { top = 8
            , left = 16
            , right = 16
            , bottom = 8
            }
    , fontAlignment = Ui.Font.alignLeft
    , borderHeader =
        Ui.borderWith
            { top = 0
            , left = 0
            , right = 0
            , bottom = 1
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


{-| A default width for a column which shrinks to it's contents and has no min or max.
-}
defaultWidth : Width
defaultWidth =
    { fill = False
    , min = Nothing
    , max = Nothing
    }


{-| -}
column :
    { header : Cell msg
    , view : data -> Cell msg
    }
    -> Column globalState rowState data msg
column input =
    Column
        { header = \_ -> input.header
        , view = \_ _ data -> [ input.view data ]
        , columnSpan = 1
        , widths = [ defaultWidth ]
        , visible = Nothing
        , order = Nothing
        , summary = Nothing
        }


{-| -}
columnWithState :
    { header : globalState -> Cell msg
    , view : Int -> Maybe rowState -> data -> Cell msg
    }
    -> Column globalState rowState data msg
columnWithState input =
    Column
        { header = input.header
        , view = \index state data -> [ input.view index state data ]
        , columnSpan = 1
        , widths = [ defaultWidth ]
        , visible = Nothing
        , order = Nothing
        , summary = Nothing
        }


{-| -}
columnWithAlignment :
    { header : globalState -> Cell msg
    , widths : ( Width, Width )
    , view : Int -> Maybe rowState -> data -> ( Cell msg, Cell msg )
    }
    -> Column globalState rowState data msg
columnWithAlignment input =
    Column
        { header = input.header
        , view =
            \index state data ->
                let
                    ( one, two ) =
                        input.view index state data
                in
                [ one
                , two
                ]
        , columnSpan = 2
        , widths =
            let
                ( w1, w2 ) =
                    input.widths
            in
            [ w1, w2 ]
        , visible = Nothing
        , order = Nothing
        , summary = Nothing
        }


{-| -}
type alias Width =
    { fill : Bool
    , min : Maybe Int
    , max : Maybe Int
    }


{-| -}
columnWithAlignment3 :
    { header : globalState -> Cell msg
    , widths : ( Width, Width, Width )
    , view : Int -> Maybe rowState -> data -> ( Cell msg, Cell msg, Cell msg )
    }
    -> Column globalState rowState data msg
columnWithAlignment3 input =
    Column
        { header = input.header
        , view =
            \index state data ->
                let
                    ( one, two, three ) =
                        input.view index state data
                in
                [ one
                , two
                , three
                ]
        , columnSpan = 3
        , widths =
            let
                ( w1, w2, w3 ) =
                    input.widths
            in
            [ w1, w2, w3 ]
        , visible = Nothing
        , order = Nothing
        , summary = Nothing
        }


{-| -}
withWidth : Width -> Column globalState rowState data msg -> Column globalState rowState data msg
withWidth width (Column col) =
    Column { col | widths = List.map (\_ -> width) col.widths }


{-| -}
withSummary : (globalState -> List data -> Cell msg) -> Column globalState rowState data msg -> Column globalState rowState data msg
withSummary toSummaryCell (Column col) =
    Column
        { col
            | summary = Just toSummaryCell
        }


{-| -}
withVisibility : (globalState -> Bool) -> Column globalState rowState data msg -> Column globalState rowState data msg
withVisibility toVisibility (Column col) =
    Column { col | visible = Just toVisibility }


{-| -}
withOrder : (globalState -> Int) -> Column globalState rowState data msg -> Column globalState rowState data msg
withOrder toOrder (Column col) =
    Column { col | order = Just toOrder }


{-| -}
view :
    List (Attribute msg)
    -> Config () () data msg
    -> List data
    -> Element msg
view attrs config data =
    viewWithState attrs config () data


{-| -}
viewWithState :
    List (Attribute msg)
    -> Config globalState rowState data msg
    -> globalState
    -> List data
    -> Element msg
viewWithState attrs config state data =
    let
        headerRow =
            Ui.Lazy.lazy2
                viewHeader
                state
                config

        rows =
            Ui.Lazy.lazy4 viewTableBody config cols state data

        cols =
            getColumns config state
    in
    Two.element Two.NodeAsTable
        Two.AsColumn
        (Two.style "display" "grid"
            :: Two.attrIf config.scrollable
                (Two.classWith Flag.overflow Style.classes.scrollbars)
            :: Two.style "grid-template-columns"
                (gridTemplateColumns state cols "")
            :: Two.style "grid-auto-rows"
                "minmax(min-content, max-content)"
            :: Ui.width Ui.fill
            :: attrs
        )
        [ headerRow
        , rows
        , if List.any hasSummary config.columns then
            Ui.Lazy.lazy4 viewSummary config cols state data

          else
            Ui.none
        ]


hasSummary : Column globalState rowState data msg -> Bool
hasSummary (Column col) =
    case col.summary of
        Nothing ->
            False

        Just _ ->
            True


gridTemplateColumns : globalState -> List (Column globalState rowState data msg) -> String -> String
gridTemplateColumns state cols str =
    case cols of
        [] ->
            str

        (Column col) :: remain ->
            gridTemplateColumns state remain (str ++ " " ++ columnToGridTemplate col)


renderWidth : Width -> String
renderWidth w =
    case w.min of
        Nothing ->
            case w.max of
                Nothing ->
                    if w.fill then
                        "1fr"

                    else
                        "minmax(min-content, max-content)"

                Just max ->
                    if w.fill then
                        "minmax(1fr, "
                            ++ String.fromInt max
                            ++ "px)"

                    else
                        "minmax(min-content, "
                            ++ String.fromInt max
                            ++ "px)"

        Just min ->
            case w.max of
                Nothing ->
                    if w.fill then
                        "minmax("
                            ++ String.fromInt min
                            ++ "px , 1fr)"

                    else
                        "minmax("
                            ++ String.fromInt min
                            ++ "px , max-content)"

                Just max ->
                    "minmax("
                        ++ String.fromInt min
                        ++ "px , "
                        ++ String.fromInt max
                        ++ ")"


columnToGridTemplate : ColumnDetails globalState rowState data msg -> String
columnToGridTemplate col =
    renderWidthList col.widths ""


renderWidthList : List Width -> String -> String
renderWidthList width str =
    case width of
        [] ->
            str

        w :: remain ->
            if str == "" then
                renderWidthList remain (renderWidth w)

            else
                renderWidthList remain (str ++ " " ++ renderWidth w)


viewHeader : globalState -> Config globalState rowState data msg -> Element msg
viewHeader state config =
    let
        cols =
            getColumns config state

        ( _, cells ) =
            List.foldl
                (viewHeaderHelper config state)
                ( 0, [] )
                cols
    in
    Two.element Two.NodeAsTableHead
        Two.AsRow
        [ Two.style "display" "contents" ]
        [ Two.elementKeyed Two.NodeAsTableRow
            Two.AsRow
            [ Two.style "display" "contents"
            ]
            (List.reverse cells)
        ]


viewHeaderHelper :
    Config globalState rowState data msg
    -> globalState
    -> Column globalState rowState data msg
    -> ( Int, List ( String, Element msg ) )
    -> ( Int, List ( String, Element msg ) )
viewHeaderHelper config state ((Column colData) as col) ( columnIndex, existingCols ) =
    ( columnIndex + colData.columnSpan
    , ( String.fromInt columnIndex
      , Ui.Lazy.lazy4 viewHeaderCell config state columnIndex col
      )
        :: existingCols
    )


viewHeaderCell :
    Config globalState rowState data msg
    -> globalState
    -> Int
    -> Column globalState rowState data msg
    -> Element msg
viewHeaderCell cfg state negativeIndex (Column col) =
    let
        columnIndex =
            negativeIndex + 1

        { attrs, children } =
            col.header state

        stickyColumn =
            cfg.stickFirstColumn && isFirstColumn

        isFirstColumn =
            columnIndex == 1
    in
    Two.element Two.NodeAsTableHeaderCell
        Two.AsEl
        (default.padding
            :: toGridCoords 1 columnIndex 2 (columnIndex + col.columnSpan)
            :: default.fontAlignment
            :: Two.attrIf
                cfg.stickHeader
                (Two.class
                    Style.classes.stickyTop
                )
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
        children


hasColumnMods : Column globalState rowState data msg -> Bool
hasColumnMods (Column col) =
    col.visible /= Nothing || col.order /= Nothing


getColumns : Config globalState rowState data msg -> globalState -> List (Column globalState rowState data msg)
getColumns config state =
    if List.any hasColumnMods config.columns then
        config.columns
            |> List.filter
                (\(Column col) ->
                    case col.visible of
                        Nothing ->
                            True

                        Just isVisible ->
                            isVisible state
                )
            |> List.sortBy
                (\(Column col) ->
                    case col.order of
                        Nothing ->
                            0

                        Just getOrder ->
                            getOrder state
                )

    else
        config.columns


viewTableBody :
    Config globalState rowState data msg
    -> List (Column globalState rowState data msg)
    -> globalState
    -> List data
    -> Element msg
viewTableBody config cols state data =
    let
        sorted =
            case config.sort of
                Nothing ->
                    data

                Just sortFn ->
                    sortFn state data
    in
    Two.elementKeyed Two.NodeAsTableBody
        Two.AsRow
        [ Two.style "display" "contents" ]
        (( "active"
         , Ui.Lazy.lazy3 viewActiveRows config state sorted
         )
            :: List.indexedMap
                (viewRowWithKey config cols state)
                sorted
        )


viewActiveRows :
    Config globalState rowState data msg
    -> globalState
    -> List data
    -> Element msg
viewActiveRows config globalState rows =
    let
        ( _, selected ) =
            List.foldl (viewActiveRow config globalState) ( 0, [] ) rows
    in
    case selected of
        [] ->
            Ui.none

        _ ->
            Two.element Two.NodeAsTableRow
                Two.AsRow
                [ Two.style "display" "contents" ]
                selected


viewActiveRow :
    Config globalState rowState data msg
    -> globalState
    -> data
    -> ( Int, List (Element msg) )
    -> ( Int, List (Element msg) )
viewActiveRow config globalState row ( rowZeroIndex, acc ) =
    case config.toRowAttrs of
        Nothing ->
            ( rowZeroIndex + 1
            , acc
            )

        Just toAttrs ->
            let
                maybeRowState =
                    case config.toRowState of
                        Nothing ->
                            Nothing

                        Just toState ->
                            toState globalState rowZeroIndex row

                rowAttrs =
                    toAttrs maybeRowState row
            in
            case rowAttrs of
                [] ->
                    ( rowZeroIndex + 1
                    , acc
                    )

                _ ->
                    ( rowZeroIndex + 1
                    , Ui.el
                        (toGridCoords (rowZeroIndex + 2) 1 (rowZeroIndex + 3) -1
                            :: rowAttrs
                        )
                        Ui.none
                        :: acc
                    )


{-|

    Given as: <row-start> / <column-start> / <row-end> / <column-end>
    grid-area: 1 / col4-start / last-line / 6;

-}
toGridCoords : Int -> Int -> Int -> Int -> Ui.Attribute msg
toGridCoords rowStart columnStart rowEnd columnEnd =
    Two.style "grid-area"
        ((String.fromInt rowStart ++ " / ")
            ++ (String.fromInt columnStart ++ " / ")
            ++ (String.fromInt rowEnd ++ " / ")
            ++ String.fromInt columnEnd
        )


viewRowWithKey :
    Config globalState rowState data msg
    -> List (Column globalState rowState data msg)
    -> globalState
    -> Int
    -> data
    -> ( String, Element msg )
viewRowWithKey config cols state index row =
    let
        rowState =
            case config.toRowState of
                Nothing ->
                    Nothing

                Just toState ->
                    toState state index row
    in
    ( config.toKey row
    , Ui.Lazy.lazy5 viewRow config cols rowState row index
    )


viewRow :
    Config globalState rowState data msg
    -> List (Column globalState rowState data msg)
    -> Maybe rowState
    -> data
    -> Int
    -> Element msg
viewRow config cols rowState row rowIndex =
    let
        attrs =
            case config.toRowAttrs of
                Nothing ->
                    []

                Just toAttrs ->
                    toAttrs rowState row

        ( _, cells ) =
            List.foldl
                (viewCellHelper config rowState rowIndex row)
                ( 0, [] )
                cols
    in
    Two.elementKeyed Two.NodeAsTableRow
        Two.AsRow
        (Two.style "display" "contents"
            :: attrs
        )
        (List.reverse cells)


viewCellHelper :
    Config globalState rowState data msg
    -> Maybe rowState
    -> Int
    -> data
    -> Column globalState rowState data msg
    -> ( Int, List ( String, Element msg ) )
    -> ( Int, List ( String, Element msg ) )
viewCellHelper config state rowIndex row ((Column colData) as col) ( columnIndex, existingCols ) =
    ( columnIndex + colData.columnSpan
    , ( String.fromInt columnIndex
      , Ui.Lazy.lazy6 viewCell config state rowIndex row col columnIndex
      )
        :: existingCols
    )


viewCell :
    Config globalState rowState data msg
    -> Maybe rowState
    -> Int
    -> data
    -> Column globalState rowState data msg
    -> Int
    -> Element msg
viewCell config state rowIndex row (Column col) columnIndexZero =
    let
        columnIndex =
            columnIndexZero + 1

        isFirstColumn =
            columnIndex == 1
    in
    case col.view rowIndex state row of
        [] ->
            Two.element Two.NodeAsTableD
                Two.AsEl
                []
                []

        [ single ] ->
            viewCellInner config Two.NodeAsTableD rowIndex columnIndex 0 col.columnSpan single

        cells ->
            Two.element Two.NodeAsTableD
                Two.AsEl
                [ Two.style "display" "contents" ]
                (List.indexedMap
                    (\i data ->
                        viewCellInner config Two.NodeAsSpan rowIndex (columnIndex + i) i col.columnSpan data
                    )
                    cells
                )


viewCellInner :
    Config globalState rowState data msg
    -> Two.Node
    -> Int
    -> Int
    -> Int
    -> Int
    -> Cell msg
    -> Element msg
viewCellInner config nodeType rowIndex columnIndex cellIndex cellCount { attrs, children } =
    let
        isFirstColumn =
            columnIndex == 1

        padding =
            if cellCount == 1 then
                if rowIndex == 0 then
                    default.paddingFirstRow

                else
                    default.padding

            else if cellIndex == 0 then
                Ui.paddingWith
                    { top = 8
                    , left = 16
                    , right = 0
                    , bottom = 8
                    }

            else if cellIndex == cellCount - 1 then
                Ui.paddingWith
                    { top = 8
                    , left = 0
                    , right = 16
                    , bottom = 8
                    }

            else
                Ui.paddingXY 0 8
    in
    Two.element nodeType
        Two.AsEl
        (padding
            :: toGridCoords (rowIndex + 2) columnIndex (rowIndex + 3) (columnIndex + 1)
            :: Two.attrIf
                (config.stickFirstColumn && isFirstColumn)
                (Two.class
                    Style.classes.stickyLeft
                )
            :: Two.attrIf
                (config.stickFirstColumn && isFirstColumn)
                (Ui.background (Ui.rgb 255 255 255))
            :: Two.attrIf
                (config.stickFirstColumn && isFirstColumn)
                (Two.style "z-index" "1")
            :: attrs
        )
        children


viewSummary :
    Config globalState rowState data msg
    -> List (Column globalState rowState data msg)
    -> globalState
    -> List data
    -> Element msg
viewSummary config cols state rows =
    let
        rowCount =
            List.length rows

        ( _, cells ) =
            List.foldl
                (viewSummaryHelper config state rows rowCount)
                ( 1, [] )
                cols
    in
    Two.element Two.NodeAsTableFoot
        Two.AsRow
        [ Two.style "display" "contents" ]
        [ Two.elementKeyed Two.NodeAsTableRow
            Two.AsRow
            [ Two.style "display" "contents"
            ]
            (List.reverse cells)
        ]


viewSummaryHelper :
    Config globalState rowState data msg
    -> globalState
    -> List data
    -> Int
    -> Column globalState rowState data msg
    -> ( Int, List ( String, Element msg ) )
    -> ( Int, List ( String, Element msg ) )
viewSummaryHelper config state rows rowCount ((Column colData) as col) ( columnIndex, existingCols ) =
    ( columnIndex + colData.columnSpan
    , ( String.fromInt columnIndex
      , Ui.Lazy.lazy6 viewSummaryColumn config state rows rowCount columnIndex col
      )
        :: existingCols
    )


viewSummaryColumn :
    Config globalState rowState data msg
    -> globalState
    -> List data
    -> Int
    -> Int
    -> Column globalState rowState data msg
    -> Element msg
viewSummaryColumn config state rows rowCount columnIndex (Column col) =
    let
        { attrs, children } =
            case col.summary of
                Nothing ->
                    cell [] Ui.none

                Just sum ->
                    sum state rows

        padding =
            default.padding

        isFirstColumn =
            columnIndex == 1
    in
    Two.element Two.NodeAsTableD
        Two.AsEl
        (padding
            :: toGridCoords (rowCount + 2) columnIndex (rowCount + 3) (columnIndex + col.columnSpan)
            :: Two.attrIf
                config.stickHeader
                (Two.class
                    Style.classes.stickyBottom
                )
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
        children

