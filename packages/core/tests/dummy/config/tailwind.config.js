/* eslint-disable node/no-extraneous-require */
const colors = require('tailwindcss/colors');

module.exports = {
  future: {
    removeDeprecatedGapUtilities: true,
    purgeLayersByDefault: true
  },
  purge: [],
  theme: {
    extend: {
      colors: {
        teal: colors.teal
      }
    },
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
