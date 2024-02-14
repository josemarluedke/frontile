import resolveConfig from 'tailwindcss/resolveConfig';
import tailwindConfig from 'tailwindcss/defaultConfig';
import { readableColor } from 'color2k';
import { swapColorValues } from './util';
import { gray, blue, green, red, yellow } from './defaults';

import type { ThemeColors, SemanticBaseColors } from './types';

const tw = resolveConfig(tailwindConfig).theme;

const base: SemanticBaseColors = {
  light: {
    background: {
      DEFAULT: '#FFFFFF'
    },
    foreground: {
      ...gray,
      DEFAULT: gray[950]
    },
    divider: {
      DEFAULT: 'rgba(17, 17, 17, 0.15)'
    },
    focus: {
      DEFAULT: blue[500]
    },
    overlay: {
      DEFAULT: '#000000'
    },
    content1: {
      DEFAULT: '#FFFFFF',
      foreground: gray[950]
    },
    content2: {
      DEFAULT: gray[100],
      foreground: gray[800]
    },
    content3: {
      DEFAULT: gray[200],
      foreground: gray[700]
    },
    content4: {
      DEFAULT: gray[300],
      foreground: gray[600]
    }
  },
  dark: {
    background: {
      DEFAULT: gray[950]
    },
    foreground: {
      ...swapColorValues(gray),
      DEFAULT: gray[50]
    },
    focus: {
      DEFAULT: blue[500]
    },
    overlay: {
      DEFAULT: '#000000'
    },
    divider: {
      DEFAULT: 'rgba(255, 255, 255, 0.15)'
    },
    content1: {
      DEFAULT: gray[900],
      foreground: gray[50]
    },
    content2: {
      DEFAULT: gray[800],
      foreground: gray[100]
    },
    content3: {
      DEFAULT: gray[700],
      foreground: gray[200]
    },
    content4: {
      DEFAULT: gray[600],
      foreground: gray[300]
    }
  }
};

const themeColorsLight: ThemeColors = {
  ...base.light,
  default: {
    ...gray,
    foreground: readableColor(gray[300]),
    DEFAULT: gray[300]
  },
  primary: {
    ...blue,
    foreground: readableColor(blue[500]),
    DEFAULT: blue[500]
  },
  success: {
    ...green,
    foreground: readableColor(green[600]),
    DEFAULT: green[600]
  },
  warning: {
    ...yellow,
    foreground: readableColor(yellow[700]),
    DEFAULT: yellow[700]
  },
  danger: {
    ...red,
    foreground: tw.colors.white,
    DEFAULT: red[600]
  }
};

const themeColorsDark: ThemeColors = {
  ...base.dark,
  default: {
    ...swapColorValues(gray),
    foreground: readableColor(gray[700]),
    DEFAULT: gray[700]
  },
  primary: {
    ...swapColorValues(blue),
    foreground: readableColor(blue[500]),
    DEFAULT: blue[400]
  },
  success: {
    ...swapColorValues(green),
    foreground: tw.colors.white,
    DEFAULT: green[500]
  },
  warning: {
    ...swapColorValues(yellow),
    foreground: readableColor(yellow[500]),
    DEFAULT: yellow[500]
  },
  danger: {
    ...swapColorValues(red),
    foreground: readableColor(red[400]),
    DEFAULT: red[400]
  }
};

export const semanticColors = {
  light: themeColorsLight,
  dark: themeColorsDark
};
