const isEmpty = require('lodash/isEmpty');
const toPairs = require('lodash/toPairs');
const fromPairs = require('lodash/fromPairs');
const mergeWith = require('lodash/mergeWith');
const kebabCase = require('lodash/kebabCase');
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
      map(flattenOptions(defaultOptions({ theme, config })), (value, key) => [
        key,
        flattenOptions(value)
      ])
    ),

    fromPairs(
      map(flattenOptions(theme(userOptionsName)), (value, key) => [
        key,
        flattenOptions(value)
      ])
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

function resolveComponents({ config: userConfig, extend } = {}, params) {
  const { defaultConfig, defaultOptions } = params;
  const config = merge(
    flattenOptions(defaultConfig),
    flattenOptions(userConfig || {})
  );
  const components = merge(
    flattenOptions(defaultOptions({ config })),
    flattenOptions(extend || {})
  );

  return {
    config,
    components
  };
}

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

  let { baseStyle, variants, parts, namespaces } = options;
  variants = flattenOptions(variants || {});
  parts = flattenOptions(parts || {});

  if (variants && !isEmpty(variants.default)) {
    const defaultVariant = variants.default;
    delete variants.default;
    baseStyle = merge(baseStyle, defaultVariant);
  }

  addComponents({
    [baseSelector]: baseStyle
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

  if (!isEmpty(namespaces)) {
    Object.keys(namespaces).forEach((namespace) => {
      addMultipartComponent(
        addComponents,
        `${namespace} ${baseSelector}`,
        namespaces[namespace]
      );
    });
  }
}

function addComponentsMaybeWithIcon(
  addComponents,
  selector,
  styles,
  replaceIconFn
) {
  if (
    (Object.keys(styles).includes('iconColor') ||
      Object.keys(styles).includes('icon')) &&
    typeof replaceIconFn === 'function'
  ) {
    addComponents(
      replaceIconDeclarations(
        {
          [selector]: styles
        },
        replaceIconFn
      )
    );
  } else {
    addComponents({
      [selector]: styles
    });
  }
}

function addSinglePartComponent(
  addComponents,
  baseSelector,
  options,
  replaceIconFn
) {
  if (isEmpty(options)) {
    return;
  }

  let { baseStyle, variants, namespaces } = options;
  variants = flattenOptions(variants || {});

  if (variants && !isEmpty(variants.default)) {
    const defaultVariant = variants.default;
    delete variants.default;
    baseStyle = merge(baseStyle, defaultVariant);
  }

  addComponentsMaybeWithIcon(
    addComponents,
    baseSelector,
    baseStyle,
    replaceIconFn
  );

  if (!isEmpty(variants)) {
    Object.keys(variants).forEach((key) => {
      if (
        Object.keys(baseStyle).includes('icon') &&
        Object.keys(variants[key]).includes('iconColor') &&
        !Object.keys(variants[key]).includes('icon')
      ) {
        variants[key].icon = baseStyle.icon;
      }

      addComponentsMaybeWithIcon(
        addComponents,
        `${baseSelector}--${kebabCase(key)}`,
        variants[key],
        replaceIconFn
      );
    });
  }

  if (!isEmpty(namespaces)) {
    Object.keys(namespaces).forEach((namespace) => {
      if (
        Object.keys(baseStyle).includes('icon') &&
        Object.keys(namespaces[namespace].baseStyle || {}).includes(
          'iconColor'
        ) &&
        !Object.keys(namespaces[namespace].baseStyle || {}).includes('icon')
      ) {
        namespaces[namespace].baseStyle.icon = baseStyle.icon;
      }

      addSinglePartComponent(
        addComponents,
        `${namespace} ${baseSelector}`,
        namespaces[namespace],
        replaceIconFn
      );
    });
  }
}

function addTransitions(addComponents, baseSelector, transitions) {
  if (isEmpty(transitions)) {
    return;
  }

  Object.keys(transitions).forEach((key) => {
    const transition = transitions[key];

    if (isEmpty(transition)) {
      return;
    }
    const name = `${baseSelector}--${kebabCase(key)}`;

    const {
      enter,
      enterTo,
      leave,
      leaveActive,
      enterActive,
      leaveTo
    } = transition;

    addComponents({
      [`${name}-enter`]: enter,
      [`${name}-enter-to`]: enterTo || leave,
      [`${name}-leave`]: leave,
      [`${name}-leave-to`]: leaveTo || enter,
      [`${name}-enter-active`]: enterActive,
      [`${name}-leave-active`]: leaveActive
    });
  });
}

module.exports = {
  map,
  merge,
  fromPairs,
  isEmpty,
  flattenOptions,
  replaceIconDeclarations,
  resolveOptions,
  resolveConfig,
  resolve,
  svgToDataUri,
  kebabCase,
  resolveComponents,
  addMultipartComponent,
  addSinglePartComponent,
  addTransitions
};
