(function () {
  var ruleCache = new Set();

  function createStyleNode() {
    const node = document.createElement("style");
    // Without it, IE will have a broken source order specificity if we
    // insert rules after we insert the style tag.
    // It seems to kick-off the source order specificity algorithm.
    node.textContent = "\n";
    document.head.appendChild(node);
    return node;
  }

  var staticSheet = createStyleNode();
  var sheet = createStyleNode().sheet;

  function sync_static(newStyleString) {
    staticSheet.textContent = newStyleString;
  }

  function sync(newStyles) {
    Object.keys(newStyles).forEach((key) => {
      if (!ruleCache.has(key)) {
        const newRule = newStyles[key];
        for (var i = 0; i < newRule.length; i++) {
          try {
            sheet.insertRule(newRule[i]);
          } catch (error) {
            // It's expected that some rules will fail if the current browser doesn't support them.
          }
        }
        ruleCache.add(key);
      }
    });
  }

  class CssRulesNode extends HTMLElement {
    set rules(rules) {
      sync(rules);
    }
  }
  customElements.define("elm-ui-rules", CssRulesNode);

  class CssStaticRulesNode extends HTMLElement {
    set rules(rules) {
      sync_static(rules);
    }
  }
  customElements.define("elm-ui-static-rules", CssStaticRulesNode);

  // New Houdini setup
  if ("registerProperty" in CSS) {
    CSS.registerProperty({
      name: "--space-x",
      syntax: "<length>",
      initialValue: "0px",
      inherits: false,
    });

    CSS.registerProperty({
      name: "--space-y",
      syntax: "<length>",
      initialValue: "0px",
      inherits: false,
    });

    CSS.registerProperty({
      name: "--width-fill",
      syntax: "<length>",
      initialValue: "0",
      inherits: false,
    });
  }

  class ElmUIElement extends HTMLElement {
    set spacing(spacing) {
      // sync_static(rules);
      this._spacingX = spacing;
      this._spacingY = spacing;
    }
    set spacingX(spacingX) {
      // sync_static(rules);
      this._spacingX = spacingX;
    }
    set spacingY(spacingY) {
      // sync_static(rules);
      this._spacingX = spacingY;
    }
    set widthPortion(portion) {
      this._widthPortion = portion;
    }
  }
  customElements.define("elm-ui-el", ElmUIElement);
})();
