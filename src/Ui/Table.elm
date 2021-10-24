module Ui.Table exposing
    ( Column, column, header, withWidth, withStickyColumn
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
                        Ui.text row.name
                }
            , Ui.Table.column
                { header =  Ui.Table.header "Occupation"
                , view =
                    \row ->
                        Ui.text row.occupation
                }
            ]



    viewTable model =
        Ui.Table.view [] myTable model.data


## Column Configuration

@docs Column, column, header, withWidth, withStickyColumn


## Table Configuration

@docs view, Config, columns

@docs withRowKey, onRowClick, withStickyHeader, withStickyRow, withScrollable


# Advanced Tables with State

@docs viewWithState

@docs columnWithState, withVisibility, withOrder

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
withScrollable : Config state data msg -> Config state data msg
withScrollable cfg =
    { cfg | scrollable = True }


{-| -}
type Column state data msg
    = Column
        { header : state -> Element msg
        , width :
            Maybe
                { fill : Bool
                , min : Maybe Int
                , max : Maybe Int
                }
        , view : Int -> state -> data -> Element msg
        , visible : state -> Bool
        , order : state -> Int
        , sticky : Bool
        }


{-| A simple header with some default styling.

Feel free to make your own! This is just an `Element`

-}
header : String -> Element msg
header str =
    Ui.el []
        (Ui.text str)


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
        , width = Nothing
        , visible = \_ -> True
        , order = \_ -> 0
        , sticky = False
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
withWidth col =
    col


{-| -}
withStickyColumn : Column state data msg -> Column state data msg
withStickyColumn col =
    col


{-| -}
withVisibility : (state -> Bool) -> Column state data msg -> Column state data msg
withVisibility col =
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
