# Benchmark Suite

It would be nice to be able to keep track of `elm-ui`'s performance characteristics and the easiest way to do that would be to write a benchmark suite.

[This project](https://github.com/webbhuset/test-elm-performance) did a great job implementing a critical rendering path benchmark.

However, it's pretty awkward for me to use when I'm doing any sort of performance-based development.

I'd love it if someone were to take that codebase and 

- Make the benchmark runnable via cli and output results as json.
- Make it really easy to test new view functions.  Meaning I'd love the ability to just write a view function and run a tool which would benchmark it render-wise.