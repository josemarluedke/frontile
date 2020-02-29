const plugin = require('tailwindcss/plugin');
const { resolve, isEmpty } = require('@frontile/tailwindcss-plugin-helpers');

module.exports = plugin.withOptions(function(userConfig) {
  return function({ addComponents, theme }) {
    const { options } = resolve(
      '@frontile/notifications',
      require('./default-options'),
      userConfig,
      theme
    );

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
