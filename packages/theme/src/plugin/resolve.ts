import { flatten } from 'flat';
import kebabCase from 'lodash.kebabcase';
import mapKeys from 'lodash.mapkeys';
import Color from 'color';
import deepMerge from 'deepmerge';

import type {
  ConfigThemes,
  DefaultThemeType,
  PluginConfig,
  ConfigTheme
} from '../types';
import type { CSSRuleObject } from 'tailwindcss/types/config';
import { defaultConfig } from './default-config';
import { getContrastingColor } from '../colors/contrast';

const parsedColorsCache: Record<string, number[]> = {};

interface ResolvedConfig {
  variants: { name: string; definition: string[] }[];
  utilities: CSSRuleObject | CSSRuleObject[];
  base: CSSRuleObject | CSSRuleObject[];
  colors: Record<string, string>;
}

/**
 * Determine if a color should have an "on-" variant generated
 *
 * Includes: semantic colors (neutral, brand, success, danger, warning) and surface-solid-*
 * Excludes: surface-overlay-*, background, focus, divider
 */
function shouldGenerateOnColor(colorName: string): boolean {
  // Exclude utility colors
  if (
    colorName === 'background' ||
    colorName === 'focus' ||
    colorName === 'divider'
  ) {
    return false;
  }

  // Exclude surface overlays (they're transparent layers)
  if (colorName.startsWith('surface-overlay')) {
    return false;
  }

  // Include semantic colors (neutral, brand, success, danger, warning)
  const semanticColorPrefixes = [
    'neutral',
    'brand',
    'success',
    'danger',
    'warning'
  ];
  if (semanticColorPrefixes.some((prefix) => colorName.startsWith(prefix))) {
    return true;
  }

  // Include surface solid colors
  if (colorName.startsWith('surface-solid')) {
    return true;
  }

  return false;
}

function resolveThemes(
  themes: ConfigThemes = {},
  defaultTheme: DefaultThemeType
): ResolvedConfig {
  const resolved: ResolvedConfig = {
    variants: [],
    utilities: {},
    base: {},
    colors: {}
  };

  for (const [themeName, { extend, layout, colors }] of Object.entries(
    themes
  )) {
    let cssSelector = `.${themeName}`;
    let baseSelector = '';

    const scheme =
      themeName === 'light' || themeName === 'dark' ? themeName : extend;

    // Add theme-inverse selectors
    if (themeName == 'light') {
      cssSelector = `${cssSelector}, .dark .theme-inverse`;
    } else if (themeName == 'dark') {
      cssSelector = `${cssSelector}, .light .theme-inverse`;
    }

    // if the theme is the default theme, add the selector to the root element
    if (themeName === defaultTheme) {
      baseSelector = `:root, ${cssSelector}`;
    }

    let themeRules: CSSRuleObject = scheme
      ? {
          'color-scheme': scheme
        }
      : {};

    const flatColors = flattenThemeObject(colors) as Record<string, string>;

    const flatLayout = layout
      ? mapKeys(layout, (_, key) => kebabCase(key))
      : {};

    resolved.variants.push({
      name: themeName,
      definition: [`&.${themeName}`]
    });

    /**
     * Colors
     */
    for (const [colorName, colorValue] of Object.entries(flatColors)) {
      if (!colorValue) continue;

      try {
        const parsedColor =
          parsedColorsCache[colorValue] ||
          Color(colorValue).hsl().round().array();

        parsedColorsCache[colorValue] = parsedColor;

        const [h, s, l, defaultAlphaValue] = parsedColor;
        const colorVariable = `--${colorName}`;

        themeRules = { ...themeRules, [colorVariable]: `${h} ${s}% ${l}%` };

        // set the dynamic color in tailwind config theme.colors
        // If color has alpha < 1, use it as fixed alpha; otherwise use dynamic alpha-value
        const alpha =
          defaultAlphaValue !== undefined && defaultAlphaValue < 1
            ? defaultAlphaValue.toString()
            : '<alpha-value>';
        resolved.colors[colorName] = `hsl(var(${colorVariable}) / ${alpha})`;
      } catch (error) {
        // eslint-disable-next-line no-console
        console.log('error', error);
      }
    }

    /**
     * Generate "on-" colors for optimal contrast
     */
    const onColors: Record<string, string> = {};

    for (const [colorName, colorValue] of Object.entries(flatColors)) {
      if (!shouldGenerateOnColor(colorName)) {
        continue;
      }

      try {
        const contrastColor = getContrastingColor(colorValue);

        // Generate the "on-" color name
        const onColorName = `on-${colorName}`;
        onColors[onColorName] = contrastColor;

        // Process the on- color and add to theme
        const parsedColor =
          parsedColorsCache[contrastColor] ||
          Color(contrastColor).hsl().round().array();

        parsedColorsCache[contrastColor] = parsedColor;

        const [h, s, l, defaultAlphaValue] = parsedColor;
        const colorVariable = `--${onColorName}`;

        themeRules = { ...themeRules, [colorVariable]: `${h} ${s}% ${l}%` };

        const alpha =
          defaultAlphaValue !== undefined && defaultAlphaValue < 1
            ? defaultAlphaValue.toString()
            : '<alpha-value>';
        resolved.colors[onColorName] = `hsl(var(${colorVariable}) / ${alpha})`;
      } catch (error) {
        // eslint-disable-next-line no-console
        console.log('error generating on-color for', colorName, error);
      }
    }

    /**
     * Layout
     */
    for (const [key, value] of Object.entries(flatLayout)) {
      if (!value) continue;

      const layoutVariablePrefix = `--${key}`;

      if (typeof value === 'object') {
        for (const [nestedKey, nestedValue] of Object.entries(value)) {
          // Handle DEFAULT key - use base variable name without suffix
          const nestedLayoutVariable: string =
            nestedKey === 'DEFAULT'
              ? layoutVariablePrefix
              : `${layoutVariablePrefix}-${nestedKey}`;

          themeRules = {
            ...themeRules,
            [nestedLayoutVariable]: nestedValue as string
          };
        }
      } else {
        // Handle opacity values and other singular layout values
        const formattedValue =
          layoutVariablePrefix.includes('opacity') && typeof value === 'number'
            ? (value as number).toString().replace(/^0\./, '.')
            : value;

        themeRules = {
          ...themeRules,
          [layoutVariablePrefix]: formattedValue as string
        };
      }
    }

    if (baseSelector) {
      resolved.base = {
        ...resolved.base,
        [baseSelector]: themeRules
      };
    } else {
      resolved.utilities = {
        ...resolved.utilities,
        [cssSelector]: themeRules
      };
    }
  }

  return resolved;
}

function removeDefaultKeys<T extends Record<string, unknown>>(
  obj: T
): Record<string, unknown> {
  const newObj: Record<string, unknown> = {};

  for (const key in obj) {
    if (key.endsWith('-DEFAULT')) {
      newObj[key.replace('-DEFAULT', '')] = obj[key];
      continue;
    }
    newObj[key] = obj[key];
  }

  return newObj;
}

function flattenThemeObject<TTarget>(obj: TTarget): Record<string, unknown> {
  return removeDefaultKeys(
    flatten(obj, {
      safe: true,
      delimiter: '-'
    }) as Record<string, unknown>
  );
}

export const isBaseTheme = (theme: string): boolean =>
  theme === 'light' || theme === 'dark';

function resolveConfig(userConfig: PluginConfig = {}): {
  themes: ConfigThemes;
  defaultTheme: DefaultThemeType;
} {
  const {
    themes: userThemes = {},
    defaultTheme = 'light',
    layout: userLayout
  } = userConfig;
  const themes: ConfigThemes & { dark: ConfigTheme; light: ConfigTheme } =
    defaultConfig.themes;

  if (typeof userLayout === 'object') {
    themes.dark.layout = deepMerge(themes.dark.layout || {}, userLayout);
    themes.light.layout = deepMerge(themes.light.layout || {}, userLayout);
  }

  if (typeof userThemes['dark'] === 'object') {
    themes.dark = deepMerge(themes.dark, userThemes['dark']);
  }

  if (typeof userThemes['light'] === 'object') {
    themes.light = deepMerge(themes.light, userThemes['light']);
  }

  Object.keys(userThemes).forEach((name) => {
    if (isBaseTheme(name)) {
      return;
    }
    const { extend } = userThemes[name] || {};
    const extendFrom = extend && isBaseTheme(extend) ? extend : 'light';

    themes[name] = deepMerge(themes[extendFrom], userThemes[name] || {});
  });

  return { themes, defaultTheme };
}

export { resolveThemes, resolveConfig };
