/* eslint-disable node/no-extraneous-require */

// Remove cache to allow rebuilds
const path = require('path');
delete require.cache[
  path.join(
    path.dirname(require.resolve('@frontile/buttons')),
    'addon/tailwind/default-options.js'
  )
];

module.exports = {
  future: {
    removeDeprecatedGapUtilities: true
  },
  theme: {
    extend: {}
  },
  variants: {},
  plugins: [require('@frontile/buttons/tailwind')]
};
