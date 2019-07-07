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
        sheet.insertRule(newRule)
        ruleCache.add(key)
      }
    });
  }

  class CssRulesNode extends HTMLElement {
    constructor() {
      var self = super();
    }
    connectedCallback() {
      sync(this.rulesPayload)
    }
    set rules(rules) {
      console.log("set rules")
      console.log(rules)
      if (self.rulesPayload) {
        console.log(self.rulesPayload)
      }
      this._rules = rules;
      console.log(this._rules)
    }
    attributeChangedCallback(attrName, oldVal, newVal) {
      console.log(attrName, oldVal, newVal)
    }
  }
  customElements.define('elm-ui-rules', CssRulesNode);



  class CssStaticRulesNode extends HTMLElement {
    constructor() {
      var self = super();
      this._rules = null;
    }
    connectedCallback() {
      // console.log("static connected")
      // console.log(this)
      // if (this._rules) {
      //   sync_static(this._rules)
      // }
    }
    set rules(rules) {
      this._rules = rules
      sync_static(this._rules)
      // console.log("set static rules")
      // console.log(rules)
    }

    attributeChangedCallback(attrName, oldVal, newVal) {
      console.log("attribute cng")
      console.log(attrName)
      if (attrName == "rules") {
        sync_static(newVal)
      }
    }
  }
  customElements.define('elm-ui-static-rules', CssStaticRulesNode);








}())
