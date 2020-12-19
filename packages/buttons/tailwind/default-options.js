const defaultTheme = require('tailwindcss/resolveConfig')(
  require('tailwindcss/defaultConfig')
).theme;

const defaultConfig = {
  borderRadius: defaultTheme.borderRadius.DEFAULT,
  default: {
    contrastColor: defaultTheme.colors.white,
    color: defaultTheme.colors.gray[700],
    hoverColor: defaultTheme.colors.gray[800],
    activeColor: defaultTheme.colors.gray[900]
  },
  minimal: {
    hoverBackgroundColor: defaultTheme.colors.gray[200],
    activeBackgroundColor: defaultTheme.colors.gray[300]
  },
  primary: {
    contrastColor: defaultTheme.colors.white,
    color: defaultTheme.colors.blue[700],
    hoverColor: defaultTheme.colors.blue[800],
    activeColor: defaultTheme.colors.blue[900]
  },
  success: {
    contrastColor: defaultTheme.colors.white,
    color: defaultTheme.colors.green[600],
    hoverColor: defaultTheme.colors.green[700],
    activeColor: defaultTheme.colors.green[800]
  },
  warning: {
    contrastColor: defaultTheme.colors.white,
    color: defaultTheme.colors.yellow[600],
    hoverColor: defaultTheme.colors.yellow[700],
    activeColor: defaultTheme.colors.yellow[800]
  },
  danger: {
    contrastColor: defaultTheme.colors.white,
    color: defaultTheme.colors.red[600],
    hoverColor: defaultTheme.colors.red[700],
    activeColor: defaultTheme.colors.red[800]
  }
};

function defaultOptions({ config }) {
  const hover = '&:not([disabled])&:hover';
  const active = '&:not([disabled])&:active,&.is-active';

  function generateIntents(options) {
    return {
      default: {
        color: options.contrastColor,
        backgroundColor: options.color,
        [hover]: {
          backgroundColor: options.hoverColor
        },
        [active]: {
          backgroundColor: options.activeColor
        }
      },
      outlined: {
        color: options.color,
        borderColor: options.color,
        [hover]: {
          color: options.contrastColor,
          backgroundColor: options.color
        },
        [active]: {
          color: options.contrastColor,
          backgroundColor: options.hoverColor
        }
      },
      minimal: {
        color: options.color
      }
    };
  }

  function generateVariants(type) {
    const intends = {
      default: generateIntents(config.default),
      primary: generateIntents(config.primary),
      success: generateIntents(config.success),
      warning: generateIntents(config.warning),
      danger: generateIntents(config.danger)
    };

    return {
      ...Object.keys(intends).reduce((obj, key) => {
        obj[key] = intends[key][type];
        return obj;
      }, {})
    };
  }

  return {
    'default, outlined, minimal': {
      baseStyle: {
        lineHeight: defaultTheme.lineHeight.tight,
        display: 'inline-block',
        fontWeight: defaultTheme.fontWeight.semibold,
        paddingTop: defaultTheme.spacing[3],
        paddingRight: defaultTheme.spacing[4],
        paddingBottom: defaultTheme.spacing[3],
        paddingLeft: defaultTheme.spacing[4],
        borderRadius: config.borderRadius,
        borderWidth: defaultTheme.borderWidth.DEFAULT,
        borderColor: defaultTheme.colors.transparent,
        '&.focus-visible:focus': {
          outline: 'none',
          boxShadow: defaultTheme.boxShadow.outline
        },
        '&[disabled]': {
          opacity: '0.4',
          cursor: defaultTheme.cursor['not-allowed']
        }
      },
      variants: {
        xs: {
          fontSize: defaultTheme.fontSize.sm,
          paddingTop: defaultTheme.spacing[1],
          paddingRight: defaultTheme.spacing[2],
          paddingBottom: defaultTheme.spacing[1],
          paddingLeft: defaultTheme.spacing[2]
        },
        sm: {
          paddingTop: defaultTheme.spacing[2],
          paddingRight: defaultTheme.spacing[3],
          paddingBottom: defaultTheme.spacing[2],
          paddingLeft: defaultTheme.spacing[3]
        },
        lg: {
          paddingTop: defaultTheme.spacing[4],
          paddingRight: defaultTheme.spacing[4],
          paddingBottom: defaultTheme.spacing[4],
          paddingLeft: defaultTheme.spacing[4]
        },
        xl: {
          fontSize: defaultTheme.fontSize.xl,
          paddingTop: defaultTheme.spacing[5],
          paddingRight: defaultTheme.spacing[6],
          paddingBottom: defaultTheme.spacing[5],
          paddingLeft: defaultTheme.spacing[6]
        }
      }
    },
    default: {
      baseStyle: {
        borderColor: defaultTheme.colors.transparent
      },

      variants: generateVariants('default')
    },
    outlined: {
      baseStyle: {
        backgroundColor: defaultTheme.colors.transparent
      },
      variants: generateVariants('outlined')
    },
    minimal: {
      baseStyle: {
        backgroundColor: defaultTheme.colors.transparent,
        borderColor: defaultTheme.colors.transparent,
        [hover]: {
          backgroundColor: config.minimal.hoverBackgroundColor
        },
        [active]: {
          backgroundColor: config.minimal.activeBackgroundColor
        }
      },

      variants: generateVariants('minimal')
    }
  };
}

module.exports = {
  defaultConfig,
  defaultOptions
};
