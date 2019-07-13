module Suite exposing (main)

import Benchmark exposing (Benchmark)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Dict
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Html
import Html.Attributes
import Internal.Flag as Flag
import Internal.Model as Internal
import Json.Encode
import Set


dict : Benchmark
dict =
    let
        dest =
            Dict.singleton "a" 1
    in
    Benchmark.describe "dictionary"
        [ Benchmark.benchmark "get" (\_ -> Dict.get "a" dest)
        , Benchmark.benchmark "insert" (\_ -> Dict.insert "b" 2 dest)
        ]


main : BenchmarkProgram
main =
    program <|
        Benchmark.describe "sample"
            [ --dict
              -- , deduplications
              --   renderPipeline
              gatheringAttributes

            --   flagOperations
            ]


flagOperations =
    Benchmark.describe "Flag Operations"
        [ Benchmark.benchmark "check if present" <|
            \_ ->
                Flag.present Flag.height Flag.none
        , Benchmark.benchmark "add to flagt" <|
            \_ ->
                Flag.add Flag.height Flag.none
        ]


gatheringAttributes =
    Benchmark.describe "Gathering Attributes"
        [ Benchmark.benchmark "existing - gatherAttrRecursive" <|
            \_ ->
                Internal.gatherAttrRecursive
                    (Internal.contextClasses Internal.AsEl)
                    Internal.Generic
                    Flag.none
                    Internal.Untransformed
                    []
                    []
                    Internal.NoNearbyChildren
                    [ Element.width Element.shrink
                    , Element.height Element.shrink
                    ]
        , Benchmark.benchmark "Simple list filterMap" <|
            \_ ->
                List.filterMap
                    identity
                    [ Just "thing"
                    , Just "other width"
                    ]
        , Benchmark.benchmark "Simple list map" <|
            \_ ->
                List.map
                    identity
                    [ Just "thing"
                    , Just "other width"
                    ]
        , Benchmark.benchmark "Foldl base speed" <|
            \_ ->
                List.foldl
                    (::)
                    [ Just "thing"
                    , Just "other width"
                    ]
        , Benchmark.benchmark "Recursive" <|
            \_ ->
                recurse
                    (::)
                    [ Just "thing"
                    , Just "other width"
                    ]
        , Benchmark.benchmark "foldl - new record each iteration" <|
            \_ ->
                List.foldl flipFoldl
                    { attributes = "class"
                    , styles = []
                    , node = "Node"
                    , children = Nothing
                    , has = Flag.none
                    }
                    -- we reverse first because we have to for the attr api.
                    (List.reverse
                        [ Just "thing"
                        , Just "other width"
                        ]
                    )
        , Benchmark.benchmark "foldl - update" <|
            \_ ->
                List.foldl flipFoldlUpdate
                    { attributes = "class"
                    , styles = []
                    , node = "Node"
                    , children = Nothing
                    , has = Flag.none
                    }
                    -- we reverse first because we have to for the attr api.
                    (List.reverse
                        [ Just "thing"
                        , Just "other width"
                        ]
                    )
        , Benchmark.benchmark "String Concatenation" <|
            \_ ->
                "This"
                    ++ "this"
                    ++ "this"
                    ++ "this"
                    ++ "this"
                    ++ "this"
                    ++ "this"
                    ++ "this"
        , Benchmark.benchmark "List String Concatenation" <|
            \_ ->
                String.concat
                    [ "This"
                    , "this"
                    , "this"
                    , "this"
                    , "this"
                    , "this"
                    , "this"
                    , "this"
                    ]
        ]


flipFoldl result found =
    { attributes = "class" ++ found.attributes
    , styles = Just 1 :: found.styles
    , node = found.node
    , children = Nothing
    , has = Flag.add Flag.height found.has
    }


flipFoldlUpdate result found =
    { found
        | attributes = "class" ++ found.attributes
        , styles = Just 1 :: found.styles
        , has = Flag.add Flag.height found.has
    }


recurse fn ls =
    case ls of
        [] ->
            []

        fst :: remain ->
            fn fst (recurse fn remain)


deduplications =
    Benchmark.describe "deduplications"
        [ Benchmark.benchmark "fold - dedup, String concat"
            (\_ ->
                String.join ":" (foldDedup largeList)
            )
        , Benchmark.benchmark "fold - dedup"
            (\_ ->
                foldDedup largeList
            )
        , Benchmark.benchmark "fold - dedup - Int"
            (\_ ->
                foldDedup largeListInt
            )
        , Benchmark.benchmark "Json encode"
            (\_ ->
                Json.Encode.object largeListJson
            )
        ]


foldDedup list =
    let
        dedup ( name, val ) ( cache, ls ) =
            if Set.member name cache then
                ( cache, ls )

            else
                ( Set.insert name cache, val :: ls )
    in
    List.foldl dedup ( Set.empty, [] ) list
        |> Tuple.second


largeListInt =
    List.range 1 10000
        |> List.map
            (\i ->
                let
                    wrappingI =
                        modBy 50 i
                in
                ( wrappingI, "elem-" ++ String.fromInt wrappingI )
            )


largeList =
    List.range 1 10000
        |> List.map
            (\i ->
                let
                    wrappingI =
                        modBy 50 i
                in
                ( "elem-" ++ String.fromInt wrappingI, "elem-" ++ String.fromInt wrappingI )
            )


largeListJson =
    List.range 1 10000
        |> List.map
            (\i ->
                let
                    wrappingI =
                        modBy 50 i
                in
                ( "elem-" ++ String.fromInt wrappingI, Json.Encode.string ("elem-" ++ String.fromInt wrappingI) )
            )


renderPipeline =
    [ Benchmark.benchmark "build 2000 elements"
        (\_ ->
            elements 0 twoThousand
        )
    , Benchmark.benchmark "build 2000 html"
        (\_ ->
            html 0 twoThousand
        )
    ]


twoThousand =
    List.range 0 2000


elements i count =
    Element.layout []
        (Element.column [ spacing 8, centerX ]
            (List.map (viewEl i) count)
        )


viewEl selectedIndex index =
    el
        [ Background.color
            (if selectedIndex == index then
                pink

             else
                white
            )
        , Font.color
            (if selectedIndex /= index then
                pink

             else
                white
            )
        , padding 24
        , width (px 500)
        , height (px 70)
        ]
        (if selectedIndex == index then
            text "selected"

         else
            text "Hello!"
        )


white =
    rgb 1 1 1


pink =
    rgb255 240 0 245


html i count =
    Html.div []
        [ Html.div []
            (List.map (viewHtmlElement i) count)
        ]


viewHtmlElement selectedIndex index =
    Html.div
        [ Html.Attributes.class
            (if selectedIndex == index then
                "white"

             else
                "pink"
            )
        ]
        [ Html.div []
            [ if selectedIndex == index then
                Html.text "selected"

              else
                Html.text "Hello!"
            ]
        ]
