const toPairs = require('lodash/toPairs');
const fromPairs = require('lodash/fromPairs');
const mergeWith = require('lodash/mergeWith');
const flatMap = require('lodash/flatMap');
const isPlainObject = require('lodash/isPlainObject');
const traverse = require('traverse');

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
      return fromPairs(keys.split(', ').map(key => [key, value]));
    })
  );
}

function replaceIconDeclarations(component, replace) {
  return traverse(component).map(function(value) {
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

module.exports = {
  merge,
  flattenOptions,
  replaceIconDeclarations
};
