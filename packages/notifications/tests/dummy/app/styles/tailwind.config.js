/* eslint-disable node/no-extraneous-require */

// Remove cache to allow rebuilds
const path = require('path');
delete require.cache[
  path.join(
    path.dirname(require.resolve('@frontile/notifications')),
    'addon/tailwind/default-options.js'
  )
];

module.exports = {
  theme: {
    extend: {}
  },
  variants: {},
  plugins: [
    require('@frontile/notifications').tailwind,
    require('@frontile/forms').tailwind
  ]
};
