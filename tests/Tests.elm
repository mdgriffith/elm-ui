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
                Expect.equal (decodeOld (encodeOld 16 37)) ( 16, 37 )
        , Test.fuzz2 (Fuzz.intRange 0 10000) (Fuzz.intRange 0 10000) "Fuzz test encoding" <|
            \one two ->
                Expect.equal (decodeOld (encodeOld one two)) ( one, two )
        ]


encodeOld : Int -> Int -> Int
encodeOld one two =
    let
        shifted =
            Bitwise.shiftLeftBy 16 two
    in
    Bitwise.or
        one
        shifted


decodeOld : Int -> ( Int, Int )
decodeOld one =
    ( Bitwise.complement 0
        |> Bitwise.shiftRightZfBy 16
        |> Bitwise.and one
    , Bitwise.shiftRightZfBy 16 one
    )


viewBits : Int -> String
viewBits i =
    String.fromInt i ++ ":" ++ viewBitsHelper i 0


viewBitsHelper : Int -> Int -> String
viewBitsHelper field slot =
    let
        bitmask =
            Bitwise.shiftLeftBy slot 1
    in
    if slot >= 32 then
        ""

    else if Bitwise.and bitmask field - bitmask == 0 then
        viewBitsHelper field (slot + 1) ++ "1"

    else
        viewBitsHelper field (slot + 1) ++ "0"



{- NEW ENCODING -}


type alias Data =
    { row : Bool
    , spacingX : Int
    , spacingY : Int
    , fontTop : Int
    , fontBottom : Int
    }


new =
    Test.describe "Encode All"
        [ Test.test "Encoding is symmetric" <|
            \_ ->
                let
                    config =
                        { row = True
                        , spacingX = 64
                        , spacingY = 32
                        , fontTop = 45
                        , fontBottom = 24
                        }
                in
                Expect.equal (decode (encode config)) config
        , Test.fuzz dataFuzzer "Fuzz test encoding" <|
            \data ->
                Expect.equal (decode (encode data)) data
        ]


dataFuzzer =
    Fuzz.map5 Data
        Fuzz.bool
        (Fuzz.intRange 0 1023)
        (Fuzz.intRange 0 1023)
        (Fuzz.intRange 0 63)
        (Fuzz.intRange 0 31)


logBits str x =
    let
        _ =
            Debug.log str (viewBits x)
    in
    x


{-| spacingx -> 10 bits
spacingy -> 10 bits
fontTop -> 6 bits
fontBottom -> 5 bits
-}
encode : Data -> Int
encode data =
    data.spacingX
        |> Bitwise.or
            (Bitwise.shiftLeftBy 10 data.spacingY)
        |> Bitwise.or
            (Bitwise.shiftLeftBy 20 data.fontTop)
        |> Bitwise.or
            (Bitwise.shiftLeftBy 26 data.fontBottom)
        |> Bitwise.or
            (if data.row then
                Bitwise.shiftLeftBy 31 1

             else
                Bitwise.shiftLeftBy 31 0
            )


decode : Int -> Data
decode one =
    { spacingX =
        Bitwise.complement 0
            |> Bitwise.shiftRightZfBy 22
            |> Bitwise.and one
    , spacingY =
        one
            |> Bitwise.shiftRightZfBy 10
            |> Bitwise.and (Bitwise.shiftRightZfBy (32 - 10) (Bitwise.complement 0))
    , row =
        Bitwise.shiftRightZfBy 31 one == 1
    , fontTop =
        one
            |> Bitwise.shiftRightZfBy 20
            |> Bitwise.and (Bitwise.shiftRightZfBy (32 - 6) (Bitwise.complement 0))
    , fontBottom =
        one
            |> Bitwise.shiftRightZfBy 26
            |> Bitwise.and (Bitwise.shiftRightZfBy (32 - 5) (Bitwise.complement 0))
    }


mask start end =
    let
        first =
            Bitwise.complement 0
                |> Bitwise.shiftLeftBy start

        -- |> logBits "first"
        second =
            Bitwise.complement 0
                |> Bitwise.shiftLeftBy end

        -- |> logBits "second"
    in
    -- logBits "mask"
    Bitwise.xor first second


focus start end x =
    x
        |> Bitwise.shiftRightZfBy start
        |> Bitwise.and (Bitwise.shiftRightZfBy (32 - (end - start)) (Bitwise.complement 0))
