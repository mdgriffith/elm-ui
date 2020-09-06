module Generate exposing (main, output)

import Html


{-| -}
main =
    Html.text output


output : String
output =
    overrides
        ++ renderCompact baseSheet
        ++ renderCompact variable



{- BEGIN COPY -}


classes =
    { root = "ui"
    , any = "s"
    , single = "e"
    , row = "r"
    , column = "c"
    , page = "pg"
    , paragraph = "p"
    , text = "t"
    , grid = "g"
    , imageContainer = "ic"
    , nowrap = "nowrp"
    , wrapped = "wrp"
    , transform = "move"

    -- widhts/heights
    , widthFill = "wf"
    , widthContent = "wc"
    , widthExact = "we"
    , widthFillPortion = "wfp"
    , heightFill = "hf"
    , heightContent = "hc"
    , heightExact = "he"
    , heightFillPortion = "hfp"
    , seButton = "sbt"

    -- nearby elements
    , nearby = "nb"
    , above = "a"
    , below = "b"
    , onRight = "or"
    , onLeft = "ol"
    , inFront = "fr"
    , behind = "bh"
    , hasBehind = "hbh"

    -- alignments
    , alignTop = "at"
    , alignBottom = "ab"
    , alignRight = "ar"
    , alignLeft = "al"
    , alignCenterX = "cx"
    , alignCenterY = "cy"
    , alignedHorizontally = "ah"
    , alignedVertically = "av"

    -- space evenly
    , spacing = "spc"
    , spaceEvenly = "sev"
    , padding = "pad"
    , container = "ctr"
    , alignContainerRight = "acr"
    , alignContainerBottom = "acb"
    , alignContainerCenterX = "accx"
    , alignContainerCenterY = "accy"

    -- content alignments
    , contentTop = "ct"
    , contentBottom = "cb"
    , contentRight = "cr"
    , contentLeft = "cl"
    , contentCenterX = "ccx"
    , contentCenterY = "ccy"

    -- selection
    , noTextSelection = "notxt"
    , cursorPointer = "cptr"
    , cursorText = "ctxt"

    -- pointer events
    , passPointerEvents = "ppe"
    , capturePointerEvents = "cpe"
    , transparent = "clr"
    , opaque = "oq"
    , overflowHidden = "oh"

    -- special state classes
    , hover = "hv"
    , focus = "fcs"
    , focusedWithin = "focus-within"
    , active = "atv"

    --scrollbars
    , scrollbars = "sb"
    , scrollbarsX = "sbx"
    , scrollbarsY = "sby"
    , clip = "cp"
    , clipX = "cpx"
    , clipY = "cpy"

    -- text weight
    , sizeByCapital = "cap"
    , fullSize = "fs"
    , italic = "i"
    , strike = "sk"
    , underline = "u"
    , textUnitalicized = "tun"
    , textJustify = "tj"
    , textJustifyAll = "tja"
    , textCenter = "tc"
    , textRight = "tr"
    , textLeft = "tl"

    -- text alignment
    , transition = "ts"

    -- inputText
    , inputText = "it"
    , inputTextInputWrapper = "itw"
    , inputTextParent = "itp"
    , inputMultiline = "iml"
    , inputMultilineParent = "imlp"
    , inputMultilineFiller = "imlf"
    , inputMultilineWrapper = "implw"
    , inputLabel = "lbl"
    , slider = "sldr"

    -- link
    , link = "lnk"
    }


type Var
    = Var String


vars =
    { spaceX = Var "space-x"
    , spaceY = Var "space-y"
    , scale = Var "scale"
    , moveX = Var "move-x"
    , moveY = Var "move-y"
    , rotate = Var "rotate"
    , heightFill = Var "height-fill"
    , widthFill = Var "width-fill"
    , padLeft = Var "pad-left"
    , padRight = Var "pad-right"
    , padTop = Var "pad-top"
    , padBottom = Var "pad-bottom"
    , borderLeft = Var "border-left"
    , borderRight = Var "border-right"
    , borderTop = Var "border-top"
    , borderBottom = Var "border-bottom"
    , sliderWidth = Var "slider-width"
    , sliderHeight = Var "slider-height"
    }



{- END COPY -}


dot c =
    "." ++ c


type Class
    = Class String (List Rule)


type Rule
    = Prop String String
    | Variable String Var
    | Calc String Calc
    | CalcPair String Calc Calc
    | Child String (List Rule)
    | AllChildren String (List Rule)
    | Descriptor String (List Rule)
    | Adjacent String (List Rule)
    | Batch (List Rule)


type Calc
    = Add Calc Calc
    | Minus Calc Calc
    | Multiply Calc Calc
    | Divide Calc Calc
    | CalcVar Var
    | CalcVal String


type Color
    = Rgb Int Int Int



{- RESETS -}


overrides =
    """@media screen and (-ms-high-contrast: active), (-ms-high-contrast: none) {"""
        ++ dot classes.any
        ++ dot classes.row
        ++ " > "
        ++ dot classes.any
        ++ " { flex-basis: auto !important; } "
        ++ dot classes.any
        ++ dot classes.row
        ++ " > "
        ++ dot classes.any
        ++ dot classes.container
        ++ " { flex-basis: auto !important; }}"
        ++ inputTextReset
        ++ sliderReset
        ++ trackReset
        ++ thumbReset
        ++ explainer


inputTextReset =
    """
input[type="search"],
input[type="search"]::-webkit-search-decoration,
input[type="search"]::-webkit-search-cancel-button,
input[type="search"]::-webkit-search-results-button,
input[type="search"]::-webkit-search-results-decoration {
  -webkit-appearance:none;
}
"""


sliderReset =
    """
    input[type=range] {
      -webkit-appearance: none;
      background: transparent;
      position:absolute;
      left:0;
      top:0;
      z-index:10;
      width: 100%;
      height: 100%;
      opacity: 0;
      // outline: dashed 1px;
    }
    """


trackReset =
    """
    input[type=range]::-moz-range-track {
        background: transparent;
        cursor: pointer;
    }
    input[type=range]::-ms-track {
        background: transparent;
        cursor: pointer;
    }
    input[type=range]::-webkit-slider-runnable-track {
        background: transparent;
        cursor: pointer;
    }
    """


thumbReset =
    -- """
    -- input[type=range]::-webkit-slider-thumb {
    --     -webkit-appearance: none;
    --     opacity: 0.5;
    --     width: 80px;
    --     height: 80px;
    --     background-color: black;
    --     border:none;
    --     border-radius: 5px;
    -- }
    -- input[type=range]::-moz-range-thumb {
    --     opacity: 0.5;
    --     width: 80px;
    --     height: 80px;
    --     background-color: black;
    --     border:none;
    --     border-radius: 5px;
    -- }
    -- input[type=range]::-ms-thumb {
    --     opacity: 0.5;
    --     width: 80px;
    --     height: 80px;
    --     background-color: black;
    --     border:none;
    --     border-radius: 5px;
    -- }
    -- input[type=range][orient=vertical]{
    --     writing-mode: bt-lr; /* IE */
    --     -webkit-appearance: slider-vertical;  /* WebKit */
    -- }
    -- """
    ""


explainer =
    """
.explain {
    border: 6px solid rgb(174, 121, 15) !important;
}
.explain > .""" ++ classes.any ++ """ {
    border: 4px dashed rgb(0, 151, 167) !important;
}

.ctr {
    border: none !important;
}
.explain > .ctr > .""" ++ classes.any ++ """ {
    border: 4px dashed rgb(0, 151, 167) !important;
}

"""



{- Base Sheet -}


type SelfDescriptor
    = Self Alignment


type ContentDescriptor
    = Content Alignment


type Alignment
    = Top
    | Bottom
    | Right
    | Left
    | CenterX
    | CenterY


alignments =
    [ Top
    , Bottom
    , Right
    , Left
    , CenterX
    , CenterY
    ]


type Location
    = Above
    | Below
    | OnRight
    | OnLeft
    | Within
    | Behind


locations =
    let
        loc =
            Above

        _ =
            case loc of
                Above ->
                    ()

                Below ->
                    ()

                OnRight ->
                    ()

                OnLeft ->
                    ()

                Within ->
                    ()

                Behind ->
                    ()
    in
    [ Above
    , Below
    , OnRight
    , OnLeft
    , Within
    , Behind
    ]


selfName desc =
    case desc of
        Self Top ->
            dot classes.alignTop

        Self Bottom ->
            dot classes.alignBottom

        Self Right ->
            dot classes.alignRight

        Self Left ->
            dot classes.alignLeft

        Self CenterX ->
            dot classes.alignCenterX

        Self CenterY ->
            dot classes.alignCenterY


contentName desc =
    case desc of
        Content Top ->
            dot classes.contentTop

        Content Bottom ->
            dot classes.contentBottom

        Content Right ->
            dot classes.contentRight

        Content Left ->
            dot classes.contentLeft

        Content CenterX ->
            dot classes.contentCenterX

        Content CenterY ->
            dot classes.contentCenterY


describeAlignment values =
    let
        createDescription alignment =
            let
                ( content, indiv ) =
                    values alignment
            in
            [ Descriptor (contentName (Content alignment)) <|
                content
            , Child (dot classes.any)
                [ Descriptor (selfName <| Self alignment) indiv
                ]
            ]
    in
    Batch <|
        List.concatMap createDescription alignments


gridAlignments values =
    let
        createDescription alignment =
            [ Child (dot classes.any)
                [ Descriptor (selfName <| Self alignment) (values alignment)
                ]
            ]
    in
    Batch <|
        List.concatMap createDescription alignments


baseSheet =
    [ Class "html,body"
        [ Prop "height" "100%"
        , Prop "padding" "0"
        , Prop "margin" "0"
        ]
    , Class (dot classes.any ++ dot classes.single ++ dot classes.imageContainer)
        [ Prop "display" "block"
        , Descriptor (dot classes.heightFill)
            [ Child "img"
                [ Prop "max-height" "100%"
                , Prop "object-fit" "cover"
                ]
            ]
        , Descriptor (dot classes.widthFill)
            [ Child "img"
                [ Prop "max-width" "100%"
                , Prop "object-fit" "cover"
                ]
            ]
        ]
    , Class (dot classes.any ++ ":focus")
        [ Prop "outline" "none"
        ]
    , Class (dot classes.root)
        [ Prop "width" "100%"
        , Prop "height" "auto"
        , Prop "min-height" "100%"
        , Prop "z-index" "0"
        , Descriptor
            (dot classes.any
                -- ++ dot classes.single
                ++ dot classes.heightFill
            )
            [ Prop "height" "100%"
            , Child (dot classes.heightFill)
                [ Prop "height" "100%"
                ]
            ]
        , Child (dot classes.inFront)
            [ Descriptor (dot classes.nearby)
                [ Prop "position" "fixed"
                , Prop "z-index" "20"
                ]
            ]
        ]
    , Class (dot classes.nearby)
        [ Prop "position" "relative"
        , Prop "border" "none"
        , Prop "display" "flex"
        , Prop "flex-direction" "row"
        , Prop "flex-basis" "auto"
        , Descriptor (dot classes.single)
            elDescription
        , Batch <|
            (\fn -> List.map fn locations) <|
                \loc ->
                    case loc of
                        Above ->
                            Descriptor (dot classes.above)
                                [ Prop "position" "absolute"
                                , Prop "bottom" "100%"
                                , Prop "left" "0"
                                , Prop "width" "100%"
                                , Prop "z-index" "20"
                                , Prop "margin" "0 !important"
                                , Child (dot classes.heightFill)
                                    [ Prop "height" "auto"
                                    ]
                                , Child (dot classes.widthFill)
                                    [ Prop "width" "100%"
                                    ]
                                , Prop "pointer-events" "none"
                                , Child "*"
                                    [ Prop "pointer-events" "auto"
                                    ]
                                ]

                        Below ->
                            Descriptor (dot classes.below)
                                [ Prop "position" "absolute"
                                , Prop "bottom" "0"
                                , Prop "left" "0"
                                , Prop "height" "0"
                                , Prop "width" "100%"
                                , Prop "z-index" "20"
                                , Prop "margin" "0 !important"
                                , Prop "pointer-events" "none"
                                , Child "*"
                                    [ Prop "pointer-events" "auto"
                                    ]
                                , Child (dot classes.heightFill)
                                    [ Prop "height" "auto"
                                    ]
                                ]

                        OnRight ->
                            Descriptor (dot classes.onRight)
                                [ Prop "position" "absolute"
                                , Prop "left" "100%"
                                , Prop "top" "0"
                                , Prop "height" "100%"
                                , Prop "margin" "0 !important"
                                , Prop "z-index" "20"
                                , Prop "pointer-events" "none"
                                , Child "*"
                                    [ Prop "pointer-events" "auto"
                                    ]
                                ]

                        OnLeft ->
                            Descriptor (dot classes.onLeft)
                                [ Prop "position" "absolute"
                                , Prop "right" "100%"
                                , Prop "top" "0"
                                , Prop "height" "100%"
                                , Prop "margin" "0 !important"
                                , Prop "z-index" "20"
                                , Prop "pointer-events" "none"
                                , Child "*"
                                    [ Prop "pointer-events" "auto"
                                    ]
                                ]

                        Within ->
                            Descriptor (dot classes.inFront)
                                [ Prop "position" "absolute"
                                , Prop "width" "100%"
                                , Prop "height" "100%"
                                , Prop "left" "0"
                                , Prop "top" "0"
                                , Prop "margin" "0 !important"
                                , Prop "pointer-events" "none"
                                , Child "*"
                                    [ Prop "pointer-events" "auto"
                                    ]
                                ]

                        Behind ->
                            Descriptor (dot classes.behind)
                                [ Prop "position" "absolute"
                                , Prop "width" "100%"
                                , Prop "height" "100%"
                                , Prop "left" "0"
                                , Prop "top" "0"
                                , Prop "margin" "0 !important"
                                , Prop "z-index" "0"
                                , Prop "pointer-events" "none"
                                , Child "*"
                                    [ Prop "pointer-events" "auto"
                                    ]
                                ]
        ]
    , Class (dot classes.any)
        [ Prop "position" "relative"
        , Prop "border" "none"
        , Prop "flex-shrink" "0"
        , Prop "display" "flex"
        , Prop "flex-direction" "row"
        , Prop "flex-basis" "auto"
        , Prop "resize" "none"
        , Prop "font-feature-settings" "inherit"

        -- , Prop "flex-basis" "0%"
        , Prop "box-sizing" "border-box"
        , Prop "margin" "0"
        , Prop "padding" "0"
        , Prop "border-width" "0"
        , Prop "border-style" "solid"

        -- inheritable font properties
        , Prop "font-size" "inherit"
        , Prop "color" "inherit"
        , Prop "font-family" "inherit"
        , Prop "line-height" "1"
        , Prop "font-weight" "inherit"

        -- Text decoration is *mandatorily inherited* in the css spec.
        -- There's no way to change this.  How crazy is that?
        , Prop "text-decoration" "none"
        , Prop "font-style" "inherit"
        , Descriptor (dot classes.wrapped)
            [ Prop "flex-wrap" "wrap"
            ]
        , Descriptor (dot classes.noTextSelection)
            [ Prop "-moz-user-select" "none"
            , Prop "-webkit-user-select" "none"
            , Prop "-ms-user-select" "none"
            , Prop "user-select" "none"
            ]
        , Descriptor (dot classes.cursorPointer)
            [ Prop "cursor" "pointer"
            ]
        , Descriptor (dot classes.cursorText)
            [ Prop "cursor" "text"
            ]
        , Descriptor (dot classes.passPointerEvents)
            [ Prop "pointer-events" "none !important"
            ]
        , Descriptor (dot classes.capturePointerEvents)
            [ Prop "pointer-events" "auto !important"
            ]
        , Descriptor (dot classes.transparent)
            [ Prop "opacity" "0"
            ]
        , Descriptor (dot classes.opaque)
            [ Prop "opacity" "1"
            ]
        , Descriptor (dot (classes.hover ++ classes.transparent) ++ ":hover")
            [ Prop "opacity" "0"
            ]
        , Descriptor (dot (classes.hover ++ classes.opaque) ++ ":hover")
            [ Prop "opacity" "1"
            ]
        , Descriptor (dot (classes.focus ++ classes.transparent) ++ ":focus")
            [ Prop "opacity" "0"
            ]
        , Descriptor (dot (classes.focus ++ classes.opaque) ++ ":focus")
            [ Prop "opacity" "1"
            ]
        , Descriptor (dot (classes.active ++ classes.transparent) ++ ":active")
            [ Prop "opacity" "0"
            ]
        , Descriptor (dot (classes.active ++ classes.opaque) ++ ":active")
            [ Prop "opacity" "1"
            ]
        , Descriptor (dot classes.transition)
            [ Prop "transition"
                (String.join ", " <|
                    List.map (\x -> x ++ " 160ms")
                        [ "transform"
                        , "opacity"
                        , "filter"
                        , "background-color"
                        , "color"
                        , "font-size"
                        ]
                )
            ]
        , Descriptor (dot classes.scrollbars)
            [ Prop "overflow" "auto"
            , Prop "flex-shrink" "1"
            ]
        , Descriptor (dot classes.scrollbarsX)
            [ Prop "overflow-x" "auto"
            , Descriptor (dot classes.row)
                [ Prop "flex-shrink" "1"
                ]
            ]
        , Descriptor (dot classes.scrollbarsY)
            [ Prop "overflow-y" "auto"
            , Descriptor (dot classes.column)
                [ Prop "flex-shrink" "1"
                ]
            , Descriptor (dot classes.single)
                [ Prop "flex-shrink" "1"
                ]
            ]
        , Descriptor (dot classes.clip)
            [ Prop "overflow" "hidden"
            ]
        , Descriptor (dot classes.clipX)
            [ Prop "overflow-x" "hidden"
            ]
        , Descriptor (dot classes.clipY)
            [ Prop "overflow-y" "hidden"
            ]
        , Descriptor (dot classes.widthContent)
            [ Prop "width" "auto"
            ]
        , Descriptor (dot classes.text)
            [ Prop "white-space" "pre"
            , Prop "display" "inline-block"
            ]
        , Descriptor (dot classes.single)
            elDescription
        , Descriptor (dot classes.row)
            [ Prop "display" "flex"
            , Prop "flex-direction" "row"
            , Child (dot classes.any)
                [ Prop "flex-basis" "0%"
                , Descriptor (dot classes.widthExact)
                    [ Prop "flex-basis" "auto"
                    ]
                , Descriptor (dot classes.link)
                    [ Prop "flex-basis" "auto"
                    ]
                , Descriptor (dot classes.paragraph)
                    [ Prop "flex-basis" "auto"
                    , Prop "flex-shrink" "1"
                    , Descriptor (dot classes.widthFill)
                        [ Prop "flex-basis" "0"
                        , Prop "flex-shrink" "0"
                        ]
                    ]
                ]
            , Child (dot classes.heightFill)
                [ -- alignTop, centerY, and alignBottom need to be disabled
                  Prop "align-self" "stretch !important"
                ]
            , Child (dot classes.heightFillPortion)
                [ -- alignTop, centerY, and alignBottom need to be disabled
                  Prop "align-self" "stretch !important"
                ]

            -- TODO:: This may be necessary..should it move to classes.heightFIll?
            -- , Child (dot classes.heightFillBetween)
            --     [ Prop "align-self" "stretch"
            --     , Descriptor ".aligned-vertically"
            --         [ Prop "height" "100%"
            --         ]
            --     ]
            -- , Child (dot classes.widthFill)
            --     [ Prop "flex-grow" "100000"
            --     ]
            , Batch
                (List.map
                    (\f ->
                        Child (dot classes.widthFillPortion ++ "-" ++ String.fromInt f)
                            [ Prop "flex-grow" (String.fromInt (f * 100000))
                            ]
                    )
                    (List.range 1 10)
                )
            , Child (dot classes.container)
                [ Prop "flex-grow" "0"
                , Prop "flex-basis" "auto"
                , Prop "align-self" "stretch"
                ]

            -- , Child "alignLeft:last-of-type.align-container-left"
            --     [ Prop "flex-grow" "1"
            --     ]
            -- alignRight -> <u>
            --centerX -> <s>
            , Child ("u:first-of-type." ++ classes.alignContainerRight)
                [ Prop "flex-grow" "1"
                ]

            -- first center y
            , Child ("s:first-of-type." ++ classes.alignContainerCenterX)
                [ Prop "flex-grow" "1"
                , Child (dot classes.alignCenterX)
                    [ Prop "margin-left" "auto !important"
                    ]
                ]
            , Child ("s:last-of-type." ++ classes.alignContainerCenterX)
                [ Prop "flex-grow" "1"
                , Child (dot classes.alignCenterX)
                    [ Prop "margin-right" "auto !important"
                    ]
                ]

            -- lonley centerX
            , Child ("s:only-of-type." ++ classes.alignContainerCenterX)
                [ Prop "flex-grow" "1"
                , Child (dot classes.alignCenterY)
                    [ Prop "margin-top" "auto !important"
                    , Prop "margin-bottom" "auto !important"
                    ]
                ]

            -- alignBottom's after a centerX should not grow
            , Child
                ("s:last-of-type." ++ classes.alignContainerCenterX ++ " ~ u")
                [ Prop "flex-grow" "0"
                ]

            -- centerX's after an alignBottom should be ignored
            , Child ("u:first-of-type." ++ classes.alignContainerRight ++ " ~ s." ++ classes.alignContainerCenterX)
                -- Bottom alignment always overrides center alignment
                [ Prop "flex-grow" "0"
                ]
            , describeAlignment <|
                \alignment ->
                    case alignment of
                        Top ->
                            ( [ Prop "align-items" "flex-start" ]
                            , [ Prop "align-self" "flex-start"
                              ]
                            )

                        Bottom ->
                            ( [ Prop "align-items" "flex-end" ]
                            , [ Prop "align-self" "flex-end"
                              ]
                            )

                        Right ->
                            ( [ Prop "justify-content" "flex-end"
                              ]
                            , []
                            )

                        Left ->
                            ( [ Prop "justify-content" "flex-start"
                              ]
                            , []
                            )

                        CenterX ->
                            ( [ Prop "justify-content" "center"
                              ]
                            , []
                            )

                        CenterY ->
                            ( [ Prop "align-items" "center" ]
                            , [ Prop "align-self" "center"
                              ]
                            )

            -- Must be below the alignment rules or else it interferes
            , Descriptor (dot classes.spaceEvenly)
                [ Prop "justify-content" "space-between"
                ]
            , Descriptor (dot classes.inputLabel)
                [ Prop "align-items" "baseline"
                ]

            -- the wrapped row element is controlled entirely by elm-ui
            , Descriptor (dot classes.wrapped)
                [ Prop "pointer-events" "none"
                , Child (dot classes.any)
                    [ Prop "pointer-events" "auto"
                    ]
                ]
            ]
        , Descriptor (dot classes.column)
            [ Prop "display" "flex"
            , Prop "flex-direction" "column"
            , Child (dot classes.any)
                -- *Note* - While rows have flex-basis 0%,
                -- which allows for the children of a row to default to their content size
                -- This apparently is a different story for columns.
                -- Safari has an issue if this is flex-basis: 0%, as it goes entirely to 0,
                -- instead of the expected content size.
                [ Prop "flex-basis" "auto"
                ]

            -- , Child (dot classes.heightFill)
            --     [ Prop "flex-grow" "100000"
            --     ]
            , Batch
                (List.map
                    (\f ->
                        Child (dot classes.heightFillPortion ++ "-" ++ String.fromInt f)
                            [ Prop "flex-grow" (String.fromInt (f * 100000))
                            ]
                    )
                    (List.range 1 10)
                )
            , Child (dot classes.widthFill)
                [ -- alignLeft, alignRight, centerX need to be disabled
                  --   Prop "align-self" "stretch !important"
                  Prop "width" "100%"
                ]
            , Child (dot classes.widthFillPortion)
                [ -- alignLeft, alignRight, centerX need to be disabled
                  --   Prop "align-self" "stretch !important"
                  Prop "width" "100%"
                ]

            -- TODO:: This might be necessary, maybe it should move to widthFill?
            -- , Child (dot classes.widthFill)
            --     [ Prop "align-self" "stretch"
            --     , Descriptor (dot classes.alignedHorizontally)
            --         [ Prop "width" "100%"
            --         ]
            --     ]
            , Child (dot classes.widthContent)
                [ Prop "align-self" "flex-start"
                ]

            -- , Child "alignTop:last-of-type.align-container-top"
            --     [ Prop "flex-grow" "1"
            --     ]
            , Child ("u:first-of-type." ++ classes.alignContainerBottom)
                [ Prop "flex-grow" "1"
                ]

            -- centerY -> <s>
            -- alignBottom -> <u>
            -- first center y
            , Child ("s:first-of-type." ++ classes.alignContainerCenterY)
                [ Prop "flex-grow" "1"
                , Child (dot classes.alignCenterY)
                    [ Prop "margin-top" "auto !important"
                    , Prop "margin-bottom" "0 !important"
                    ]
                ]
            , Child ("s:last-of-type." ++ classes.alignContainerCenterY)
                [ Prop "flex-grow" "1"
                , Child (dot classes.alignCenterY)
                    [ Prop "margin-bottom" "auto !important"
                    , Prop "margin-top" "0 !important"
                    ]
                ]

            -- lonley centerY
            , Child ("s:only-of-type." ++ classes.alignContainerCenterY)
                [ Prop "flex-grow" "1"
                , Child (dot classes.alignCenterY)
                    [ Prop "margin-top" "auto !important"
                    , Prop "margin-bottom" "auto !important"
                    ]
                ]

            -- alignBottom's after a centerY should not grow
            , Child ("s:last-of-type." ++ classes.alignContainerCenterY ++ " ~ u")
                [ Prop "flex-grow" "0"
                ]

            -- centerY's after an alignBottom should be ignored
            , Child ("u:first-of-type." ++ classes.alignContainerBottom ++ " ~ s." ++ classes.alignContainerCenterY)
                -- Bottom alignment always overrides center alignment
                [ Prop "flex-grow" "0"
                ]
            , describeAlignment <|
                \alignment ->
                    case alignment of
                        Top ->
                            ( [ Prop "justify-content" "flex-start" ]
                            , [ Prop "margin-bottom" "auto" ]
                            )

                        Bottom ->
                            ( [ Prop "justify-content" "flex-end" ]
                            , [ Prop "margin-top" "auto" ]
                            )

                        Right ->
                            ( [ Prop "align-items" "flex-end" ]
                            , [ Prop "align-self" "flex-end" ]
                            )

                        Left ->
                            ( [ Prop "align-items" "flex-start" ]
                            , [ Prop "align-self" "flex-start" ]
                            )

                        CenterX ->
                            ( [ Prop "align-items" "center" ]
                            , [ Prop "align-self" "center"
                              ]
                            )

                        CenterY ->
                            ( [ Prop "justify-content" "center" ]
                            , []
                            )
            , Child (dot classes.container)
                [ Prop "flex-grow" "0"
                , Prop "flex-basis" "auto"
                , Prop "width" "100%"
                , Prop "align-self" "stretch !important"
                ]
            , Descriptor (dot classes.spaceEvenly)
                [ Prop "justify-content" "space-between"
                ]
            ]
        , Descriptor (dot classes.grid)
            [ Prop "display" "-ms-grid"
            , Child ".gp"
                [ Child (dot classes.any)
                    [ Prop "width" "100%"
                    ]
                ]
            , Prop "display" "grid"
            , gridAlignments <|
                \alignment ->
                    case alignment of
                        Top ->
                            [ Prop "justify-content" "flex-start" ]

                        Bottom ->
                            [ Prop "justify-content" "flex-end" ]

                        Right ->
                            [ Prop "align-items" "flex-end" ]

                        Left ->
                            [ Prop "align-items" "flex-start" ]

                        CenterX ->
                            [ Prop "align-items" "center" ]

                        CenterY ->
                            [ Prop "justify-content" "center" ]
            ]
        , Descriptor (dot classes.page)
            [ Prop "display" "block"
            , Child (dot <| classes.any ++ ":first-child")
                [ Prop "margin" "0 !important"
                ]

            -- clear spacing of any subsequent element if an element is float-left
            , Child (dot <| classes.any ++ selfName (Self Left) ++ ":first-child + ." ++ classes.any)
                [ Prop "margin" "0 !important"
                ]
            , Child (dot <| classes.any ++ selfName (Self Right) ++ ":first-child + ." ++ classes.any)
                [ Prop "margin" "0 !important"
                ]
            , describeAlignment <|
                \alignment ->
                    case alignment of
                        Top ->
                            ( []
                            , []
                            )

                        Bottom ->
                            ( []
                            , []
                            )

                        Right ->
                            ( []
                            , [ Prop "float" "right"
                              , Descriptor "::after"
                                    [ Prop "content" "\"\""
                                    , Prop "display" "table"
                                    , Prop "clear" "both"
                                    ]
                              ]
                            )

                        Left ->
                            ( []
                            , [ Prop "float" "left"
                              , Descriptor "::after"
                                    [ Prop "content" "\"\""
                                    , Prop "display" "table"
                                    , Prop "clear" "both"
                                    ]
                              ]
                            )

                        CenterX ->
                            ( []
                            , []
                            )

                        CenterY ->
                            ( []
                            , []
                            )
            ]
        , Descriptor (dot classes.inputMultiline)
            [ Prop "white-space" "pre-wrap !important"
            , Prop "height" "100%"
            , Prop "width" "100%"
            , Prop "background-color" "transparent"
            ]
        , Descriptor (dot classes.inputMultilineWrapper)
            -- Get this.
            -- This allows multiline input to anchor scrolling to the bottom of the node
            -- when in a scrolling viewport, and the user is adding content.
            -- however, it only works in chrome.  In firefox, it prevents scrolling.
            --
            -- But how crazy is this solution?
            -- [ Prop "display" "flex"
            -- , Prop "flex-direction" "column-reverse"
            -- ]
            [ -- to increase specificity to beat another rule
              Descriptor (dot classes.single)
                [ Prop "flex-basis" "auto" ]
            ]
        , Descriptor (dot classes.inputMultilineParent)
            [ Prop "white-space" "pre-wrap !important"
            , Prop "cursor" "text"
            , Child (dot classes.inputMultilineFiller)
                [ Prop "white-space" "pre-wrap !important"
                , Prop "color" "transparent"
                ]
            ]
        , Descriptor (dot classes.paragraph)
            [ Prop "display" "block"
            , Prop "white-space" "normal"
            , Prop "overflow-wrap" "break-word"
            , Descriptor (dot classes.hasBehind)
                [ Prop "z-index" "0"
                , Child (dot classes.behind)
                    [ Prop "z-index" "-1"
                    ]
                ]
            , AllChildren (dot classes.text)
                [ Prop "display" "inline"
                , Prop "white-space" "normal"
                ]
            , AllChildren (dot classes.paragraph)
                [ Prop "display" "inline"
                , Descriptor "::after"
                    [ Prop "content" "none"
                    ]
                , Descriptor "::before"
                    [ Prop "content" "none"
                    ]
                ]
            , AllChildren (dot classes.single)
                [ Prop "display" "inline"
                , Prop "white-space" "normal"

                -- Inline block allows the width of the item to be set
                -- but DOES NOT like wrapping text in a standard, normal, sane way.
                -- We're sorta counting that if an exact width has been set,
                -- people aren't expecting proper text wrapping for this element
                , Descriptor (dot classes.widthExact)
                    [ Prop "display" "inline-block"
                    ]
                , Descriptor (dot classes.nearby)
                    [ Prop "display" "flex"
                    ]
                , Child (dot classes.text)
                    [ Prop "display" "inline"
                    , Prop "white-space" "normal"
                    ]
                ]
            , Child (dot classes.row)
                [ Prop "display" "inline"
                ]
            , Child (dot classes.column)
                [ Prop "display" "inline-flex"
                ]
            , Child (dot classes.grid)
                [ Prop "display" "inline-grid"
                ]
            , describeAlignment <|
                \alignment ->
                    case alignment of
                        Top ->
                            ( []
                            , []
                            )

                        Bottom ->
                            ( []
                            , []
                            )

                        Right ->
                            ( []
                            , [ Prop "float" "right" ]
                            )

                        Left ->
                            ( []
                            , [ Prop "float" "left" ]
                            )

                        CenterX ->
                            ( []
                            , []
                            )

                        CenterY ->
                            ( []
                            , []
                            )
            ]
        , Descriptor ".hidden"
            [ Prop "display" "none"
            ]
        , Descriptor (dot classes.textJustify)
            [ Prop "text-align" "justify"
            ]
        , Descriptor (dot classes.textJustifyAll)
            [ Prop "text-align" "justify-all"
            ]
        , Descriptor (dot classes.textCenter)
            [ Prop "text-align" "center"
            ]
        , Descriptor (dot classes.textRight)
            [ Prop "text-align" "right"
            ]
        , Descriptor (dot classes.textLeft)
            [ Prop "text-align" "left"
            ]
        , Descriptor (dot classes.italic)
            [ Prop "font-style" "italic"
            ]
        , Descriptor (dot classes.strike)
            [ Prop "text-decoration" "line-through"
            ]
        , Descriptor (dot classes.underline)
            [ Prop "text-decoration" "underline"
            , Prop "text-decoration-skip-ink" "auto"
            , Prop "text-decoration-skip" "ink"
            ]
        , Descriptor (dot classes.underline ++ dot classes.strike)
            [ Prop "text-decoration" "line-through underline"
            , Prop "text-decoration-skip-ink" "auto"
            , Prop "text-decoration-skip" "ink"
            ]
        , Descriptor (dot classes.textUnitalicized)
            [ Prop "font-style" "normal"
            ]
        ]
    ]


elDescription =
    [ Prop "display" "flex"
    , Prop "flex-direction" "column"
    , Prop "white-space" "pre"
    , Descriptor (dot classes.hasBehind)
        [ Prop "z-index" "0"
        , Child (dot classes.behind)
            [ Prop "z-index" "-1"
            ]
        ]
    , Descriptor (dot classes.seButton)
        -- Special default for text in a button.
        -- This is overridden is they put the text inside an `el`
        [ Child (dot classes.text)
            [ Descriptor (dot classes.heightFill)
                [ Prop "flex-grow" "0"
                ]
            , Descriptor (dot classes.widthFill)
                [ Prop "align-self" "auto !important"
                ]
            ]
        ]
    , Child (dot classes.heightContent)
        [ Prop "height" "auto"
        ]
    , Child (dot classes.heightFill)
        [ Prop "flex-grow" "100000"
        ]
    , Child (dot classes.widthFill)
        [ -- alignLeft, alignRight, centerX are overridden by width.
          --   Prop "align-self" "stretch !important"
          Prop "width" "100%"
        ]
    , Child (dot classes.widthFillPortion)
        [ Prop "width" "100%"
        ]
    , Child (dot classes.widthContent)
        [ Prop "align-self" "flex-start"
        ]

    -- , Child (dot classes.widthFill)
    --     [ Prop "align-self" "stretch"
    --     , Descriptor (dot classes.alignedHorizontally)
    --         [ Prop "width" "100%"
    --         ]
    --     ]
    , describeAlignment <|
        \alignment ->
            case alignment of
                Top ->
                    ( [ Prop "justify-content" "flex-start" ]
                    , [ Prop "margin-bottom" "auto !important"
                      , Prop "margin-top" "0 !important"
                      ]
                    )

                Bottom ->
                    ( [ Prop "justify-content" "flex-end" ]
                    , [ Prop "margin-top" "auto !important"
                      , Prop "margin-bottom" "0 !important"
                      ]
                    )

                Right ->
                    ( [ Prop "align-items" "flex-end" ]
                    , [ Prop "align-self" "flex-end" ]
                    )

                Left ->
                    ( [ Prop "align-items" "flex-start" ]
                    , [ Prop "align-self" "flex-start" ]
                    )

                CenterX ->
                    ( [ Prop "align-items" "center" ]
                    , [ Prop "align-self" "center"
                      ]
                    )

                CenterY ->
                    ( [ -- Prop "justify-content" "center"
                        Child (dot classes.any)
                            [ Prop "margin-top" "auto"
                            , Prop "margin-bottom" "auto"
                            ]
                      ]
                    , [ Prop "margin-top" "auto !important"
                      , Prop "margin-bottom" "auto !important"
                      ]
                    )
    ]


variable =
    List.concat
        [ spacing
        , padding
        , transform
        , textInput
        , slider
        ]


pair : String -> String -> String
pair one two =
    one ++ " " ++ two


triple : String -> String -> String -> String
triple one two three =
    one ++ " " ++ two ++ " " ++ three


quad : String -> String -> String -> String -> String
quad one two three four =
    one ++ " " ++ two ++ " " ++ three ++ " " ++ four


pent : String -> String -> String -> String -> String -> String
pent one two three four five =
    one ++ " " ++ two ++ " " ++ three ++ " " ++ four ++ " " ++ five


prop : String -> String -> String
prop name val =
    name ++ ":" ++ val ++ ";"


set : Var -> String -> String
set (Var v) val =
    "--" ++ v ++ ":" ++ val ++ ";"


px : Int -> String
px x =
    String.fromInt x ++ "px"


floatPx : Float -> String
floatPx x =
    String.fromFloat x ++ "px"


rad : Float -> String
rad x =
    String.fromFloat x ++ "rad"


type alias Shadow =
    { x : Float
    , y : Float
    , size : Float
    , blur : Float
    , color : Color
    }


innerShadows : List Shadow -> String
innerShadows shades =
    List.foldl joinInnerShadows "" shades


joinInnerShadows shadow rendered =
    if String.isEmpty rendered then
        "inset " ++ singleShadow shadow

    else
        rendered ++ ", inset" ++ singleShadow shadow


shadows : List Shadow -> String
shadows shades =
    List.foldl joinShadows "" shades


joinShadows shadow rendered =
    if String.isEmpty rendered then
        singleShadow shadow

    else
        rendered ++ "," ++ singleShadow shadow


singleShadow : Shadow -> String
singleShadow shadow =
    pent
        (floatPx shadow.x)
        (floatPx shadow.y)
        (floatPx shadow.blur)
        (floatPx shadow.size)
        (color shadow.color)


color : Color -> String
color (Rgb red green blue) =
    "rgb("
        ++ String.fromInt red
        ++ ("," ++ String.fromInt green)
        ++ ("," ++ String.fromInt blue)
        ++ ")"


transform =
    [ Class (dot classes.transform)
        [-- Variable "transform" vars.moveX
         -- (rotate scale trasnform)
        ]
    ]


padding =
    [-- Class (dot classes.padding)
     -- [ Prop "padding"
     --     (quad
     --         (renderVar vars.padTop)
     --         (renderVar vars.padRight)
     --         (renderVar vars.padBottom)
     --         (renderVar vars.padLeft)
     --     )
     -- ]
    ]


slider =
    let
        props =
            [ Prop "width" "16px"
            , Prop "height" "16px"
            ]
    in
    [ Class ("input[type=\"range\"]." ++ classes.slider ++ "::-moz-range-thumb")
        props
    , Class ("input[type=\"range\"]." ++ classes.slider ++ "::-webkit-slider-thumb")
        props
    , Class ("input[type=\"range\"]." ++ classes.slider ++ "::-ms-thumb")
        props
    ]


spacing =
    [ Class (dot classes.spacing)
        [ Descriptor (dot classes.row)
            [ Descriptor (dot classes.nowrap)
                [ Child (dot classes.any)
                    [ Descriptor ":first-child"
                        [ Prop "margin" "0 !important"
                        ]
                    , Adjacent (dot classes.any)
                        [ Prop "margin-top" "0 !important"
                        , Prop "margin-right" "0 !important"
                        , Prop "margin-bottom" "0 !important"
                        ]
                    ]
                , Child (dot classes.nearby)
                    [ Adjacent (dot classes.any)
                        [ Prop "margin" "0 !important"
                        ]
                    ]
                ]
            , Descriptor (dot classes.wrapped)
                [ Child (dot classes.any)
                    [ Prop "margin-top" "0 !important"
                    , Prop "margin-left" "0 !important"
                    ]
                ]
            ]
        , Descriptor (dot classes.column)
            [ Child (dot classes.any)
                [ Descriptor ":first-child"
                    [ Prop "margin" "0 !important"
                    ]
                , Adjacent (dot classes.any)
                    [ Prop "margin-left" "0 !important"
                    , Prop "margin-right" "0 !important"
                    , Prop "margin-bottom" "0 !important"
                    ]
                ]
            , Child (dot classes.nearby)
                [ Adjacent (dot classes.any)
                    [ Prop "margin" "0 !important"
                    ]
                ]
            ]

        -- , Descriptor (dot classes.page)
        --     [ Child (dot classes.any)
        --         [ Adjacent (dot classes.any)
        --             [ Variable "margin-top" vars.spaceY
        --             ]
        --         ]
        --     , Child (dot classes.alignLeft)
        --         [ Variable "margin-right" vars.spaceX
        --         ]
        --     , Child (dot classes.alignRight)
        --         [ Variable "margin-left" vars.spaceX
        --         ]
        --     ]
        -- , Descriptor (dot classes.paragraph)
        --     [ Child (dot classes.alignLeft)
        --         [ Variable "margin-right" vars.spaceX
        --         ]
        --     , Child (dot classes.alignRight)
        --         [ Variable "margin-left" vars.spaceX
        --         ]
        --     , Variable "margin-right" vars.spaceX
        --     , Variable "margin-bottom" vars.spaceY
        --     , Calc "line-height" (Add (CalcVal "1em") (CalcVar vars.spaceY))
        --     , Descriptor "::after"
        --         [ Prop "content" "''"
        --         , Prop "display" "block"
        --         , Prop "height" "0"
        --         , Prop "width" "0"
        --         , Calc "margin-top"
        --             (Multiply
        --                 (CalcVal "-1")
        --                 (Divide (CalcVar vars.spaceY) (CalcVal "2"))
        --             )
        --         ]
        --     , Descriptor "::before"
        --         [ Prop "content" "''"
        --         , Prop "display" "block"
        --         , Prop "height" "0"
        --         , Prop "width" "0"
        --         , Calc "margin-bottom"
        --             (Multiply
        --                 (CalcVal "-1")
        --                 (Divide (CalcVar vars.spaceY) (CalcVal "2"))
        --             )
        --         ]
        --     ]
        ]

    -- , Class
    --     ("textarea" ++ dot classes.any ++ dot classes.spacing)
    --     [ Calc "line-height"
    --         (Add
    --             (CalcVal "1em")
    --             (CalcVar vars.spaceY)
    --         )
    --     , Calc "height"
    --         (Add
    --             (CalcVal "100%")
    --             (CalcVar vars.spaceY)
    --         )
    --     ]
    --     Class (dot classes.spacing)
    --     [ Descriptor (dot classes.row)
    --         [ Child (dot classes.any)
    --             [ Adjacent (dot classes.any)
    --                 [
    --                     Variable "margin-left" vars.spaceX
    --                 ]
    --             ]
    --         , Descriptor
    --             (dot classes.wrapped)
    --             [ Child (dot classes.any)
    --                 [ CalcPair "margin"
    --                     (Divide (CalcVar vars.spaceY) (CalcVal "2"))
    --                     (Divide (CalcVar vars.spaceX) (CalcVal "2"))
    --                 ]
    --             ]
    --         ]
    --     , Descriptor (dot classes.column)
    --         [ Child (dot classes.any)
    --             [ Adjacent (dot classes.any)
    --                 [ Variable "margin-top" vars.spaceY
    --                 ]
    --             ]
    --         ]
    --     , Descriptor (dot classes.page)
    --         [ Child (dot classes.any)
    --             [ Adjacent (dot classes.any)
    --                 [ Variable "margin-top" vars.spaceY
    --                 ]
    --             ]
    --         , Child (dot classes.alignLeft)
    --             [ Variable "margin-right" vars.spaceX
    --             ]
    --         , Child (dot classes.alignRight)
    --             [ Variable "margin-left" vars.spaceX
    --             ]
    --         ]
    --     , Descriptor (dot classes.paragraph)
    --         [ Child (dot classes.alignLeft)
    --             [ Variable "margin-right" vars.spaceX
    --             ]
    --         , Child (dot classes.alignRight)
    --             [ Variable "margin-left" vars.spaceX
    --             ]
    --         , Variable "margin-right" vars.spaceX
    --         , Variable "margin-bottom" vars.spaceY
    --         , Calc "line-height" (Add (CalcVal "1em") (CalcVar vars.spaceY))
    --         , Descriptor "::after"
    --             [ Prop "content" "''"
    --             , Prop "display" "block"
    --             , Prop "height" "0"
    --             , Prop "width" "0"
    --             , Calc "margin-top"
    --                 (Multiply
    --                     (CalcVal "-1")
    --                     (Divide (CalcVar vars.spaceY) (CalcVal "2"))
    --                 )
    --             ]
    --         , Descriptor "::before"
    --             [ Prop "content" "''"
    --             , Prop "display" "block"
    --             , Prop "height" "0"
    --             , Prop "width" "0"
    --             , Calc "margin-bottom"
    --                 (Multiply
    --                     (CalcVal "-1")
    --                     (Divide (CalcVar vars.spaceY) (CalcVal "2"))
    --                 )
    --             ]
    --         ]
    --     ]
    -- , Class
    --     ("textarea" ++ dot classes.any ++ dot classes.spacing)
    --     [ Calc "line-height"
    --         (Add
    --             (CalcVal "1em")
    --             (CalcVar vars.spaceY)
    --         )
    --     , Calc "height"
    --         (Add
    --             (CalcVal "100%")
    --             (CalcVar vars.spaceY)
    --         )
    --     ]
    ]



{- Rules:

       <input> ->
           line-height:  ("calc(1.0em + " ++ String.fromFloat (2 * min padding.top padding.bottom) ++ "px)")
           padding: (t - min t b) right (b - min t b) left

       border-width:
           -> parent ++ cover
       transform:
           -> parent ++ cover


   Approach ->

       All style classes for a text input are assigned to inputTextParent.
            The parent itself needs to 'forward' some of these properties to certain children.

            1. Font attributes are generally inherited.
                Font alignment likely needs to be forwarded though.

            2. Borders
                Border width ->
                    x -> parent
                    y -> inputParent
                    y -> cover

            3. Padding
                x -> parent
                y -> inputParent
                y -> cover
                if single line -> do math involving line-height

            4. Transform
                 x -> parent
                    y -> inputParent
                    y -> cover

            5. width/height



-}


textInput =
    -- the parent of the label + input + placeholder
    [ Class (dot classes.inputTextParent)
        [ Prop "padding" "0 !important"
        , Prop "border-width" "0 !important"
        , Prop "transform" "none"
        ]
    , Class (dot classes.inputText)
        [ Prop "background-color" "rgba(255,255,255,0)"
        ]

    -- the parent of just input + placeholder
    -- , Class (dot classes.inputTextInputWrapper)
    --     [ Prop "padding-top" "0"
    --     , Prop "padding-bottom" "0"
    --     , Variable "padding-left" vars.padLeft
    --     , Variable "padding-right" vars.padRight
    --     ]
    -- -- the input itself
    -- , Class (dot classes.inputText)
    --     [ -- chrome and safari have a minimum recognized line height for text input of 1.05
    --       -- If it's 1, it bumps up to something like 1.2
    --       --   Prop "line-height" "1.05"
    --       -- ,
    --       Prop "background" "transparent"
    --     , Prop "text-align" "inherit"
    --     , Calc "height"
    --         (Add
    --             (CalcVal "1.0em")
    --             (Add
    --                 (CalcVar vars.padTop)
    --                 (CalcVar vars.padBottom)
    --             )
    --         )
    --     , Calc "line-height"
    --         (Add
    --             (CalcVal "1.0em")
    --             (Add
    --                 (CalcVar vars.padTop)
    --                 (CalcVar vars.padBottom)
    --             )
    --         )
    --     ]
    -- TODO!
    -- add scrollbars to textarea if height is constrained
    ]



{- RENDERERS -}


type Intermediate
    = Intermediate IntermediateDetails


type alias IntermediateDetails =
    { selector : String
    , props : List ( String, String )
    , closing : String
    , others : List Intermediate
    }


emptyIntermediate : String -> String -> Intermediate
emptyIntermediate selector closing =
    Intermediate
        { selector = selector
        , props = []
        , closing = closing
        , others = []
        }


renderRules : Intermediate -> List Rule -> Intermediate
renderRules (Intermediate parent) rulesToRender =
    Intermediate <| List.foldr (generateIntermediates parent) parent rulesToRender


renderVar : Var -> String
renderVar (Var var) =
    "var(--" ++ var ++ ")"


renderCalc : Calc -> String
renderCalc calc =
    "calc(" ++ renderCalcTerms calc ++ ")"


renderCalcTerms : Calc -> String
renderCalcTerms calc =
    case calc of
        Add one two ->
            renderCalcTerms one ++ " + " ++ renderCalcTerms two

        Minus one two ->
            renderCalcTerms one ++ " - " ++ renderCalcTerms two

        Multiply one two ->
            renderCalcTerms one ++ " * " ++ renderCalcTerms two

        Divide one two ->
            renderCalcTerms one ++ " / " ++ renderCalcTerms two

        CalcVar var ->
            renderVar var

        CalcVal val ->
            val


generateIntermediates : IntermediateDetails -> Rule -> IntermediateDetails -> IntermediateDetails
generateIntermediates parent rule rendered =
    case rule of
        Prop name val ->
            { rendered | props = ( name, val ) :: rendered.props }

        Variable name var ->
            { rendered | props = ( name, renderVar var ) :: rendered.props }

        Calc name calc ->
            { rendered | props = ( name, renderCalc calc ) :: rendered.props }

        CalcPair name one two ->
            { rendered
                | props =
                    ( name, renderCalc one ++ " " ++ renderCalc two )
                        :: rendered.props
            }

        Adjacent selector adjRules ->
            { rendered
                | others =
                    renderRules
                        (emptyIntermediate (parent.selector ++ " + " ++ selector) "")
                        adjRules
                        :: rendered.others
            }

        Child child childRules ->
            { rendered
                | others =
                    renderRules
                        (emptyIntermediate (parent.selector ++ " > " ++ child) "")
                        childRules
                        :: rendered.others
            }

        AllChildren child childRules ->
            { rendered
                | others =
                    renderRules
                        (emptyIntermediate (parent.selector ++ " " ++ child) "")
                        childRules
                        :: rendered.others
            }

        Descriptor descriptor descriptorRules ->
            { rendered
                | others =
                    renderRules
                        (emptyIntermediate (parent.selector ++ descriptor) "")
                        descriptorRules
                        :: rendered.others
            }

        Batch batched ->
            { rendered
                | others =
                    renderRules (emptyIntermediate parent.selector "") batched
                        :: rendered.others
            }


render : List Class -> String
render classNames =
    let
        renderValues values =
            values
                |> List.map (\( x, y ) -> "  " ++ x ++ ": " ++ y ++ ";")
                |> String.join "\n"

        renderClass rule =
            case rule.props of
                [] ->
                    ""

                _ ->
                    rule.selector ++ " {\n" ++ renderValues rule.props ++ rule.closing ++ "\n}"

        renderIntermediate (Intermediate rule) =
            renderClass rule
                ++ String.join "\n" (List.map renderIntermediate rule.others)
    in
    classNames
        |> List.foldr
            (\(Class name styleRules) existing ->
                renderRules (emptyIntermediate name "") styleRules :: existing
            )
            []
        |> List.map renderIntermediate
        |> String.join "\n"


renderCompact : List Class -> String
renderCompact styleClasses =
    let
        renderValues values =
            values
                |> List.map (\( x, y ) -> x ++ ":" ++ y ++ ";")
                |> String.concat

        renderClass rule =
            case rule.props of
                [] ->
                    ""

                _ ->
                    rule.selector ++ "{" ++ renderValues rule.props ++ rule.closing ++ "}"

        renderIntermediate (Intermediate rule) =
            renderClass rule
                ++ String.concat (List.map renderIntermediate rule.others)
    in
    styleClasses
        |> List.foldr
            (\(Class name styleRules) existing ->
                renderRules (emptyIntermediate name "") styleRules :: existing
            )
            []
        |> List.map renderIntermediate
        |> String.concat
