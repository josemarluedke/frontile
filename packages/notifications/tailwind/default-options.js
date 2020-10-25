const defaultTheme = require('tailwindcss/resolveConfig')(
  require('tailwindcss/defaultConfig')
).theme;

const defaultConfig = {
  textColor: defaultTheme.colors.white,
  zIndex: 1000,
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

function generateAppearance({ color, buttonHoverColor }) {
  return {
    baseStyle: {
      backgroundColor: color
    },

    parts: {
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

  const notificationEnteringFrom = {
    right: {
      transform: 'translate3d(125%, 0, 0)'
    },

    left: {
      transform: 'translate3d(-125%, 0, 0)'
    },

    top: {
      transform: 'translate3d(0, -125%, 0)'
    },

    bottom: {
      transform: 'translate3d(0, 125%, 0)'
    }
  };

  const zoomOut = {
    leaveTo: {
      transform: 'scale(0.80)',
      opacity: 0
    },
    leave: {
      transform: 'translate3d(0,0,0)'
    }
  };

  return {
    container: {
      baseStyle: {
        width: '100%',
        maxHeight: '100%',
        overflow: 'hidden',
        paddingLeft: defaultTheme.padding[4],
        paddingRight: defaultTheme.padding[4],
        position: 'fixed',
        zIndex: config.zIndex,
        maxWidth: defaultTheme.maxWidth.lg
      },

      variants: {
        topLeft: {
          top: 0,
          left: 0
        },
        topCenter: {
          top: 0,
          left: '50%',
          transform: 'translateX(-50%)'
        },
        topRight: {
          top: 0,
          right: 0
        },
        bottomLeft: {
          bottom: 0,
          left: 0
        },
        bottomCenter: {
          bottom: 0,
          left: '50%',
          transform: 'translateX(-50%)'
        },
        bottomRight: {
          bottom: 0,
          right: 0
        }
      }
    },
    card: {
      baseStyle: {
        transitionProperty: defaultTheme.transitionProperty.all,
        transitionDuration: defaultTheme.transitionDuration[200],
        transitionTimingFunction:
          defaultTheme.transitionTimingFunction['in-out'],
        color: config.textColor,
        fontSize: defaultTheme.fontSize.sm,
        borderRadius: defaultTheme.borderRadius.default,
        boxShadow: defaultTheme.boxShadow.default,
        position: 'relative',
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        minHeight: defaultTheme.height[16],
        overflow: 'hidden',
        paddingTop: defaultTheme.padding[3],
        paddingBottom: defaultTheme.padding[3],
        paddingRight: defaultTheme.padding[4],
        paddingLeft: defaultTheme.padding[4]
      },

      variants: {
        info: generateAppearance(config.info),
        success: generateAppearance(config.success),
        warning: generateAppearance(config.warning),
        error: generateAppearance(config.error)
      },

      parts: {
        message: {
          flexGrow: 1
        },
        closeBtn: {
          display: 'inline-block',
          padding: defaultTheme.spacing[2],
          marginLeft: defaultTheme.spacing[2],
          marginRight: `-${defaultTheme.spacing[2]}`,
          borderRadius: defaultTheme.borderRadius.full,
          fontSize: 'inherit'
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
    transitions: {
      slideFromTopLeft: {
        ...zoomOut,
        enter: {
          ...notificationEnteringFrom.left
        }
      },
      slideFromTopCenter: {
        ...zoomOut,
        enter: notificationEnteringFrom.top
      },
      slideFromTopRight: {
        ...zoomOut,
        enter: notificationEnteringFrom.right
      },
      slideFromBottomLeft: {
        ...zoomOut,
        enter: notificationEnteringFrom.left
      },
      slideFromBottomCenter: {
        ...zoomOut,
        enter: notificationEnteringFrom.bottom
      },
      slideFromBottomRight: {
        ...zoomOut,
        enter: notificationEnteringFrom.right
      }
    }
  };
}

module.exports = {
  defaultConfig,
  defaultOptions
};
