module Ui.Table exposing
    ( Column, column, withWidth
    , view
    , Config, columns, withRowKey, onRowClick, withStickyHeader, withStickyRow, scrollable
    , viewWithState
    , columnWithState, withVisible, withOrder
    , withSort
    )

{-|

    myTable =
        Ui.Table.columns
            [ Ui.Table.column
                { header = Ui.text "Name"
                , view =
                    \row ->
                        Ui.text row.name
                }
            , Ui.Table.column
                { header = Ui.text "Occupation"
                , view =
                    \row ->
                        Ui.text row.occupation
                }
            ]



    viewTable model =
        Ui.Table.view [] myTable model.data


## Column Configuration

@docs Column, column, withWidth


## Table Configuration

@docs view

@docs Config, columns, withRowKey, onRowClick, withStickyHeader, withStickyRow, scrollable


# Advanced Tables with State

@docs viewWithState

@docs columnWithState, withVisible, withOrder

@docs withSort

-}

import Ui exposing (Attribute, Element)


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
    }


{-| Adding a `key` to a row will automatically use `Keyed` under the hood.
-}
withRowKey : (data -> String) -> Config state data msg -> Config state data msg
withRowKey toKey (Config cfg) =
    Config
        { cfg | toKey = toKey }


{-| -}
onRowClick : (data -> msg) -> Config state data msg -> Config state data msg
onRowClick onClick cfg =
    { cfg | onRowClick = onClick }


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
scrollable : Config state data msg -> Config state data msg
scrollable cfg =
    { cfg | scrollable = True }


{-| -}
type Column state data msg
    = Column
        { header : state -> Element msg
        , width : Length
        , view : Int -> state -> data -> Element msg
        , visible : state -> Bool
        , order : state -> Int
        }


{-| -}
column :
    { header : Element msg
    , view : data -> Element msg
    }
    -> Column state data msg
column input =
    Column
        { header = \state -> input.header
        , view = \index state data -> input.view data
        , id = Nothing
        , width = Len
        , visible = \_ -> True
        , order = \_ -> 0
        }


{-| -}
columnWithState :
    { header : state -> Element msg
    , view : Int -> state -> data -> Element msg
    }
    -> Column state data msg
columnWithState input =
    Column
        { header = input.header
        , view = input.view
        , id = Nothing
        , width = Len
        , visible = \_ -> True
        , order = \_ -> 0
        }


{-| -}
withWidth :
    { fill : Bool
    , min : Maybe Int
    , max : Maybe Int
    }
    -> Column state data msg
    -> Column state data msg
withWidth col =
    col


{-| -}
withVisible : (state -> Bool) -> Column state data msg -> Column state data msg
withVisible col =
    col


{-| -}
withOrder : (state -> Int) -> Column state data msg -> Column state data msg
withOrder col =
    col


{-| -}
view :
    List (Attribute msg)
    -> Config () data msg
    -> List data
    -> Element msg
view attrs config data =
    Debug.todo "Do da table"


{-| -}
viewWithState :
    List (Attribute msg)
    -> Config state data msg
    -> state
    -> List data
    -> Element msg
viewWithState attrs config state data =
    Debug.todo "With state!"
