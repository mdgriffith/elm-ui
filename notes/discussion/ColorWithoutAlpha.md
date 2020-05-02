# A Design for Color without Alpha

Color is hard!

I've spent a decade and a half in web development and only now feel like I have some sort of handle on it.

What I've learned basically comes down to the fact that the two color spaces we're used to dealing with (`rgb` and `hsl`), are not actually that great for thinking about color.  Which is unfortunate.

So, what can we use instead?

Research on color perception in the 1920's led to the development of the [CIEXYZ colorspace](https://en.wikipedia.org/wiki/CIE_1931_color_space), which describes color in a way that is much closer to how humans perceive color.  Essentially they were able to model constants in their equations that literally represent some of the built-in values we have as humans to perceive color. 

How crazy is that?

(Skipping over the fact that there is variation in how people perceive color.)

There are a number of color spaces that are based on this initial research, including CIELAB(generally recommended for print), and CIELUV(generally recommended for light).  They are essentailly different ways to talk about the same color space.  Sorta like polar coordinates(r,θ) and cartesian coordiantes (x,y) can both represent a point.

The `L` in the above acronyms represents `Luminance`.

This is one of the really cool parts.  Two colors that have the same `Luminance`, will be equally "bright" to the human eye.

You might be thinking "well, what about the `lightness` channel in `HSL`, huh?".  Turns out it's not really based on anything! 

Here are two hsl colors with the same lightness:
![](http://lea.verou.me/wp-content/uploads/2020/04/image-4.png)

Do they look like the same "brightness"?

Unfortunately the L in HSL stands for Lies and we've been misled all along.

[This whole article on color spaces is worth a read if you got the time](http://lea.verou.me/2020/04/lch-colors-in-css-what-why-and-how/)


Ok, so, luminance is really cool. 

With a real `Luminance` factor you can
    1. Generate palettes of colors that work together in a consistent manner.
    2. Automatically know the difference in luminance between two colors.  Guess what that is.  It's a contrast calculation!  Like for accessibility!  How nice would that be if it was X - Y as opposed to some crazy math?
    3. Get an intuition for how colors will interact with each other.
    4. Generate gradients that aren't unexpectedly broken. (I have some examples of this, I'll dig them up later)
    5. Animate colors consistently.  Animating in rgb or hsl will cause color animation to look awful in different ways.

It really is a better world.

Ok, so how do we get there and what does this mean for elm-ui?


# Elm UI stuff

The above knowledge is hard won.  Many people are not aware that there are better colorspaces than rgb and hsl.

Color is hard.  In many cases, it will remain hard until people get a nice introduction to something based on CIEXYZ.

In elm, [we have a package for HSLuv](
https://package.elm-lang.org/packages/kuon/elm-hsluv/latest/), which you can use right now. It's great.

However!  We have one confouding factor, which is that we're used to bundling an `alpha` value with our colors.

The same math that makes rgb and hsl less than great is used to blend colors via alpha.

By bundling alpha with color, we're encouranging people to blend colors in an ad-hoc way when we could be providing them avenues to easily do it the right way. We have a whole programming language, we're not confined to only CSS anymore.

However!  Frontend development also involves talking to designers.  Designers usually provide rgb, hsl, or a hex version of rgb.

I now sorta view these as *interop formats*.

