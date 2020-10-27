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
  addSinglePartComponent,
  addMultipartComponent
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

    [
      ['.form-field-checkbox', 'checkbox'],
      ['.form-field-feedback', 'feedback'],
      ['.form-field-hint', 'hint'],
      ['.form-field-input', 'input'],
      ['.form-field-label', 'label'],
      ['.form-field-radio', 'radio'],
      ['.form-field-textarea', 'textarea']
    ].forEach(([selector, key]) => {
      addSinglePartComponent(
        addComponents,
        selector,
        options[key],
        replaceIconFn
      );
    });

    [
      ['.form-input', 'formInput'],
      ['.form-textarea', 'formTextarea'],
      ['.form-select', 'formSelect'],
      ['.form-checkbox', 'formCheckbox'],
      ['.form-radio', 'formRadio'],
      ['.form-checkbox-group', 'formRadioGroup'],
      ['.form-radio-group', 'formRadioGroup']
    ].forEach(([selector, key]) => {
      addMultipartComponent(addComponents, selector, options[key]);
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
