module Generator exposing (..)

{-| -}

import Testable
import Testable.Element as Element exposing (..)


-- sizes : (List (Testable.Attr msg) -> Testable.Element msg -> Testable.Element msg) -> List (Testable.Element msg)


sizes render =
    List.concatMap
        (\( widthLen, heightLen ) ->
            [ text (Debug.toString ( widthLen, heightLen ))
            , render
                (\attrs children ->
                    el
                        (width widthLen
                            :: height heightLen
                            :: attrs
                        )
                        children
                )
            ]
        )
        allLengthPairs


allLengthPairs : List ( Length, Length )
allLengthPairs =
    let
        crossProduct len =
            List.map (Tuple.pair len) lengths
    in
    List.concatMap crossProduct lengths


lengths =
    [ px 50
    , fill
    , shrink
    , fill
        |> maximum 100
    , fill
        |> maximum 100
        |> minimum 50
    , shrink
        |> maximum 100
    , shrink
        |> maximum 100
        |> minimum 50
    ]
