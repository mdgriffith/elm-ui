module Ui exposing
    ( layout, embed, Option
    , Element, none, text, el
    , row, column, wrap
    , id, noAttr, attrIf
    , Attribute, Length, px, fill, portion, shrink
    , width, widthMin, widthMax
    , height, heightMin, heightMax
    , explain
    , padding, paddingXY, paddingLeft, paddingRight, paddingTop, paddingBottom, paddingWith
    , spacing, spacingWith, spaceEvenly
    , centerX, centerY, alignLeft, alignRight, alignTop, alignBottom
    , contentCenterX, contentCenterY, contentTop, contentBottom, contentLeft, contentRight
    , opacity
    , border, borderWith, Edges, borderGradient, borderColor
    , rounded, roundedWith, circle
    , background, Gradient, backgroundGradient
    , pointer, grab, grabbing
    , move, Position, up, down, left, right
    , rotate, Angle, turns, radians
    , scale
    , scrollable, clipped, clipWithEllipsis
    , link, linkNewTab, download, downloadAs
    , image
    , Color, rgb, rgba, palette
    , above, below, onRight, onLeft, inFront, behindContent
    , map
    , html, htmlAttribute
    )

{-|


# Getting started

@docs layout, embed, Option


# Basic Elements

@docs Element, none, text, el


# Rows and Columns

When we want more than one child on an element, we want to be _specific_ about how they will be laid out.

So, the common ways to do that would be `row` and `column`.

@docs row, column, wrap


# Attributes

@docs id, noAttr, attrIf


# Size

@docs Attribute, Length, px, fill, portion, shrink

@docs width, widthMin, widthMax

@docs height, heightMin, heightMax


# Debugging

@docs explain


# Padding and Spacing

There's no concept of margin in `elm-ui`, instead we have padding and spacing.

Padding is the distance between the outer edge and the content, and spacing is the space between children.

So, if we have the following row, with some padding and spacing.

    Ui.row [ padding 10, spacing 7 ]
        [ Ui.el [] Ui.none
        , Ui.el [] Ui.none
        , Ui.el [] Ui.none
        ]

Here's what we can expect:

![Three boxes spaced 7 pixels apart. There's a 10 pixel distance from the edge of the parent to the boxes.](https://mdgriffith.gitbooks.io/style-elements/content/assets/spacing-400.png)

**Note** `spacing` set on a `paragraph`, will set the pixel spacing between lines.

@docs padding, paddingXY, paddingLeft, paddingRight, paddingTop, paddingBottom, paddingWith

@docs spacing, spacingWith, spaceEvenly


# Alignment

Alignment can be used to align an `Element` within another `Element`.

    Ui.el [ centerX, alignTop ] (text "I'm centered and aligned top!")

If alignment is set on elements in a layout such as a `row`, then the element will push the other elements in that direction. Here's an example.

    Ui.row []
        [ Ui.el [] Ui.none
        , Ui.el [ alignLeft ] Ui.none
        , Ui.el [ centerX ] Ui.none
        , Ui.el [ alignRight ] Ui.none
        ]

will result in a layout like

    |-|-|    |-|    |-|

Where there are two elements on the left, one on the right, and one in the center of the space between the elements on the left and right.

**Note** For text alignment, check out `Ui.Font`!

@docs centered, centerX, centerY, alignLeft, alignRight, alignTop, alignBottom


## Content Alignment

@docs contentCentered, contentCenterX, contentCenterY, contentTop, contentBottom, contentLeft, contentRight


# Transparency

@docs opacity


# Borders

@docs border, borderWith, Edges, borderGradient, borderColor

@docs rounded, roundedWith, circle


# Backgrounds

@docs background, Gradient, backgroundGradient


# Cursors

@docs pointer, grab, grabbing


# Adjustment

@docs move, Position, up, down, left, right

@docs rotate, Angle, turns, radians

@docs scale


# Viewports

For scrolling element, we're going to borrow some terminology from 3D graphics just like the Elm [Browser](https://package.elm-lang.org/packages/elm/browser/latest/Browser-Dom) package does.

Essentially a `scrollable` is the window that you're looking through. If the content is larger than the scrollable, then scrollbars will appear.

@docs scrollable, clipped, clipWithEllipsis


# Links

@docs link, linkNewTab, download, downloadAs


# Images

@docs image


# Color

In order to use attributes like `Font.color` and `Background.color`, you'll need to make some colors!

@docs Color, rgb, rgba, palette


# Nearby Elements

Let's say we want a dropdown menu. Essentially we want to say: _put this element below this other element, but don't affect the layout when you do_.

    Ui.row []
        [ Ui.el
            [ Ui.below (Ui.text "I'm below!")
            ]
            (Ui.text "I'm normal!")
        ]

This will result in
/---------------
|- I'm normal! -|
---------------/
I'm below

Where `"I'm Below"` doesn't change the size of `Ui.row`.

This is very useful for things like dropdown menus or tooltips.

@docs above, below, onRight, onLeft, inFront, behindContent


# Mapping

@docs map


# Compatibility

@docs html, htmlAttribute

-}

import Color
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Html.Keyed
import Html.Lazy
import Internal.BitField as BitField
import Internal.Bits.Inheritance as Inheritance
import Internal.Flag as Flag exposing (Flag)
import Internal.Model2 as Two
import Internal.Style2 as Style
import Json.Decode as Decode
import Set


{-| -}
type alias Color =
    Style.Color


{-| Provide the red, green, and blue channels for the color.

Each channel takes a value between 0 and 255.

-}
rgb : Int -> Int -> Int -> Color
rgb r g b =
    Color.rgb255 r g b


{-| -}
rgba : Int -> Int -> Int -> Float -> Color
rgba r g b a =
    Color.rgba (toFloat r / 255) (toFloat g / 255) (toFloat b / 255) a


{-| The basic building block of your layout.

    howdy : Element msg
    howdy =
        Ui.el [] (Ui.text "Howdy!")

-}
type alias Element msg =
    Two.Element msg


{-| An attribute that can be attached to an `Element`
-}
type alias Attribute msg =
    Two.Attribute msg


{-| -}
html : Html msg -> Element msg
html x =
    Two.Element (\_ -> x)


{-| -}
htmlAttribute : Html.Attribute msg -> Attribute msg
htmlAttribute a =
    Two.attribute a


{-| -}
map : (msg -> msg1) -> Element msg -> Element msg1
map =
    Two.map


{-| -}
type Length
    = Px Int
    | Fill Int
    | Shrink


{-| -}
shrink : Length
shrink =
    Shrink


{-| -}
px : Int -> Length
px =
    Px


{-| Fill the available space. The available space will be split evenly between elements that have `width fill`.
-}
fill : Length
fill =
    Fill 1


{-| Sometimes you may not want to split available space evenly. In this case you can use `portion` to define which elements should have what portion of the available space.

So, two elements, one with `width (portion 2)` and one with `width (portion 3)`. The first would get 2 portions of the available space, while the second would get 3.

**Also:** `fill == portion 1`

-}
portion : Int -> Length
portion i =
    Fill (min 1 i)


{-| This is your top level node where you can turn `Element` into `Html`.
-}
layout : List (Attribute msg) -> Element msg -> Html msg
layout attrs content =
    Two.renderLayout
        { options = []
        , includeStatisStylesheet = True
        }
        emptyState
        attrs
        content


emptyState : Two.State
emptyState =
    Two.State
        { added = Set.empty
        , rules = []
        , boxes = []
        }


{-| Converts an `Element msg` to an `Html msg` but does not include the stylesheet.

You'll need to include it manually yourself

-}
embed : List (Attribute msg) -> Element msg -> Html msg
embed attrs content =
    Two.renderLayout
        { options = []
        , includeStatisStylesheet = False
        }
        emptyState
        attrs
        content


style : String -> Html msg
style styleStr =
    Html.div []
        [ Html.node "style"
            []
            [ Html.text styleStr ]
        ]


styleRules : List String -> Html msg
styleRules styleStr =
    Html.div []
        [ Html.node "style"
            []
            [ Html.text (String.join "\n" styleStr) ]
        ]


{-| -}
type alias Option =
    Two.Option


{-| When you want to render exactly nothing.
-}
none : Element msg
none =
    Two.none


{-| Create some plain text.

    text "Hello, you stylish developer!"

-}
text : String -> Element msg
text =
    Two.text


{-| The basic building block of your layout.

You can think of an `el` as a `div`, but it can only have one child.

If you want multiple children, you'll need to use something like `row` or `column`

    import Ui

    myElement : Ui.Element msg
    myElement =
        Ui.el
            [ Ui.background (Ui.rgb 0 125 0)
            , Ui.borderColor (Ui.rgb 0 178 0)
            ]
            (Ui.text "You've made a stylish element!")

-}
el : List (Attribute msg) -> Element msg -> Element msg
el attrs child =
    Two.element Two.NodeAsDiv
        Two.AsEl
        (width fill :: attrs)
        [ child ]


{-| -}
row : List (Attribute msg) -> List (Element msg) -> Element msg
row attrs children =
    Two.element Two.NodeAsDiv
        Two.AsRow
        (width fill :: attrs)
        children


{-| -}
column : List (Attribute msg) -> List (Element msg) -> Element msg
column attrs children =
    Two.element Two.NodeAsDiv
        Two.AsColumn
        (width fill :: attrs)
        children


{-| -}
id : String -> Attribute msg
id strId =
    Two.attribute (Attr.id strId)


{-| -}
noAttr : Attribute msg
noAttr =
    Two.noAttr


{-| -}
attrIf : Bool -> Attribute msg -> Attribute msg
attrIf bool attr =
    if bool then
        attr

    else
        noAttr


{-| This is just an alias for `Debug.todo`
-}
type alias Todo =
    String -> Never


{-| Highlight the borders of an element and it's children below. This can really help if you're running into some issue with your layout!

**Note** This attribute needs to be handed `Debug.todo` in order to work, even though it won't do anything with it. This is a safety measure so you don't accidently ship code with `explain` in it, as Elm won't compile with `--optimize` if you still have a `Debug` statement in your code.

    el
        [ Ui.explain Debug.todo
        ]
        (text "Help, I'm being debugged!")

-}
explain : Todo -> Attribute msg
explain _ =
    Two.class "explain"


{-| Both a source and a description are required for images.

The description is used for people using screen readers.

Leaving the description blank will cause the image to be ignored by assistive technology. This can make sense for images that are purely decorative and add no additional information.

So, take a moment to describe your image as you would to someone who has a harder time seeing.

-}
image :
    List (Attribute msg)
    ->
        { source : String
        , description : String
        }
    -> Element msg
image attrs img =
    -- let
    --     imageAttributes =
    --         attrs
    --             |> List.filter
    --                 (\a ->
    --                     case a of
    --                         Internal.Width _ ->
    --                             True
    --                         Internal.Height _ ->
    --                             True
    --                         _ ->
    --                             False
    --                 )
    -- in
    -- Internal.element
    --     Internal.asEl
    --     Internal.div
    --     (Internal.htmlClass classes.imageContainer
    --         :: attrs
    --     )
    --     (Internal.Unkeyed
    --         [ Internal.element
    --             Internal.asEl
    --             (Internal.NodeName "img")
    -- ([ Internal.Attr <| Attr.src src
    --  , Internal.Attr <| Attr.alt description
    --  ]
    --     ++ imageAttributes
    --             )
    --             (Internal.Unkeyed [])
    --         ]
    --     )
    Two.element Two.NodeAsDiv
        Two.AsEl
        (width fill :: Two.class Style.classes.imageContainer :: attrs)
        [ Two.Element
            (\s ->
                Html.img
                    [ Attr.src img.source
                    , Attr.alt img.description
                    ]
                    []
            )
        ]


{-| -}
palette :
    { background : Color
    , border : Color
    , font : Color
    }
    -> Attribute msg
palette colors =
    Two.style3
        "background-color"
        (Style.color colors.background)
        "border-color"
        (Style.color colors.border)
        "color"
        (Style.color colors.font)


{-| -}
border : Int -> Attribute msg
border options =
    Two.styleWith Flag.skip
        "border-width"
        (String.fromInt options ++ "px")


{-| -}
borderColor : Color -> Attribute msg
borderColor color =
    Two.styleWith Flag.skip
        "border-color"
        (Style.color color)


{-| -}
borderGradient :
    { width : Int
    , gradient : Gradient
    , background : Gradient
    }
    -> Attribute msg
borderGradient options =
    -- https://codyhouse.co/nuggets/css-gradient-borders
    Two.style2
        "background"
        (Style.toCssGradient options.background
            ++ " padding-box, "
            ++ Style.toCssGradient options.gradient
            ++ " border-box"
        )
        "border"
        (String.fromInt options.width ++ "px solid transparent")


{-| -}
borderWith : Edges -> Attribute msg
borderWith options =
    Two.style
        "border-width"
        ((String.fromInt options.top ++ "px ")
            ++ (String.fromInt options.right ++ "px ")
            ++ (String.fromInt options.bottom ++ "px ")
            ++ (String.fromInt options.left ++ "px")
        )


{-| -}
rounded : Int -> Attribute msg
rounded radius =
    Two.style "border-radius" (String.fromInt radius ++ "px")


{-| -}
roundedWith :
    { topLeft : Int
    , topRight : Int
    , bottomLeft : Int
    , bottomRight : Int
    }
    -> Attribute msg
roundedWith options =
    Two.style "border-radius"
        ((String.fromInt options.topLeft ++ "px ")
            ++ (String.fromInt options.topRight ++ "px ")
            ++ (String.fromInt options.bottomRight ++ "px ")
            ++ (String.fromInt options.bottomLeft ++ "px")
        )


{-| -}
circle : Attribute msg
circle =
    Two.style "border-radius" "50%"


{-| -}
background : Color -> Attribute msg
background color =
    Two.styleWith Flag.background
        "background-color"
        (Style.color color)


{-| -}
type alias Gradient =
    Style.Gradient


{-| -}
backgroundGradient : List Gradient -> Attribute msg
backgroundGradient gradient =
    Two.styleWith Flag.background
        "background-image"
        (List.map Style.toCssGradient gradient
            |> String.join ", "
        )


{-|

    el
        [ link "http://fruits.com" ]
        (text "A link to my favorite fruit provider.")

-}
link : String -> Attribute msg
link uri =
    Two.link
        { newTab = False
        , url = uri
        , download = Nothing
        }


{-| -}
linkNewTab : String -> Attribute msg
linkNewTab uri =
    Two.link
        { newTab = True
        , url = uri
        , download = Nothing
        }


{-| A link to download a file.
-}
download : String -> Attribute msg
download url =
    Two.link
        { newTab = False
        , url = url
        , download = Just ""
        }


{-| A link to download a file where you can supply a filename you would like the file downloaded as.
-}
downloadAs :
    { url : String
    , filename : String
    }
    -> Attribute msg
downloadAs opts =
    Two.link
        { newTab = False
        , url = opts.url
        , download =
            Just opts.filename
        }



{- NEARBYS -}


{-| -}
below : Element msg -> Attribute msg
below element =
    Two.nearby Two.Below element


{-| -}
above : Element msg -> Attribute msg
above element =
    Two.nearby Two.Above element


{-| -}
onRight : Element msg -> Attribute msg
onRight element =
    Two.nearby Two.OnRight element


{-| -}
onLeft : Element msg -> Attribute msg
onLeft element =
    Two.nearby Two.OnLeft element


{-| This will place an element in front of another.

**Note:** If you use this on a `layout` element, it will place the element as fixed to the scrollable which can be useful for modals and overlays.

-}
inFront : Element msg -> Attribute msg
inFront element =
    Two.nearby Two.InFront element


{-| This will place an element between the background and the content of an Ui.
-}
behindContent : Element msg -> Attribute msg
behindContent element =
    Two.nearby Two.Behind element


{-| -}
width : Length -> Attribute msg
width len =
    case len of
        Shrink ->
            Two.classWith Flag.width Style.classes.widthContent

        Px x ->
            Two.styleAndClass Flag.width
                { class = Style.classes.widthExact
                , styleName = "width"
                , styleVal = Style.px x
                }

        Fill 1 ->
            Two.classWith Flag.width
                Style.classes.widthFill

        Fill portionSize ->
            Two.Attribute
                { flag = Flag.width
                , attr =
                    Two.Attr
                        { node = Two.NodeAsDiv
                        , additionalInheritance = BitField.none
                        , attrs = []
                        , class = Just Style.classes.widthFill
                        , styles =
                            \inheritance _ ->
                                if BitField.has Inheritance.isRow inheritance then
                                    [ Tuple.pair "flex-grow" (String.fromInt (portionSize * 100000)) ]

                                else
                                    []
                        , nearby = Nothing
                        , teleport = Nothing
                        }
                }


{-| -}
widthMin : Int -> Attribute msg
widthMin x =
    Two.styleAndClass Flag.skip
        { class = Style.classes.widthBounded
        , styleName = "min-width"
        , styleVal = Style.px x
        }


{-| -}
widthMax : Int -> Attribute msg
widthMax x =
    Two.styleAndClass Flag.skip
        { class = Style.classes.widthBounded
        , styleName = "max-width"
        , styleVal = Style.px x
        }


{-| -}
heightMin : Int -> Attribute msg
heightMin x =
    Two.styleAndClass Flag.skip
        { class = Style.classes.heightBounded
        , styleName = "min-height"
        , styleVal = Style.px x
        }


{-| -}
heightMax : Int -> Attribute msg
heightMax x =
    Two.styleAndClass Flag.skip
        { class = Style.classes.heightBounded
        , styleName = "max-height"
        , styleVal = Style.px x
        }


{-| -}
height : Length -> Attribute msg
height len =
    case len of
        Shrink ->
            Two.classWith Flag.height Style.classes.heightContent

        Px x ->
            Two.styleAndClass Flag.height
                { class = Style.classes.heightExact
                , styleName = "height"
                , styleVal = Style.px x
                }

        Fill 1 ->
            Two.classWith Flag.height
                Style.classes.heightFill

        Fill portionSize ->
            Two.Attribute
                { flag = Flag.width
                , attr =
                    Two.Attr
                        { node = Two.NodeAsDiv
                        , additionalInheritance = BitField.none
                        , attrs = []
                        , class = Just Style.classes.heightFill
                        , styles =
                            \inheritance _ ->
                                if BitField.has Inheritance.isColumn inheritance then
                                    [ Tuple.pair "flex-grow" (String.fromInt (portionSize * 100000)) ]

                                else
                                    []
                        , nearby = Nothing
                        , teleport = Nothing
                        }
                }


{-| -}
scale : Float -> Attribute msg
scale s =
    Two.style "scale" (String.fromFloat s)


{-| -}
type alias Angle =
    Style.Angle


{-| -}
turns : Float -> Angle
turns t =
    Style.Angle (t * 2 * pi)


{-| -}
radians : Float -> Angle
radians =
    Style.Angle


{-| -}
rotate : Angle -> Attribute msg
rotate (Style.Angle rads) =
    Two.style "rotate" (String.fromFloat rads ++ "rad")


{-| -}
type alias Position =
    { x : Int
    , y : Int
    , z : Int
    }


{-| -}
up : Int -> Position
up y =
    { x = 0
    , y = negate y
    , z = 0
    }


{-| -}
down : Int -> Position
down y =
    { x = 0
    , y = y
    , z = 0
    }


{-| -}
right : Int -> Position
right x =
    { x = x
    , y = 0
    , z = 0
    }


{-| -}
left : Int -> Position
left x =
    { x = negate x
    , y = 0
    , z = 0
    }


{-| -}
move : Position -> Attribute msg
move pos =
    Two.style "translate"
        ((String.fromInt pos.x ++ "px ")
            ++ (String.fromInt pos.y ++ "px ")
            ++ (String.fromInt pos.z ++ "px")
        )


{-| -}
padding : Int -> Attribute msg
padding x =
    Two.style "padding" (String.fromInt x ++ "px")


{-| -}
paddingXY : Int -> Int -> Attribute msg
paddingXY x y =
    Two.style "padding"
        ((String.fromInt y ++ "px ")
            ++ (String.fromInt x ++ "px")
        )


{-| -}
paddingLeft : Int -> Attribute msg
paddingLeft x =
    Two.style "padding-left" (String.fromInt x ++ "px")


{-| -}
paddingRight : Int -> Attribute msg
paddingRight x =
    Two.style "padding-right" (String.fromInt x ++ "px")


{-| -}
paddingTop : Int -> Attribute msg
paddingTop x =
    Two.style "padding-top" (String.fromInt x ++ "px")


{-| -}
paddingBottom : Int -> Attribute msg
paddingBottom x =
    Two.style "padding-bottom" (String.fromInt x ++ "px")


{-| A record that is used to set padding or border widths individually.

    Ui.paddingWith
        { top = 10
        , right = 20
        , bottom = 30
        , left = 40
        }

You can also use `Edges` as a constructor. So, the above is the same as this:

    Ui.paddingWith (Ui.Edges 10 20 30 40)

Where the numbers start at the top and proceed clockwise.

-}
type alias Edges =
    { top : Int
    , right : Int
    , bottom : Int
    , left : Int
    }


{-| -}
paddingWith : Edges -> Attribute msg
paddingWith pad =
    Two.style "padding"
        ((String.fromInt pad.top ++ "px ")
            ++ (String.fromInt pad.right ++ "px ")
            ++ (String.fromInt pad.bottom ++ "px ")
            ++ (String.fromInt pad.left ++ "px")
        )


{-| -}
centerX : Attribute msg
centerX =
    Two.classWith Flag.xAlign Style.classes.alignCenterX


{-| -}
centerY : Attribute msg
centerY =
    Two.classWith Flag.yAlign Style.classes.alignCenterY


{-| -}
alignTop : Attribute msg
alignTop =
    Two.classWith Flag.yAlign Style.classes.alignTop


{-| -}
alignBottom : Attribute msg
alignBottom =
    Two.classWith Flag.yAlign Style.classes.alignBottom


{-| -}
alignLeft : Attribute msg
alignLeft =
    Two.classWith Flag.xAlign Style.classes.alignLeft


{-| -}
alignRight : Attribute msg
alignRight =
    Two.classWith Flag.xAlign Style.classes.alignRight



{- Content Alignment -}


{-| -}
wrap : Attribute msg
wrap =
    Two.style "flex-wrap" "wrap"


{-| -}
contentCenterX : Attribute msg
contentCenterX =
    Two.classWith Flag.xContentAlign Style.classes.contentCenterX


{-| -}
contentCenterY : Attribute msg
contentCenterY =
    Two.classWith Flag.yContentAlign Style.classes.contentCenterY


{-| -}
contentTop : Attribute msg
contentTop =
    Two.classWith Flag.yContentAlign Style.classes.contentTop


{-| -}
contentBottom : Attribute msg
contentBottom =
    Two.classWith Flag.yContentAlign Style.classes.contentBottom


{-| -}
contentLeft : Attribute msg
contentLeft =
    Two.classWith Flag.xContentAlign Style.classes.contentLeft


{-| -}
contentRight : Attribute msg
contentRight =
    Two.classWith Flag.xContentAlign Style.classes.contentRight


{-| -}
spaceEvenly : Attribute msg
spaceEvenly =
    Two.class Style.classes.spaceEvenly


{-| -}
spacing : Int -> Attribute msg
spacing x =
    Two.Attribute
        { flag = Flag.spacing
        , attr =
            Two.Attr
                { node = Two.NodeAsDiv
                , additionalInheritance =
                    BitField.none
                        |> BitField.set Inheritance.spacingX x
                        |> BitField.set Inheritance.spacingY x
                , attrs = []
                , class = Nothing
                , styles =
                    \inheritance _ ->
                        if BitField.has Inheritance.isTextLayout inheritance then
                            []

                        else
                            [ Tuple.pair "gap"
                                (String.fromInt x
                                    ++ "px"
                                )
                            ]
                , nearby = Nothing
                , teleport = Nothing
                }
        }


{-| In the majority of cases you'll just need to use `spacing`, which will work as intended.

However for some layouts, like `textColumn`, you may want to set a different spacing for the x axis compared to the y axis.

-}
spacingWith : { horizontal : Int, vertical : Int } -> Attribute msg
spacingWith { horizontal, vertical } =
    Two.Attribute
        { flag = Flag.spacing
        , attr =
            Two.Attr
                { node = Two.NodeAsDiv
                , additionalInheritance =
                    BitField.none
                        |> BitField.set Inheritance.spacingX horizontal
                        |> BitField.set Inheritance.spacingY vertical
                , attrs = []
                , class = Nothing
                , styles =
                    \inheritance _ ->
                        if BitField.has Inheritance.isTextLayout inheritance then
                            []

                        else
                            [ Tuple.pair "gap"
                                (String.fromInt vertical
                                    ++ "px "
                                    ++ String.fromInt horizontal
                                    ++ "px"
                                )
                            ]
                , nearby = Nothing
                , teleport = Nothing
                }
        }


{-| -}
opacity : Float -> Attribute msg
opacity o =
    Two.style "opacity" (String.fromFloat o)


{-| -}
scrollable : List (Attribute msg) -> Element msg -> Element msg
scrollable attrs child =
    Two.element Two.NodeAsDiv
        Two.AsEl
        (scrollbarY
            :: width fill
            :: height fill
            :: attrs
        )
        [ child ]


{-| -}
scrollbars : Attribute msg
scrollbars =
    Two.classWith Flag.overflow Style.classes.scrollbars


{-| -}
scrollbarY : Attribute msg
scrollbarY =
    Two.classWith Flag.overflow Style.classes.scrollbarsY


{-| -}
scrollbarX : Attribute msg
scrollbarX =
    Two.classWith Flag.overflow Style.classes.scrollbarsX


{-| -}
clipWithEllipsis : Attribute msg
clipWithEllipsis =
    Two.classWith Flag.fontEllipsis Style.classes.ellipses


{-| Clip the content if it overflows.

Similar to `scrollable`, this element will fill the space it's given.

If the content overflows this element, it will be clipped.

-}
clipped : List (Attribute msg) -> Element msg -> Element msg
clipped attrs child =
    Two.element Two.NodeAsDiv
        Two.AsEl
        (clip
            :: width fill
            :: height fill
            :: attrs
        )
        [ child ]


{-| -}
clip : Attribute msg
clip =
    Two.classWith Flag.overflow Style.classes.clip


{-| -}
clipY : Attribute msg
clipY =
    Two.classWith Flag.overflow Style.classes.clipY


{-| -}
clipX : Attribute msg
clipX =
    Two.classWith Flag.overflow Style.classes.clipX


{-| Set the cursor to be a pointing hand when it's hovering over this Ui.
-}
pointer : Attribute msg
pointer =
    Two.class Style.classes.cursorPointer


{-| -}
grab : Attribute msg
grab =
    Two.class Style.classes.cursorGrab


{-| -}
grabbing : Attribute msg
grabbing =
    Two.class Style.classes.cursorGrabbing
