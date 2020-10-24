const plugin = require('tailwindcss/plugin');
const {
  resolve,
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

module.exports = plugin.withOptions(function (userConfig) {
  return function ({ addComponents, theme }) {
    const { options } = resolve(
      '@frontile/buttons',
      require('./default-options'),
      userConfig,
      theme
    );

    addSinglePartComponent(addComponents, '.btn', options.default);
    addSinglePartComponent(addComponents, '.btn-outlined', options.outlined);
    addSinglePartComponent(addComponents, '.btn-minimal', options.minimal);
  };
});
