const plugin = require('tailwindcss/plugin');
const {
  resolveComponents,
  addMultipartComponent
} = require('@frontile/tailwindcss-plugin-helpers');

module.exports = plugin.withOptions(function () {
  return function ({ addComponents, theme }) {
    const { components } = resolveComponents(
      theme('frontile.core') || {},
      require('./default-options')
    );

    addMultipartComponent(
      addComponents,
      '.close-button',
      components.closeButton
    );
  };
});
