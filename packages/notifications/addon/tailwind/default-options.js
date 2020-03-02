const defaultTheme = require('tailwindcss/resolveConfig')(
  require('tailwindcss/defaultConfig')
).theme;

const defaultConfig = {
  // empty for now
};

function defaultOptions(/*{ config }*/) {
  const placements = {
    '&.top-left': { top: 0, left: 0 },
    '&.top-center': { top: 0, left: '50%', transform: 'translateX(-50%)' },
    '&.top-right': { top: 0, right: 0 },
    '&.bottom-left': { bottom: 0, left: 0 },
    '&.bottom-center': {
      bottom: 0,
      left: '50%',
      transform: 'translateX(-50%)'
    },
    '&.bottom-right': { bottom: 0, right: 0 }
  };

  const btnShared = {
    transitionProperty: defaultTheme.transitionProperty.default,
    transitionDuration: defaultTheme.transitionDuration[200],

    '&.focus-visible:focus': {
      outline: 'none',
      boxShadow: defaultTheme.boxShadow.outline
    }
  };

  return {
    default: {
      container: {
        width: '100%',
        maxHeight: '100%',
        overflow: 'hidden',
        padding: defaultTheme.padding[4],
        position: 'fixed',
        zIndex: 1000,
        maxWidth: defaultTheme.maxWidth.lg,
        ...placements
      },
      card: {
        transitionProperty: defaultTheme.transitionProperty.default,
        transitionDuration: defaultTheme.transitionDuration[200],
        color: defaultTheme.colors.white,
        fontSize: defaultTheme.fontSize.sm,
        borderRadius: defaultTheme.borderRadius.default,
        boxShadow: defaultTheme.boxShadow.default,
        position: 'relative',
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        minHeight: defaultTheme.height[16],
        paddingTop: defaultTheme.padding[3],
        paddingBottom: defaultTheme.padding[3],
        paddingRight: defaultTheme.padding[4],
        paddingLeft: defaultTheme.padding[4],
        '&:not(:last-child)': {
          marginBottom: defaultTheme.spacing[4]
        },
        '.message': {
          flexGrow: 1
        },
        '.close-btn': {
          display: 'inline-block',
          padding: defaultTheme.spacing[2],
          marginLeft: defaultTheme.spacing[2],
          marginRight: `-${defaultTheme.spacing[2]}`,
          borderRadius: defaultTheme.borderRadius.full,
          ...btnShared
        },
        '.close-btn-icon': {
          height: '1em',
          width: '1em',
          backgroundRepeat: 'no-repeat',
          iconColor: defaultTheme.colors.white,
          icon: iconColor =>
            `<svg fill="none" viewBox="0 0 24 24" stroke="${iconColor}" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>`
        },
        '.custom-actions': {
          display: 'flex',
          flexWrap: 'nowrap'
        },
        '.custom-action-btn': {
          fontWeight: defaultTheme.fontWeight.semibold,
          paddingTop: defaultTheme.spacing[1],
          paddingBottom: defaultTheme.spacing[1],
          paddingLeft: defaultTheme.spacing[2],
          paddingRight: defaultTheme.spacing[2],
          borderRadius: defaultTheme.borderRadius.default,
          marginRight: `-${defaultTheme.spacing[2]}`,
          ...btnShared,

          '&:first-child': {
            marginLeft: defaultTheme.spacing[4]
          },
          '&:not(:last-child)': {
            marginRight: defaultTheme.spacing[2]
          }
        }
      }
    },
    info: {
      card: {
        backgroundColor: defaultTheme.colors.gray[900],
        '.close-btn': {
          '&:hover': {
            backgroundColor: defaultTheme.colors.gray[800]
          }
        },
        '.custom-action-btn': {
          '&:hover': {
            backgroundColor: defaultTheme.colors.gray[800]
          }
        }
      }
    },
    success: {
      card: {
        backgroundColor: defaultTheme.colors.blue[700],
        '.close-btn': {
          '&:hover': {
            backgroundColor: defaultTheme.colors.blue[800]
          }
        },
        '.custom-action-btn': {
          '&:hover': {
            backgroundColor: defaultTheme.colors.blue[800]
          }
        }
      }
    },
    warning: {
      card: {
        backgroundColor: defaultTheme.colors.yellow[600],
        '.close-btn': {
          '&:hover': {
            backgroundColor: defaultTheme.colors.yellow[700]
          }
        },
        '.custom-action-btn': {
          '&:hover': {
            backgroundColor: defaultTheme.colors.yellow[700]
          }
        }
      }
    },
    error: {
      card: {
        backgroundColor: defaultTheme.colors.red[600],
        '.close-btn': {
          '&:hover': {
            backgroundColor: defaultTheme.colors.red[700]
          }
        },
        '.custom-action-btn': {
          '&:hover': {
            backgroundColor: defaultTheme.colors.red[700]
          }
        }
      }
    }
  };
}

module.exports = {
  defaultConfig,
  defaultOptions
};
