# Mini Palette Experiment

`elm-ui` currently implements most things such as layout and style as attributes on a element. These are intended to be explicit so that visiting an element will give you all the information you need to understand how an element is shown.

However, this can also mean that Elements gather a lot of attributes and in the effort of capturing a consistent design language you may find yourself repeating a lot of combinations of attributes.

Previously a construct like `mix : List (Attribute msg) -> Attribute msg` has been proposed as a way to make things easier, however that opens up a large design space.  Developers then have to make the difficult decision about what attributes to group together. That decision is  It also would allow intermixing of event handlers with style and layout, which seems weird.  

As an alternative, we could have specific groupings of attributes that are allowed.  Done right, this may solve the problem of the dev having to worry about proper groupings and push them towards thinking of their design as a cohesive whole.

My intuition says that these groupings will fall along the lines of the current module organization.  Here are the helper functions that come to mind.  These would be in addition to everything we already have.


## Spacing Palette

```elm
Element.spaceWith : 
    { padding :
        { top : Int
        , right : Int
        , bottom : Int
        , left : Int
        }
    , spacing : 
        { x : Int
        , y : Int
        }
    } -> Attribute msg
```

## Color Palette

It might be a little weird to have a color grouping, but my gut says it probably makes sense.

By binding background and text color together, we can know all of our background and text color combinations, making it easier to verify and specifiy a minimum contrast for accessibility.

```elm
Element.colors :
    { background : Color
    , text : Color
    , border : Color
    } -> Attribute msg
```

## Font Palette

```elm
Element.Font.with :
    { typeface : String
    , fallback : List String
    , scale : Scale
    -- adjustments is a new thing that's coming that will allow more precise font sizing.
    , adjustments : Maybe Font.Adjustment
    -- These are variations like `slash zero`
    , variations : List Font.Variation
    } -> (Option, Attribute msg)

type Scale 
    = Single Int
    | Triple
        { small : Int
        , normal : Int
        , large : Int
        }
    | Fluid (windowSize -> Scale)




-- Usage

(titleFont, title) = 
    Font.with
        { typeface = "EB Garamond"
        , fallback =
            [ "georgia"
            , "serif"
            ]
        , scale =
            Font.Triple
                { small = 12
                , normal = 16
                , large = 32
                }
        , adjustments = Nothing
        , variations = []
        }


view =
    Element.layoutWith { options = [ titleFont ] } <|
        el 
            [ title.large
            ]
            (text "I am a large title font")


```

## Border Model

```elm
Element.Border.with :
    { width : Int
    , style : Border.Style
    , rounded :
        { topLeft : Int
        , topRight : Int
        , bottomLeft : Int
        , bottomRight : Int
        }
    }
```


## Shadow Model

This might mean breaking out shadows into their own module.

```elm
Element.Shadow.stack : List Shadow -> Attribute msg
```


# General Questions

So, here are the questions I have:

- If you have a current codebase with `elm-ui`, would this simplify things at all?  Is there a way you can quantify it(most elements I have would have half as many attributes)?
- Are there alternate groupings that you've come across?


