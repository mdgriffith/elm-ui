class CssRulesNode extends HTMLParagraphElement {
    constructor() {
      var self = super();
  
      // Our css rule cache
      self.rules = {}
      return self
    }

    set rules(rules) {
        this._rules = rules;
    }
}


customElements.define('elm-ui-css', CssRulesNode, { extends: 'div' });