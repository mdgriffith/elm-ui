module Internal.StyleGenerator exposing (..)

{-| This module is used to generate the actual base stylesheet for elm-ui.
-}

import Internal.StyleGen as Gen



-- locked : String
-- locked =
--     """@media screen and (-ms-high-contrast: active), (-ms-high-contrast: none) {.s.r > .s { flex-basis: auto !important; } .s.r > .s.ctr { flex-basis: auto !important; }}
-- input[type="search"],
-- input[type="search"]::-webkit-search-decoration,
-- input[type="search"]::-webkit-search-cancel-button,
-- input[type="search"]::-webkit-search-results-button,
-- input[type="search"]::-webkit-search-results-decoration {
--   -webkit-appearance:none;
-- }
-- input[type=range] {
--   -webkit-appearance: none;
--   background: transparent;
--   position:absolute;
--   left:0;
--   top:0;
--   z-index:10;
--   width: 100%;
--   outline: dashed 1px;
--   height: 100%;
--   opacity: 0;
-- }
-- input[type=range]::-moz-range-track {
--     background: transparent;
--     cursor: pointer;
-- }
-- input[type=range]::-ms-track {
--     background: transparent;
--     cursor: pointer;
-- }
-- input[type=range]::-webkit-slider-runnable-track {
--     background: transparent;
--     cursor: pointer;
-- }
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
-- .explain {
--     border: 6px solid rgb(174, 121, 15) !important;
-- }
-- .explain > .s {
--     border: 4px dashed rgb(0, 151, 167) !important;
-- }
-- .ctr {
--     border: none !important;
-- }
-- .explain > .ctr > .s {
--     border: 4px dashed rgb(0, 151, 167) !important;
-- }
-- html,body{height:100%;padding:0;margin:0;}.s.e.ic{display:block;}.s.e.ic.hf > img{max-height:100%;object-fit:cover;}.s.e.ic.wf > img{max-width:100%;object-fit:cover;}.s:focus{outline:none;}.ui{width:100%;height:auto;min-height:100%;z-index:0;}.ui.s.hf{height:100%;}.ui.s.hf > .hf{height:100%;}.ui > .fr.nb{position:fixed;z-index:20;}.nb{position:relative;border:none;display:flex;flex-direction:row;flex-basis:auto;}.nb.e{display:flex;flex-direction:column;white-space:pre;}.nb.e.hbh{z-index:0;}.nb.e.hbh > .bh{z-index:-1;}.nb.e.sbt > .t.hf{flex-grow:0;}.nb.e.sbt > .t.wf{align-self:auto !important;}.nb.e > .hc{height:auto;}.nb.e > .hf{flex-grow:100000;}.nb.e > .wf{width:100%;}.nb.e > .wfp{width:100%;}.nb.e > .wc{align-self:flex-start;}.nb.e.ct{justify-content:flex-start;}.nb.e > .s.at{margin-bottom:auto !important;margin-top:0 !important;}.nb.e.cb{justify-content:flex-end;}.nb.e > .s.ab{margin-top:auto !important;margin-bottom:0 !important;}.nb.e.cr{align-items:flex-end;}.nb.e > .s.ar{align-self:flex-end;}.nb.e.cl{align-items:flex-start;}.nb.e > .s.al{align-self:flex-start;}.nb.e.ccx{align-items:center;}.nb.e > .s.cx{align-self:center;}.nb.e.ccy > .s{margin-top:auto;margin-bottom:auto;}.nb.e > .s.cy{margin-top:auto !important;margin-bottom:auto !important;}.nb.a{position:absolute;bottom:100%;left:0;width:100%;z-index:20;margin:0 !important;pointer-events:none;}.nb.a > .hf{height:auto;}.nb.a > .wf{width:100%;}.nb.a > *{pointer-events:auto;}.nb.b{position:absolute;bottom:0;left:0;height:0;width:100%;z-index:20;margin:0 !important;pointer-events:none;}.nb.b > *{pointer-events:auto;}.nb.b > .hf{height:auto;}.nb.or{position:absolute;left:100%;top:0;height:100%;margin:0 !important;z-index:20;pointer-events:none;}.nb.or > *{pointer-events:auto;}.nb.ol{position:absolute;right:100%;top:0;height:100%;margin:0 !important;z-index:20;pointer-events:none;}.nb.ol > *{pointer-events:auto;}.nb.fr{position:absolute;width:100%;height:100%;left:0;top:0;margin:0 !important;pointer-events:none;}.nb.fr > *{pointer-events:auto;}.nb.bh{position:absolute;width:100%;height:100%;left:0;top:0;margin:0 !important;z-index:0;pointer-events:none;}.nb.bh > *{pointer-events:auto;}.s{position:relative;border:none;flex-shrink:0;display:flex;flex-direction:row;flex-basis:auto;resize:none;font-feature-settings:inherit;box-sizing:border-box;margin:0;padding:0;border-width:0;border-style:solid;font-size:inherit;color:inherit;font-family:inherit;line-height:1;font-weight:inherit;text-decoration:none;font-style:inherit;}.s.wrp{flex-wrap:wrap;}.s.notxt{-moz-user-select:none;-webkit-user-select:none;-ms-user-select:none;user-select:none;}.s.cptr{cursor:pointer;}.s.ctxt{cursor:text;}.s.ppe{pointer-events:none !important;}.s.cpe{pointer-events:auto !important;}.s.clr{opacity:0;}.s.oq{opacity:1;}.s.hvclr:hover{opacity:0;}.s.hvoq:hover{opacity:1;}.s.fcsclr:focus{opacity:0;}.s.fcsoq:focus{opacity:1;}.s.atvclr:active{opacity:0;}.s.atvoq:active{opacity:1;}.s.ts{transition:transform 160ms, opacity 160ms, filter 160ms, background-color 160ms, color 160ms, font-size 160ms;}.s.sb{overflow:auto;flex-shrink:1;}.s.sbx{overflow-x:auto;}.s.sbx.r{flex-shrink:1;}.s.sby{overflow-y:auto;}.s.sby.c{flex-shrink:1;}.s.sby.e{flex-shrink:1;}.s.cp{overflow:hidden;}.s.cpx{overflow-x:hidden;}.s.cpy{overflow-y:hidden;}.s.wc{width:auto;}.s.t{white-space:pre;display:inline-block;}.s.e{display:flex;flex-direction:column;white-space:pre;}.s.e.hbh{z-index:0;}.s.e.hbh > .bh{z-index:-1;}.s.e.sbt > .t.hf{flex-grow:0;}.s.e.sbt > .t.wf{align-self:auto !important;}.s.e > .hc{height:auto;}.s.e > .hf{flex-grow:100000;}.s.e > .wf{width:100%;}.s.e > .wfp{width:100%;}.s.e > .wc{align-self:flex-start;}.s.e.ct{justify-content:flex-start;}.s.e > .s.at{margin-bottom:auto !important;margin-top:0 !important;}.s.e.cb{justify-content:flex-end;}.s.e > .s.ab{margin-top:auto !important;margin-bottom:0 !important;}.s.e.cr{align-items:flex-end;}.s.e > .s.ar{align-self:flex-end;}.s.e.cl{align-items:flex-start;}.s.e > .s.al{align-self:flex-start;}.s.e.ccx{align-items:center;}.s.e > .s.cx{align-self:center;}.s.e.ccy > .s{margin-top:auto;margin-bottom:auto;}.s.e > .s.cy{margin-top:auto !important;margin-bottom:auto !important;}.s.r{display:flex;flex-direction:row;}.s.r > .s{flex-basis:0%;}.s.r > .s.we{flex-basis:auto;}.s.r > .s.lnk{flex-basis:auto;}.s.r > .hf{align-self:stretch !important;}.s.r > .hfp{align-self:stretch !important;}.s.r > .wf{flex-grow:100000;}.s.r > .ctr{flex-grow:0;flex-basis:auto;align-self:stretch;}.s.r > u:first-of-type.acr{flex-grow:1;}.s.r > s:first-of-type.accx{flex-grow:1;}.s.r > s:first-of-type.accx > .cx{margin-left:auto !important;}.s.r > s:last-of-type.accx{flex-grow:1;}.s.r > s:last-of-type.accx > .cx{margin-right:auto !important;}.s.r > s:only-of-type.accx{flex-grow:1;}.s.r > s:only-of-type.accx > .cy{margin-top:auto !important;margin-bottom:auto !important;}.s.r > s:last-of-type.accx ~ u{flex-grow:0;}.s.r > u:first-of-type.acr ~ s.accx{flex-grow:0;}.s.r.ct{align-items:flex-start;}.s.r > .s.at{align-self:flex-start;}.s.r.cb{align-items:flex-end;}.s.r > .s.ab{align-self:flex-end;}.s.r.cr{justify-content:flex-end;}.s.r.cl{justify-content:flex-start;}.s.r.ccx{justify-content:center;}.s.r.ccy{align-items:center;}.s.r > .s.cy{align-self:center;}.s.r.sev{justify-content:space-between;}.s.r.lbl{align-items:baseline;}.s.c{display:flex;flex-direction:column;}.s.c > .s{flex-basis:auto;}.s.c > .hf{flex-grow:100000;}.s.c > .wf{width:100%;}.s.c > .wfp{width:100%;}.s.c > .wc{align-self:flex-start;}.s.c > u:first-of-type.acb{flex-grow:1;}.s.c > s:first-of-type.accy{flex-grow:1;}.s.c > s:first-of-type.accy > .cy{margin-top:auto !important;margin-bottom:0 !important;}.s.c > s:last-of-type.accy{flex-grow:1;}.s.c > s:last-of-type.accy > .cy{margin-bottom:auto !important;margin-top:0 !important;}.s.c > s:only-of-type.accy{flex-grow:1;}.s.c > s:only-of-type.accy > .cy{margin-top:auto !important;margin-bottom:auto !important;}.s.c > s:last-of-type.accy ~ u{flex-grow:0;}.s.c > u:first-of-type.acb ~ s.accy{flex-grow:0;}.s.c.ct{justify-content:flex-start;}.s.c > .s.at{margin-bottom:auto;}.s.c.cb{justify-content:flex-end;}.s.c > .s.ab{margin-top:auto;}.s.c.cr{align-items:flex-end;}.s.c > .s.ar{align-self:flex-end;}.s.c.cl{align-items:flex-start;}.s.c > .s.al{align-self:flex-start;}.s.c.ccx{align-items:center;}.s.c > .s.cx{align-self:center;}.s.c.ccy{justify-content:center;}.s.c > .ctr{flex-grow:0;flex-basis:auto;width:100%;align-self:stretch !important;}.s.c.sev{justify-content:space-between;}.s.g{display:-ms-grid;display:grid;}.s.g > .gp > .s{width:100%;}.s.g > .s.at{justify-content:flex-start;}.s.g > .s.ab{justify-content:flex-end;}.s.g > .s.ar{align-items:flex-end;}.s.g > .s.al{align-items:flex-start;}.s.g > .s.cx{align-items:center;}.s.g > .s.cy{justify-content:center;}.s.pg{display:block;}.s.pg > .s:first-child{margin:0 !important;}.s.pg > .s.al:first-child + .s{margin:0 !important;}.s.pg > .s.ar:first-child + .s{margin:0 !important;}.s.pg > .s.ar{float:right;}.s.pg > .s.ar::after{content:"";display:table;clear:both;}.s.pg > .s.al{float:left;}.s.pg > .s.al::after{content:"";display:table;clear:both;}.s.iml{white-space:pre-wrap !important;height:100%;width:100%;background-color:transparent;}.s.implw.e{flex-basis:auto;}.s.imlp{white-space:pre-wrap !important;cursor:text;}.s.imlp > .imlf{white-space:pre-wrap !important;color:transparent;}.s.p{display:block;white-space:normal;overflow-wrap:break-word;}.s.p.hbh{z-index:0;}.s.p.hbh > .bh{z-index:-1;}.s.p .t{display:inline;white-space:normal;}.s.p .p{display:inline;}.s.p .p::after{content:none;}.s.p .p::before{content:none;}.s.p .e{display:inline;white-space:normal;}.s.p .e.we{display:inline-block;}.s.p .e.nb{display:flex;}.s.p .e > .t{display:inline;white-space:normal;}.s.p > .r{display:inline;}.s.p > .c{display:inline-flex;}.s.p > .g{display:inline-grid;}.s.p > .s.ar{float:right;}.s.p > .s.al{float:left;}.s.hidden{display:none;}.s.tj{text-align:justify;}.s.tja{text-align:justify-all;}.s.tc{text-align:center;}.s.tr{text-align:right;}.s.tl{text-align:left;}.s.i{font-style:italic;}.s.sk{text-decoration:line-through;}.s.u{text-decoration:underline;text-decoration-skip-ink:auto;text-decoration-skip:ink;}.s.u.sk{text-decoration:line-through underline;text-decoration-skip-ink:auto;text-decoration-skip:ink;}.s.tun{font-style:normal;}.itp{padding:0 !important;border-width:0 !important;transform:none;}"""


rules =
    Gen.rules



{- CLASSES -}


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
    , nowrap = "nowrp"
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


vars =
    { spaceX = Gen.Var "space-x"
    , spaceY = Gen.Var "space-y"
    , scale = Gen.Var "scale"
    , moveX = Gen.Var "move-x"
    , moveY = Gen.Var "move-y"
    , rotate = Gen.Var "rotate"
    , heightFill = Gen.Var "height-fill"
    , widthFill = Gen.Var "width-fill"
    , padLeft = Gen.Var "pad-left"
    , padRight = Gen.Var "pad-right"
    , padTop = Gen.Var "pad-top"
    , padBottom = Gen.Var "pad-bottom"
    , borderLeft = Gen.Var "border-left"
    , borderRight = Gen.Var "border-right"
    , borderTop = Gen.Var "border-top"
    , borderBottom = Gen.Var "border-bottom"
    , sliderWidth = Gen.Var "slider-width"
    , sliderHeight = Gen.Var "slider-height"
    }


type Color
    = Rgb Int Int Int


spacing : Float -> String
spacing s =
    floatPx s


set : Gen.Var -> String -> String
set (Gen.Var v) val =
    "--" ++ v ++ ":" ++ val ++ ";"


{-| TODO: a compact quad here is actually two numbers where we extract 4 numbers.

We're treatnig each as two numbers, each with an accuracy of 16bits.

-}
compactQuad : Int -> Int -> String
compactQuad x y =
    px y ++ " " ++ px x


color : Color -> String
color (Rgb red green blue) =
    "rgb("
        ++ String.fromInt red
        ++ ("," ++ String.fromInt green)
        ++ ("," ++ String.fromInt blue)
        ++ ")"


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
