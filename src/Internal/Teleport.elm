module Internal.Teleport exposing (Data(..), decode, encodeCss, persistentId)

{-| This is data that is teleported to the central state.
-}

import Animator
import Json.Decode as Decode
import Json.Encode as Encode


persistentId : String -> String -> Encode.Value
persistentId group instance =
    Encode.string group



-- ENCODER


encodeCss : Animator.Css -> Encode.Value
encodeCss css =
    Encode.object
        [ ( "hash", Encode.string css.hash )
        , ( "keyframes", Encode.string css.keyframes )
        , ( "props", Encode.list encodeProp css.props )
        ]


encodeProp : ( String, String ) -> Encode.Value
encodeProp ( key, value ) =
    Encode.object
        [ ( "key", Encode.string key )
        , ( "value", Encode.string value )
        ]



-- DECODER


type Data
    = Persistent String String
    | Css Animator.Css


decode : Decode.Decoder Data
decode =
    Decode.oneOf
        [ Decode.map Css decodeCss
        ]


decodeCss : Decode.Decoder Animator.Css
decodeCss =
    Decode.map3 Animator.Css
        (Decode.field "hash" Decode.string)
        (Decode.field "keyframes" Decode.string)
        (Decode.field "props" (Decode.list decodeProp))


decodeProp : Decode.Decoder ( String, String )
decodeProp =
    Decode.map2 (\key value -> ( key, value ))
        (Decode.field "key" Decode.string)
        (Decode.field "value" Decode.string)
