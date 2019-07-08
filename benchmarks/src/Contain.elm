module Contain exposing
    ( viewHtml8192
    , viewHtmlContain8192
    )

{-| -}

import Benchmark.Render
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Keyed
import Html
import Html.Attributes
import Internal.Model as Internal


type alias Model =
    { index : Int
    , numberOfElements : Int
    , elements : List Int
    }


type Msg
    = Refresh
    | Tick Float


viewHtml8192 : Benchmark.Render.Benchmark Model Msg
viewHtml8192 =
    viewHtml "viewHtml8192" 8192


viewHtmlContain8192 : Benchmark.Render.Benchmark Model Msg
viewHtmlContain8192 =
    viewHtmlContain "viewHtmlContain8192" 8192


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
        [ Html.Attributes.class "box"
        , Html.Attributes.class
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


{-| -}
viewHtmlContain : String -> Int -> Benchmark.Render.Benchmark Model Msg
viewHtmlContain name count =
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
                    (List.map (viewHtmlElementContain model.index) model.elements)
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


viewHtmlElementContain selectedIndex index =
    Html.div
        [ Html.Attributes.class "box contain"
        , Html.Attributes.class
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
