module Tables exposing (main)

{-| -}

import Html exposing (Html)
import Theme
import Ui
import Ui.Font
import Ui.Table


myTable =
    Ui.Table.columns
        [ Ui.Table.column
            { header = Ui.Table.header "Name"
            , view =
                \row ->
                    Ui.Table.cell []
                        (Ui.text row.name)
            }
        , Ui.Table.column
            { header = Ui.Table.header "Occupation"
            , view =
                \row ->
                    Ui.Table.cell []
                        (Ui.text row.occupation)
            }
        , Ui.Table.column
            { header =
                Ui.Table.cell
                    [ Ui.Font.alignRight
                    , Ui.borderWith
                        { top = 0
                        , left = 0
                        , right = 0
                        , bottom = 1
                        }
                    ]
                    (Ui.text "Salary")
            , view =
                \row ->
                    Ui.Table.cell [ Ui.Font.alignRight ]
                        (Ui.text (String.fromInt row.salary))
            }
            |> Ui.Table.withWidth
                { fill = True
                , min = Nothing
                , max = Nothing
                }
        ]


data =
    List.concat <|
        List.repeat 10
            [ { name = "John"
              , occupation = "Programmer"
              , salary = 1098080980900
              }
            , { name = "Jane"
              , occupation = "Designer"
              , salary = 1000900890890898989
              }
            , { name = "Bob"
              , occupation = "Manager"
              , salary = 1000
              }
            ]


main : Html msg
main =
    Ui.layout []
        (Ui.column
            [ Ui.width (Ui.px 800)
            , Ui.centerX
            , Ui.padding 100
            , Ui.spacing 100
            ]
            [ Theme.h1 "Row"
            , Ui.Table.view [] myTable data
            , Ui.el [ Ui.Font.alignRight ] (Ui.text "testestests")
            ]
        )
