module Responsiveness exposing (main)

{-| -}

import Browser
import Html exposing (Html)
import Theme
import Ui
import Ui.Anim
import Ui.Font
import Ui.Prose
import Ui.Responsive


type Breakpoints
    = Small
    | Medium
    | Large


{-| Translates into
0-800 -> Small
800-1400 -> Medium
1400-2400 -> Large
2400-above -> ExtraLarge
-}
breakpoints : Ui.Responsive.Breakpoints Breakpoints
breakpoints =
    Ui.Responsive.breakpoints Small
        [ ( 800, Medium )
        , ( 1200, Large )
        ]


main =
    Browser.document
        { init = \() -> ( { ui = Ui.Anim.init }, Cmd.none )
        , update = update
        , view =
            \model ->
                { title = "pls"
                , body = [ view model ]
                }
        , subscriptions = \_ -> Sub.none
        }


type Msg
    = Ui Ui.Anim.Msg


update msg model =
    case msg of
        Ui ui ->
            let
                ( newUi, cmd ) =
                    Ui.Anim.update Ui ui model.ui
            in
            ( { model | ui = newUi }
            , cmd
            )


view model =
    Ui.Anim.layout
        { options = []
        , toMsg = Ui
        , breakpoints = Just breakpoints
        }
        model.ui
        []
        (Ui.column
            [ Ui.width (Ui.px 800)
            , Ui.centerX
            , Ui.padding 100
            , Ui.spacing 100
            ]
            [ Theme.h1 "Row"
            , Theme.description "The following should be a row 'Large and below', which is always"
            , Ui.Responsive.rowWhen breakpoints
                (Ui.Responsive.orBelow Large breakpoints)
                [ Ui.spacing 20, Ui.wrap, Ui.heightMax 200 ]
                (List.repeat 20 smallBox)
            , Theme.description "The following should be a row only when the page is 'medum'"
            , Ui.Responsive.rowWhen breakpoints
                [ Medium
                ]
                [ Ui.spacing 20, Ui.wrap, Ui.heightMax 200 ]
                (List.repeat 20 smallBox)
            , Theme.description "The following should be a row only when the page is 'medum' or above"
            , Ui.Responsive.rowWhen breakpoints
                (Ui.Responsive.orAbove Medium breakpoints)
                [ Ui.spacing 20, Ui.wrap, Ui.heightMax 200 ]
                (List.repeat 20 smallBox)
            , Ui.el
                [ Ui.height (Ui.px 100)
                , Ui.width (Ui.px 100)
                , Ui.padding 25
                , Theme.rulerRight 100
                , Theme.rulerTop 100
                , Theme.palette.pink
                , Ui.Responsive.visible breakpoints
                    [ Small ]
                ]
                (Ui.text "Small")
            , Ui.el
                [ Ui.height (Ui.px 200)
                , Ui.width (Ui.px 200)
                , Ui.padding 25
                , Theme.rulerRight 200
                , Theme.rulerTop 200
                , Theme.palette.pink
                , Ui.Responsive.visible breakpoints
                    [ Medium ]
                ]
                (Ui.text "Medium")
            , Ui.el
                [ Ui.height (Ui.px 300)
                , Ui.width (Ui.px 300)
                , Ui.padding 25
                , Theme.rulerRight 300
                , Theme.rulerTop 300
                , Theme.palette.pink
                , Ui.Responsive.visible breakpoints
                    [ Large ]
                ]
                (Ui.text "Large")
            , Ui.Prose.paragraph
                [ Ui.paddingXY 100 0
                , Ui.Font.gradient Theme.gradient
                , Ui.Responsive.fontSize breakpoints
                    (\breakpoint ->
                        case breakpoint of
                            Small ->
                                Ui.Responsive.value 10

                            Medium ->
                                Ui.Responsive.fluid 10 30

                            Large ->
                                Ui.Responsive.value 30
                    )
                ]
                (List.repeat 100 (Ui.el [] (Ui.text "Text should wrap by default. ")))
            ]
        )


smallBox =
    Ui.el
        [ Ui.width (Ui.px 20)
        , Ui.height (Ui.px 20)
        , Theme.palette.pink
        ]
        Ui.none


row =
    Ui.row [ Ui.spacing 80, Ui.height Ui.fill ]
        [ Ui.text "Hello"
        , Ui.text "World"
        , Ui.el [ Theme.palette.pink ] (Ui.text "default is width fill")
        , Ui.el
            [ Ui.height (Ui.px 200)
            , Ui.width (Ui.px 200)
            , Ui.padding 25
            , Theme.rulerRight 200
            , Theme.rulerTop 200
            , Theme.palette.pink
            , Ui.Responsive.visible breakpoints
                [ Medium ]
            ]
            (Ui.text "Box:200px w/padding")
        , Ui.el
            [ Ui.height Ui.fill
            , Ui.heightMax 200
            , Theme.rulerRight 200
            , Ui.width (Ui.px 200)
            , Ui.padding 25
            , Theme.palette.pink
            ]
            (Ui.text "Max height: 200px")
        , Ui.el
            [ Ui.height Ui.fill
            , Ui.heightMax 500
            , Theme.rulerRight 500
            , Ui.widthMax 800
            , Ui.padding 25
            , Theme.palette.pink
            , Ui.alignTop
            ]
            (Ui.text "Max height: 500px")
        ]


column =
    Ui.column [ Ui.spacing 40, Ui.height (Ui.px 1500) ]
        [ Ui.text "Hello"
        , Ui.text "World"
        , Ui.el [ Theme.palette.pink ] (Ui.text "default is width fill")
        , Ui.el
            [ Ui.height (Ui.px 200)
            , Ui.width (Ui.px 200)
            , Ui.padding 25
            , Theme.rulerRight 200
            , Theme.palette.pink
            ]
            (Ui.text "Box:100px w/padding")
        , Ui.el [ Theme.rulerRight 200, Ui.width Ui.shrink ] <|
            Ui.clipped
                [ Ui.width (Ui.px 200)
                , Ui.height (Ui.px 200)
                , Ui.padding 40
                , Theme.palette.pink
                ]
                (Ui.el
                    [ Ui.width (Ui.px 400)
                    , Ui.height (Ui.px 800)
                    ]
                    (Ui.text "Clipped at 200px X and Y")
                )
        , Ui.el
            [ Ui.height Ui.fill
            , Ui.heightMax 200
            , Theme.rulerRight 200
            , Ui.width (Ui.px 200)
            , Ui.padding 25
            , Theme.palette.pink
            ]
            (Ui.text "Max height: 200px")
        , Ui.el
            [ Ui.height Ui.fill
            , Theme.rulerTop 400
            , Ui.widthMax 400
            , Ui.padding 25
            , Theme.palette.pink
            , Ui.centerX
            ]
            (Ui.text "Height fill, Centered X, and width max of 400")
        ]
