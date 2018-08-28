module Main exposing (..)

import Html
import Internal.Flag as Flag


main =
    Html.div []
        [ Html.text "Verify All Flags invalidate themselves"
        , Html.div []
            (List.indexedMap invalidateSelf allFlags)
        , Html.text "Verify All Flags don't interfere with other flags"
        , Html.div []
            (List.indexedMap doesntInvalidateOthers allFlags)
        ]


invalidateSelf i flag =
    if Flag.present flag (Flag.add flag Flag.none) then
        Html.text ""
    else
        Html.div [] [ Html.text (toString (Flag.value flag) ++ " at index " ++ toString i ++ " does not invalidate itself") ]


doesntInvalidateOthers i flag =
    let
        withFlag =
            Flag.none
                |> Flag.add flag

        passing =
            List.all identity <|
                List.indexedMap
                    (\j otherFlag ->
                        Flag.present otherFlag (Flag.add otherFlag withFlag)
                    )
                    allFlags
    in
    if passing then
        Html.text ""
    else
        Html.div []
            [ Html.text (toString (Flag.value flag) ++ " at index " ++ toString i ++ " invalidates other flags!")
            ]


allFlags =
    [ Flag.transparency
    , Flag.padding
    , Flag.spacing
    , Flag.fontSize
    , Flag.fontFamily
    , Flag.width
    , Flag.height
    , Flag.bgColor
    , Flag.bgImage
    , Flag.bgGradient
    , Flag.borderStyle
    , Flag.fontAlignment
    , Flag.fontWeight
    , Flag.fontColor
    , Flag.wordSpacing
    , Flag.letterSpacing
    , Flag.borderRound
    , Flag.shadows
    , Flag.overflow
    , Flag.cursor
    , Flag.scale
    , Flag.rotate
    , Flag.moveX
    , Flag.moveY
    , Flag.borderWidth
    , Flag.borderColor
    , Flag.yAlign
    , Flag.xAlign
    , Flag.focus
    , Flag.active
    , Flag.hover
    , Flag.gridTemplate
    , Flag.gridPosition
    , Flag.heightContent
    , Flag.heightFill
    , Flag.widthContent
    , Flag.widthFill
    , Flag.alignRight
    , Flag.alignBottom
    , Flag.centerX
    , Flag.centerY
    ]
