module Main exposing (main)

import Element
import Element.Background
import Element.Input


main =
    Element.layout []
        (Element.column [ Element.width (Element.px 200), Element.spacing 10 ]
            [ Element.Input.text [ Element.focused [] ]
                { label = Element.Input.labelHidden ""
                , onChange = \_ -> ()
                , placeholder = Nothing
                , text = ""
                }
            , Element.Input.multiline
                [ Element.focused [ Element.Background.color (Element.rgb 0 0 0) ] ]
                { label = Element.Input.labelHidden ""
                , onChange = \_ -> ()
                , placeholder = Nothing
                , spellcheck = False
                , text = ""
                }
            , Element.Input.button [ Element.focused [] ]
                { label = Element.text "Button"
                , onPress = Nothing
                }
            , Element.Input.button []
                { label = Element.text "Button"
                , onPress = Nothing
                }
            ]
        )
