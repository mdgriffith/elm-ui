# Rendering Order

Nearby elements such as `below`, `above`, and `inFront` are rendered after the other children of the `Element. `behindContent` is rendered before.

This is so:

- `inFront` doesn't need a special `z-index` to work.  This can increase performance because too many `z-index` overrides means shipping more layers to the gpu.
- Nearby elements higher up in the DOM hierarchy will be on top of elements lower in the hierarchy.  `inFront` on a higher element should be on top of `inFront` elements on a lower element.
- Allows nearby elements to be affected by `focused` for `Input`, because they can be reached by a sibling selector.  `.focuesed:focus ~ .focusable-style {}`



# Desired Behavior of Nearby Elements



- `inFront` on an element will be in front of all children.
    - if there's an `inFront` attached to a child, it will be beneath the parent's `inFront`
- `behindContent`, likewise, will always be between the background and the element's children.
- `onLeft`, `onRight`, `above`, and `below` will be in front of any element they overlap with.
    - if an element has an `inFront` and it's neighbor has an `onLeft`, then the `onLeft` element will be on top of the `inFront`.
- if `onLeft`, `onRight`, `above`, and `below` on separate elements overlap, source order wins:
    - in a row, the one attached to the element farthest to the right wins.
    - in a column, the one attached to the element farthest down wins.
