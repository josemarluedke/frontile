export type ColorScale =
  | Partial<{
      50: string;
      100: string;
      200: string;
      300: string;
      400: string;
      500: string;
      600: string;
      700: string;
      800: string;
      900: string;
      950: string;
      foreground: string;
      DEFAULT: string;
    }>
  | string;

export type BaseColors = {
  background: ColorScale;
  foreground: ColorScale;
  divider: ColorScale;
  overlay: ColorScale;
  focus: ColorScale;
  content1: ColorScale;
  content2: ColorScale;
  content3: ColorScale;
  content4: ColorScale;
};

export type SemanticBaseColors = {
  light: BaseColors;
  dark: BaseColors;
};

export interface SemanticColorCategory {
  'contrast-1': string;
  'contrast-2': string;
  subtle: string;
  medium: string;
  strong: string;
  soft: string;
  DEFAULT: string;
}

export interface ThemeColors {
  neutral: SemanticColorCategory;
  brand: SemanticColorCategory;
  success: SemanticColorCategory;
  warning: SemanticColorCategory;
  danger: SemanticColorCategory;
  inverse: SemanticColorCategory;
}
