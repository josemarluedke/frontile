'use strict';

module.exports = {
  extends: ['octane', 'stylistic'],
  rules: {
    quotes: 'double',
    'no-curly-component-invocation': {
      allow: ['demo.example', 'nav.item', 'nav.subnav']
    }
  }
};
