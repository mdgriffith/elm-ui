module Internal.Style.Generated exposing (Var(..), classes, vars, stylesheet, lineHeightAdjustment)

{-| This file is generated via 'npm run stylesheet' in the elm-ui repository -}

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



stylesheet : String
stylesheet = """@media screen and (-ms-high-contrast: active), (-ms-high-contrast: none) {.s.r > .s { flex-basis: auto !important; } }
input[type="search"],
input[type="search"]::-webkit-search-decoration,
input[type="search"]::-webkit-search-cancel-button,
input[type="search"]::-webkit-search-results-button,
input[type="search"]::-webkit-search-results-decoration {
  -webkit-appearance:none;
}

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
    }
    
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
    
.explain {
    border: 6px solid rgb(174, 121, 15) !important;
}
.explain > .s {
    border: 4px dashed rgb(0, 151, 167) !important;
}

.ctr {
    border: none !important;
}
.explain > .ctr > .s {
    border: 4px dashed rgb(0, 151, 167) !important;
}


.explain * {
    animation: show-redraw 0.4s ease;
}


@keyframes show-redraw {
    0% {
       background-color:red;
    }
}


.debug-box {
    display:fixed;
    outline: 1px solid red !important;
}



.ui-placeholder {
    visibility: hidden;
    border: 0px !important;
}
.explain > .ui-placeholder {
    border: 0px !important;
}
.ui-movable {
    position: absolute !important;
    visibility: visible;
    margin:0px !important;
    left:0px;
    top:0px;
    width:100%;
    height:100%;
}
.ui-movable.on-rendered {
    animation: none !important;
}



@keyframes on-hovered { from {} to {} }
@keyframes on-focused { from {} to {} }
@keyframes on-pressed { from {} to {} }
@keyframes on-rendered { from {} to {} }
@keyframes on-dismount { from {} to {} }
html,body{height:100%;padding:0;margin:0;}.s.e.ic{display:block;}.s.e.ic.hf > img{max-height:100%;object-fit:cover;}.s.e.ic.wf > img{max-width:100%;object-fit:cover;}.s:focus{outline:none;}.ui{width:100%;height:auto;line-height:1.2;}.ui{position:relative;z-index:0;}.ui.e{min-height:100%;font-size:16px;font-family:"Open Sans", sans-serif;color:#000;}.ui .t{margin-top:-0.1em;margin-bottom:-0.1em;}.ui .p{margin-top:-0.1em;margin-bottom:-0.1em;}.ui.s.hf{height:100%;}.ui.s.hf > .hf{height:100%;}.ui > .fr.nb{position:fixed;z-index:20;}.hnb{position:relative;}.nb{position:relative;border:none;display:flex;flex-direction:row;flex-basis:auto;border-radius:inherit;}.nb.e{display:flex;flex-direction:column;}.nb.e.hbh{z-index:0;}.nb.e.hbh > .bh{z-index:-1;}.nb.e > .hc{height:auto;}.nb.e > .hf{flex-grow:1;max-height:100%;}.nb.e > .wf:not(.ar, .al, .cx){min-width:100%;}.nb.e > .wc{align-self:flex-start;}.nb.e.ct{justify-content:flex-start;}.nb.e > .s.at{margin-bottom:auto !important;margin-top:0 !important;}.nb.e.cb{justify-content:flex-end;}.nb.e > .s.ab{margin-top:auto !important;margin-bottom:0 !important;}.nb.e.cr{align-items:flex-end;}.nb.e > .s.ar{align-self:flex-end;}.nb.e.cl{align-items:flex-start;}.nb.e > .s.al{align-self:flex-start;}.nb.e.ccx{align-items:center;}.nb.e > .s.cx{align-self:center;}.nb.e.ccy > .s{margin-top:auto;margin-bottom:auto;}.nb.e > .s.cy{margin-top:auto !important;margin-bottom:auto !important;}.nb.a{position:absolute;bottom:100%;left:0;width:100%;z-index:20;margin:0 !important;pointer-events:none;}.nb.a > .hf{height:auto;}.nb.a > .wf:not(.ar, .al, .cx){width:100%;}.nb.a > *{pointer-events:auto;}.nb.b{position:absolute;bottom:0;left:0;height:0;width:100%;z-index:20;margin:0 !important;pointer-events:none;}.nb.b > *{pointer-events:auto;}.nb.b > .hf{height:auto;}.nb.or{position:absolute;left:100%;top:0;height:100%;margin:0 !important;z-index:20;pointer-events:none;}.nb.or > *{pointer-events:auto;}.nb.ol{position:absolute;right:100%;top:0;height:100%;margin:0 !important;z-index:20;pointer-events:none;}.nb.ol > *{pointer-events:auto;}.nb.fr{position:absolute;width:100%;height:100%;left:0;top:0;margin:0 !important;pointer-events:none;}.nb.fr > *{pointer-events:auto;}.nb.bh{position:absolute;width:100%;height:100%;left:0;top:0;margin:0 !important;z-index:0;pointer-events:none;}.nb.bh > *{pointer-events:auto;}.e{flex:0 0 0px;align-items:flex-start;min-height:min-content;display:flex;flex-direction:column;}button.s{background-color:transparent;text-align:start;}.s{border:none;flex-shrink:0;display:flex;flex-direction:row;flex-basis:auto;resize:none;box-sizing:border-box;margin:0;padding:0;border-width:0;border-style:solid;font-size:inherit;color:inherit;font-family:inherit;font-weight:inherit;font-feature-settings:inherit;text-decoration:none;font-style:inherit;}.s.on-hovered:hover{animation:on-hovered 1ms;}.s.on-focused:focus{animation:on-focused 1ms;}.s.on-focused-within:focus-within{animation:on-focused 1ms;}.s.on-pressed:active{animation:on-pressed 1ms;}.s.on-rendered{animation:on-rendered 1ms;}.s.on-dismount{animation:on-dismount 31449600s;}.s.stick-top{position:sticky;top:0;}.s.stick-bottom{position:sticky;bottom:-1px;}.s.stick-left{position:sticky;left:0;}.s.tgrd .t{background:var(--text-gradient);-webkit-background-clip:text;-webkit-text-fill-color:transparent;}.s.f-adj{font-size:calc(1em * var(--font-size-factor));}.s.ellip .t{text-overflow:ellipsis;white-space:nowrap;overflow:hidden;}.s.notxt{user-select:none;}.s.cptr{cursor:pointer;}.s.grab{cursor:grab;}.s.grabbing{cursor:grabbing;}.s.ctxt{cursor:text;}.s.ppe{pointer-events:none !important;}.s.cpe{pointer-events:auto !important;}.s.clr{opacity:0;}.s.oq{opacity:1;}.s.hvclr:hover{opacity:0;}.s.hvoq:hover{opacity:1;}.s.fcsclr:focus{opacity:0;}.s.fcsoq:focus{opacity:1;}.s.atvclr:active{opacity:0;}.s.atvoq:active{opacity:1;}.s.ts{transition:transform 160ms, opacity 160ms, filter 160ms, background-color 160ms, color 160ms, font-size 160ms;}.s.sb{overflow:auto;flex-shrink:1;}.s.sb.c{flex-shrink:1;flex-basis:auto;}.s.sb.e{flex-shrink:1;flex-basis:auto;}.s.sbx{overflow-x:auto;}.s.sbx.r{flex-shrink:1;}.s.sby{overflow-y:auto;}.s.sby.c{flex-shrink:1;flex-basis:auto;}.s.sby.e{flex-shrink:1;flex-basis:auto;}.s.cp{overflow:hidden;min-width:min-content;min-height:min-content;}.s.cp.wb{min-width:auto;}.s.cp.hb{min-height:auto;}.s.cpx{overflow-x:hidden;min-width:min-content;}.s.cpx.wb{min-width:auto;}.s.cpy{overflow-y:hidden;min-height:min-content;}.s.cpy.hb{min-height:auto;}.s.wc{width:auto;}.s.t{display:inline-block;max-width:100%;}.s.lh-5 .t{margin-top:-0.023809523809523808lh;margin-bottom:-0.023809523809523808lh;}.s.lh-5 .p{margin-top:-0.023809523809523808lh;margin-bottom:-0.023809523809523808lh;}.s.lh-10 .t{margin-top:-0.045454545454545456lh;margin-bottom:-0.045454545454545456lh;}.s.lh-10 .p{margin-top:-0.045454545454545456lh;margin-bottom:-0.045454545454545456lh;}.s.lh-15 .t{margin-top:-0.06521739130434782lh;margin-bottom:-0.06521739130434782lh;}.s.lh-15 .p{margin-top:-0.06521739130434782lh;margin-bottom:-0.06521739130434782lh;}.s.lh-20 .t{margin-top:-0.08333333333333334lh;margin-bottom:-0.08333333333333334lh;}.s.lh-20 .p{margin-top:-0.08333333333333334lh;margin-bottom:-0.08333333333333334lh;}.s.lh-25 .t{margin-top:-0.1lh;margin-bottom:-0.1lh;}.s.lh-25 .p{margin-top:-0.1lh;margin-bottom:-0.1lh;}.s.lh-30 .t{margin-top:-0.11538461538461538lh;margin-bottom:-0.11538461538461538lh;}.s.lh-30 .p{margin-top:-0.11538461538461538lh;margin-bottom:-0.11538461538461538lh;}.s.lh-35 .t{margin-top:-0.12962962962962962lh;margin-bottom:-0.12962962962962962lh;}.s.lh-35 .p{margin-top:-0.12962962962962962lh;margin-bottom:-0.12962962962962962lh;}.s.lh-40 .t{margin-top:-0.14285714285714288lh;margin-bottom:-0.14285714285714288lh;}.s.lh-40 .p{margin-top:-0.14285714285714288lh;margin-bottom:-0.14285714285714288lh;}.s.lh-45 .t{margin-top:-0.15517241379310345lh;margin-bottom:-0.15517241379310345lh;}.s.lh-45 .p{margin-top:-0.15517241379310345lh;margin-bottom:-0.15517241379310345lh;}.s.lh-50 .t{margin-top:-0.16666666666666666lh;margin-bottom:-0.16666666666666666lh;}.s.lh-50 .p{margin-top:-0.16666666666666666lh;margin-bottom:-0.16666666666666666lh;}.s.lh-55 .t{margin-top:-0.1774193548387097lh;margin-bottom:-0.1774193548387097lh;}.s.lh-55 .p{margin-top:-0.1774193548387097lh;margin-bottom:-0.1774193548387097lh;}.s.lh-60 .t{margin-top:-0.18749999999999997lh;margin-bottom:-0.18749999999999997lh;}.s.lh-60 .p{margin-top:-0.18749999999999997lh;margin-bottom:-0.18749999999999997lh;}.s.lh-65 .t{margin-top:-0.196969696969697lh;margin-bottom:-0.196969696969697lh;}.s.lh-65 .p{margin-top:-0.196969696969697lh;margin-bottom:-0.196969696969697lh;}.s.lh-70 .t{margin-top:-0.20588235294117646lh;margin-bottom:-0.20588235294117646lh;}.s.lh-70 .p{margin-top:-0.20588235294117646lh;margin-bottom:-0.20588235294117646lh;}.s.lh-75 .t{margin-top:-0.21428571428571427lh;margin-bottom:-0.21428571428571427lh;}.s.lh-75 .p{margin-top:-0.21428571428571427lh;margin-bottom:-0.21428571428571427lh;}.s.lh-80 .t{margin-top:-0.22222222222222224lh;margin-bottom:-0.22222222222222224lh;}.s.lh-80 .p{margin-top:-0.22222222222222224lh;margin-bottom:-0.22222222222222224lh;}.s.lh-85 .t{margin-top:-0.22972972972972971lh;margin-bottom:-0.22972972972972971lh;}.s.lh-85 .p{margin-top:-0.22972972972972971lh;margin-bottom:-0.22972972972972971lh;}.s.lh-90 .t{margin-top:-0.2368421052631579lh;margin-bottom:-0.2368421052631579lh;}.s.lh-90 .p{margin-top:-0.2368421052631579lh;margin-bottom:-0.2368421052631579lh;}.s.lh-95 .t{margin-top:-0.24358974358974358lh;margin-bottom:-0.24358974358974358lh;}.s.lh-95 .p{margin-top:-0.24358974358974358lh;margin-bottom:-0.24358974358974358lh;}.s.lh-100 .t{margin-top:-0.25lh;margin-bottom:-0.25lh;}.s.lh-100 .p{margin-top:-0.25lh;margin-bottom:-0.25lh;}.s.e{display:flex;flex-direction:column;}.s.e.hbh{z-index:0;}.s.e.hbh > .bh{z-index:-1;}.s.e > .hc{height:auto;}.s.e > .hf{flex-grow:1;max-height:100%;}.s.e > .wf:not(.ar, .al, .cx){min-width:100%;}.s.e > .wc{align-self:flex-start;}.s.e.ct{justify-content:flex-start;}.s.e > .s.at{margin-bottom:auto !important;margin-top:0 !important;}.s.e.cb{justify-content:flex-end;}.s.e > .s.ab{margin-top:auto !important;margin-bottom:0 !important;}.s.e.cr{align-items:flex-end;}.s.e > .s.ar{align-self:flex-end;}.s.e.cl{align-items:flex-start;}.s.e > .s.al{align-self:flex-start;}.s.e.ccx{align-items:center;}.s.e > .s.cx{align-self:center;}.s.e.ccy > .s{margin-top:auto;margin-bottom:auto;}.s.e > .s.cy{margin-top:auto !important;margin-bottom:auto !important;}.s.r{display:flex;flex-direction:row;}.s.r.wf:not(.ar, .al, .cx) > .wf:not(.ar, .al, .cx){flex-basis:0%;}.s.r > .s{flex-basis:auto;flex-shrink:1;}.s.r > .s.wf:not(.ar, .al, .cx){flex-shrink:0;flex-grow:1;}.s.r > .s.cp.wf:not(.ar, .al, .cx){min-width:auto;}.s.r > .s.cpx.wf:not(.ar, .al, .cx){min-width:auto;}.s.r > .s.we{flex-shrink:0;}.s.r > .hf{align-self:stretch !important;}.s.r.ct{align-items:flex-start;}.s.r > .s.at{align-self:flex-start;}.s.r.cb{align-items:flex-end;}.s.r > .s.ab{align-self:flex-end;}.s.r.cr{justify-content:flex-end;}.s.r > .s.ar{margin-left:auto;}.s.r.cl{justify-content:flex-start;}.s.r > .s.al{margin-right:auto;}.s.r.ccx{justify-content:center;}.s.r > .s.cx{margin:0 auto;}.s.r.ccy{align-items:center;}.s.r > .s.cy{align-self:center;}.s.r.sev{justify-content:space-between;}.s.r.lbl{align-items:baseline;}.s.c{display:flex;flex-direction:column;}.s.c > .s{min-height:min-content;}.s.c > .s.he{flex-basis:auto;}.s.c > .s.cp{flex-basis:auto;}.s.c > .s.sb{flex-basis:auto;}.s.c > .s.wb.wf{width:100%;}.s.c > .hf{flex-grow:1;max-height:100%;}.s.c > .wf:not(.ar, .al, .cx){width:100%;}.s.c > .wc{align-self:flex-start;}.s.c.ct{justify-content:flex-start;}.s.c > .s.at{margin-bottom:auto;}.s.c.cb{justify-content:flex-end;}.s.c > .s.ab{margin-top:auto;}.s.c.cr{align-items:flex-end;}.s.c > .s.ar{align-self:flex-end;}.s.c.cl{align-items:flex-start;}.s.c > .s.al{align-self:flex-start;}.s.c.ccx{align-items:center;}.s.c > .s.cx{align-self:center;}.s.c.ccy{justify-content:center;}.s.c > .s.cy{margin:auto 0;}.s.c.sev{justify-content:space-between;}.s.g{display:-ms-grid;display:grid;}.s.g > .gp > .s{width:100%;}.s.g > .s.at{justify-content:flex-start;}.s.g > .s.ab{justify-content:flex-end;}.s.g > .s.ar{align-items:flex-end;}.s.g > .s.al{align-items:flex-start;}.s.g > .s.cx{align-items:center;}.s.g > .s.cy{justify-content:center;}.s.pg{display:block;}.s.pg > .s:first-child{margin:0 !important;}.s.pg > .s.al:first-child + .s{margin:0 !important;}.s.pg > .s.ar:first-child + .s{margin:0 !important;}.s.pg > .s.ar{float:right;}.s.pg > .s.ar::after{content:"";display:table;clear:both;}.s.pg > .s.al{float:left;}.s.pg > .s.al::after{content:"";display:table;clear:both;}.s.iml{white-space:pre-wrap !important;height:100%;width:100%;background-color:transparent;}.s.implw.e{flex-basis:auto;}.s.imlp{white-space:pre-wrap !important;cursor:text;}.s.imlp > .imlf{white-space:pre-wrap !important;color:transparent;}.s.p{display:block;overflow-wrap:break-word;}.s.p.hbh{z-index:0;}.s.p.hbh > .bh{z-index:-1;}.s.p .t{display:inline;}.s.p > .p{display:inline;}.s.p > .p::after{content:none;}.s.p > .p::before{content:none;}.s.p .e{display:inline;}.s.p .e.we{display:inline-block;}.s.p .e.nb{display:flex;}.s.p .e > .t{display:inline;}.s.p > .r{display:inline;}.s.p > .c{display:inline-flex;}.s.p > .g{display:inline-grid;}.s.p > .s.ar{float:right;}.s.p > .s.al{float:left;}.s.hidden{display:none;}.s.tj{text-align:justify;}.s.tja{text-align:justify-all;}.s.tc{text-align:center;}.s.tr{text-align:right;}.s.tl{text-align:left;}.s.i{font-style:italic;}.s.sk{text-decoration:line-through;}.s.u{text-decoration:underline;text-decoration-skip-ink:auto;text-decoration-skip:ink;}.s.u.sk{text-decoration:line-through underline;text-decoration-skip-ink:auto;text-decoration-skip:ink;}.s.tun{font-style:normal;}.itp{padding:0 !important;border-width:0 !important;transform:none;}.it{background-color:rgba(255,255,255,0);}input[type="range"].sldr::-moz-range-thumb{width:16px;height:16px;}input[type="range"].sldr::-webkit-slider-thumb{width:16px;height:16px;}input[type="range"].sldr::-ms-thumb{width:16px;height:16px;}"""
