![](https://github.com/mdgriffith/elm-ui/workflows/Test%20Suite/badge.svg)


Check out the talk that goes with the library, [Building a Better Design Toolkit](https://www.youtube.com/watch?v=Ie-gqwSHQr0&t=2s)

# A New Language for Layout and Interface

CSS and HTML are actually quite difficult to use when you're trying to do the layout and styling of a web page.

This library is a complete alternative to HTML and CSS.  Basically you can just write your app using this library and (mostly) never have to think about HTML and CSS again.

The high level goal of this library is to be a **design toolkit** that draws inspiration from the domains of design, layout, and typography, as opposed to drawing from the ideas as implemented in CSS and HTML.

This means:

* Writing and designing your layout and `view` should be as **simple and as fun** as possible.
* Many layout errors (like you'd run into using CSS) **are just not possible to write** in the first place!
* Everything should just **run fast.**
* **Layout and style are explicit and easy to modify.** CSS and HTML as tools for a layout language are hard to modify because there's no central place that represents your layout. You're generally forced to bounce back and forth between multiple definitions in multiple files in order to adjust layout, even though it's probably the most common thing you'll do.


[Try this live example on Ellie!](https://ellie-app.com/7Cw4VCyr3RGa1)

```elm
module Main exposing (..)

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

# Join the Elm UI Slack!

First, if you have a question about how to do something with the library, join `#elm-ui` on the [Elm Slack](https://elmlang.herokuapp.com/)!  There are usually a number of people who are willing to help out, myself included.

## History

The work is based off of a rewrite of the [Style Elements](https://github.com/mdgriffith/style-elements) library.  A lot of that work was originally released under the [Stylish Elephants](https://github.com/mdgriffith/stylish-elephants) project.

## Community Cookbook

The community around `elm-ui` is maintaining a collection of examples called the [elm-ui-cookbook](https://github.com/rofrol/elm-ui-cookbook). If you are just starting out with `elm-ui`, or get stuck on specific things, this can be a great resource.

## Contributing

Want to help out fixing bugs or reporting issues?

Please add issues you find, and if you want to verify code you want to contribute, please read how to run the tests [here](https://github.com/mdgriffith/elm-ui/blob/master/notes/RUNNING_TESTS.md).
