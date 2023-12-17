module Theme exposing
    ( black
    , description
    , garamond
    , gradient
    , h1
    , h2
    , hr
    , hrFromBottom
    , palette
    , pink
    , rulerLeft
    , rulerLeftOffset
    , rulerRight
    , rulerTop
    , vr
    )

import Html.Attributes as Attr
import Ui
import Ui.Font
import Ui.Gradient


garamond =
    Ui.Font.font
        { name = "EB Garamond"
        , fallback = [ Ui.Font.serif ]
        , variants = []
        , weight = Ui.Font.regular
        , size = 60
        , lineSpacing = 40
        , capitalSizeRatio = 0.74
        }


h1 content =
    Ui.el [ Ui.Font.size 40 ] (Ui.text content)


h2 content =
    Ui.el [ Ui.Font.size 28 ] (Ui.text content)


gradient =
    Ui.Gradient.linear (Ui.turns 0.35)
        [ Ui.Gradient.percent 0 (Ui.rgb 0 255 255)
        , Ui.Gradient.percent 20 (Ui.rgb 255 0 255)
        , Ui.Gradient.percent 100 (Ui.rgb 255 255 0)
        ]


description content =
    Ui.el
        [ Ui.Font.size 16
        , Ui.Font.italic
        , Ui.paddingXY 32 16
        , Ui.borderWith (Ui.Edges 0 0 0 4)
        , Ui.borderColor black
        ]
        (Ui.text content)


pink =
    Ui.rgb 240 0 245


black =
    Ui.rgb 0 0 0


grey =
    Ui.rgba 0 0 0 0.2


palette =
    { pink =
        Ui.palette
            { background = pink
            , font = black
            , border = black
            }
    }


hr : Int -> Ui.Attribute msg
hr fromTop =
    Ui.inFront <|
        Ui.el
            [ Ui.width Ui.fill
            , Ui.height (Ui.px 2)
            , Ui.background grey
            , Ui.move (Ui.down fromTop)
            ]
            Ui.none


hrFromBottom : Int -> Ui.Attribute msg
hrFromBottom fromTop =
    Ui.inFront <|
        Ui.el
            [ Ui.width Ui.fill
            , Ui.height (Ui.px 2)
            , Ui.background grey
            , Ui.move (Ui.up fromTop)
            , Ui.alignBottom
            ]
            Ui.none


vr : Int -> Ui.Attribute msg
vr fromLeft =
    Ui.inFront <|
        Ui.el
            [ Ui.width (Ui.px 2)
            , Ui.height Ui.fill
            , Ui.background grey
            , Ui.move (Ui.right fromLeft)
            ]
            Ui.none


rulerLeft : Int -> Ui.Attribute msg
rulerLeft height =
    Ui.onLeft
        (Ui.el
            [ Ui.Font.size 16
            , Ui.width (Ui.px 30)
            , Ui.height (Ui.px height)
            , Ui.borderWith (Ui.Edges 2 0 2 2)
            , Ui.borderColor black
            , Ui.onLeft
                (Ui.el [ Ui.centerY, Ui.move (Ui.left 5) ]
                    (Ui.text (String.fromInt height ++ "px"))
                )
            ]
            Ui.none
        )


rulerLeftOffset : { height : Int, fromTop : Int } -> Ui.Attribute msg
rulerLeftOffset { height, fromTop } =
    Ui.onLeft
        (Ui.el
            [ Ui.Font.size 16
            , Ui.move (Ui.down fromTop)
            , Ui.width (Ui.px 30)
            , Ui.height (Ui.px height)
            , Ui.borderWith (Ui.Edges 2 0 2 2)
            , Ui.borderColor black
            , Ui.onLeft
                (Ui.el [ Ui.centerY, Ui.move (Ui.left 5) ]
                    (Ui.text (String.fromInt height ++ "px"))
                )
            ]
            Ui.none
        )


rulerRight : Int -> Ui.Attribute msg
rulerRight height =
    Ui.onRight
        (Ui.el
            [ Ui.Font.size 16
            , Ui.width (Ui.px 30)
            , Ui.height (Ui.px height)
            , Ui.borderWith (Ui.Edges 2 2 2 0)
            , Ui.borderColor black
            , Ui.onRight
                (Ui.el [ Ui.centerY, Ui.move (Ui.right 5) ]
                    (Ui.text (String.fromInt height ++ "px"))
                )
            ]
            Ui.none
        )


rulerTop : Int -> Ui.Attribute msg
rulerTop width =
    Ui.above
        (Ui.el
            [ Ui.Font.size 16
            , Ui.height (Ui.px 30)
            , Ui.width (Ui.px width)
            , Ui.borderWith (Ui.Edges 2 2 0 2)
            , Ui.borderColor black
            , Ui.above
                (Ui.el [ Ui.centerX, Ui.move (Ui.up 5) ]
                    (Ui.text (String.fromInt width ++ "px"))
                )
            ]
            Ui.none
        )
