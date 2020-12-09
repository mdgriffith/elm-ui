module Internal.Grid exposing (Around, Layout(..), PositionedElement, RelativePosition(..), build, createGrid, getWidth, relative)

{-| Relative positioning within a grid.

A relatively positioned grid, means a 3x3 grid with the primary element in the center.

-}

import Element
import Internal.Flag as Flag
import Internal.Model as Internal


type RelativePosition
    = OnRight
    | OnLeft
    | Above
    | Below
    | InFront


type Layout
    = GridElement
    | Row
    | Column


type alias Around alignment msg =
    { right : Maybe (PositionedElement alignment msg)
    , left : Maybe (PositionedElement alignment msg)
    , primary : ( Maybe String, List (Internal.Attribute alignment msg), List (Internal.Element msg) )

    -- , primaryWidth : Internal.Length
    , defaultWidth : Internal.Length
    , below : Maybe (PositionedElement alignment msg)
    , above : Maybe (PositionedElement alignment msg)
    , inFront : Maybe (PositionedElement alignment msg)
    }


type alias PositionedElement alignment msg =
    { layout : Layout
    , child : List (Internal.Element msg)
    , attrs : List (Internal.Attribute alignment msg)
    , width : Int
    , height : Int
    }


relative : Maybe String -> List (Internal.Attribute alignment msg) -> Around alignment msg -> Internal.Element msg
relative node attributes around =
    let
        ( sX, sY ) =
            Internal.getSpacing attributes ( 7, 7 )

        make positioned =
            Internal.element Internal.noStyleSheet
                Internal.asEl
                Nothing
                positioned.attrs
                (Internal.Unkeyed positioned.child)

        ( template, children ) =
            createGrid ( sX, sY ) around
    in
    Internal.element Internal.noStyleSheet
        Internal.asGrid
        node
        (template ++ attributes)
        (Internal.Unkeyed
            children
        )


createGrid : ( Int, Int ) -> Around alignment msg -> ( List (Internal.Attribute alignment msg1), List (Element.Element msg) )
createGrid ( spacingX, spacingY ) nearby =
    let
        rowCount =
            List.sum
                [ 1
                , if Nothing == nearby.above then
                    0

                  else
                    1
                , if Nothing == nearby.below then
                    0

                  else
                    1
                ]

        colCount =
            List.sum
                [ 1
                , if Nothing == nearby.left then
                    0

                  else
                    1
                , if Nothing == nearby.right then
                    0

                  else
                    1
                ]

        rows =
            if nearby.above == Nothing then
                { above = 0
                , primary = 1
                , below = 2
                }

            else
                { above = 1
                , primary = 2
                , below = 3
                }

        columns =
            if Nothing == nearby.left then
                { left = 0
                , primary = 1
                , right = 2
                }

            else
                { left = 1
                , primary = 2
                , right = 3
                }

        rowCoord pos =
            case pos of
                Above ->
                    rows.above

                Below ->
                    rows.below

                OnRight ->
                    rows.primary

                OnLeft ->
                    rows.primary

                InFront ->
                    rows.primary

        colCoord pos =
            case pos of
                Above ->
                    columns.primary

                Below ->
                    columns.primary

                OnRight ->
                    columns.right

                OnLeft ->
                    columns.left

                InFront ->
                    columns.primary

        place pos el =
            build (rowCoord pos) (colCoord pos) spacingX spacingY el
    in
    ( [ Internal.StyleClass Flag.gridTemplate
            (Internal.GridTemplateStyle
                { spacing = ( Internal.Px spacingX, Internal.Px spacingY )
                , columns =
                    List.filterMap identity
                        [ nearby.left
                            |> Maybe.map (\el -> Maybe.withDefault nearby.defaultWidth (getWidth el.attrs))
                        , nearby.primary
                            |> (\( node, attrs, el ) -> getWidth attrs)
                            |> Maybe.withDefault nearby.defaultWidth
                            |> Just
                        , nearby.right
                            |> Maybe.map (\el -> Maybe.withDefault nearby.defaultWidth (getWidth el.attrs))
                        ]
                , rows = List.map (always Internal.Content) (List.range 1 rowCount)
                }
            )
      ]
    , List.filterMap identity
        [ Just <|
            case nearby.primary of
                ( primaryNode, primaryAttrs, primaryChildren ) ->
                    Internal.element Internal.noStyleSheet
                        Internal.asEl
                        primaryNode
                        (Internal.StyleClass Flag.gridPosition
                            (Internal.GridPosition
                                { row = rows.primary
                                , col = columns.primary
                                , width = 1
                                , height = 1
                                }
                            )
                            :: primaryAttrs
                        )
                        (Internal.Unkeyed primaryChildren)
        , Maybe.map (place OnLeft) nearby.left
        , Maybe.map (place OnRight) nearby.right
        , Maybe.map (place Above) nearby.above
        , Maybe.map (place Below) nearby.below
        , Maybe.map (place InFront) nearby.inFront
        ]
    )


build : Int -> Int -> Int -> Int -> { a | attrs : List (Internal.Attribute alignment msg), height : Int, layout : Layout, width : Int, child : List (Internal.Element msg) } -> Internal.Element msg
build rowCoord colCoord spacingX spacingY positioned =
    let
        attributes =
            Internal.StyleClass Flag.gridPosition
                (Internal.GridPosition
                    { row = rowCoord
                    , col = colCoord
                    , width = positioned.width
                    , height = positioned.height
                    }
                )
                :: Internal.StyleClass Flag.spacing (Internal.SpacingStyle spacingX spacingY)
                :: positioned.attrs
    in
    case positioned.layout of
        GridElement ->
            Internal.element Internal.noStyleSheet
                Internal.asEl
                Nothing
                attributes
                (Internal.Unkeyed <| positioned.child)

        Row ->
            Internal.element Internal.noStyleSheet
                Internal.asRow
                Nothing
                attributes
                (Internal.Unkeyed positioned.child)

        Column ->
            Internal.element Internal.noStyleSheet
                Internal.asColumn
                Nothing
                attributes
                (Internal.Unkeyed positioned.child)


getWidth : List (Internal.Attribute align msg) -> Maybe Internal.Length
getWidth attrs =
    let
        widthPlease attr found =
            case found of
                Just x ->
                    Just x

                Nothing ->
                    case attr of
                        Internal.Width w ->
                            Just w

                        _ ->
                            Nothing
    in
    List.foldr widthPlease Nothing attrs
