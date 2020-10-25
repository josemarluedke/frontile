const plugin = require('tailwindcss/plugin');
const {
  resolveComponents,
  addMultipartComponent,
  addTransitions
} = require('@frontile/tailwindcss-plugin-helpers');

module.exports = plugin.withOptions(function () {
  return function ({ addComponents, theme }) {
    const { components } = resolveComponents(
      theme('frontile.overlays') || {},
      require('./default-options')
    );

    addTransitions(
      addComponents,
      '.overlay-transition',
      components.transitions
    );

    addMultipartComponent(addComponents, '.overlay', components.overlay);
    addMultipartComponent(addComponents, '.modal', components.modal);
    addMultipartComponent(addComponents, '.drawer', components.drawer);
  };
});
