module Nearby.OtherInFrontIssue exposing (main)

import Browser
import Element exposing (Element)
import Element.Background as Background
import Html exposing (Html, button, div, text)
import Html.Attributes
import Html.Events exposing (onClick)



-- helping hack


translateLeft : Element.Attribute msg
translateLeft =
    Html.Attributes.style "transform" "translate(-100%)"
        |> Element.htmlAttribute


main =
    Element.layout
        [ Element.inFront <|
            Element.el
                [ Element.alignLeft
                , Background.color <| Element.rgb 1 0.5 0.5
                , Element.height Element.fill
                ]
            <|
                Element.text "Side Menu .........."
        ]
        contentPane


contentPane =
    Element.column
        [ Element.width Element.fill
        , Element.height Element.fill
        , Background.color <| Element.rgb 1 0 0
        ]
        [ Element.el
            [ Element.centerX
            , Element.centerY
            , Element.onLeft <| Element.text " [ onLeft. onLeft onLeft onLeft onLeft onLeft onLeft ] "
            ]
            (Element.text " [ Content: This will remain behind the Side Menu. ]")
        , Element.el
            [ Element.centerX
            , Element.centerY
            , Element.behindContent <|
                Element.el [ translateLeft ] <|
                    Element.text " [ behindContent + translateLeft. behindContent + translateLeft ] "
            ]
            (Element.text " [ Content: This will remain behind the Side Menu. ]")
        ]
