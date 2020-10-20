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

      let prefix = '';
      if (modifier !== '') {
        prefix = `.overlay${modifier} `;
      }

      const { backdrop, content, jsIsOpen, ...rest } = options;
      addComponents({
        [`.overlay${modifier}`]: rest,
        [`${prefix}.overlay__backdrop`]: backdrop,
        [`${prefix}.overlay__content`]: content,
        [`.js-overlay-is-open`]: jsIsOpen
      });
    }

    function addModal(options, modifier) {
      if (isEmpty(options)) {
        return;
      }

      let prefix = '';
      if (modifier !== '') {
        prefix = `.modal${modifier} `;
      }

      const { closeBtn, header, body, footer, ...rest } = options;

      addComponents({
        [`.modal${modifier}`]: rest,
        [`${prefix}.modal__header`]: header,
        [`${prefix}.modal__footer`]: footer,
        [`${prefix}.modal__body`]: body
      });

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
    }

    function addDrawer(options, modifier) {
      if (isEmpty(options)) {
        return;
      }

      let prefix = '';
      if (modifier !== '') {
        prefix = `.drawer${modifier} `;
      }

      const { header, body, footer, drawer, placements, sizes } = options;

      addComponents({
        [`.drawer${modifier}`]: drawer,
        [`${prefix}.drawer__header`]: header,
        [`${prefix}.drawer__footer`]: footer,
        [`${prefix}.drawer__body`]: body
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

    addTransitions(options.default.transitions);

    Object.keys(options).forEach((key) => {
      const modifier = key === 'default' ? '' : `--${key}`;
      addOverlay(options[key].overlay, modifier);
      addModal(options[key].modal, modifier);
      addDrawer(options[key].drawer, modifier);
    });
  };
});
