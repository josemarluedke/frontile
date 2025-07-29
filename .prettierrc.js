/* eslint-disable node/no-missing-require */
const defaults = require('@underline/eslint-config/.prettierrc.js');
module.exports = {
  ...defaults,
  plugins: ['prettier-plugin-ember-template-tag'],
  overrides: [
    ...defaults.overrides,
    {
      files: '*.{js,ts,gjs,gts}',
      options: {
        templateSingleQuote: false
      }
    }
  ]
};
