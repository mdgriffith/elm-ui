module Element.Input
    exposing
        ( Label
        , Option
        , OptionState(..)
        , Placeholder
        , Thumb
        , button
        , checkbox
        , currentPassword
        , defaultCheckbox
        , defaultThumb
        , email
        , focusedOnLoad
        , labelAbove
        , labelBelow
        , labelLeft
        , labelRight
        , multiline
        , newPassword
        , option
        , optionWith
        , placeholder
        , radio
        , radioRow
        , search
        , slider
        , spellChecked
        , text
        , thumb
        , username
        )

{-|

@docs button

@docs checkbox, defaultCheckbox


## Text Input

@docs text, Placeholder, placeholder, username, newPassword, currentPassword, email, search, spellChecked


## Multiline Text

@docs multiline


## Slider

@docs slider, Thumb, thumb, defaultThumb


## Radio Buttons

@docs radio, radioRow, Option, option, optionWith, OptionState


## Labels

@docs Label, labelAbove, labelBelow, labelLeft, labelRight

@docs focusedOnLoad

-}

import Element exposing (Attribute, Color, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Region as Region
import Html
import Html.Attributes
import Html.Events
import Internal.Flag as Flag
import Internal.Model as Internal
import Internal.Style exposing (classes)
import Json.Decode as Json


{-| -}
type Placeholder msg
    = Placeholder (List (Attribute msg)) (Element msg)


white =
    Element.rgb 1 1 1


darkGrey =
    Element.rgb (186 / 255) (189 / 255) (182 / 255)


charcoal =
    Element.rgb
        (136 / 255)
        (138 / 255)
        (133 / 255)


{-| -}
placeholder : List (Attribute msg) -> Element msg -> Placeholder msg
placeholder =
    Placeholder


{-| Every input has a required `label`.
-}
type Label msg
    = Label Internal.Location (List (Attribute msg)) (Element msg)


{-| -}
labelRight : List (Attribute msg) -> Element msg -> Label msg
labelRight =
    Label Internal.OnRight


{-| -}
labelLeft : List (Attribute msg) -> Element msg -> Label msg
labelLeft =
    Label Internal.OnLeft


{-| -}
labelAbove : List (Attribute msg) -> Element msg -> Label msg
labelAbove =
    Label Internal.Above


{-| -}
labelBelow : List (Attribute msg) -> Element msg -> Label msg
labelBelow =
    Label Internal.Below


{-| A standard button.

The `onPress` handler will be fired either `onClick` or when the element is focused and the enter key has been pressed.

    import Element.Input as Input

    Input.button []
        { onPress = Just ClickMsg
        , label = text "My Button"
        }

`onPress` takes a `Maybe msg`. If you provide the value `Nothing`, then the button will be disabled.

-}
button :
    List (Attribute msg)
    ->
        { onPress : Maybe msg
        , label : Element msg
        }
    -> Element msg
button attrs { onPress, label } =
    Internal.element
        Internal.asEl
        -- We don't explicitly label this node as a button,
        -- because buttons fire a bunch of times when you hold down the enter key.
        -- We'd like to fire just once on the enter key, which means using keyup instead of keydown.
        -- Because we have no way to disable keydown, though our messages get doubled.
        Internal.div
        (Element.width Element.shrink
            :: Element.height Element.shrink
            :: Internal.htmlClass classes.contentCenterX
            :: Internal.htmlClass classes.contentCenterY
            :: Internal.htmlClass classes.seButton
            :: Element.pointer
            :: focusDefault attrs
            :: Internal.Describe Internal.Button
            :: Internal.Attr (Html.Attributes.tabindex 0)
            :: (case onPress of
                    Nothing ->
                        Internal.Attr (Html.Attributes.disabled True) :: attrs

                    Just msg ->
                        Events.onClick msg
                            :: onEnter msg
                            :: attrs
               )
        )
        (Internal.Unkeyed [ label ])


focusDefault attrs =
    if List.any hasFocusStyle attrs then
        Internal.NoAttribute
    else
        Internal.htmlClass "focusable"


hasFocusStyle attr =
    case attr of
        Internal.StyleClass _ (Internal.PseudoSelector Internal.Focus _) ->
            True

        _ ->
            False


{-| -}
type alias Checkbox msg =
    { onChange : Maybe (Bool -> msg)
    , icon : Maybe (Element msg)
    , checked : Bool
    , label : Label msg
    }


{-| -}
checkbox :
    List (Attribute msg)
    ->
        { onChange : Bool -> msg
        , icon : Bool -> Element msg
        , checked : Bool
        , label : Label msg
        }
    -> Element msg
checkbox attrs { label, icon, checked, onChange } =
    let
        attributes =
            Element.spacing 6
                :: [ Internal.Attr (Html.Events.onClick (onChange (not checked)))
                   , Region.announce
                   , onKeyLookup <|
                        \code ->
                            if code == enter then
                                Just <| onChange (not checked)
                            else if code == space then
                                Just <| onChange (not checked)
                            else
                                Nothing
                   ]
                ++ (tabindex 0 :: Element.pointer :: Element.alignLeft :: Element.width Element.fill :: attrs)
    in
    applyLabel attributes
        label
        (Internal.element
            Internal.asEl
            Internal.div
            [ Internal.Attr <|
                Html.Attributes.attribute "role" "checkbox"
            , Internal.Attr <|
                Html.Attributes.attribute "aria-checked" <|
                    if checked then
                        "true"
                    else
                        "false"
            , Element.centerY
            , Element.height Element.fill
            , Element.width Element.shrink
            ]
            (Internal.Unkeyed
                [ icon checked
                ]
            )
        )


{-| -}
type Thumb
    = Thumb (List (Attribute Never))


{-| -}
thumb : List (Attribute Never) -> Thumb
thumb =
    Thumb


{-| -}
defaultThumb : Thumb
defaultThumb =
    Thumb
        [ Element.width (Element.px 16)
        , Element.height (Element.px 16)
        , Border.rounded 8
        , Border.width 1
        , Border.color (Element.rgb 0.5 0.5 0.5)
        , Background.color (Element.rgb 1 1 1)
        ]


{-| A slider input, good for capturing float values.

    Input.slider
        [ Element.height (Element.px 30)
        -- Here is where we're creating/styling the "track"
        , Element.behindContent
            (Element.el
                [ Element.width Element.fill
                , Element.height (Element.px 2)
                , Element.centerY
                , Background.color grey
                , Border.rounded 2
                ]
                Element.none
            )
        ]
        { onChange = AdjustValue
        , label = Input.labelAbove [] (text "My Slider Value")
        , min = 0
        , max = 75
        , step = Nothing
        , value = model.sliderValue
        , thumb =
            Input.defaultThumb
        }

The `thumb` is the icon that you can move around.

The slider can be vertical or horizontal depending on the width/height of the slider.

  - `height fill` and `width (px someWidth)` will cause the slider to be vertical.
  - `height (px someHeight)` and `width (px someWidth)` where `someHeight` > `someWidth` will also do it.
  - otherwise, the slider will be horizontal.

**Note:** If you want a slider for an `Int` value:

  - set `step` to be `Just 1`, or some other whole value
  - `value = toFloat model.myInt`
  - And finally, round the value before making a message `onChange = round >> AdjustValue`

-}
slider :
    List (Attribute msg)
    ->
        { onChange : Float -> msg
        , label : Label msg
        , min : Float
        , max : Float
        , value : Float
        , thumb : Thumb
        , step : Maybe Float
        }
    -> Element msg
slider attributes input =
    let
        (Thumb thumbAttributes) =
            input.thumb

        width =
            Internal.getWidth thumbAttributes

        height =
            Internal.getHeight thumbAttributes

        vertical =
            case ( trackWidth, trackHeight ) of
                ( Nothing, Nothing ) ->
                    False

                ( Just (Internal.Px w), Just (Internal.Px h) ) ->
                    h > w

                ( Just (Internal.Px _), Just (Internal.Fill _) ) ->
                    True

                _ ->
                    False

        trackHeight =
            Internal.getHeight attributes

        trackWidth =
            Internal.getWidth attributes

        ( spacingX, spacingY ) =
            Internal.getSpacing attributes ( 5, 5 )

        factor =
            (input.value - input.min)
                / (input.max - input.min)

        {- Needed attributes

           Thumb Attributes
              - Width/Height of thumb so that the input can shadow it.


           Attributes

               OnParent ->
                   Spacing


               On track ->
                   Everything else




            The `<input>`


        -}
        className =
            "thmb-" ++ thumbWidthString ++ "-" ++ thumbHeightString

        thumbWidthString =
            case width of
                Nothing ->
                    "20px"

                Just (Internal.Px px) ->
                    String.fromInt px ++ "px"

                _ ->
                    "100%"

        thumbHeightString =
            case height of
                Nothing ->
                    "20px"

                Just (Internal.Px px) ->
                    String.fromInt px ++ "px"

                _ ->
                    "100%"

        thumbShadowStyle =
            [ Internal.Property "width"
                thumbWidthString
            , Internal.Property "height"
                thumbHeightString
            ]
    in
    applyLabel
        [ Element.spacingXY spacingX spacingY
        , Region.announce
        , Element.width Element.fill
        ]
        input.label
        (Element.row
            [ Element.width
                (Maybe.withDefault Element.fill trackWidth)
            , Element.height
                (Maybe.withDefault (Element.px 20) trackHeight)
            ]
            [ Internal.element
                Internal.asEl
                (Internal.NodeName "input")
                [ Internal.StyleClass Flag.active
                    (Internal.Style
                        ("input[type=\"range\"]." ++ className ++ "::-moz-range-thumb")
                        thumbShadowStyle
                    )
                , Internal.StyleClass Flag.hover
                    (Internal.Style
                        ("input[type=\"range\"]." ++ className ++ "::-webkit-slider-thumb")
                        thumbShadowStyle
                    )
                , Internal.StyleClass Flag.focus
                    (Internal.Style
                        ("input[type=\"range\"]." ++ className ++ "::-ms-thumb")
                        thumbShadowStyle
                    )
                , Internal.Attr (Html.Attributes.class (className ++ " focusable-parent"))
                , Internal.Attr
                    (Html.Events.onInput
                        (\str ->
                            case String.toFloat str of
                                Nothing ->
                                    -- This should never happen because the browser
                                    -- should always provide a Float.
                                    input.onChange 0

                                Just val ->
                                    input.onChange val
                        )
                    )
                , Internal.Attr <|
                    Html.Attributes.type_ "range"
                , Internal.Attr <|
                    Html.Attributes.step
                        (case input.step of
                            Nothing ->
                                -- Note: If we set `any` here,
                                -- Firefox makes a single press of the arrows keys equal to 1
                                -- We could set the step manually to the effective range / 100
                                -- String.fromFloat ((input.max - input.min) / 100)
                                -- Which matches Chrome's default behavior
                                -- HOWEVER, that means manually moving a slider with the mouse will snap to that interval.
                                "any"

                            Just step ->
                                String.fromFloat step
                        )
                , Internal.Attr <|
                    Html.Attributes.min (String.fromFloat input.min)
                , Internal.Attr <|
                    Html.Attributes.max (String.fromFloat input.max)
                , Internal.Attr <|
                    Html.Attributes.value (String.fromFloat input.value)
                , if vertical then
                    Internal.Attr <|
                        Html.Attributes.attribute "orient" "vertical"
                  else
                    Internal.NoAttribute
                , Element.width <|
                    if vertical then
                        Maybe.withDefault (Element.px 20) trackHeight
                    else
                        Maybe.withDefault Element.fill trackWidth
                , Element.height <|
                    if vertical then
                        Maybe.withDefault Element.fill trackWidth
                    else
                        Maybe.withDefault (Element.px 20) trackHeight
                ]
                (Internal.Unkeyed [])
            , Element.el
                (Element.width
                    (Maybe.withDefault Element.fill trackWidth)
                    :: Element.height
                        (Maybe.withDefault (Element.px 20) trackHeight)
                    :: attributes
                    -- This is after `attributes` because the thumb should be in front of everything.
                    ++ [ Element.behindContent <|
                            if vertical then
                                viewVerticalThumb factor thumbAttributes trackWidth
                            else
                                viewHorizontalThumb factor thumbAttributes trackHeight
                       ]
                )
                Element.none
            ]
        )


viewHorizontalThumb factor thumbAttributes trackHeight =
    Element.row
        [ Element.width Element.fill
        , Element.height (Maybe.withDefault Element.fill trackHeight)
        , Element.centerY
        ]
        [ Element.el
            [ Element.width (Element.fillPortion (round <| factor * 10000))
            ]
            Element.none
        , Element.el
            (Element.centerY
                :: List.map (Internal.mapAttr Basics.never) thumbAttributes
            )
            Element.none
        , Element.el
            [ Element.width (Element.fillPortion (round <| (abs <| 1 - factor) * 10000))
            ]
            Element.none
        ]


viewVerticalThumb factor thumbAttributes trackWidth =
    Element.column
        [ Element.height Element.fill
        , Element.width (Maybe.withDefault Element.fill trackWidth)
        , Element.centerX
        ]
        [ Element.el
            [ Element.height (Element.fillPortion (round <| (abs <| 1 - factor) * 10000))
            ]
            Element.none
        , Element.el
            (Element.centerX
                :: List.map (Internal.mapAttr Basics.never) thumbAttributes
            )
            Element.none
        , Element.el
            [ Element.height (Element.fillPortion (round <| factor * 10000))
            ]
            Element.none
        ]


type alias TextInput =
    { type_ : TextKind
    , spellchecked : Bool
    , autofill : Maybe String
    }


type TextKind
    = TextInputNode String
    | TextArea


{-| -}
type alias Text msg =
    { onChange : String -> msg
    , text : String
    , placeholder : Maybe (Placeholder msg)
    , label : Label msg
    }


type Padding
    = Padding Int Int Int Int


{-|

    attributes

    <parent>
        attribute::width/height fill
        attribtue::alignment
        attribute::spacing
        attribute::fontsize/family/lineheight
        <el-wrapper>
                attribute::nearby(placeholder)
                attribute::width/height fill
                inFront ->
                    placeholder
                        attribute::padding


            <input>
                textarea ->
                    special height for height-content
                        attribtue::padding
                        attribute::lineHeight
                attributes
        <label>

-}
textHelper : TextInput -> List (Attribute msg) -> Text msg -> Element msg
textHelper textInput attrs textOptions =
    let
        attributes =
            Element.width Element.fill :: (defaultTextBoxStyle ++ attrs)

        behavior =
            [ Internal.Attr (Html.Events.onInput textOptions.onChange) ]

        noNearbys =
            List.filter (not << forNearby) attributes

        forNearby attr =
            case attr of
                Internal.Nearby _ _ ->
                    True

                _ ->
                    False

        ( inputNode, inputAttrs, inputChildren ) =
            case textInput.type_ of
                TextInputNode inputType ->
                    ( "input"
                    , [ value textOptions.text
                      , Internal.Attr (Html.Attributes.type_ inputType)
                      , spellcheck textInput.spellchecked
                      , Internal.htmlClass classes.inputText
                      , case textInput.autofill of
                            Nothing ->
                                Internal.NoAttribute

                            Just fill ->
                                autofill fill
                      ]
                        ++ noNearbys
                    , []
                    )

                TextArea ->
                    let
                        { maybePadding, heightContent, maybeSpacing, adjustedAttributes } =
                            attributes
                                |> List.foldr
                                    (\attr found ->
                                        case attr of
                                            Internal.Describe _ ->
                                                found

                                            Internal.Height val ->
                                                case found.heightContent of
                                                    Nothing ->
                                                        case val of
                                                            Internal.Content ->
                                                                { found
                                                                    | heightContent = Just val
                                                                    , adjustedAttributes = attr :: found.adjustedAttributes
                                                                }

                                                            _ ->
                                                                { found | heightContent = Just val }

                                                    Just i ->
                                                        found

                                            Internal.StyleClass _ (Internal.PaddingStyle _ t r b l) ->
                                                case found.maybePadding of
                                                    Nothing ->
                                                        { found
                                                            | maybePadding = Just (Padding t r b l)
                                                            , adjustedAttributes = found.adjustedAttributes
                                                        }

                                                    _ ->
                                                        found

                                            Internal.StyleClass _ (Internal.SpacingStyle _ x y) ->
                                                case found.maybeSpacing of
                                                    Nothing ->
                                                        { found
                                                            | maybeSpacing = Just y
                                                            , adjustedAttributes = attr :: found.adjustedAttributes
                                                        }

                                                    _ ->
                                                        found

                                            _ ->
                                                { found | adjustedAttributes = attr :: found.adjustedAttributes }
                                    )
                                    { maybePadding = Nothing
                                    , heightContent = Nothing
                                    , maybeSpacing = Nothing
                                    , adjustedAttributes = []
                                    }

                        -- NOTE: This is where default text spacing is set
                        spacing =
                            Maybe.withDefault 5 maybeSpacing
                    in
                    ( "textarea"
                    , [ spellcheck textInput.spellchecked
                      , Internal.htmlClass classes.inputMultiline
                      , Maybe.map autofill textInput.autofill
                            |> Maybe.withDefault Internal.NoAttribute
                      , case maybePadding of
                            Nothing ->
                                Internal.NoAttribute

                            Just (Padding t r b l) ->
                                Element.paddingEach
                                    { top = max 0 (t - (spacing // 2))
                                    , bottom = max 0 (b - (spacing // 2))
                                    , left = l
                                    , right = r
                                    }
                      , case heightContent of
                            Nothing ->
                                Internal.NoAttribute

                            Just Internal.Content ->
                                let
                                    newlineCount =
                                        String.lines textOptions.text
                                            |> List.length
                                            |> (\x ->
                                                    if x < 1 then
                                                        1
                                                    else
                                                        x
                                               )

                                    heightValue count =
                                        case maybePadding of
                                            Nothing ->
                                                "calc(" ++ String.fromInt count ++ "em + " ++ String.fromInt ((count - 1) * spacing) ++ "px) !important"

                                            Just (Padding t r b l) ->
                                                "calc(" ++ String.fromInt count ++ "em + " ++ String.fromInt ((t + b) + ((count - 1) * spacing)) ++ "px) !important"
                                in
                                Internal.StyleClass Flag.height
                                    (Internal.Single ("textarea-height-" ++ String.fromInt newlineCount)
                                        "height"
                                        (heightValue newlineCount)
                                    )

                            Just x ->
                                Internal.Height x
                      ]
                        ++ adjustedAttributes
                    , [ Internal.unstyled (Html.text textOptions.text) ]
                    )

        attributesFromChild =
            Internal.get attributes <|
                \attr ->
                    case attr of
                        Internal.Width (Internal.Fill _) ->
                            True

                        Internal.Height (Internal.Fill _) ->
                            True

                        Internal.AlignX _ ->
                            True

                        Internal.AlignY _ ->
                            True

                        Internal.StyleClass _ (Internal.SpacingStyle _ _ _) ->
                            True

                        Internal.StyleClass _ (Internal.FontSize _) ->
                            True

                        Internal.StyleClass _ (Internal.FontFamily _ _) ->
                            True

                        _ ->
                            False

        nearbys =
            Internal.get attributes <|
                \attr ->
                    case attr of
                        Internal.Nearby _ _ ->
                            True

                        _ ->
                            False

        inputPadding =
            Internal.get attributes <|
                \attr ->
                    case attr of
                        Internal.StyleClass _ (Internal.PaddingStyle _ _ _ _ _) ->
                            True

                        _ ->
                            False

        inputElement =
            Internal.element
                Internal.asEl
                Internal.div
                (Element.width Element.fill
                    :: List.concat
                        [ nearbys
                        , case textOptions.placeholder of
                            Nothing ->
                                []

                            Just (Placeholder placeholderAttrs placeholderEl) ->
                                [ Element.inFront
                                    (Element.el
                                        (defaultTextPadding
                                            :: noNearbys
                                            ++ [ Font.color charcoal
                                               , Internal.htmlClass (classes.noTextSelection ++ " " ++ classes.passPointerEvents)
                                               , Border.color (Element.rgba 0 0 0 0)
                                               , Background.color (Element.rgba 0 0 0 0)
                                               , Element.height Element.fill
                                               , Element.width Element.fill
                                               , Element.alpha
                                                    (if textOptions.text == "" then
                                                        1
                                                     else
                                                        0
                                                    )
                                               ]
                                            ++ placeholderAttrs
                                        )
                                        placeholderEl
                                    )
                                ]
                        ]
                )
                (Internal.Unkeyed
                    [ Internal.element
                        Internal.asEl
                        (Internal.NodeName inputNode)
                        (List.concat
                            [ [ focusDefault attrs
                              ]
                            , inputAttrs
                            , behavior
                            ]
                        )
                        (Internal.Unkeyed inputChildren)
                    ]
                )
    in
    applyLabel
        (Internal.Class Flag.cursor classes.cursorText
            :: Element.spacing 5
            :: Region.announce
            :: attributesFromChild
        )
        textOptions.label
        inputElement


{-| -}
text :
    List (Attribute msg)
    ->
        { onChange : String -> msg
        , text : String
        , placeholder : Maybe (Placeholder msg)
        , label : Label msg
        }
    -> Element msg
text =
    textHelper
        { type_ = TextInputNode "text"
        , spellchecked = False
        , autofill = Nothing
        }


{-| -}
spellChecked :
    List (Attribute msg)
    ->
        { onChange : String -> msg
        , text : String
        , placeholder : Maybe (Placeholder msg)
        , label : Label msg
        }
    -> Element msg
spellChecked =
    textHelper
        { type_ = TextInputNode "text"
        , spellchecked = True
        , autofill = Nothing
        }


{-| -}
search :
    List (Attribute msg)
    ->
        { onChange : String -> msg
        , text : String
        , placeholder : Maybe (Placeholder msg)
        , label : Label msg
        }
    -> Element msg
search =
    textHelper
        { type_ = TextInputNode "search"
        , spellchecked = False
        , autofill = Nothing
        }


{-| A password input that allows the browser to autofill.

It's `newPassword` instead of just `password` because it gives the browser a hint on what type of password input it is.

A password takes all the arguments a normal `Input.text` would, and also `show`, which will remove the password mask (e.g. `****` vs `pass1234`)

-}
newPassword :
    List (Attribute msg)
    ->
        { onChange : String -> msg
        , text : String
        , placeholder : Maybe (Placeholder msg)
        , label : Label msg
        , show : Bool
        }
    -> Element msg
newPassword attrs pass =
    textHelper
        { type_ =
            TextInputNode <|
                if pass.show then
                    "text"
                else
                    "password"
        , spellchecked = False
        , autofill = Just "new-password"
        }
        attrs
        { onChange = pass.onChange
        , text = pass.text
        , placeholder = pass.placeholder
        , label = pass.label
        }


{-| -}
currentPassword :
    List (Attribute msg)
    ->
        { onChange : String -> msg
        , text : String
        , placeholder : Maybe (Placeholder msg)
        , label : Label msg
        , show : Bool
        }
    -> Element msg
currentPassword attrs pass =
    textHelper
        { type_ =
            TextInputNode <|
                if pass.show then
                    "text"
                else
                    "password"
        , spellchecked = False
        , autofill = Just "current-password"
        }
        attrs
        { onChange = pass.onChange
        , text = pass.text
        , placeholder = pass.placeholder
        , label = pass.label
        }


{-| -}
username :
    List (Attribute msg)
    ->
        { onChange : String -> msg
        , text : String
        , placeholder : Maybe (Placeholder msg)
        , label : Label msg
        }
    -> Element msg
username =
    textHelper
        { type_ = TextInputNode "text"
        , spellchecked = False
        , autofill = Just "username"
        }


{-| -}
email :
    List (Attribute msg)
    ->
        { onChange : String -> msg
        , text : String
        , placeholder : Maybe (Placeholder msg)
        , label : Label msg
        }
    -> Element msg
email =
    textHelper
        { type_ = TextInputNode "email"
        , spellchecked = False
        , autofill = Just "email"
        }


{-| -}
multiline :
    List (Attribute msg)
    ->
        { onChange : String -> msg
        , text : String
        , placeholder : Maybe (Placeholder msg)
        , label : Label msg
        , spellcheck : Bool
        }
    -> Element msg
multiline attrs multi =
    textHelper
        { type_ =
            TextArea
        , spellchecked = multi.spellcheck
        , autofill = Nothing
        }
        attrs
        { onChange = multi.onChange
        , text = multi.text
        , placeholder = multi.placeholder
        , label = multi.label
        }


applyLabel : List (Attribute msg) -> Label msg -> Element msg -> Element msg
applyLabel attrs label input =
    case label of
        Label position labelAttrs labelChild ->
            let
                labelElement =
                    Internal.element
                        Internal.asEl
                        Internal.div
                        labelAttrs
                        (Internal.Unkeyed [ labelChild ])
            in
            case position of
                Internal.Above ->
                    Internal.element
                        Internal.asColumn
                        (Internal.NodeName "label")
                        attrs
                        (Internal.Unkeyed [ labelElement, input ])

                Internal.Below ->
                    Internal.element
                        Internal.asColumn
                        (Internal.NodeName "label")
                        attrs
                        (Internal.Unkeyed [ input, labelElement ])

                Internal.OnRight ->
                    Internal.element
                        Internal.asRow
                        (Internal.NodeName "label")
                        attrs
                        (Internal.Unkeyed [ input, labelElement ])

                Internal.OnLeft ->
                    Internal.element
                        Internal.asRow
                        (Internal.NodeName "label")
                        attrs
                        (Internal.Unkeyed [ labelElement, input ])

                Internal.InFront ->
                    Internal.element
                        Internal.asRow
                        (Internal.NodeName "label")
                        attrs
                        (Internal.Unkeyed [ labelElement, input ])

                Internal.Behind ->
                    Internal.element
                        Internal.asRow
                        (Internal.NodeName "label")
                        attrs
                        (Internal.Unkeyed [ labelElement, input ])


{-| Add choices to your radio and select menus.
-}
type Option value msg
    = Option value (OptionState -> Element msg)


{-| -}
type OptionState
    = Idle
    | Focused
    | Selected


{-| -}
option : value -> Element msg -> Option value msg
option val txt =
    Option val (defaultRadioOption txt)


{-| -}
optionWith : value -> (OptionState -> Element msg) -> Option value msg
optionWith val view =
    Option val view


{-|

    Input.radio
        [ padding 10
        , spacing 20
        ]
        { onChange = ChooseLunch
        , selected = Just model.lunch
        , label = Input.labelAbove (text "Lunch")
        , options =
            [ Input.styledChoice Burrito <|
                \selected ->
                    Element.row
                        [ spacing 5 ]
                        [ el None [] <|
                            if selected then
                                text ":D"
                            else
                                text ":("
                        , text "burrito"
                        ]
            , Input.option Taco (text "Taco!")
            , Input.option Gyro (text "Gyro")
            ]
        }

-}
radio :
    List (Attribute msg)
    ->
        { onChange : option -> msg
        , options : List (Option option msg)
        , selected : Maybe option
        , label : Label msg
        }
    -> Element msg
radio =
    radioHelper Column


{-| Same as radio, but displayed as a row
-}
radioRow :
    List (Attribute msg)
    ->
        { onChange : option -> msg
        , options : List (Option option msg)
        , selected : Maybe option
        , label : Label msg
        }
    -> Element msg
radioRow =
    radioHelper Row


defaultRadioOption : Element msg -> OptionState -> Element msg
defaultRadioOption optionLabel status =
    Element.row
        [ Element.spacing 10
        , Element.alignLeft
        , Element.width Element.shrink
        ]
        [ Element.el
            [ Element.width (Element.px 14)
            , Element.height (Element.px 14)
            , Background.color white
            , Border.rounded 7
            , case status of
                Selected ->
                    Internal.htmlClass "focusable"

                _ ->
                    Internal.NoAttribute

            -- , Border.shadow <|
            --     -- case status of
            --     --     Idle ->
            --     --         { offset = ( 0, 0 )
            --     --         , blur =
            --     --             1
            --     --         , color = Color.rgb 235 235 235
            --     --         }
            --     --     Focused ->
            --     --         { offset = ( 0, 0 )
            --     --         , blur =
            --     --             0
            --     --         , color = Color.rgba 235 235 235 0
            --     --         }
            --     --     Selected ->
            --     { offset = ( 0, 0 )
            --     , blur =
            --         1
            --     , color = Color.rgba 235 235 235 0
            --     }
            , Border.width <|
                case status of
                    Idle ->
                        1

                    Focused ->
                        1

                    Selected ->
                        5
            , Border.color <|
                case status of
                    Idle ->
                        Element.rgb (208 / 255) (208 / 255) (208 / 255)

                    Focused ->
                        Element.rgb (208 / 255) (208 / 255) (208 / 255)

                    Selected ->
                        Element.rgb (59 / 255) (153 / 255) (252 / 255)
            ]
            Element.none
        , Element.el [ Element.width Element.fill, Internal.htmlClass "unfocusable" ] optionLabel
        ]


radioHelper :
    Orientation
    -> List (Attribute msg)
    ->
        { onChange : option -> msg
        , options : List (Option option msg)
        , selected : Maybe option
        , label : Label msg
        }
    -> Element msg
radioHelper orientation attrs input =
    let
        renderOption (Option val view) =
            let
                status =
                    if Just val == input.selected then
                        Selected
                    else
                        Idle
            in
            Element.el
                [ Element.pointer
                , case orientation of
                    Row ->
                        Element.width Element.shrink

                    Column ->
                        Element.width Element.fill
                , Events.onClick (input.onChange val)
                , case status of
                    Selected ->
                        Internal.Attr <|
                            Html.Attributes.attribute "aria-checked"
                                "true"

                    _ ->
                        Internal.Attr <|
                            Html.Attributes.attribute "aria-checked"
                                "false"
                , Internal.Attr <|
                    Html.Attributes.attribute "role" "radio"
                ]
                (view status)

        optionArea =
            case orientation of
                Row ->
                    row attrs
                        (List.map renderOption input.options)

                Column ->
                    column attrs
                        (List.map renderOption input.options)

        prevNext =
            case input.options of
                [] ->
                    Nothing

                (Option val _) :: _ ->
                    List.foldl track ( NotFound, val, val ) input.options
                        |> (\( found, b, a ) ->
                                case found of
                                    NotFound ->
                                        Just ( b, val )

                                    BeforeFound ->
                                        Just ( b, val )

                                    _ ->
                                        Just ( b, a )
                           )

        track opt ( found, prev, nxt ) =
            case opt of
                Option val _ ->
                    case found of
                        NotFound ->
                            if Just val == input.selected then
                                ( BeforeFound, prev, nxt )
                            else
                                ( found, val, nxt )

                        BeforeFound ->
                            ( AfterFound, prev, val )

                        AfterFound ->
                            ( found, prev, nxt )

        inputVisible =
            List.isEmpty <|
                Internal.get attrs <|
                    \attr ->
                        case attr of
                            Internal.StyleClass _ (Internal.Transparency _ _) ->
                                True

                            Internal.Class _ "hidden" ->
                                True

                            _ ->
                                False

        labelVisible =
            case input.label of
                Label _ labelAttrs _ ->
                    List.isEmpty <|
                        Internal.get labelAttrs <|
                            \attr ->
                                case attr of
                                    Internal.StyleClass _ (Internal.Transparency _ _) ->
                                        True

                                    Internal.Class _ "hidden" ->
                                        True

                                    _ ->
                                        False

        hideIfEverythingisInvisible =
            if not labelVisible && not inputVisible then
                let
                    pseudos =
                        List.filterMap
                            (\attr ->
                                case attr of
                                    Internal.StyleClass _ style ->
                                        case style of
                                            Internal.PseudoSelector pseudo styles ->
                                                let
                                                    transparent =
                                                        List.filter forTransparency styles

                                                    forTransparency psuedoStyle =
                                                        case psuedoStyle of
                                                            Internal.Transparency _ _ ->
                                                                True

                                                            _ ->
                                                                False

                                                    flag =
                                                        case pseudo of
                                                            Internal.Hover ->
                                                                Flag.hover

                                                            Internal.Focus ->
                                                                Flag.focus

                                                            Internal.Active ->
                                                                Flag.active
                                                in
                                                case transparent of
                                                    [] ->
                                                        Nothing

                                                    _ ->
                                                        Just <| Internal.StyleClass flag <| Internal.PseudoSelector pseudo transparent

                                            _ ->
                                                Nothing

                                    _ ->
                                        Nothing
                            )
                            attrs
                in
                Internal.StyleClass Flag.transparency (Internal.Transparency "transparent" 1.0) :: pseudos
            else
                []

        events =
            Internal.get
                attrs
            <|
                \attr ->
                    case attr of
                        Internal.Width (Internal.Fill _) ->
                            True

                        Internal.Height (Internal.Fill _) ->
                            True

                        Internal.Attr _ ->
                            True

                        _ ->
                            False
    in
    applyLabel
        (List.filterMap identity
            [ Just Element.alignLeft
            , Just (tabindex 0)
            , Just (Internal.htmlClass "focus")
            , Just Region.announce
            , Just <|
                Internal.Attr <|
                    Html.Attributes.attribute "role" "radiogroup"
            , case prevNext of
                Nothing ->
                    Nothing

                Just ( prev, next ) ->
                    Just
                        (onKeyLookup <|
                            \code ->
                                if code == leftArrow then
                                    Just (input.onChange prev)
                                else if code == upArrow then
                                    Just (input.onChange prev)
                                else if code == rightArrow then
                                    Just (input.onChange next)
                                else if code == downArrow then
                                    Just (input.onChange next)
                                else if code == space then
                                    case input.selected of
                                        Nothing ->
                                            Just (input.onChange prev)

                                        _ ->
                                            Nothing
                                else
                                    Nothing
                        )
            ]
            ++ events
            ++ hideIfEverythingisInvisible
        )
        input.label
        optionArea


type Found
    = NotFound
    | BeforeFound
    | AfterFound


type Orientation
    = Row
    | Column


column : List (Attribute msg) -> List (Internal.Element msg) -> Internal.Element msg
column attributes children =
    Internal.element
        Internal.asColumn
        Internal.div
        (Element.height Element.shrink
            :: Element.width Element.fill
            :: attributes
        )
        (Internal.Unkeyed children)


row : List (Attribute msg) -> List (Internal.Element msg) -> Internal.Element msg
row attributes children =
    Internal.element
        Internal.asRow
        Internal.div
        (Element.width Element.fill
            :: attributes
        )
        (Internal.Unkeyed children)



{- Event Handlers -}


{-| -}
onEnter : msg -> Attribute msg
onEnter msg =
    onKey enter msg


{-| -}
onSpace : msg -> Attribute msg
onSpace msg =
    onKey space msg


{-| -}
onUpArrow : msg -> Attribute msg
onUpArrow msg =
    onKey upArrow msg


{-| -}
onRightArrow : msg -> Attribute msg
onRightArrow msg =
    onKey rightArrow msg


{-| -}
onLeftArrow : msg -> Attribute msg
onLeftArrow msg =
    onKey leftArrow msg


{-| -}
onDownArrow : msg -> Attribute msg
onDownArrow msg =
    onKey downArrow msg


enter : String
enter =
    "Enter"


tab : String
tab =
    "Tab"


delete : String
delete =
    "Delete"


backspace : String
backspace =
    "Backspace"


upArrow : String
upArrow =
    "ArrowUp"


leftArrow : String
leftArrow =
    "ArrowLeft"


rightArrow : String
rightArrow =
    "ArrowRight"


downArrow : String
downArrow =
    "ArrowDown"


space : String
space =
    " "


{-| -}
onKey : String -> msg -> Attribute msg
onKey desiredCode msg =
    let
        decode code =
            if code == desiredCode then
                Json.succeed msg
            else
                Json.fail "Not the enter key"

        isKey =
            Json.field "key" Json.string
                |> Json.andThen decode
    in
    Internal.Attr <|
        Html.Events.preventDefaultOn "keyup"
            (Json.map (\fired -> ( fired, True )) isKey)



-- preventKeydown : String -> a -> Attribute a
-- preventKeydown desiredCode msg =
--     let
--         decode code =
--             if code == desiredCode then
--                 Json.succeed msg
--             else
--                 Json.fail "Not the enter key"
--         isKey =
--             Json.field "key" Json.string
--                 |> Json.andThen decode
--     in
--     Events.onWithOptions "keydown"
--         { stopPropagation = False
--         , preventDefault = True
--         }
--         isKey


{-| -}
onKeyLookup : (String -> Maybe msg) -> Attribute msg
onKeyLookup lookup =
    let
        decode code =
            case lookup code of
                Nothing ->
                    Json.fail "No key matched"

                Just msg ->
                    Json.succeed msg

        isKey =
            Json.field "key" Json.string
                |> Json.andThen decode
    in
    Internal.Attr <| Html.Events.on "keyup" isKey


{-| -}
onFocusOut : msg -> Attribute msg
onFocusOut msg =
    Internal.Attr <| Html.Events.on "focusout" (Json.succeed msg)


{-| -}
onFocusIn : msg -> Attribute msg
onFocusIn msg =
    Internal.Attr <| Html.Events.on "focusin" (Json.succeed msg)


type_ : String -> Attribute msg
type_ =
    Internal.Attr << Html.Attributes.type_



-- checked : Bool -> Attribute msg
-- checked =
--     Internal.Attr << Html.Attributes.checked


selected : Bool -> Attribute msg
selected =
    Internal.Attr << Html.Attributes.selected


name : String -> Attribute msg
name =
    Internal.Attr << Html.Attributes.name


value : String -> Attribute msg
value =
    Internal.Attr << Html.Attributes.value


tabindex : Int -> Attribute msg
tabindex =
    Internal.Attr << Html.Attributes.tabindex


disabled : Bool -> Attribute msg
disabled =
    Internal.Attr << Html.Attributes.disabled


spellcheck : Bool -> Attribute msg
spellcheck =
    Internal.Attr << Html.Attributes.spellcheck


readonly : Bool -> Attribute msg
readonly =
    Internal.Attr << Html.Attributes.readonly


autofill : String -> Attribute msg
autofill =
    Internal.Attr << Html.Attributes.attribute "autocomplete"


{-| -}
focusedOnLoad : Attribute msg
focusedOnLoad =
    Internal.Attr <| Html.Attributes.autofocus True



{- Style Defaults -}


defaultTextBoxStyle : List (Attribute msg)
defaultTextBoxStyle =
    [ defaultTextPadding
    , Border.rounded 3
    , Border.color darkGrey
    , Background.color white
    , Border.width 1
    , Element.spacing 3
    ]


defaultTextPadding : Attribute msg
defaultTextPadding =
    Element.paddingXY 12 12


{-| -}
defaultCheckbox : Bool -> Element msg
defaultCheckbox checked =
    Element.el
        [ Internal.htmlClass "focusable"
        , Element.width (Element.px 14)
        , Element.height (Element.px 14)
        , Font.color white
        , Element.centerY
        , Font.size 9
        , Font.center
        , Border.rounded 3
        , Border.color <|
            if checked then
                Element.rgb (59 / 255) (153 / 255) (252 / 255)
            else
                Element.rgb (211 / 255) (211 / 255) (211 / 255)
        , Border.shadow <|
            { offset = ( 0, 0 )
            , blur = 1
            , size = 1
            , color =
                if checked then
                    Element.rgba (238 / 255) (238 / 255) (238 / 255) 0
                else
                    Element.rgb (238 / 255) (238 / 255) (238 / 255)
            }
        , Background.color <|
            if checked then
                Element.rgb (59 / 255) (153 / 255) (252 / 255)
            else
                white
        , Border.width <|
            if checked then
                0
            else
                1
        ]
        (if checked then
            Element.el
                [ Border.color white
                , Element.height (Element.px 6)
                , Element.width (Element.px 9)
                , Element.rotate (degrees -45)
                , Element.centerX
                , Element.centerY
                , Element.moveUp 1
                , Border.widthEach
                    { top = 0
                    , left = 2
                    , bottom = 2
                    , right = 0
                    }
                ]
                Element.none
         else
            Element.none
        )
