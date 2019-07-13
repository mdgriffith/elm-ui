# Render Benchmark

```bash
# In root directory
yarn install
yarn bench
```

We're interested in overall rendering performance.  Right now that means measuring:

1. Speed for first paint.
2. Rerender speed.
3. FPS for extended animations.

## Some notes about results.

- For the extended animation graph, you see it tops out at a certain point.  That's when the rendering pipeline is maxed out and it's now going below 60fps.
  
- The html and inline style cases are **not really** directly comparable to the `elm-ui` stuff because they're not buying you the same thing (which is really write-able, maintainable layouts.)  However they're nice to see because they're the current limit of elm's rendering.

