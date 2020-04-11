const plugin = require('tailwindcss/plugin');
const {
  resolve,
  isEmpty,
  svgToDataUri,
  replaceIconDeclarations
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
      const { enter, enterActive, leave, leaveActive } = options || {};

      name = `.overlay--transition--${name}`;

      addComponents({ [`${name}-enter`]: enter });
      addComponents({ [`${name}-enter-active`]: enterActive });
      addComponents({ [`${name}-leave`]: leave });
      addComponents({ [`${name}-leave-active`]: leaveActive });
    }

    function addTransitions(options) {
      if (isEmpty(options)) {
        return;
      }

      Object.keys(options).forEach((key) => {
        addTransitionPhases(key, options[key]);
      });
    }

    function addOverlay(options, modifier) {
      if (isEmpty(options)) {
        return;
      }
      addComponents({ [`.overlay${modifier}`]: options });
      addComponents({
        [`.overlay${modifier} .overlay__backdrop`]: options.backdrop
      });

      addComponents({
        [`.overlay${modifier} .overlay__content`]: options.content
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

      if (!isEmpty(options.header)) {
        addComponents({
          [`.modal${modifier} .modal__header`]: options.header
        });
      }

      if (!isEmpty(closeBtn)) {
        const { icon: btnIcon } = closeBtn;

        if (btnIcon) {
          delete closeBtn.icon;
        }

        addComponents({
          [`.modal${modifier} .modal__close-btn`]: closeBtn
        });
        if (!isEmpty(btnIcon)) {
          addComponents(
            replaceIconDeclarations(
              {
                [`.modal${modifier} .modal__close-btn--icon`]: btnIcon
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
          [`.modal${modifier} .modal__body`]: options.body
        });
      }

      if (!isEmpty(options.footer)) {
        addComponents({
          [`.modal${modifier} .modal__footer`]: options.footer
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
