module ClassNames exposing (suite)

{-| -}

import Expect
import Generated.Inventories exposing (allClassNames)
import Html exposing (Html)
import Test exposing (Test)


suite : Test
suite =
    Test.describe "Classname Collisions"
        [ Test.test "No duplicates" <|
            \_ ->
                Expect.equal [] onlyDuplicates
        ]


main : Html msg
main =
    Html.div []
        [ Html.text "The following names collide"
        , Html.div []
            (List.map viewPair onlyDuplicates)
        ]


viewPair : ( String, String ) -> Html msg
viewPair ( name, description ) =
    Html.div []
        [ Html.text name
        , Html.text ": "
        , Html.text description
        ]


onlyDuplicates =
    List.filter findDuplicates allClassNames


findDuplicates ( name, description ) =
    List.any
        (\( checkName, checkDescription ) ->
            checkName == name && description /= checkDescription
        )
        allClassNames
