module Testable.Generator exposing (..)

{-| -}

import Testable
import Testable.Element exposing (..)
import Testable.Element.Background as Background
import Testable.Element.Font as Font


{-| Given a list of attributes, generate every context this list of attributes could be in.

So, this means,

    - every element type
    - in every element type

-}
element : String -> List (Testable.Attr msg) -> List ( String, Testable.Element msg )
element label attrs =
    -- [ ( label, paragraph attrs [ short ] )
    -- ]
    mapEveryCombo
        (\( selfLabel, makeSelf ) ( childLabel, child ) ->
            ( label ++ " - " ++ selfLabel ++ " > " ++ childLabel
            , makeSelf attrs child
            )
        )
        layouts
        contents


{-| Given a list of attributes, generate every context this list of attributes could be in.

So, this means,

    - every element type
    - in every element type

-}
elementInLayout : String -> List (Testable.Attr msg) -> List ( String, Testable.Element msg )
elementInLayout label attrs =
    -- [ ( label, paragraph attrs [ short ] )
    -- ]
    mapEveryCombo3
        (\( layoutLabel, makeLayout ) ( selfLabel, makeSelf ) ( childLabel, child ) ->
            ( label ++ " - " ++ layoutLabel ++ " > " ++ selfLabel ++ " > " ++ childLabel
            , makeLayout [] (makeSelf attrs child)
            )
        )
        layouts
        layouts
        contents


{-| Sometimes we want to try a whole bunch of combinations of attributes

This makes it a bit easier to construct

-}
elementWith : String -> List ( String, List (Testable.Attr msg) ) -> List ( String, Testable.Element msg )
elementWith label labelAttrs =
    mapEveryCombo3
        (\( attrLabel, attrs ) ( selfLabel, makeSelf ) ( childLabel, child ) ->
            ( label ++ " - " ++ selfLabel ++ " with " ++ attrLabel ++ " > " ++ childLabel
            , makeSelf attrs child
            )
        )
        labelAttrs
        layouts
        contents


{-| This varies the layout element that an element is in.
-}
elementInLayoutWith : String -> List ( String, List (Testable.Attr msg) ) -> List ( String, Testable.Element msg )
elementInLayoutWith label labelAttrs =
    mapEveryCombo4
        (\( attrLabel, attrs ) ( layoutLabel, makeLayout ) ( selfLabel, makeSelf ) ( childLabel, child ) ->
            ( label ++ " - " ++ layoutLabel ++ " > " ++ selfLabel ++ " with " ++ attrLabel ++ " > " ++ childLabel
            , makeLayout [] (makeSelf attrs child)
            )
        )
        labelAttrs
        layouts
        layouts
        contents


layouts =
    [ ( "el"
      , \attrs child ->
            el attrs child
      )
    , ( "row"
      , \attrs child ->
            row attrs [ child ]
      )
    , ( "col"
      , \attrs child ->
            column attrs [ child ]
      )
    , ( "para"
      , \attrs child ->
            paragraph attrs [ child ]
      )
    , ( "txtCol"
      , \attrs child ->
            textColumn attrs [ child ]
      )
    ]


nearbys =
    [ ( "inFront", inFront )
    , ( "above", above )
    , ( "onLeft", onLeft )
    , ( "onRight", onRight )
    , ( "below", below )
    , ( "behindContent", behindContent )
    ]


alignments =
    [ Tuple.pair "alignLeft" alignLeft
    , Tuple.pair "alignRight" alignRight
    , Tuple.pair "alignTop" alignTop
    , Tuple.pair "alignBottom" alignBottom
    , Tuple.pair "centerX" centerX
    , Tuple.pair "centerY" centerY
    ]


contents =
    [ ( "none", none )
    , ( "short text", text short )

    -- , ( "long text", text lorem )
    , ( "box"
      , box
      )
    ]


box =
    el
        [ width (px 50)
        , height (px 50)
        , Background.color (rgb (240 / 255) 0 (245 / 255))
        , Font.color (rgb 1 1 1)
        ]
        none


short =
    "short and small"


lorem =
    "There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don't look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc."


mapEveryCombo fn listOne listTwo =
    List.concatMap
        (\one ->
            List.map
                (\two ->
                    fn one two
                )
                listTwo
        )
        listOne


mapEveryCombo3 fn listOne listTwo listThree =
    List.concatMap
        (\one ->
            List.concatMap
                (\two ->
                    List.map
                        (\three ->
                            fn one two three
                        )
                        listThree
                )
                listTwo
        )
        listOne


mapEveryCombo4 fn listOne listTwo listThree listFour =
    List.concatMap
        (\one ->
            List.concatMap
                (\two ->
                    List.concatMap
                        (\three ->
                            List.map
                                (\four ->
                                    fn one two three four
                                )
                                listFour
                        )
                        listThree
                )
                listTwo
        )
        listOne


sizes render =
    List.concatMap
        (\( widthLen, heightLen ) ->
            [ text (Debug.toString ( widthLen, heightLen ))
            , render
                (\attrs children ->
                    el
                        (width widthLen
                            :: height heightLen
                            :: attrs
                        )
                        children
                )
            ]
        )
        allLengthPairs


allLengthPairs : List ( Length, Length )
allLengthPairs =
    let
        crossProduct len =
            List.map (Tuple.pair len) lengths
    in
    List.concatMap crossProduct lengths


lengths =
    [ px 50
    , fill
    , shrink
    , fill
        |> maximum 100
    , fill
        |> maximum 100
        |> minimum 50
    , shrink
        |> maximum 100
    , shrink
        |> maximum 100
        |> minimum 50
    ]
