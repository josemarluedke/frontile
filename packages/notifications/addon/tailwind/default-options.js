const defaultTheme = require('tailwindcss/resolveConfig')(
  require('tailwindcss/defaultConfig')
).theme;

const defaultConfig = {
  textColor: defaultTheme.colors.white,
  info: {
    color: defaultTheme.colors.gray[900],
    buttonHoverColor: defaultTheme.colors.gray[800]
  },
  success: {
    color: defaultTheme.colors.blue[700],
    buttonHoverColor: defaultTheme.colors.blue[800]
  },
  warning: {
    color: defaultTheme.colors.yellow[600],
    buttonHoverColor: defaultTheme.colors.yellow[700]
  },
  error: {
    color: defaultTheme.colors.red[600],
    buttonHoverColor: defaultTheme.colors.red[700]
  }
};

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

function generateAppearance({ color, buttonHoverColor }) {
  return {
    card: {
      backgroundColor: color,
      closeBtn: {
        '&:hover': {
          backgroundColor: buttonHoverColor
        }
      },
      customActionBtn: {
        '&:hover': {
          backgroundColor: buttonHoverColor
        }
      }
    }
  };
}

function defaultOptions({ config }) {
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
        margin: defaultTheme.padding[4],
        position: 'fixed',
        zIndex: 1000,
        maxWidth: defaultTheme.maxWidth.lg,
        ...placements
      },
      card: {
        transitionProperty: defaultTheme.transitionProperty.default,
        transitionDuration: defaultTheme.transitionDuration[200],
        color: config.textColor,
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
        '&.is-removing': {
          opacity: 0
        },
        '&:not(:last-child)': {
          marginBottom: defaultTheme.spacing[4]
        },
        message: {
          flexGrow: 1
        },
        closeBtn: {
          display: 'inline-block',
          padding: defaultTheme.spacing[2],
          marginLeft: defaultTheme.spacing[2],
          marginRight: `-${defaultTheme.spacing[2]}`,
          borderRadius: defaultTheme.borderRadius.full,
          ...btnShared
        },
        closeBtnIcon: {
          height: '1em',
          width: '1em',
          backgroundRepeat: 'no-repeat',
          iconColor: config.textColor,
          icon: iconColor =>
            `<svg fill="none" viewBox="0 0 24 24" stroke="${iconColor}" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>`
        },
        customActions: {
          display: 'flex',
          flexWrap: 'nowrap'
        },
        customActionBtn: {
          fontWeight: defaultTheme.fontWeight.semibold,
          paddingTop: defaultTheme.spacing[1],
          paddingBottom: defaultTheme.spacing[1],
          paddingLeft: defaultTheme.spacing[2],
          paddingRight: defaultTheme.spacing[2],
          borderRadius: defaultTheme.borderRadius.default,
          ...btnShared,

          '&:first-child': {
            marginLeft: defaultTheme.spacing[4]
          },
          '&:last-child': {
            marginRight: `-${defaultTheme.spacing[2]}`
          }
        }
      }
    },
    info: generateAppearance(config.info),
    success: generateAppearance(config.success),
    warning: generateAppearance(config.warning),
    error: generateAppearance(config.error)
  };
}

module.exports = {
  defaultConfig,
  defaultOptions
};
