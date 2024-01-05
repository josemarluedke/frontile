/* eslint-disable node/no-extraneous-require */
const colors = require('tailwindcss/colors');
const { frontile } = require('@frontile/theme/plugin');

module.exports = {
  content: [
    './app/**/*.{html,js,ts,hbs}',
    './node_modules/@frontile/theme/dist/**/*.{js,ts}'
  ],

  theme: {
    extend: {
      colors: {
        teal: colors.teal
      }
    }
  },
  plugins: [
    frontile(),
    require('@frontile/forms/tailwind'),
    require('@frontile/overlays/tailwind')
  ],
  safelist: [
    { pattern: /^js-focus-visible/ },
    { pattern: /^sr-only/ },

    // Frontile Forms
    { pattern: /^form-field-checkbox/ },
    { pattern: /^form-field-feedback/ },
    { pattern: /^form-field-hint/ },
    { pattern: /^form-field-input/ },
    { pattern: /^form-field-label/ },
    { pattern: /^form-field-radio/ },
    { pattern: /^form-field-textarea/ },
    { pattern: /^form-input/ },
    { pattern: /^form-textarea/ },
    { pattern: /^form-select/ },
    { pattern: /^form-checkbox/ },
    { pattern: /^form-radio/ },
    { pattern: /^form-checkbox-group/ },
    { pattern: /^form-radio-group/ },

    // Frontile Notifications
    { pattern: /^notification-transition/ },

    // Frontile Overlays
    { pattern: /^overlay/ },
    { pattern: /^modal/ },
    { pattern: /^drawer/ },

    // Power Select
    { pattern: /^ember-power-select/ }
  ]
};
