module.exports = {
  future: {
    removeDeprecatedGapUtilities: true
  },
  theme: {
    '@frontile/forms': {
      default: {}
    }
  },
  plugins: [
    require('@frontile/core/tailwind'),
    require('@frontile/forms/tailwind'),
    require('@frontile/notifications/tailwind'),
    require('@frontile/overlays/tailwind'),
    require('@frontile/buttons/tailwind')
  ]
};
