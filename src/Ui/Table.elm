module Ui.Table exposing
    ( Column, column, Cell, cell
    , header, withWidth, withStickyColumn
    , view, Config, columns
    , withRowKey, onRowClick, withStickyHeader, withStickyRow, withScrollable
    , viewWithState
    , columnWithState, withVisibility, withOrder
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
                { header =  Ui.Table.header "Occupation"
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

@docs header, withWidth, withStickyColumn


## Table Configuration

@docs view, Config, columns

@docs withRowKey, onRowClick, withStickyHeader, withStickyRow, withScrollable


# Advanced Tables with State

@docs viewWithState

@docs columnWithState, withVisibility, withOrder

@docs withSort

-}

import Html
import Html.Attributes as Attr
import Internal.Model2 as Two
import Ui exposing (Attribute, Element)
import Ui.Border
import Ui.Font
import Ui.Lazy


{-| -}
type alias Config state data msg =
    { toKey : data -> String
    , columns : List (Column state data msg)
    , sort : Maybe (state -> List data -> List data)
    , onRowClick : Maybe (data -> msg)
    , headerStick : Bool
    , rowStick : data -> Bool
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
    , headerStick = False
    , rowStick = \_ -> False
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
withStickyHeader : Config state data msg -> Config state data msg
withStickyHeader cfg =
    { cfg | headerStick = True }


{-| -}
withSort : (state -> List data -> List data) -> Config state data msg -> Config state data msg
withSort sort cfg =
    { cfg | sort = Just sort }


{-| -}
withStickyRow : (data -> Bool) -> Config state data msg -> Config state data msg
withStickyRow rowStick cfg =
    { cfg | rowStick = rowStick }


{-| -}
withScrollable : Config state data msg -> Config state data msg
withScrollable cfg =
    { cfg | scrollable = True }


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
        , sticky : Bool
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
    , borderHeaderColor = Ui.Border.color (Ui.rgb 200 200 200)
    , borderHeader =
        Ui.Border.widthEach
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
        [ -- some minimal defaults

        ]
        (Ui.text "Header text")

-}
header : String -> Cell msg
header str =
    cell
        [ default.padding
        , default.borderHeader
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
        , sticky = False
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
        , sticky = False
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
withStickyColumn : Column state data msg -> Column state data msg
withStickyColumn (Column col) =
    Column { col | sticky = True }


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
            renderRows config state data
    in
    Two.elementAs Html.table
        Two.AsColumn
        (Two.attribute (Attr.style "display" "grid")
            :: Two.attribute
                (Attr.style "grid-template-columns"
                    (gridTemplate config.columns "")
                )
            :: attrs
        )
        [ headerRow
        , rows
        ]


gridTemplate cols str =
    case cols of
        [] ->
            str

        (Column col) :: remain ->
            case col.width of
                Nothing ->
                    gridTemplate remain (str ++ " minmax(min-content, max-content)")

                Just w ->
                    case w.min of
                        Nothing ->
                            case w.max of
                                Nothing ->
                                    if w.fill then
                                        gridTemplate remain (str ++ " 1fr")

                                    else
                                        gridTemplate remain (str ++ " min-content")

                                Just max ->
                                    if w.fill then
                                        gridTemplate remain
                                            (str
                                                ++ " minmax(1fr, "
                                                ++ String.fromInt max
                                                ++ "px)"
                                            )

                                    else
                                        gridTemplate remain
                                            (str
                                                ++ " minmax(min-content, "
                                                ++ String.fromInt max
                                                ++ "px)"
                                            )

                        Just min ->
                            case w.max of
                                Nothing ->
                                    if w.fill then
                                        gridTemplate remain
                                            (str
                                                ++ " minmax("
                                                ++ String.fromInt min
                                                ++ "px , 1fr)"
                                            )

                                    else
                                        gridTemplate remain
                                            (str
                                                ++ " minmax("
                                                ++ String.fromInt min
                                                ++ "px , max-content)"
                                            )

                                Just max ->
                                    gridTemplate remain
                                        (str
                                            ++ " minmax("
                                            ++ String.fromInt min
                                            ++ "px , "
                                            ++ String.fromInt max
                                            ++ ")"
                                        )


renderHeader state config =
    Two.elementAs Html.thead
        Two.AsRow
        [ Two.attribute (Attr.style "display" "contents") ]
        [ Two.elementAs Html.tr
            Two.AsRow
            [ Two.attribute (Attr.style "display" "contents") ]
            (List.map
                (renderColumnHeader state)
                config.columns
            )
        ]


renderColumnHeader state (Column col) =
    let
        { attrs, child } =
            col.header state
    in
    Two.elementAs Html.th
        Two.AsRow
        (default.padding :: default.fontAlignment :: attrs)
        [ child ]


renderRows config state data =
    Two.elementKeyed "tbody"
        Two.AsRow
        [ Two.attribute (Attr.style "display" "contents") ]
        (List.indexedMap
            (renderRowWithKey config state)
            data
        )


renderRowWithKey config state index row =
    ( config.toKey row
    , Ui.Lazy.lazy4 renderRow config state row index
    )


renderRow config state row rowIndex =
    Two.elementAs Html.tr
        Two.AsRow
        [ Two.attribute (Attr.style "display" "contents") ]
        (List.map
            (renderColumn config state rowIndex row)
            config.columns
        )


renderColumn config state rowIndex row (Column col) =
    let
        { attrs, child } =
            col.view rowIndex state row

        padding =
            if rowIndex == 0 then
                default.paddingFirstRow

            else
                default.padding
    in
    Two.elementAs Html.td
        Two.AsRow
        (padding :: attrs)
        [ child ]
