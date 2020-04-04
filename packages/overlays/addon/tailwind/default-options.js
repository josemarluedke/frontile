const defaultTheme = require('tailwindcss/resolveConfig')(
  require('tailwindcss/defaultConfig')
).theme;

const defaultConfig = {
  // empty for now
};

function defaultOptions(/*{ config }*/) {
  return {
    default: {
      transitions: {
        fade: {
          enter: {
            opacity: 0
          },
          enterActive: {
            opacity: 1,
            transition: 'opacity 0.2s linear'
          },
          leave: {
            opacity: 1
          },
          leaveActive: {
            opacity: 0,
            transition: 'opacity 0.2s linear'
          }
        },
        zoom: {
          enter: {
            opacity: 0,
            transform: 'scale(0.8)'
          },
          enterActive: {
            opacity: 1,
            transform: 'scale(1)',
            transition: 'all 0.2s ease-in-out'
          },
          leave: {
            opacity: 1,
            transform: 'scale(1)'
          },
          leaveActive: {
            opacity: 0,
            transform: 'scale(0.8)',
            transition: 'all 0.2s ease-in-out'
          }
        }
      },

      overlay: {
        zIndex: 50,
        overflow: 'auto',
        position: 'fixed',
        top: 0,
        bottom: 0,
        right: 0,
        left: 0,

        '-webkit-overflow-scrolling': 'touch',

        jsIsOpen: {
          overflow: 'hidden'
        },

        backdrop: {
          position: 'fixed',
          top: 0,
          bottom: 0,
          right: 0,
          left: 0,
          overflow: 'auto',
          backgroundColor: 'rgba(0, 0, 0, 0.45)',
          userSelect: 'none'
        },

        content: {
          position: 'relative'
        }
      },
      modal: {
        position: 'relative',
        backgroundColor: defaultTheme.colors.white,
        borderRadius: defaultTheme.borderRadius.default,
        boxShadow: defaultTheme.boxShadow.default,
        maxWidth: defaultTheme.maxWidth['xl'],
        marginLeft: 'auto',
        marginRight: 'auto',
        outline: 'none',
        top: defaultTheme.spacing[24],
        marginBottom: defaultTheme.margin[4],

        [`@media (max-width: ${defaultTheme.screens.sm})`]: {
          maxWidth: `calc(100vw - ${defaultTheme.margin[4]})`
        },

        closeBtn: {
          display: 'flex',
          position: 'absolute',
          padding: defaultTheme.spacing[2],
          top: defaultTheme.padding[2],
          right: defaultTheme.padding[2],
          transitionProperty: defaultTheme.transitionProperty.default,
          transitionDuration: defaultTheme.transitionDuration[200],
          '&:hover': {
            backgroundColor: defaultTheme.colors.gray[200]
          },

          '&.focus-visible:focus': {
            outline: 'none',
            boxShadow: defaultTheme.boxShadow.outline
          },

          borderRadius: defaultTheme.borderRadius.full,
          icon: {
            display: 'inline-block',
            height: '1em',
            width: '1em',
            backgroundRepeat: 'no-repeat',
            iconColor: 'currentColor',
            icon: (iconColor) =>
              `<svg fill="none" viewBox="0 0 24 24" stroke="${iconColor}" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>`
          }
        },

        header: {
          fontWeight: defaultTheme.fontWeight.bold,
          paddingTop: defaultTheme.padding[4],
          paddingBottom: defaultTheme.padding[4],
          paddingRight: defaultTheme.padding[4],
          paddingLeft: defaultTheme.padding[4]
        },
        body: {
          paddingTop: defaultTheme.padding[4],
          paddingBottom: defaultTheme.padding[8],
          paddingRight: defaultTheme.padding[4],
          paddingLeft: defaultTheme.padding[4]
        },
        footer: {
          display: 'flex',
          justifyContent: 'flex-end',
          backgroundColor: defaultTheme.colors.gray[200],
          borderTopWidth: defaultTheme.borderWidth.default,
          borderTopColor: defaultTheme.borderColor.default,
          paddingTop: defaultTheme.padding[4],
          paddingBottom: defaultTheme.padding[4],
          paddingRight: defaultTheme.padding[4],
          paddingLeft: defaultTheme.padding[4],
          borderBottomRightRadius: defaultTheme.borderRadius.default,
          borderBottomLeftRadius: defaultTheme.borderRadius.default
        }
      }
    },
    'in-place': {
      overlay: {
        position: 'absolute',

        backdrop: {
          position: 'absolute'
        }
      }
    }
  };
}

module.exports = {
  defaultConfig,
  defaultOptions
};
