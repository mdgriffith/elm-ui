module Main exposing (main)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Input exposing (labelAbove, multiline)
import Html exposing (Html)
import Html.Events exposing (onClick)


type alias Model =
    { count : Int }


initialModel : Model
initialModel =
    { count = 0 }


type Msg
    = Increment
    | Decrement
    | MLChanged String


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            { model | count = model.count + 1 }

        Decrement ->
            { model | count = model.count - 1 }

        MLChanged s ->
            model


testtxt =
    "orem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.  Why do we use it?"


testtxtnewlines =
    """orem Ipsum is simply dummy text of the printing 
and typesetting industry. Lorem Ipsum has been the industry's 
standard dummy text ever since the 1500s, when an unknown 
printer took a galley of type and scrambled it to make a type specimen book. 
It has survived not only five centuries, but also the leap into electronic 
typesetting

, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.  Why do we use it?"""


view : Model -> Html Msg
view model =
    layout [] <|
        column
            [ width (px 1200)
            , padding 100
            , spacing 50
            , centerX
            ]
            [ column
                [ width (px 700)
                , padding 100
                , spacing 50
                , centerX
                ]
                [ multiline [ spacing 3 ]
                    { onChange = MLChanged
                    , text = testtxt
                    , placeholder = Nothing
                    , spellcheck = False
                    , label =
                        labelAbove
                            [ width (px 100)
                            , Background.color (Element.rgb 0.5 0.5 0.5)
                            ]
                        <|
                            text "Default height"
                    }
                , multiline [ spacing 0, padding 10, height shrink ]
                    { onChange = MLChanged
                    , text = testtxt
                    , placeholder = Nothing
                    , spellcheck = False
                    , label =
                        labelAbove
                            [ Background.color (Element.rgb 0.5 0.5 0.5)
                            , width (px 100)
                            ]
                        <|
                            text "Shrink - no nl"
                    }
                , multiline [ spacing 3, height shrink ]
                    { onChange = MLChanged
                    , text = testtxtnewlines
                    , placeholder = Nothing
                    , spellcheck = False
                    , label = labelAbove [ Background.color (Element.rgb 0.5 0.5 0.5), width (px 100) ] <| text "Shrink - w/nl"
                    }
                ]
            , row [ width fill, height (px 400), spacing 40 ]
                [ multiline [ spacing 3 ]
                    { onChange = MLChanged
                    , text = testtxt
                    , placeholder = Nothing
                    , spellcheck = False
                    , label =
                        labelAbove
                            [ width (px 100)
                            , Background.color (Element.rgb 0.5 0.5 0.5)
                            ]
                        <|
                            text "Default height"
                    }
                , multiline [ spacing 0, padding 10, height shrink ]
                    { onChange = MLChanged
                    , text = testtxt
                    , placeholder = Nothing
                    , spellcheck = False
                    , label =
                        labelAbove
                            [ Background.color (Element.rgb 0.5 0.5 0.5)
                            , width (px 100)
                            ]
                        <|
                            text "Shrink - no nl"
                    }
                , multiline [ spacing 3, height shrink ]
                    { onChange = MLChanged
                    , text = testtxtnewlines
                    , placeholder = Nothing
                    , spellcheck = False
                    , label = labelAbove [ Background.color (Element.rgb 0.5 0.5 0.5), width (px 100) ] <| text "Shrink - w/nl"
                    }
                ]
            , row
                [ width fill
                , height (px 400)
                , spacing 40
                , Border.width 1
                ]
                [ multiline [ padding 20, spacing 20, height fill ]
                    { onChange = MLChanged
                    , text = testtxt
                    , placeholder = Nothing
                    , spellcheck = False
                    , label =
                        labelAbove
                            [ width (px 100)
                            , Background.color (Element.rgb 0.5 0.5 0.5)
                            ]
                        <|
                            text "Default height"
                    }
                , multiline [ spacing 0, padding 10, height shrink ]
                    { onChange = MLChanged
                    , text = testtxt
                    , placeholder = Nothing
                    , spellcheck = False
                    , label =
                        labelAbove
                            [ Background.color (Element.rgb 0.5 0.5 0.5)
                            , width (px 100)
                            ]
                        <|
                            text "Shrink - no nl"
                    }
                , multiline [ spacing 3, height shrink ]
                    { onChange = MLChanged
                    , text = testtxtnewlines
                    , placeholder = Nothing
                    , spellcheck = False
                    , label = labelAbove [ Background.color (Element.rgb 0.5 0.5 0.5), width (px 100) ] <| text "Shrink - w/nl"
                    }
                ]
            , row
                [ width fill
                , height (px 800)
                , spacing 40
                , Border.width 1
                ]
                [ multiline [ spacing 3, height fill ]
                    { onChange = MLChanged
                    , text = testtxt
                    , placeholder = Nothing
                    , spellcheck = False
                    , label =
                        labelAbove
                            [ width (px 100)
                            , Background.color (Element.rgb 0.5 0.5 0.5)
                            ]
                        <|
                            text "Default height"
                    }
                , multiline [ spacing 0, padding 10, height shrink ]
                    { onChange = MLChanged
                    , text = testtxt
                    , placeholder = Nothing
                    , spellcheck = False
                    , label =
                        labelAbove
                            [ Background.color (Element.rgb 0.5 0.5 0.5)
                            , width (px 100)
                            ]
                        <|
                            text "Shrink - no nl"
                    }
                , multiline [ spacing 3, height shrink ]
                    { onChange = MLChanged
                    , text = testtxtnewlines
                    , placeholder = Nothing
                    , spellcheck = False
                    , label = labelAbove [ Background.color (Element.rgb 0.5 0.5 0.5), width (px 100) ] <| text "Shrink - w/nl"
                    }
                ]
            ]


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
