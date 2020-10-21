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
      require('./default-options'),
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

    function addOverlay(options, modifier = '') {
      if (isEmpty(options)) {
        return;
      }

      let prefix = '';
      if (modifier !== '') {
        prefix = `.overlay${modifier} `;
      }

      const { backdrop, content, jsIsOpen, overlay, inPlace } = options;
      addComponents({
        [`.overlay${modifier}`]: overlay,
        [`${prefix}.overlay__backdrop`]: backdrop,
        [`${prefix}.overlay__content`]: content,
        [`.js-overlay-is-open`]: jsIsOpen
      });

      if (inPlace) {
        addOverlay(inPlace, '--in-place');
      }
    }

    function addModal(options) {
      if (isEmpty(options)) {
        return;
      }

      const {
        closeBtn,
        header,
        body,
        footer,
        modal,
        centered,
        sizes
      } = options;

      addComponents({
        [`.modal`]: modal,
        [`.modal--centered`]: centered,
        [`.modal__header`]: header,
        [`.modal__footer`]: footer,
        [`.modal__body`]: body
      });

      Object.keys(sizes || {}).forEach((key) => {
        addComponents({
          [`.modal--${key}`]: sizes[key]
        });
      });

      if (!isEmpty(closeBtn)) {
        const { icon: btnIcon } = closeBtn;

        if (btnIcon) {
          delete closeBtn.icon;
        }

        addComponents({
          [`.modal__close-btn`]: closeBtn
        });

        if (!isEmpty(btnIcon)) {
          addComponents(
            replaceIconDeclarations(
              {
                [`.modal__close-btn--icon`]: btnIcon
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
    }

    function addDrawer(options) {
      if (isEmpty(options)) {
        return;
      }

      const { header, body, footer, drawer, placements, sizes } = options;

      addComponents({
        ['.drawer']: drawer,
        ['.drawer__header']: header,
        ['.drawer__footer']: footer,
        ['.drawer__body']: body
      });

      Object.keys(placements).forEach((key) => {
        addComponents({
          [`.drawer--${key}`]: placements[key]
        });
      });

      Object.keys(sizes).forEach((sizeKey) => {
        Object.keys(sizes[sizeKey]).forEach((placementKey) => {
          addComponents({
            [`.drawer--${sizeKey}-${placementKey}`]: sizes[sizeKey][
              placementKey
            ]
          });
        });
      });
    }

    addTransitions(options.transitions);
    addOverlay(options.overlay);
    addModal(options.modal);
    addDrawer(options.drawer);
  };
});
