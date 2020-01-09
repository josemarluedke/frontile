/* eslint-disable node/no-extraneous-require */

// Remove cache to allow rebuilds
const path = require('path');
delete require.cache[
  path.join(
    path.dirname(require.resolve('@frontile/forms')),
    'addon/tailwind/default-options.js'
  )
];

module.exports = {
  theme: {
    '@frontile/forms': {
      default: {}
    }
  },
  plugins: [require('@frontile/forms').tailwind]
};
