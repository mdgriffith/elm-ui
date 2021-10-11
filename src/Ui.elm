module Ui exposing
    ( Element, none, text, el
    , row, wrappedRow, column
    , paragraph, textColumn
    , Column, table, IndexedColumn, indexedTable
    , Attribute, Length, px, fill, portion, width, widthMin, widthMax, height, heightMin, heightMax
    , ellip
    , explain
    , padding, paddingXY, paddingEach
    , spacing, spacingXY, spaceEvenly
    , centerX, centerY, alignLeft, alignRight, alignTop, alignBottom
    , transparent, alpha
    , pointer, grab, grabbing
    , moveUp, moveDown, moveRight, moveLeft, rotate, scale
    , viewport, clipped
    , layout, layoutWith, Option, focusStyle, FocusStyle
    , link, linkNewTab, download, downloadAs
    , image
    , Color, rgb
    , above, below, onRight, onLeft, inFront, behindContent
    , Device, DeviceClass(..), Orientation(..), classifyDevice
    , Angle, up, down, right, left
    , turns, radians
    , update
    , updateWith, subscription
    , map, mapAttribute
    , html, htmlAttribute
    , Msg, Phase, State, Transition, clip, clipX, clipY, duration, embed, init, scrollbarX, scrollbarY, transition
    )

{-|


# Basic Elements

@docs Element, none, text, el


# Rows and Columns

When we want more than one child on an element, we want to be _specific_ about how they will be laid out.

So, the common ways to do that would be `row` and `column`.

@docs row, wrappedRow, column


# Text Layout

Text layout needs some specific considerations.

@docs paragraph, textColumn


# Data Table

@docs Column, table, IndexedColumn, indexedTable


# Size

@docs Attribute, Length, px, fill, portion, width, widthMin, widthMax, height, heightMin, heightMax

@docs ellip


# Debugging

@docs explain


# Padding and Spacing

There's no concept of margin in `elm-ui`, instead we have padding and spacing.

Padding is the distance between the outer edge and the content, and spacing is the space between children.

So, if we have the following row, with some padding and spacing.

    Ui.row [ padding 10, spacing 7 ]
        [ Ui.el [] none
        , Ui.el [] none
        , Ui.el [] none
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

@docs transparent, alpha


# Cursors

@docs pointer, grab, grabbing


# Adjustment

@docs moveUp, moveDown, moveRight, moveLeft, rotate, scale


# Viewports

For scrolling element, we're going to borrow some terminology from 3D graphics just like the Elm [Browser](https://package.elm-lang.org/packages/elm/browser/latest/Browser-Dom) package does.

Essentially a `viewport` is the window that you're looking through. If the content is larger than the viewport, then scrollbars will appear.

@docs viewport, clipped


# Rendering

@docs layout, layoutWith, Option, noStaticStyleSheet, forceHover, noHover, focusStyle, FocusStyle


# Links

@docs link, linkNewTab, download, downloadAs


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


# Responsiveness

The main technique for responsiveness is to store window size information in your model.

Install the `Browser` package, and set up a subscription for [`Browser.Events.onResize`](https://package.elm-lang.org/packages/elm/browser/latest/Browser-Events#onResize).

You'll also need to retrieve the initial window size. You can either use [`Browser.Dom.getViewport`](https://package.elm-lang.org/packages/elm/browser/latest/Browser-Dom#getViewport) or pass in `window.innerWidth` and `window.innerHeight` as flags to your program, which is the preferred way. This requires minor setup on the JS side, but allows you to avoid the state where you don't have window info.

@docs Device, DeviceClass, Orientation, classifyDevice


# Angles

@docs Angle, up, down, right, left

@docs turns, radians


# Animation

@docs update

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
import Html.Keyed
import Html.Lazy
import Internal.Flag2 as Flag exposing (Flag)
import Internal.Model2 as Two
import Internal.Style2 as Style
import Set


{-| -}
type alias Color =
    Style.Color


{-| Provide the red, green, and blue channels for the color.

Each channel takes a value between 0 and 1.

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
htmlAttribute =
    Two.Attr


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
    | Content
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
    Two.Attr (Attr.class Style.classes.ellipses)


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
type alias Phase =
    Two.Phase


type alias Transition =
    Two.Transition


duration : Int -> Two.Transition
duration dur =
    Two.Transition
        { arriving =
            { durDelay = dur
            , curve = 1
            }
        , departing =
            { durDelay = dur
            , curve = 1
            }
        }


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
layoutWith : { options : List Option } -> State -> List (Attribute msg) -> Two.Element msg -> Html msg
layoutWith { options } (Two.State state) attrs content =
    Two.unwrap Two.zero <|
        Two.element Two.AsRoot
            attrs
            [ Two.Element
                (\_ ->
                    Html.Keyed.node "div"
                        []
                        [ ( "static", Html.Lazy.lazy style Style.rules )
                        , ( "animations", Html.Lazy.lazy styleRules state.rules )
                        , ( "boxes"
                          , Html.div [] (List.map viewBox state.boxes)
                          )
                        ]
                )
            , content
            ]


viewBox ( id, box ) =
    Html.div
        [ Attr.style "position" "absolute"
        , Attr.style "left" (String.fromFloat box.x ++ "px")
        , Attr.style "top" (String.fromFloat box.y ++ "px")
        , Attr.style "width" (String.fromFloat box.width ++ "px")
        , Attr.style "height" (String.fromFloat box.height ++ "px")
        , Attr.style "z-index" "10"
        , Attr.style "background-color" "rgba(255,0,0,0.1)"
        , Attr.style "border-radius" "3px"
        , Attr.style "border" "3px dashed rgba(255,0,0,0.2)"
        , Attr.style "box-sizing" "border-box"
        ]
        [--Html.text (Debug.toString id)
        ]


{-| Converts an `Element msg` to an `Html msg` but does not include the stylesheet.

You'll need to include it manually yourself

-}
embed : List (Attribute msg) -> Two.Element msg -> Html msg
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
            { color : Color
            , offset : ( Int, Int )
            , blur : Int
            , size : Int
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
            { color : Color
            , offset : ( Int, Int )
            , blur : Int
            , size : Int
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
        (width Content
            :: height Content
            :: attrs
        )
        [ child ]


{-| -}
row : List (Attribute msg) -> List (Two.Element msg) -> Two.Element msg
row attrs children =
    Two.element Two.AsRow
        (width Content
            :: height Content
            :: attrs
        )
        children


{-| -}
column : List (Attribute msg) -> List (Two.Element msg) -> Two.Element msg
column attrs children =
    Two.element Two.AsColumn
        (width Content
            :: height Content
            :: attrs
        )
        children


{-| Same as `row`, but will wrap if it takes up too much horizontal space.
-}
wrappedRow : List (Attribute msg) -> List (Two.Element msg) -> Two.Element msg
wrappedRow attrs children =
    -- in order to make spacing work:
    --      the margin is only applied to the right and bottom of child elements
    --      We have an intermediate element which has a negative bottom and right margin to keep the sizing correct.
    --      There is some overflow with the intermediate element, so we set pointer events none on it and reenable pointer events on children.
    Two.element Two.AsEl
        attrs
        [ Two.element Two.AsWrappedRow
            (List.concatMap Two.wrappedRowAttributes attrs)
            children
        ]


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


{-| -}
type alias Column record msg =
    { header : Element msg
    , width : Length
    , view : record -> Element msg
    }


{-| Show some tabular data.

Start with a list of records and specify how each column should be rendered.

So, if we have a list of `persons`:

    type alias Person =
        { firstName : String
        , lastName : String
        }

    persons : List Person
    persons =
        [ { firstName = "David"
          , lastName = "Bowie"
          }
        , { firstName = "Florence"
          , lastName = "Welch"
          }
        ]

We could render it using

    Ui.table []
        { data = persons
        , columns =
            [ { header = Ui.text "First Name"
              , width = fill
              , view =
                    \person ->
                        Ui.text person.firstName
              }
            , { header = Ui.text "Last Name"
              , width = fill
              , view =
                    \person ->
                        Ui.text person.lastName
              }
            ]
        }

**Note:** Sometimes you might not have a list of records directly in your model. In this case it can be really nice to write a function that transforms some part of your model into a list of records before feeding it into `Ui.table`.

-}
table :
    List (Attribute msg)
    ->
        { data : List records
        , columns : List (Column records msg)
        }
    -> Two.Element msg
table attrs config =
    -- tableHelper attrs
    --     { data = config.data
    --     , columns =
    --         List.map InternalColumn config.columns
    --     }
    Two.text "pls, do this"


{-| -}
type alias IndexedColumn record msg =
    { header : Element msg
    , width : Length
    , view : Int -> record -> Element msg
    }


{-| Same as `Ui.table` except the `view` for each column will also receive the row index as well as the record.
-}
indexedTable :
    List (Attribute msg)
    ->
        { data : List records
        , columns : List (IndexedColumn records msg)
        }
    -> Two.Element msg
indexedTable attrs config =
    -- tableHelper attrs
    --     { data = config.data
    --     , columns =
    --         List.map InternalIndexedColumn config.columns
    --     }
    Two.text "yo!"


{-| -}
type alias InternalTable records msg =
    { data : List records
    , columns : List (InternalTableColumn records msg)
    }


{-| -}
type InternalTableColumn record msg
    = InternalIndexedColumn (IndexedColumn record msg)
    | InternalColumn (Column record msg)


tableHelper : List (Attribute msg) -> InternalTable data msg -> Two.Element msg
tableHelper attrs config =
    -- let
    --     ( sX, sY ) =
    --         Internal.getSpacing attrs ( 0, 0 )
    --     columnHeader col =
    --         case col of
    --             InternalIndexedColumn colConfig ->
    --                 colConfig.header
    --             InternalColumn colConfig ->
    --                 colConfig.header
    --     columnWidth col =
    --         case col of
    --             InternalIndexedColumn colConfig ->
    --                 colConfig.width
    --             InternalColumn colConfig ->
    --                 colConfig.width
    --     maybeHeaders =
    --         List.map columnHeader config.columns
    --             |> (\headers ->
    --                     if List.all ((==) Internal.Empty) headers then
    --                         Nothing
    --                     else
    --                         Just (List.indexedMap (\col header -> onGrid 1 (col + 1) header) headers)
    --                )
    --     template =
    --         Internal.StyleClass Flag.gridTemplate <|
    --             Internal.GridTemplateStyle
    --                 { spacing = ( px sX, px sY )
    --                 , columns = List.map columnWidth config.columns
    --                 , rows = List.repeat (List.length config.data) Internal.Content
    --                 }
    --     onGrid rowLevel columnLevel elem =
    --         Internal.element
    --             Internal.asEl
    --             Internal.div
    --             [ Internal.StyleClass Flag.gridPosition
    --                 (Internal.GridPosition
    --                     { row = rowLevel
    --                     , col = columnLevel
    --                     , width = 1
    --                     , height = 1
    --                     }
    --                 )
    --             ]
    --             (Internal.Unkeyed [ elem ])
    --     add cell columnConfig cursor =
    --         case columnConfig of
    --             InternalIndexedColumn col ->
    --                 { cursor
    --                     | elements =
    --                         onGrid cursor.row
    --                             cursor.column
    --                             (col.view
    --                                 (if maybeHeaders == Nothing then
    --                                     cursor.row - 1
    --                                  else
    --                                     cursor.row - 2
    --                                 )
    --                                 cell
    --                             )
    --                             :: cursor.elements
    --                     , column = cursor.column + 1
    --                 }
    --             InternalColumn col ->
    --                 { elements =
    --                     onGrid cursor.row cursor.column (col.view cell)
    --                         :: cursor.elements
    --                 , column = cursor.column + 1
    --                 , row = cursor.row
    --                 }
    --     build columns rowData cursor =
    --         let
    --             newCursor =
    --                 List.foldl (add rowData)
    --                     cursor
    --                     columns
    --         in
    --         { elements = newCursor.elements
    --         , row = cursor.row + 1
    --         , column = 1
    --         }
    --     children =
    --         List.foldl (build config.columns)
    --             { elements = []
    --             , row =
    --                 if maybeHeaders == Nothing then
    --                     1
    --                 else
    --                     2
    --             , column = 1
    --             }
    --             config.data
    -- in
    -- Internal.element
    --     Internal.asGrid
    --     Internal.div
    --     (width fill
    --         :: template
    --         :: attrs
    --     )
    --     (Internal.Unkeyed
    --         (case maybeHeaders of
    --             Nothing ->
    --                 children.elements
    --             Just renderedHeaders ->
    --                 renderedHeaders ++ List.reverse children.elements
    --         )
    --     )
    -- Two.text "do this"
    Two.text "do this"


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
        (width Content
            :: height Content
            :: attrs
        )
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
    -- Internal.element
    --     Internal.asTextColumn
    --     Internal.div
    --     (width
    --         (fill
    --             |> minimum 500
    --             |> maximum 750
    --         )
    --         :: attrs
    --     )
    --     (Internal.Unkeyed children)
    Two.element Two.AsTextColumn
        (width Content
            :: height Content
            :: attrs
        )
        children


{-| Both a source and a description are required for images.

The description is used for people using screen readers.

Leaving the description blank will cause the image to be ignored by assistive technology. This can make sense for images that are purely decorative and add no additional information.

So, take a moment to describe your image as you would to someone who has a harder time seeing.

-}
image : List (Attribute msg) -> { src : String, description : String } -> Two.Element msg
image attrs { src, description } =
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
                    [ Attr.src src
                    , Attr.alt description
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
link =
    Two.Link False


{-| -}
linkNewTab : String -> Attribute msg
linkNewTab =
    Two.Link True


{-| A link to download a file.
-}
download : String -> Attribute msg
download url =
    Two.Download url ""


{-| A link to download a file, but you can specify the filename.
-}
downloadAs : { url : String, filename : String } -> Attribute msg
downloadAs { url, filename } =
    Two.Download url filename



{- NEARBYS -}


{-| -}
below : Two.Element msg -> Attribute msg
below element =
    Two.Nearby Two.Below element


{-| -}
above : Two.Element msg -> Attribute msg
above element =
    Two.Nearby Two.Above element


{-| -}
onRight : Two.Element msg -> Attribute msg
onRight element =
    Two.Nearby Two.OnRight element


{-| -}
onLeft : Two.Element msg -> Attribute msg
onLeft element =
    Two.Nearby Two.OnLeft element


{-| This will place an element in front of another.

**Note:** If you use this on a `layout` element, it will place the element as fixed to the viewport which can be useful for modals and overlays.

-}
inFront : Two.Element msg -> Attribute msg
inFront element =
    Two.Nearby Two.InFront element


{-| This will place an element between the background and the content of an Ui.
-}
behindContent : Two.Element msg -> Attribute msg
behindContent element =
    Two.Nearby Two.Behind element


{-| -}
width : Length -> Attribute msg
width len =
    case len of
        Px x ->
            Two.ClassAndStyle Flag.width
                Style.classes.widthExact
                "width"
                (Style.px x)

        Content ->
            Two.Class Flag.width Style.classes.widthContent

        Fill f ->
            Two.WidthFill f


{-| -}
widthMin : Int -> Attribute msg
widthMin x =
    Two.ClassAndStyle Flag.widthBetween
        Style.classes.widthBounded
        "min-width"
        (String.fromInt x ++ "px")


{-| -}
widthMax : Int -> Attribute msg
widthMax x =
    Two.ClassAndStyle Flag.widthBetween
        Style.classes.widthBounded
        "max-width"
        (String.fromInt x ++ "px")


{-| -}
heightMin : Int -> Attribute msg
heightMin x =
    Two.ClassAndStyle Flag.heightBetween
        Style.classes.heightBounded
        "min-height"
        (String.fromInt x ++ "px;")


{-| -}
heightMax : Int -> Attribute msg
heightMax x =
    Two.ClassAndStyle Flag.heightBetween
        Style.classes.heightBounded
        "max-height"
        (String.fromInt x ++ "px")


{-| -}
height : Length -> Attribute msg
height len =
    case len of
        Px x ->
            Two.ClassAndStyle Flag.height
                Style.classes.heightExact
                "height"
                (String.fromInt x ++ "px")

        Content ->
            Two.Class Flag.height Style.classes.heightContent

        Fill f ->
            Two.HeightFill f


{-| -}
scale : Float -> Attribute msg
scale =
    Two.TransformPiece 3


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
rotate =
    Two.TransformPiece 2


{-| -}
moveUp : Float -> Attribute msg
moveUp =
    Two.TransformPiece 1 << negate


{-| -}
moveDown : Float -> Attribute msg
moveDown =
    Two.TransformPiece 1


{-| -}
moveRight : Float -> Attribute msg
moveRight =
    Two.TransformPiece 0


{-| -}
moveLeft : Float -> Attribute msg
moveLeft =
    Two.TransformPiece 0 << negate


{-| -}
padding : Int -> Attribute msg
padding x =
    Two.Padding Flag.padding
        { top = x
        , left = x
        , bottom = x
        , right = x
        }


{-| Set horizontal and vertical padding.
-}
paddingXY : Int -> Int -> Attribute msg
paddingXY x y =
    Two.Padding Flag.padding
        { top = y
        , left = x
        , bottom = y
        , right = x
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
    Two.Padding Flag.padding pad


{-| -}
centerX : Attribute msg
centerX =
    Two.Class Flag.xAlign Style.classes.alignCenterX


{-| -}
centerY : Attribute msg
centerY =
    Two.Class Flag.yAlign Style.classes.alignCenterY


{-| -}
alignTop : Attribute msg
alignTop =
    Two.Class Flag.yAlign Style.classes.alignTop


{-| -}
alignBottom : Attribute msg
alignBottom =
    Two.Class Flag.yAlign Style.classes.alignBottom


{-| -}
alignLeft : Attribute msg
alignLeft =
    Two.Class Flag.xAlign Style.classes.alignLeft


{-| -}
alignRight : Attribute msg
alignRight =
    Two.Class Flag.xAlign Style.classes.alignRight


{-| -}
spaceEvenly : Attribute msg
spaceEvenly =
    Two.Class Flag.spacing Style.classes.spaceEvenly


{-| -}
spacing : Int -> Attribute msg
spacing x =
    Two.Spacing Flag.spacing x x


{-| In the majority of cases you'll just need to use `spacing`, which will work as intended.

However for some layouts, like `textColumn`, you may want to set a different spacing for the x axis compared to the y axis.

-}
spacingXY : Int -> Int -> Attribute msg
spacingXY x y =
    Two.Spacing Flag.spacing x y


{-| Make an element transparent and have it ignore any mouse or touch events, though it will stil take up space.
-}
transparent : Bool -> Attribute msg
transparent on =
    if on then
        Two.Attr (Attr.style "opacity" "1")

    else
        Two.Attr (Attr.style "opacity" "0")


{-| A capped value between 0.0 and 1.0, where 0.0 is transparent and 1.0 is fully opaque.

Semantically equivalent to html opacity.

-}
alpha : Float -> Attribute msg
alpha o =
    Two.Attr (Attr.style "opacity" (String.fromFloat (1 + (-1 * o))))


{-| -}
viewport : List (Attribute msg) -> Two.Element msg -> Two.Element msg
viewport attrs child =
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
    Two.Class Flag.overflow Style.classes.scrollbars


{-| -}
scrollbarY : Attribute msg
scrollbarY =
    Two.Class Flag.overflow Style.classes.scrollbarsY


{-| -}
scrollbarX : Attribute msg
scrollbarX =
    Two.Class Flag.overflow Style.classes.scrollbarsX


{-| Clip the content if it overflows.

Similar to `viewport`, this element will fill the space it's given.

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
    Two.Class Flag.overflow Style.classes.clip


{-| -}
clipY : Attribute msg
clipY =
    Two.Class Flag.overflow Style.classes.clipY


{-| -}
clipX : Attribute msg
clipX =
    Two.Class Flag.overflow Style.classes.clipX


{-| Set the cursor to be a pointing hand when it's hovering over this Ui.
-}
pointer : Attribute msg
pointer =
    Two.Class Flag.cursor Style.classes.cursorPointer


{-| -}
grab : Attribute msg
grab =
    Two.Class Flag.cursor Style.classes.cursorGrab


{-| -}
grabbing : Attribute msg
grabbing =
    Two.Class Flag.cursor Style.classes.cursorGrabbing


{-| -}
type alias Device =
    { class : DeviceClass
    , orientation : Orientation
    }


{-| -}
type DeviceClass
    = Phone
    | Tablet
    | Desktop
    | BigDesktop


{-| -}
type Orientation
    = Portrait
    | Landscape


{-| Takes in a Window.Size and returns a device profile which can be used for responsiveness.

If you have more detailed concerns around responsiveness, it probably makes sense to copy this function into your codebase and modify as needed.

-}
classifyDevice : { window | height : Int, width : Int } -> Device
classifyDevice window =
    -- Tested in this ellie:
    -- https://ellie-app.com/68QM7wLW8b9a1
    { class =
        let
            longSide =
                max window.width window.height

            shortSide =
                min window.width window.height
        in
        if shortSide < 600 then
            Phone

        else if longSide <= 1200 then
            Tablet

        else if longSide > 1200 && longSide <= 1920 then
            Desktop

        else
            BigDesktop
    , orientation =
        if window.width < window.height then
            Portrait

        else
            Landscape
    }
