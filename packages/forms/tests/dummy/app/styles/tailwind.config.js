/* eslint-disable node/no-extraneous-require */

module.exports = {
  future: {
    removeDeprecatedGapUtilities: true
  },
  theme: {
    frontile: {
      forms: {
        config: {},
        extend: {}
      }
    }
  },
  plugins: [require('@frontile/forms/tailwind')]
};
