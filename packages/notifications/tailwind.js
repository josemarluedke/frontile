const plugin = require('tailwindcss/plugin');
const {
  resolve,
  isEmpty,
  replaceIconDeclarations,
  svgToDataUri
} = require('@frontile/tailwindcss-plugin-helpers');

function camelCaseToDash(str) {
  return str.replace(/([a-zA-Z])(?=[A-Z])/g, '$1-').toLowerCase();
}

module.exports = plugin.withOptions(function (userConfig) {
  return function ({ addComponents, theme }) {
    const { options } = resolve(
      '@frontile/notifications',
      require('./addon/tailwind/default-options'),
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

      if (!isEmpty(rest)) {
        addComponents({ [`.notification-card${modifier}`]: rest });
      }
      if (!isEmpty(message)) {
        addComponents({
          [`.notification-card${modifier} .notification-card__message`]: message
        });
      }
      if (!isEmpty(closeBtn)) {
        addComponents({
          [`.notification-card${modifier} .notification-card__close-btn`]: closeBtn
        });
      }
      if (!isEmpty(customActions)) {
        addComponents({
          [`.notification-card${modifier} .notification-card__custom-actions`]: customActions
        });
      }
      if (!isEmpty(customActionBtn)) {
        addComponents({
          [`.notification-card${modifier} .notification-card__custom-actions__btn`]: customActionBtn
        });
      }
      if (!isEmpty(closeBtnIcon)) {
        addComponents(
          replaceIconDeclarations(
            {
              [`.notification-card${modifier} .notification-card__close-btn__icon`]: closeBtnIcon
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
    }

    Object.keys(options).forEach((key) => {
      const modifier = key === 'default' ? '' : `--${camelCaseToDash(key)}`;
      addContainer(options[key].container, modifier);
      addCard(options[key].card, modifier);
    });
  };
});
