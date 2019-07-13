(function () {
  var ruleCache = new Set()

  function createStyleNode() {
    const node = document.createElement('style')
    // Without it, IE will have a broken source order specificity if we
    // insert rules after we insert the style tag.
    // It seems to kick-off the source order specificity algorithm.
    node.textContent = '\n'
    document.head.appendChild(node);
    return node
  }

  var staticSheet = createStyleNode();
  var sheet = createStyleNode().sheet;

  function sync_static(newStyleString) {
    staticSheet.textContent = newStyleString
  }

  function sync(newStyles) {
    Object.keys(newStyles).forEach((key) => {
      if (!ruleCache.has(key)) {
        const newRule = newStyles[key]
        for (var i = 0; i < newRule.length; i++) {
          sheet.insertRule(newRule[i])
        }
        ruleCache.add(key)
      }
    });
  }

  class CssRulesNode extends HTMLElement {
    set rules(rules) {
      sync(rules);
    }
  }
  customElements.define('elm-ui-rules', CssRulesNode);

  class CssStaticRulesNode extends HTMLElement {
    set rules(rules) {
      sync_static(rules);
    }
  }
  customElements.define('elm-ui-static-rules', CssStaticRulesNode);

}())
