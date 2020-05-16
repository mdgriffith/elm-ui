module StackedScrollingColumnsHeight exposing (..)

{-|


# Column height can be set incorrectly for two stacked columns with scrollbarY

<https://github.com/mdgriffith/elm-ui/issues/197>

Both red and green columns should always have equal height.

Currently, the height is set incorrectly if only one column has enough content to scroll.

Both columns are correctly set to the same height only if neither has enough content
to scroll or if both have enough content to scroll.

-}

import Testable.Element exposing (..)
import Testable.Element.Background as Background


view =
    layout [ height fill ] <|
        column [ height fill ]
            [ column
                [ height fill
                , scrollbarY
                , Background.color (rgb 0 255 0)
                ]
              <|
                List.map (\_ -> text "Hello") <|
                    List.range 1 20
            , column
                [ height fill
                , scrollbarY
                , Background.color (rgb 255 0 0)
                ]
              <|
                List.map (\_ -> text "Hello") <|
                    List.range 1 3
            ]
