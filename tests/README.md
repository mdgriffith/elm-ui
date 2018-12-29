# Elm UI Test Suite

There are two types of tests for Elm UI.  The normal kind, which are located in `tests/suite/`

These can be run using [`elm-test`](https://github.com/elm-explorations/test) and can be run via 

```bash
elm-test
```

at the `elm-ui` root.

# Layout Testing

`elm-ui` also needs to ensure that all layouts work as expected on all browsers.

In order to do this, we need a different testing environment.

So, the tests in `elm-ui/tests/Tests` will render output, then harvest bounding boxes form the browser, and run the test on the resulting data.

In order to run the test locally, compile

`elm make Tests/Run.elm --output elm.js`

and then open `gather-styles.html`