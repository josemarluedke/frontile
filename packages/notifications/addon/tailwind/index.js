const plugin = require('tailwindcss/plugin');
const {
  resolve,
  isEmpty,
  replaceIconDeclarations,
  svgToDataUri
} = require('@frontile/tailwindcss-plugin-helpers');

module.exports = plugin.withOptions(function (userConfig) {
  return function ({ addComponents, theme }) {
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

      const {
        message,
        closeBtn,
        closeBtnIcon,
        customActions,
        customActionBtn,
        ...rest
      } = options;

      addComponents({ [`.notification-card${modifier}`]: rest });
      addComponents({
        [`.notification-card${modifier} .notification-card-message`]: message
      });
      addComponents({
        [`.notification-card${modifier} .notification-card-close-btn`]: closeBtn
      });
      addComponents({
        [`.notification-card${modifier} .notification-card-custom-actions`]: customActions
      });

      addComponents({
        [`.notification-card${modifier} .notification-card-custom-action-btn`]: customActionBtn
      });

      addComponents(
        replaceIconDeclarations(
          {
            [`.notification-card${modifier} .notification-card-close-btn-icon`]: closeBtnIcon
          },
          ({ icon = closeBtn.icon, iconColor = closeBtnIcon.iconColor }) => {
            return {
              backgroundImage: `url("${svgToDataUri(
                typeof icon === 'function' ? icon(iconColor) : icon
              )}")`
            };
          }
        )
      );
    }

    Object.keys(options).forEach((key) => {
      const modifier = key === 'default' ? '' : `-${key}`;
      addContainer(options[key].container, modifier);
      addCard(options[key].card, modifier);
    });
  };
});
