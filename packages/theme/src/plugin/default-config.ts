import { semanticColors } from '../colors/semantic';
import type { LayoutTheme } from '../types';

const baseLayout: LayoutTheme = {
  disabledOpacity: '.5'
};

const defaultConfig = {
  defaultTheme: 'light',
  prefix: 'frontile',
  themes: {
    light: {
      colors: semanticColors.light,
      layout: { ...baseLayout, hoverOpacity: '.8' }
    },
    dark: {
      colors: semanticColors.dark,
      layout: { ...baseLayout, hoverOpacity: '.7' }
    }
  }
};

export { defaultConfig };
