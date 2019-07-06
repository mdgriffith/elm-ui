module Main exposing (main)

import Browser
import Element exposing (text)
import Element.Border as Border
import Element.Input as Input
import Html exposing (Html, button, div)
import Html.Events exposing (onClick)


black =
    Element.rgb 0 0 0


styles =
    [ Border.color black
    , Border.width 1
    , Element.padding 5
    , Border.rounded 0
    ]


view : () -> Html ()
view () =
    -- Element.layout []
    --     (Input.text [ Border.rounded 0 ]
    --         { onChange = always ()
    --         , text = "yes"
    --         , placeholder = Nothing
    --         , label = Input.labelAbove [] <| text ""
    --         }
    --     )
    Element.layout [] <|
        Element.row [ Element.padding 10 ]
            [ Element.el
                styles
              <|
                Element.text "Hello yes"
            , Input.text
                styles
                { onChange = always ()
                , text = "Hello yes"
                , placeholder = Nothing
                , label = Input.labelHidden "Hello"
                }
            , Element.el
                [ Element.padding 0
                , Border.color black
                , Border.width 1
                ]
              <|
                Element.text "Hello yes"
            , Input.search
                [ Element.padding 0
                , Border.color black
                , Border.width 1
                ]
                { onChange = always ()
                , text = "Hello yes"
                , placeholder = Nothing
                , label = Input.labelHidden "Hello"
                }
            , Input.text
                [ Element.padding 0
                , Border.color black
                , Border.width 1
                ]
                { onChange = always ()
                , text = "Hello yes"
                , placeholder = Nothing
                , label = Input.labelHidden "Hello"
                }
            ]


main : Program () () ()
main =
    Browser.sandbox
        { init = ()
        , view = view
        , update = \_ _ -> ()
        }
