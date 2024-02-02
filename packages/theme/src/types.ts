import type { ThemeColors } from './colors/types';

export interface LayoutTheme {
  /**
   * A number between 0 and 1 that is applied as opacity: [value] when the component is hovered.
   *
   * format: ".[value]"
   *
   * @default .8
   */
  hoverOpacity?: string | number;

  disabledOpacity?: string | number;
}

export type ConfigTheme = {
  extend?: 'light' | 'dark';
  layout?: LayoutTheme;
  colors?: Partial<ThemeColors>;
};

export type ConfigThemes = Record<string, ConfigTheme>;
export type DefaultThemeType = 'light' | 'dark';

export type PluginConfig = {
  /**
   * The prefix for the css variables.
   * @default "frontile"
   */
  prefix?: string;
  themes?: ConfigThemes;
  layout?: LayoutTheme;
  defaultTheme?: DefaultThemeType;
};
