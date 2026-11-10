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
import type { CSSRuleObject } from './types';
import { defaultConfig } from './default-config';
import { getContrastingColor } from '../colors/util';

interface ParsedColor {
  formatted: string;
  alpha: number;
}

const parsedColorsCache: Record<string, ParsedColor> = {};

interface ResolvedConfig {
  variants: { name: string; definition: string[] }[];
  // Every entry is a selector mapped to its own nested rule object (see the
  // `resolved.utilities[cssSelector] = themeRules` assignment below) --
  // never a bare CSS declaration -- so this is narrower than `base`, which
  // `addBase` accepts as either shape.
  utilities: Record<string, CSSRuleObject>;
  base: CSSRuleObject;
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
  'primary',
  'secondary',
  'tertiary',
  'success',
  'danger',
  'warning',
  'surface-input',
  'surface-modal',
  'surface-drawer'
];

const EXCLUDED_COLORS = ['background', 'focus', 'divider'];

/**
 * Determine if a color should have an "on-" variant generated.
 *
 * Membership is the explicit `SEMANTIC_COLOR_PREFIXES` allowlist, not a
 * derived rule: every intent category needs a contrast foreground, but only
 * some surfaces do, and which ones is a judgement call recorded in that list.
 * Utility colors and translucent surfaces are rejected outright below.
 */
function shouldGenerateOnColor(colorName: string): boolean {
  if (EXCLUDED_COLORS.includes(colorName)) {
    return false;
  }

  // Translucent veils: contrast depends on whatever shows through, so a
  // single on-color cannot be computed for them.
  if (
    colorName.startsWith('surface-overlay') ||
    colorName.startsWith('surface-lift')
  ) {
    return false;
  }

  return SEMANTIC_COLOR_PREFIXES.some((prefix) => colorName.startsWith(prefix));
}

/**
 * Give `.theme-inverse` the tokens of `themeName` wherever its nearest
 * `.light`/`.dark` ancestor says it should resolve to that theme.
 *
 * Each `@scope` runs from a `.light` or `.dark` root down to the next nested
 * `.light`/`.dark` (exclusive of that boundary's descendants), so a
 * `.theme-inverse` sits in the scope of its nearest one only, at any depth:
 *
 * - a single inverse below the opposite theme's root resolves to `themeName`
 *   (`.dark` > `.theme-inverse` is light);
 * - a second inverse inside the first, below this theme's root, flips back
 *   (`.light` > `.theme-inverse` > `.theme-inverse` is light).
 *
 * Consecutive `.theme-inverse` chains resolve up to 2 deep: `@scope` cannot
 * count parity, so a third directly nested inverse keeps its parent's
 * tokens. The `dark`/`light` variants in `index.css` do not use `@scope`:
 * they enumerate themed ancestors and stop at 3 (see the comment there).
 *
 * Every `.theme-inverse` matches exactly one of these rules, so their cascade
 * layer never decides the outcome. (`:root` is the exception by design: it
 * carries the default theme in the base layer, and a theme class on `<html>`
 * overrides it from the utilities layer while tokens only the default theme
 * defines stay available.)
 */
function addInverseRules(
  base: CSSRuleObject,
  themeName: 'light' | 'dark',
  themeRules: CSSRuleObject
): void {
  const opposite = themeName === 'light' ? 'dark' : 'light';
  const scope = (root: string): string =>
    `@scope (.${root}) to (:scope :is(.light, .dark) *)`;
  const add = (root: string, selector: string): void => {
    const key = scope(root);
    base[key] = {
      ...(base[key] as CSSRuleObject | undefined),
      [selector]: themeRules
    };
  };

  // `:scope` is spelled out at the front: a selector inside `@scope` that
  // already mentions `:scope` (here, in `:not()`) is not implicitly relative
  // to the root, and would let an inverse above the root count.
  add(opposite, ':scope .theme-inverse:not(:scope .theme-inverse *)');
  add(
    themeName,
    ':scope .theme-inverse .theme-inverse:not(:scope .theme-inverse .theme-inverse *)'
  );
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
    const cssSelector = `.${themeName}`;
    let baseSelector = '';

    const scheme =
      themeName === 'light' || themeName === 'dark' ? themeName : extend;

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

    if (themeName === 'light' || themeName === 'dark') {
      addInverseRules(resolved.base, themeName, themeRules);
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
