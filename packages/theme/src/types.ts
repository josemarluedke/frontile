import type { ThemeColors } from './colors/types';

export interface LayoutTheme {
  /**
   * Opacity configuration for components.
   * Supports Tailwind's opacity-* naming convention.
   */
  opacity?: {
    /**
     * A number between 0 and 1 that is applied as opacity when the component is hovered.
     * @default .8
     */
    hover?: string | number;
    /**
     * A number between 0 and 1 that is applied as opacity when the component is disabled.
     * @default .5
     */
    disabled?: string | number;
  };

  /**
   * Border radius configuration for components.
   * Values can be any valid CSS length unit (px, rem, em, etc.)
   *
   * `DEFAULT` is the single knob for the whole system: every other step is
   * derived from it via `calc()`, so setting it alone scales all component
   * radii proportionally.
   *
   * ```ts
   * frontile({ layout: { radius: { DEFAULT: '0.75rem' } } }) // softer overall
   * frontile({ layout: { radius: { DEFAULT: '0' } } })       // fully squared off
   * ```
   *
   * The individual steps are escape hatches — set one only to break a single
   * step out of the derived scale. `none` and `pill` are absolutes and are not
   * affected by `DEFAULT`.
   */
  radius?: {
    /** Base unit the scale is derived from. Defaults to `0.5rem` (8px). */
    DEFAULT?: string;
    none?: string;
    xs?: string;
    sm?: string;
    md?: string;
    lg?: string;
    xl?: string;
    '2xl'?: string;
    '3xl'?: string;
    '4xl'?: string;
    full?: string;
    pill?: string;
  };
}

export type ConfigTheme = {
  extend?: 'light' | 'dark';
  layout?: LayoutTheme;
  colors?: Partial<ThemeColors>;
};

export type ConfigThemes = Record<string, ConfigTheme>;
export type DefaultThemeType = 'light' | 'dark';

export type PluginConfig = {
  themes?: ConfigThemes;
  layout?: LayoutTheme;
  defaultTheme?: DefaultThemeType;
};
