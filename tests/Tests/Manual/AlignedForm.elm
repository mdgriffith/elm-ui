module Main exposing (..)

{-| -}

import Tests.Palette as Palette exposing (..)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Html


main =
    Html.program
        { init = ( init, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


init =
    { username = ""
    , password = ""
    , agreeTOS = False
    , comment = ""
    , lunch = Gyro
    }


type alias Form =
    { username : String
    , password : String
    , agreeTOS : Bool
    , comment : String
    , lunch : Lunch
    }


type Msg
    = Update Form


update msg model =
    case Debug.log "msg" msg of
        Update new ->
            ( new, Cmd.none )


type Lunch
    = Burrito
    | Taco
    | Gyro


view model =
    let
        label str =
            Input.labelLeft
                [ width (fillPortion 1)
                , Font.alignRight
                , paddingXY 12 7
                , Font.bold
                , focused
                    [ Background.color blue
                    , Font.size 40
                    , Font.color white
                    ]
                ]
                (text str)

        testRadio =
            Input.radio
                [ width (fillPortion 4)
                , transparent True
                , spacing 15
                , focused
                    [ transparent False
                    ]
                ]
                { selected = Just model.lunch
                , onChange = Just (\new -> Update { model | lunch = new })
                , label =
                    Input.labelAbove
                        [ transparent True
                        , focused
                            [ transparent False
                            ]
                        ]
                        (text "What would you like for lunch?")
                , options =
                    [ Input.option Gyro (text "Gyro")
                    , Input.option Burrito (text "Burrito")
                    , Input.option Taco (text "Taco")
                    ]
                }
    in
    Element.layout
        [ Font.size 20
        ]
    <|
        Element.column
            [ width (px 800)
            , height shrink
            , centerY
            , centerX
            , spacing 36
            , padding 10
            ]
            [ el
                [ Region.heading 1
                , alignLeft
                , Font.size 36

                -- , above True
                --     [ focused
                --         [ transparent False ]
                --     ]
                --     (text "show me")
                -- , mouseOver
                --     [ Font.size 36
                --     , above True
                --         (el
                --             [ Font.color red
                --             , Font.size 14
                --             , alignLeft
                --             ]
                --             (text "This one is le wrong")
                --         )
                --     -- Decoration.backgroundColor Color.blue
                --     -- , Decoration.fontSize 40
                --     -- , Decoration.fontColor Color.white
                --     ]
                , above True
                    (el
                        [ Font.color red
                        , Font.size 14
                        , alignLeft
                        ]
                        (text "This one is le wrong")
                    )

                -- [ Decoration.fontSize 40
                -- , Decoration.backgroundColor Color.blue
                -- ]
                ]
                (text "Welcome to the Stylish Elephants Lunch Emporium")

            -- , Input.radioRow [ width (fillPortion 4), spacing 15 ]
            --     { selected = Just model.lunch
            --     , onChange = Just (\new -> Update { model | lunch = new })
            --     , label = label "What would you like for lunch?"
            --     , options =
            --         [ Input.option Gyro (text "Gyro")
            --         , Input.option Burrito (text "Burrito")
            --         , Input.option Taco (text "Taco")
            --         ]
            --     }
            -- , Input.username
            --     [ width (fillPortion 4)
            --     , focused
            --         [ Decoration.backgroundColor Color.blue
            --         , Decoration.fontSize 40
            --         , Decoration.fontColor Color.white
            --         ]
            --     , below True
            --         (el
            --             [ Font.color red
            --             , Font.size 14
            --             , alignLeft
            --             ]
            --             (text "This one is le wrong")
            --         )
            --     ]
            --     { text = model.username
            --     , placeholder = Nothing --Just (Input.placeholder [] (text "Extra hot sauce?"))
            --     , onChange = Just (\new -> Update { model | username = new })
            --     , label =
            --         Input.labelAbove
            --             []
            --             (text "username")
            --     }
            -- , Input.username
            --     [ below True
            --         (el
            --             [ Font.color red
            --             , Font.size 14
            --             , alignLeft
            --             ]
            --             (text "This one is le wrong")
            --         )
            --     , width (fillPortion 4)
            --     -- , Decoration.focused
            --     --     [ Decoration.backgroundColor Color.blue
            --     --     , Decoration.fontSize 40
            --     --     , Decoration.fontColor Color.white
            --     --     ]
            --     ]
            --     { text = model.username
            --     , placeholder = Nothing --Just (Input.placeholder [] (text "Extra hot sauce?"))
            --     , onChange = Just (\new -> Update { model | username = new })
            --     , label =
            --         Input.labelAbove
            --             [ moveDown 30
            --             , Font.size 20
            --             , Decoration.focused
            --                 [ Decoration.fontSize 15
            --                 , Decoration.moveUp 500
            --                 ]
            --             ]
            --             (text "Username")
            --     }
            -- , Input.currentPassword [ width (fillPortion 4) ]
            --     { text = model.password
            --     , placeholder = Nothing
            --     , onChange = Just (\new -> Update { model | password = new })
            --     , label = label "Password"
            --     , show = False
            --     }
            , Input.multiline
                [ height shrink
                , width (fillPortion 4)
                , below True
                    (el
                        [ Font.color red
                        , Font.size 14
                        , alignLeft
                        ]
                        (text "This one is le wrong")
                    )
                ]
                { text = model.comment
                , placeholder = Just (Input.placeholder [] (text "Extra hot sauce?"))
                , onChange = Just (\new -> Update { model | comment = new })
                , label =
                    Input.labelLeft
                        [ width (fillPortion 1)
                        , Font.alignRight
                        , Font.bold
                        , transparent True
                        , paddingXY 12 7
                        , focused
                            [ Background.color blue
                            , Font.size 40
                            , Font.color white
                            ]
                        ]
                        (text "Question")
                , spellcheck = False
                }

            -- , testRadio
            , Element.row
                [ Font.bold
                , alignLeft
                , below True <|
                    testRadio
                ]
                [ el [ alignLeft, Font.bold ] <| text "Selection"
                ]

            -- , Element.row []
            --     [ Element.el [ Element.width Element.fill ] Element.none
            --     , Input.checkbox
            --         [ width (fillPortion 4) ]
            --         { checked = model.agreeTOS
            --         , onChange = Just (\new -> Update { model | agreeTOS = new })
            --         , icon = Nothing
            --         , label = Input.labelRight [] (text "Agree to Terms of Service")
            --         }
            --     ]
            -- , Input.button
            --     [ Background.color blue
            --     , Font.color white
            --     , Border.color darkBlue
            --     , paddingXY 15 5
            --     , Border.rounded 3
            --     , alignLeft
            --     -- , width fill
            --     ]
            --     { onPress = Nothing
            --     , label = Element.text "Place your lunch order!"
            --     }
            ]
