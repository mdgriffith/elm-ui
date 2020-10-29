module Tests exposing (..)

{-| -}

import Bitwise
import Expect
import Fuzz
import Test


suite =
    Test.describe "Encode two numbers into one"
        [ Test.test "Encoding is symmetric" <|
            \_ ->
                Expect.equal (decode (encode 16 37)) ( 16, 37 )
        , Test.fuzz2 (Fuzz.intRange 0 10000) (Fuzz.intRange 0 10000) "Fuzz test encoding" <|
            \one two ->
                Expect.equal (decode (encode one two)) ( one, two )
        ]


encode : Int -> Int -> Int
encode one two =
    let
        shifted =
            Bitwise.shiftLeftBy 16 two
    in
    Bitwise.or
        one
        shifted


decode : Int -> ( Int, Int )
decode one =
    ( Bitwise.complement 0
        |> Bitwise.shiftRightZfBy 16
        |> Bitwise.and one
    , Bitwise.shiftRightZfBy 16 one
    )


viewBits : Int -> String
viewBits i =
    String.fromInt i ++ ":" ++ viewBitsHelper i 32


viewBitsHelper : Int -> Int -> String
viewBitsHelper field slot =
    if slot <= 0 then
        ""

    else if Bitwise.and slot field - slot == 0 then
        viewBitsHelper field (slot - 1) ++ "1"

    else
        viewBitsHelper field (slot - 1) ++ "0"
