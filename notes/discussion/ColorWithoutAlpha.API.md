
# Possible API Changes


## Element.Font

    Font.color : Color -> Attribute msg

    -- Tempted to drop this one.
    -- People could still have transparent text using `Element.opacity`
    -- if they really want it
    Font.opacity : Float -> Attribute msg

    Font.shadow : 
        { offset : (Float, Float)
        , blur : Float
        , color : Color
        , opacity : Float
        } -> Attribute msg


## Element.Background

    Background.color : Color -> Attribute

    -- background opacity is commonly used when we have some text
    -- over an image background.
    Background.opacity : Float -> Attribute


For gradients, we can have opacity as a separate set of steps.
This actually makes it _easier_ to do something like a rainbow that linearly fades away.  We don't have to figure out the exact opacity that the 5th color has.

    Background.gradient : 
        { angle : Float
        , colors : List Color
        , opacity : List Float
        }

Do you ever have a gradient with more than two alpha steps?
Maybe you'd actually like to adjust the falloff curve instead of have it be linear?
Maybe there's an even better way to represent this?

    -- Will eventually want to cover radial gradients, but a similar approach to the above is likely easy.

Took a look at [background blend modes](https://developer.mozilla.org/en-US/docs/Web/CSS/background-blend-mode), which can be used to dynamically color images, like the [header image here](https://professional-rentals.com/).

The blend modes are vaguely influenced by background opacity.


## Element.Border

Sometimes a transparent border is used as a placeholder, and then we change a color on `mouseOver`.  This is to avoid layout movement in the resulting animation.

    Border.color : Color -> Attribute

    Border.opacity : Float -> Attribute

    Border.shadow :
        { offset : (Float, Float)
        , size : Float
        , blur : Float
        , color : Color
        , opacity : Float
        }

    Border.manyShadows : 
        List
            { offset : (Float, Float)
            , blur : Float
            , color : Color
            , opacity : Float
            } -> Attribute msg

    Border.innerShadow
        { offset : ( Float, Float )
        , size : Float
        , blur : Float
        , color : Color
        , opacity : Float
        }


# Discussion and Usecases 

The main question about binding alpha with color is:

    Is the identity of this color an identity about the color and it's ability to mix.  Knowing that it's ability to mix in this case is not great.

Or would you want to set these things explicitly and independently of each other?


## Tinting and shading (i.e. lightening and darkening)

*Note* - not sure what package would house these functions.

We usually get in the habit of using alpha for an ad-hoc lightener/darkener.
This can easily be replicated with functions that actually operate on colors in elm.

    Color.lighten 0.3 color

With the idea that this function should use the luminance from CIELUV instead of lightness from hsl.

## Mixing two colors

We also use alpha as an ad hoc way to mix two colors (i.e. [turn a font subtley green on a green background](https://medium.com/refactoring-ui/7-practical-tips-for-cheating-at-design-40c736799886#9cdf).

    el 
        [ Background.color bg
        -- explicitly mix the two!
        , Font.color (Color.mix 0.2 white bg)
        ]
        (text "Howdy")



