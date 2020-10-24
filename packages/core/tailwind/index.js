const plugin = require('tailwindcss/plugin');
const {
  merge,
  resolveComponents,
  isEmpty,
  kebabCase
} = require('@frontile/tailwindcss-plugin-helpers');

function addMultipartComponent(
  addComponents,
  baseSelector,
  options,
  modifier = ''
) {
  if (isEmpty(options)) {
    return;
  }

  if (modifier !== '') {
    baseSelector += `--${modifier}`;
  }

  const { baseStyle, variants, parts } = options;

  let defaultVariant = {};
  if (variants && !isEmpty(variants.default)) {
    defaultVariant = variants.default;
    delete variants.default;
  }

  addComponents({
    [baseSelector]: merge(baseStyle, defaultVariant)
  });

  if (!isEmpty(parts)) {
    Object.keys(parts).forEach((key) => {
      addComponents({
        [`${baseSelector}__${kebabCase(key)}`]: parts[key]
      });
    });
  }

  if (!isEmpty(variants)) {
    Object.keys(variants).forEach((key) => {
      addMultipartComponent(
        addComponents,
        baseSelector,
        variants[key],
        kebabCase(key)
      );
    });
  }
}

module.exports = plugin.withOptions(function () {
  return function ({ addComponents, theme }) {
    const { components } = resolveComponents(
      theme('frontile.core') || {},
      require('./default-options')
    );

    addMultipartComponent(
      addComponents,
      '.close-button',
      components.closeButton
    );
  };
});
