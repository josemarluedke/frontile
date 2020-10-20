const plugin = require('tailwindcss/plugin');
const {
  resolve,
  isEmpty,
  svgToDataUri,
  replaceIconDeclarations,
  kebabCase
} = require('@frontile/tailwindcss-plugin-helpers');

module.exports = plugin.withOptions(function (userConfig) {
  return function ({ addComponents, theme }) {
    const { options } = resolve(
      '@frontile/overlays',
      require('./addon/tailwind/default-options'),
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

    function addOverlay(options, modifier) {
      if (isEmpty(options)) {
        return;
      }
      addComponents({ [`.overlay${modifier}`]: options });

      let prefix = '';
      if (modifier !== '') {
        prefix = `.overlay${modifier} `;
      }

      addComponents({
        [`${prefix}.overlay__backdrop`]: options.backdrop
      });

      addComponents({
        [`${prefix}.overlay__content`]: options.content
      });

      addComponents({ [`.js-overlay-is-open`]: options.jsIsOpen });
    }

    function addModal(options, modifier) {
      if (isEmpty(options)) {
        return;
      }
      const { closeBtn } = options;

      if (closeBtn) {
        delete options.closeBtn;
      }

      addComponents({ [`.modal${modifier}`]: options });
      let prefix = '';
      if (modifier !== '') {
        prefix = `.modal${modifier} `;
      }

      if (!isEmpty(options.header)) {
        addComponents({
          [`${prefix}.modal__header`]: options.header
        });
      }

      if (!isEmpty(closeBtn)) {
        const { icon: btnIcon } = closeBtn;

        if (btnIcon) {
          delete closeBtn.icon;
        }

        addComponents({
          [`${prefix}.modal__close-btn`]: closeBtn
        });
        if (!isEmpty(btnIcon)) {
          addComponents(
            replaceIconDeclarations(
              {
                [`${prefix}.modal__close-btn--icon`]: btnIcon
              },
              ({ icon = btnIcon.icon, iconColor = btnIcon.iconColor }) => {
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

      if (!isEmpty(options.body)) {
        addComponents({
          [`${prefix}.modal__body`]: options.body
        });
      }

      if (!isEmpty(options.footer)) {
        addComponents({
          [`${prefix}.modal__footer`]: options.footer
        });
      }
    }

    addTransitions(options.default.transitions);

    Object.keys(options).forEach((key) => {
      const modifier = key === 'default' ? '' : `--${key}`;
      addOverlay(options[key].overlay, modifier);
      addModal(options[key].modal, modifier);
    });
  };
});
