const plugin = require('tailwindcss/plugin');
const {
  resolve,
  isEmpty,
  replaceIconDeclarations,
  svgToDataUri
} = require('@frontile/tailwindcss-plugin-helpers');

module.exports = plugin.withOptions(function(userConfig) {
  return function({ addComponents, theme }) {
    const { options } = resolve(
      '@frontile/notifications',
      require('./default-options'),
      userConfig,
      theme
    );

    function addContainer(options, modifier) {
      if (isEmpty(options)) {
        return;
      }
      addComponents({ [`.notifications-container${modifier}`]: options });
    }

    function addCard(options, modifier) {
      if (isEmpty(options)) {
        return;
      }
      addComponents(
        replaceIconDeclarations(
          { [`.notification-card${modifier}`]: options },
          ({ icon = options.icon, iconColor = options.iconColor }) => {
            return {
              backgroundImage: `url("${svgToDataUri(
                typeof icon === 'function' ? icon(iconColor) : icon
              )}")`
            };
          }
        )
      );
    }

    Object.keys(options).forEach(key => {
      const modifier = key === 'default' ? '' : `-${key}`;
      addContainer(options[key].container, modifier);
      addCard(options[key].card, modifier);
    });
  };
});
