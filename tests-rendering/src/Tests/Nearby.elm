module Tests.Nearby exposing (view)

{-| Testing nearby elements such as those defined with `above`, `below`, etc.
-}

import Html
import Testable
import Testable.Element exposing (..)
import Testable.Element.Background as Background
import Testable.Element.Font as Font
import Testable.Generator
import Testable.Runner
import Tests.Palette as Palette exposing (..)


box attrs =
    el
        ([ width (px 50)
         , height (px 50)
         , Background.color blue
         ]
            ++ attrs
        )
        none


justBox size color attrs =
    el
        ([ width (px size)
         , height (px size)
         , Background.color color
         ]
            ++ attrs
        )
        none


littleBox name attrs =
    el
        ([ label name
         , width (px 5)
         , height (px 5)
         ]
            ++ attrs
        )
        none


p attrs =
    paragraph
        ([ Background.color blue
         , Font.color white
         , padding 20
         ]
            ++ attrs
        )
        [ text "Lorem Ipsum or something or other." ]


{-| -}
view : List ( String, Testable.Element msg )
view =
    List.concat
        [ [ Tuple.pair "Parent inFront above child inFront" layeredVisibility
          , Tuple.pair "Sibling onLeft above sibling inFront" overlappingChildren
          , Tuple.pair "el with all nearbys and alignments" master
          , Tuple.pair "paragraph with all nearbys and alignments" masterParagraph
          ]
        , Testable.Generator.generate "Nearbys"
            (\element nearby ->
                element
                    [ nearby (box [])
                    , width (px 200)
                    , height (px 200)
                    , Background.color red
                    ]
                    none
            )
            |> Testable.Generator.with Testable.Generator.allElements
            |> Testable.Generator.with Testable.Generator.nearbys
        , Testable.Generator.generate "Nearbys with alignment"
            (\element nearby align ->
                element
                    [ nearby (box [ align ])
                    , width (px 200)
                    , height (px 200)
                    , Background.color red
                    ]
                    none
            )
            |> Testable.Generator.with Testable.Generator.allElements
            |> Testable.Generator.with Testable.Generator.nearbys
            |> Testable.Generator.with Testable.Generator.alignments
        ]


layeredVisibility =
    el
        [ centerX
        , inFront (justBox 40 red [ isVisible ])
        ]
        (el [ inFront (justBox 30 green []) ]
            (justBox 50 blue [])
        )


overlappingChildren =
    row [ centerX ]
        [ el [ inFront (justBox 40 green []) ]
            (justBox 40 darkGrey [])
        , el [ onLeft (littleBox "overlapping" [ isVisible, Background.color red ]) ]
            (justBox 40 darkGrey [])
        ]


little name attrs =
    el
        ([ label name
         , width (px 5)
         , height (px 5)
         , Background.color darkCharcoal
         ]
            ++ attrs
        )
        none


master =
    el [ padding 20 ] <|
        box
            [ above (little "above-left" [ alignLeft ])
            , above (little "above-center" [ centerX ])
            , above (little "above-right" [ alignRight ])
            , below (little "below-left" [ alignLeft ])
            , below (little "below-center" [ centerX ])
            , below (little "below-right" [ alignRight ])
            , onRight (little "onRight-left" [ alignTop ])
            , onRight (little "onRight-center" [ centerY ])
            , onRight (little "onRight-right" [ alignBottom ])
            , onLeft (little "onLeft-left" [ alignTop ])
            , onLeft (little "onLeft-center" [ centerY ])
            , onLeft (little "onLeft-right" [ alignBottom ])
            , inFront (little "infront-left-top" [ alignTop, alignLeft ])
            , inFront (little "infront-center-top" [ alignTop, centerX ])
            , inFront (little "infront-right-top" [ alignTop, alignRight ])
            , inFront (little "infront-left-center" [ centerY, alignLeft ])
            , inFront (little "infront-center-center" [ centerY, centerX ])
            , inFront (little "infront-right-center" [ centerY, alignRight ])
            , inFront (little "infront-left-bottom" [ alignBottom, alignLeft ])
            , inFront (little "infront-center-bottom" [ alignBottom, centerX ])
            , inFront (little "infront-right-bottom" [ alignBottom, alignRight ])
            ]


masterParagraph =
    el [ padding 20 ] <|
        p
            [ above (little "above-left" [ alignLeft ])
            , above (little "above-center" [ centerX ])
            , above (little "above-right" [ alignRight ])
            , below (little "below-left" [ alignLeft ])
            , below (little "below-center" [ centerX ])
            , below (little "below-right" [ alignRight ])
            , onRight (little "onRight-left" [ alignTop ])
            , onRight (little "onRight-center" [ centerY ])
            , onRight (little "onRight-right" [ alignBottom ])
            , onLeft (little "onLeft-left" [ alignTop ])
            , onLeft (little "onLeft-center" [ centerY ])
            , onLeft (little "onLeft-right" [ alignBottom ])
            , inFront (little "infront-left-top" [ alignTop, alignLeft ])
            , inFront (little "infront-center-top" [ alignTop, centerX ])
            , inFront (little "infront-right-top" [ alignTop, alignRight ])
            , inFront (little "infront-left-center" [ centerY, alignLeft ])
            , inFront (little "infront-center-center" [ centerY, centerX ])
            , inFront (little "infront-right-center" [ centerY, alignRight ])
            , inFront (little "infront-left-bottom" [ alignBottom, alignLeft ])
            , inFront (little "infront-center-bottom" [ alignBottom, centerX ])
            , inFront (little "infront-right-bottom" [ alignBottom, alignRight ])
            ]
