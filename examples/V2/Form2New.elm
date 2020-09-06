module Form2New exposing (..)

{-| -}

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Element2
import Element2.Background as Background2
import Element2.Border as Border2
import Element2.Font as Font2
import Element2.Input as Input2
import Element2.Region as Region2
import Html


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
    case Debug.log "Test msg" msg of
        Update new ->
            new


type Lunch
    = Burrito
    | Taco
    | Gyro


box =
    Element2.el
        [ Background2.color red2
        , Element2.width (Element2.px 200)
        , Element2.height (Element2.px 50)
        ]
        Element2.none


blueBox =
    Element2.el
        [ Background2.color blue2
        , Element2.width
            (Element2.fill
                |> Element2.minimum 200
            )
        , Element2.height
            (Element2.fill
                |> Element2.minimum 20
            )
        ]
        Element2.none


view model =
    Html.div []
        [ Element2.layout
            [ Font2.size 20
            ]
          <|
            Element2.column
                [ Element2.width (Element2.px 800)
                , Element2.centerY
                , Element2.centerX
                , Element2.spacing 36
                , Element2.padding 10
                ]
                [ Element2.el
                    [ Region2.heading 1
                    , Element2.alignLeft
                    , Font2.size 36
                    ]
                    (Element2.text "New Stylish")
                , Element2.el
                    [ Border2.width 5
                    , Element2.onRight box
                    , Element2.inFront blueBox
                    , Element2.below blueBox
                    ]
                    box
                , Element2.wrappedRow
                    [ Element2.spacing 36
                    , Element2.padding 10
                    , Border2.width 2
                    ]
                    [ box
                    , box
                    , box
                    , box
                    ]
                , Input2.text
                    [ Element2.spacing 12
                    , Border2.width 2
                    , Element2.padding 24
                    , Element2.below
                        (Element2.el
                            [ Font2.color red2
                            , Font2.size 14
                            , Element2.alignRight
                            , Element2.moveDown 6
                            ]
                            (Element2.text "This one is wrong")
                        )
                    ]
                    { text = model.username
                    , placeholder = Just (Input2.placeholder [] (Element2.text "username"))
                    , onChange = \new -> Update { model | username = new }
                    , label = Input2.labelAbove [ Font2.size 14 ] (Element2.text "Username")
                    }
                , Input2.multiline
                    [ Element2.height Element2.shrink
                    , Element2.spacing 12

                    -- , padding 6
                    ]
                    { text = model.comment
                    , placeholder = Just (Input2.placeholder [] (Element2.text "Extra hot sauce?\n\n\nYes pls"))
                    , onChange = \new -> Update { model | comment = new }
                    , label = Input2.labelAbove [ Font2.size 14 ] (Element2.text "Leave a comment!")
                    , spellcheck = False
                    }
                , Input2.text
                    []
                    { text = model.username
                    , placeholder = Just (Input2.placeholder [] (Element2.text "username"))
                    , onChange = \new -> Update { model | username = new }
                    , label = Input2.labelAbove [ Font2.size 14 ] (Element2.text "Username")
                    }
                , Input2.multiline
                    []
                    { text = model.comment
                    , placeholder = Just (Input2.placeholder [] (Element2.text "Extra hot sauce?\n\n\nYes pls"))
                    , onChange = \new -> Update { model | comment = new }
                    , label = Input2.labelAbove [ Font2.size 14 ] (Element2.text "Leave a comment!")
                    , spellcheck = False
                    }
                , Input2.sliderX
                    [ Element2.behindContent
                        (Element2.el
                            [ Element2.width Element2.fill
                            , Element2.height (Element2.px 2)
                            , Element2.centerY
                            , Background2.color grey2
                            , Border2.rounded 2
                            ]
                            Element2.none
                        )
                    ]
                    { onChange = \spiciness -> Update { model | spiciness = spiciness }
                    , label =
                        Input2.labelAbove []
                            (Element2.text
                                ("Spiciness: " ++ String.fromFloat model.spiciness)
                            )
                    , min = 0
                    , max = 75
                    , step = Nothing
                    , value = model.spiciness
                    , thumb =
                        Input2.defaultThumb
                    }
                , Input2.sliderY
                    [ Element2.behindContent
                        (Element2.el
                            [ Element2.height Element2.fill
                            , Element2.width (Element2.px 2)
                            , Element2.centerX
                            , Background2.color grey2
                            , Border2.rounded 2
                            ]
                            Element2.none
                        )
                    ]
                    { onChange = \spiciness -> Update { model | spiciness = spiciness }
                    , label =
                        Input2.labelAbove []
                            (Element2.text
                                ("Spiciness: " ++ String.fromFloat model.spiciness)
                            )
                    , min = 0
                    , max = 75
                    , step = Nothing
                    , value = model.spiciness
                    , thumb =
                        Input2.defaultThumb
                    }
                , Input2.radio
                    [ Element2.spacing 12
                    , Background2.color grey2
                    ]
                    { selected = Just model.lunch
                    , onChange = \new -> Update { model | lunch = new }
                    , label =
                        Input2.labelAbove
                            [ Font2.size 14
                            , Element2.paddingXY 0 12
                            ]
                            (Element2.text "What would you like for lunch?")
                    , options =
                        [ Input2.option Gyro (Element2.text "Gyro")
                        , Input2.option Burrito (Element2.text "Burrito")
                        , Input2.option Taco (Element2.text "Taco")
                        ]
                    }
                , Element2.el [ Element2.height (Element2.px 200) ] Element2.none
                ]
        ]


white2 =
    Element2.rgb 255 255 255


grey2 =
    Element2.rgb (round <| 255 * 0.9) (round <| 255 * 0.9) (round <| 255 * 0.9)


blue2 =
    Element2.rgb 0 0 (round <| 255 * 0.8)


red2 =
    Element2.rgb (round <| 255 * 0.8) 0 0


darkBlue2 =
    Element2.rgb 0 0 (round <| 255 * 0.9)
