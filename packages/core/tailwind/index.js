const plugin = require('tailwindcss/plugin');
const {
  resolve,
  isEmpty,
  kebabCase
} = require('@frontile/tailwindcss-plugin-helpers');

module.exports = plugin.withOptions(function (userConfig) {
  return function ({ addComponents, theme }) {
    const { options } = resolve(
      '@frontile/core',
      require('./default-options'),
      userConfig,
      theme
    );

    function addStylesFor(base, options, modifier = '') {
      if (isEmpty(options)) {
        return;
      }

      if (modifier !== '') {
        base += `--${modifier}`;
      }

      const { baseStyle, variants, parts } = options;

      addComponents({
        [base]: baseStyle
      });

      if (!isEmpty(parts)) {
        Object.keys(parts).forEach((key) => {
          addComponents({
            [`${base}__${kebabCase(key)}`]: parts[key]
          });
        });
      }

      if (!isEmpty(variants)) {
        Object.keys(variants).forEach((key) => {
          addStylesFor(base, variants[key], kebabCase(key));
        });
      }
    }

    addStylesFor('.close-button', options.closeButton);
  };
});
