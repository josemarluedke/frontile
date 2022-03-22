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
    }
  },
  variants: {},
  plugins: [
    require('@frontile/core/tailwind'),
    require('@frontile/forms/tailwind'),
    require('@frontile/buttons/tailwind'),
    require('@frontile/notifications/tailwind'),
    require('@frontile/overlays/tailwind')
  ]
};
