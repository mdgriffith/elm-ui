# A New Language for Layout and Interface

CSS and HTML are actually quite difficult to use when you're trying to do the layout and styling of a web page.

This library is a complete alternative to HTML and CSS.  Basically you can just write your app using this library and (mostly) never have to think about HTML and CSS again.

The high level goal of this library is to be a **design toolkit** that draws inspiration from the domains of design, layout, and typography, as opposed to drawing from the ideas as implemented in CSS and HTML.

This means:

* Writing and designing your layout and `view` should be as **simple and as fun** as possible.
* Many layout errors (like you'd run into using CSS) **are just not possible to write** in the first place!
* Everything should just **run fast.**
* **Layout and style are explicit and easy to modify.** CSS and HTML as tools for a layout language are hard to modify because there's no central place that represents your layout. You're generally forced to bounce back and forth between multiple definitions in multiple files in order to adjust layout, even though it's probably the most common thing you'll do.

However: All of this comes at the small cost of requiring [Flex](https://developer.mozilla.org/en-US/docs/Glossary/Flex).
If you are not sure whether your target browser supports it, check out [this support table](https://caniuse.com/#feat=flexbox).
But today most, if not all, major browsers allow the use of Flex, so you shouldn't have to worry about it in most cases.


[Try this live example on Ellie!](https://ellie-app.com/3f2n4J5RnT3a1)

```elm
import Element exposing (Element, el, text, row, alignRight, fill, width, rgb255, spacing, centerY, padding)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font


main = 
    Element.layout []
        myRowOfStuff

myRowOfStuff : Element msg
myRowOfStuff =
    row [ width fill, centerY, spacing 30 ]
        [ myElement
        , myElement
        , el [ alignRight ] myElement
        ]


myElement : Element msg
myElement =
    el
        [ Background.color (rgb255 240 0 245)
        , Font.color (rgb255 255 255 255)
        , Border.rounded 3
        , padding 30
        ]
        (text "stylish!")
```




## History

The work is based off of a rewrite of the [Style Elements](https://github.com/mdgriffith/style-elements) library.  A lot of that work was originally released under the [Stylish Elephants](https://github.com/mdgriffith/stylish-elephants) project.






