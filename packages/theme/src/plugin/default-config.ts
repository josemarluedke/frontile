import { semanticColors } from '../colors/config';
import type { LayoutTheme } from '../types';

// Layout defaults otherwise live in index.css; only per-theme values need to
// be declared here, since index.css can only carry one value for both schemes.
const baseLayout: LayoutTheme = {};

// Facet spec: a disabled control keeps its colors and drops opacity. Dark mode
// uses a lower value because the same veil reads heavier on a dark ground.
const lightLayout: LayoutTheme = {
  ...baseLayout,
  opacity: { disabled: 0.5 }
};

const darkLayout: LayoutTheme = {
  ...baseLayout,
  opacity: { disabled: 0.4 }
};

const defaultConfig = {
  defaultTheme: 'light',
  themes: {
    light: {
      colors: semanticColors.light,
      layout: lightLayout
    },
    dark: {
      colors: semanticColors.dark,
      layout: darkLayout
    }
  }
};

export { defaultConfig };
