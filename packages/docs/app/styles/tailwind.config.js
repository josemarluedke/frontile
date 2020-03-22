module.exports = {
  theme: {
    '@frontile/forms': {
      default: {}
    }
  },
  plugins: [
    require('@frontile/forms').tailwind,
    require('@frontile/notifications').tailwind,
    require('@frontile/buttons').tailwind
  ]
};
