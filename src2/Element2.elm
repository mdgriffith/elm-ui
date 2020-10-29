module Element2 exposing
    ( Element, none, text, el
    , row, wrappedRow, column
    , paragraph, textColumn
    , Column, table, IndexedColumn, indexedTable
    , Attribute, width, height, Length, px, shrink, fill, portion, maximum, minimum, ellip
    , explain
    , padding, paddingXY, paddingEach
    , spacing, spacingXY, spaceEvenly
    , centerX, centerY, alignLeft, alignRight, alignTop, alignBottom
    , transparent, alpha
    , pointer, grab, grabbing
    , moveUp, moveDown, moveRight, moveLeft, rotate, scale
    , viewport, clipped
    , layout, layoutWith, Option, noStaticStyleSheet, focusStyle, FocusStyle
    , link, newTabLink, download, downloadAs
    , image
    , Color, rgb
    , above, below, onRight, onLeft, inFront, behindContent
    , Device, DeviceClass(..), Orientation(..), classifyDevice
    , map, mapAttribute
    , html, htmlAttribute
    , clip, clipX, clipY, embed, scrollbarX, scrollbarY
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

@docs Attribute, width, height, Length, px, shrink, fill, portion, maximum, minimum, ellip


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

If alignment is set on elements in a layout such as a `row`, then the element will push the other elements in that direction. Here's an example.

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

@docs link, newTabLink, download, downloadAs


# Images

@docs image


# Color

In order to use attributes like `Font.color` and `Background.color`, you'll need to make some colors!

@docs Color, rgb


# Nearby Elements

Let's say we want a dropdown menu. Essentially we want to say: _put this element below this other element, but don't affect the layout when you do_.

    Element.row []
        [ Element.el
            [ Element.below (Element.text "I'm below!")
            ]
            (Element.text "I'm normal!")
        ]

This will result in
/---------------
|- I'm normal! -|
---------------/
I'm below

Where `"I'm Below"` doesn't change the size of `Element.row`.

This is very useful for things like dropdown menus or tooltips.

@docs above, below, onRight, onLeft, inFront, behindContent


# Responsiveness

The main technique for responsiveness is to store window size information in your model.

Install the `Browser` package, and set up a subscription for [`Browser.Events.onResize`](https://package.elm-lang.org/packages/elm/browser/latest/Browser-Events#onResize).

You'll also need to retrieve the initial window size. You can either use [`Browser.Dom.getViewport`](https://package.elm-lang.org/packages/elm/browser/latest/Browser-Dom#getViewport) or pass in `window.innerWidth` and `window.innerHeight` as flags to your program, which is the preferred way. This requires minor setup on the JS side, but allows you to avoid the state where you don't have window info.

@docs Device, DeviceClass, Orientation, classifyDevice


# Mapping

@docs map, mapAttribute


# Compatibility

@docs html, htmlAttribute

-}

import Html exposing (Html)
import Html.Attributes
import Internal.Flag2 as Flag exposing (Flag)
import Internal.Model2 as Two
import Internal.Style2 as Style


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
        Element.el [] (Element.text "Howdy!")

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
htmlAttribute : Html.Attribute msg -> Two.Attribute msg
htmlAttribute =
    Two.Attr


{-| -}
map : (msg -> msg1) -> Two.Element msg -> Two.Element msg1
map =
    Two.map


{-| -}
mapAttribute : (msg -> msg1) -> Attribute msg -> Attribute msg1
mapAttribute =
    Two.mapAttr


{-| -}
type Length
    = Px Int
    | Content
    | Fill Int
    | Bounded (Maybe Int) (Maybe Int) Length


{-| -}
px : Int -> Length
px =
    Px


{-| Shrink an element to fit its contents.
-}
shrink : Length
shrink =
    Content


{-| Fill the available space. The available space will be split evenly between elements that have `width fill`.
-}
fill : Length
fill =
    Fill 1


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
minimum i len =
    case len of
        Bounded minBound maxBound val ->
            Bounded (Just i) maxBound val

        otherwise ->
            Bounded (Just i) Nothing otherwise


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
maximum i len =
    case len of
        Bounded minBound maxBound val ->
            Bounded minBound (Just i) val

        otherwise ->
            Bounded Nothing (Just i) otherwise


ellip : Attribute msg
ellip =
    Two.Attr (Html.Attributes.class Style.classes.ellipses)


{-| Sometimes you may not want to split available space evenly. In this case you can use `portion` to define which elements should have what portion of the available space.

So, two elements, one with `width (portion 2)` and one with `width (portion 3)`. The first would get 2 portions of the available space, while the second would get 3.

**Also:** `fill == portion 1`

-}
portion : Int -> Length
portion =
    Fill


{-| This is your top level node where you can turn `Element` into `Html`.
-}
layout : List (Two.Attribute msg) -> Two.Element msg -> Html msg
layout attrs content =
    Two.unwrap Two.zero <|
        Two.element Two.AsRoot
            (Two.Style Flag.fontSize (Style.prop "font-size" (Style.px 16))
                :: Two.Style Flag.fontFamily (Style.prop "font-family" "\"Open Sans\", sans-serif")
                :: Two.Style Flag.fontColor (Style.prop "color" (Style.color (rgb 0 0 0)))
                :: attrs
            )
            [ Two.Element styleNode
            , content
            ]


{-| Converts an `Element msg` to an `Html msg` but does not include the stylesheet.

You'll need to include it manually yourself

-}
embed : List (Two.Attribute msg) -> Two.Element msg -> Html msg
embed attrs content =
    Two.unwrap Two.zero <|
        Two.element Two.AsRoot
            (Two.Style Flag.fontSize (Style.prop "font-size" (Style.px 16))
                :: Two.Style Flag.fontFamily (Style.prop "font-family" "\"Open Sans\", sans-serif")
                :: Two.Style Flag.fontColor (Style.prop "color" (Style.color (rgb 0 0 0)))
                :: attrs
            )
            [ content
            ]


{-| -}
layoutWith : { options : List Option } -> List (Two.Attribute msg) -> Two.Element msg -> Html msg
layoutWith { options } attrs content =
    -- Internal.renderRoot options
    --     (Internal.htmlClass
    --         (String.join " "
    --             [ classes.root
    --             , classes.any
    --             , classes.single
    --             ]
    --         )
    --         :: (Internal.rootStyle ++ attrs)
    --     )
    --     child
    Two.unwrap Two.zero <|
        rootNode options attrs content


rootNode options attrs content =
    Two.element Two.AsRoot
        (Two.Style Flag.fontSize (Style.prop "font-size" (Style.px 16))
            :: Two.Style Flag.fontFamily (Style.prop "font-family" "\"Open Sans\", sans-serif")
            :: Two.Style Flag.fontColor (Style.prop "color" (Style.color (rgb 0 0 0)))
            :: attrs
        )
        [ Two.Element styleNode
        , content
        ]


styleNode _ =
    Html.div []
        [ Html.node "style"
            []
            [ Html.text Style.rules ]
        ]


{-| -}
type alias Option =
    Two.Option


{-| Elm UI embeds two StyleSheets, one that is constant, and one that changes dynamically based on styles collected from the elements being rendered.

This option will stop the static/constant stylesheet from rendering.

If you're embedding multiple elm-ui `layout` elements, you need to guarantee that only one is rendering the static style sheet and that it's above all the others in the DOM tree.

-}
noStaticStyleSheet : Option
noStaticStyleSheet =
    Two.RenderModeOption Two.NoStaticStyleSheet


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
el : List (Two.Attribute msg) -> Two.Element msg -> Two.Element msg
el attrs child =
    Two.render Two.AsEl
        Two.emptyDetails
        [ child ]
        Flag.none
        ""
        []
        Two.singleClass
        Two.NoNearbyChildren
        (List.reverse
            (width shrink
                :: height shrink
                :: attrs
            )
        )


{-| -}
row : List (Two.Attribute msg) -> List (Two.Element msg) -> Two.Element msg
row attrs children =
    Two.render Two.AsRow
        Two.emptyDetails
        children
        Flag.none
        ""
        []
        Two.rowClass
        Two.NoNearbyChildren
        (List.reverse
            (width shrink
                :: height shrink
                :: attrs
            )
        )


{-| -}
column : List (Two.Attribute msg) -> List (Two.Element msg) -> Two.Element msg
column attrs children =
    Two.render Two.AsColumn
        Two.emptyDetails
        children
        Flag.none
        ""
        []
        Two.columnClass
        Two.NoNearbyChildren
        (List.reverse
            (width shrink
                :: height shrink
                :: attrs
            )
        )


{-| Same as `row`, but will wrap if it takes up too much horizontal space.
-}
wrappedRow : List (Two.Attribute msg) -> List (Two.Element msg) -> Two.Element msg
wrappedRow attrs children =
    -- in order to make spacing work:
    --      the margin is only applied to the right and bottom of child elements
    --      We have an intermediate element which has a negative bottom and right margin to keep the sizing correct.
    --      There is some overflow with the intermediate element, so we set pointer events none on it and reenable pointer events on children.
    Two.element Two.AsEl
        attrs
        [ Two.render Two.AsWrappedRow
            Two.emptyDetails
            children
            Flag.none
            ""
            []
            Two.wrappedRowClass
            Two.NoNearbyChildren
            (List.reverse (List.concatMap Two.wrappedRowAttributes attrs))
        ]


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
explain : Todo -> Two.Attribute msg
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
    List (Two.Attribute msg)
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


{-| Same as `Element.table` except the `view` for each column will also receive the row index as well as the record.
-}
indexedTable :
    List (Two.Attribute msg)
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


tableHelper : List (Two.Attribute msg) -> InternalTable data msg -> Two.Element msg
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
paragraph : List (Two.Attribute msg) -> List (Two.Element msg) -> Two.Element msg
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
    -- Two.element Two.AsParagraph
    Two.render Two.AsParagraph
        Two.emptyDetails
        children
        Flag.none
        ""
        []
        Two.paragraphClass
        Two.NoNearbyChildren
        (List.reverse
            (width shrink
                :: height shrink
                :: attrs
            )
        )


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
textColumn : List (Two.Attribute msg) -> List (Two.Element msg) -> Two.Element msg
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
    Two.render Two.AsTextColumn
        Two.emptyDetails
        children
        Flag.none
        ""
        []
        Two.textColumnClass
        Two.NoNearbyChildren
        (List.reverse
            (width shrink
                :: height shrink
                :: attrs
            )
        )


{-| Both a source and a description are required for images.

The description is used for people using screen readers.

Leaving the description blank will cause the image to be ignored by assistive technology. This can make sense for images that are purely decorative and add no additional information.

So, take a moment to describe your image as you would to someone who has a harder time seeing.

-}
image : List (Two.Attribute msg) -> { src : String, description : String } -> Two.Element msg
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
    -- ([ Internal.Attr <| Html.Attributes.src src
    --  , Internal.Attr <| Html.Attributes.alt description
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
                    [ Html.Attributes.src src
                    , Html.Attributes.alt description
                    ]
                    []
            )
        ]


{-|

    el
        [ link "http://fruits.com" ]
        (text "A link to my favorite fruit provider.")

-}
link : String -> Two.Attribute msg
link =
    Two.Link False


{-| -}
newTabLink : String -> Two.Attribute msg
newTabLink =
    Two.Link True


{-| A link to download a file.
-}
download : String -> Two.Attribute msg
download url =
    Two.Download url ""


{-| A link to download a file, but you can specify the filename.
-}
downloadAs : { url : String, filename : String } -> Two.Attribute msg
downloadAs { url, filename } =
    Two.Download url filename



{- NEARBYS -}


{-| -}
below : Two.Element msg -> Two.Attribute msg
below element =
    Two.Nearby Two.Below element


{-| -}
above : Two.Element msg -> Two.Attribute msg
above element =
    Two.Nearby Two.Above element


{-| -}
onRight : Two.Element msg -> Two.Attribute msg
onRight element =
    Two.Nearby Two.OnRight element


{-| -}
onLeft : Two.Element msg -> Two.Attribute msg
onLeft element =
    Two.Nearby Two.OnLeft element


{-| This will place an element in front of another.

**Note:** If you use this on a `layout` element, it will place the element as fixed to the viewport which can be useful for modals and overlays.

-}
inFront : Two.Element msg -> Two.Attribute msg
inFront element =
    Two.Nearby Two.InFront element


{-| This will place an element between the background and the content of an element.
-}
behindContent : Two.Element msg -> Two.Attribute msg
behindContent element =
    Two.Nearby Two.Behind element


{-| -}
width : Length -> Two.Attribute msg
width len =
    case len of
        Px x ->
            Two.ClassAndStyle Flag.width
                Style.classes.widthExact
                (Style.prop "width" (Style.px x))

        Content ->
            Two.Class Flag.width Style.classes.widthContent

        Fill f ->
            -- width fill should be flex-grow: portion for rows
            -- and the default behavior for anything else
            -- however for columns, flex-grow needs to be set by the height
            -- which means
            if f < 10 then
                Two.Class Flag.width
                    (Style.classes.widthFill
                        ++ " "
                        ++ Style.classes.widthFillPortion
                        ++ "-"
                        ++ String.fromInt f
                    )

            else
                Two.ClassAndStyle Flag.width
                    Style.classes.widthFill
                    (Style.set Style.vars.widthFill (String.fromInt f))

        Bounded minBound maxBound (Px x) ->
            Two.ClassAndStyle Flag.width
                (Style.classes.widthBounded ++ " " ++ Style.classes.widthExact)
                (Style.prop "width" (Style.px x) ++ renderBounds "width" minBound maxBound)

        Bounded minBound maxBound Content ->
            Two.ClassAndStyle Flag.width
                (Style.classes.widthBounded ++ " " ++ Style.classes.widthContent)
                (renderBounds "width" minBound maxBound)

        Bounded minBound maxBound (Fill f) ->
            if f < 10 then
                Two.ClassAndStyle Flag.width
                    (Style.classes.widthFill
                        ++ " "
                        ++ Style.classes.widthBounded
                        ++ " "
                        ++ Style.classes.widthFillPortion
                        ++ "-"
                        ++ String.fromInt f
                    )
                    (renderBounds "width" minBound maxBound)

            else
                Two.ClassAndStyle Flag.width
                    (Style.classes.widthFill ++ " " ++ Style.classes.widthBounded)
                    (Style.set Style.vars.widthFill (String.fromInt f) ++ renderBounds "width" minBound maxBound)

        Bounded _ _ embedded ->
            -- This shouldn't happen because our constructors only allow for one level deep
            Two.NoAttribute


{-| -}
height : Length -> Two.Attribute msg
height len =
    case len of
        Px x ->
            Two.ClassAndStyle Flag.height
                Style.classes.heightExact
                ("height:" ++ String.fromInt x ++ "px;")

        Content ->
            Two.Class Flag.height Style.classes.heightContent

        Fill f ->
            if f < 10 then
                Two.Class Flag.height
                    (Style.classes.heightFill
                        ++ " "
                        ++ Style.classes.heightFillPortion
                        ++ "-"
                        ++ String.fromInt f
                    )

            else
                Two.ClassAndStyle Flag.height
                    Style.classes.heightFill
                    (Style.set Style.vars.heightFill (String.fromInt f))

        Bounded minBound maxBound (Px x) ->
            Two.ClassAndStyle Flag.height
                (Style.classes.heightExact ++ " " ++ Style.classes.heightBounded)
                ("height:" ++ (String.fromInt x ++ "px;") ++ renderBounds "height" minBound maxBound ++ ";")

        Bounded minBound maxBound Content ->
            Two.ClassAndStyle Flag.height
                (Style.classes.heightContent ++ " " ++ Style.classes.heightBounded)
                (renderBounds "height" minBound maxBound)

        Bounded minBound maxBound (Fill f) ->
            if f < 10 then
                Two.ClassAndStyle Flag.height
                    (Style.classes.heightFill
                        ++ " "
                        ++ Style.classes.heightBounded
                        ++ " "
                        ++ Style.classes.heightFillPortion
                        ++ "-"
                        ++ String.fromInt f
                    )
                    (renderBounds "height" minBound maxBound)

            else
                Two.ClassAndStyle Flag.height
                    (Style.classes.heightFill ++ " " ++ Style.classes.heightBounded)
                    (Style.set Style.vars.heightFill (String.fromInt f)
                        ++ renderBounds "height" minBound maxBound
                    )

        Bounded _ _ embedded ->
            -- This shouldn't happen because our constructors only allow for one level deep
            Two.NoAttribute


renderBounds : String -> Maybe Int -> Maybe Int -> String
renderBounds name minBound maxBound =
    case minBound of
        Just actualMin ->
            case maxBound of
                Just actualMax ->
                    Style.prop ("min-" ++ name) (Style.px actualMin)
                        ++ Style.prop ("max-" ++ name) (Style.px actualMin)

                Nothing ->
                    Style.prop ("min-" ++ name) (Style.px actualMin)

        Nothing ->
            case maxBound of
                Just actualMax ->
                    Style.prop ("max-" ++ name) (Style.px actualMax)

                Nothing ->
                    ""


{-| -}
scale : Float -> Two.Attribute msg
scale =
    Two.Scale


{-| Angle is given in radians. [Here are some conversion functions if you want to use another unit.](https://package.elm-lang.org/packages/elm/core/latest/Basics#degrees)
-}
rotate : Float -> Two.Attribute msg
rotate =
    Two.Rotate


{-| -}
moveUp : Float -> Two.Attribute msg
moveUp =
    Two.TranslateY << negate


{-| -}
moveDown : Float -> Two.Attribute msg
moveDown =
    Two.TranslateY


{-| -}
moveRight : Float -> Two.Attribute msg
moveRight =
    Two.TranslateX


{-| -}
moveLeft : Float -> Two.Attribute msg
moveLeft =
    Two.TranslateX << negate


{-| -}
padding : Int -> Two.Attribute msg
padding x =
    Two.Padding Flag.padding x x x x


{-| Set horizontal and vertical padding.
-}
paddingXY : Int -> Int -> Two.Attribute msg
paddingXY x y =
    Two.Padding Flag.padding y x y x


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
paddingEach : { top : Int, right : Int, bottom : Int, left : Int } -> Two.Attribute msg
paddingEach { top, right, bottom, left } =
    Two.Padding Flag.padding top right bottom left


{-| -}
centerX : Two.Attribute msg
centerX =
    Two.Class Flag.xAlign Style.classes.alignCenterX


{-| -}
centerY : Two.Attribute msg
centerY =
    Two.Class Flag.yAlign Style.classes.alignCenterY


{-| -}
alignTop : Two.Attribute msg
alignTop =
    Two.Class Flag.yAlign Style.classes.alignTop


{-| -}
alignBottom : Two.Attribute msg
alignBottom =
    Two.Class Flag.yAlign Style.classes.alignBottom


{-| -}
alignLeft : Two.Attribute msg
alignLeft =
    Two.Class Flag.xAlign Style.classes.alignLeft


{-| -}
alignRight : Two.Attribute msg
alignRight =
    Two.Class Flag.xAlign Style.classes.alignRight


{-| -}
spaceEvenly : Two.Attribute msg
spaceEvenly =
    Two.Class Flag.spacing Style.classes.spaceEvenly


{-| -}
spacing : Int -> Two.Attribute msg
spacing x =
    Two.Spacing Flag.spacing x x


{-| In the majority of cases you'll just need to use `spacing`, which will work as intended.

However for some layouts, like `textColumn`, you may want to set a different spacing for the x axis compared to the y axis.

-}
spacingXY : Int -> Int -> Two.Attribute msg
spacingXY x y =
    Two.Spacing Flag.spacing x y


{-| Make an element transparent and have it ignore any mouse or touch events, though it will stil take up space.
-}
transparent : Bool -> Two.Attribute msg
transparent on =
    if on then
        Two.Style Flag.transparency "opacity:1;"

    else
        Two.Style Flag.transparency "opacity:0;"


{-| A capped value between 0.0 and 1.0, where 0.0 is transparent and 1.0 is fully opaque.

Semantically equivalent to html opacity.

-}
alpha : Float -> Two.Attribute msg
alpha o =
    Two.Style Flag.transparency ("opacity:" ++ String.fromFloat o ++ ";")


{-| -}
viewport : List (Two.Attribute msg) -> Two.Element msg -> Two.Element msg
viewport attrs child =
    Two.element Two.AsEl
        (scrollbars
            :: width fill
            :: height fill
            :: attrs
        )
        [ child ]


{-| -}
scrollbars : Two.Attribute msg
scrollbars =
    Two.Class Flag.overflow Style.classes.scrollbars


{-| -}
scrollbarY : Two.Attribute msg
scrollbarY =
    Two.Class Flag.overflow Style.classes.scrollbarsY


{-| -}
scrollbarX : Two.Attribute msg
scrollbarX =
    Two.Class Flag.overflow Style.classes.scrollbarsX


{-| Clip the content if it overflows.

Similar to `viewport`, this element will fill the space it's given.

If the content overflows this element, it will be clipped.

-}
clipped : List (Two.Attribute msg) -> Two.Element msg -> Two.Element msg
clipped attrs child =
    Two.element Two.AsEl
        (clip
            :: width fill
            :: height fill
            :: attrs
        )
        [ child ]


{-| -}
clip : Two.Attribute msg
clip =
    Two.Class Flag.overflow Style.classes.clip


{-| -}
clipY : Two.Attribute msg
clipY =
    Two.Class Flag.overflow Style.classes.clipY


{-| -}
clipX : Two.Attribute msg
clipX =
    Two.Class Flag.overflow Style.classes.clipX


{-| Set the cursor to be a pointing hand when it's hovering over this element.
-}
pointer : Two.Attribute msg
pointer =
    Two.Class Flag.cursor Style.classes.cursorPointer


{-| -}
grab : Two.Attribute msg
grab =
    Two.Style Flag.cursor "cursor:grab;"


{-| -}
grabbing : Two.Attribute msg
grabbing =
    Two.Style Flag.cursor "cursor:grabbing;"


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



-- {-| -}
-- mouseOver : List Decoration -> Attribute msg
-- mouseOver decs =
--     Internal.StyleClass Flag.hover <|
--         Internal.PseudoSelector Internal.Hover
--             (Internal.unwrapDecorations decs)
-- {-| -}
-- mouseDown : List Decoration -> Attribute msg
-- mouseDown decs =
--     Internal.StyleClass Flag.active <|
--         Internal.PseudoSelector Internal.Active
--             (Internal.unwrapDecorations decs)
-- {-| -}
-- focused : List Decoration -> Attribute msg
-- focused decs =
--     Internal.StyleClass Flag.focus <|
--         Internal.PseudoSelector Internal.Focus
--             (Internal.unwrapDecorations decs)
