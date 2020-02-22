const defaultTheme = require('tailwindcss/resolveConfig')(
  require('tailwindcss/defaultConfig')
).theme;

const defaultConfig = {
  borderRadius: defaultTheme.borderRadius.default,
  minimal: {
    hoverBackgroundColor: defaultTheme.colors.gray[200],
    activeBackgroundColor: defaultTheme.colors.gray[300]
  },
  default: {
    contrastColor: defaultTheme.colors.white,
    color: defaultTheme.colors.gray[700],
    hoverColor: defaultTheme.colors.gray[800],
    activeColor: defaultTheme.colors.gray[900]
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
  const buttonShape = {
    lineHeight: defaultTheme.lineHeight.tight,
    display: 'inline-block',
    fontWeight: defaultTheme.fontWeight.semibold,
    paddingTop: defaultTheme.spacing[3],
    paddingRight: defaultTheme.spacing[4],
    paddingBottom: defaultTheme.spacing[3],
    paddingLeft: defaultTheme.spacing[4],
    borderRadius: config.borderRadius,
    borderWidth: defaultTheme.borderWidth.default,
    borderColor: defaultTheme.colors.transparent,
    '&.focus-visible:focus': {
      outline: 'none',
      boxShadow: defaultTheme.boxShadow.outline
    },
    '&[disabled]': {
      opacity: '0.4',
      cursor: defaultTheme.cursor['not-allowed']
    }
  };

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

  return {
    default: {
      button: {
        default: {
          ...buttonShape,

          color: config.default.contrastColor,
          backgroundColor: config.default.color,
          borderColor: defaultTheme.colors.transparent,
          [hover]: {
            backgroundColor: config.default.hoverColor
          },
          [active]: {
            backgroundColor: config.default.activeColor
          }
        },
        outlined: {
          ...buttonShape,

          color: config.default.color,
          backgroundColor: defaultTheme.colors.transparent,
          borderColor: config.default.color,
          [hover]: {
            color: config.default.contrastColor,
            backgroundColor: config.default.color
          },
          [active]: {
            color: config.default.contrastColor,
            backgroundColor: config.default.hoverColor
          }
        },
        minimal: {
          ...buttonShape,

          color: config.default.color,
          backgroundColor: defaultTheme.colors.transparent,
          borderColor: defaultTheme.colors.transparent,
          [hover]: {
            backgroundColor: config.minimal.hoverBackgroundColor
          },
          [active]: {
            backgroundColor: config.minimal.activeBackgroundColor
          }
        }
      }
    },
    primary: { button: generateIntents(config.primary) },
    success: { button: generateIntents(config.success) },
    warning: { button: generateIntents(config.warning) },
    danger: { button: generateIntents(config.danger) },
    sm: {},
    lg: {}
  };
}

module.exports = {
  defaultConfig,
  defaultOptions
};
