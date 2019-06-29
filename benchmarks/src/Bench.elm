module Bench exposing (bench)

{-| -}

import Html
import Render


type Msg
    = Refresh
    | Tick Float


bench : Render.Benchmark Int Msg
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
