'use strict';

module.exports = {
  extends: 'octane',
  rules: {
    quotes: 'double',
    'no-curly-component-invocation': { allow: ['demo.example', 'nav.item'] }
  }
};
