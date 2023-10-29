module Internal.Teleport.Persistent exposing
    ( id, Id
    , Persistent, empty, insert
    , get
    , getGroup, getOthersInGroup, removeGroup
    )

{-|

@docs id, Id

@docs Persistent, empty, insert
@docs get

@docs getGroup, getOthersInGroup, removeGroup

-}

import Dict


type Id
    = Id
        { group : String
        , instance : String
        }


id : String -> String -> Id
id group instance =
    Id { group = group, instance = instance }



-- CREATE


{-| A dictionary mapping IDs to values
-}
type Persistent value
    = Persistent (Dict.Dict String (Dict.Dict String value))


{-| Create an empty dictonary.
-}
empty : Persistent value
empty =
    Persistent Dict.empty



-- READ


{-| Get an item in the dictonary by ID.
-}
get : Id -> Persistent value -> Maybe value
get (Id { group, instance }) (Persistent dict) =
    Dict.get group dict
        |> Maybe.andThen (Dict.get instance)


{-| Get an item in the dictonary by ID.
-}
getGroup :
    Id
    -> Persistent value
    ->
        List
            { instance : String
            , value : value
            }
getGroup (Id { group, instance }) (Persistent dict) =
    Dict.get group dict
        |> Maybe.map Dict.toList
        |> Maybe.withDefault []
        |> List.map
            (\( i, value ) ->
                { instance = i
                , value = value
                }
            )


getOthersInGroup :
    Id
    -> Persistent value
    ->
        List
            { instance : String
            , value : value
            }
getOthersInGroup ((Id iddetails) as fullId) dict =
    getGroup fullId dict
        |> List.filter (\{ instance } -> instance /= iddetails.instance)


{-| Remove an item by ID.
-}
removeGroup : Id -> Persistent value -> Persistent value
removeGroup (Id { group, instance }) (Persistent dict) =
    Persistent (Dict.remove group dict)


{-| Insert a new item into the dictionary. This replaces existing values.
-}
insert : Id -> value -> Persistent value -> Persistent value
insert (Id { group, instance }) value (Persistent dict) =
    let
        newInstances =
            Dict.get group dict
                |> Maybe.withDefault Dict.empty
                |> Dict.insert instance value
    in
    Persistent (Dict.insert group newInstances dict)
