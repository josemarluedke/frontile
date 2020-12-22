const defaultTheme = require('tailwindcss/defaultTheme');
const { teal } = require('tailwindcss/colors');

module.exports = {
  purge: [],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', ...defaultTheme.fontFamily.sans]
      },
      colors: {
        gray: {
          1000: '#12161f'
        },
        teal
      },
      typography: {
        DEFAULT: {
          css: {
            maxWidth: null,
            'h1 a, h2 a, h3 a, h4 a': {
              textDecoration: 'none'
            }
          }
        }
      }
    }
  },
  variants: {},
  plugins: [
    require('@frontile/core/tailwind'),
    require('@frontile/forms/tailwind'),
    require('@frontile/buttons/tailwind'),
    require('@frontile/notifications/tailwind'),
    require('@frontile/overlays/tailwind'),
    require('@frontile/buttons/tailwind'),
    require('@tailwindcss/typography')
  ]
};
