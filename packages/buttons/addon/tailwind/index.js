const plugin = require('tailwindcss/plugin');
const map = require('lodash/map');
const isEmpty = require('lodash/isEmpty');
const fromPairs = require('lodash/fromPairs');
const { merge, flattenOptions } = require('./helpers');

module.exports = plugin.withOptions(function(customConfig) {
  const { defaultConfig, defaultOptions } = require('./default-options');

  function resolveOptions(userOptions, params) {
    return merge(
      defaultOptions(params),
      fromPairs(map(userOptions, (value, key) => [key, flattenOptions(value)]))
    );
  }

  return function({ addComponents, theme }) {
    if (typeof customConfig === 'function') {
      customConfig = customConfig({ theme });
    }

    const config = merge(defaultConfig, customConfig || {});
    const options = resolveOptions(theme('@frontile/buttons'), {
      theme,
      config
    });

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

    Object.keys(options).forEach(key => {
      const modifier = key === 'default' ? '' : `-${key}`;
      addButton(options[key].button, modifier);
    });
  };
});
