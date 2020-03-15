module Main exposing (main)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input exposing (labelAbove, multiline)
import Html exposing (Html)
import Html.Events exposing (onClick)


type alias Model =
    { multiline : String
    , single : String
    }


initialModel : Model
initialModel =
    { multiline = testtxt
    , single = ""
    }


type Msg
    = MultilineChanged String
    | SingleChanged String


update : Msg -> Model -> Model
update msg model =
    case msg of
        MultilineChanged new ->
            { model | multiline = new }

        SingleChanged new ->
            { model | single = new }


examplePlaceholder =
    Input.placeholder [ Font.color (rgb 0.2 0.2 0.8) ] (text "My placeholder...")


examplePlaceholderLong =
    Input.placeholder [ Font.color (rgb 0.2 0.2 0.8) ] (text "My placeholderMy placeholderMy placeholderMy placeholderMy placeholderMy placeholderMy placeholderMy placeholder...")


background =
    Background.color (rgb 0 1 0)


testtxt =
    """orem Ipsum is simply dummy text of the printing 
and typesetting industry. Lorem Ipsum has been the industry's 
standard dummy text ever since the 1500s, when an unknown 
printer took a galley of type and scrambled it to make a type specimen book. 
It has survived not only five centuries, but also the leap into electronic 
typesetting

, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.  Why do we use it?"""


rowTest header els =
    column [ width fill, spacing 24 ]
        [ el [] (text header)
        , row
            [ width fill
            , height (px 800)
            , spacing 50
            , centerX
            , Border.width 1
            ]
            els
        ]


label str =
    labelAbove
        [ width (px 100)
        , Font.italic
        ]
        (text str)


view : Model -> Html Msg
view model =
    layout [] <|
        column []
            [ el [ Font.size 32 ] (text "Single Input")
            , viewSingle model
            , el [ Font.size 32 ] (text "Multiline")
            , viewMultiline model
            ]


viewMultiline model =
    column
        [ width (px 1500)
        , padding 100
        , spacing 500
        , centerX
        ]
        [ rowTest "Heights"
            [ multiline [ background ]
                { onChange = MultilineChanged
                , text = model.multiline
                , placeholder = Nothing
                , spellcheck = False
                , label =
                    label "Default"
                }
            , multiline [ background, height shrink ]
                { onChange = MultilineChanged
                , text = model.multiline
                , placeholder = Nothing
                , spellcheck = False
                , label =
                    label "Height shrink"
                }
            , multiline [ background, height fill ]
                { onChange = MultilineChanged
                , text = model.multiline
                , placeholder = Nothing
                , spellcheck = False
                , label =
                    label "Height Fill"
                }
            , multiline [ background, height (px 200) ]
                { onChange = MultilineChanged
                , text = model.multiline
                , placeholder = Nothing
                , spellcheck = False
                , label =
                    label "Height 200px"
                }
            ]
        , rowTest "Widths"
            [ multiline []
                { onChange = MultilineChanged
                , text = model.multiline
                , placeholder = Nothing
                , spellcheck = False
                , label =
                    label "Default"
                }
            , multiline [ width fill ]
                { onChange = MultilineChanged
                , text = model.multiline
                , placeholder = Nothing
                , spellcheck = False
                , label =
                    label "Width fill"
                }
            , multiline [ width shrink ]
                { onChange = MultilineChanged
                , text = model.multiline
                , placeholder = Nothing
                , spellcheck = False
                , label =
                    label "Width Shrink"
                }
            , multiline [ width (px 300) ]
                { onChange = MultilineChanged
                , text = model.multiline
                , placeholder = Nothing
                , spellcheck = False
                , label = label "width 300"
                }
            ]
        , rowTest "Spacing"
            [ multiline []
                { onChange = MultilineChanged
                , text = model.multiline
                , placeholder = Nothing
                , spellcheck = False
                , label =
                    label "Default"
                }
            , multiline [ spacing 30, padding 60 ]
                { onChange = MultilineChanged
                , text = model.multiline
                , placeholder = Nothing
                , spellcheck = False
                , label =
                    label "Spacing 30"
                }
            , multiline [ spacing 0 ]
                { onChange = MultilineChanged
                , text = model.multiline
                , placeholder = Nothing
                , spellcheck = False
                , label = label "Spacing 0"
                }
            ]
        , rowTest "Scrollable viewport with different paddings "
            [ multiline [ height (px 200), padding 30 ]
                { onChange = MultilineChanged
                , text = model.multiline
                , placeholder = Nothing
                , spellcheck = False
                , label =
                    label "Height 200, Padding 30"
                }
            , multiline [ height (px 200), padding 60 ]
                { onChange = MultilineChanged
                , text = model.multiline
                , placeholder = Nothing
                , spellcheck = False
                , label =
                    label "Height 200, Padding 60"
                }
            , multiline [ height (px 200), padding 0 ]
                { onChange = MultilineChanged
                , text = model.multiline
                , placeholder = Nothing
                , spellcheck = False
                , label = label "Height 200, Padding 0"
                }
            ]
        , rowTest "Placeholders"
            [ multiline []
                { onChange = MultilineChanged
                , text = ""
                , placeholder = Just examplePlaceholder
                , spellcheck = False
                , label =
                    label "Default"
                }
            , multiline [ height shrink ]
                { onChange = MultilineChanged
                , text = ""
                , placeholder = Just examplePlaceholder
                , spellcheck = False
                , label =
                    label "Height shrink"
                }
            , multiline [ height fill ]
                { onChange = MultilineChanged
                , text = ""
                , placeholder = Just examplePlaceholder
                , spellcheck = False
                , label =
                    label "Height Fill"
                }
            , multiline [ height (px 200) ]
                { onChange = MultilineChanged
                , text = ""
                , placeholder = Just examplePlaceholder
                , spellcheck = False
                , label =
                    label "Height 200px"
                }
            ]
        , rowTest "Long Placeholders"
            [ multiline []
                { onChange = MultilineChanged
                , text = ""
                , placeholder = Just examplePlaceholderLong
                , spellcheck = False
                , label =
                    label "Default"
                }
            , multiline [ height shrink ]
                { onChange = MultilineChanged
                , text = ""
                , placeholder = Just examplePlaceholderLong
                , spellcheck = False
                , label =
                    label "Height shrink"
                }
            , multiline [ height fill ]
                { onChange = MultilineChanged
                , text = ""
                , placeholder = Just examplePlaceholderLong
                , spellcheck = False
                , label =
                    label "Height Fill"
                }
            , multiline [ height (px 200) ]
                { onChange = MultilineChanged
                , text = ""
                , placeholder = Just examplePlaceholderLong
                , spellcheck = False
                , label =
                    label "Height 200px"
                }
            ]
        ]


singleInput attrs labelTxt model =
    Input.text attrs
        { onChange = SingleChanged
        , text = model
        , label =
            labelAbove
                [ width (px 100)
                , Font.italic
                ]
                (text labelTxt)
        , placeholder =
            Just
                (Input.placeholder [ Font.color (rgb 0.8 0.8 0.8) ]
                    (text "Here is my single input")
                )
        }


singleInputLongPlaceholder attrs labelTxt model =
    Input.text attrs
        { onChange = SingleChanged
        , text = model
        , label =
            labelAbove
                [ width (px 100)
                , Font.italic
                ]
                (text labelTxt)
        , placeholder =
            Just
                (Input.placeholder [ Font.color (rgb 0.8 0.8 0.8) ]
                    (text "Here is my single input with a placeholder that is super long")
                )
        }


viewSingle model =
    column
        [ width (px 1500)
        , padding 100
        , spacing 500
        , centerX
        ]
        [ rowTest "Heights"
            [ singleInput [] "Default" model.single
            , singleInput [ height shrink ] "Height shrink" model.single
            , singleInput [ height fill ] "Height Fill" model.single
            , singleInput [ height (px 200) ] "Height 200px" model.single
            ]
        , rowTest "Widths"
            [ singleInput [] "Default" model.single
            , singleInput [ width fill ] "Width fill" model.single
            , singleInput [ width shrink ] "Width Shrink" model.single
            , singleInput [ width (px 200) ] "width 200" model.single
            ]
        , rowTest "Spacing (no effect)"
            [ singleInput [] "Default" model.single
            , singleInput [ spacing 60 ] "Spacing 30" model.single
            , singleInput [ spacing 0 ] "Spacing 0" model.single
            ]
        , rowTest "Padding"
            [ singleInput [] "Default" model.single
            , singleInput [ padding 60 ] "Padding 30" model.single
            , singleInput [ padding 0 ] "Padding 0" model.single
            ]
        , rowTest "Scrollable viewport with different paddings "
            [ singleInput [ height (px 200), padding 30 ] "Height 200, Padding 30" model.single
            , singleInput [ height (px 200), padding 60 ] "Height 200, Padding 60" model.single
            , singleInput [ height (px 200), padding 0 ] "Height 200, Padding 0" model.single
            ]
        , rowTest "Long Placeholders"
            [ singleInputLongPlaceholder [] "Default" model.single
            , singleInputLongPlaceholder [ height shrink ] "Height shrink" model.single
            , singleInputLongPlaceholder [ height fill ] "Height Fill" model.single
            , singleInputLongPlaceholder [ height (px 200) ] "Height 200px" model.single
            ]
        ]


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
