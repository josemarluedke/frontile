/* eslint-disable node/no-extraneous-require */

// Remove cache to allow rebuilds
const path = require('path');
delete require.cache[
  path.join(
    path.dirname(require.resolve('@frontile/modals')),
    'addon/tailwind/default-options.js'
  )
];

module.exports = {
  theme: {
    extend: {}
  },
  variants: {},
  plugins: [require('@frontile/modals/tailwind')]
};
