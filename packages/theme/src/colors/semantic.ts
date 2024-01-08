import resolveConfig from 'tailwindcss/resolveConfig';
import tailwindConfig from 'tailwindcss/defaultConfig';
import { readableColor } from 'color2k';
import { swapColorValues } from './util';

import type { ThemeColors, SemanticBaseColors } from './types';

const tw = resolveConfig(tailwindConfig).theme;

const base: SemanticBaseColors = {
  light: {
    background: {
      DEFAULT: '#FFFFFF'
    },
    foreground: {
      ...tw.colors.zinc,
      DEFAULT: tw.colors.zinc[950]
    },
    divider: {
      DEFAULT: 'rgba(17, 17, 17, 0.15)'
    },
    focus: {
      DEFAULT: tw.colors.blue[500]
    },
    overlay: {
      DEFAULT: '#000000'
    },
    content1: {
      DEFAULT: '#FFFFFF',
      foreground: tw.colors.zinc[950]
    },
    content2: {
      DEFAULT: tw.colors.zinc[100],
      foreground: tw.colors.zinc[800]
    },
    content3: {
      DEFAULT: tw.colors.zinc[200],
      foreground: tw.colors.zinc[700]
    },
    content4: {
      DEFAULT: tw.colors.zinc[300],
      foreground: tw.colors.zinc[600]
    }
  },
  dark: {
    background: {
      DEFAULT: tw.colors.zinc[950]
    },
    foreground: {
      ...swapColorValues(tw.colors.zinc),
      DEFAULT: tw.colors.zinc[50]
    },
    focus: {
      DEFAULT: tw.colors.blue[500]
    },
    overlay: {
      DEFAULT: '#000000'
    },
    divider: {
      DEFAULT: 'rgba(255, 255, 255, 0.15)'
    },
    content1: {
      DEFAULT: tw.colors.zinc[900],
      foreground: tw.colors.zinc[50]
    },
    content2: {
      DEFAULT: tw.colors.zinc[800],
      foreground: tw.colors.zinc[100]
    },
    content3: {
      DEFAULT: tw.colors.zinc[700],
      foreground: tw.colors.zinc[200]
    },
    content4: {
      DEFAULT: tw.colors.zinc[600],
      foreground: tw.colors.zinc[300]
    }
  }
};

export const themeColorsLight: ThemeColors = {
  ...base.light,
  default: {
    ...tw.colors.zinc,
    foreground: readableColor(tw.colors.zinc[300]),
    DEFAULT: tw.colors.zinc[300]
  },
  primary: {
    ...tw.colors.blue,
    foreground: readableColor(tw.colors.blue[500]),
    DEFAULT: tw.colors.blue[500]
  },
  success: {
    ...tw.colors.green,
    foreground: readableColor(tw.colors.green[500]),
    DEFAULT: tw.colors.green[500]
  },
  warning: {
    ...tw.colors.yellow,
    foreground: readableColor(tw.colors.yellow[500]),
    DEFAULT: tw.colors.yellow[500]
  },
  danger: {
    ...tw.colors.red,
    foreground: tw.colors.white,
    DEFAULT: tw.colors.red[500]
  }
};

export const themeColorsDark: ThemeColors = {
  ...base.dark,
  default: {
    ...swapColorValues(tw.colors.zinc),
    foreground: readableColor(tw.colors.zinc[700]),
    DEFAULT: tw.colors.zinc[700]
  },
  primary: {
    ...swapColorValues(tw.colors.blue),
    foreground: readableColor(tw.colors.blue[500]),
    DEFAULT: tw.colors.blue[500]
  },
  success: {
    ...swapColorValues(tw.colors.green),
    foreground: readableColor(tw.colors.green[500]),
    DEFAULT: tw.colors.green[500]
  },
  warning: {
    ...swapColorValues(tw.colors.yellow),
    foreground: readableColor(tw.colors.yellow[500]),
    DEFAULT: tw.colors.yellow[500]
  },
  danger: {
    ...swapColorValues(tw.colors.red),
    foreground: tw.colors.white,
    DEFAULT: tw.colors.red[500]
  }
};

export const semanticColors = {
  light: themeColorsLight,
  dark: themeColorsDark
};
