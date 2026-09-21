module HeightFillBounds exposing (suite)

{-| -}

import Expect
import Internal.BitField as BitField
import Internal.Model2 as Internal
import Internal.Style.Generated as Generated
import Test exposing (Test)
import Ui


suite : Test
suite =
    Test.describe "height fill with bounds in a row"
        [ Test.test "heightMin 0 keeps fill and adds the minimum" <|
            \_ ->
                Expect.equal
                    [ ( Just Generated.classes.heightFill, [] )
                    , ( Just Generated.classes.heightBounded, [ ( "min-height", "0px" ) ] )
                    ]
                    (attributeDetails [ Ui.height Ui.fill, Ui.heightMin 0 ])
        , Test.test "a nonzero heightMin keeps fill and adds the minimum" <|
            \_ ->
                Expect.equal
                    [ ( Just Generated.classes.heightFill, [] )
                    , ( Just Generated.classes.heightBounded, [ ( "min-height", "40px" ) ] )
                    ]
                    (attributeDetails [ Ui.height Ui.fill, Ui.heightMin 40 ])
        , Test.test "heightMax keeps fill and adds the maximum" <|
            \_ ->
                Expect.equal
                    [ ( Just Generated.classes.heightFill, [] )
                    , ( Just Generated.classes.heightBounded, [ ( "max-height", "40px" ) ] )
                    ]
                    (attributeDetails [ Ui.height Ui.fill, Ui.heightMax 40 ])
        , Test.test "bounded height-fill children match the row stretch selector" <|
            \_ ->
                Expect.equal True
                    (String.contains correctedRowStretchSelector Generated.stylesheet)
        , Test.test "explicit vertical alignment remains excluded from row stretching" <|
            \_ ->
                Expect.equal False
                    (String.contains oldRowStretchSelector Generated.stylesheet)
        , Test.test "row height-fill children retain the minimum-height reset" <|
            \_ ->
                Expect.equal True
                    (String.contains rowMinimumHeightSelector Generated.stylesheet)
        ]


attributeDetails : List (Ui.Attribute msg) -> List ( Maybe String, List ( String, String ) )
attributeDetails attributes =
    attributes
        |> List.concatMap
            (\(Internal.Attribute flagged) ->
                List.map
                    (\{ attr } ->
                        ( attr.class
                        , attr.styles BitField.init BitField.init
                        )
                    )
                    flagged
            )


correctedRowStretchSelector : String
correctedRowStretchSelector =
    ".s.r > .hf:not(.at, .ab, .cy){align-self:stretch;}"


oldRowStretchSelector : String
oldRowStretchSelector =
    ".s.r > .hf:not(.at, .ab, .cy, .hb){align-self:stretch;}"


rowMinimumHeightSelector : String
rowMinimumHeightSelector =
    ".s.r > .hf{min-height:0;}"
