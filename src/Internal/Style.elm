module Internal.Style exposing (classes, dot, rules)

{-| -}


type Class
    = Class String (List Rule)


type Rule
    = Prop String String
    | Child String (List Rule)
    | AllChildren String (List Rule)
    | Supports ( String, String ) (List ( String, String ))
    | Descriptor String (List Rule)
    | Adjacent String (List Rule)
    | Batch (List Rule)


type StyleClasses
    = Root
    | Any
    | Single
    | Row
    | Column
    | Paragraph
    | Page
    | Text
    | Grid
    | Spacer



-- lengths


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
    , wrapped = "wrp"

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
    , spaceEvenly = "sev"
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

    -- , hoverOpaque = "hover-opaque"
    , focus = "fcs"
    , focusedWithin = "focus-within"

    -- , focusOpaque = "focus-opaque"
    , active = "atv"

    -- , activeOpaque = "active-opaque"
    --scrollbars
    , scrollbars = "sb"
    , scrollbarsX = "sbx"
    , scrollbarsY = "sby"
    , clip = "cp"
    , clipX = "cpx"
    , clipY = "cpy"

    -- borders
    , borderNone = "bn"
    , borderDashed = "bd"
    , borderDotted = "bdt"
    , borderSolid = "bs"

    -- text weight
    , sizeByCapital = "cap"
    , fullSize = "fs"
    , textThin = "w1"
    , textExtraLight = "w2"
    , textLight = "w3"
    , textNormalWeight = "w4"
    , textMedium = "w5"
    , textSemiBold = "w6"
    , bold = "w7"
    , textExtraBold = "w8"
    , textHeavy = "w9"
    , italic = "i"
    , strike = "sk"
    , underline = "u"
    , textUnitalicized = "tun"

    -- text alignment
    , textJustify = "tj"
    , textJustifyAll = "tja"
    , textCenter = "tc"
    , textRight = "tr"
    , textLeft = "tl"
    , transition = "ts"

    -- inputText
    , inputText = "it"
    , inputMultiline = "iml"
    , inputMultilineParent = "imlp"
    , inputMultilineFiller = "imlf"
    , inputMultilineWrapper = "implw"
    , inputLabel = "lbl"

    -- link
    , link = "lnk"
    }


{-| The indulgent unicode character version.
-}
unicode =
    { root = "style-elements"
    , any = "s"
    , single = "e"
    , row = "⋯"
    , column = "⋮"
    , page = "🗏"
    , paragraph = "p"
    , text = "text"
    , grid = "▦"

    -- widhts/heights
    , widthFill = "↔"
    , widthContent = "width-content"
    , widthExact = "width-exact"
    , heightFill = "↕"
    , heightContent = "height-content"
    , heightExact = "height-exact"

    -- nearby elements
    , above = "above"
    , below = "below"
    , onRight = "on-right"
    , onLeft = "on-left"
    , inFront = "infront"
    , behind = "behind"

    -- alignments
    , alignTop = "⤒"
    , alignBottom = "⤓"
    , alignRight = "⇥"
    , alignLeft = "⇤"
    , alignCenterX = "self-center-x"
    , alignCenterY = "self-center-y"

    -- space evenly
    , spaceEvenly = "space-evenly"
    , container = "container"

    -- content alignments
    , contentTop = "content-top"
    , contentBottom = "content-bottom"
    , contentRight = "content-right"
    , contentLeft = "content-left"
    , contentCenterX = "content-center-x"
    , contentCenterY = "content-center-y"

    -- selection
    , noTextSelection = "no-text-selection"
    , cursorPointer = "cursor-pointer"
    , cursorText = "cursor-text"

    -- pointer events
    , passPointerEvents = "pass-pointer-events"
    , capturePointerEvents = "capture-pointer-events"
    , transparent = "transparent"
    , opaque = "opaque"

    --scrollbars
    , scrollbars = "scrollbars"
    , scrollbarsX = "scrollbars-x"
    , scrollbarsY = "scrollbars-y"
    , clip = "✂"
    , clipX = "✂x"
    , clipY = "✂y"

    -- borders
    , borderNone = "border-none"
    , borderDashed = "border-dashed"
    , borderDotted = "border-dotted"
    , borderSolid = "border-solid"

    -- text weight
    , textThin = "text-thin"
    , textExtraLight = "text-extra-light"
    , textLight = "text-light"
    , textNormalWeight = "text-normal-weight"
    , textMedium = "text-medium"
    , textSemiBold = "text-semi-bold"
    , bold = "bold"
    , textExtraBold = "text-extra-bold"
    , textHeavy = "text-heavy"
    , italic = "italic"
    , strike = "strike"
    , underline = "underline"
    , textUnitalicized = "text-unitalicized"

    -- text alignment
    , textJustify = "text-justify"
    , textJustifyAll = "text-justify-all"
    , textCenter = "text-center"
    , textRight = "text-right"
    , textLeft = "text-left"
    }


single =
    { root = "z"
    , any = "s"
    , single = "e"
    , row = "r"
    , column = "c"
    , page = "l"
    , paragraph = "p"
    , text = "t"
    , grid = "g"

    -- widhts/heights
    , widthFill = "↔"
    , widthContent = "wc"
    , widthExact = "w"
    , heightFill = "↕"
    , heightContent = "hc"
    , heightExact = "h"

    -- nearby elements
    , above = "o"
    , below = "u"
    , onRight = "r"
    , onLeft = "l"
    , inFront = "f"
    , behind = "b"

    -- alignments
    , alignTop = "⤒"
    , alignBottom = "⤓"
    , alignRight = "⇥"
    , alignLeft = "⇤"
    , alignCenterX = "self-center-x"
    , alignCenterY = "self-center-y"

    -- space evenly
    , spaceEvenly = "space-evenly"
    , container = "container"

    -- content alignments
    , contentTop = "c⤒"
    , contentBottom = "c⤓"
    , contentRight = "c⇥"
    , contentLeft = "c⇤"
    , contentCenterX = "content-center-x"
    , contentCenterY = "content-center-y"

    -- selection
    , noTextSelection = "no-text-selection"
    , cursorPointer = "cursor-pointer"
    , cursorText = "cursor-text"

    -- pointer events
    , passPointerEvents = "pass-pointer-events"
    , capturePointerEvents = "capture-pointer-events"
    , transparent = "transparent"
    , opaque = "opaque"

    --scrollbars
    , scrollbars = "scrollbars"
    , scrollbarsX = "scrollbars-x"
    , scrollbarsY = "scrollbars-y"
    , clip = "✂"
    , clipX = "✂x"
    , clipY = "✂y"

    -- borders
    , borderNone = "border-none"
    , borderDashed = "border-dashed"
    , borderDotted = "border-dotted"
    , borderSolid = "border-solid"

    -- text weight
    , textThin = "text-thin"
    , textExtraLight = "text-extra-light"
    , textLight = "text-light"
    , textNormalWeight = "text-normal-weight"
    , textMedium = "text-medium"
    , textSemiBold = "text-semi-bold"
    , bold = "b"
    , textExtraBold = "text-extra-bold"
    , textHeavy = "text-heavy"
    , italic = "i"
    , strike = "-"
    , underline = "u"
    , textUnitalicized = "text-unitalicized"

    -- text alignment
    , textJustify = "text-justify"
    , textJustifyAll = "text-justify-all"
    , textCenter = "text-center"
    , textRight = "text-right"
    , textLeft = "text-left"
    }


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


type Intermediate
    = Intermediate
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
    let
        generateIntermediates rule rendered =
            case rule of
                Prop name val ->
                    { rendered | props = ( name, val ) :: rendered.props }

                Supports ( prop, value ) props ->
                    { rendered
                        | others =
                            Intermediate
                                { selector = "@supports (" ++ prop ++ ":" ++ value ++ ") {" ++ parent.selector
                                , props = props
                                , closing = "\n}"
                                , others = []
                                }
                                :: rendered.others
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
    in
    Intermediate <| List.foldr generateIntermediates parent rulesToRender


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


viewportRules : String
viewportRules =
    """html, body {
    height: 100%;
    width: 100%;
} """ ++ rules


describeText : String -> List Rule -> Rule
describeText cls props =
    Descriptor cls
        (List.map makeImportant props
            ++ [ Child ".text"
                    props
               , Child ".el"
                    props
               , Child ".el > .text"
                    props
               ]
        )


makeImportant : Rule -> Rule
makeImportant rule =
    case rule of
        Prop name prop ->
            Prop name (prop ++ " !important")

        _ ->
            rule


dot c =
    "." ++ c


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
  outline: dashed 1px;
  height: 100%;
  opacity: 0;
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
    """
input[type=range]::-webkit-slider-thumb {
    -webkit-appearance: none;
    opacity: 0.5;
    width: 80px;
    height: 80px;
    background-color: black;
    border:none;
    border-radius: 5px;
}
input[type=range]::-moz-range-thumb {
    opacity: 0.5;
    width: 80px;
    height: 80px;
    background-color: black;
    border:none;
    border-radius: 5px;
}
input[type=range]::-ms-thumb {
    opacity: 0.5;
    width: 80px;
    height: 80px;
    background-color: black;
    border:none;
    border-radius: 5px;
}
input[type=range][orient=vertical]{
    writing-mode: bt-lr; /* IE */
    -webkit-appearance: slider-vertical;  /* WebKit */
}
"""


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


commonValues =
    List.concat
        [ List.map
            (\x ->
                Class (".border-" ++ String.fromInt x) [ Prop "border-width" (String.fromInt x ++ "px") ]
            )
            (List.range 0 6)
        , List.map
            (\i ->
                Class (".font-size-" ++ String.fromInt i) [ Prop "font-size" (String.fromInt i ++ "px") ]
            )
            (List.range 8 32)
        , List.map
            (\i ->
                Class (".p-" ++ String.fromInt i) [ Prop "padding" (String.fromInt i ++ "px") ]
            )
            (List.range 0 24)

        -- Common Font Variants
        , [ Class ".v-smcp"
                [ Prop "font-variant" "small-caps"
                ]
          , Class ".v-smcp-off"
                [ Prop "font-variant" "normal"
                ]
          ]

        -- , fontVariant "smcp"
        , fontVariant "zero"
        , fontVariant "onum"
        , fontVariant "liga"
        , fontVariant "dlig"
        , fontVariant "ordn"
        , fontVariant "tnum"
        , fontVariant "afrc"
        , fontVariant "frac"
        ]


fontVariant var =
    [ Class (".v-" ++ var)
        [ Prop "font-feature-settings" ("\"" ++ var ++ "\"")
        ]
    , Class (".v-" ++ var ++ "-off")
        [ Prop "font-feature-settings" ("\"" ++ var ++ "\" 0")
        ]
    ]


rules : String
rules =
    overrides
        ++ renderCompact (baseSheet ++ commonValues)


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
        , Descriptor (dot classes.borderNone)
            [ Prop "border-width" "0"
            ]
        , Descriptor (dot classes.borderDashed)
            [ Prop "border-style" "dashed"
            ]
        , Descriptor (dot classes.borderDotted)
            [ Prop "border-style" "dotted"
            ]
        , Descriptor (dot classes.borderSolid)
            [ Prop "border-style" "solid"
            ]
        , Descriptor (dot classes.text)
            [ Prop "white-space" "pre"
            , Prop "display" "inline-block"
            ]
        , Descriptor (dot classes.inputText)
            -- chrome and safari have a minimum recognized line height for text input of 1.05
            -- If it's 1, it bumps up to something like 1.2
            [ Prop "line-height" "1.05"
            , Prop "background" "transparent"
            , Prop "text-align" "inherit"
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
            , Child (dot classes.widthFill)
                [ Prop "flex-grow" "100000"
                ]
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
                -- So we add `min-height: min-content`, which isn't supported by IE, but works for all other browsers!
                -- Separately, 0% is different than 0px, but only for columns
                -- In columns, 0% will actually be calculated as `auto` for columns
                -- So, 0px is the one we want.
                [ Prop "flex-basis" "0px"
                , Prop "min-height" "min-content"
                , Descriptor (dot classes.heightExact)
                    [ Prop "flex-basis" "auto"
                    ]
                ]
            , Child (dot classes.heightFill)
                [ Prop "flex-grow" "100000"
                ]
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
            , Supports ( "display", "grid" )
                [ ( "display", "grid" )
                ]
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
                , Descriptor (dot classes.inFront)
                    [ Prop "display" "flex"
                    ]
                , Descriptor (dot classes.behind)
                    [ Prop "display" "flex"
                    ]
                , Descriptor (dot classes.above)
                    [ Prop "display" "flex"
                    ]
                , Descriptor (dot classes.below)
                    [ Prop "display" "flex"
                    ]
                , Descriptor (dot classes.onRight)
                    [ Prop "display" "flex"
                    ]
                , Descriptor (dot classes.onLeft)
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
        , Descriptor (dot classes.textThin)
            [ Prop "font-weight" "100"
            ]
        , Descriptor (dot classes.textExtraLight)
            [ Prop "font-weight" "200"
            ]
        , Descriptor (dot classes.textLight)
            [ Prop "font-weight" "300"
            ]
        , Descriptor (dot classes.textNormalWeight)
            [ Prop "font-weight" "400"
            ]
        , Descriptor (dot classes.textMedium)
            [ Prop "font-weight" "500"
            ]
        , Descriptor (dot classes.textSemiBold)
            [ Prop "font-weight" "600"
            ]
        , Descriptor (dot classes.bold)
            [ Prop "font-weight" "700"
            ]
        , Descriptor (dot classes.textExtraBold)
            [ Prop "font-weight" "800"
            ]
        , Descriptor (dot classes.textHeavy)
            [ Prop "font-weight" "900"
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
        , Descriptor ".modal"
            [ Prop "position" "fixed"
            , Prop "left" "0"
            , Prop "top" "0"
            , Prop "width" "100%"
            , Prop "height" "100%"
            , Prop "pointer-events" "none"
            ]
        ]
    ]
