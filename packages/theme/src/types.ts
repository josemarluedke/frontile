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
   */
  radius?: {
    xs?: string;
    sm?: string;
    md?: string;
    lg?: string;
    DEFAULT?: string;
    xl?: string;
    '2xl'?: string;
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
