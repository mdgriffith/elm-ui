module Element exposing
    ( Element, none, text, el
    , row, wrappedRow, column
    , paragraph, textColumn
    , Column, table, IndexedColumn, indexedTable
    , Attribute, width, height, Length, px, shrink, fill, fillPortion, maximum, minimum
    , explain
    , padding, paddingXY, paddingEach
    , spacing, spacingXY, spaceEvenly
    , centerX, centerY, alignLeft, alignRight, alignTop, alignBottom
    , transparent, alpha, pointer
    , moveUp, moveDown, moveRight, moveLeft, rotate, scale
    , clip, clipX, clipY
    , scrollbars, scrollbarX, scrollbarY
    , layout, layoutWith, Option, noStaticStyleSheet, forceHover, noHover, focusStyle, FocusStyle
    , link, newTabLink, download, downloadAs
    , image
    , Color, rgba, rgb, rgb255, rgba255, fromRgb, fromRgb255, toRgb
    , above, below, onRight, onLeft, inFront, behindContent
    , Attr, Decoration, mouseOver, mouseDown, focused
    , Device, DeviceClass(..), Orientation(..), classifyDevice
    , modular
    , map, mapAttribute
    , html, htmlAttribute
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

@docs Attribute, width, height, Length, px, shrink, fill, fillPortion, maximum, minimum


# Debugging

@docs explain


# Padding and Spacing

There's no concept of margin in `elm-ui`, instead we have padding and spacing.

Padding is the distance between the outer edge and the content, and spacing is the space between children.

So, if we have the following row, with some padding and spacing.

    Element.row [ padding 10, spacing 7 ]
        [ Element.el [] none
        , Element.el [] none
        , Element.el [] none
        ]

Here's what we can expect:

![Three boxes spaced 7 pixels apart. There's a 10 pixel distance from the edge of the parent to the boxes.](https://mdgriffith.gitbooks.io/style-elements/content/assets/spacing-400.png)

**Note** `spacing` set on a `paragraph`, will set the pixel spacing between lines.

@docs padding, paddingXY, paddingEach

@docs spacing, spacingXY, spaceEvenly


# Alignment

Alignment can be used to align an `Element` within another `Element`.

    Element.el [ centerX, alignTop ] (text "I'm centered and aligned top!")

If alignment is set on elements in a layout such as `row`, then the element will push the other elements in that direction. Here's an example.

    Element.row []
        [ Element.el [] Element.none
        , Element.el [ alignLeft ] Element.none
        , Element.el [ centerX ] Element.none
        , Element.el [ alignRight ] Element.none
        ]

will result in a layout like

    |-|-|    |-|    |-|

Where there are two elements on the left, one on the right, and one in the center of the space between the elements on the left and right.

**Note** For text alignment, check out `Element.Font`!

@docs centerX, centerY, alignLeft, alignRight, alignTop, alignBottom


# Transparency

@docs transparent, alpha, pointer


# Adjustment

@docs moveUp, moveDown, moveRight, moveLeft, rotate, scale


# Clipping and Scrollbars

Clip the content if it overflows.

@docs clip, clipX, clipY

Add a scrollbar if the content is larger than the element.

@docs scrollbars, scrollbarX, scrollbarY


# Rendering

@docs layout, layoutWith, Option, noStaticStyleSheet, forceHover, noHover, focusStyle, FocusStyle


# Links

@docs link, newTabLink, download, downloadAs


# Images

@docs image


# Color

In order to use attributes like `Font.color` and `Background.color`, you'll need to make some colors!

@docs Color, rgba, rgb, rgb255, rgba255, fromRgb, fromRgb255, toRgb


# Nearby Elements

Let's say we want a dropdown menu. Essentially we want to say: _put this element below this other element, but don't affect the layout when you do_.

    Element.row []
        [ Element.el
            [ Element.below (Element.text "I'm below!")
            ]
            (Element.text "I'm normal!")
        ]

This will result in

    |- I'm normal! -|
       I'm below

Where `"I'm Below"` doesn't change the size of `Element.row`.

This is very useful for things like dropdown menus or tooltips.

@docs above, below, onRight, onLeft, inFront, behindContent


# Temporary Styling

@docs Attr, Decoration, mouseOver, mouseDown, focused


# Responsiveness

The main technique for responsiveness is to store window size information in your model.

Install the `Browser` package, and set up a subscription for [`Browser.Events.onResize`](https://package.elm-lang.org/packages/elm/browser/latest/Browser-Events#onResize).

You'll also need to retrieve the initial window size. You can either use [`Browser.Dom.getViewport`](https://package.elm-lang.org/packages/elm/browser/latest/Browser-Dom#getViewport) or pass in `window.innerWidth` and `window.innerHeight` as flags to your program, which is the preferred way. This requires minor setup on the JS side, but allows you to avoid the state where you don't have window info.

@docs Device, DeviceClass, Orientation, classifyDevice


# Scaling

@docs modular


## Mapping

@docs map, mapAttribute


## Compatibility

@docs html, htmlAttribute

-}

import Html exposing (Html)
import Html.Attributes
import Internal.Flag as Flag exposing (Flag)
import Internal.Model as Internal
import Internal.Style exposing (classes)


{-| -}
type alias Color =
    Internal.Color


{-| Provide the red, green, and blue channels for the color.

Each channel takes a value between 0 and 1.

-}
rgb : Float -> Float -> Float -> Color
rgb r g b =
    Internal.Rgba r g b 1


{-| -}
rgba : Float -> Float -> Float -> Float -> Color
rgba =
    Internal.Rgba


{-| Provide the red, green, and blue channels for the color.

Each channel takes a value between 0 and 255.

-}
rgb255 : Int -> Int -> Int -> Color
rgb255 red green blue =
    Internal.Rgba
        (toFloat red / 255)
        (toFloat green / 255)
        (toFloat blue / 255)
        1


{-| -}
rgba255 : Int -> Int -> Int -> Float -> Color
rgba255 red green blue a =
    Internal.Rgba
        (toFloat red / 255)
        (toFloat green / 255)
        (toFloat blue / 255)
        a


{-| Create a color from an RGB record.
-}
fromRgb :
    { red : Float
    , green : Float
    , blue : Float
    , alpha : Float
    }
    -> Color
fromRgb clr =
    Internal.Rgba
        clr.red
        clr.green
        clr.blue
        clr.alpha


{-| -}
fromRgb255 :
    { red : Int
    , green : Int
    , blue : Int
    , alpha : Float
    }
    -> Color
fromRgb255 clr =
    Internal.Rgba
        (toFloat clr.red / 255)
        (toFloat clr.green / 255)
        (toFloat clr.blue / 255)
        clr.alpha


{-| Deconstruct a `Color` into its rgb channels.
-}
toRgb :
    Color
    ->
        { red : Float
        , green : Float
        , blue : Float
        , alpha : Float
        }
toRgb (Internal.Rgba r g b a) =
    { red = r
    , green = g
    , blue = b
    , alpha = a
    }


{-| The basic building block of your layout.

    howdy : Element msg
    howdy =
        Element.el [] (Element.text "Howdy!")

-}
type alias Element msg =
    Internal.Element msg


{-| An attribute that can be attached to an `Element`
-}
type alias Attribute msg =
    Internal.Attribute () msg


{-| This is a special attribute that counts as both a `Attribute msg` and a `Decoration`.
-}
type alias Attr decorative msg =
    Internal.Attribute decorative msg


{-| Only decorations
-}
type alias Decoration =
    Internal.Attribute Never Never


{-| -}
html : Html msg -> Element msg
html =
    Internal.unstyled


{-| -}
htmlAttribute : Html.Attribute msg -> Attribute msg
htmlAttribute =
    Internal.Attr


{-| -}
map : (msg -> msg1) -> Element msg -> Element msg1
map =
    Internal.map


{-| -}
mapAttribute : (msg -> msg1) -> Attribute msg -> Attribute msg1
mapAttribute =
    Internal.mapAttr


{-| -}
type alias Length =
    Internal.Length


{-| -}
px : Int -> Length
px =
    Internal.Px


{-| Shrink an element to fit its contents.
-}
shrink : Length
shrink =
    Internal.Content


{-| Fill the available space. The available space will be split evenly between elements that have `width fill`.
-}
fill : Length
fill =
    Internal.Fill 1


{-| Similarly you can set a minimum boundary.

     el
        [ height
            (fill
                |> maximum 300
                |> minimum 30
            )

        ]
        (text "I will stop at 300px")

-}
minimum : Int -> Length -> Length
minimum i l =
    Internal.Min i l


{-| Add a maximum to a length.

    el
        [ height
            (fill
                |> maximum 300
            )
        ]
        (text "I will stop at 300px")

-}
maximum : Int -> Length -> Length
maximum i l =
    Internal.Max i l


{-| Sometimes you may not want to split available space evenly. In this case you can use `fillPortion` to define which elements should have what portion of the available space.

So, two elements, one with `width (fillPortion 2)` and one with `width (fillPortion 3)`. The first would get 2 portions of the available space, while the second would get 3.

**Also:** `fill == fillPortion 1`

-}
fillPortion : Int -> Length
fillPortion =
    Internal.Fill


{-| This is your top level node where you can turn `Element` into `Html`.
-}
layout : List (Attribute msg) -> Element msg -> Html msg
layout =
    layoutWith { options = [] }


{-| -}
layoutWith : { options : List Option } -> List (Attribute msg) -> Element msg -> Html msg
layoutWith { options } attrs child =
    Internal.renderRoot options
        (Internal.htmlClass
            (String.join " "
                [ classes.root
                , classes.any
                , classes.single
                ]
            )
            :: (Internal.rootStyle ++ attrs)
        )
        child


{-| -}
type alias Option =
    Internal.Option


{-| Elm UI embeds two StyleSheets, one that is constant, and one that changes dynamically based on styles collected from the elements being rendered.

This option will stop the static/constant stylesheet from rendering.

If you're embedding multiple elm-ui `layout` elements, you need to guarantee that only one is rendering the static style sheet and that it's above all the others in the DOM tree.

-}
noStaticStyleSheet : Option
noStaticStyleSheet =
    Internal.RenderModeOption Internal.NoStaticStyleSheet


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
    Internal.focusDefaultStyle


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
focusStyle : FocusStyle -> Option
focusStyle =
    Internal.FocusStyleOption


{-| Disable all `mouseOver` styles.
-}
noHover : Option
noHover =
    Internal.HoverOption Internal.NoHover


{-| Any `hover` styles, aka attributes with `mouseOver` in the name, will be always turned on.

This is useful for when you're targeting a platform that has no mouse, such as mobile.

-}
forceHover : Option
forceHover =
    Internal.HoverOption Internal.ForceHover


{-| When you want to render exactly nothing.
-}
none : Element msg
none =
    Internal.Empty


{-| Create some plain text.

    text "Hello, you stylish developer!"

**Note** text does not wrap by default. In order to get text to wrap, check out `paragraph`!

-}
text : String -> Element msg
text content =
    Internal.Text content


{-| The basic building block of your layout.

You can think of an `el` as a `div`, but it can only have one child.

If you want multiple children, you'll need to use something like `row` or `column`

    import Element exposing (Element, rgb)
    import Element.Background as Background
    import Element.Border as Border

    myElement : Element msg
    myElement =
        Element.el
            [ Background.color (rgb 0 0.5 0)
            , Border.color (rgb 0 0.7 0)
            ]
            (Element.text "You've made a stylish element!")

-}
el : List (Attribute msg) -> Element msg -> Element msg
el attrs child =
    Internal.element
        Internal.asEl
        Internal.div
        (width shrink
            :: height shrink
            :: attrs
        )
        (Internal.Unkeyed [ child ])


{-| -}
row : List (Attribute msg) -> List (Element msg) -> Element msg
row attrs children =
    Internal.element
        Internal.asRow
        Internal.div
        (Internal.htmlClass (classes.contentLeft ++ " " ++ classes.contentCenterY)
            :: width shrink
            :: height shrink
            :: attrs
        )
        (Internal.Unkeyed children)


{-| -}
column : List (Attribute msg) -> List (Element msg) -> Element msg
column attrs children =
    Internal.element
        Internal.asColumn
        Internal.div
        (Internal.htmlClass
            (classes.contentTop
                ++ " "
                ++ classes.contentLeft
            )
            :: height shrink
            :: width shrink
            :: attrs
        )
        (Internal.Unkeyed children)


{-| Same as `row`, but will wrap if it takes up too much horizontal space.
-}
wrappedRow : List (Attribute msg) -> List (Element msg) -> Element msg
wrappedRow attrs children =
    let
        ( padded, spaced ) =
            Internal.extractSpacingAndPadding attrs
    in
    case spaced of
        Nothing ->
            Internal.element
                Internal.asRow
                Internal.div
                (Internal.htmlClass
                    (classes.contentLeft
                        ++ " "
                        ++ classes.contentCenterY
                        ++ " "
                        ++ classes.wrapped
                    )
                    :: width shrink
                    :: height shrink
                    :: attrs
                )
                (Internal.Unkeyed children)

        Just (Internal.Spaced spaceName x y) ->
            let
                newPadding =
                    case padded of
                        Just (Internal.Padding name t r b l) ->
                            if r >= (toFloat x / 2) && b >= (toFloat y / 2) then
                                let
                                    newTop =
                                        t - (toFloat y / 2)

                                    newRight =
                                        r - (toFloat x / 2)

                                    newBottom =
                                        b - (toFloat y / 2)

                                    newLeft =
                                        l - (toFloat x / 2)
                                in
                                Just <|
                                    Internal.StyleClass Flag.padding
                                        (Internal.PaddingStyle
                                            (Internal.paddingNameFloat
                                                newTop
                                                newRight
                                                newBottom
                                                newLeft
                                            )
                                            newTop
                                            newRight
                                            newBottom
                                            newLeft
                                        )

                            else
                                Nothing

                        Nothing ->
                            Nothing
            in
            case newPadding of
                Just pad ->
                    Internal.element
                        Internal.asRow
                        Internal.div
                        (Internal.htmlClass
                            (classes.contentLeft
                                ++ " "
                                ++ classes.contentCenterY
                                ++ " "
                                ++ classes.wrapped
                            )
                            :: width shrink
                            :: height shrink
                            :: attrs
                            ++ [ pad ]
                        )
                        (Internal.Unkeyed children)

                Nothing ->
                    -- Not enough space in padding to compensate for spacing
                    let
                        halfX =
                            negate (toFloat x / 2)

                        halfY =
                            negate (toFloat y / 2)
                    in
                    Internal.element
                        Internal.asEl
                        Internal.div
                        attrs
                        (Internal.Unkeyed
                            [ Internal.element
                                Internal.asRow
                                Internal.div
                                (Internal.htmlClass
                                    (classes.contentLeft
                                        ++ " "
                                        ++ classes.contentCenterY
                                        ++ " "
                                        ++ classes.wrapped
                                    )
                                    :: Internal.Attr
                                        (Html.Attributes.style "margin"
                                            (String.fromFloat halfY
                                                ++ "px"
                                                ++ " "
                                                ++ String.fromFloat halfX
                                                ++ "px"
                                            )
                                        )
                                    :: Internal.Attr
                                        (Html.Attributes.style "width"
                                            ("calc(100% + "
                                                ++ String.fromInt x
                                                ++ "px)"
                                            )
                                        )
                                    :: Internal.Attr
                                        (Html.Attributes.style "height"
                                            ("calc(100% + "
                                                ++ String.fromInt y
                                                ++ "px)"
                                            )
                                        )
                                    :: Internal.StyleClass Flag.spacing (Internal.SpacingStyle spaceName x y)
                                    :: []
                                )
                                (Internal.Unkeyed children)
                            ]
                        )


{-| This is just an alias for `Debug.todo`
-}
type alias Todo =
    String -> Never


{-| Highlight the borders of an element and it's children below. This can really help if you're running into some issue with your layout!

**Note** This attribute needs to be handed `Debug.todo` in order to work, even though it won't do anything with it. This is a safety measure so you don't accidently ship code with `explain` in it, as Elm won't compile with `--optimize` if you still have a `Debug` statement in your code.

    el
        [ Element.explain Debug.todo
        ]
        (text "Help, I'm being debugged!")

-}
explain : Todo -> Attribute msg
explain _ =
    Internal.htmlClass "explain"


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

    Element.table []
        { data = persons
        , columns =
            [ { header = Element.text "First Name"
              , width = fill
              , view =
                    \person ->
                        Element.text person.firstName
              }
            , { header = Element.text "Last Name"
              , width = fill
              , view =
                    \person ->
                        Element.text person.lastName
              }
            ]
        }

**Note:** Sometimes you might not have a list of records directly in your model. In this case it can be really nice to write a function that transforms some part of your model into a list of records before feeding it into `Element.table`.

-}
table :
    List (Attribute msg)
    ->
        { data : List records
        , columns : List (Column records msg)
        }
    -> Element msg
table attrs config =
    tableHelper attrs
        { data = config.data
        , columns =
            List.map InternalColumn config.columns
        }


{-| -}
type alias IndexedColumn record msg =
    { header : Element msg
    , width : Length
    , view : Int -> record -> Element msg
    }


{-| Same as `Element.table` except the `view` for each column will also receive the row index as well as the record.
-}
indexedTable :
    List (Attribute msg)
    ->
        { data : List records
        , columns : List (IndexedColumn records msg)
        }
    -> Element msg
indexedTable attrs config =
    tableHelper attrs
        { data = config.data
        , columns =
            List.map InternalIndexedColumn config.columns
        }


{-| -}
type alias InternalTable records msg =
    { data : List records
    , columns : List (InternalTableColumn records msg)
    }


{-| -}
type InternalTableColumn record msg
    = InternalIndexedColumn (IndexedColumn record msg)
    | InternalColumn (Column record msg)


tableHelper : List (Attribute msg) -> InternalTable data msg -> Element msg
tableHelper attrs config =
    let
        ( sX, sY ) =
            Internal.getSpacing attrs ( 0, 0 )

        columnHeader col =
            case col of
                InternalIndexedColumn colConfig ->
                    colConfig.header

                InternalColumn colConfig ->
                    colConfig.header

        columnWidth col =
            case col of
                InternalIndexedColumn colConfig ->
                    colConfig.width

                InternalColumn colConfig ->
                    colConfig.width

        maybeHeaders =
            List.map columnHeader config.columns
                |> (\headers ->
                        if List.all ((==) Internal.Empty) headers then
                            Nothing

                        else
                            Just (List.indexedMap (\col header -> onGrid 1 (col + 1) header) headers)
                   )

        template =
            Internal.StyleClass Flag.gridTemplate <|
                Internal.GridTemplateStyle
                    { spacing = ( px sX, px sY )
                    , columns = List.map columnWidth config.columns
                    , rows = List.repeat (List.length config.data) Internal.Content
                    }

        onGrid rowLevel columnLevel elem =
            Internal.element
                Internal.asEl
                Internal.div
                [ Internal.StyleClass Flag.gridPosition
                    (Internal.GridPosition
                        { row = rowLevel
                        , col = columnLevel
                        , width = 1
                        , height = 1
                        }
                    )
                ]
                (Internal.Unkeyed [ elem ])

        add cell columnConfig cursor =
            case columnConfig of
                InternalIndexedColumn col ->
                    { cursor
                        | elements =
                            onGrid cursor.row
                                cursor.column
                                (col.view
                                    (if maybeHeaders == Nothing then
                                        cursor.row - 1

                                     else
                                        cursor.row - 2
                                    )
                                    cell
                                )
                                :: cursor.elements
                        , column = cursor.column + 1
                    }

                InternalColumn col ->
                    { elements =
                        onGrid cursor.row cursor.column (col.view cell)
                            :: cursor.elements
                    , column = cursor.column + 1
                    , row = cursor.row
                    }

        build columns rowData cursor =
            let
                newCursor =
                    List.foldl (add rowData)
                        cursor
                        columns
            in
            { elements = newCursor.elements
            , row = cursor.row + 1
            , column = 1
            }

        children =
            List.foldl (build config.columns)
                { elements = []
                , row =
                    if maybeHeaders == Nothing then
                        1

                    else
                        2
                , column = 1
                }
                config.data
    in
    Internal.element
        Internal.asGrid
        Internal.div
        (width fill
            :: template
            :: attrs
        )
        (Internal.Unkeyed
            (case maybeHeaders of
                Nothing ->
                    children.elements

                Just renderedHeaders ->
                    renderedHeaders ++ List.reverse children.elements
            )
        )


{-| A paragraph will layout all children as wrapped, inline elements.

    import Element exposing (el, paragraph, text)
    import Element.Font as Font

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
    import Element.Font as Font

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
paragraph : List (Attribute msg) -> List (Element msg) -> Element msg
paragraph attrs children =
    Internal.element
        Internal.asParagraph
        Internal.div
        (Internal.Describe Internal.Paragraph
            :: width fill
            :: spacing 5
            :: attrs
        )
        (Internal.Unkeyed children)


{-| Now that we have a paragraph, we need some way to attach a bunch of paragraph's together.

To do that we can use a `textColumn`.

The main difference between a `column` and a `textColumn` is that `textColumn` will flow the text around elements that have `alignRight` or `alignLeft`, just like we just saw with paragraph.

In the following example, we have a `textColumn` where one child has `alignLeft`.

    Element.textColumn [ spacing 10, padding 10 ]
        [ paragraph [] [ text "lots of text ...." ]
        , el [ alignLeft ] none
        , paragraph [] [ text "lots of text ...." ]
        ]

Which will result in something like:

![A text layout where an image is on the left.](https://mdgriffith.gitbooks.io/style-elements/content/assets/Screen%20Shot%202017-08-25%20at%208.42.39%20PM.png)

-}
textColumn : List (Attribute msg) -> List (Element msg) -> Element msg
textColumn attrs children =
    Internal.element
        Internal.asTextColumn
        Internal.div
        (width
            (fill
                |> minimum 500
                |> maximum 750
            )
            :: attrs
        )
        (Internal.Unkeyed children)


{-| Both a source and a description are required for images.

The description is used for people using screen readers.

Leaving the description blank will cause the image to be ignored by assistive technology. This can make sense for images that are purely decorative and add no additional information.

So, take a moment to describe your image as you would to someone who has a harder time seeing.

-}
image : List (Attribute msg) -> { src : String, description : String } -> Element msg
image attrs { src, description } =
    let
        imageAttributes =
            attrs
                |> List.filter
                    (\a ->
                        case a of
                            Internal.Width _ ->
                                True

                            Internal.Height _ ->
                                True

                            _ ->
                                False
                    )
    in
    Internal.element
        Internal.asEl
        Internal.div
        (Internal.htmlClass classes.imageContainer
            :: attrs
        )
        (Internal.Unkeyed
            [ Internal.element
                Internal.asEl
                (Internal.NodeName "img")
                ([ Internal.Attr <| Html.Attributes.src src
                 , Internal.Attr <| Html.Attributes.alt description
                 ]
                    ++ imageAttributes
                )
                (Internal.Unkeyed [])
            ]
        )


{-|

    link []
        { url = "http://fruits.com"
        , label = text "A link to my favorite fruit provider."
        }

-}
link :
    List (Attribute msg)
    ->
        { url : String
        , label : Element msg
        }
    -> Element msg
link attrs { url, label } =
    Internal.element
        Internal.asEl
        (Internal.NodeName "a")
        (Internal.Attr (Html.Attributes.href url)
            :: Internal.Attr (Html.Attributes.rel "noopener noreferrer")
            :: width shrink
            :: height shrink
            :: Internal.htmlClass
                (classes.contentCenterX
                    ++ " "
                    ++ classes.contentCenterY
                    ++ " "
                    ++ classes.link
                )
            :: attrs
        )
        (Internal.Unkeyed [ label ])


{-| -}
newTabLink :
    List (Attribute msg)
    ->
        { url : String
        , label : Element msg
        }
    -> Element msg
newTabLink attrs { url, label } =
    Internal.element
        Internal.asEl
        (Internal.NodeName "a")
        (Internal.Attr (Html.Attributes.href url)
            :: Internal.Attr (Html.Attributes.rel "noopener noreferrer")
            :: Internal.Attr (Html.Attributes.target "_blank")
            :: width shrink
            :: height shrink
            :: Internal.htmlClass
                (classes.contentCenterX
                    ++ " "
                    ++ classes.contentCenterY
                    ++ " "
                    ++ classes.link
                )
            :: attrs
        )
        (Internal.Unkeyed [ label ])


{-| A link to download a file.
-}
download :
    List (Attribute msg)
    ->
        { url : String
        , label : Element msg
        }
    -> Element msg
download attrs { url, label } =
    Internal.element
        Internal.asEl
        (Internal.NodeName "a")
        (Internal.Attr (Html.Attributes.href url)
            :: Internal.Attr (Html.Attributes.download "")
            :: width shrink
            :: height shrink
            :: Internal.htmlClass classes.contentCenterX
            :: Internal.htmlClass classes.contentCenterY
            :: attrs
        )
        (Internal.Unkeyed [ label ])


{-| A link to download a file, but you can specify the filename.
-}
downloadAs :
    List (Attribute msg)
    ->
        { label : Element msg
        , filename : String
        , url : String
        }
    -> Element msg
downloadAs attrs { url, filename, label } =
    Internal.element
        Internal.asEl
        (Internal.NodeName "a")
        (Internal.Attr (Html.Attributes.href url)
            :: Internal.Attr (Html.Attributes.download filename)
            :: width shrink
            :: height shrink
            :: Internal.htmlClass classes.contentCenterX
            :: Internal.htmlClass classes.contentCenterY
            :: attrs
        )
        (Internal.Unkeyed [ label ])



{- NEARBYS -}


createNearby : Internal.Location -> Element msg -> Attribute msg
createNearby loc element =
    case element of
        Internal.Empty ->
            Internal.NoAttribute

        _ ->
            Internal.Nearby loc element


{-| -}
below : Element msg -> Attribute msg
below element =
    createNearby Internal.Below element


{-| -}
above : Element msg -> Attribute msg
above element =
    createNearby Internal.Above element


{-| -}
onRight : Element msg -> Attribute msg
onRight element =
    createNearby Internal.OnRight element


{-| -}
onLeft : Element msg -> Attribute msg
onLeft element =
    createNearby Internal.OnLeft element


{-| This will place an element in front of another.

**Note:** If you use this on a `layout` element, it will place the element as fixed to the viewport which can be useful for modals and overlays.

-}
inFront : Element msg -> Attribute msg
inFront element =
    createNearby Internal.InFront element


{-| This will place an element between the background and the content of an element.
-}
behindContent : Element msg -> Attribute msg
behindContent element =
    createNearby Internal.Behind element


{-| -}
width : Length -> Attribute msg
width =
    Internal.Width


{-| -}
height : Length -> Attribute msg
height =
    Internal.Height


{-| -}
scale : Float -> Attr decorative msg
scale n =
    Internal.TransformComponent Flag.scale (Internal.Scale ( n, n, 1 ))


{-| Angle is given in radians. [Here are some conversion functions if you want to use another unit.](https://package.elm-lang.org/packages/elm/core/latest/Basics#degrees)
-}
rotate : Float -> Attr decorative msg
rotate angle =
    Internal.TransformComponent Flag.rotate (Internal.Rotate ( 0, 0, 1 ) angle)


{-| -}
moveUp : Float -> Attr decorative msg
moveUp y =
    Internal.TransformComponent Flag.moveY (Internal.MoveY (negate y))


{-| -}
moveDown : Float -> Attr decorative msg
moveDown y =
    Internal.TransformComponent Flag.moveY (Internal.MoveY y)


{-| -}
moveRight : Float -> Attr decorative msg
moveRight x =
    Internal.TransformComponent Flag.moveX (Internal.MoveX x)


{-| -}
moveLeft : Float -> Attr decorative msg
moveLeft x =
    Internal.TransformComponent Flag.moveX (Internal.MoveX (negate x))


{-| -}
padding : Int -> Attribute msg
padding x =
    let
        f =
            toFloat x
    in
    Internal.StyleClass Flag.padding (Internal.PaddingStyle ("p-" ++ String.fromInt x) f f f f)


{-| Set horizontal and vertical padding.
-}
paddingXY : Int -> Int -> Attribute msg
paddingXY x y =
    if x == y then
        let
            f =
                toFloat x
        in
        Internal.StyleClass Flag.padding (Internal.PaddingStyle ("p-" ++ String.fromInt x) f f f f)

    else
        let
            xFloat =
                toFloat x

            yFloat =
                toFloat y
        in
        Internal.StyleClass Flag.padding
            (Internal.PaddingStyle
                ("p-" ++ String.fromInt x ++ "-" ++ String.fromInt y)
                yFloat
                xFloat
                yFloat
                xFloat
            )


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
paddingEach { top, right, bottom, left } =
    if top == right && top == bottom && top == left then
        let
            topFloat =
                toFloat top
        in
        Internal.StyleClass Flag.padding
            (Internal.PaddingStyle ("p-" ++ String.fromInt top)
                topFloat
                topFloat
                topFloat
                topFloat
            )

    else
        Internal.StyleClass Flag.padding
            (Internal.PaddingStyle
                (Internal.paddingName top right bottom left)
                (toFloat top)
                (toFloat right)
                (toFloat bottom)
                (toFloat left)
            )


{-| -}
centerX : Attribute msg
centerX =
    Internal.AlignX Internal.CenterX


{-| -}
centerY : Attribute msg
centerY =
    Internal.AlignY Internal.CenterY


{-| -}
alignTop : Attribute msg
alignTop =
    Internal.AlignY Internal.Top


{-| -}
alignBottom : Attribute msg
alignBottom =
    Internal.AlignY Internal.Bottom


{-| -}
alignLeft : Attribute msg
alignLeft =
    Internal.AlignX Internal.Left


{-| -}
alignRight : Attribute msg
alignRight =
    Internal.AlignX Internal.Right


{-| -}
spaceEvenly : Attribute msg
spaceEvenly =
    Internal.Class Flag.spacing Internal.Style.classes.spaceEvenly


{-| -}
spacing : Int -> Attribute msg
spacing x =
    Internal.StyleClass Flag.spacing (Internal.SpacingStyle (Internal.spacingName x x) x x)


{-| In the majority of cases you'll just need to use `spacing`, which will work as intended.

However for some layouts, like `textColumn`, you may want to set a different spacing for the x axis compared to the y axis.

-}
spacingXY : Int -> Int -> Attribute msg
spacingXY x y =
    Internal.StyleClass Flag.spacing (Internal.SpacingStyle (Internal.spacingName x y) x y)


{-| Make an element transparent and have it ignore any mouse or touch events, though it will stil take up space.
-}
transparent : Bool -> Attr decorative msg
transparent on =
    if on then
        Internal.StyleClass Flag.transparency (Internal.Transparency "transparent" 1.0)

    else
        Internal.StyleClass Flag.transparency (Internal.Transparency "visible" 0.0)


{-| A capped value between 0.0 and 1.0, where 0.0 is transparent and 1.0 is fully opaque.

Semantically equivalent to html opacity.

-}
alpha : Float -> Attr decorative msg
alpha o =
    let
        transparency =
            o
                |> max 0.0
                |> min 1.0
                |> (\x -> 1 - x)
    in
    Internal.StyleClass Flag.transparency <| Internal.Transparency ("transparency-" ++ Internal.floatClass transparency) transparency



-- {-| -}
-- hidden : Bool -> Attribute msg
-- hidden on =
--     if on then
--         Internal.class "hidden"
--     else
--         Internal.NoAttribute


{-| -}
scrollbars : Attribute msg
scrollbars =
    Internal.Class Flag.overflow classes.scrollbars


{-| -}
scrollbarY : Attribute msg
scrollbarY =
    Internal.Class Flag.overflow classes.scrollbarsY


{-| -}
scrollbarX : Attribute msg
scrollbarX =
    Internal.Class Flag.overflow classes.scrollbarsX


{-| -}
clip : Attribute msg
clip =
    Internal.Class Flag.overflow classes.clip


{-| -}
clipY : Attribute msg
clipY =
    Internal.Class Flag.overflow classes.clipY


{-| -}
clipX : Attribute msg
clipX =
    Internal.Class Flag.overflow classes.clipX


{-| Set the cursor to be a pointing hand when it's hovering over this element.
-}
pointer : Attribute msg
pointer =
    Internal.Class Flag.cursor classes.cursorPointer


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


{-| When designing it's nice to use a modular scale to set spacial rythms.

    scaled =
        Element.modular 16 1.25

A modular scale starts with a number, and multiplies it by a ratio a number of times.
Then, when setting font sizes you can use:

    Font.size (scaled 1) -- results in 16

    Font.size (scaled 2) -- 16 * 1.25 results in 20

    Font.size (scaled 4) -- 16 * 1.25 ^ (4 - 1) results in 31.25

We can also provide negative numbers to scale below 16px.

    Font.size (scaled -1) -- 16 * 1.25 ^ (-1) results in 12.8

-}
modular : Float -> Float -> Int -> Float
modular normal ratio rescale =
    if rescale == 0 then
        normal

    else if rescale < 0 then
        normal * ratio ^ toFloat rescale

    else
        normal * ratio ^ (toFloat rescale - 1)


{-| -}
mouseOver : List Decoration -> Attribute msg
mouseOver decs =
    Internal.StyleClass Flag.hover <|
        Internal.PseudoSelector Internal.Hover
            (Internal.unwrapDecorations decs)


{-| -}
mouseDown : List Decoration -> Attribute msg
mouseDown decs =
    Internal.StyleClass Flag.active <|
        Internal.PseudoSelector Internal.Active
            (Internal.unwrapDecorations decs)


{-| -}
focused : List Decoration -> Attribute msg
focused decs =
    Internal.StyleClass Flag.focus <|
        Internal.PseudoSelector Internal.Focus
            (Internal.unwrapDecorations decs)
