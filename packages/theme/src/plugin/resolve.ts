import flatten from 'flat';
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

const parsedColorsCache: Record<string, number[]> = {};

interface ResolvedConfig {
  variants: { name: string; definition: string[] }[];
  utilities: CSSRuleObject | CSSRuleObject[];
  colors: Record<
    string,
    ({
      opacityValue,
      opacityVariable
    }: {
      opacityValue: string;
      opacityVariable: string;
    }) => string
  >;
}

function resolveThemes(
  themes: ConfigThemes = {},
  defaultTheme: DefaultThemeType,
  prefix: string
): ResolvedConfig {
  const resolved: ResolvedConfig = {
    variants: [],
    utilities: {},
    colors: {}
  };

  for (const [themeName, { extend, layout, colors }] of Object.entries(
    themes
  )) {
    let cssSelector = `.${themeName}`;
    const scheme =
      themeName === 'light' || themeName === 'dark' ? themeName : extend;

    // if the theme is the default theme, add the selector to the root element
    if (themeName === defaultTheme) {
      cssSelector = `:root,${cssSelector}`;
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
        const colorVariable = `--${prefix}-${colorName}`;
        const customOpacityVariable = `--${prefix}-${colorName}-opacity`;

        themeRules = { ...themeRules, [colorVariable]: `${h} ${s}% ${l}%` };

        if (typeof defaultAlphaValue === 'number') {
          themeRules = {
            ...themeRules,
            [customOpacityVariable]: defaultAlphaValue.toFixed(2)
          };
        }

        // set the dynamic color in tailwind config theme.colors
        resolved.colors[colorName] = ({
          opacityVariable,
          opacityValue
        }): string => {
          // if the opacity is set  with a slash (e.g. bg-primary/90), use the provided value
          if (!isNaN(+opacityValue)) {
            return `hsl(var(${colorVariable}) / ${opacityValue})`;
          }
          if (opacityVariable) {
            return `hsl(var(${colorVariable}) / var(${customOpacityVariable}, var(${opacityVariable})))`;
          }

          return `hsl(var(${colorVariable}) / var(${customOpacityVariable}, 1))`;
        };
      } catch (error) {
        // eslint-disable-next-line no-console
        console.log('error', error);
      }
    }

    /**
     * Layout
     */
    for (const [key, value] of Object.entries(flatLayout)) {
      if (!value) continue;

      const layoutVariablePrefix = `--${prefix}-${key}`;

      if (typeof value === 'object') {
        for (const [nestedKey, nestedValue] of Object.entries(value)) {
          const nestedLayoutVariable: string = `${layoutVariablePrefix}-${nestedKey}`;

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

    resolved.utilities = {
      ...resolved.utilities,
      [cssSelector]: themeRules
    };
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
  prefix: string;
} {
  const {
    themes: userThemes = {},
    defaultTheme = 'light',
    layout: userLayout,
    prefix = defaultConfig.prefix
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

  return { themes, defaultTheme, prefix };
}

export { resolveThemes, resolveConfig };
