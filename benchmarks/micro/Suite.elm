module Suite exposing (main)

import Benchmark exposing (Benchmark)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Dict
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
            [ dict
            , deduplications
            ]


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
