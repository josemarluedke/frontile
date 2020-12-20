/* eslint-disable node/no-extraneous-require */
const colors = require('tailwindcss/colors');

module.exports = {
  future: {
    removeDeprecatedGapUtilities: true
  },
  theme: {
    extend: {
      colors: {
        teal: colors.teal
      }
    },
    frontile: {
      forms: {
        config: {},
        extend: {}
      }
    }
  },
  plugins: [require('@frontile/forms/tailwind')]
};
