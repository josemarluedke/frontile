const defaultTheme = require('tailwindcss/resolveConfig')(
  require('tailwindcss/defaultConfig')
).theme;

module.exports = function(/*{ theme }*/) {
  return {
    hint: {
      color: defaultTheme.colors.gray[500],
      fontSize: defaultTheme.fontSize.xs,
      paddingBottom: defaultTheme.spacing[1],
      '&:last-child': {
        paddingBottom: defaultTheme.spacing[0]
      }
    },
    feedback: {
      '&.is-error': {
        color: defaultTheme.colors.red[600],
        fontSize: defaultTheme.fontSize.xs,
        paddingTop: defaultTheme.spacing[1]
      }
    },
    label: {
      display: 'inline-block',
      color: defaultTheme.colors.gray[800],
      fontWeight: defaultTheme.fontWeight.semibold,
      lineHeight: defaultTheme.lineHeight.tight,
      paddingBottom: defaultTheme.spacing[1]
    },
    input: {
      appearance: 'none',
      width: defaultTheme.width.full,
      backgroundColor: defaultTheme.colors.white,
      borderColor: defaultTheme.colors.gray[500],
      borderWidth: defaultTheme.borderWidth.default,
      borderRadius: defaultTheme.borderRadius.default,
      paddingTop: defaultTheme.spacing[3],
      paddingRight: defaultTheme.spacing[3],
      paddingBottom: defaultTheme.spacing[3],
      paddingLeft: defaultTheme.spacing[3],
      fontSize: defaultTheme.fontSize.base,
      lineHeight: defaultTheme.lineHeight.tight,
      '&::placeholder': {
        color: defaultTheme.colors.gray[500],
        opacity: '1'
      },
      '&:focus': {
        outline: 'none',
        borderColor: defaultTheme.colors.gray[800]
      },
      '&.has-error': {
        borderColor: defaultTheme.colors.red[600]
      },
      container: {},
      label: {}
    },
    textarea: {
      appearance: 'none',
      width: defaultTheme.width.full,
      backgroundColor: defaultTheme.colors.white,
      borderColor: defaultTheme.colors.gray[500],
      borderWidth: defaultTheme.borderWidth.default,
      borderRadius: defaultTheme.borderRadius.default,
      paddingTop: defaultTheme.spacing[3],
      paddingRight: defaultTheme.spacing[3],
      paddingBottom: defaultTheme.spacing[3],
      paddingLeft: defaultTheme.spacing[3],
      fontSize: defaultTheme.fontSize.base,
      lineHeight: defaultTheme.lineHeight.tight,
      minHeight: defaultTheme.height[24],
      '&::placeholder': {
        color: defaultTheme.colors.gray[500],
        opacity: '1'
      },
      '&:focus': {
        outline: 'none',
        borderColor: defaultTheme.colors.gray[800]
      }
    },
    checkbox: {
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
      fontSize: '1rem',
      color: defaultTheme.colors.blue[500],
      backgroundColor: defaultTheme.colors.white,
      borderColor: defaultTheme.borderColor.gray[500],
      borderWidth: defaultTheme.borderWidth.default,
      borderRadius: defaultTheme.borderRadius.sm,
      iconColor: defaultTheme.colors.white,
      icon: iconColor =>
        `<svg viewBox="0 0 16 16" fill="${iconColor}" xmlns="http://www.w3.org/2000/svg"><path d="M5.125 7.666a1.304 1.304 0 00-.882-.328 1.3 1.3 0 00-.876.343c-.232.216-.364.51-.367.816-.003.307.124.602.352.822l2.508 2.339c.235.219.554.342.886.342.333 0 .651-.123.887-.342l5.015-4.677c.228-.22.355-.516.352-.822a1.132 1.132 0 00-.367-.817A1.301 1.301 0 0011.757 5a1.304 1.304 0 00-.882.328l-4.129 3.85-1.621-1.512z"/></svg>`,
      '&:focus': {
        outline: 'none'
      },
      '&.focus-visible:focus': {
        boxShadow: defaultTheme.boxShadow.outline,
        borderColor: defaultTheme.colors.blue[400]
      },
      '&:checked': {
        borderColor: 'transparent',
        backgroundColor: 'currentColor',
        backgroundSize: '100% 100%',
        backgroundPosition: 'center',
        backgroundRepeat: 'no-repeat'
      },
      container: {
        display: 'flex',
        flexWrap: 'wrap',
        alignItems: 'center',
        paddingBottom: defaultTheme.spacing[1],
        '&:last-child': {
          paddingBottom: defaultTheme.spacing[0]
        }
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
          height: '1em'
        }
      }
    },
    radio: {
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
      borderRadius: '100%',
      height: '1em',
      width: '1em',
      color: defaultTheme.colors.blue[500],
      backgroundColor: defaultTheme.colors.white,
      borderColor: defaultTheme.borderColor.gray[500],
      borderWidth: defaultTheme.borderWidth.default,
      iconColor: defaultTheme.colors.white,
      icon: iconColor =>
        `<svg viewBox="0 0 16 16"  xmlns="http://www.w3.org/2000/svg"><circle cx="8" cy="8" r="6" stroke="${iconColor}" stroke-width="3" fill="none" /></svg>`,
      '&:focus': {
        outline: 'none'
      },
      '&.focus-visible:focus': {
        boxShadow: defaultTheme.boxShadow.outline,
        borderColor: defaultTheme.colors.blue[400]
      },
      '&:checked': {
        borderColor: 'transparent',
        backgroundColor: 'currentColor',
        backgroundSize: '100% 100%',
        backgroundPosition: 'center',
        backgroundRepeat: 'no-repeat'
      },
      container: {
        display: 'flex',
        flexWrap: 'wrap',
        alignItems: 'center',
        paddingBottom: defaultTheme.spacing[1],
        '&:last-child': {
          paddingBottom: defaultTheme.spacing[0]
        }
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
          height: '1em'
        }
      }
    },
    checkboxGroup: {
      label: {
        paddingBottom: defaultTheme.spacing[2]
      },
      feedback: {
        paddingTop: defaultTheme.spacing[0]
      }
    },
    radioGroup: {
      label: {
        paddingBottom: defaultTheme.spacing[2]
      },
      feedback: {
        paddingTop: defaultTheme.spacing[0]
      }
    }
  };
};
