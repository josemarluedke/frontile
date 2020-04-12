const plugin = require('tailwindcss/plugin');
const {
  merge,
  replaceIconDeclarations,
  resolve,
  svgToDataUri,
  isEmpty,
  camelCaseToDash
} = require('@frontile/tailwindcss-plugin-helpers');

module.exports = plugin.withOptions(function (userConfig) {
  return function ({ addComponents, theme }) {
    const { config, options } = resolve(
      '@frontile/forms',
      require('./addon/tailwind/default-options'),
      userConfig,
      theme
    );

    function addFormElementComponent(key, options, modifier = '', prefix = '') {
      if (isEmpty(options)) {
        return;
      }

      addComponents({ [`${prefix}.form__${key}${modifier}`]: options });
    }

    // To be used with Radio and Checkbox elements
    function addFromElementWithIcon(key, options, modifier = '', prefix = '') {
      if (isEmpty(options)) {
        return;
      }

      addComponents(
        replaceIconDeclarations(
          {
            [`${prefix}.form__${key}${modifier}`]: merge(
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
    }

    function addFormContainerComponents(key, options, modifier) {
      const {
        label,
        input,
        textarea,
        checkbox,
        radio,
        hint,
        feedback,
        labelContainer,
        inputContainer,
        ...rest
      } = options || {};

      const className = `.form-${key}-container${modifier}`;

      if (!isEmpty(rest)) {
        addComponents({ [className]: rest });
      }

      addFormElementComponent('label', label, modifier, `${className} `);
      addFormElementComponent('input', input, modifier, `${className} > `);
      addFormElementComponent(
        'textarea',
        textarea,
        modifier,
        `${className} > `
      );
      addFormElementComponent(
        'feedback',
        feedback,
        modifier,
        `${className} > `
      );
      addFromElementWithIcon('checkbox', checkbox, modifier, `${className} > `);
      addFromElementWithIcon('radio', radio, modifier, `${className} > `);

      if (!isEmpty(hint)) {
        let hintOptions = hint;

        // Make sure to set up the fontSize for hint before
        if (hintOptions['&::before'] !== undefined && modifier === '') {
          hintOptions = merge(hintOptions, {
            '&::before': {
              fontSize: rest.fontSize || '1rem'
            }
          });
        }

        addFormElementComponent(
          'hint',
          hintOptions,
          modifier,
          `${className} > `
        );
      }

      // Used in FormCheckbox and FormRadio components
      if (!isEmpty(labelContainer)) {
        addComponents({
          [`.form-${key}-container__label-container`]: labelContainer
        });
      }
      if (!isEmpty(inputContainer)) {
        addComponents({
          [`.form-${key}-container__input-container`]: inputContainer
        });
      }
    }

    Object.keys(options).forEach((key) => {
      const {
        label,
        input,
        textarea,
        checkbox,
        radio,
        hint,
        feedback,

        formInputContainer,
        formTextareaContainer,
        formCheckboxGroup,
        formRadioGroup,
        formCheckboxContainer,
        formRadioContainer,
        formSelectContainer
      } = options[key] || {};

      const modifier = key === 'default' ? '' : `--${camelCaseToDash(key)}`;

      addFormElementComponent('label', label, modifier);
      addFormElementComponent('input', input, modifier);
      addFormElementComponent('textarea', textarea, modifier);
      addFormElementComponent('hint', hint, modifier);
      addFormElementComponent('feedback', feedback, modifier);
      addFromElementWithIcon('checkbox', checkbox, modifier);
      addFromElementWithIcon('radio', radio, modifier);

      addFormContainerComponents('input', formInputContainer, modifier);
      addFormContainerComponents('textarea', formTextareaContainer, modifier);
      addFormContainerComponents('checkbox', formCheckboxContainer, modifier);
      addFormContainerComponents('radio', formRadioContainer, modifier);
      addFormContainerComponents('select', formSelectContainer, modifier);
      addFormContainerComponents('checkbox-group', formCheckboxGroup, modifier);
      addFormContainerComponents('radio-group', formRadioGroup, modifier);
    });

    const { powerSelect: powerSelectOptions } = options.default || {};

    require('tailwindcss-ember-power-select').registerComponents(
      { addComponents },
      powerSelectOptions,
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
