/* eslint-disable node/no-extraneous-require */
const { teal } = require('tailwindcss/colors');

module.exports = {
  future: {
    removeDeprecatedGapUtilities: true
  },
  theme: {
    extend: {
      colors: {
        teal
      }
    }
  },
  variants: {},
  plugins: [
    require('@frontile/core/tailwind'),
    require('@frontile/notifications/tailwind'),
    require('@frontile/forms/tailwind')
  ]
};
