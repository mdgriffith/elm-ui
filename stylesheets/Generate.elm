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
    , el = "e"
    , row = "r"
    , column = "c"
    , page = "pg"
    , paragraph = "p"
    , text = "t"
    , grid = "g"
    , imageContainer = "ic"
    , nowrap = "nowrp"
    , transform = "move"
    , ellipses = "ellip"

    -- widhts/heights
    , widthFill = "wf"
    , widthContent = "wc"
    , widthExact = "we"
    , widthBounded = "wb"
    , heightFill = "hf"
    , heightContent = "hc"
    , heightExact = "he"
    , heightBounded = "hb"

    -- nearby elements
    , hasNearby = "hnb"
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

    -- space evenly
    , spacing = "spc"
    , spaceEvenly = "sev"
    , padding = "pad"

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
    , cursorGrab = "grab"
    , cursorGrabbing = "grabbing"
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

    -- line height
    , lineHeightPrefix = "lh"

    -- text alignment
    , transition = "ts"

    -- inputText
    , inputReset = "irs"
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
    , fontAdjusted = "f-adj"
    , textGradient = "tgrd"
    , stickyTop = "stick-top"
    , stickyLeft = "stick-left"
    , stickyBottom = "stick-bottom"

    -- animation triggers
    , onHovered = "on-hovered"
    , onFocused = "on-focused"
    , onFocusedWithin = "on-focused-within"
    , onPressed = "on-pressed"
    , onRendered = "on-rendered"
    , onDismout = "on-dismount"

    --
    , trigger = "ui-trigger"
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

    --
    , fontSizeFactor = Var "font-size-factor"
    , vacuumTop = Var "vacuum-top"
    , vacuumBottom = Var "vacuum-bottom"
    , visibleTop = Var "visible-top"
    , visibleBottom = Var "visible-bottom"
    }


lineHeightAdjustment : Int -> String
lineHeightAdjustment i =
    let
        -- offset would be 5 if the line-height is 1.05
        offsetInt =
            i * 5

        lineHeightOffset =
            toFloat offsetInt / 100

        offset =
            -- 0.05 line height
            -- But we need to express it as a percentage of the *existing* lineheight.
            lineHeightOffset
                / (1 + lineHeightOffset)

        offsetString =
            String.fromFloat (offset / 2)
    in
    "-" ++ offsetString ++ "lh"



{- END COPY -}


dot c =
    "." ++ c


type Class
    = Class String (List Rule)


type Rule
    = Prop String String
    | Variable String Var
    | SetVariable Var String
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


overrides : String
overrides =
    inputTextReset
        ++ sliderReset
        ++ trackReset
        ++ thumbReset
        ++ explainer
        ++ animationTriggerKeyframes


{-| This probably looks super weird!
But these animations are just used to fire animation events
NOT to actually animate anything.
They need separate names because we want to know what event occurred.
-}
animationTriggerKeyframes =
    """@keyframes on-hovered { from {} to {} }
@keyframes on-focused { from {} to {} }
@keyframes on-pressed { from {} to {} }
@keyframes on-rendered { from {} to {} }
@keyframes on-dismount { from {} to {} }"""


inputTextReset =
    """input[type="search"],
input[type="search"]::-webkit-search-decoration,
input[type="search"]::-webkit-search-cancel-button,
input[type="search"]::-webkit-search-results-button,
input[type="search"]::-webkit-search-results-decoration {
  -webkit-appearance:none;
}"""


sliderReset =
    """input[type=range] {
    -webkit-appearance: none;
    background: transparent;
    position:absolute;
    left:0;
    top:0;
    z-index:10;
    width: 100%;
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


explainerRules =
    Class ".explain"
        [ Prop "outline" "6px solid rgb(174, 121, 15) !important"
        , Child (dot classes.any)
            [ Prop "outline" "4px dashed rgb(0, 151, 167) !important"
            ]
        , AllChildren "*"
            [ Prop "animation" "show-redraw 0.4s ease"
            ]
        ]


explainer =
    """@keyframes show-redraw { 0% { background-color:red; }}"""



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


select =
    { widthFill =
        dot classes.widthFill
            ++ ":not("
            ++ String.join ", "
                [ dot classes.alignRight
                , dot classes.alignLeft
                , dot classes.alignCenterX
                ]
            ++ ")"
    , heightFill =
        dot classes.heightFill
            ++ ":not("
            ++ String.join ", "
                [ dot classes.alignTop
                , dot classes.alignBottom
                , dot classes.alignCenterY
                , dot classes.heightBounded
                ]
            ++ ")"
    }


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
    , Class (dot classes.inputReset)
        [ Prop "appearance" "none"
        , Prop "-webkit-appearance" "none"
        , Prop "-moz-appearance" "none"
        ]
    , Class (dot classes.any ++ dot classes.el ++ dot classes.imageContainer)
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
    , explainerRules
    , Class (dot classes.root)
        [ Prop "width" "100%"
        , Prop "height" "auto"
        , zIndex 0
        , Descriptor (dot classes.el)
            [ Prop "min-height" "100%"
            , Prop "font-size" "16px"
            , Prop "font-family" "\"Open Sans\", sans-serif"
            , Prop "color" "#000"
            ]

        -- Default line-height rules
        , Prop "line-height" "1.4"
        , Descriptor
            (dot classes.any
                -- ++ dot classes.el
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
    , Class (dot classes.hasNearby)
        [ Prop "position" "relative"
        ]
    , Class "li"
        [ Descriptor (dot classes.any)
            [ Descriptor (dot classes.el)
                [ Prop "display" "list-item"
                ]
            ]
        ]
    , Class (dot classes.nearby)
        [ Prop "position" "relative"
        , Prop "border" "none"
        , Prop "display" "flex"
        , Prop "flex-direction" "row"
        , Prop "flex-basis" "auto"
        , Prop "border-radius" "inherit"
        , Descriptor (dot classes.el)
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
                                , Child select.widthFill
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
    , Class (dot classes.el)
        [ Prop "flex" "0 0 0px"
        , Prop "align-items" "flex-start"
        , Prop "min-height" "min-content"
        , Prop "display" "flex"
        , Prop "flex-direction" "column"
        ]
    , Class "button"
        -- Button reset
        [ Descriptor (dot classes.any)
            [ Prop "background-color" "transparent"
            , Prop "text-align" "start"
            ]
        ]
    , Class (dot classes.any)
        [ Prop "border" "none"
        , Prop "flex-shrink" "1"
        , Prop "flex-basis" "auto"
        , Prop "display" "flex"
        , Prop "flex-direction" "row"
        , Prop "resize" "none"
        , Prop "box-sizing" "border-box"
        , Prop "margin" "0"
        , Prop "padding" "0"
        , Prop "border-width" "0"
        , Prop "border-style" "solid"

        -- https://dfmcphee.com/flex-items-and-min-width-0/
        -- https://defensivecss.dev/tip/flexbox-min-content-size/
        -- https://www.joshwcomeau.com/css/interactive-guide-to-flexbox/
        , Prop "min-width" "0"

        -- inheritable font properties
        , Prop "font-size" "inherit"
        , Prop "color" "inherit"
        , Prop "font-family" "inherit"
        , Prop "font-weight" "inherit"
        , Prop "font-feature-settings" "inherit"

        -- Text decoration is *mandatorily inherited* in the css spec.
        -- There's no way to change this.  How crazy is that?
        , Prop "text-decoration" "none"
        , Prop "font-style" "inherit"
        , Batch animationTriggers
        , Descriptor (dot classes.stickyTop)
            [ Prop "position" "sticky"
            , Prop "top" "0"
            ]
        , Descriptor (dot classes.stickyBottom)
            [ Prop "position" "sticky"

            -- there seems to be a weird issue where there is a 1px gap
            -- This solves it, but makes everyone nervous.
            , Prop "bottom" "-1px"
            ]
        , Descriptor (dot classes.stickyLeft)
            [ Prop "position" "sticky"
            , Prop "left" "0"
            ]
        , Descriptor (dot classes.textGradient)
            [ Prop "-webkit-background-clip" "text"
            , Prop "-webkit-text-fill-color" "transparent"
            ]
        , Descriptor (dot classes.fontAdjusted)
            [ Prop "font-size" "calc(1em * var(--font-size-factor))"
            ]
        , Descriptor (dot classes.text)
            [ Descriptor "::after"
                [ Prop "content" "\" \""
                , Prop "margin-top" "calc((1lh - 1cap) / -2)"
                , Prop "display" "table"
                ]
            , Descriptor "::before"
                [ Prop "content" "\" \""
                , Prop "margin-bottom" "calc((1lh - 1cap) / -2)"
                , Prop "display" "table"
                ]
            ]
        , Descriptor (dot classes.ellipses)
            [ AllChildren (dot classes.text)
                [ Prop "text-overflow" "ellipsis"
                , Prop "white-space" "nowrap"
                , Prop "overflow" "hidden"

                -- If we're clipping ellips, we adjust the vaccum so that
                -- we're exactly 1lh
                , Descriptor "::after"
                    [ Prop "content" "\" \""
                    , Prop "margin-top" "calc((1lh - 1cap) / -2)"
                    , Prop "display" "table"
                    ]
                , Descriptor "::before"
                    [ Prop "content" "\" \""
                    , Prop "margin-bottom" "calc((1lh - 1cap) / -2)"
                    , Prop "display" "table"
                    ]
                ]
            ]
        , Descriptor (dot classes.noTextSelection)
            [ Prop "user-select" "none"
            ]
        , Descriptor (dot classes.cursorPointer)
            [ Prop "cursor" "pointer"
            ]
        , Descriptor (dot classes.cursorGrab)
            [ Prop "cursor" "grab"
            ]
        , Descriptor (dot classes.cursorGrabbing)
            [ Prop "cursor" "grabbing"
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
            , Descriptor (dot classes.column)
                [ Prop "flex-shrink" "1"
                , Prop "flex-basis" "auto"
                ]
            , Descriptor (dot classes.el)
                [ Prop "flex-shrink" "1"
                , Prop "flex-basis" "auto"
                ]
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
                , Prop "flex-basis" "auto"
                ]
            , Descriptor (dot classes.el)
                [ Prop "flex-shrink" "1"
                , Prop "flex-basis" "auto"
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
            [ Prop "display" "inline-block"
            , Prop "max-width" "100%"
            ]
        , Descriptor (dot classes.el)
            elDescription
        , Descriptor (dot classes.row)
            [ Prop "display" "flex"
            , Prop "flex-direction" "row"

            -- Default alignment is vertically centered
            , Prop "align-items" "center"

            --
            -- If the row has width fill, then everything within it
            -- That has width-fill should have a flex-basis of 0.
            -- This is so that they can share the available space evenly.
            , Descriptor select.widthFill
                [ Child select.widthFill
                    [ Prop "flex-basis" "0%"
                    ]
                ]
            , Child (dot classes.any)
                [ Prop "flex-basis" "auto"
                , Prop "flex-shrink" "1"
                , Descriptor select.widthFill
                    [ Prop "flex-grow" "1"
                    ]
                , Descriptor (dot classes.clip)
                    [ Descriptor select.widthFill
                        [ Prop "min-width" "auto" ]
                    ]
                , Descriptor (dot classes.clipX)
                    [ Descriptor select.widthFill
                        [ Prop "min-width" "auto" ]
                    ]
                , Descriptor (dot classes.widthExact)
                    [ Prop "flex-shrink" "0"
                    ]
                ]
            , Child select.heightFill
                [ Prop "align-self" "stretch"
                ]
            , Child (dot classes.heightFill)
                [ Descriptor (dot classes.heightBounded)
                    -- This looks super weird, I know.
                    -- Here's the awkward situation: https://www.notion.so/Difficult-or-impossible-CSS-challenges-33d1216a69b74688a038da7a18eee200?pvs=4
                    -- basically height: 100% is broken in a flex row
                    -- Other approaches also fail for various reasons
                    -- We know the height is bounded by a specific pixel height
                    -- so we can set this value to a large pixel value to cause it to grow
                    [ Prop "height" "max(2000px, 100vh)"
                    ]
                ]
            , describeAlignment <|
                \alignment ->
                    case alignment of
                        Top ->
                            ( [ Prop "align-items" "flex-start" ]
                            , [ Prop "margin-bottom" "auto"
                              ]
                            )

                        Bottom ->
                            ( [ Prop "align-items" "flex-end" ]
                            , [ Prop "margin-top" "auto"
                              ]
                            )

                        Right ->
                            ( [ Prop "justify-content" "flex-end"
                              ]
                            , [ Prop "margin-left" "auto" ]
                            )

                        Left ->
                            ( [ Prop "justify-content" "flex-start"
                              ]
                            , [ Prop "margin-right" "auto" ]
                            )

                        CenterX ->
                            ( [ Prop "justify-content" "center"
                              ]
                            , [ Prop "margin" "0 auto" ]
                            )

                        CenterY ->
                            ( [ Prop "align-items" "center" ]
                            , [ Prop "margin" "auto 0"
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
            , Prop "align-content" "flex-start"
            , Child (dot classes.any)
                [ Prop "min-height" "min-content"
                , Descriptor (dot classes.heightExact)
                    [ Prop "flex-basis" "auto"
                    ]
                , Descriptor (dot classes.clip)
                    [ Prop "flex-basis" "auto"
                    ]
                , Descriptor (dot classes.scrollbars)
                    [ Prop "flex-basis" "auto"
                    ]
                , Descriptor (dot classes.widthBounded)
                    [ Descriptor (dot classes.widthFill)
                        [ Prop "width" "100%"
                        ]
                    ]
                ]
            , Child (dot classes.heightFill)
                [ Prop "flex-grow" "1"
                , Prop "max-height" "100%"
                ]
            , Child select.widthFill
                [ Prop "width" "100%"
                ]
            , Child (dot classes.widthContent)
                [ Prop "align-self" "flex-start"
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
                            , [ Prop "margin" "auto 0" ]
                            )
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
            , Prop "background-color" "transparent !important"
            , Prop "border-color" "transparent !important"
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
              Descriptor (dot classes.el)
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
            , Prop "overflow-wrap" "break-word"
            , AllChildren (dot classes.text)
                [ Prop "display" "inline"

                -- We can have text elements within a paragraph if there is
                -- a text modification like a text gradient.
                -- In this case, we don't want to clip the text because the paragraph already has
                , Descriptor "::after"
                    [ Prop "content" "none"
                    ]
                , Descriptor "::before"
                    [ Prop "content" "none"
                    ]
                ]
            , Descriptor "::after"
                [ Prop "content" "\" \""
                , Prop "margin-top" "calc((1lh - 1cap) / -2)"
                , Prop "display" "table"
                ]
            , Descriptor "::before"
                [ Prop "content" "\" \""
                , Prop "margin-bottom" "calc((1lh - 1cap) / -2)"
                , Prop "display" "table"
                ]
            , Descriptor (dot classes.hasBehind)
                [ Prop "z-index" "0"
                , Child (dot classes.behind)
                    [ Prop "z-index" "-1"
                    ]
                ]
            , AllChildren (dot classes.text)
                [ Prop "display" "inline"
                ]
            , Child (dot classes.paragraph)
                [ Prop "display" "inline"
                , Descriptor "::after"
                    [ Prop "content" "none"
                    ]
                , Descriptor "::before"
                    [ Prop "content" "none"
                    ]
                ]
            , AllChildren (dot classes.el)
                [ Prop "display" "inline"

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
                            , [ Prop "float" "right"
                              ]
                            )

                        Left ->
                            ( []
                            , [ Prop "float" "left"
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
            , Prop "align-items" "center"
            ]
        , Descriptor (dot classes.textRight)
            [ Prop "text-align" "end"
            , Prop "align-items" "flex-end"
            ]
        , Descriptor (dot classes.textLeft)
            [ Prop "text-align" "start"
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
        ]
    ]


{-| This is the main mechanism to "teleport" CSS to the top of the DOM.

1.  Attach an `on-hovered` class to an element (Let's call this the `primary` element)
2.  Also embed a "behind-content" element as the first child of the `primary` element.
    Let's call this the `trigger` element.
3.  When a pseudo class is applied to the `primary` element, we apply an animation to the `trigger` element.
      - We also attach arbitrary data to the `trigger` element.
4.  We listen for animation events globally and use the decoder to extract information we need to render the CSS.
5.  We then use the information to render the CSS to the top of the DOM.
    We ALSO use this information to remove the `animation` trigger.

```
    -- The DOM element
    <div class= "on-hovered css-hash-abc-123">
        <div class="hover-trigger trigger-css-hash-abc-123" data-elm-ui={arbitraryCSSAsJson}></div>
        ...arbitrary content
    </div>

    -- Initial Static CSS
    .on-hovered:hover > .ui-trigger { animation: on-hovered 1ms;}

    -- The animation is triggered, and css is rendered that uses css-hash-abc-123
    .css-hash-abc-123:hover {..whatever}

    -- And we also disable the original animation.
    .on-hovered:hover > .ui-trigger.trigger-css-hash-abc-123 { animation: none }
```

-}
animationTriggers : List Rule
animationTriggers =
    let
        toTrigger baseClass props =
            Descriptor baseClass
                [ Child "*"
                    [ Child (dot classes.trigger)
                        props
                    ]
                ]
    in
    [ toTrigger ".on-hovered:hover"
        [ Prop "animation" "on-hovered 1ms"
        ]
    , toTrigger ".on-focused:focus"
        [ Prop "animation" "on-focused 1ms"
        ]
    , toTrigger ".on-focused-within:focus-within"
        [ Prop "animation" "on-focused 1ms"
        ]
    , toTrigger ".on-pressed:active"
        [ Prop "animation" "on-pressed 1ms"
        ]
    , toTrigger ".on-rendered"
        [ Prop "animation" "on-rendered 1ms"
        ]
    , toTrigger ".on-dismount"
        --  A years worth of seconds :imp-smiling:
        [ Prop "animation" "on-dismount 31449600s"
        ]
    ]


{-| z-index only takes effect if the element is not position:static
<https://developer.mozilla.org/en-US/docs/Web/CSS/z-index>
-}
zIndex : Int -> Rule
zIndex z =
    Batch
        [ Prop "position" "relative"
        , Prop "z-index" (String.fromInt z)
        ]


elDescription =
    [ Prop "display" "flex"
    , Prop "flex-direction" "column"
    , Descriptor (dot classes.hasBehind)
        [ Prop "z-index" "0"
        , Child (dot classes.behind)
            [ Prop "z-index" "-1"
            ]
        ]
    , Child (dot classes.heightContent)
        [ Prop "height" "auto"
        ]
    , Child (dot classes.heightFill)
        [ Prop "flex-grow" "1"

        -- max height is for when the child is larger than the parent el.
        -- An example case is
        -- el [ height fill ]
        --   (row [heightFill]
        --     [ scrollable [ height fill ] (text "hello")
        -- We want the height fill to translate through the row so that scrollable know show to scroll.
        , Prop "max-height" "100%"
        ]
    , Child select.widthFill
        -- width full, but not aligned
        [ Prop "width" "100%"
        ]
    , Child (dot classes.widthFill)
        -- Bounded + width fill.
        -- The element should grow to fill the space
        -- but be capped
        -- The weird case is if alignment is applied, which negates the initial width fill
        -- But now we want to restore it.
        [ Descriptor (dot classes.widthBounded)
            [ Prop "width" "100%"
            ]
        ]
    , Child (dot classes.widthContent)
        [ Prop "align-self" "flex-start"
        ]
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
        [ textInput
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
        "inset " ++ elShadow shadow

    else
        rendered ++ ", inset" ++ elShadow shadow


shadows : List Shadow -> String
shadows shades =
    List.foldl joinShadows "" shades


joinShadows shadow rendered =
    if String.isEmpty rendered then
        elShadow shadow

    else
        rendered ++ "," ++ elShadow shadow


elShadow : Shadow -> String
elShadow shadow =
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
                if el line -> do math involving line-height

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

        SetVariable (Var var) val ->
            { rendered | props = ( "--" ++ var, val ) :: rendered.props }

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
