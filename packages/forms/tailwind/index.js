const plugin = require('tailwindcss/plugin');
const {
  merge,
  resolveComponents,
  svgToDataUri,
  addSinglePartComponent,
  addMultipartComponent
} = require('@frontile/tailwindcss-plugin-helpers');

module.exports = plugin.withOptions(function () {
  return function ({ addComponents, theme }) {
    const { config, components } = resolveComponents(
      theme('frontile.forms'),
      require('./default-options')
    );

    function replaceIconFn({
      icon = components.icon,
      iconColor = components.iconColor
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
        components[key],
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
      addMultipartComponent(addComponents, selector, components[key]);
    });

    const { powerSelect: powerSelectOptions } = components || {};

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
