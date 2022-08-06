module Ui exposing
    ( Element, none, text, el
    , row, column
    , ellip, paragraph, textColumn
    , id, noAttr
    , Attribute, Length, px, fill, portion
    , width, widthMin, widthMax
    , height, heightMin, heightMax
    , explain
    , padding, paddingXY, paddingEach
    , spacing, spacingXY, spaceEvenly
    , centerX, centerY, alignLeft, alignRight, alignTop, alignBottom
    , opacity
    , pointer, grab, grabbing
    , moveUp, moveDown, moveRight, moveLeft, rotate, scale
    , scrollable, clipped
    , layout, layoutWith, Option, focusStyle, FocusStyle
    , link, linkNewTab, download
    , image
    , Color, rgb
    , above, below, onRight, onLeft, inFront, behindContent
    , Angle, up, down, right, left
    , turns, radians
    , init, Msg, update, State
    , Animator, updateWith, subscription
    , map, mapAttribute
    , html, htmlAttribute
    , clip, clipX, clipY, embed, scrollbarX, scrollbarY, transition
    )

{-|


# Basic Elements

@docs Element, none, text, el


# Rows and Columns

When we want more than one child on an element, we want to be _specific_ about how they will be laid out.

So, the common ways to do that would be `row` and `column`.

@docs row, column


# Text Layout

Text layout needs some specific considerations.

@docs ellip, paragraph, textColumn


# Attributes

@docs id, noAttr


# Size

@docs Attribute, Length, px, fill, portion

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

@docs padding, paddingXY, paddingEach

@docs spacing, spacingXY, spaceEvenly


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

@docs centerX, centerY, alignLeft, alignRight, alignTop, alignBottom


# Transparency

@docs opacity


# Cursors

@docs pointer, grab, grabbing


# Adjustment

@docs moveUp, moveDown, moveRight, moveLeft, rotate, scale


# Viewports

For scrolling element, we're going to borrow some terminology from 3D graphics just like the Elm [Browser](https://package.elm-lang.org/packages/elm/browser/latest/Browser-Dom) package does.

Essentially a `scrollable` is the window that you're looking through. If the content is larger than the scrollable, then scrollbars will appear.

@docs scrollable, clipped


# Rendering

@docs layout, layoutWith, Option, focusStyle, FocusStyle


# Links

@docs link, linkNewTab, download


# Images

@docs image


# Color

In order to use attributes like `Font.color` and `Background.color`, you'll need to make some colors!

@docs Color, rgb


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


# Angles

@docs Angle, up, down, right, left

@docs turns, radians


# Animation

@docs init, Msg, update, State

@docs Animator, updateWith, subscription, watching


# Mapping

@docs map, mapAttribute


# Compatibility

@docs html, htmlAttribute

-}

import Animator
import Animator.Timeline
import Animator.Watcher
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Html.Keyed
import Html.Lazy
import Internal.BitEncodings as Bits
import Internal.BitField as BitField
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
    Style.Rgb r g b


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
html : Html msg -> Two.Element msg
html x =
    Two.Element (\_ -> x)


{-| -}
htmlAttribute : Html.Attribute msg -> Attribute msg
htmlAttribute a =
    Two.Attribute
        { flag = Flag.skip
        , attr = Two.Attr a
        }


{-| -}
map : (msg -> msg1) -> Element msg -> Element msg1
map =
    Two.map


{-| -}
mapAttribute : (Msg msg2 -> msg2) -> (msg -> msg2) -> Attribute msg -> Attribute msg2
mapAttribute =
    Two.mapAttr


{-| -}
type Length
    = Px Int
    | Fill Int


{-| -}
px : Int -> Length
px =
    Px


{-| Fill the available space. The available space will be split evenly between elements that have `width fill`.
-}
fill : Length
fill =
    Fill 1


{-| -}
ellip : Attribute msg
ellip =
    Two.Attribute
        { flag = Flag.skip
        , attr = Two.Class Style.classes.ellipses
        }


{-| Sometimes you may not want to split available space evenly. In this case you can use `portion` to define which elements should have what portion of the available space.

So, two elements, one with `width (portion 2)` and one with `width (portion 3)`. The first would get 2 portions of the available space, while the second would get 3.

**Also:** `fill == portion 1`

-}
portion : Int -> Length
portion =
    Fill


{-| This is your top level node where you can turn `Element` into `Html`.
-}
layout : List (Attribute msg) -> Two.Element msg -> Html msg
layout attrs content =
    Two.unwrap Two.zero <|
        Two.element Two.AsRoot
            attrs
            [ Two.Element
                (\_ ->
                    Html.Keyed.node "div"
                        []
                        [ ( "static", Html.Lazy.lazy style Style.rules )
                        ]
                )
            , content
            ]


init : State
init =
    Two.State
        { added = Set.empty
        , rules = []
        , boxes = []
        }


{-| -}
type alias State =
    Two.State


{-| -}
type alias Msg msg =
    Two.Msg msg


{-| -}
transition : (Msg msg -> msg) -> msg -> msg
transition toMsg appMsg =
    toMsg (Two.RefreshBoxesAndThen appMsg)


{-| -}
type alias Animator msg model =
    Two.Animator msg model


{-| -}
update : (Msg msg -> msg) -> Msg msg -> State -> ( State, Cmd msg )
update =
    Two.update


{-| -}
updateWith :
    (Msg msg -> msg)
    -> Msg msg
    -> State
    ->
        { ui : State -> model
        , timelines : Animator msg model
        }
    -> ( model, Cmd msg )
updateWith =
    Two.updateWith


subscription : (Msg msg -> msg) -> State -> Animator msg model -> model -> Sub msg
subscription =
    Two.subscription


watching :
    { get : model -> Animator.Timeline.Timeline state
    , set : Animator.Timeline.Timeline state -> model -> model
    , onStateChange : state -> Maybe msg
    }
    -> Animator msg model
    -> Animator msg model
watching config anim =
    { animator = Animator.Watcher.watching config.get config.set anim.animator
    , onStateChange =
        -- config.onStateChange << config.get
        \model ->
            let
                future =
                    []

                -- TODO: wire this up once elm-animator supports Animator.future
                -- Animator.future (config.get model)
                -- |> List.map (Tuple.mapSecond anim.onStateChange)
            in
            future ++ anim.onStateChange model
    }


{-| -}
layoutWith :
    { options : List Option }
    -> State
    -> List (Attribute msg)
    -> Element msg
    -> Html msg
layoutWith =
    Two.renderLayout


{-| Converts an `Element msg` to an `Html msg` but does not include the stylesheet.

You'll need to include it manually yourself

-}
embed : List (Attribute msg) -> Element msg -> Html msg
embed attrs content =
    Two.unwrap Two.zero <|
        Two.element Two.AsRoot
            attrs
            [ content
            ]


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


{-| -}
defaultFocus :
    { borderColor : Maybe Color
    , backgroundColor : Maybe Color
    , shadow :
        Maybe
            { x : Float
            , y : Float
            , size : Float
            , blur : Float
            , color : Color
            }
    }
defaultFocus =
    Two.focusDefaultStyle


{-| -}
type alias FocusStyle =
    { borderColor : Maybe Color
    , backgroundColor : Maybe Color
    , shadow :
        Maybe
            { x : Float
            , y : Float
            , size : Float
            , blur : Float
            , color : Color
            }
    }


{-| -}
focusStyle : FocusStyle -> Two.Option
focusStyle =
    Two.FocusStyleOption


{-| When you want to render exactly nothing.
-}
none : Two.Element msg
none =
    Two.none


{-| Create some plain text.

    text "Hello, you stylish developer!"

**Note** text does not wrap by default. In order to get text to wrap, check out `paragraph`!

-}
text : String -> Two.Element msg
text =
    Two.text


{-| The basic building block of your layout.

You can think of an `el` as a `div`, but it can only have one child.

If you want multiple children, you'll need to use something like `row` or `column`

    import Element exposing (Element, rgb)
    import Ui.Background as Background
    import Ui.Border as Border

    myElement : Element msg
    myElement =
        Ui.el
            [ Background.color (rgb 0 0.5 0)
            , Border.color (rgb 0 0.7 0)
            ]
            (Ui.text "You've made a stylish element!")

-}
el : List (Attribute msg) -> Two.Element msg -> Two.Element msg
el attrs child =
    Two.element Two.AsEl
        attrs
        [ child ]


{-| -}
row : List (Attribute msg) -> List (Two.Element msg) -> Two.Element msg
row attrs children =
    Two.element Two.AsRow
        attrs
        children


{-| -}
column : List (Attribute msg) -> List (Two.Element msg) -> Two.Element msg
column attrs children =
    Two.element Two.AsColumn
        attrs
        children


{-| -}
id : String -> Attribute msg
id strId =
    Two.attribute (Attr.id strId)


{-| -}
noAttr : Attribute msg
noAttr =
    Attribute
        { flag = Flag.skip
        , attr = NoAttribute
        }


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


{-| A paragraph will layout all children as wrapped, inline elements.

    import Element exposing (el, paragraph, text)
    import Ui.Font as Font

    view =
        paragraph []
            [ text "lots of text ...."
            , el [ Font.bold ] (text "this is bold")
            , text "lots of text ...."
            ]

This is really useful when you want to markup text by having some parts be bold, or some be links, or whatever you so desire.

Also, if a child element has `alignLeft` or `alignRight`, then it will be moved to that side and the text will flow around it, (ah yes, `float` behavior).

This makes it particularly easy to do something like a [dropped capital](https://en.wikipedia.org/wiki/Initial).

    import Element exposing (alignLeft, el, padding, paragraph, text)
    import Ui.Font as Font

    view =
        paragraph []
            [ el
                [ alignLeft
                , padding 5
                ]
                (text "S")
            , text "o much text ...."
            ]

Which will look something like

![A paragraph where the first letter is twice the height of the others](https://mdgriffith.gitbooks.io/style-elements/content/assets/Screen%20Shot%202017-08-25%20at%209.41.52%20PM.png)

**Note** `spacing` on a paragraph will set the pixel spacing between lines.

-}
paragraph : List (Attribute msg) -> List (Two.Element msg) -> Two.Element msg
paragraph attrs children =
    -- Internal.element
    --     Internal.asParagraph
    --     Internal.div
    --     (Internal.Describe Internal.Paragraph
    --         :: width fill
    --         :: spacing 5
    --         :: attrs
    --     )
    --     (Internal.Unkeyed children)
    Two.element Two.AsParagraph
        attrs
        children


{-| Now that we have a paragraph, we need some way to attach a bunch of paragraph's together.

To do that we can use a `textColumn`.

The main difference between a `column` and a `textColumn` is that `textColumn` will flow the text around elements that have `alignRight` or `alignLeft`, just like we just saw with paragraph.

In the following example, we have a `textColumn` where one child has `alignLeft`.

    Ui.textColumn [ spacing 10, padding 10 ]
        [ paragraph [] [ text "lots of text ...." ]
        , el [ alignLeft ] none
        , paragraph [] [ text "lots of text ...." ]
        ]

Which will result in something like:

![A text layout where an image is on the left.](https://mdgriffith.gitbooks.io/style-elements/content/assets/Screen%20Shot%202017-08-25%20at%208.42.39%20PM.png)

-}
textColumn : List (Attribute msg) -> List (Two.Element msg) -> Two.Element msg
textColumn attrs children =
    Two.element Two.AsTextColumn
        attrs
        children


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
    Two.element Two.AsEl
        (Two.class Style.classes.imageContainer :: attrs)
        [ Two.Element
            (\s ->
                Html.img
                    [ Attr.src img.source
                    , Attr.alt img.description
                    ]
                    []
            )
        ]


{-|

    el
        [ link "http://fruits.com" ]
        (text "A link to my favorite fruit provider.")

-}
link : String -> Attribute msg
link uri =
    Two.Attribute
        { flag = Flag.isLink
        , attr =
            Two.Link
                { newTab = False
                , url = uri
                , download = Nothing
                }
        }


{-| -}
linkNewTab : String -> Attribute msg
linkNewTab uri =
    Two.Attribute
        { flag = Flag.isLink
        , attr =
            Two.Link
                { newTab = True
                , url = uri
                , download = Nothing
                }
        }


{-| A link to download a file.

You can optionally supply a filename you would like the file downloaded as.

If no filename is provided, whatever the server says the filename should be will be used.

-}
download :
    { url : String
    , filename : Maybe String
    }
    -> Attribute msg
download opts =
    Two.Attribute
        { flag = Flag.isLink
        , attr =
            Two.Link
                { newTab = False
                , url = opts.url
                , download =
                    case opts.filename of
                        Nothing ->
                            Just ""

                        _ ->
                            opts.filename
                }
        }



{- NEARBYS -}


{-| -}
below : Two.Element msg -> Attribute msg
below element =
    Two.Attribute
        { flag = Flag.skip
        , attr = Two.Nearby Two.Below element
        }


{-| -}
above : Two.Element msg -> Attribute msg
above element =
    Two.Attribute
        { flag = Flag.skip
        , attr = Two.Nearby Two.Above element
        }


{-| -}
onRight : Two.Element msg -> Attribute msg
onRight element =
    Two.Attribute
        { flag = Flag.skip
        , attr = Two.Nearby Two.OnRight element
        }


{-| -}
onLeft : Two.Element msg -> Attribute msg
onLeft element =
    Two.Attribute
        { flag = Flag.skip
        , attr = Two.Nearby Two.OnLeft element
        }


{-| This will place an element in front of another.

**Note:** If you use this on a `layout` element, it will place the element as fixed to the scrollable which can be useful for modals and overlays.

-}
inFront : Two.Element msg -> Attribute msg
inFront element =
    Two.Attribute
        { flag = Flag.skip
        , attr = Two.Nearby Two.InFront element
        }


{-| This will place an element between the background and the content of an Ui.
-}
behindContent : Two.Element msg -> Attribute msg
behindContent element =
    Two.Attribute
        { flag = Flag.skip
        , attr = Two.Nearby Two.Behind element
        }


{-| -}
width : Length -> Attribute msg
width len =
    case len of
        Px x ->
            Two.styleAndClass Flag.width
                { class = Style.classes.widthExact
                , styleName = "width"
                , styleVal = Style.px x
                }

        Fill f ->
            Two.Attribute
                { flag = Flag.width
                , attr = Two.WidthFill f
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
        Px x ->
            Two.styleAndClass Flag.height
                { class = Style.classes.heightExact
                , styleName = "height"
                , styleVal = Style.px x
                }

        Fill f ->
            Two.Attribute
                { flag = Flag.height
                , attr =
                    Two.HeightFill f
                }


{-| -}
scale : Float -> Attribute msg
scale s =
    Two.Attribute
        { flag = Flag.skip
        , attr = Two.TransformPiece 3 s
        }


{-| -}
type alias Angle =
    Style.Angle


{-| -}
up : Angle
up =
    Style.Angle 0


{-| -}
down : Angle
down =
    Style.Angle pi


{-| -}
right : Angle
right =
    Style.Angle (pi / 2)


{-| -}
left : Angle
left =
    Style.Angle (pi + (pi / 2))


{-| -}
turns : Float -> Angle
turns t =
    Style.Angle (t * 2 * pi)


{-| -}
radians : Float -> Angle
radians =
    Style.Angle


{-| Angle is given in radians. [Here are some conversion functions if you want to use another unit.](https://package.elm-lang.org/packages/elm/core/latest/Basics#degrees)
-}
rotate : Float -> Attribute msg
rotate r =
    Two.Attribute
        { flag = Flag.skip
        , attr = Two.TransformPiece 2 r
        }


{-| -}
moveUp : Float -> Attribute msg
moveUp x =
    Two.Attribute
        { flag = Flag.skip
        , attr = Two.TransformPiece 1 (negate x)
        }


{-| -}
moveDown : Float -> Attribute msg
moveDown x =
    Two.Attribute
        { flag = Flag.skip
        , attr = Two.TransformPiece 1 x
        }


{-| -}
moveRight : Float -> Attribute msg
moveRight x =
    Two.Attribute
        { flag = Flag.skip
        , attr =
            Two.TransformPiece 0 x
        }


{-| -}
moveLeft : Float -> Attribute msg
moveLeft x =
    Two.Attribute
        { flag = Flag.skip
        , attr =
            Two.TransformPiece 0 (negate x)
        }


{-| -}
padding : Int -> Attribute msg
padding x =
    Two.Attribute
        { flag = Flag.padding
        , attr =
            Two.Padding
                { top = x
                , left = x
                , bottom = x
                , right = x
                }
        }


{-| Set horizontal and vertical padding.
-}
paddingXY : Int -> Int -> Attribute msg
paddingXY x y =
    Two.Attribute
        { flag = Flag.padding
        , attr =
            Two.Padding
                { top = y
                , left = x
                , bottom = y
                , right = x
                }
        }


{-| If you find yourself defining unique paddings all the time, you might consider defining

    edges =
        { top = 0
        , right = 0
        , bottom = 0
        , left = 0
        }

And then just do

    paddingEach { edges | right = 5 }

-}
paddingEach : { top : Int, right : Int, bottom : Int, left : Int } -> Attribute msg
paddingEach pad =
    Two.Attribute
        { flag = Flag.padding
        , attr = Two.Padding pad
        }


{-| -}
centerX : Attribute msg
centerX =
    Two.Attribute
        { flag = Flag.xAlign
        , attr = Two.Class Style.classes.alignCenterX
        }


{-| -}
centerY : Attribute msg
centerY =
    Two.Attribute
        { flag = Flag.yAlign
        , attr = Two.Class Style.classes.alignCenterY
        }


{-| -}
alignTop : Attribute msg
alignTop =
    Two.Attribute
        { flag = Flag.yAlign
        , attr = Two.Class Style.classes.alignTop
        }


{-| -}
alignBottom : Attribute msg
alignBottom =
    Two.Attribute
        { flag = Flag.yAlign
        , attr = Two.Class Style.classes.alignBottom
        }


{-| -}
alignLeft : Attribute msg
alignLeft =
    Two.Attribute
        { flag = Flag.xAlign
        , attr = Two.Class Style.classes.alignLeft
        }


{-| -}
alignRight : Attribute msg
alignRight =
    Two.Attribute
        { flag = Flag.xAlign
        , attr = Two.Class Style.classes.alignRight
        }


{-| -}
spaceEvenly : Attribute msg
spaceEvenly =
    Two.Attribute
        { flag = Flag.spacing
        , attr = Two.Class Style.classes.spaceEvenly
        }


{-| -}
spacing : Int -> Attribute msg
spacing x =
    Two.Attribute
        { flag = Flag.spacing
        , attr = Two.Spacing x x
        }


{-| In the majority of cases you'll just need to use `spacing`, which will work as intended.

However for some layouts, like `textColumn`, you may want to set a different spacing for the x axis compared to the y axis.

-}
spacingXY : Int -> Int -> Attribute msg
spacingXY x y =
    Two.Attribute
        { flag = Flag.spacing
        , attr = Two.Spacing x y
        }


{-| Make an element transparent and have it ignore any mouse or touch events, though it will stil take up space.
-}
transparent : Bool -> Attribute msg
transparent on =
    if on then
        alpha 0

    else
        alpha 1


{-| A capped value between 0.0 and 1.0, where 0.0 is transparent and 1.0 is fully opaque.

Semantically equivalent to html opacity.

-}
alpha : Float -> Attribute msg
alpha o =
    Two.style "opacity" (String.fromFloat (1 + (-1 * o)))


{-| -}
opacity : Float -> Attribute msg
opacity o =
    Two.style "opacity" (String.fromFloat o)


{-| -}
scrollable : List (Attribute msg) -> Two.Element msg -> Two.Element msg
scrollable attrs child =
    Two.element Two.AsEl
        (scrollbarY
            :: width fill
            :: height fill
            :: attrs
        )
        [ child ]


{-| -}
scrollbars : Attribute msg
scrollbars =
    Two.Attribute
        { flag = Flag.overflow
        , attr = Two.Class Style.classes.scrollbars
        }


{-| -}
scrollbarY : Attribute msg
scrollbarY =
    Two.Attribute
        { flag = Flag.overflow
        , attr = Two.Class Style.classes.scrollbarsY
        }


{-| -}
scrollbarX : Attribute msg
scrollbarX =
    Two.Attribute
        { flag = Flag.overflow
        , attr = Two.Class Style.classes.scrollbarsX
        }


{-| Clip the content if it overflows.

Similar to `scrollable`, this element will fill the space it's given.

If the content overflows this element, it will be clipped.

-}
clipped : List (Attribute msg) -> Two.Element msg -> Two.Element msg
clipped attrs child =
    Two.element Two.AsEl
        (clip
            :: width fill
            :: height fill
            :: attrs
        )
        [ child ]


{-| -}
clip : Attribute msg
clip =
    Two.Attribute
        { flag = Flag.overflow
        , attr = Two.Class Style.classes.clip
        }


{-| -}
clipY : Attribute msg
clipY =
    Two.Attribute
        { flag = Flag.overflow
        , attr = Two.Class Style.classes.clipY
        }


{-| -}
clipX : Attribute msg
clipX =
    Two.Attribute
        { flag = Flag.overflow
        , attr = Two.Class Style.classes.clipX
        }


{-| Set the cursor to be a pointing hand when it's hovering over this Ui.
-}
pointer : Attribute msg
pointer =
    Two.Attribute
        { flag = Flag.cursor
        , attr = Two.Class Style.classes.cursorPointer
        }


{-| -}
grab : Attribute msg
grab =
    Two.Attribute
        { flag = Flag.cursor
        , attr = Two.Class Style.classes.cursorGrab
        }


{-| -}
grabbing : Attribute msg
grabbing =
    Two.Attribute
        { flag = Flag.cursor
        , attr = Two.Class Style.classes.cursorGrabbing
        }
