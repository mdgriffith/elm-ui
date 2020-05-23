module InputAlignment exposing (main)

import Browser
import Element exposing (fill, padding, width)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)


view : () -> Html ()
view () =
    Element.layout [ Font.alignRight ] <|
        Element.column [ padding 10 ]
            [ Element.el [ Border.width 1, padding 5, width fill ] <| Element.text "Element.el"
            , Input.text
                [ Border.width 1
                , padding 5
                , width fill
                , Border.rounded 0
                , Font.color (Element.rgb 0 0.5 0.5)
                ]
                { onChange = always ()
                , text = "Input.text"
                , placeholder = Nothing
                , label = Input.labelHidden "Input.text"
                }
            , Element.paragraph []
                [ Element.text "Helooooo!" ]
            , Element.row []
                [ Element.text "one!"
                , Element.text "two!"
                , Element.text "three!"
                ]
            ]


main : Program () () ()
main =
    Browser.sandbox
        { init = ()
        , view = view
        , update = \_ _ -> ()
        }
