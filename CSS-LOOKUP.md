# CSS Concepts and where to find them

This library creates a new language around layout and style, though if you're already used to CSS, you're probably wondering where certain concepts lie.

> I know how I can do it in CSS, but how could I approach the problem using Style Elements?


CSS    |  Style Elements  | Description
-------|------------------|------------
`position:absolute` | `above`, `below`, `onRight`, `onLeft`, `inFront`, `behindContent` |  In Style Elements we can attach elements relative to another element.  They won't affect normal flow, just like `position:absolute`
`position:fixed` | `inFront` if it's attached to the `Element.layout` element.  |  `position:fixed` needs to be at the top of your view or else it can break in seemingly random ways.  Did you know `position:fixed` will position something relative to the viewport *OR* any parent that uses `filter`, `transform` or `perspective`?  So you add a blur effect and your layout breaks...
`z-index` | __N/A__  |  One of the goals of the library was to make `z-index` a behind-the-scenes detail.  If you ever encounter a situation where you feel like you actually need it, let me know on slack or through the issues.
`float:left` `float:right` | `alignLeft` or `alignRight` when inside a `paragraph` or a `textColumn` |
`opacity` | `alpha` |
`margin` | __N/A__  Instead, check out `padding` and `spacing` |  `margin` in CSS was designed to fight with `padding`.  This library was designed to minimize override logic and properties that fight with each other in order to create a layout language that is predictable and easy to think about.  The result is that in style elements, there's generally only *one place* where an effect can happen.
`:hover`, `:focus`, `:active` | `mouseOver`, `focused`, `mouseDown`  | Only certain styles are allowed to be in a pseudo state.  They have the type `Attr decorative msg`, which means they can be either an `Attribute` or a `Decoration`.
`<form>` | __N/a__ | __Elm__ already has a mechanism for submiting data to a server, namely the `Http` package.  There has been some mention that the `form` element might be beneficial accessibility-wise, which I'm definitely open to hearing about!
`onSubmit` | __N/A__ | Similar to `<form>`, there is no `onSubmit` behavior.  Likely if you're attempting to capture some of the keybaord related behavior of `onSubmit`, you're likely better just crafting a keyboard even handler in the first place!
