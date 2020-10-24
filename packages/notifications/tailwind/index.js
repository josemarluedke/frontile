const plugin = require('tailwindcss/plugin');
const {
  resolveComponents,
  addSinglePartComponent,
  addMultipartComponent,
  addTransitions
} = require('@frontile/tailwindcss-plugin-helpers');

module.exports = plugin.withOptions(function (userConfig) {
  return function ({ addComponents, theme }) {
    const { components } = resolveComponents(
      theme('frontile.notifications') || {},
      require('./default-options')
    );

    addSinglePartComponent(
      addComponents,
      '.notifications-container',
      components.container
    );

    addMultipartComponent(addComponents, '.notification-card', components.card);

    addTransitions(
      addComponents,
      '.notification-transition',
      components.transitions
    );
  };
});
