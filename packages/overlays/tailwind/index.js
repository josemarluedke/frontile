const plugin = require('tailwindcss/plugin');
const {
  resolveComponents,
  isEmpty,
  kebabCase,
  addMultipartComponent
} = require('@frontile/tailwindcss-plugin-helpers');

module.exports = plugin.withOptions(function () {
  return function ({ addComponents, theme }) {
    const { components } = resolveComponents(
      theme('frontile.overlays') || {},
      require('./default-options')
    );

    function addTransitionPhases(name, options) {
      if (isEmpty(options)) {
        return;
      }
      name = `.overlay--transition--${name}`;

      const { enter, enterActive, leave, leaveActive } = options;
      addComponents({
        [`${name}-enter`]: enter,
        [`${name}-leave-to`]: enter,
        [`${name}-enter-active`]: enterActive,
        [`${name}-leave`]: leave,
        [`${name}-enter-to`]: leave,
        [`${name}-leave-active`]: leaveActive
      });
    }

    function addTransitions(options) {
      if (isEmpty(options)) {
        return;
      }

      Object.keys(options).forEach((key) => {
        addTransitionPhases(kebabCase(key), options[key]);
      });
    }

    addTransitions(components.transitions);

    addMultipartComponent(addComponents, '.overlay', components.overlay);
    addMultipartComponent(addComponents, '.modal', components.modal);
    addMultipartComponent(addComponents, '.drawer', components.drawer);
  };
});
