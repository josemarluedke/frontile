const plugin = require('tailwindcss/plugin');
const map = require('lodash/map');
const fromPairs = require('lodash/fromPairs');
const isEmpty = require('lodash/isEmpty');
const svgToDataUri = require('mini-svg-data-uri');
const { merge, flattenOptions, replaceIconDeclarations } = require('./helpers');
const { defaultConfig, defaultOptions } = require('./default-options');

function resolveOptions(userOptions, params) {
  return merge(
    defaultOptions(params),
    fromPairs(map(userOptions, (value, key) => [key, flattenOptions(value)]))
  );
}

module.exports = plugin.withOptions(function(customConfig) {
  return function({ addComponents, theme }) {
    if (typeof customConfig === 'function') {
      customConfig = customConfig({ theme });
    }

    const config = merge(defaultConfig, customConfig || {});
    const options = resolveOptions(theme('@frontile/forms'), {
      theme,
      config
    });

    function addRelatedComponents(key, options, modifier) {
      if (options.container !== undefined) {
        addComponents({
          [`.form-${key}-container${modifier}`]: options.container
        });
      }

      if (options.label !== undefined) {
        addComponents({
          [`.form-${key}-container${modifier} .form-field-label${modifier}`]: options.label
        });
      }

      if (options.hint !== undefined) {
        let hint = options.hint;

        if (hint['&::before'] !== undefined) {
          hint = merge(options.hint, {
            '&::before': {
              fontSize: options.fontSize || '1rem'
            }
          });
        }

        addComponents({
          [`.form-${key}-container${modifier} > .form-field-hint${modifier}`]: hint
        });
      }

      if (options.feedback !== undefined) {
        addComponents({
          [`.form-${key}-container${modifier} > .form-field-feedback${modifier}`]: options.feedback
        });
      }
    }

    function addLabel(options, modifier = '') {
      if (isEmpty(options)) {
        return;
      }

      addComponents({ [`.form-field-label${modifier}`]: options });
    }

    function addHint(options, modifier = '') {
      if (isEmpty(options)) {
        return;
      }

      addComponents({ [`.form-field-hint${modifier}`]: options });
    }

    function addFeedback(options, modifier = '') {
      if (isEmpty(options)) {
        return;
      }

      addComponents({ [`.form-field-feedback${modifier}`]: options });
    }

    function addInput(options, modifier = '') {
      if (isEmpty(options)) {
        return;
      }

      addComponents({ [`.form-input${modifier}`]: options });
      addRelatedComponents('input', options, modifier);
    }

    function addTextarea(options, modifier = '') {
      if (isEmpty(options)) {
        return;
      }

      addComponents({ [`.form-textarea${modifier}`]: options });
      addRelatedComponents('textarea', options, modifier);
    }

    function addCheckbox(options, modifier = '') {
      if (isEmpty(options)) {
        return;
      }

      addComponents(
        replaceIconDeclarations(
          {
            [`.form-checkbox${modifier}`]: merge(
              options.borderWidth === undefined
                ? {}
                : {
                    '&::-ms-check': {
                      '@media not print': {
                        borderWidth: options.borderWidth
                      }
                    }
                  },
              options
            )
          },
          ({ icon = options.icon, iconColor = options.iconColor }) => {
            return {
              '&:checked': {
                backgroundImage: `url("${svgToDataUri(
                  typeof icon === 'function' ? icon(iconColor) : icon
                )}")`
              }
            };
          }
        )
      );

      addRelatedComponents('checkbox', options, modifier);
    }

    function addRadio(options, modifier = '') {
      if (isEmpty(options)) {
        return;
      }

      addComponents(
        replaceIconDeclarations(
          {
            [`.form-radio${modifier}`]: merge(
              options.borderWidth === undefined
                ? {}
                : {
                    '&::-ms-check': {
                      '@media not print': {
                        borderWidth: options.borderWidth
                      }
                    }
                  },
              options
            )
          },
          ({ icon = options.icon, iconColor = options.iconColor }) => {
            return {
              '&:checked': {
                backgroundImage: `url("${svgToDataUri(
                  typeof icon === 'function' ? icon(iconColor) : icon
                )}")`
              }
            };
          }
        )
      );

      addRelatedComponents('radio', options, modifier);
    }

    function addCheckboxGroup(options, modifier = '') {
      if (isEmpty(options)) {
        return;
      }

      addComponents({ [`.form-checkbox-group-container${modifier}`]: options });

      // Make sure to remove container as group styles are the container
      delete options.container;

      addRelatedComponents('checkbox-group', options, modifier);
    }

    function addRadioGroup(options, modifier = '') {
      if (isEmpty(options)) {
        return;
      }

      addComponents({ [`.form-radio-group-container${modifier}`]: options });

      // Make sure to remove container as group styles are the container
      delete options.container;

      addRelatedComponents('radio-group', options, modifier);
    }

    const selectOptions = {};

    Object.keys(options).forEach(key => {
      selectOptions[key] = options[key].select || {};
      delete options[key].select;

      const modifier = key === 'default' ? '' : `-${key}`;

      addLabel(options[key].label || {}, modifier);
      addInput(options[key].input || {}, modifier);
      addTextarea(options[key].textarea || {}, modifier);
      addCheckbox(options[key].checkbox || {}, modifier);
      addRadio(options[key].radio || {}, modifier);
      addHint(options[key].hint || {}, modifier);
      addFeedback(options[key].feedback || {}, modifier);
      addCheckboxGroup(options[key].checkboxGroup || {}, modifier);
      addRadioGroup(options[key].radioGroup || {}, modifier);
    });

    require('tailwindcss-ember-power-select').registerComponents(
      { addComponents },
      selectOptions,
      merge(
        {
          textColor: config.textColor,
          disabledTextColor: config.disabledTextColor,
          disabledBorderColor: config.disabledBorderColor,
          placeholderTextColor: config.placeholderTextColor,
          backgroundColor: config.backgroundColor,
          dropdownBackgroundColor: config.backgroundColor,
          borderColor: config.borderColor,
          focusBorderColor: config.focusBorderColor,
          invalidBorderColor: config.invalidColor,
          triggerFocusBoxShadow: config.focusBoxShadow,
          triggerFocusBoxShadowInvalid: config.focusBoxShadowInvalid,
          searchInputFocusBoxShadow: config.focusBoxShadow
        },
        config.powerSelect || {}
      )
    );
  };
});
