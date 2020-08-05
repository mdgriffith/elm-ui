module Form2 exposing (..)

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
    case Debug.log "msg" msg of
        Update new ->
            new


type Lunch
    = Burrito
    | Taco
    | Gyro


box =
    el
        [ Background.color red
        , width (px 200)
        , height (px 50)
        ]
        none


view model =
    Html.div []
        [ Element.layout
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
                    ]
                    (text "Previous Form Elements")
                , wrappedRow
                    [ spacing 36
                    , padding 10
                    , Border.width 2
                    ]
                    [ box, box, box ]
                , Input.text
                    [ spacing 12
                    , padding 24
                    , below
                        (el
                            [ Font.color red
                            , Font.size 14
                            , alignRight
                            , moveDown 6
                            ]
                            (text "This one is wrong")
                        )
                    , Border.width 2
                    ]
                    { text = model.username
                    , placeholder = Just (Input.placeholder [] (text "username"))
                    , onChange = \new -> Update { model | username = new }
                    , label = Input.labelAbove [ Font.size 14 ] (text "Username")
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
                , Input.text
                    [ width (px 300) ]
                    { text = model.username
                    , placeholder = Just (Input.placeholder [] (text "username"))
                    , onChange = \new -> Update { model | username = new }
                    , label = Input.labelLeft [ Font.size 14 ] (text "Username")
                    }
                , Input.multiline
                    []
                    { text = model.comment
                    , placeholder = Just (Input.placeholder [] (text "Extra hot sauce?\n\n\nYes pls"))
                    , onChange = \new -> Update { model | comment = new }
                    , label = Input.labelAbove [ Font.size 14 ] (text "Leave a comment!")
                    , spellcheck = False
                    }
                ]

        -- , Element2.layout
        --     [ Font2.size 20
        --     ]
        --   <|
        --     Element2.column
        --         [ Element2.width (Element2.px 800)
        --         , Element2.centerY
        --         , Element2.centerX
        --         , Element2.spacing 36
        --         , Element2.padding 10
        --         ]
        --         [ Element2.el
        --             [ Region2.heading 1
        --             , Element2.alignLeft
        --             , Font2.size 36
        --             ]
        --             (Element2.text "New Stylish")
        --         , Input2.text
        --             [ Element2.spacing 12
        --             , Element2.below
        --                 (Element2.el
        --                     [ Font2.color red2
        --                     , Font2.size 14
        --                     , Element2.alignRight
        --                     , Element2.moveDown 6
        --                     ]
        --                     (Element2.text "This one is wrong")
        --                 )
        --             ]
        --             { text = model.username
        --             , placeholder = Just (Input2.placeholder [] (Element2.text "username"))
        --             , onChange = \new -> Update { model | username = new }
        --             , label = Input2.labelAbove [ Font2.size 14 ] (Element2.text "Username")
        --             }
        --         , Input2.multiline
        --             [ Element2.height Element2.shrink
        --             , Element2.spacing 12
        --             -- , padding 6
        --             ]
        --             { text = model.comment
        --             , placeholder = Just (Input2.placeholder [] (Element2.text "Extra hot sauce?\n\n\nYes pls"))
        --             , onChange = \new -> Update { model | comment = new }
        --             , label = Input2.labelAbove [ Font2.size 14 ] (Element2.text "Leave a comment!")
        --             , spellcheck = False
        --             }
        --         ]
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
