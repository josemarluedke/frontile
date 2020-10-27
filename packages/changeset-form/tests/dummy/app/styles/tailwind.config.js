module.exports = {
  future: {
    removeDeprecatedGapUtilities: true
  },
  theme: {},
  plugins: [
    require('@frontile/core/tailwind'),
    require('@frontile/forms/tailwind')
  ]
};
