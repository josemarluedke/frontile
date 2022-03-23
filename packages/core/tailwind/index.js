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

    /* https://github.com/WICG/focus-visible */
    addComponents({
      '.js-focus-visible :focus:not(.focus-visible)': {
        outline: 'none'
      }
    });

    addMultipartComponent(
      addComponents,
      '.close-button',
      components.closeButton
    );
  };
});
