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
    const options = resolveOptions(theme('@frontile/notifications'), {
      theme,
      config
    });

    function addTODO(options, modifier) {
      if (isEmpty(options)) {
        return;
      }
      addComponents({ [`.TODO${modifier}`]: options });
    }

    Object.keys(options).forEach(key => {
      const modifier = key === 'default' ? '' : `-${key}`;
      addTODO(options[key].TODO, modifier);
    });
  };
});
