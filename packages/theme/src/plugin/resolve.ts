import { flatten } from 'flat';
import kebabCase from 'lodash.kebabcase';
import mapKeys from 'lodash.mapkeys';
import { parse, oklch } from 'culori';
import deepMerge from 'deepmerge';

import type {
  ConfigThemes,
  DefaultThemeType,
  PluginConfig,
  ConfigTheme
} from '../types';
import type { CSSRuleObject } from 'tailwindcss/types/config';
import { defaultConfig } from './default-config';
import { getContrastingColor } from '../colors/util';

interface ParsedColor {
  formatted: string;
  alpha: number;
}

const parsedColorsCache: Record<string, ParsedColor> = {};

interface ResolvedConfig {
  variants: { name: string; definition: string[] }[];
  utilities: CSSRuleObject | CSSRuleObject[];
  base: CSSRuleObject | CSSRuleObject[];
  colors: Record<string, string>;
}

/**
 * Parse a color value and convert it to OKLCH format.
 */
function parseAndFormatColor(colorValue: string): ParsedColor {
  const parsed = parse(colorValue);
  if (!parsed) {
    throw new Error(`Failed to parse color: ${colorValue}`);
  }

  const color = oklch(parsed);
  const l = ((color.l ?? 0) * 100).toFixed(2);
  const c = (color.c ?? 0).toFixed(4);
  const h = (color.h ?? 0).toFixed(2);
  const alpha = color.alpha ?? 1;

  const formatted =
    alpha < 1 ? `oklch(${l}% ${c} ${h} / ${alpha})` : `oklch(${l}% ${c} ${h})`;

  return { formatted, alpha };
}

/**
 * Get parsed color from cache or parse and cache it.
 */
function getCachedColor(colorValue: string): ParsedColor {
  if (!parsedColorsCache[colorValue]) {
    parsedColorsCache[colorValue] = parseAndFormatColor(colorValue);
  }
  return parsedColorsCache[colorValue];
}

const SEMANTIC_COLOR_PREFIXES = [
  'neutral',
  'brand',
  'accent',
  'success',
  'danger',
  'warning',
  'surface-solid'
];

const EXCLUDED_COLORS = ['background', 'focus', 'divider'];

/**
 * Determine if a color should have an "on-" variant generated.
 * Includes semantic colors and surface-solid-*.
 * Excludes utility colors and transparent overlays.
 */
function shouldGenerateOnColor(colorName: string): boolean {
  if (EXCLUDED_COLORS.includes(colorName)) {
    return false;
  }

  if (colorName.startsWith('surface-overlay')) {
    return false;
  }

  return SEMANTIC_COLOR_PREFIXES.some((prefix) => colorName.startsWith(prefix));
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
    if (themeName === 'light') {
      cssSelector = `${cssSelector}, .dark .theme-inverse`;
    } else if (themeName === 'dark') {
      cssSelector = `${cssSelector}, .light .theme-inverse`;
    }

    // if the theme is the default theme, add the selector to the root element
    if (themeName === defaultTheme) {
      baseSelector = `:root, ${cssSelector}`;
    }

    const themeRules: CSSRuleObject = scheme ? { 'color-scheme': scheme } : {};

    const flatColors = flattenThemeObject(colors) as Record<string, string>;

    const flatLayout = layout
      ? mapKeys(layout, (_, key) => kebabCase(key))
      : {};

    resolved.variants.push({
      name: themeName,
      definition: [`&.${themeName}`]
    });

    // Process colors and generate CSS variables
    for (const [colorName, colorValue] of Object.entries(flatColors)) {
      if (!colorValue) continue;

      const cssVar = `--color-${colorName}`;

      // Handle CSS variable references (e.g., var(--color-name))
      if (colorValue.startsWith('var(')) {
        themeRules[cssVar] = colorValue;
        resolved.colors[colorName] = `var(${cssVar})`;
        continue;
      }

      try {
        const { formatted } = getCachedColor(colorValue);
        themeRules[cssVar] = formatted;
        resolved.colors[colorName] = `var(${cssVar})`;
      } catch (error) {
        // eslint-disable-next-line no-console
        console.warn(`Failed to parse color "${colorName}":`, error);
      }
    }

    // Generate "on-" colors for optimal contrast on semantic backgrounds
    for (const [colorName, colorValue] of Object.entries(flatColors)) {
      if (!shouldGenerateOnColor(colorName)) continue;

      // Check if user has already defined this on-color
      const onColorName = `on-${colorName}`;
      if (flatColors[onColorName]) {
        // User provided custom on-color, skip auto-generation
        continue;
      }

      // Skip CSS variable references - can't calculate contrast for them
      if (colorValue.startsWith('var(')) {
        continue;
      }

      try {
        const contrastColor = getContrastingColor(colorValue);
        const { formatted } = getCachedColor(contrastColor);
        const cssVar = `--color-${onColorName}`;

        themeRules[cssVar] = formatted;
        resolved.colors[onColorName] = `var(${cssVar})`;
      } catch (error) {
        // eslint-disable-next-line no-console
        console.warn(`Failed to generate on-color for "${colorName}":`, error);
      }
    }

    // Process layout variables
    for (const [key, value] of Object.entries(flatLayout)) {
      if (!value) continue;

      const varPrefix = `--${key}`;

      if (typeof value === 'object') {
        for (const [nestedKey, nestedValue] of Object.entries(value)) {
          const cssVar =
            nestedKey === 'DEFAULT' ? varPrefix : `${varPrefix}-${nestedKey}`;
          themeRules[cssVar] = nestedValue as string;
        }
      } else {
        // Format opacity values (e.g., 0.5 -> .5)
        const formattedValue =
          varPrefix.includes('opacity') && typeof value === 'number'
            ? String(value).replace(/^0\./, '.')
            : value;
        themeRules[varPrefix] = formattedValue as string;
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
