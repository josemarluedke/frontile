const defaultTheme = require('tailwindcss/resolveConfig')(
  require('tailwindcss/defaultConfig')
).theme;

const defaultConfig = {
  textColor: defaultTheme.colors.gray[900],
  labelColor: defaultTheme.colors.gray[800],
  placeholderTextColor: defaultTheme.colors.gray[500],
  hintColor: defaultTheme.colors.gray[500],
  disabledTextColor: defaultTheme.colors.gray[500],
  checkboxAndRadioColor: defaultTheme.colors.blue[500],
  checkboxAndRadioIconColor: defaultTheme.colors.white,
  invalidColor: defaultTheme.colors.red[600],
  backgroundColor: defaultTheme.colors.white,
  focusBoxShadow: defaultTheme.boxShadow.outline,
  focusBoxShadowInvalid: '0 0 0 3px rgba(229,62,62, 0.3)',
  borderColor: defaultTheme.borderColor.gray[500],
  focusBorderColor: defaultTheme.colors.blue[400],
  disabledBorderColor: defaultTheme.borderColor.gray[300],
  powerSelect: {}
};

function defaultOptions({ config }) {
  return {
    label: {
      baseStyle: {
        display: 'inline-block',
        color: config.labelColor,
        fontWeight: defaultTheme.fontWeight.semibold,
        lineHeight: defaultTheme.lineHeight.tight,
        paddingBottom: defaultTheme.spacing[1]
      }
    },
    hint: {
      baseStyle: {
        color: config.hintColor,
        fontSize: defaultTheme.fontSize.xs,
        paddingBottom: defaultTheme.spacing[1],
        '&:last-child': {
          paddingBottom: defaultTheme.spacing[0]
        }
      }
    },
    feedback: {
      baseStyle: {
        fontSize: defaultTheme.fontSize.xs,
        paddingTop: defaultTheme.spacing[1]
      },
      variants: {
        error: {
          color: config.invalidColor
        }
      }
    },
    'input, textarea': {
      baseStyle: {
        appearance: 'none',
        flex: defaultTheme.flex[1],
        width: defaultTheme.width.full,
        backgroundColor: config.backgroundColor,
        borderColor: config.borderColor,
        borderWidth: defaultTheme.borderWidth.default,
        borderRadius: defaultTheme.borderRadius.default,
        paddingTop: defaultTheme.spacing[3],
        paddingRight: defaultTheme.spacing[3],
        paddingBottom: defaultTheme.spacing[3],
        paddingLeft: defaultTheme.spacing[3],
        fontSize: defaultTheme.fontSize.base,
        color: config.textColor,
        lineHeight: defaultTheme.lineHeight.tight,
        '&::placeholder': {
          color: config.placeholderTextColor,
          opacity: '1'
        },
        '&:focus': {
          outline: 'none',
          boxShadow: config.focusBoxShadow,
          borderColor: config.focusBorderColor
        },
        '&:disabled': {
          borderColor: config.disabledBorderColor,
          color: config.disabledTextColor
        },
        '&[aria-invalid="true"]': {
          borderColor: config.invalidColor,
          '&:focus': {
            boxShadow: config.focusBoxShadowInvalid
          }
        }
      },
      variants: {
        sm: {
          fontSize: defaultTheme.fontSize.sm,
          paddingTop: defaultTheme.spacing[2],
          paddingRight: defaultTheme.spacing[2],
          paddingBottom: defaultTheme.spacing[2],
          paddingLeft: defaultTheme.spacing[2]
        },
        lg: {
          paddingTop: defaultTheme.spacing[4],
          paddingRight: defaultTheme.spacing[4],
          paddingBottom: defaultTheme.spacing[4],
          paddingLeft: defaultTheme.spacing[4]
        }
      }
    },
    textarea: {
      baseStyle: {
        minHeight: defaultTheme.height[24]
      },
      variants: {
        sm: {
          minHeight: defaultTheme.height[16]
        },
        lg: {
          minHeight: defaultTheme.height[32]
        }
      }
    },

    'checkbox, radio': {
      baseStyle: {
        appearance: 'none',
        colorAdjust: 'exact',
        '&::-ms-check': {
          '@media not print': {
            color: 'transparent', // Hide the check
            background: 'inherit',
            borderColor: 'inherit',
            borderRadius: 'inherit'
          }
        },
        display: 'inline-block',
        verticalAlign: 'middle',
        backgroundOrigin: 'border-box',
        userSelect: 'none',
        flexShrink: 0,
        height: '1em',
        width: '1em',
        fontSize: defaultTheme.fontSize.base,
        color: config.checkboxAndRadioColor,
        backgroundColor: config.backgroundColor,
        borderColor: config.borderColor,
        borderWidth: defaultTheme.borderWidth.default,
        iconColor: config.checkboxAndRadioIconColor,
        '&:focus': {
          outline: 'none'
        },
        '&.focus-visible:focus': {
          boxShadow: config.focusBoxShadow,
          borderColor: config.focusBorderColor
        },
        '&:checked': {
          borderColor: 'transparent',
          backgroundColor: 'currentColor',
          backgroundSize: '100% 100%',
          backgroundPosition: 'center',
          backgroundRepeat: 'no-repeat',
          '&:disabled': {
            color: config.disabledBorderColor
          }
        },
        '&:disabled': {
          borderColor: config.disabledBorderColor
        }
      },
      variants: {
        sm: {
          fontSize: defaultTheme.fontSize.sm
        },
        lg: {
          fontSize: defaultTheme.fontSize.lg
        }
      }
    },
    checkbox: {
      baseStyle: {
        borderRadius: defaultTheme.borderRadius.sm,
        icon: (iconColor) =>
          `<svg viewBox="0 0 16 16" fill="${iconColor}" xmlns="http://www.w3.org/2000/svg"><path d="M5.125 7.666a1.304 1.304 0 00-.882-.328 1.3 1.3 0 00-.876.343c-.232.216-.364.51-.367.816-.003.307.124.602.352.822l2.508 2.339c.235.219.554.342.886.342.333 0 .651-.123.887-.342l5.015-4.677c.228-.22.355-.516.352-.822a1.132 1.132 0 00-.367-.817A1.301 1.301 0 0011.757 5a1.304 1.304 0 00-.882.328l-4.129 3.85-1.621-1.512z"/></svg>`
      }
    },
    radio: {
      baseStyle: {
        borderRadius: defaultTheme.borderRadius.full,
        icon: (iconColor) =>
          `<svg viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg"><circle cx="8" cy="8" r="6" stroke="${iconColor}" stroke-width="3" fill="none" /></svg>`
      }
    },

    default: {
      'formCheckboxGroup, formRadioGroup': {
        '> *': {
          paddingBottom: defaultTheme.spacing[1],
          '&:last-child': {
            paddingBottom: defaultTheme.spacing[0]
          }
        },
        feedback: {
          paddingTop: defaultTheme.spacing[0],
          flex: '1 100%'
        }
      },

      formSelectContainer: {
        display: 'flex',
        flexDirection: 'column'
      },

      'formInputContainer, formTextareaContainer': {
        display: 'flex',
        flexFlow: 'row wrap',
        label: {
          flex: '1 100%'
        },
        hint: {
          flex: '1 100%'
        },
        feedback: {
          flex: '1 100%'
        }
      },

      'formCheckboxContainer, formRadioContainer': {
        display: 'flex',
        flexWrap: 'wrap',
        alignItems: 'center',

        labelContainer: {
          lineHeight: defaultTheme.lineHeight.tight,
          display: 'flex',
          alignItems: 'flex-start'
        },
        inputContainer: {
          display: 'flex',
          alignItems: 'center'
        },
        label: {
          fontWeight: defaultTheme.fontWeight.normal,
          paddingLeft: defaultTheme.spacing[2],
          paddingBottom: defaultTheme.spacing[0]
        },
        hint: {
          flexBasis: '100%',
          paddingLeft: defaultTheme.spacing[2],
          display: 'flex',
          '&::before': {
            content: '""',
            display: 'inline-block',
            width: '1em',
            height: '1em',
            flexShrink: 0
          }
        }
      }
    },

    inline: {
      'formCheckboxGroup, formRadioGroup': {
        display: 'flex',
        flexFlow: 'row wrap',
        alignItems: 'flex-start',
        '> *, > label': {
          paddingRight: defaultTheme.spacing[4],
          paddingBottom: defaultTheme.spacing[0]
        }
      }
    },
    sm: {
      'formCheckboxContainer, formRadioContainer': {
        label: {
          fontSize: defaultTheme.fontSize.sm
        }
      }
    }
  };
}

module.exports = {
  defaultConfig,
  defaultOptions
};
