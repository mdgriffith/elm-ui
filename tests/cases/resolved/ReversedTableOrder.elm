module Main exposing (Person, main, persons)

{-| -}

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input


type alias Person =
    { firstName : String
    , lastName : String
    }


persons : List Person
persons =
    [ { firstName = "David"
      , lastName = "Bowie"
      }
    , { firstName = "Florence"
      , lastName = "Welch"
      }
    ]


main =
    Element.layout [] <|
        Element.table []
            { data = persons
            , columns =
                [ { header = Element.text "First Name"
                  , width = fill
                  , view =
                        \person ->
                            Element.Input.text []
                                { text = person.firstName
                                , placeholder = Nothing
                                , onChange = always Nothing
                                , label = Element.Input.labelAbove [] Element.none
                                }
                  }
                , { header = Element.text "Last Name"
                  , width = fill
                  , view =
                        \person ->
                            Element.Input.text []
                                { text = person.lastName
                                , placeholder = Nothing
                                , onChange = always Nothing
                                , label = Element.Input.labelAbove [] Element.none
                                }
                  }
                ]
            }
