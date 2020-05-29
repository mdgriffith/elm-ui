module Color exposing (suite)

import Element exposing (hex, hexOrRed, rgb255)
import Expect
import Test exposing (Test, test)


suite : Test
suite =
    Test.describe "Color from hex string"
        [ test "Black hex code" <|
            \_ ->
                Expect.equal (Ok <| rgb255 0 0 0) (hex "#000000")
        , test "White hex code" <|
            \_ ->
                Expect.equal (Ok <| rgb255 255 255 255) (hex "#FFFFFF")
        , test "Red hex code" <|
            \_ ->
                Expect.equal (Ok <| rgb255 255 0 0) (hex "#FF0000")
        , test "All hex letters code" <|
            \_ ->
                Expect.equal (Ok <| rgb255 171 205 239) (hex "#ABCDEF")
        , test "Random hex code" <|
            \_ ->
                Expect.equal (Ok <| rgb255 47 76 122) (hex "#2F4C7A")
        , test "Random hex code 2" <|
            \_ ->
                Expect.equal (Ok <| rgb255 95 47 122) (hex "#5F2F7A")
        , test "Random hex code lowercase" <|
            \_ ->
                Expect.equal (Ok <| rgb255 47 76 122) (hex "#2f4c7A")
        , test "Random hex code lowercase no hashtag" <|
            \_ ->
                Expect.equal (Ok <| rgb255 47 76 122) (hex "#2f4c7A")
        , test "3 digit hex code white" <|
            \_ ->
                Expect.equal (Ok <| rgb255 255 255 255) (hex "#FFF")
        , test "3 digit hex code black" <|
            \_ ->
                Expect.equal (Ok <| rgb255 0 0 0) (hex "#000")
        , test "3 digit hex code black no hashtag lowercase hexOrRed" <|
            \_ ->
                Expect.equal (rgb255 0 0 0) (hexOrRed "000")
        , test "3 digit hex code red" <|
            \_ ->
                Expect.equal (Ok <| rgb255 255 0 0) (hex "#F00")
        , test "3 digit hex code red no hashtag" <|
            \_ ->
                Expect.equal (Ok <| rgb255 255 0 0) (hex "F00")
        , test "3 digit hex code red no hashtag lowercase" <|
            \_ ->
                Expect.equal (Ok <| rgb255 255 0 0) (hex "f00")
        , test "fail on 5 digit hex code" <|
            \_ ->
                Expect.equal (Err "A color hex code has to be 3 or 6 characters long.") (hex "f0000")
        , test "Return red on 5 digit hex code for hexOrRed" <|
            \_ ->
                Expect.equal (rgb255 255 0 0) (hexOrRed "f0000")
        , test "fail on 2 digit hex code" <|
            \_ ->
                Expect.equal (Err "A color hex code has to be 3 or 6 characters long.") (hex "a1")
        , test "fail on empty string" <|
            \_ ->
                Expect.equal (Err "A color hex code has to be 3 or 6 characters long.") (hex "")
        , test "fail on invalid hex characters" <|
            \_ ->
                Expect.equal (Err "Not all characters in hex string were hex digits.") (hex "f1a23g")
        , test "fail on invalid hex characters 2" <|
            \_ ->
                Expect.equal (Err "Not all characters in hex string were hex digits.") (hex "l1a23f")
        , test "fail on invalid hex characters with 3 digits" <|
            \_ ->
                Expect.equal (Err "Not all characters in hex string were hex digits.") (hex "zaf")
        , test "fail on special invalid hex characters" <|
            \_ ->
                Expect.equal (Err "Not all characters in hex string were hex digits.") (hex ".abcde")
        , test "fail on special invalid hex characters 2" <|
            \_ ->
                Expect.equal (Err "Not all characters in hex string were hex digits.") (hex ".*/:)~")
        ]
