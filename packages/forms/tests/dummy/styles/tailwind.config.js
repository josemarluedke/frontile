// Remove cache to allow rebuilds
delete require.cache[
  require('path').join(__dirname, '../../../addon/tailwind/default-options.js')
];

module.exports = {
  theme: {
    '@frontile/forms': {
      default: {}
    }
  },
  plugins: [require('../../../addon/tailwind/plugin.js')]
};
