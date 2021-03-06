const defaultTheme = require('tailwindcss/resolveConfig')(
  require('tailwindcss/defaultConfig')
).theme;

const defaultConfig = {
  closeButton: {
    backgroundColor: undefined,
    hoverBackgroundColor: defaultTheme.colors.gray[100],
    borderRadius: defaultTheme.borderRadius.full,
    color: 'inherit',

    sizes: {
      xs: defaultTheme.fontSize.sm[0],
      sm: defaultTheme.fontSize.base[0],
      md: defaultTheme.fontSize.xl[0],
      lg: defaultTheme.fontSize['2xl'][0],
      xl: defaultTheme.fontSize['4xl'][0]
    }
  }
};

function defaultOptions({ config }) {
  return {
    closeButton: {
      baseStyle: {
        backgroundColor: config.closeButton.backgroundColor,
        borderRadius: config.closeButton.borderRadius,
        transitionProperty: defaultTheme.transitionProperty.DEFAULT,
        transitionDuration: defaultTheme.transitionDuration[200],

        '&.focus-visible:focus': {
          outline: 'none',
          boxShadow: defaultTheme.boxShadow.outline
        },

        '&:hover': {
          backgroundColor: config.closeButton.hoverBackgroundColor
        }
      },
      variants: {
        xs: {
          baseStyle: {
            fontSize: config.closeButton.sizes.xs,
            padding: defaultTheme.spacing[1]
          }
        },
        sm: {
          baseStyle: {
            fontSize: config.closeButton.sizes.sm,
            padding: defaultTheme.spacing[2]
          }
        },
        md: {
          baseStyle: {
            fontSize: config.closeButton.sizes.md,
            padding: defaultTheme.spacing[2]
          }
        },
        lg: {
          baseStyle: {
            fontSize: config.closeButton.sizes.lg,
            padding: defaultTheme.spacing[3]
          }
        },
        xl: {
          baseStyle: {
            fontSize: config.closeButton.sizes.xl,
            padding: defaultTheme.spacing[3]
          }
        }
      },

      parts: {
        icon: {
          height: '1em',
          width: '1em'
        }
      }
    }
  };
}

module.exports = {
  defaultConfig,
  defaultOptions
};
