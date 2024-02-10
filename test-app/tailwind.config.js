/* eslint-disable */
const { frontile } = require('@frontile/theme/plugin');

module.exports = {
  content: [
    './app/**/*.{html,js,ts,hbs,gts,gjs}',
    './node_modules/@frontile/theme/dist/**/*.{js,ts}'
  ],

  darkMode: 'class',

  plugins: [frontile()],
  safelist: [
    { pattern: /^js-focus-visible/ },
    { pattern: /^sr-only/ },

    // Frontile Notifications
    { pattern: /^notification-transition/ },

    // Frontile Overlays
    { pattern: /^overlay/ },
    { pattern: /^modal/ },
    { pattern: /^drawer/ }
  ]
};
