module Placeholder exposing (main)

import Element exposing (..)
import Element.Background as Background
import Element.Input as Input
import Element.Keyed as Keyed
import Html.Attributes exposing (style)


grey =
    rgb 0.8 0.8 0.8


darkGrey =
    rgb 0.7 0.7 0.7


type Msg
    = NoMsg String


main =
    Element.layout [ width fill, height fill ] <|
        column
            [ width fill
            , inFront
                (el
                    [ width fill
                    , Background.color grey
                    , padding 20
                    , below <|
                        el
                            [ height (px 300)
                            , width (px 300)
                            , Background.color darkGrey
                            , htmlAttribute <| style "z-index" "1"
                            , moveRight 50
                            , padding 50
                            , alpha 0.5
                            ]
                            (el [ alignBottom ] (text "I'm a dropdown menu."))
                    ]
                    (text "I'm a toolbar.")
                )
            ]
            [ Input.text []
                { onChange = NoMsg
                , text = ""
                , placeholder = Just (Input.placeholder [] (text "I'm a text input."))
                , label = Input.labelAbove [] none
                }
            , Input.multiline []
                { onChange = NoMsg
                , text = ""
                , placeholder = Just (Input.placeholder [] (text "I'm a multiline input."))
                , label = Input.labelAbove [] none
                , spellcheck = False
                }
            ]
