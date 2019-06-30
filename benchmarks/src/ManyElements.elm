module ManyElements exposing
    ( elmUI1024
    , elmUI128
    , elmUI2048
    , elmUI24
    , elmUI256
    , elmUI4096
    , elmUI512
    , elmUI64
    , elmUI8192
    , viewHtml1024
    , viewHtml128
    , viewHtml2048
    , viewHtml24
    , viewHtml256
    , viewHtml4096
    , viewHtml512
    , viewHtml64
    , viewHtml8192
    , viewInline1024
    , viewInline128
    , viewInline2048
    , viewInline24
    , viewInline256
    , viewInline4096
    , viewInline512
    , viewInline64
    , viewInline8192
    )

{-| -}

import Benchmark.Render
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Html
import Html.Attributes



{- START BENCHMARKS -}


elmUI24 : Benchmark.Render.Benchmark Model Msg
elmUI24 =
    elmUI "elmUI24" 24


elmUI64 : Benchmark.Render.Benchmark Model Msg
elmUI64 =
    elmUI "elmUI64" 64


elmUI128 : Benchmark.Render.Benchmark Model Msg
elmUI128 =
    elmUI "elmUI128" 128


elmUI256 : Benchmark.Render.Benchmark Model Msg
elmUI256 =
    elmUI "elmUI256" 256


elmUI512 : Benchmark.Render.Benchmark Model Msg
elmUI512 =
    elmUI "elmUI512" 512


elmUI1024 : Benchmark.Render.Benchmark Model Msg
elmUI1024 =
    elmUI "elmUI1024" 1024


elmUI2048 : Benchmark.Render.Benchmark Model Msg
elmUI2048 =
    elmUI "elmUI2048" 2048


elmUI4096 : Benchmark.Render.Benchmark Model Msg
elmUI4096 =
    elmUI "elmUI4096" 4096


elmUI8192 : Benchmark.Render.Benchmark Model Msg
elmUI8192 =
    elmUI "elmUI8192" 8192



{- Normal Html -}


viewHtml24 : Benchmark.Render.Benchmark Model Msg
viewHtml24 =
    viewHtml "viewHtml24" 24


viewHtml64 : Benchmark.Render.Benchmark Model Msg
viewHtml64 =
    viewHtml "viewHtml64" 64


viewHtml128 : Benchmark.Render.Benchmark Model Msg
viewHtml128 =
    viewHtml "viewHtml128" 128


viewHtml256 : Benchmark.Render.Benchmark Model Msg
viewHtml256 =
    viewHtml "viewHtml256" 256


viewHtml512 : Benchmark.Render.Benchmark Model Msg
viewHtml512 =
    viewHtml "viewHtml512" 512


viewHtml1024 : Benchmark.Render.Benchmark Model Msg
viewHtml1024 =
    viewHtml "viewHtml1024" 1024


viewHtml2048 : Benchmark.Render.Benchmark Model Msg
viewHtml2048 =
    viewHtml "viewHtml2048" 2048


viewHtml4096 : Benchmark.Render.Benchmark Model Msg
viewHtml4096 =
    viewHtml "viewHtml4096" 4096


viewHtml8192 : Benchmark.Render.Benchmark Model Msg
viewHtml8192 =
    viewHtml "viewHtml8192" 8192



{- Inline Html -}


viewInline24 : Benchmark.Render.Benchmark Model Msg
viewInline24 =
    viewInline "viewInline24" 24


viewInline64 : Benchmark.Render.Benchmark Model Msg
viewInline64 =
    viewInline "viewInline64" 64


viewInline128 : Benchmark.Render.Benchmark Model Msg
viewInline128 =
    viewInline "viewInline128" 128


viewInline256 : Benchmark.Render.Benchmark Model Msg
viewInline256 =
    viewInline "viewInline256" 256


viewInline512 : Benchmark.Render.Benchmark Model Msg
viewInline512 =
    viewInline "viewInline512" 512


viewInline1024 : Benchmark.Render.Benchmark Model Msg
viewInline1024 =
    viewInline "viewInline1024" 1024


viewInline2048 : Benchmark.Render.Benchmark Model Msg
viewInline2048 =
    viewInline "viewInline2048" 2048


viewInline4096 : Benchmark.Render.Benchmark Model Msg
viewInline4096 =
    viewInline "viewInline4096" 4096


viewInline8192 : Benchmark.Render.Benchmark Model Msg
viewInline8192 =
    viewInline "viewInline8192" 8192



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
elmUI : String -> Int -> Benchmark.Render.Benchmark Model Msg
elmUI name count =
    { name = name
    , init =
        { index = 0
        , numberOfElements = count
        , elements = List.range 0 (count - 1)
        }
    , view =
        view
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


view model =
    Element.layout []
        (Element.column [ spacing 8, centerX ]
            (List.map (viewEl model.index) model.elements)
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
        ]
        (text "Hello!")


white =
    rgb 1 1 1


pink =
    rgb255 240 0 245


{-| -}
viewHtml : String -> Int -> Benchmark.Render.Benchmark Model Msg
viewHtml name count =
    { name = name
    , init =
        { index = 0
        , numberOfElements = count
        , elements = List.range 0 (count - 1)
        }
    , view =
        \model ->
            Html.div []
                [ Html.div []
                    (List.map (viewHtmlElement model.index) model.elements)
                ]
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


viewHtmlElement selectedIndex index =
    Html.div
        [ Html.Attributes.class
            (if selectedIndex == index then
                "white"

             else
                "pink"
            )
        ]
        [ Html.text "Hello!" ]


{-| -}
viewInline : String -> Int -> Benchmark.Render.Benchmark Model Msg
viewInline name count =
    { name = name
    , init =
        { index = 0
        , numberOfElements = count
        , elements = List.range 0 (count - 1)
        }
    , view =
        \model ->
            Html.div []
                [ Html.div []
                    (List.map (viewInlineHtmlElement model.index) model.elements)
                ]
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


viewInlineHtmlElement selectedIndex index =
    Html.div
        (if selectedIndex == index then
            [ Html.Attributes.style "background-color" "rgb(240, 0, 245)"
            , Html.Attributes.style "color" "white"
            , Html.Attributes.style "padding" "24"
            ]

         else
            [ Html.Attributes.style "background-color" "white"
            , Html.Attributes.style "color" "rgb(240, 0, 245)"
            , Html.Attributes.style "padding" "24"
            ]
        )
        [ Html.text "Hello!" ]
