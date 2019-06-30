module Baseline exposing (bench)

{-| -}

import Benchmark.Render
import Html


type Msg
    = Refresh
    | Tick Float


bench : Benchmark.Render.Benchmark Int Msg
bench =
    { name = "Baseline"
    , init = 0
    , view =
        \i ->
            Html.text (String.fromInt i)
    , update =
        \msg model ->
            case msg of
                Refresh ->
                    model + 1

                Tick i ->
                    model + 1
    , tick = Tick
    , refresh = Refresh
    }
