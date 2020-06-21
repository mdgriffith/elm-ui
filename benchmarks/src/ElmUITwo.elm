module ElmUITwo exposing
    ( elmUITwo1024
    , elmUITwo128
    , elmUITwo2048
    , elmUITwo24
    , elmUITwo256
    , elmUITwo4096
    , elmUITwo512
    , elmUITwo64
    , elmUITwo8192
    )

{-| -}

import Benchmark.Render
import Element2 as Two
import Element2.Background as Background2
import Element2.Font as Font2
import Html
import Html.Attributes



{- START BENCHMARKS -}
{- Elm UI 2.0 -}


elmUITwo24 : Benchmark.Render.Benchmark Model Msg
elmUITwo24 =
    elmUITwo "elmUITwo24" 24


elmUITwo64 : Benchmark.Render.Benchmark Model Msg
elmUITwo64 =
    elmUITwo "elmUITwo64" 64


elmUITwo128 : Benchmark.Render.Benchmark Model Msg
elmUITwo128 =
    elmUITwo "elmUITwo128" 128


elmUITwo256 : Benchmark.Render.Benchmark Model Msg
elmUITwo256 =
    elmUITwo "elmUITwo256" 256


elmUITwo512 : Benchmark.Render.Benchmark Model Msg
elmUITwo512 =
    elmUITwo "elmUITwo512" 512


elmUITwo1024 : Benchmark.Render.Benchmark Model Msg
elmUITwo1024 =
    elmUITwo "elmUITwo1024" 1024


elmUITwo2048 : Benchmark.Render.Benchmark Model Msg
elmUITwo2048 =
    elmUITwo "elmUITwo2048" 2048


elmUITwo4096 : Benchmark.Render.Benchmark Model Msg
elmUITwo4096 =
    elmUITwo "elmUITwo4096" 4096


elmUITwo8192 : Benchmark.Render.Benchmark Model Msg
elmUITwo8192 =
    elmUITwo "elmUITwo8192" 8192



{- END BENCHMARKS -}


type alias Model =
    { index : Int
    , numberOfElements : Int
    , elements : List Int
    }


type Msg
    = Refresh
    | Tick Float


{-| -}
elmUITwo : String -> Int -> Benchmark.Render.Benchmark Model Msg
elmUITwo name count =
    { name = name
    , init =
        { index = 0
        , numberOfElements = count
        , elements = List.range 0 (count - 1)
        }
    , view =
        \model ->
            Two.layout []
                (Two.column
                    [ Two.spacing ((model.index |> modBy 2) * 8)
                    , Two.centerX
                    ]
                    (List.map (viewElTwo model.index) model.elements)
                )
    , update =
        \msg model ->
            case msg of
                Refresh ->
                    if model.index > model.numberOfElements then
                        { model | index = 0 }

                    else
                        { model | index = model.index + 1 }

                Tick i ->
                    if model.index > model.numberOfElements then
                        { model | index = 0 }

                    else
                        { model | index = model.index + 1 }
    , tick = Tick
    , refresh = Refresh
    }


viewElTwo selectedIndex index =
    Two.el
        [ Background2.color
            (if selectedIndex == index then
                pinkTwo

             else
                whiteTwo
            )
        , Font2.color
            (if selectedIndex /= index then
                pinkTwo

             else
                whiteTwo
            )
        , Two.padding 24
        , Two.width (Two.px 500)
        , Two.height (Two.px 70)
        ]
        (if selectedIndex == index then
            Two.text "selected"

         else
            Two.text "Hello!"
        )


whiteTwo =
    Two.rgb 255 255 255


pinkTwo =
    Two.rgb 240 0 245
