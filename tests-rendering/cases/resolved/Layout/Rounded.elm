module Rounded exposing (main)

import Element exposing (..)
import Element.Background as Background
import Html exposing (Html)


sizePadding =
    10


sizeSpacing =
    11


nbElement =
    10


sizeElement =
    50


totalSizeElement =
    nbElement * sizeElement


totalSpacing =
    (nbElement - 1) * sizeSpacing


totalPadding =
    2 * sizePadding


sizeRow =
    totalSizeElement + totalSpacing + totalPadding


main : Html msg
main =
    layout [ width fill, height fill ] <|
        -- The row should have 4.5px of padding to get
        -- from the 5.5px of margin of the elements on the edge
        -- up to 10px of padding specified on the wrappedRow.
        -- Instead the row has 5px of padding.
        wrappedRow [ width (px sizeRow), padding sizePadding, spacing sizeSpacing, Background.color (rgb 0 0 1) ]
        <|
            List.repeat nbElement <|
                -- Each element has a margin of 5.5px (11px of spacing / 2)
                el [ width (px sizeElement), height (px sizeElement), Background.color (rgb 1 0 0) ]
                <|
                    el [ centerX, centerY ] <|
                        text "card"
