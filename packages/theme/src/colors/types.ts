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
      DEFAULT: string;
    }>
  | string;

export type BaseColors = {
  background: ColorScale;
  divider: ColorScale;
  focus: ColorScale;
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

export interface SurfaceOverlay {
  subtle: string;
  soft: string;
  medium: string;
  strong: string;
  inverse: {
    subtle: string;
    soft: string;
    medium: string;
    strong: string;
  };
}

export interface SurfaceSolid {
  0: string;
  1: string;
  2: string;
  3: string;
  4: string;
  5: string;
  6: string;
  7: string;
  8: string;
  9: string;
  10: string;
  11: string;
}

export interface SurfaceColors {
  overlay: SurfaceOverlay;
  solid: SurfaceSolid;
}

export interface ThemeColors {
  neutral: SemanticColorCategory;
  brand: SemanticColorCategory;
  success: SemanticColorCategory;
  warning: SemanticColorCategory;
  danger: SemanticColorCategory;
  inverse: SemanticColorCategory;
  surface: SurfaceColors;
}
