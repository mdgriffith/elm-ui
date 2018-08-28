module Main exposing (..)

{-| -}

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region


white =
    Element.rgb 1 1 1


grey =
    Element.rgb 0.9 0.9 0.9


blue =
    Element.rgb 0 0 0.8


red =
    Element.rgb 0.8 0 0


darkBlue =
    Element.rgb 0 0 0.9


main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }


init =
    { username = ""
    , password = ""
    , agreeTOS = False
    , comment = "Extra hot sauce?\n\n\nYes pls"
    , lunch = Gyro
    , spiciness = 2
    }


type alias Form =
    { username : String
    , password : String
    , agreeTOS : Bool
    , comment : String
    , lunch : Lunch
    , spiciness : Float
    }


type Msg
    = Update Form


update msg model =
    case Debug.log "msg" msg of
        Update new ->
            new


type Lunch
    = Burrito
    | Taco
    | Gyro


view model =
    Element.layout
        [ Font.size 20
        ]
    <|
        Element.column [ width (px 800), height shrink, centerY, centerX, spacing 36, padding 10, explain Debug.todo ]
            [ el
                [ Region.heading 1
                , alignLeft
                , Font.size 36
                ]
                (text "Welcome to the Stylish Elephants Lunch Emporium")
            , Input.radio
                [ spacing 12
                , Background.color grey
                ]
                { selected = Just model.lunch
                , onChange = \new -> Update { model | lunch = new }
                , label = Input.labelAbove [ Font.size 14, paddingXY 0 12 ] (text "What would you like for lunch?")
                , options =
                    [ Input.option Gyro (text "Gyro")
                    , Input.option Burrito (text "Burrito")
                    , Input.option Taco (text "Taco")
                    ]
                }
            , Input.username
                [ spacing 12
                , below
                    (el
                        [ Font.color red
                        , Font.size 14
                        , alignRight
                        , moveDown 6
                        ]
                        (text "This one is wrong")
                    )
                ]
                { text = model.username
                , placeholder = Just (Input.placeholder [] (text "username"))
                , onChange = \new -> Update { model | username = new }
                , label = Input.labelAbove [ Font.size 14 ] (text "Username")
                }
            , Input.currentPassword [ spacing 12, width shrink ]
                { text = model.password
                , placeholder = Nothing
                , onChange = \new -> Update { model | password = new }
                , label = Input.labelAbove [ Font.size 14 ] (text "Password")
                , show = False
                }
            , Input.multiline
                [ height shrink
                , spacing 12

                -- , padding 6
                ]
                { text = model.comment
                , placeholder = Just (Input.placeholder [] (text "Extra hot sauce?\n\n\nYes pls"))
                , onChange = \new -> Update { model | comment = new }
                , label = Input.labelAbove [ Font.size 14 ] (text "Leave a comment!")
                , spellcheck = False
                }
            , Input.checkbox []
                { checked = model.agreeTOS
                , onChange = \new -> Update { model | agreeTOS = new }
                , icon = Input.defaultCheckbox
                , label = Input.labelRight [] (text "Agree to Terms of Service")
                }
            , Input.slider
                [ Element.height (Element.px 30)
                , Element.behindContent
                    (Element.el
                        [ Element.width Element.fill
                        , Element.height (Element.px 2)
                        , Element.centerY
                        , Background.color grey
                        , Border.rounded 2
                        ]
                        Element.none
                    )
                ]
                { onChange = \new -> Update { model | spiciness = new }
                , label = Input.labelAbove [] (text ("Spiciness: " ++ String.fromFloat model.spiciness))
                , min = 0
                , max = 3.2
                , step = Nothing
                , value = model.spiciness
                , thumb =
                    Input.defaultThumb
                }
            , Input.slider
                [ Element.width (Element.px 40)
                , Element.height (Element.px 200)
                , Element.behindContent
                    (Element.el
                        [ Element.height Element.fill
                        , Element.width (Element.px 2)
                        , Element.centerX
                        , Background.color grey
                        , Border.rounded 2
                        ]
                        Element.none
                    )
                ]
                { onChange = \new -> Update { model | spiciness = new }
                , label = Input.labelAbove [] (text ("Spiciness: " ++ String.fromFloat model.spiciness))
                , min = 0
                , max = 3.2
                , step = Nothing
                , value = model.spiciness
                , thumb =
                    Input.defaultThumb
                }
            , Input.button
                [ Background.color blue
                , Font.color white
                , Border.color darkBlue
                , paddingXY 32 16
                , Border.rounded 3
                , width fill
                ]
                { onPress = Nothing
                , label = Element.text "Place your lunch order!"
                }
            ]
