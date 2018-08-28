module MaskedInput exposing (..)

{-| When we've created a Mask, it should be able to:

  - The validator's job is only to say if an entire string is valid.
      - If a string is valid, then a message is sent out with the updated value.
      - If a string is not valid, then the last(i.e. the current) value is sent out on a message.
      - We have to send out a message on every input or else we'll get out of sync.(?)

  - The formatter's job is to take an input string and to format it into a view-string

  - The capturing parser's job is to transform the input string into the desired value.
      - If the parser fails, we keep returning `Partial`
      - As soon as it succeeds, we can return `Full`, which can have a value extracted.

First pass at full description.

Mask is defined in a view.

  - An initial string is potentially given.
  - String is formatted and displayed
  - onInput handler is registered which parses the value, and creates either a Partial or a Full
  - The onInput handler will return the formatted string.
    ->? we could diff it against a previous formatted string to see what changed. Maybe too complicated
    ->? Capture keyboard events directly and make modifications there. What about pasting?
    ->! Have the parser operate directly on the formatted string.

-}

import Parser exposing (Parser)


type Masked input
    = Mask
        { capture : Parser input -- String -> input
        , format : List Formatter -- tel: "86" -> "(86 )    -    "
        , validate : List Validator -- Is a character allowed to be typed
        }


type Validator
    = Validator Int (Char -> Bool)


type Formatter
    = Exactly String
    | FromInput Int (Maybe Hint) -- hint is shown if no string can be retrieved


type alias Hint =
    String


type Captured thing
    = Partial String
    | Full thing String


capture : input -> Masked input
capture value =
    Mask
        { capture = Parser.succeed value
        , format = []
        , validate = []
        }


{-| Shows a static string.
-}
show str (Mask mask) =
    Mask
        { mask
            | format = mask.format ++ [ Exactly str ]
            , capture = Parser.token str
        }


type alias Match =
    { length : Int
    , valid : Char -> Bool
    , hint : Maybe String
    }


{-| -}
match matcher (Mask mask) =
    Mask
        { mask
            | format = mask.format ++ [ FromInput matcher.length matcher.hint ]
            , validate = mask.validate ++ [ Validator matcher.length matcher.valid ]
            , capture = Parser.exactly matcher.length matcher.valid
        }



-- map : (a -> b) -> Masked a -> Masked b
-- map =
--     Debug.crash "TODO"
-- map2 :
--     (a -> b -> value)
--     -> Masked a
--     -> Masked b
--     -> Masked value
-- map2 =
--     Debug.crash "TODO"


view : String -> Masked input -> Element msg
view =
    Debug.crash


captureValue : String -> Masked input -> Captured input
captureValue input (Mask mask) =
    case Parser.run mask.capture input of
        Ok val ->
            Full val input

        Err _ ->
            Partial input


valid : Captured input -> Maybe input
valid cap =
    case cap of
        Partial _ ->
            Nothing

        Full result _ ->
            Just result
