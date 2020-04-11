const defaultTheme = require('tailwindcss/resolveConfig')(
  require('tailwindcss/defaultConfig')
).theme;

const defaultConfig = {
  textColor: 'inherit',
  zIndex: 50,
  borderRadius: defaultTheme.borderRadius.default,
  backdropColor: 'rgba(0, 0, 0, 0.45)',
  modal: {
    padding: defaultTheme.padding[4],
    backgroundColor: defaultTheme.colors.white,
    secondaryBackgroundColor: defaultTheme.colors.gray[100], // Background for footer and close btn applied on hover
    iconColor: 'currentColor',
    borderColor: defaultTheme.borderColor.default,
    maxWidth: defaultTheme.maxWidth['xl']
  }
};

function defaultOptions({ config }) {
  const inset0 = {
    top: 0,
    bottom: 0,
    right: 0,
    left: 0
  };

  return {
    default: {
      overlay: {
        color: config.textColor,
        zIndex: config.zIndex,
        jsIsOpen: {
          overflow: 'hidden'
        },

        backdrop: {
          ...inset0,
          position: 'fixed',
          backgroundColor: config.backdropColor,
          userSelect: 'none'
        },

        content: {
          ...inset0,
          position: 'fixed',
          overflow: 'auto',
          display: 'flex',
          flexDirection: 'column',
          '-webkit-overflow-scrolling': 'touch'
        }
      },
      modal: {
        backgroundColor: config.modal.backgroundColor,
        borderRadius: config.borderRadius,
        boxShadow: defaultTheme.boxShadow.default,
        marginBottom: defaultTheme.margin[24],
        marginLeft: 'auto',
        marginRight: 'auto',
        marginTop: defaultTheme.spacing[24],
        width: defaultTheme.width.full,
        maxWidth: config.modal.maxWidth,
        outline: 'none',
        position: 'relative',

        [`@media (max-width: ${defaultTheme.screens.sm})`]: {
          maxWidth: `calc(100vw - ${defaultTheme.margin[4]})`
        },

        closeBtn: {
          display: 'flex',
          position: 'absolute',
          fontSize: defaultTheme.fontSize.xl,
          padding: defaultTheme.spacing[2],
          top: defaultTheme.padding[2],
          right: defaultTheme.padding[2],
          transitionProperty: defaultTheme.transitionProperty.default,
          transitionDuration: defaultTheme.transitionDuration[200],
          borderRadius: defaultTheme.borderRadius.full,

          '&:hover': {
            backgroundColor: config.modal.secondaryBackgroundColor
          },

          '&.focus-visible:focus': {
            outline: 'none',
            boxShadow: defaultTheme.boxShadow.outline
          },

          icon: {
            height: '1em',
            width: '1em',
            backgroundRepeat: 'no-repeat',
            iconColor: config.modal.iconColor,
            icon: (iconColor) =>
              `<svg fill="none" stroke="${iconColor}" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M6 18L18 6M6 6l12 12"></path></svg>`
          }
        },
        header: {
          fontWeight: defaultTheme.fontWeight.bold,
          fontSize: defaultTheme.fontSize.xl,
          padding: config.modal.padding,
          borderTopRightRadius: config.borderRadius,
          borderTopLeftRadius: config.borderRadius
        },
        body: {
          padding: config.modal.padding
        },
        footer: {
          display: 'flex',
          justifyContent: 'flex-end',
          backgroundColor: config.modal.secondaryBackgroundColor,
          borderTopWidth: defaultTheme.borderWidth.default,
          borderTopColor: config.modal.borderColor,
          padding: config.modal.padding,
          borderBottomRightRadius: config.borderRadius,
          borderBottomLeftRadius: config.borderRadius
        }
      },
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
      }
    },
    'in-place': {
      overlay: {
        backdrop: {
          position: 'absolute'
        },
        content: {
          position: 'absolute'
        }
      }
    },
    centered: {
      modal: {
        marginTop: 'auto',
        marginBottom: 'auto'
      }
    }
  };
}

module.exports = {
  defaultConfig,
  defaultOptions
};
