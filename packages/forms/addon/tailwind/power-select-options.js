const defaultTheme = require('tailwindcss/resolveConfig')(
  require('tailwindcss/defaultConfig')
).theme;
const { merge } = require('./helpers');

const defaultConfig = {
  textColor: 'inherit',
  disabledTextColor: defaultTheme.borderColor.gray[500],
  placeholderTextColor: defaultTheme.borderColor.gray[500],
  backgroundColor: defaultTheme.colors.white,
  dropdownMargin: defaultTheme.spacing[1],

  // Selected option
  selectedBackgroundColor: defaultTheme.colors.gray[200],
  selectedTextColor: null,

  // Highlighted option (aka hover)
  highlightedBackgroundColor: defaultTheme.colors.blue[500],
  highlightedTextColor: defaultTheme.colors.white,

  // Multiple option
  multipleOptionBackgroundColor: defaultTheme.colors.gray[600],
  multipleOptionTextColor: defaultTheme.colors.white,

  // Box Shadow
  triggerFocusBoxShadow: defaultTheme.boxShadow.outline,
  searchInputFocusBoxShadow: defaultTheme.boxShadow.outline,
  dropdownBoxShadow: defaultTheme.boxShadow.md,

  // Border color
  borderColor: defaultTheme.colors.gray[500],
  focusBorderColor: defaultTheme.colors.gray[800],
  disabledBorderColor: defaultTheme.borderColor.gray[300],
  invalidBorderColor: defaultTheme.borderColor.red[600],

  // Border Radius
  triggerBorderRadius: defaultTheme.borderRadius.default,
  dropdownBorderRadius: defaultTheme.borderRadius.default,
  searchInputBorderRadius: defaultTheme.borderRadius.default,
  multipleOptionBorderRadius: defaultTheme.borderRadius.default,
  openedBorderRadius: defaultTheme.borderRadius.default
};

module.exports = function(customConfig) {
  const config = merge(defaultConfig, customConfig);

  return {
    default: {
      trigger: {
        position: 'relative',
        borderColor: config.borderColor,
        borderWidth: defaultTheme.borderWidth.default,
        borderRadius: config.triggerBorderRadius,
        width: defaultTheme.width.full,
        backgroundColor: config.backgroundColor,
        fontSize: defaultTheme.fontSize.base,
        color: config.textColor,
        lineHeight: defaultTheme.lineHeight.tight,
        padding: defaultTheme.spacing[3],
        overflowX: 'hidden',
        textOverflow: 'ellipsis',
        minHeight: `calc((${defaultTheme.fontSize.base} * ${defaultTheme.lineHeight.snug}) + ${defaultTheme.spacing[6]})`,
        userSelect: 'none',
        '&:focus': {
          boxShadow: config.triggerFocusBoxShadow,
          borderColor: config.focusBorderColor
        },
        /* Minimum clearfix for modern browsers */
        '&:after': {
          content: '""',
          display: 'table',
          clear: 'both'
        },
        '&[aria-expanded="true"]': {
          '.ember-power-select-status-icon': {
            transform: 'rotate(180deg)'
          }
        },
        '&[aria-disabled=true]': {
          borderColor: config.disabledBorderColor,
          color: config.disabledTextColor
        },
        '&[aria-invalid=true]': {
          borderColor: config.invalidBorderColor
        }
      },
      placeholder: {
        display: 'block',
        overflowX: 'hidden',
        whiteSpace: 'nowrap',
        textOverflow: 'ellipsis',
        color: config.placeholderTextColor,
        lineHeight: defaultTheme.lineHeight.tight
      },
      statusIcon: {
        position: 'absolute',
        display: 'inline-block',
        height: '1em',
        width: '1em',
        right: defaultTheme.spacing[3],
        top: '0',
        bottom: '0',
        margin: 'auto',
        minHeight: defaultTheme.fontSize.base,
        transition:
          'background-image .25s ease-in-out,transform .25s ease-in-out',
        iconColor: 'currentColor',
        icon: iconColor =>
          `<svg viewBox="0 0 16 16" color="${iconColor}" xmlns="http://www.w3.org/2000/svg"><path fill="none" stroke="currentColor" stroke-linecap="round" d="M4 6.5l3.6 3.6c.2.2.5.2.7 0L12 6.5" /></svg>`
      },
      clearBtn: {
        display: 'inline-block',
        position: 'absolute',
        cursor: 'pointer',
        right: defaultTheme.spacing[8],
        top: '0',
        bottom: '0',
        margin: 'auto',
        textIndent: '-9999rem',
        height: '1em',
        width: '1em',
        iconColor: 'currentColor',
        icon: iconColor =>
          `<svg viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path stroke="${iconColor}" d="M5 5L8 8M11 11L8 8M8 8L5 11L11 5"/></svg>`
      },

      // Search
      search: {
        paddingTop: defaultTheme.spacing[2],
        paddingRight: defaultTheme.spacing[2],
        paddingLeft: defaultTheme.spacing[2]
      },
      searchInput: {
        borderColor: config.borderColor,
        borderWidth: defaultTheme.borderWidth.default,
        borderRadius: config.searchInputBorderRadius,
        width: defaultTheme.width.full,
        backgroundColor: config.backgroundColor,
        fontSize: defaultTheme.fontSize.base,
        lineHeight: defaultTheme.lineHeight.tight,
        padding: defaultTheme.spacing[3],
        '&:focus': {
          outline: 'none',
          boxShadow: config.searchInputFocusBoxShadow,
          borderColor: config.focusBorderColor
        }
      },

      // Dropdown
      dropdown: {
        color: config.textColor,
        borderColor: config.borderColor,
        borderWidth: defaultTheme.borderWidth.default,
        borderRadius: config.dropdownBorderRadius,
        boxShadow: config.dropdownBoxShadow,
        '&.ember-basic-dropdown-content--in-place': {
          width: defaultTheme.width.full
        },
        '&.ember-basic-dropdown-content--above': {
          transform:
            config.dropdownMargin && config.dropdownMargin !== '0'
              ? `translateY(calc(-1 * ${config.dropdownMargin}))`
              : null,
          borderBottomLeftRadius: config.openedBorderRadius,
          borderBottomRightRadius: config.openedBorderRadius
        },
        '&.ember-basic-dropdown-content--below, &.ember-basic-dropdown-content--in-place': {
          transform:
            config.dropdownMargin && config.dropdownMargin !== '0'
              ? `translateY(${config.dropdownMargin})`
              : null,
          borderTopLeftRadius: config.openedBorderRadius,
          borderTopRightRadius: config.openedBorderRadius
        }
      },

      // Options
      options: {
        listStyle: 'none',
        marginTop: defaultTheme.spacing[2],
        marginBottom: defaultTheme.spacing[2],
        marginLeft: '0',
        marginRight: '0',
        padding: '0',
        userSelect: 'none',
        '&[role="listbox"]': {
          overflowY: 'auto',
          '-webkit-overflow-scrolling': 'touch',
          maxHeight: defaultTheme.spacing[48]
        }
      },
      option: {
        cursor: 'pointer',
        paddingLeft: defaultTheme.spacing[3],
        paddingRight: defaultTheme.spacing[3],
        paddingTop: defaultTheme.spacing[1],
        paddingBottom: defaultTheme.spacing[1],
        '&[aria-disabled="true"]': {
          color: config.disabledTextColor,
          cursor: 'not-allowed'
        },
        '&[aria-selected="true"]': {
          backgroundColor: config.selectedBackgroundColor,
          color: config.selectedTextColor
        },
        '&[aria-current="true"]': {
          backgroundColor: config.highlightedBackgroundColor,
          color: config.highlightedTextColor
        }
      },
      group: {
        '.ember-power-select-group': {
          '.ember-power-select-group-name': {
            paddingLeft: defaultTheme.spacing[8]
          },
          '.ember-power-select-option': {
            paddingLeft: defaultTheme.spacing[12]
          }
        },
        '.ember-power-select-option': {
          paddingLeft: defaultTheme.spacing[8]
        },
        '.ember-power-select-group-name': {
          paddingLeft: defaultTheme.spacing[3]
        },
        '&[aria-disabled=true]': {
          borderColor: config.disabledBorderColor,
          color: config.disabledTextColor,
          '.ember-power-select-option': {
            cursor: 'not-allowed'
          }
        }
      },
      groupName: {
        fontWeight: defaultTheme.fontWeight.bold
      },

      // multiple
      triggerMultipleInput: {
        display: 'inline-flex',
        marginTop: '0.15rem',
        alignSelf: 'baseline',
        '&:focus': {
          outline: 'none'
        }
      },
      multipleOptions: {
        display: 'flex',
        flexWrap: 'wrap',
        alignItems: 'center',
        paddingRight: defaultTheme.spacing[6],
        marginTop: `-0.15rem`, // Discount to make one line items not take more space
        marginBottom: `-0.40rem` // Discount marginBottom from option
      },
      multipleOption: {
        display: 'flex',
        alignItems: 'center',
        backgroundColor: config.multipleOptionBackgroundColor,
        color: config.multipleOptionTextColor,
        borderRadius: config.multipleOptionBorderRadius,
        fontSize: defaultTheme.fontSize.sm,
        lineHeight: defaultTheme.lineHeight.tight,
        paddingTop: defaultTheme.spacing[1],
        paddingRight: defaultTheme.spacing[2],
        paddingBottom: defaultTheme.spacing[1],
        paddingLeft: defaultTheme.spacing[1],
        marginRight: defaultTheme.spacing[1],
        marginBottom: defaultTheme.spacing[1],
        '&:first-child': {
          marginLeft: 0
        },
        '&:last-child': {
          marginRight: 0
        }
      },
      multipleRemoveBtn: {
        lineHeight: defaultTheme.lineHeight.tight,
        display: 'inline-block',
        cursor: 'pointer',
        textIndent: '-9999rem',
        marginTop: '0.15em',
        transition: 'opacity .20s ease-in-out',
        height: '1em',
        width: '1em',
        iconColor: config.multipleOptionTextColor,
        icon: iconColor =>
          `<svg fill="${iconColor}" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg"><path d="M9.41 8l2.29-2.29c.19-.18.3-.43.3-.71a1.003 1.003 0 0 0-1.71-.71L8 6.59l-2.29-2.3a1.003 1.003 0 0 0-1.42 1.42L6.59 8 4.3 10.29c-.19.18-.3.43-.3.71a1.003 1.003 0 0 0 1.71.71L8 9.41l2.29 2.29c.18.19.43.3.71.3a1.003 1.003 0 0 0 .71-1.71L9.41 8z" /></svg>`,
        '&:not(:hover)': {
          opacity: 0.5
        }
      }
    },
    sm: {
      trigger: {
        fontSize: defaultTheme.fontSize.sm,
        padding: defaultTheme.spacing[2],
        minHeight: `calc((${defaultTheme.fontSize.sm} * ${defaultTheme.lineHeight.snug}) + ${defaultTheme.spacing[4]})`,
        '.ember-power-select-multiple-options': {
          marginTop: '-0.05rem'
        },
        '.ember-power-select-multiple-option': {
          fontSize: defaultTheme.fontSize.xs,
          paddingTop: '0.15rem',
          paddingRight: defaultTheme.spacing[1],
          paddingBottom: '0.15rem',
          paddingLeft: '0.15rem'
        }
      }
    },
    lg: {
      trigger: {
        padding: defaultTheme.spacing[4],
        minHeight: `calc((${defaultTheme.fontSize.base} * ${defaultTheme.lineHeight.snug}) + ${defaultTheme.spacing[8]})`
      }
    }
  };
};
