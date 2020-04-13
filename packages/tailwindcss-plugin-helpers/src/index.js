const isEmpty = require('lodash/isEmpty');
const toPairs = require('lodash/toPairs');
const fromPairs = require('lodash/fromPairs');
const mergeWith = require('lodash/mergeWith');
const map = require('lodash/map');
const flatMap = require('lodash/flatMap');
const isPlainObject = require('lodash/isPlainObject');
const traverse = require('traverse');
const svgToDataUri = require('mini-svg-data-uri');

function merge(...options) {
  function mergeCustomizer(objValue, srcValue, key, obj, src) {
    if (isPlainObject(srcValue)) {
      return mergeWith(objValue, srcValue, mergeCustomizer);
    }
    return Object.keys(src).includes(key)
      ? // Convert undefined to null otherwise lodash won't replace the key
        // PostCSS still omits properties with a null value so it behaves
        // the same as undefined.
        srcValue === undefined
        ? null
        : srcValue
      : objValue;
  }

  return mergeWith({}, ...options, mergeCustomizer);
}

function flattenOptions(options) {
  return merge(
    ...flatMap(toPairs(options), ([keys, value]) => {
      return fromPairs(keys.split(', ').map((key) => [key, value]));
    })
  );
}

function replaceIconDeclarations(component, replace) {
  return traverse(component).map(function (value) {
    if (!isPlainObject(value)) {
      return;
    }

    if (
      Object.keys(value).includes('iconColor') ||
      Object.keys(value).includes('icon')
    ) {
      const { iconColor, icon, ...rest } = value;
      this.update(merge(replace({ icon, iconColor }), rest));
    }
  });
}

function resolveOptions(userOptionsName, defaultOptions, config, theme) {
  return merge(
    fromPairs(
      map(defaultOptions({ theme, config }), (value, key) => [
        key,
        flattenOptions(value)
      ])
    ),
    fromPairs(
      map(theme(userOptionsName), (value, key) => [key, flattenOptions(value)])
    )
  );
}

function resolveConfig(defaultConfig, userConfig, theme) {
  if (typeof userConfig === 'function') {
    userConfig = userConfig({ theme });
  }
  return merge(defaultConfig, userConfig || {});
}

function resolve(optionsName, params, userConfig, theme) {
  const { defaultConfig, defaultOptions } = params;
  const config = resolveConfig(defaultConfig, userConfig, theme);
  const options = resolveOptions(optionsName, defaultOptions, config, theme);

  return {
    config,
    options
  };
}

function camelCaseToDash(str) {
  return str.replace(/([a-zA-Z])(?=[A-Z])/g, '$1-').toLowerCase();
}

module.exports = {
  merge,
  isEmpty,
  flattenOptions,
  replaceIconDeclarations,
  resolveOptions,
  resolveConfig,
  resolve,
  svgToDataUri,
  camelCaseToDash
};
