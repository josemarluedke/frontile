const plugin = require('tailwindcss/plugin');
const { resolve, isEmpty } = require('@frontile/tailwindcss-plugin-helpers');

module.exports = plugin.withOptions(function (userConfig) {
  return function ({ addComponents, theme }) {
    const { options } = resolve(
      '@frontile/buttons',
      require('./default-options'),
      userConfig,
      theme
    );

    function addButton(options, modifier) {
      if (isEmpty(options)) {
        return;
      }

      if (modifier === '') {
        addComponents({ [`.btn`]: options.default });

        if (!isEmpty(options.outlined)) {
          addComponents({
            [`.btn-outlined`]: options.outlined
          });
        }

        if (!isEmpty(options.minimal)) {
          addComponents({
            [`.btn-minimal`]: options.minimal
          });
        }
      } else {
        addComponents({ [`.btn.btn${modifier}`]: options.default });

        if (!isEmpty(options.outlined)) {
          addComponents({
            [`.btn-outlined.btn-outlined${modifier}`]: options.outlined
          });
        }

        if (!isEmpty(options.minimal)) {
          addComponents({
            [`.btn-minimal.btn-minimal${modifier}`]: options.minimal
          });
        }
      }
    }

    Object.keys(options).forEach((key) => {
      const modifier = key === 'default' ? '' : `-${key}`;
      addButton(options[key].button, modifier);
    });
  };
});
