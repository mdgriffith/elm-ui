module Element.Background exposing
    ( color, gradient
    , image, uncropped, tiled, tiledX, tiledY
    )

{-|

@docs color, gradient


# Images

@docs image, uncropped, tiled, tiledX, tiledY

**Note** if you want more control over a background image than is provided here, you should try just using a normal `Element.image` with something like `Element.behindContent`.

-}

import Element exposing (Attr, Attribute, Color)
import Internal.Flag as Flag
import Internal.Model as Internal
import VirtualDom


{-| -}
color : Color -> Attr decorative msg
color clr =
    Internal.StyleClass Flag.bgColor (Internal.Colored ("bg-" ++ Internal.formatColorClass clr) "background-color" clr)


{-| Resize the image to fit the containing element while maintaining proportions and cropping the overflow.
-}
image : String -> Attribute msg
image src =
    Internal.Attr (VirtualDom.style "background" ("url(\"" ++ src ++ "\") center / cover no-repeat"))


{-| A centered background image that keeps its natural proportions, but scales to fit the space.
-}
uncropped : String -> Attribute msg
uncropped src =
    Internal.Attr (VirtualDom.style "background" ("url(\"" ++ src ++ "\") center / contain no-repeat"))


{-| Tile an image in the x and y axes.
-}
tiled : String -> Attribute msg
tiled src =
    Internal.Attr (VirtualDom.style "background" ("url(\"" ++ src ++ "\") repeat"))


{-| Tile an image in the x axis.
-}
tiledX : String -> Attribute msg
tiledX src =
    Internal.Attr (VirtualDom.style "background" ("url(\"" ++ src ++ "\") repeat-x"))


{-| Tile an image in the y axis.
-}
tiledY : String -> Attribute msg
tiledY src =
    Internal.Attr (VirtualDom.style "background" ("url(\"" ++ src ++ "\") repeat-y"))


type Direction
    = ToUp
    | ToDown
    | ToRight
    | ToTopRight
    | ToBottomRight
    | ToLeft
    | ToTopLeft
    | ToBottomLeft
    | ToAngle Float


type Step
    = ColorStep Color
    | PercentStep Float Color
    | PxStep Int Color


{-| -}
step : Color -> Step
step =
    ColorStep


{-| -}
percent : Float -> Color -> Step
percent =
    PercentStep


{-| -}
px : Int -> Color -> Step
px =
    PxStep


{-| A linear gradient.

First you need to specify what direction the gradient is going by providing an angle in radians. `0` is up and `pi` is down.

The colors will be evenly spaced.

-}
gradient :
    { angle : Float
    , steps : List Color
    }
    -> Attr decorative msg
gradient { angle, steps } =
    case steps of
        [] ->
            Internal.NoAttribute

        clr :: [] ->
            Internal.StyleClass Flag.bgColor
                (Internal.Colored ("bg-" ++ Internal.formatColorClass clr) "background-color" clr)

        _ ->
            Internal.StyleClass Flag.bgGradient <|
                Internal.Single ("bg-grad-" ++ (String.join "-" <| Internal.floatClass angle :: List.map Internal.formatColorClass steps))
                    "background-image"
                    ("linear-gradient(" ++ (String.join ", " <| (String.fromFloat angle ++ "rad") :: List.map Internal.formatColor steps) ++ ")")



-- {-| -}
-- gradientWith : { direction : Direction, steps : List Step } -> Attribute msg
-- gradientWith { direction, steps } =
--     StyleClass <|
--         Single ("bg-gradient-" ++ (String.join "-" <| renderDirectionClass direction :: List.map renderStepClass steps))
--             "background"
--             ("linear-gradient(" ++ (String.join ", " <| renderDirection direction :: List.map renderStep steps) ++ ")")
-- {-| -}
-- renderStep : Step -> String
-- renderStep step =
--     case step of
--         ColorStep color ->
--             formatColor color
--         PercentStep percent color ->
--             formatColor color ++ " " ++ toString percent ++ "%"
--         PxStep px color ->
--             formatColor color ++ " " ++ toString px ++ "px"
-- {-| -}
-- renderStepClass : Step -> String
-- renderStepClass step =
--     case step of
--         ColorStep color ->
--             formatColorClass color
--         PercentStep percent color ->
--             formatColorClass color ++ "-" ++ floatClass percent ++ "p"
--         PxStep px color ->
--             formatColorClass color ++ "-" ++ toString px ++ "px"
-- toUp : Direction
-- toUp =
--     ToUp
-- toDown : Direction
-- toDown =
--     ToDown
-- toRight : Direction
-- toRight =
--     ToRight
-- toTopRight : Direction
-- toTopRight =
--     ToTopRight
-- toBottomRight : Direction
-- toBottomRight =
--     ToBottomRight
-- toLeft : Direction
-- toLeft =
--     ToLeft
-- toTopLeft : Direction
-- toTopLeft =
--     ToTopLeft
-- toBottomLeft : Direction
-- toBottomLeft =
--     ToBottomLeft
-- angle : Float -> Direction
-- angle rad =
--     ToAngle rad
-- renderDirection : Direction -> String
-- renderDirection dir =
--     case dir of
--         ToUp ->
--             "to top"
--         ToDown ->
--             "to bottom"
--         ToRight ->
--             "to right"
--         ToTopRight ->
--             "to top right"
--         ToBottomRight ->
--             "to bottom right"
--         ToLeft ->
--             "to left"
--         ToTopLeft ->
--             "to top left"
--         ToBottomLeft ->
--             "to bottom left"
--         ToAngle angle ->
--             toString angle ++ "rad"
-- renderDirectionClass : Direction -> String
-- renderDirectionClass dir =
--     case dir of
--         ToUp ->
--             "to-top"
--         ToDown ->
--             "to-bottom"
--         ToRight ->
--             "to-right"
--         ToTopRight ->
--             "to-top-right"
--         ToBottomRight ->
--             "to-bottom-right"
--         ToLeft ->
--             "to-left"
--         ToTopLeft ->
--             "to-top-left"
--         ToBottomLeft ->
--             "to-bottom-left"
--         ToAngle angle ->
--             floatClass angle ++ "rad"
