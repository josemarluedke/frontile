const defaultTheme = require('tailwindcss/resolveConfig')(
  require('tailwindcss/defaultConfig')
).theme;

const defaultConfig = {};

function defaultOptions(/*{ config }*/) {
  const buttonShape = {
    lineHeight: defaultTheme.lineHeight.tight,
    display: 'inline-block',
    fontWeight: defaultTheme.fontWeight.semibold,
    paddingTop: defaultTheme.spacing[3],
    paddingRight: defaultTheme.spacing[4],
    paddingBottom: defaultTheme.spacing[3],
    paddingLeft: defaultTheme.spacing[4],
    borderRadius: defaultTheme.borderRadius.default,
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

  return {
    default: {
      button: {
        default: {
          ...buttonShape,

          color: defaultTheme.colors.white,
          backgroundColor: defaultTheme.colors.gray[900],
          borderColor: defaultTheme.colors.transparent,
          [hover]: {
            backgroundColor: defaultTheme.colors.black
          },
          [active]: {
            backgroundColor: defaultTheme.colors.black
          }
        },
        outlined: {
          ...buttonShape,

          color: defaultTheme.colors.gray[900],
          backgroundColor: defaultTheme.colors.transparent,
          borderColor: defaultTheme.colors.gray[900],
          [hover]: {
            color: defaultTheme.colors.white,
            backgroundColor: defaultTheme.colors.gray[900]
          },
          [active]: {
            color: defaultTheme.colors.white,
            backgroundColor: defaultTheme.colors.black
          }
        },
        minimal: {
          ...buttonShape,

          color: defaultTheme.colors.gray[900],
          backgroundColor: defaultTheme.colors.transparent,
          borderColor: defaultTheme.colors.transparent,
          [hover]: {
            backgroundColor: defaultTheme.colors.gray[200]
          },
          [active]: {
            backgroundColor: defaultTheme.colors.gray[300]
          }
        }
      }
    },
    primary: {
      button: {
        default: {
          color: defaultTheme.colors.white,
          backgroundColor: defaultTheme.colors.blue[700],
          [hover]: {
            backgroundColor: defaultTheme.colors.blue[800]
          },
          [active]: {
            backgroundColor: defaultTheme.colors.blue[900]
          }
        },
        outlined: {
          color: defaultTheme.colors.blue[700],
          borderColor: defaultTheme.colors.blue[700],
          [hover]: {
            color: defaultTheme.colors.white,
            backgroundColor: defaultTheme.colors.blue[700]
          },
          [active]: {
            color: defaultTheme.colors.white,
            backgroundColor: defaultTheme.colors.blue[800]
          }
        },
        minimal: {
          color: defaultTheme.colors.blue[700]
        }
      }
    },
    success: {
      button: {
        default: {
          color: defaultTheme.colors.white,
          backgroundColor: defaultTheme.colors.green[600],
          [hover]: {
            backgroundColor: defaultTheme.colors.green[700]
          },
          [active]: {
            backgroundColor: defaultTheme.colors.green[800]
          }
        },
        outlined: {
          color: defaultTheme.colors.green[600],
          borderColor: defaultTheme.colors.green[600],
          [hover]: {
            color: defaultTheme.colors.white,
            backgroundColor: defaultTheme.colors.green[600]
          },
          [active]: {
            color: defaultTheme.colors.white,
            backgroundColor: defaultTheme.colors.green[700]
          }
        },
        minimal: {
          color: defaultTheme.colors.green[600]
        }
      }
    },
    warning: {
      button: {
        default: {
          color: defaultTheme.colors.white,
          backgroundColor: defaultTheme.colors.yellow[600],
          [hover]: {
            backgroundColor: defaultTheme.colors.yellow[700]
          },
          [active]: {
            backgroundColor: defaultTheme.colors.yellow[800]
          }
        },
        outlined: {
          color: defaultTheme.colors.yellow[600],
          borderColor: defaultTheme.colors.yellow[600],
          [hover]: {
            color: defaultTheme.colors.white,
            backgroundColor: defaultTheme.colors.yellow[600]
          },
          [active]: {
            color: defaultTheme.colors.white,
            backgroundColor: defaultTheme.colors.yellow[700]
          }
        },
        minimal: {
          color: defaultTheme.colors.yellow[600]
        }
      }
    },
    danger: {
      button: {
        default: {
          color: defaultTheme.colors.white,
          backgroundColor: defaultTheme.colors.red[600],
          [hover]: {
            backgroundColor: defaultTheme.colors.red[700]
          },
          [active]: {
            backgroundColor: defaultTheme.colors.red[800]
          }
        },
        outlined: {
          color: defaultTheme.colors.red[600],
          borderColor: defaultTheme.colors.red[600],
          [hover]: {
            color: defaultTheme.colors.white,
            backgroundColor: defaultTheme.colors.red[600]
          },
          [active]: {
            color: defaultTheme.colors.white,
            backgroundColor: defaultTheme.colors.red[700]
          }
        },
        minimal: {
          color: defaultTheme.colors.red[600]
        }
      }
    },
    sm: {},
    lg: {}
  };
}

module.exports = {
  defaultConfig,
  defaultOptions
};
