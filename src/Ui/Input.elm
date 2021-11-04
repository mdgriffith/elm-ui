module Ui.Input exposing
    ( focusedOnLoad
    , checkbox, defaultCheckbox
    , text, multiline
    , Placeholder, placeholder
    , username, newPassword, currentPassword, email, search, spellChecked
    , sliderX, sliderY, Thumb, thumb, defaultThumb
    , radio, radioRow, Option, option, optionWith, OptionState(..)
    , Label, labelAbove, labelBelow, labelLeft, labelRight, labelHidden
    )

{-| Input elements have a lot of constraints!

We want all of our input elements to:

  - _Always be accessible_
  - _Behave intuitively_
  - _Be completely restyleable_

While these three goals may seem pretty obvious, Html and CSS have made it surprisingly difficult to achieve!

And incredibly difficult for developers to remember all the tricks necessary to make things work. If you've every tried to make a `<textarea>` be the height of it's content or restyle a radio button while maintaining accessibility, you may be familiar.

This module is intended to be accessible by default. You shouldn't have to wade through docs, articles, and books to find out [exactly how accessible your html actually is](https://www.powermapper.com/tests/screen-readers/aria/index.html).


# Focus Styling

All Elements can be styled on focus by using [`Ui.focusStyle`](Element#focusStyle) to set a global focus style or [`Ui.focused`](Element#focused) to set a focus style individually for an Ui.

@docs focusedOnLoad


# Checkboxes

A checkbox requires you to store a `Bool` in your model.

This is also the first input element that has a [`required label`](#Label).

    import Ui exposing (text)
    import Ui.Input

    type Msg
        = GuacamoleChecked Bool

    view model =
        Ui.Input.checkbox []
            { onChange = GuacamoleChecked
            , icon = Ui.Input.defaultCheckbox
            , checked = model.guacamole
            , label =
                Ui.Input.labelRight []
                    (text "Do you want Guacamole?")
            }

@docs checkbox, defaultCheckbox


# Text

@docs text, multiline

@docs Placeholder, placeholder


## Text with autofill

If we want to play nicely with a browser's ability to autofill a form, we need to be able to give it a hint about what we're expecting.

The following inputs are very similar to `Input.text`, but they give the browser a hint to allow autofill to work correctly.

@docs username, newPassword, currentPassword, email, search, spellChecked


# Sliders

A slider is great for choosing between a range of numerical values.

  - **thumb** - The icon that you click and drag to change the value.
  - **track** - The line behind the thumb denoting where you can slide to.

@docs sliderX, sliderY, Thumb, thumb, defaultThumb


# Radio Selection

The fact that we still call this a radio selection is fascinating. I can't remember the last time I actually used an honest-to-goodness button on a radio. Chalk it up along with the floppy disk save icon or the word [Dashboard](https://en.wikipedia.org/wiki/Dashboard).

Perhaps a better name would be `Input.chooseOne`, because this allows you to select one of a set of options!

Nevertheless, here we are. Here's how you put one together

    Input.radio
        [ padding 10
        , spacing 20
        ]
        { onChange = ChooseLunch
        , selected = Just model.lunch
        , label = Input.labelAbove [] (text "Lunch")
        , options =
            [ Input.option Burrito (text "Burrito")
            , Input.option Taco (text "Taco!")
            , Input.option Gyro (text "Gyro")
            ]
        }

**Note** we're using `Input.option`, which will render the default radio icon you're probably used to. If you want compeltely custom styling, use `Input.optionWith`!

@docs radio, radioRow, Option, option, optionWith, OptionState


# Labels

Every input has a required `Label`.

@docs Label, labelAbove, labelBelow, labelLeft, labelRight, labelHidden


# Form Elements

You might be wondering where something like `<form>` is.

What I've found is that most people who want `<form>` usually want it for the [implicit submission behavior](https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#implicit-submission) or to be clearer, they want to do something when the `Enter` key is pressed.

Instead of implicit submission behavior, [try making an `onEnter` event handler like in this Ellie Example](https://ellie-app.com/5X6jBKtxzdpa1). Then everything is explicit!

And no one has to look up obtuse html documentation to understand the behavior of their code :).


# File Inputs

Presently, elm-ui does not expose a replacement for `<input type="file">`; in the meantime, an `Input.button` and `elm/file`'s `File.Select` may meet your needs.


# Disabling Inputs

You also might be wondering how to disable an input.

Disabled inputs can be a little problematic for user experience, and doubly so for accessibility. This is because it's now your priority to inform the user _why_ some field is disabled.

If an input is truly disabled, meaning it's not focusable or doesn't send off a `Msg`, you actually lose your ability to help the user out! For those wary about accessibility [this is a big problem.](https://ux.stackexchange.com/questions/103239/should-disabled-elements-be-focusable-for-accessibility-purposes)

Here are some alternatives to think about that don't involve explicitly disabling an input.

**Disabled Buttons** - Change the `Msg` it fires, the text that is rendered, and optionally set a `Region.description` which will be available to screen readers.

    import Ui.Input as Input
    import Ui.Region as Region

    myButton ready =
        if ready then
            Input.button
                [ Background.color blue
                ]
                { onPress =
                    Just SaveButtonPressed
                , label =
                    text "Save blog post"
                }

        else
            Input.button
                [ Background.color grey
                , Region.description
                    "A publish date is required before saving a blogpost."
                ]
                { onPress =
                    Just DisabledSaveButtonPressed
                , label =
                    text "Save Blog "
                }

Consider showing a hint if `DisabledSaveButtonPressed` is sent.

For other inputs such as `Input.text`, consider simply rendering it in a normal `paragraph` or `el` if it's not editable.

Alternatively, see if it's reasonable to _not_ display an input if you'd normally disable it. Is there an option where it's only visible when it's editable?

-}

import Html
import Html.Attributes
import Html.Events
import Internal.Flag as Flag2
import Internal.Model2 as Two
import Internal.Style.Generated exposing (classes)
import Internal.Style2 as Style
import Json.Decode as Json
import Json.Encode as Encode
import Ui exposing (Attribute, Element)
import Ui.Accessibility as Region2
import Ui.Background as Background2
import Ui.Border as Border2
import Ui.Events as Events2
import Ui.Font as Font2


{-| -}
type Placeholder id msg
    = Placeholder (List (Attribute msg)) (Element msg)


white2 : Ui.Color
white2 =
    Ui.rgb 255 255 255


darkGrey2 : Ui.Color
darkGrey2 =
    Ui.rgb 186 189 182


charcoal2 : Ui.Color
charcoal2 =
    Ui.rgb
        136
        138
        133


{-| -}
placeholder : List (Attribute msg) -> Element msg -> Placeholder id msg
placeholder =
    Placeholder


type LabelLocation
    = OnRight
    | OnLeft
    | Above
    | Below


{-| -}
type Label msg
    = Label LabelLocation (List (Attribute msg)) (Element msg)
    | HiddenLabel String


{-| -}
labelRight : List (Attribute msg) -> Element msg -> Label msg
labelRight =
    Label OnRight


{-| -}
labelLeft : List (Attribute msg) -> Element msg -> Label msg
labelLeft =
    Label OnLeft


{-| -}
labelAbove : List (Attribute msg) -> Element msg -> Label msg
labelAbove =
    Label Above


{-| -}
labelBelow : List (Attribute msg) -> Element msg -> Label msg
labelBelow =
    Label Below


{-| Sometimes you may need to have a label which is not visible, but is still accessible to screen readers.

Seriously consider a visible label before using this.

The situations where a hidden label makes sense:

  - A searchbar with a `search` button right next to it.
  - A `table` of inputs where the header gives the label.

Basically, a hidden label works when there are other contextual clues that sighted people can pick up on.

-}
labelHidden : String -> Label msg
labelHidden =
    HiddenLabel


hiddenLabelAttribute2 : Label msg -> Ui.Attribute a
hiddenLabelAttribute2 label =
    case label of
        HiddenLabel textLabel ->
            Region2.description textLabel

        Label _ _ _ ->
            Two.noAttr


{-|

  - **onChange** - The `Msg` to send.
  - **icon** - The checkbox icon to show. This can be whatever you'd like, but `Input.defaultCheckbox` is included to get you started.
  - **checked** - The current checked state.
  - **label** - The [`Label`](#Label) for this checkbox

-}
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
            [ if isHiddenLabel label then
                Two.noAttr

              else
                Ui.spacing 6
            , Two.attribute (Html.Events.onClick (onChange (not checked)))
            , Region2.announce
            , onKeyLookup2 <|
                \code ->
                    if code == enter then
                        Just <| onChange (not checked)

                    else if code == space then
                        Just <| onChange (not checked)

                    else
                        Nothing
            , Two.attribute (Html.Attributes.tabindex 0)
            , Ui.pointer
            , Ui.alignLeft
            , Ui.width Ui.fill
            ]
                ++ attrs
    in
    applyLabel attributes
        label
        (Two.element
            Two.AsEl
            [ Two.attribute <|
                Html.Attributes.attribute "role" "checkbox"
            , Two.attribute <|
                Html.Attributes.attribute "aria-checked" <|
                    if checked then
                        "true"

                    else
                        "false"
            , hiddenLabelAttribute2 label
            , Ui.centerY
            , Ui.height Ui.fill

            -- TODO: SHOULD BE WIDTH SHRINK
            ]
            [ icon checked
            ]
        )


{-| -}
type Thumb msg
    = Thumb (List (Attribute msg))


{-| -}
thumb : List (Attribute msg) -> Thumb msg
thumb =
    Thumb


{-| -}
defaultThumb : Thumb msg
defaultThumb =
    Thumb
        [ Ui.width (Ui.px 16)
        , Ui.height (Ui.px 16)
        , Border2.rounded 8
        , Border2.width 1
        , Border2.color (Ui.rgb 100 100 100)
        , Background2.color (Ui.rgb 255 255 255)
        ]


{-| A slider input, good for capturing float values.
Input.slider
[ Ui.height (Ui.px 30)
-- Here is where we're creating/styling the "track"
, Ui.behindContent
(Ui.el
[ Ui.width Ui.fill
, Ui.height (Ui.px 2)
, Ui.centerY
, Background.color grey
, Border.rounded 2
][ Ui.width Ui.fill
, Ui.height (Ui.px 2)
, Ui.centerY
, Background.color grey
, Border.rounded 2
]
Ui.none
)
][ Ui.height (Ui.px 30)
-- Here is where we're creating/styling the "track"
, Ui.behindContent
(Ui.el
[ Ui.width Ui.fill
, Ui.height (Ui.px 2)
, Ui.centerY
, Background.color grey
, Border.rounded 2
]
Ui.none
)
]
{ onChange = AdjustValue
, label =
Input.labelAbove []
(text "My Slider Value")
, min = 0
, max = 75
, step = Nothing
, value = model.sliderValue
, thumb =
Input.defaultThumb
}
`Ui.behindContent` is used to render the track of the slider. Without it, no track would be rendered. The `thumb` is the icon that you can move around.
The slider can be vertical or horizontal depending on the width/height of the slider.

  - `height fill` and `width (px someWidth)` will cause the slider to be vertical.
  - `height (px someHeight)` and `width (px someWidth)` where `someHeight` > `someWidth` will also do it.
  - otherwise, the slider will be horizontal.
    **Note** If you want a slider for an `Int` value:
  - set `step` to be `Just 1`, or some other whole value
  - `value = toFloat model.myInt`
  - And finally, round the value before making a message `onChange = round >> AdjustValue`

-}
sliderX :
    List (Ui.Attribute msg)
    ->
        { onChange : Float -> msg
        , label : Label msg
        , min : Float
        , max : Float
        , value : Float
        , thumb : Thumb msg
        , step : Maybe Float
        }
    -> Two.Element msg
sliderX attributes input =
    let
        (Thumb thumbAttributes) =
            input.thumb

        factor =
            (input.value - input.min)
                / (input.max - input.min)
    in
    applyLabel
        ([ Region2.announce
         , Ui.width Ui.fill
         , Ui.height Ui.fill
         ]
            ++ List.filter
                (Two.hasFlags
                    [ Flag2.width
                    , Flag2.height
                    , Flag2.spacing
                    ]
                )
                attributes
        )
        input.label
        (Ui.row
            [ Ui.width Ui.fill
            ]
            [ Two.elementAs Html.input
                Two.AsEl
                [ hiddenLabelAttribute2 input.label
                , Two.class (Style.classes.slider ++ " focusable-parent")
                , Two.attribute
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
                , Two.attribute
                    (Html.Attributes.type_ "range")
                , Two.attribute <|
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
                , Two.attribute
                    (Html.Attributes.min (String.fromFloat input.min))
                , Two.attribute
                    (Html.Attributes.max (String.fromFloat input.max))
                , Two.attribute <|
                    Html.Attributes.value (String.fromFloat input.value)
                , Ui.width Ui.fill
                , Ui.height Ui.fill
                ]
                []
            , Ui.el
                (Ui.width Ui.fill
                    :: Ui.height (Ui.px 20)
                    :: attributes
                    -- This is after `attributes` because the thumb should be in front of everything.
                    ++ [ Ui.behindContent
                            (viewThumb factor thumbAttributes)
                       ]
                )
                Ui.none
            ]
        )


sliderY :
    List (Ui.Attribute msg)
    ->
        { onChange : Float -> msg
        , label : Label msg
        , min : Float
        , max : Float
        , value : Float
        , thumb : Thumb msg
        , step : Maybe Float
        }
    -> Two.Element msg
sliderY attrs input =
    let
        attributes =
            Ui.height (Ui.px 200)
                :: Ui.width (Ui.px 20)
                :: attrs

        (Thumb thumbAttributes) =
            input.thumb

        factor =
            (input.value - input.min)
                / (input.max - input.min)
    in
    applyLabel
        ([ Region2.announce
         , Ui.width Ui.fill
         , Ui.height Ui.fill
         ]
            ++ List.filter
                (Two.hasFlags
                    [ Flag2.width
                    , Flag2.height
                    , Flag2.spacing
                    ]
                )
                attributes
        )
        input.label
        (Ui.row
            [ Ui.width Ui.fill
            ]
            [ Two.elementAs Html.input
                Two.AsEl
                [ hiddenLabelAttribute2 input.label
                , Two.class (Style.classes.slider ++ " focusable-parent")
                , Two.attribute <|
                    Html.Attributes.attribute "orient" "vertical"
                , Two.attribute
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
                , Two.attribute
                    (Html.Attributes.type_ "range")
                , Two.attribute <|
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
                , Two.attribute
                    (Html.Attributes.min (String.fromFloat input.min))
                , Two.attribute
                    (Html.Attributes.max (String.fromFloat input.max))
                , Two.attribute <|
                    Html.Attributes.value (String.fromFloat input.value)
                , Ui.width Ui.fill
                , Ui.height Ui.fill
                ]
                []
            , Ui.el
                (Ui.height Ui.fill
                    :: Ui.width (Ui.px 20)
                    :: attributes
                    -- This is after `attributes` because the thumb should be in front of everything.
                    ++ [ Ui.behindContent
                            (viewVerticalThumb factor thumbAttributes)
                       ]
                )
                Ui.none
            ]
        )


viewThumb factor thumbAttributes =
    Ui.row
        [ Ui.width Ui.fill
        , Ui.height Ui.fill
        , Ui.centerY
        ]
        [ Ui.el
            [ Ui.htmlAttribute
                (Html.Attributes.style
                    "flex-grow"
                    (String.fromInt (round (factor * 5000)))
                )
            ]
            Ui.none
        , Ui.el
            (Ui.centerY
                :: thumbAttributes
            )
            Ui.none
        , Ui.el
            [ Ui.htmlAttribute
                (Html.Attributes.style
                    "flex-grow"
                    (String.fromInt (round ((1 - factor) * 5000)))
                )
            ]
            Ui.none
        ]


viewVerticalThumb factor thumbAttributes =
    Ui.column
        [ Ui.width Ui.fill
        , Ui.height Ui.fill
        , Ui.centerX
        ]
        [ Ui.el
            [ Ui.htmlAttribute
                (Html.Attributes.style
                    "flex-grow"
                    (String.fromInt (round ((1 - factor) * 5000)))
                )
            ]
            Ui.none
        , Ui.el
            (Ui.centerX
                :: thumbAttributes
            )
            Ui.none
        , Ui.el
            [ Ui.htmlAttribute
                (Html.Attributes.style
                    "flex-grow"
                    (String.fromInt (round (factor * 5000)))
                )
            ]
            Ui.none
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
type alias Text2 id msg =
    { onChange : String -> msg
    , text : String
    , placeholder : Maybe (Placeholder id msg)
    , label : Label msg
    }


{-| -}
textHelper2 : TextInput -> List (Ui.Attribute msg) -> Text2 id msg -> Two.Element msg
textHelper2 textInput attrs textOptions =
    {- General overview:

          - padding is used by the text area and negated in order to make the padded area clickable.

       We specifically do property redistribution using `redistribute`, which

           redistribute them to the parent, the input, or the cover.

               - fullParent -> Wrapper around label and input
               - parent -> parent of wrapper
               - wrapper -> the element that is here to take up space.
               - cover -> things like placeholders or text areas which are layered on top of input.
               - input -> actual input element

    -}
    let
        withDefaults =
            defaultTextBoxStyle2 ++ attrs

        redistributed =
            redistribute2 textInput.type_ withDefaults

        inputElement =
            Two.elementAs
                (case textInput.type_ of
                    TextInputNode inputType ->
                        Html.input

                    TextArea ->
                        Html.textarea
                )
                Two.AsEl
                ((case textInput.type_ of
                    TextInputNode inputType ->
                        -- Note: Due to a weird edgecase in...Edge...
                        -- `type` needs to come _before_ `value`
                        -- More reading: https://github.com/mdgriffith/elm-ui/pull/94/commits/4f493a27001ccc3cf1f2baa82e092c35d3811876
                        [ Two.attribute (Html.Attributes.type_ inputType)
                        , Two.class classes.inputText
                        ]

                    TextArea ->
                        [ Two.classWith Flag2.overflow Style.classes.clip
                        , Ui.height Ui.fill
                        , Two.class classes.inputMultiline

                        -- , calcMoveToCompensateForPadding withDefaults
                        -- The only reason we do this padding trick is so that when the user clicks in the padding,
                        -- that the cursor will reset correctly.
                        -- This could probably be combined with the above `calcMoveToCompensateForPadding`
                        , Two.attribute (Html.Attributes.style "box-sizing" "content-box")
                        ]
                 )
                    ++ [ Two.attribute (Html.Attributes.value textOptions.text)
                       , Two.attribute (Html.Events.onInput textOptions.onChange)
                       , hiddenLabelAttribute2 textOptions.label
                       , Two.attribute (Html.Attributes.spellcheck textInput.spellchecked)
                       , case textInput.autofill of
                            Nothing ->
                                Two.noAttr

                            Just fill ->
                                Two.attribute (Html.Attributes.attribute "autocomplete" fill)
                       ]
                    ++ redistributed.input
                )
                []

        wrappedInput =
            case textInput.type_ of
                TextArea ->
                    -- textarea with height-content means that
                    -- the input element is rendered `inFront` with a transparent background
                    -- Then the input text is rendered as the space filling Ui.
                    Two.element
                        Two.AsEl
                        ([ Ui.width Ui.fill
                         , Two.class classes.focusedWithin
                         , Two.class classes.inputMultilineWrapper
                         ]
                            ++ redistributed.inputParent
                        )
                        [ Two.element
                            Two.AsParagraph
                            ([ Ui.width Ui.fill
                             , Ui.height Ui.fill
                             , Ui.inFront inputElement
                             , Two.class classes.inputMultilineParent
                             ]
                                ++ redistributed.textAreaWrapper
                            )
                            (if textOptions.text == "" then
                                case textOptions.placeholder of
                                    Nothing ->
                                        -- Without this, firefox will make the text area lose focus
                                        -- if the input is empty and you mash the keyboard
                                        [ Ui.text "\u{00A0}"
                                        ]

                                    Just place ->
                                        [ renderPlaceholder redistributed.placeholder place (textOptions.text == "")
                                        ]

                             else
                                [ Ui.html
                                    (Html.span (Html.Attributes.class classes.inputMultilineFiller :: redistributed.textAreaFiller)
                                        -- We append a non-breaking space to the end of the content so that newlines don't get chomped.
                                        [ Html.text (textOptions.text ++ "\u{00A0}")
                                        ]
                                    )
                                ]
                            )
                        ]

                TextInputNode inputType ->
                    Two.element
                        Two.AsEl
                        (Ui.width Ui.fill
                            :: Two.class classes.focusedWithin
                            :: Two.class Style.classes.inputTextInputWrapper
                            :: List.concat
                                [ redistributed.inputParent
                                , case textOptions.placeholder of
                                    Nothing ->
                                        []

                                    Just place ->
                                        [ Ui.behindContent
                                            (renderPlaceholder redistributed.placeholder place (textOptions.text == ""))
                                        ]
                                ]
                        )
                        [ inputElement ]
    in
    applyLabel
        (Two.classWith Flag2.cursor classes.cursorText
            :: Two.class Style.classes.inputTextParent
            :: (if isHiddenLabel textOptions.label then
                    Two.noAttr

                else
                    Ui.spacing
                        5
               )
            :: Region2.announce
            :: redistributed.parent
        )
        textOptions.label
        wrappedInput


renderPlaceholder attrs (Placeholder placeholderAttrs placeholderEl) on =
    Ui.el
        (attrs
            ++ [ Font2.color charcoal2
               , Two.class
                    (Style.classes.noTextSelection
                        ++ " "
                        ++ Style.classes.passPointerEvents
                    )
               , Two.classWith Flag2.overflow Style.classes.clip
               , Ui.height Ui.fill
               , Ui.width Ui.fill
               , Ui.alpha
                    (if on then
                        1

                     else
                        0
                    )
               ]
            ++ placeholderAttrs
        )
        placeholderEl



-- {-| Because textareas are now shadowed, where they're rendered twice,
-- we to move the literal text area up because spacing is based on line height.
-- -}
-- calcMoveToCompensateForPadding : List (Attribute msg) -> Attribute msg
-- calcMoveToCompensateForPadding attrs =
--     let
--         gatherSpacing attr found =
--             case attr of
--                 Internal.StyleClass _ (Internal.SpacingStyle _ x y) ->
--                     case found of
--                         Nothing ->
--                             Just y
--                         _ ->
--                             found
--                 _ ->
--                     found
--     in
--     case List.foldr gatherSpacing Nothing attrs of
--         Nothing ->
--             Internal.NoAttribute
--         Just vSpace ->
--             Ui.moveUp (toFloat (floor (toFloat vSpace / 2)))


{-| Given the list of attributes provided to `Input.multiline` or `Input.text`,

redistribute them to the parent, the input, or the cover.

  - fullParent -> Wrapper around label and input
  - parent -> parent of wrapper
  - wrapper -> the element that is here to take up space.
  - cover -> things like placeholders or text areas which are layered on top of input.
  - input -> actual input element

^^ old logic

----vv new logic

  - nearbys -> inputParent element
  - attributes -> `input`
  - styles and classes ->
    full parent (with special css to invalidate, and move styles to the proper places)

-}
redistribute2 :
    TextKind
    -> List (Ui.Attribute msg)
    ->
        { parent : List (Ui.Attribute msg)
        , inputParent : List (Ui.Attribute msg)
        , input : List (Ui.Attribute msg)
        , placeholder : List (Ui.Attribute msg)
        , textAreaWrapper : List (Ui.Attribute msg)
        , textAreaFiller : List (Html.Attribute msg)
        }
redistribute2 input attrs =
    List.foldl (redistributeOver2 input)
        { parent = []
        , inputParent = []
        , input = []
        , placeholder = []
        , textAreaWrapper = []
        , textAreaFiller = []
        }
        attrs
        |> (\redist ->
                { parent = List.reverse redist.parent
                , inputParent = List.reverse redist.inputParent
                , input = List.reverse redist.input
                , placeholder = List.reverse redist.placeholder
                , textAreaWrapper = List.reverse redist.textAreaWrapper
                , textAreaFiller = List.reverse redist.textAreaFiller
                }
           )


{-|

    --> full parent
    <label class="ctxt spacing-12-12 s c wf lbl" aria-live="polite">
      --> actual label
      <div class="font-size-14 s e">
        <div class="s t wf hf">Username</div>
      </div>

      --> parent (wrapper only applies to multiline text)
      <div class="pad-0-3060-0-3060 br-3 bc-186-189-182-255 bg-255-255-255-255 b-1 hc spacing-12-12 s e wf focus-within">

        --> placeholder (cover)
        <div class="nb e bh">
          <div class="p-12 b-1 fc-136-138-133-255 cp bc-0-0-0-0 bg-0-0-0-0 hf transparency-0 s e wf notxt ppe">
            <div class="s t wf hf">username</div>
          </div>
        </div>

        --> actual input
        <input
          class="spacing-12-12 s e wf it"
          type="text"
          spellcheck="false"
          style="line-height: calc(1em + 24px); height: calc(1em + 24px);"
        />

        --> manually attached `nearby`
        <div class="nb e b">
          <div class="hc fc-204-0-0-255 font-size-14 ah ar s e wc mv-0-1530-0">
            <div class="s t wf hf">This one is wrong</div>
          </div>
        </div>
      </div>
    </label>

-}
redistributeOver2 :
    TextKind
    -> Ui.Attribute msg
    ->
        { parent :
            List (Ui.Attribute msg)
        , textAreaFiller : List (Html.Attribute b)
        , input : List (Ui.Attribute msg)
        , textAreaWrapper : List (Ui.Attribute msg)
        , inputParent : List (Ui.Attribute msg)
        , placeholder : List (Ui.Attribute msg)
        }
    ->
        { parent :
            List (Ui.Attribute msg)
        , textAreaFiller : List (Html.Attribute b)
        , input : List (Ui.Attribute msg)
        , textAreaWrapper : List (Ui.Attribute msg)
        , inputParent : List (Ui.Attribute msg)
        , placeholder : List (Ui.Attribute msg)
        }
redistributeOver2 input ((Two.Attribute attrDetails) as attr) els =
    case attrDetails.attr of
        Two.Spacing xSpace ySpace ->
            case input of
                TextArea ->
                    let
                        height =
                            Html.Attributes.style "height" ("calc(100% + " ++ String.fromInt ySpace ++ "px)")

                        lineHeight =
                            Html.Attributes.style "line-height" ("calc(1em + " ++ String.fromInt ySpace ++ "px)")
                    in
                    { els
                        | parent = attr :: els.parent
                        , textAreaFiller =
                            lineHeight
                                :: height
                                :: els.textAreaFiller
                        , input =
                            Ui.moveUp
                                (toFloat (floor (toFloat ySpace / 2)))
                                :: Two.attribute lineHeight
                                :: Two.attribute height
                                :: els.input
                        , textAreaWrapper = attr :: els.textAreaWrapper
                    }

                TextInputNode _ ->
                    { els
                        | parent = attr :: els.parent
                    }

        Two.Padding pad ->
            case input of
                TextArea ->
                    { els
                        | inputParent = attr :: els.inputParent
                        , placeholder = attr :: els.placeholder
                    }

                TextInputNode _ ->
                    { els
                        | inputParent =
                            Ui.paddingEach Two.emptyEdges
                                :: els.inputParent
                        , placeholder = attr :: els.placeholder
                        , input =
                            Two.attribute
                                (Html.Attributes.style "height"
                                    ("calc(1em + "
                                        ++ String.fromInt (pad.top + pad.bottom)
                                        ++ "px)"
                                    )
                                )
                                :: Two.attribute
                                    (Html.Attributes.style "line-height"
                                        ("calc(1em + "
                                            ++ String.fromInt (pad.top + pad.bottom)
                                            ++ "px)"
                                        )
                                    )
                                :: attr
                                :: els.input
                    }

        Two.BorderWidth _ ->
            { els
                | inputParent = attr :: els.inputParent
            }

        Two.Nearby _ _ ->
            { els | inputParent = attr :: els.inputParent }

        Two.NoAttribute ->
            els

        Two.OnPress _ ->
            { els | input = attr :: els.input }

        Two.Attr a ->
            { els
                | input = attr :: els.input
            }

        Two.Class _ ->
            { els | parent = attr :: els.parent }

        Two.FontSize _ ->
            { els | parent = attr :: els.parent }

        Two.Font _ ->
            { els | parent = attr :: els.parent }

        Two.WidthFill _ ->
            { els
                | parent = attr :: els.parent
            }

        Two.HeightFill _ ->
            { els
                | parent = attr :: els.parent
            }

        Two.Link _ ->
            els

        Two.TransformPiece _ _ ->
            { els | parent = attr :: els.parent }

        Two.ClassAndStyle _ _ _ ->
            { els
                | parent = attr :: els.parent
                , inputParent = attr :: els.inputParent
            }

        Two.ClassAndVarStyle _ _ ->
            { els
                | parent = attr :: els.parent
                , inputParent = attr :: els.inputParent
            }

        Two.ClassAndVar _ _ _ ->
            { els
                | parent = attr :: els.parent
                , inputParent = attr :: els.inputParent
            }

        Two.When _ _ ->
            { els | parent = attr :: els.parent }

        Two.WhenAll _ _ _ _ ->
            { els | parent = attr :: els.parent }

        Two.Animated _ _ ->
            { els | parent = attr :: els.parent }


{-| -}
text :
    List (Ui.Attribute msg)
    ->
        { onChange : String -> msg
        , text : String
        , placeholder : Maybe (Placeholder id msg)
        , label : Label msg
        }
    -> Two.Element msg
text =
    textHelper2
        { type_ = TextInputNode "text"
        , spellchecked = False
        , autofill = Nothing
        }


{-| If spell checking is available, this input will be spellchecked.
-}
spellChecked :
    List (Ui.Attribute msg)
    ->
        { onChange : String -> msg
        , text : String
        , placeholder : Maybe (Placeholder id msg)
        , label : Label msg
        }
    -> Two.Element msg
spellChecked =
    textHelper2
        { type_ = TextInputNode "text"
        , spellchecked = True
        , autofill = Nothing
        }


{-| -}
search :
    List (Ui.Attribute msg)
    ->
        { onChange : String -> msg
        , text : String
        , placeholder : Maybe (Placeholder id msg)
        , label : Label msg
        }
    -> Two.Element msg
search =
    textHelper2
        { type_ = TextInputNode "search"
        , spellchecked = False
        , autofill = Nothing
        }


{-| A password input that allows the browser to autofill.

It's `newPassword` instead of just `password` because it gives the browser a hint on what type of password input it is.

A password takes all the arguments a normal `Input.text` would, and also **show**, which will remove the password mask (e.g. `****` vs `pass1234`)

-}
newPassword :
    List (Ui.Attribute msg)
    ->
        { onChange : String -> msg
        , text : String
        , placeholder : Maybe (Placeholder id msg)
        , label : Label msg
        , show : Bool
        }
    -> Two.Element msg
newPassword attrs pass =
    textHelper2
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
    List (Ui.Attribute msg)
    ->
        { onChange : String -> msg
        , text : String
        , placeholder : Maybe (Placeholder id msg)
        , label : Label msg
        , show : Bool
        }
    -> Two.Element msg
currentPassword attrs pass =
    textHelper2
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
    List (Ui.Attribute msg)
    ->
        { onChange : String -> msg
        , text : String
        , placeholder : Maybe (Placeholder id msg)
        , label : Label msg
        }
    -> Two.Element msg
username =
    textHelper2
        { type_ = TextInputNode "text"
        , spellchecked = False
        , autofill = Just "username"
        }


{-| -}
email :
    List (Ui.Attribute msg)
    ->
        { onChange : String -> msg
        , text : String
        , placeholder : Maybe (Placeholder id msg)
        , label : Label msg
        }
    -> Two.Element msg
email =
    textHelper2
        { type_ = TextInputNode "email"
        , spellchecked = False
        , autofill = Just "email"
        }


{-| A multiline text input.

By default it will have a minimum height of one line and resize based on it's contents.

-}
multiline :
    List (Ui.Attribute msg)
    ->
        { onChange : String -> msg
        , text : String
        , placeholder : Maybe (Placeholder id msg)
        , label : Label msg
        , spellcheck : Bool
        }
    -> Two.Element msg
multiline attrs multi =
    textHelper2
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


isHiddenLabel label =
    case label of
        HiddenLabel _ ->
            True

        _ ->
            False


applyLabel : List (Ui.Attribute msg) -> Label msg -> Two.Element msg -> Two.Element msg
applyLabel attrs label input =
    case label of
        HiddenLabel labelText ->
            -- NOTE: This means that the label is applied outside of this function!
            -- It would be nice to unify this logic, but it's a little tricky
            Two.elementAs Html.label
                Two.AsColumn
                attrs
                [ input ]

        Label position labelAttrs labelChild ->
            let
                labelElement =
                    Two.element
                        Two.AsEl
                        labelAttrs
                        [ labelChild ]
            in
            case position of
                Above ->
                    Two.elementAs Html.label
                        Two.AsColumn
                        (Two.class classes.inputLabel :: attrs)
                        [ labelElement, input ]

                Below ->
                    Two.elementAs Html.label
                        Two.AsColumn
                        (Two.class classes.inputLabel :: attrs)
                        [ input, labelElement ]

                OnRight ->
                    Two.elementAs Html.label
                        Two.AsRow
                        (Two.class classes.inputLabel :: attrs)
                        [ input, labelElement ]

                OnLeft ->
                    Two.elementAs Html.label
                        Two.AsRow
                        (Two.class classes.inputLabel :: attrs)
                        [ labelElement, input ]


{-| -}
type Option value msg
    = Option value (OptionState -> Two.Element msg)


{-| -}
type OptionState
    = Idle
    | Focused
    | Selected


{-| Add a choice to your radio Ui. This will be rendered with the default radio icon.
-}
option : value -> Two.Element msg -> Option value msg
option val txt =
    Option val (defaultRadioOption txt)


{-| Customize exactly what your radio option should look like in different states.
-}
optionWith : value -> (OptionState -> Two.Element msg) -> Option value msg
optionWith val view =
    Option val view


{-| -}
radio :
    List (Ui.Attribute msg)
    ->
        { onChange : option -> msg
        , options : List (Option option msg)
        , selected : Maybe option
        , label : Label msg
        }
    -> Two.Element msg
radio =
    radioHelper2 Column


{-| Same as radio, but displayed as a row
-}
radioRow :
    List (Ui.Attribute msg)
    ->
        { onChange : option -> msg
        , options : List (Option option msg)
        , selected : Maybe option
        , label : Label msg
        }
    -> Two.Element msg
radioRow =
    radioHelper2 Row


defaultRadioOption : Two.Element msg -> OptionState -> Two.Element msg
defaultRadioOption optionLabel status =
    Ui.row
        [ Ui.spacing 10
        , Ui.alignLeft
        ]
        [ Ui.el
            [ Ui.width (Ui.px 14)
            , Ui.height (Ui.px 14)
            , Background2.color white2
            , Border2.rounded 7
            , case status of
                Selected ->
                    Two.class "focusable"

                _ ->
                    Two.noAttr

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
            , Border2.width <|
                case status of
                    Idle ->
                        1

                    Focused ->
                        1

                    Selected ->
                        5
            , Border2.color <|
                case status of
                    Idle ->
                        Ui.rgb 208 208 208

                    Focused ->
                        Ui.rgb 208 208 208

                    Selected ->
                        Ui.rgb 59 153 252
            ]
            Ui.none
        , Ui.el [ Ui.width Ui.fill, Two.class "unfocusable" ] optionLabel
        ]


radioHelper2 :
    Orientation
    -> List (Ui.Attribute msg)
    ->
        { onChange : option -> msg
        , options : List (Option option msg)
        , selected : Maybe option
        , label : Label msg
        }
    -> Two.Element msg
radioHelper2 orientation attrs input =
    let
        optionArea =
            case orientation of
                Row ->
                    Ui.row (Ui.width Ui.fill :: hiddenLabelAttribute2 input.label :: attrs)
                        (List.map (renderOption orientation input) input.options)

                Column ->
                    Ui.column (Ui.width Ui.fill :: hiddenLabelAttribute2 input.label :: attrs)
                        (List.map (renderOption orientation input) input.options)

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

        events =
            -- List.
            []

        --         Internal.get
        --             attrs
        --         <|
        --             \attr ->
        --                 case attr of
        --                     Internal.Width (Internal.Fill _) ->
        --                         True
        --                     Internal.Height (Internal.Fill _) ->
        --                         True
        --                     Internal.Attr _ ->
        --                         True
        --                     _ ->
        --                         False
    in
    applyLabel
        ([ Ui.alignLeft
         , Two.attribute (Html.Attributes.tabindex 0)
         , Two.class "focus"
         , Region2.announce
         , Two.attribute <|
            Html.Attributes.attribute "role" "radiogroup"
         , case prevNext of
            Nothing ->
                Two.class ""

            Just ( prev, next ) ->
                onKeyLookup2 <|
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
         ]
            ++ events
         -- ++ hideIfEverythingisInvisible
        )
        input.label
        optionArea


renderOption orientation input (Option val view) =
    let
        status =
            if Just val == input.selected then
                Selected

            else
                Idle
    in
    Ui.el
        [ Ui.pointer
        , case orientation of
            Row ->
                Two.noAttr

            Column ->
                Ui.width Ui.fill
        , Events2.onClick (input.onChange val)
        , case status of
            Selected ->
                Two.attribute <|
                    Html.Attributes.attribute "aria-checked"
                        "true"

            _ ->
                Two.attribute <|
                    Html.Attributes.attribute "aria-checked"
                        "false"
        , Two.attribute <|
            Html.Attributes.attribute "role" "radio"
        ]
        (view status)


type Found
    = NotFound
    | BeforeFound
    | AfterFound


type Orientation
    = Row
    | Column



{- Event Handlers -}


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
onKeyLookup2 : (String -> Maybe msg) -> Ui.Attribute msg
onKeyLookup2 lookup =
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
    Two.attribute <| Html.Events.on "keyup" isKey


{-| Attach this attribute to any `Input` that you would like to be automatically focused when the page loads.

You should only have a maximum of one per page.

-}
focusedOnLoad : Ui.Attribute msg
focusedOnLoad =
    Two.attribute <| Html.Attributes.autofocus True



{- Style Defaults -}


defaultTextBoxStyle2 : List (Ui.Attribute msg)
defaultTextBoxStyle2 =
    [ Ui.paddingXY 12 12
    , Border2.rounded 3
    , Border2.color darkGrey2
    , Background2.color white2
    , Border2.width 1
    , Ui.spacing 5
    , Ui.width Ui.fill

    -- TODO: SHOULD BE HEIGHT SHRINK
    ]


{-| The blue default checked box icon.

You'll likely want to make your own checkbox at some point that fits your design.

-}
defaultCheckbox : Bool -> Two.Element msg
defaultCheckbox checked =
    Ui.el
        [ Two.class "focusable"
        , Ui.width (Ui.px 14)
        , Ui.height (Ui.px 14)
        , Font2.color white2
        , Ui.centerY
        , Font2.size 9
        , Font2.center
        , Border2.rounded 3
        , Border2.color <|
            if checked then
                Ui.rgb 59 153 252

            else
                Ui.rgb 211 211 211
        , if checked then
            Ui.alpha 1

          else
            Border2.shadows
                [ { x = 0
                  , y = 0
                  , blur = 1
                  , size = 1
                  , color =
                        Ui.rgb 238 238 238
                  }
                ]
        , Background2.color <|
            if checked then
                Ui.rgb 59 153 252

            else
                white2
        , Border2.width <|
            if checked then
                0

            else
                1
        ]
        (if checked then
            Ui.el
                [ Border2.color white2
                , Ui.height (Ui.px 6)
                , Ui.width (Ui.px 9)
                , Ui.rotate (degrees -45)
                , Ui.centerX
                , Ui.centerY
                , Ui.moveUp 1
                , Border2.widthEach
                    { top = 0
                    , left = 2
                    , bottom = 2
                    , right = 0
                    }
                ]
                Ui.none

         else
            Ui.none
        )
