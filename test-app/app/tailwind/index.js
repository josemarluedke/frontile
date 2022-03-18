const plugin = require('tailwindcss/plugin');
const {
  resolveComponents,
  addSinglePartComponent
} = require('@frontile/tailwindcss-plugin-helpers');

module.exports = plugin.withOptions(function () {
  return function ({ addComponents, theme }) {
    const { components } = resolveComponents(
      theme('frontile.buttons') || {},
      require('./default-options')
    );

    addSinglePartComponent(addComponents, '.btn', components.default);
    addSinglePartComponent(addComponents, '.btn-outlined', components.outlined);
    addSinglePartComponent(addComponents, '.btn-minimal', components.minimal);
    addSinglePartComponent(addComponents, '.btn-custom', components.custom);
  };
});
