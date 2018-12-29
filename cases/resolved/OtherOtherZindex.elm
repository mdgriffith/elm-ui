module Main exposing (main)

import Element
import Element.Background


main =
    Element.layout []
        (Element.el
            [ Element.inFront
                (Element.el
                    [ Element.width (Element.px 70)
                    , Element.height (Element.px 70)
                    , Element.Background.color (Element.rgb 0 0 0)
                    ]
                    Element.none
                )
            ]
            (Element.el
                [ Element.inFront
                    (Element.el
                        [ Element.width (Element.px 50)
                        , Element.height (Element.px 50)
                        , Element.Background.color (Element.rgb 1 0 0)
                        ]
                        Element.none
                    )
                ]
                Element.none
            )
        )
