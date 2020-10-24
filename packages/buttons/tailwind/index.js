const plugin = require('tailwindcss/plugin');
const {
  resolveComponents,
  isEmpty,
  kebabCase,
  merge
} = require('@frontile/tailwindcss-plugin-helpers');

function addSinglePartComponent(addComponents, baseSelector, options) {
  if (isEmpty(options)) {
    return;
  }

  const { baseStyle, variants } = options;

  let defaultVariant = {};
  if (variants && !isEmpty(variants.default)) {
    defaultVariant = variants.default;
    delete variants.default;
  }

  addComponents({
    [baseSelector]: merge(baseStyle, defaultVariant)
  });

  if (!isEmpty(variants)) {
    Object.keys(variants).forEach((key) => {
      addComponents({
        [`${baseSelector}--${kebabCase(key)}`]: variants[key]
      });
    });
  }
}

module.exports = plugin.withOptions(function () {
  return function ({ addComponents, theme }) {
    const { components } = resolveComponents(
      theme('frontile.buttons') || {},
      require('./default-options')
    );

    addSinglePartComponent(addComponents, '.btn', components.default);
    addSinglePartComponent(addComponents, '.btn-outlined', components.outlined);
    addSinglePartComponent(addComponents, '.btn-minimal', components.minimal);
  };
});
