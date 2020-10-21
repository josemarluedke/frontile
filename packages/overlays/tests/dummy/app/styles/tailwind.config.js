/* eslint-disable node/no-extraneous-require */

module.exports = {
  future: {
    removeDeprecatedGapUtilities: true
  },
  theme: {
    extend: {}
  },
  variants: {},
  plugins: [
    require('@frontile/overlays/tailwind'),
    require('@frontile/buttons/tailwind'),
    require('@frontile/forms/tailwind')
  ]
};
