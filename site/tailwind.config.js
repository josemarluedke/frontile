/* eslint-disable node/no-extraneous-require */
const defaultTheme = require('tailwindcss/defaultTheme');
const { teal } = require('tailwindcss/colors');
/* eslint-disable node/no-missing-require */
const { frontile } = require('@frontile/theme/plugin');
const { blue, gray } = require('@frontile/theme/colors');

module.exports = {
  content: [
    './app/**/*.{html,js,ts,hbs,gts,gjs}',
    './node_modules/@frontile/theme/dist/**/*.js',
    './lib/docfy-theme/addon/**/*.hbs',
    '../**/*.md',
    './node_modules/**/*.hbs',
    '../node_modules/**/*.hbs'
  ],
  darkMode: 'class',
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', ...defaultTheme.fontFamily.sans]
      },
      colors: {
        gray: {
          1000: '#12161f'
        },
        teal,
        brand: blue[500]
      },
      zIndex: {
        1: '1'
      },
      maxHeight: {
        '(screen-16)': 'calc(100vh - 4rem)'
      },
      typography: () => ({
        DEFAULT: {
          css: {
            'code::before': null,
            'code::after': null
          }
        }
      })
    }
  },
  variants: {
    extend: {
      typography: ['dark']
    }
  },
  plugins: [frontile(), require('@tailwindcss/typography')],
  safelist: [
    { pattern: /^js-focus-visible/ },
    { pattern: /^sr-only/ },
    { pattern: /^not-prose/ },
    { pattern: /^prose"/ },
    { pattern: /^dark:prose-invert"/ },

    // Frontile Notifications
    { pattern: /^notification-transition/ },

    // Frontile Overlays
    { pattern: /^overlay/ },
    { pattern: /^modal/ },
    { pattern: /^drawer/ }
  ]
};
