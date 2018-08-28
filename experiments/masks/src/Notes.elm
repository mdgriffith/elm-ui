module Element.Input.Mask exposing (..)

{-| With masked input we can simultaneously descibe:

  - a parser to only allow specific arguments
      - We have a set of expected characters and how many of them to expect.
  - Static formating. Meaning show a `/` between two numbers, but it's not part of the input
  - Hints. These are mini placeholder values for a section of your input.
  - Autocomplete suggestions. These are suggestions that can be selected and completed with `tab`.

-}


type Masked input
    = Mask (List Pattern)


type Pattern
    = Capture Limit (Char -> Bool)
    | Decimal
    | Decoration String


type Limit
    = NoLimit
    | Min Int
    | Max Int
    | MinMax Int Int


type Input thing
    = Partial String
    | Full thing String


type alias CreditCard =
    { number : String
    , expMonth : String
    , expYear : String
    , ccv : String
    }


type alias CreditCardNumber =
    String


example =
    capture (\one two three four -> CreditCardNumber (one ++ two ++ three ++ four))
        |> Mask.stringWith
            { length = 4
            , valid = String.isDigit
            , hint = "1234"
            }
        |> Mask.show " "
        |> Mask.stringWith
            { length = 4
            , valid = String.isDigit
            , hint = "1234"
            }
        |> Mask.show " "
        |> Mask.stringWith
            { length = 4
            , valid = String.isDigit
            , hint = "1234"
            }
        |> Mask.space
        |> Mask.stringWith
            { length = 4
            , valid = String.isDigit
            , hint = "1234"
            }
        |> Mask.andThen
            (\creditcard ->
                capture (CreditCard creditNumber)
                    |> Mask.show "1234"
                    -- last four digits of credit card
                    |> Mask.space
                    |> Mask.stringWith
                        { length = 2
                        , valid = String.isDigit
                        , hint = "MM"
                        }
                    |> Mask.show "/"
                    |> Mask.stringWith
                        { length = 2
                        , valid = String.isDigit
                        , hint = "YY"
                        }
                    |> Mask.space
                    |> Mask.stringWith
                        { length = 4
                        , valid = String.isDigit
                        , hint = "CCV"
                        }
            )


float =
    Mask.int
        |> Mask.token "."
        |> Mask.andThen
            (\one ->
                masked (\two -> one + two)
                    --combine ints in a way
                    |> Mask.token (toString one)
                    |> Mask.token "."
                    |> Mask.stringWith
                        { length = 3 -- No length restrictions
                        , valid = String.isDigit
                        , hint = "CCV"
                        }
            )


{-| <https://ellie-app.com/JJxYGFKptVa1>

<https://ellie-app.com/JKMJgSTtn2a1>

<https://ellie-app.com/KdY8X99fqba1>

-}



-- type Masked input
--     = Mask
--         { capture : Parser input -- String -> input
--         , format : List Formatter -- tel: "86" -> "(86 )    -    "
--         , validate : List Validator -- Is a character allowed to be typed
--         }
-- type Validator
--     = Match Int (Char -> Bool)
-- type Formatter
--     = Exactly String
--     | FromInput Int Hint -- hint is shown if no string can be retrieved
-- type alias Hint =
--     String
-- -- type Masked input =
-- --     { parser : Parser input
-- --     ,
-- --     }
-- {-| We want this to be in
-- ---> formatting
-- -x-> result
-- -}
-- show str mask =
--     mask
-- {-| ---> formatting
-- ---> result
-- | if nothing's parsed
-- hint ---> formatting
-- hint -x-> result
-- -}
-- stringWith options mask =
--     mask
-- type Pattern input
--     = Capture Limit (Char -> Bool)
--     | Decimal
--     | Show String
-- type Limit
--     = NoLimit
--     | Min Int
--     | Max Int
--     | MinMax Int Int
-- type Captured input
--     = Partial String
--     | Full input String
-- {-| A placeholder ot represent different pieces having different styles
-- -}
-- type Styled
--     = Styled String String
-- render : String -> Masked input -> List Styled
-- captureValue : String -> Masked input -> Captured input
-- capture : input -> Masked input
-- map : (a -> b) -> Masked a -> Masked b
-- map2 :
--     (a -> b -> value)
--     -> Masked a
--     -> Masked b
--     -> Masked value
-- andThen : (a -> Masked b) -> Masked a -> Masked b
-- valid : Captured input -> Maybe input
-- valid cap =
--     case cap of
--         Partial _ ->
--             Nothing
--         Full result _ ->
--             Just result
