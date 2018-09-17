# Rendering Order

Nearby elements such as `below`, `above`, `behindContent`, and `inFront` are rendered after the other children of the `Element.

This is so:

- `inFront` doesn't need a special `z-index` to work.  This can increase performance because too many `z-index` overrides means shipping more layers to the gpu.
- Nearby elements higher up in the DOM hierarchy will be on top of elements lower in the hierarchy.  `inFront` on a higher element should be on top of `inFront` elements on a lower element.
- Allows nearby elements to be affected by `focused` for `Input`, because they can be reached by a sibling selector.  `.focuesed:focus ~ .focusable-style {}`

