module Tests.WidthHeight exposing (view)

{-| -}

import Html
import Testable
import Testable.Element as Element exposing (..)
import Testable.Element.Background as Background
import Testable.Element.Font as Font
import Testable.Runner
import Tests.Palette as Palette exposing (..)


{-| -}
main : Html.Html msg
main =
    Testable.Runner.show view


container attrs child =
    el
        (Background.color lightGrey
            :: attrs
        )
        child


box attrs =
    el (Background.color blue :: attrs) none


{-| -}
view : Testable.Element msg
view =
    column [ spacing 50, alignTop, Font.color white ]
        [ el [ Font.color black ] (text "fill")
        , el
            [ width (px 600)
            , Background.color lightGrey
            ]
            (el
                [ Background.color blue
                , width fill
                , height (px 200)
                ]
                none
            )
        , el [ Font.color black ] (text "shrink")
        , el
            [ width (px 600)
            , height (px 100)
            , Background.color lightGrey
            ]
            (el
                [ Background.color blue
                , width shrink
                , height shrink
                ]
                (text "Hello")
            )
        ]
