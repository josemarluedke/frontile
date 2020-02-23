module.exports = {
  theme: {
    '@frontile/forms': {
      default: {}
    }
  },
  plugins: [
    require('@frontile/forms').tailwind,
    require('@frontile/buttons').tailwind
  ]
};
