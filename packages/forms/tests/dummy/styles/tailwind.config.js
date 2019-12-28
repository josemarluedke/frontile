// Remove cache to allow rebuilds
delete require.cache[
  require('path').join(__dirname, '../../../addon/tailwind/default-options.js')
];
delete require.cache[
  require('path').join(
    __dirname,
    '../../../addon/tailwind/power-select-options.js'
  )
];

module.exports = {
  theme: {
    '@frontile/forms': {
      default: {}
    }
  },
  plugins: [require('../../../').tailwind]
};
