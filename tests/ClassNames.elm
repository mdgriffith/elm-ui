module ClassNames exposing (suite)

{-| -}

import Expect
import Html
import Internal.Flag as Flag
import Internal.Style
import Test


suite =
    Test.describe "Classname Collisions"
        [ Test.test "No duplicates" <|
            \_ ->
                Expect.equal [] onlyDuplicates
        ]


main =
    Html.div []
        [ Html.text "The following names collide"
        , Html.div []
            (List.map viewPair onlyDuplicates)
        ]


viewPair ( name, description ) =
    Html.div []
        [ Html.text name
        , Html.text ": "
        , Html.text description
        ]


onlyDuplicates =
    List.filter findDuplicates allClassNames


findDuplicates ( name, description ) =
    List.any
        (\( checkName, checkDescription ) ->
            checkName == name && description /= checkDescription
        )
        allClassNames


allClassNames =
    List.map (Tuple.mapFirst (\fn -> fn Internal.Style.classes)) allClassNameFns


allClassNameFns =
    [ ( .root, "root" )
    , ( .any, "any" )
    , ( .single, "single" )
    , ( .row, "row" )
    , ( .column, "column" )
    , ( .page, "page" )
    , ( .paragraph, "paragraph" )
    , ( .text, "text" )
    , ( .grid, "grid" )
    , ( .imageContainer, "imageContainer" )

    -- widhts/heights
    , ( .widthFill, "widthFill" )
    , ( .widthContent, "widthContent" )
    , ( .widthExact, "widthExact" )
    , ( .widthFillPortion, "widthFillPortion" )
    , ( .heightFill, "heightFill" )
    , ( .heightContent, "heightContent" )
    , ( .heightFillPortion, "heightFillPortion" )
    , ( .seButton, "seButton" )

    -- nearby elements
    , ( .above, "above" )
    , ( .below, "below" )
    , ( .onRight, "onRight" )
    , ( .onLeft, "onLeft" )
    , ( .inFront, "inFront" )
    , ( .behind, "behind" )

    -- alignments
    , ( .alignTop, "alignTop" )
    , ( .alignBottom, "alignBottom" )
    , ( .alignRight, "alignRight" )
    , ( .alignLeft, "alignLeft" )
    , ( .alignCenterX, "alignCenterX" )
    , ( .alignCenterY, "alignCenterY" )
    , ( .alignedHorizontally, "alignedHorizontally" )
    , ( .alignedVertically, "alignedVertically" )

    -- space evenly
    , ( .spaceEvenly, "spaceEvenly" )
    , ( .container, "container" )
    , ( .alignContainerRight, "alignContainerRight" )
    , ( .alignContainerBottom, "alignContainerBottom" )
    , ( .alignContainerCenterX, "alignContainerCenterX" )
    , ( .alignContainerCenterY, "alignContainerCenterY" )

    -- content alignments
    , ( .contentTop, "contentTop" )
    , ( .contentBottom, "contentBottom" )
    , ( .contentRight, "contentRight" )
    , ( .contentLeft, "contentLeft" )
    , ( .contentCenterX, "contentCenterX" )
    , ( .contentCenterY, "contentCenterY" )

    -- selection
    , ( .noTextSelection, "noTextSelection" )
    , ( .cursorPointer, "cursorPointer" )
    , ( .cursorText, "cursorText" )

    -- pointer events
    , ( .passPointerEvents, "passPointerEvents" )
    , ( .capturePointerEvents, "capturePointerEvents" )
    , ( .transparent, "transparent" )
    , ( .opaque, "opaque" )
    , ( .overflowHidden, "overflowHidden" )

    -- special state classes
    , ( .hover, "hover" )

    -- , ( .hoverOpaque, "hoverOpaque" )
    , ( .focus, "focus" )

    -- , ( .focusOpaque, "focusOpaque" )
    , ( .active, "active" )

    -- , ( .activeOpaque, "activeOpaque" )
    --scrollbars
    , ( .scrollbars, "scrollbars" )
    , ( .scrollbarsX, "scrollbarsX" )
    , ( .scrollbarsY, "scrollbarsY" )
    , ( .clip, "clip" )
    , ( .clipX, "clipX" )
    , ( .clipY, "clipY" )

    -- borders
    , ( .borderNone, "borderNone" )
    , ( .borderDashed, "borderDashed" )
    , ( .borderDotted, "borderDotted" )
    , ( .borderSolid, "borderSolid" )

    -- text weight
    , ( .textThin, "textThin" )
    , ( .textExtraLight, "textExtraLight" )
    , ( .textLight, "textLight" )
    , ( .textNormalWeight, "textNormalWeight" )
    , ( .textMedium, "textMedium" )
    , ( .textSemiBold, "textSemiBold" )
    , ( .bold, "bold" )
    , ( .textExtraBold, "textExtraBold" )
    , ( .textHeavy, "textHeavy" )
    , ( .italic, "italic" )
    , ( .strike, "strike" )
    , ( .underline, "underline" )
    , ( .textUnitalicized, "textUnitalicized" )

    -- text alignment
    , ( .textJustify, "textJustify" )
    , ( .textJustifyAll, "textJustifyAll" )
    , ( .textCenter, "textCenter" )
    , ( .textRight, "textRight" )
    , ( .textLeft, "textLeft" )
    , ( .transition, "transition" )

    -- inputText
    , ( .inputText, "inputText" )
    , ( .inputMultiline, "inputMultiline" )
    ]
