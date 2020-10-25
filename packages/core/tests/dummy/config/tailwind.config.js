/* eslint-disable node/no-extraneous-require */

module.exports = {
  future: {
    removeDeprecatedGapUtilities: true,
    purgeLayersByDefault: true
  },
  purge: [],
  theme: {
    extend: {},
    frontile: {
      core: {
        config: {
          closeButton: {}
        },
        extend: {
          closeButton: {
            baseStyle: {}
          }
        }
      }
    }
  },
  variants: {},
  plugins: [require('@frontile/core/tailwind')]
};
