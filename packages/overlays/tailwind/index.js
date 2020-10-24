const plugin = require('tailwindcss/plugin');
const {
  resolve,
  isEmpty,
  kebabCase,
  addMultipartComponent
} = require('@frontile/tailwindcss-plugin-helpers');

module.exports = plugin.withOptions(function (userConfig) {
  return function ({ addComponents, theme }) {
    const { options } = resolve(
      '@frontile/overlays',
      require('./default-options'),
      userConfig,
      theme
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

    addTransitions(options.transitions);

    addMultipartComponent(addComponents, '.overlay', options.overlay);
    addMultipartComponent(addComponents, '.modal', options.modal);
    addMultipartComponent(addComponents, '.drawer', options.drawer);
  };
});
