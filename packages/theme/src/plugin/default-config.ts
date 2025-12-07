import { semanticColors } from '../colors/config';
import type { LayoutTheme } from '../types';

// No default layout values - defaults are in index.css
// Users can override via CSS or configure via JS
const baseLayout: LayoutTheme = {};

const defaultConfig = {
  defaultTheme: 'light',
  themes: {
    light: {
      colors: semanticColors.light,
      layout: baseLayout
    },
    dark: {
      colors: semanticColors.dark,
      layout: baseLayout
    }
  }
};

export { defaultConfig };
