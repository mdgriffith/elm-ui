module Clip exposing (main)

import Element2 exposing (..)
import Element2.Background as Background
import Element2.Border as Border
import Element2.Font as Font
import Html


main : Html.Html msg
main =
    layout
        [ -- Font.familyWith
          -- { name = "EB Garamond"
          -- , fallback = [ Font.serif ]
          -- , sizing =
          --     Font.byCapital
          --         { capital = 1.09
          --         , lowercase = 0.81
          --         , baseline = 0.385
          --         , descender = 0.095
          --         -- , lineHeight = 1.5
          --         }
          -- , variants =
          --     []
          -- }
          Font.size 20
        ]
    <|
        -- column [ spacing 20 ]
        --     [ el
        --         [ Background.color <| rgb 255 135 255
        --         , padding 20
        --         , clip
        --         -- , height (shrink |> minimum 200)
        --         ]
        --       <|
        --         text "This is a test"
        --     ]
        column [ spacing 50, width (px 600) ]
            [ row [ spacing 20, Border.width 1, width fill, Border.rounded 3 ]
                [ el
                    [ Background.color <| rgb 255 135 255
                    , padding 20
                    -- , clip
                    , width fill
                    -- , ellip
                    , Font.gradient 
                        { steps = []
                        , angle = 5
                        }
                    ]
                  <|
                    text "This is a test"
                , el
                    [ Background.color <| rgb 255 135 255
                    , padding 20
                    , clip

                    -- , width (fill |> maximum 200)
                    , width (portion 3)
                    , ellip
                    ]
                  <|
                    text "This is a test, something much longer than the other one"
                ]
            , row [ spacing 20, Border.width 1, width fill, Border.rounded 3 ]
                [ el
                    [ Background.color <| rgb 255 135 255
                    , padding 20
                    , clip
                    , width fill
                    , ellip
                    ]
                  <|
                    text "This is a test"
                , el
                    [ Background.color <| rgb 255 135 255
                    , padding 20
                    , clip
                    , width (fill |> maximum 200)

                    -- , width fill
                    , ellip
                    ]
                  <|
                    text "This is a test, something much longer than the other one"
                ]

          , row [ spacing 20, Border.width 1, width fill, Border.rounded 3 ]
                [ el
                    [ Background.color <| rgb 255 135 255
                    , padding 20
                    -- , clip
                    -- , width fill
                    -- , ellip
                    ]
                  <|
                    text "This is a test?"
                , el
                    [ Background.color <| rgb 255 135 255
                    , padding 20
                    -- , clip
                    -- , width (fill |> maximum 200)

                    , width fill
                    -- , ellip
                    ]
                  <|
                    text "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
                ]

             
            , column
                [ spacing 20, Border.width 1, width fill, Border.rounded 3 ]
                [ el
                    [ Background.color <| rgb 255 135 255
                    , padding 20
                    , clip
                    , width fill
                    , ellip
                    ]
                  <|
                    text "This is a test"
                , el
                    [ Background.color <| rgb 255 135 255
                    , padding 20
                    , clip

                    -- , width (fill |> maximum 200)
                    , width fill
                    , ellip
                    ]
                  <|
                    text "This is a test, something much longer than the other one"
                ]
            , column [ spacing 20, Border.width 1, width fill, Border.rounded 3 ]
                [ el
                    [ Background.color <| rgb 255 135 255
                    , padding 20
                    , clip
                    , width fill
                    , ellip
                    ]
                  <|
                    text "This is a test"
                , el
                    [ Background.color <| rgb 255 135 255
                    , padding 20
                    , clip
                    , width (fill |> maximum 200)

                    -- , width fill
                    , ellip
                    ]
                  <|
                    text "This is a test, something much longer than the other one"
                ]
            , row [ spacing 40, width fill ]
                [ column [ spacing 20, height (px 500), Border.width 1, width fill, Border.rounded 3 ]
                    [ el
                        [ Background.color <| rgb 255 135 255
                        , padding 20

                        -- , clip
                        , width fill
                        , height fill
                        , ellip
                        ]
                      <|
                        text "This is a test"
                    , el
                        [ Background.color <| rgb 255 135 255
                        , padding 20

                        -- , clip
                        , width (fill |> maximum 200)
                        , height (portion 3)

                        -- , width fill
                        -- , ellip
                        ]
                      <|
                        text "This is a test, something much longer than the other one"
                    ]
                , column [ spacing 20, height (px 500), Border.width 1, width fill, Border.rounded 3 ]
                    [ el
                        [ Background.color <| rgb 255 135 255

                        -- , padding 20
                        -- , clip
                        , width fill
                        , height fill
                        , ellip
                        ]
                      <|
                        text "This is a test"
                    , el
                        [ Background.color <| rgb 255 135 255

                        -- , padding 20
                        -- , clip
                        , width (fill |> maximum 200)
                        , height (portion 3)

                        -- , width fill
                        -- , ellip
                        ]
                      <|
                        text "This is a test, something much longer than the other one"
                    ]
                , column [ spacing 20, height (px 500), Border.width 1, width fill, Border.rounded 3 ]
                    [ el
                        [ width fill
                        , height fill
                        ]
                      <|
                        el
                            [ Background.color <| rgb 255 135 255
                            , padding 20

                            -- , clip
                            , width fill
                            , height fill
                            , ellip
                            ]
                        <|
                            text "This is a test"
                    , el
                        [ width (fill |> maximum 200)
                        , height (portion 3)
                        ]
                      <|
                        el
                            [ Background.color <| rgb 255 135 255
                            , padding 20

                            -- , clip
                            , width (fill |> maximum 200)
                            , height (portion 3)

                            -- , width fill
                            -- , ellip
                            ]
                        <|
                            text "This is a test, something much longer than the other one"
                    ]
                ]
            , column [ spacing 40, width fill ]
                [ row [ spacing 20, height (px 500), Border.width 1, width fill, Border.rounded 3 ]
                    [ el
                        [ Background.color <| rgb 255 135 255
                        , padding 20

                        -- , clip
                        , width fill
                        , height fill
                        , ellip
                        ]
                      <|
                        text "This is a test"
                    , el
                        [ Background.color <| rgb 255 135 255
                        , padding 20

                        -- , clip
                        , width (portion 3)
                        , height (portion 3)

                        -- , width fill
                        -- , ellip
                        ]
                      <|
                        text "This is a test, something much longer than the other one"
                    ]
                , row [ spacing 20
                      , height (px 500)
                      , Border.width 1
                      , width fill
                      , Border.rounded 3 
                      ]
                      [ el
                          [ Background.color <| rgb 255 135 255

                          -- , padding 20
                          -- , clip
                          -- , width fill
                          -- , height fill
                          , ellip
                          ]
                        <|
                          text "This is a test?!"
                      , el
                          [ Background.color <| rgb 255 135 255

                          -- , padding 20
                          -- , clip
                          -- , width (portion 3)
                          -- , height (portion 3)

                          -- , width fill
                          -- , ellip
                          ]
                        <|
                          text "This is a test, something much longer than the other one"
                      ]
                , row [ spacing 20, height (px 500), Border.width 1, width fill, Border.rounded 3 ]
                    [ el
                        [ width fill
                        , height fill
                        ]
                      <|
                        el
                            [ Background.color <| rgb 255 135 255
                            , padding 20

                            -- , clip
                            , width fill
                            , height fill
                            , ellip
                            ]
                        <|
                            text "This is a test"
                    , el
                        [ width (portion 3)
                        , height (portion 3)
                        ]
                      <|
                        el
                            [ Background.color <| rgb 255 135 255
                            , padding 20

                            -- , clip
                            , width (portion 3)
                            , height (portion 3)

                            -- , width fill
                            -- , ellip
                            ]
                        <|
                            text "This is a test, something much longer than the other one"
                    ]
                ]
            , column [ spacing 20 ]
                [ el
                    [ Background.color <| rgb 255 135 255
                    , padding 20
                    , clip
                    ]
                  <|
                    text "This is a test"
                ]
            , row [ spacing 20 ]
                [ el
                    [ Background.color <| rgb 255 135 255
                    , padding 20
                    , clip
                    ]
                  <|
                    text "This is a test"
                ]
            ]
