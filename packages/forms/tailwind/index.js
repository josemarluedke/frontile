const plugin = require('tailwindcss/plugin');
const {
  merge,
  map,
  fromPairs,
  replaceIconDeclarations,
  resolve,
  svgToDataUri,
  isEmpty,
  kebabCase,
  flattenOptions,
  addSinglePartComponent
} = require('@frontile/tailwindcss-plugin-helpers');

module.exports = plugin.withOptions(function (userConfig) {
  return function ({ addComponents, theme }) {
    const { config, options } = resolve(
      '@frontile/forms',
      require('./default-options'),
      userConfig,
      theme
    );

    function replaceIconFn({
      icon = options.icon,
      iconColor = options.iconColor
    }) {
      return {
        '&:checked': {
          backgroundImage: `url("${svgToDataUri(
            typeof icon === 'function' ? icon(iconColor) : icon
          )}")`
        }
      };
    }

    addSinglePartComponent(
      addComponents,
      '.form-field-checkbox',
      options.checkbox,
      replaceIconFn
    );
    addSinglePartComponent(
      addComponents,
      '.form-field-feedback',
      options.feedback,
      replaceIconFn
    );
    addSinglePartComponent(
      addComponents,
      '.form-field-hint',
      options.hint,
      replaceIconFn
    );
    addSinglePartComponent(
      addComponents,
      '.form-field-input',
      options.input,
      replaceIconFn
    );
    addSinglePartComponent(
      addComponents,
      '.form-field-label',
      options.label,
      replaceIconFn
    );
    addSinglePartComponent(
      addComponents,
      '.form-field-radio',
      options.radio,
      replaceIconFn
    );
    addSinglePartComponent(
      addComponents,
      '.form-field-textarea',
      options.textarea,
      replaceIconFn
    );

    // OLD ---

    function addFormElementComponent(
      namespace,
      key,
      options,
      modifier = '',
      prefix = ''
    ) {
      if (isEmpty(options)) {
        return;
      }

      addComponents({
        [`${namespace}${prefix}.form__${key}${modifier}`]: options
      });
    }

    // To be used with Radio and Checkbox elements
    function addFromElementWithIcon(
      namespace,
      key,
      options,
      modifier = '',
      prefix = ''
    ) {
      if (isEmpty(options)) {
        return;
      }

      addComponents(
        replaceIconDeclarations(
          {
            [`${namespace}${prefix}.form__${key}${modifier}`]: merge(
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

    function addFormContainerComponents(namespace, key, options, modifier) {
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

      const className = `${namespace}.form-${key}-container${modifier}`;

      if (!isEmpty(rest)) {
        addComponents({ [className]: rest });
      }

      addFormElementComponent(
        namespace,
        'label',
        label,
        modifier,
        `${className} `
      );
      addFormElementComponent(
        namespace,
        'input',
        input,
        modifier,
        `${className} > `
      );
      addFormElementComponent(
        namespace,
        'textarea',
        textarea,
        modifier,
        `${className} > `
      );
      addFormElementComponent(
        namespace,
        'feedback',
        feedback,
        modifier,
        `${className} > `
      );
      addFromElementWithIcon(
        namespace,
        'checkbox',
        checkbox,
        modifier,
        `${className} > `
      );
      addFromElementWithIcon(
        namespace,
        'radio',
        radio,
        modifier,
        `${className} > `
      );

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
          namespace,
          'hint',
          hintOptions,
          modifier,
          `${className} > `
        );
      }

      // Used in FormCheckbox and FormRadio components
      if (!isEmpty(labelContainer)) {
        addComponents({
          [`${namespace}.form-${key}-container__label-container`]: labelContainer
        });
      }
      if (!isEmpty(inputContainer)) {
        addComponents({
          [`${namespace}.form-${key}-container__input-container`]: inputContainer
        });
      }
    }

    function addNamespaced(namespace, options) {
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

        const modifier = key === 'default' ? '' : `--${kebabCase(key)}`;

        addFormElementComponent(namespace, 'label', label, modifier);
        addFormElementComponent(namespace, 'input', input, modifier);
        addFormElementComponent(namespace, 'textarea', textarea, modifier);
        addFormElementComponent(namespace, 'hint', hint, modifier);
        addFormElementComponent(namespace, 'feedback', feedback, modifier);
        addFromElementWithIcon(namespace, 'checkbox', checkbox, modifier);
        addFromElementWithIcon(namespace, 'radio', radio, modifier);

        addFormContainerComponents(
          namespace,
          'input',
          formInputContainer,
          modifier
        );
        addFormContainerComponents(
          namespace,
          'textarea',
          formTextareaContainer,
          modifier
        );
        addFormContainerComponents(
          namespace,
          'checkbox',
          formCheckboxContainer,
          modifier
        );
        addFormContainerComponents(
          namespace,
          'radio',
          formRadioContainer,
          modifier
        );
        addFormContainerComponents(
          namespace,
          'select',
          formSelectContainer,
          modifier
        );
        addFormContainerComponents(
          namespace,
          'checkbox-group',
          formCheckboxGroup,
          modifier
        );
        addFormContainerComponents(
          namespace,
          'radio-group',
          formRadioGroup,
          modifier
        );
      });
    }

    const { namespaced } = options;
    options.namespaced = undefined;
    addNamespaced('', options);

    if (namespaced && Object.keys(namespaced).length > 0) {
      Object.keys(namespaced).forEach((namespace) => {
        const namespacedOptions = fromPairs(
          map(namespaced[namespace], (value, key) => [
            key,
            flattenOptions(value)
          ])
        );

        // Work around to allow change color of icons in namespace
        Object.keys(namespacedOptions).forEach((key) => {
          Object.keys(namespacedOptions[key]).forEach((k) => {
            if (
              k === 'checkbox' ||
              (k === 'radio' && namespacedOptions[key][k].iconColor)
            ) {
              namespacedOptions[key][k].icon = options[key][k].icon;
            }
          });
        });

        addNamespaced(`${namespace} `, namespacedOptions);
      });
    }

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
