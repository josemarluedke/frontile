module.exports = {
  future: {
    removeDeprecatedGapUtilities: true
  },
  theme: {
    '@frontile/forms': {
      default: {}
    }
  },
  plugins: [require('@frontile/forms/tailwind')]
};
