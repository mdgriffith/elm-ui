# Classifying Issues


One of the first things we want to do is to keep our issues categorized. 

If you add a comment to an issue that references a label, that label will be assigned to that issue! (e.g. `#has-ellie` will add the `has-ellie` label.)

[Here's one that I categorized](https://github.com/mdgriffith/elm-ui/issues/201)

[Labels are described here](https://github.com/mdgriffith/elm-ui/labels)

- **Feature Suggestions** - `#feature-suggestion` -  This issue describes a feature suggestion.  Tagging it with `#feature-suggestion` is all that needs to happen.

- **Pain Point** - `#pain-point` - This is an issue that descrbes a challenge someone is facing, but makes not direct suggestion about how it should be solved. Here's a good example, [unable to applly text overflow ellipses](https://github.com/mdgriffith/elm-ui/issues/112).

- **Bug** - `#bug` - The issue that's being described is potentially a bug.  It may not be totally obvious what the fix is.
  - **Has Ellie** - `#has-ellie` - Every bug described should have an ellie showing the problem, even if it's sorta trivial.
  - **No Ellie** - If it's a bug, but has been checked for ellies and has no ellie, flag it as `#no-ellie`.
  - **Has Test** - `#has-test` - Once we have an ellie for the problem, we want a version of that code in the codebase so I can easily take a look.
    - The thing to do is to open a PR that copies that ellie into the [`tests-rendering/cases/open`](https://github.com/mdgriffith/elm-ui/tree/master/tests-rendering/cases/open) directory.  Give it a succinct, human name.
    - Rename the `Element.*` imports as `Testable.Element.*`
    - Add a link to the issue, the title of the issue, and the body of the issue to the module comment.  [Here's an example](https://github.com/mdgriffith/elm-ui/tree/master/tests-rendering/cases/open/InFrontSize.elm)
  - Test is compiling - Optionally you can see if the test is compiling by first `cd tests-rendering` and then running `elm-live cases/open/{The file}.elm --open --dir=view -- --output=view/elm.js --debug` 
    - If it does not compile, flag the issue as `#test-not-compiling`.  Don't worry about fixing it unless it's really obvious what needs to happen.
  - Check if the test passes.  Do that by opening `tests-rendering/cases/view/view.html` after running the above compilation.  If it says all passes, likely you should flag the issue as `#test-incorrectly-passing`.
  - If it's failing, you can flag as `#test-failing`



