module Attrs exposing (main)

import Benchmark exposing (Benchmark)
import Benchmark.Runner
import Dict
import Internal.Model2 as Internal
import Ui
import Array exposing (Array)
import Ui.Font
import Ui.Background
import Ui.Gradient

main : Benchmark.Runner.BenchmarkProgram
main =
    Benchmark.Runner.program <|
        Benchmark.describe "Attr recursion"
            [ 
            --     dict
            -- , intDict
            -- , record
            -- transforms
            rendering
            ]





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



intDict : Benchmark
intDict =
    let
        dest =
            Dict.singleton 1 "Hello!"
        el = Ui.el []
    in
    Benchmark.describe "int dict"
        [ Benchmark.benchmark "get" (\_ -> Dict.get 1 dest)
        , Benchmark.benchmark "insert" (\_ -> Dict.insert 2 "HELLO!" dest)
        ]


type Transform =
    Transform (Array Float)



initTransform =
    Transform <|
        Array.initialize 4
            (\i ->
                if i == 2 then
                    2 * pi
                else if i == 3 then
                    1
                else
                    0
            ) 

transformToString (Transform trans) =
    Array.foldl 
        (\t (i, str) -> 
            ( i + 1 
            , case i of
                0 ->
                    "translate("
                        ++ String.fromFloat t
                        ++ "px, "
                    

                1 ->
                    str
                        ++ String.fromFloat t
                        ++ "px) "

                2 ->
                    str 
                        ++ "rotate("
                        ++ String.fromFloat t
                        ++ "rad) "

                3 ->
                    str 
                        ++ "scale("
                        ++ String.fromFloat t
                        ++ ")"

                _ ->
                   str
            )
        )
        (0, "")
        trans


type alias Details =
    { x : Float
    , y : Float
    , rotate : Float
    , scale : Float
    }

transformRecord =
     { x = 0
    , y = 0
    , rotate = 2 * pi
    , scale = 1
    }

detailsToString details =
    "translate("
        ++ String.fromFloat details.x
        ++ "px, "
        ++ String.fromFloat details.y
        ++ "px) rotate("
        ++ String.fromFloat details.rotate
        ++ "rad) scale("
        ++ String.fromFloat details.scale
        ++ ")"
                


transforms : Benchmark
transforms =
    let
        details =
            Internal.emptyDetails
    in
    Benchmark.describe "transforms"
        [ Benchmark.benchmark "array" (\_ -> transformToString initTransform)
        , Benchmark.benchmark "record" 
            (\_ -> 
                detailsToString transformRecord
            )

       

       
        ]



record : Benchmark
record =
    let
        details =
            Internal.emptyDetails
    in
    Benchmark.describe "record"
        [ Benchmark.benchmark "get" (\_ -> details.spacingY)
        , Benchmark.benchmark "insert" 
            (\_ -> 
                { details |  spacingY = 10 }
            )

        , Benchmark.benchmark "insert - full copy" 
            (\_ -> 
                { name = details.name
                    , node = details.node
                    , spacingX = details.spacingX
                    , spacingY = 10
                    , fontSize = details.fontSize
                    , fontOffset = details.fontOffset
                    , fontHeight =
                        details.fontHeight
                    , heightFill = details.heightFill
                    , widthFill = details.widthFill
                    , padding = details.padding
                    , borders = details.borders
                   , transform = details.transform
                    , animEvents = details.animEvents
                    , hover = details.hover
                    , focus = details.focus
                    , active = details.active
                    }


            )
        ]



attrsStatic =
    [ Ui.Font.color (Ui.rgb 0 255 0)
    , Ui.Background.color (Ui.rgb 0 255 0)
    , Ui.Font.size 24
    , Ui.width (Ui.fill)
    , Ui.height (Ui.fill)
   
    , Ui.Background.gradient 
        (Ui.Gradient.linear Ui.right
            [ Ui.Gradient.percent 0 (Ui.rgb 0 255 0)
            , Ui.Gradient.percent 0 (Ui.rgb 255 255 0)

            ]


        )
    ]



rendering =
    Benchmark.describe "Rendering"
        [ Benchmark.benchmark "Standard" 
            (\_ ->
                let
                    attrs =
                        [ Ui.Font.color (Ui.rgb 0 255 0)
                        , Ui.Background.color (Ui.rgb 0 255 0)
                        , Ui.Font.size 24
                        , Ui.width (Ui.fill)
                        , Ui.height (Ui.fill)
                       
                        , Ui.Background.gradient 
                            (Ui.Gradient.linear Ui.right
                                [ Ui.Gradient.percent 0 (Ui.rgb 0 255 0)
                                , Ui.Gradient.percent 0 (Ui.rgb 255 255 0)

                                ]


                            )
                        ]
                in

                Ui.row attrs
                    [ Ui.el ( attrs) (Ui.text "Hello!")
                    , Ui.el attrs (Ui.text "Hello!")


                    ]


            )

        , Benchmark.benchmark "New 3"
            (\_ -> 
                Internal.element Internal.AsRow
                    attrsStatic
                    [ Internal.element Internal.AsEl
                        attrsStatic
                        [ Internal.text "Hello!"
                        ]
                    , Internal.element Internal.AsEl
                        attrsStatic
                        [ Internal.text "Hello!"
                        ]

                    ]
            
            )

        ]
