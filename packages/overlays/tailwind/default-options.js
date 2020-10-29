const defaultTheme = require('tailwindcss/resolveConfig')(
  require('tailwindcss/defaultConfig')
).theme;

const defaultConfig = {
  textColor: 'inherit',
  zIndex: 50,
  borderRadius: defaultTheme.borderRadius.default,
  backdropColor: 'rgba(0, 0, 0, 0.45)',
  'modal, drawer': {
    backgroundColor: defaultTheme.colors.white,
    boxShadow: defaultTheme.boxShadow.default,
    closeBtnMargin: defaultTheme.spacing[2],

    header: {
      padding: defaultTheme.padding[4]
    },

    body: {
      padding: defaultTheme.padding[4]
    },

    footer: {
      borderColor: defaultTheme.borderColor.default,
      padding: defaultTheme.padding[4],
      backgroundColor: defaultTheme.colors.gray[100]
    },

    obscurer: {
      disabled: false,
      size: defaultTheme.padding[4],
      background: `linear-gradient(180deg, rgba(255, 255, 255, 0) 0%, rgba(255, 255, 255, 0.8) 50%, ${defaultTheme.colors.white} 100%)`
    },

    sizes: {
      xs: '20rem',
      sm: '24rem',
      md: '28rem',
      lg: '32rem',
      xl: '36rem',
      full: '100%'
    }
  }
};

const inset0 = {
  top: 0,
  bottom: 0,
  right: 0,
  left: 0
};

const slideTransition = {
  enterActive: {
    transition: 'transform 0.2s cubic-bezier(0.37, 0, 0.63, 1)'
  },

  leaveActive: {
    transition: 'transform 0.2s cubic-bezier(0.37, 0, 0.63, 1)'
  }
};

const getObscurer = (options) => {
  return options.disabled
    ? undefined
    : {
        position: 'absolute',
        top: `calc(-${options.size} - ${defaultTheme.borderWidth.default})`,
        left: 0,
        content: '" "',
        height: options.size,
        width: '100%',
        background: options.background
      };
};

function defaultOptions({ config }) {
  return {
    overlay: {
      baseStyle: {
        color: config.textColor,
        zIndex: config.zIndex
      },

      parts: {
        backdrop: {
          ...inset0,
          position: 'fixed',
          backgroundColor: config.backdropColor,
          userSelect: 'none',
          zIndex: 1
        },

        content: {
          ...inset0,
          alignItems: 'center',
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          overflow: 'auto',
          position: 'fixed',
          '-webkit-overflow-scrolling': 'touch',
          zIndex: 2,
          willChange: 'transform'
        }
      },

      variants: {
        inPlace: {
          parts: {
            backdrop: {
              position: 'absolute'
            },
            content: {
              position: 'absolute'
            }
          }
        }
      }
    },
    modal: {
      baseStyle: {
        display: 'flex',
        flexDirection: 'column',
        flexShrink: 0,
        position: 'relative',
        backgroundColor: config.modal.backgroundColor,
        borderRadius: config.borderRadius,
        boxShadow: config.modal.boxShadow,
        marginBottom: defaultTheme.margin[24],
        marginTop: defaultTheme.spacing[24],
        width: defaultTheme.width.full,
        outline: 'none',
        overflow: 'hidden',
        zIndex: 0
      },

      parts: {
        closeBtn: {
          position: 'absolute',
          top: config.modal.closeBtnMargin,
          right: config.modal.closeBtnMargin,
          zIndex: 1
        },

        header: {
          fontWeight: defaultTheme.fontWeight.bold,
          fontSize: defaultTheme.fontSize.xl,
          padding: config.modal.header.padding,
          borderTopRightRadius: config.borderRadius,
          borderTopLeftRadius: config.borderRadius
        },
        body: {
          flexGrow: 1,
          padding: config.modal.body.padding,
          overflowY: 'scroll',
          '-webkit-overflow-scrolling': 'touch'
        },
        footer: {
          display: 'flex',
          justifyContent: 'flex-end',
          backgroundColor: config.modal.footer.backgroundColor,
          borderTopWidth: defaultTheme.borderWidth.default,
          borderTopColor: config.modal.footer.borderColor,
          padding: config.modal.footer.padding,
          alignItems: 'center',
          position: 'relative',
          '&:before': getObscurer(config.modal.obscurer)
        }
      },

      variants: {
        centered: {
          baseStyle: {
            marginTop: 'auto',
            marginBottom: 'auto'
          }
        },

        ...['xs', 'sm', 'md', 'lg', 'xl', 'full'].reduce((obj, key) => {
          if (key === 'full') {
            obj[key] = {
              baseStyle: {
                width: config.modal.sizes[key],
                height: config.modal.sizes[key],
                marginTop: 'auto',
                marginBottom: 'auto',
                borderRadius: 0
              }
            };
          } else {
            obj[key] = {
              baseStyle: {
                maxWidth: config.modal.sizes[key],
                [`@media (max-width: ${config.modal.sizes[key]})`]: {
                  maxWidth: `calc(100vw - ${defaultTheme.margin[4]})`
                }
              }
            };
          }
          return obj;
        }, {})
      }
    },

    drawer: {
      baseStyle: {
        display: 'flex',
        flexDirection: 'column',
        position: 'absolute',
        backgroundColor: config.drawer.backgroundColor,
        width: '100%',
        height: '100%',
        boxShadow: config.drawer.boxShadow.default,
        zIndex: 0
      },

      parts: {
        closeBtn: {
          position: 'absolute',
          top: config.drawer.closeBtnMargin,
          right: config.drawer.closeBtnMargin,
          zIndex: 1
        },

        header: {
          fontWeight: defaultTheme.fontWeight.bold,
          fontSize: defaultTheme.fontSize.xl,
          padding: config.drawer.header.padding
        },

        body: {
          flexGrow: 1,
          flexBasis: 0,
          padding: config.drawer.body.padding,
          overflowY: 'scroll',
          '-webkit-overflow-scrolling': 'touch'
        },

        footer: {
          display: 'flex',
          justifyContent: 'flex-end',
          backgroundColor: config.drawer.footer.backgroundColor,
          borderTopWidth: defaultTheme.borderWidth.default,
          borderTopColor: config.drawer.footer.borderColor,
          padding: config.drawer.footer.padding,
          alignItems: 'center',
          position: 'relative',
          '&:before': getObscurer(config.drawer.obscurer)
        }
      },

      variants: {
        top: {
          baseStyle: {
            top: 0,
            right: 0,
            left: 0
          }
        },
        bottom: {
          baseStyle: {
            bottom: 0,
            right: 0,
            left: 0
          }
        },
        left: {
          baseStyle: {
            left: 0,
            top: 0,
            bottom: 0
          }
        },
        right: {
          baseStyle: {
            right: 0,
            top: 0,
            bottom: 0
          }
        },
        ...['xs', 'sm', 'md', 'lg', 'xl', 'full'].reduce((obj, key) => {
          obj[`${key}-vertical`] = {
            baseStyle: {
              maxHeight: config.drawer.sizes[key],
              [`@media (max-height: calc(${config.drawer.sizes[key]} + ${defaultTheme.margin[8]}))`]:
                key === 'full'
                  ? undefined
                  : {
                      maxHeight: `calc(100vh - ${defaultTheme.margin[8]})`
                    }
            }
          };

          obj[`${key}-horizontal`] = {
            baseStyle: {
              maxWidth: config.drawer.sizes[key],
              [`@media (max-width: calc(${config.drawer.sizes[key]} + ${defaultTheme.margin[8]}))`]:
                key === 'full'
                  ? undefined
                  : {
                      maxWidth: `calc(100vw - ${defaultTheme.margin[8]})`
                    }
            }
          };

          return obj;
        }, {})
      }
    },

    transitions: {
      fade: {
        enter: {
          opacity: 0
        },
        enterActive: {
          transition: 'opacity 0.2s linear'
        },
        leave: {
          opacity: 1
        },
        leaveActive: {
          transition: 'opacity 0.2s linear'
        }
      },
      zoom: {
        enter: {
          opacity: 0,
          transform: 'scale(0.8)'
        },
        enterActive: {
          transition: 'all 0.2s ease-in-out'
        },
        leave: {
          opacity: 1,
          transform: 'scale(1)'
        },
        leaveActive: {
          transition: 'all 0.2s ease-in-out'
        }
      },
      slideFromLeft: {
        enter: {
          transform: 'translateX(-100%)'
        },
        leave: {
          transform: 'translateX(0%)'
        },
        ...slideTransition
      },
      slideFromRight: {
        enter: {
          transform: 'translateX(100%)'
        },
        leave: {
          transform: 'translateX(0%)'
        },
        ...slideTransition
      },

      slideFromTop: {
        enter: {
          transform: 'translateY(-100%)'
        },
        leave: {
          transform: 'translateY(0%)'
        },
        ...slideTransition
      },
      slideFromBottom: {
        enter: {
          transform: 'translateY(100%)'
        },
        leave: {
          transform: 'translateY(0%)'
        },
        ...slideTransition
      }
    }
  };
}

module.exports = {
  defaultConfig,
  defaultOptions
};
