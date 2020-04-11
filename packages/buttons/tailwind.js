const plugin = require('tailwindcss/plugin');
const { resolve, isEmpty } = require('@frontile/tailwindcss-plugin-helpers');

module.exports = plugin.withOptions(function (userConfig) {
  return function ({ addComponents, theme }) {
    const { options } = resolve(
      '@frontile/buttons',
      require('./addon/tailwind/default-options'),
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
        addComponents({ [`.btn${modifier}`]: options.default });

        if (!isEmpty(options.outlined)) {
          addComponents({
            [`.btn-outlined${modifier}`]: options.outlined
          });
        }

        if (!isEmpty(options.minimal)) {
          addComponents({
            [`.btn-minimal${modifier}`]: options.minimal
          });
        }
      }
    }

    Object.keys(options).forEach((key) => {
      const modifier = key === 'default' ? '' : `--${key}`;
      if (['xs', 'sm', 'lg', 'xl'].includes(modifier.substring(2))) {
        addButton(
          {
            default: options[key].button.default,
            outlined:
              options[key].button.outlined || options[key].button.default,
            minimal: options[key].button.minimal || options[key].button.default
          },
          modifier
        );
      } else {
        addButton(options[key].button, modifier);
      }
    });
  };
});
