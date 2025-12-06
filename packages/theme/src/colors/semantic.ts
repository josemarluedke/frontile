/**
 * Frontile Semantic Colors
 *
 * AUTO-GENERATED - DO NOT EDIT
 * Generated from design tokens via npm run generate:frontile:semantic
 *
 * Semantic color mappings for light and dark themes.
 */

import * as lightPalette from './palette-light';
import * as darkPalette from './palette-dark';
import * as absolute from './palette-absolute';

import type { ThemeColors } from './types';

const themeColorsLight: ThemeColors = {
  neutral: {
    contrastPrimary: absolute.white,
    strong: absolute.black,
    medium: `${absolute.black}c9`,
    DEFAULT: `${absolute.black}c9`,
    soft: `${absolute.black}73`,
    subtle: `${absolute.black}0f`,
    contrastSecondary: absolute.black
  },
  success: {
    contrastPrimary: absolute.white,
    subtle: `${lightPalette.green['400']}80`,
    medium: lightPalette.green['800'],
    DEFAULT: lightPalette.green['800'],
    strong: lightPalette.green['900'],
    soft: lightPalette.green['600'],
    contrastSecondary: absolute.black
  },
  inverse: {
    contrastPrimary: absolute.black,
    subtle: `${absolute.white}24`,
    soft: `${absolute.white}4f`,
    medium: `${absolute.white}c4`,
    DEFAULT: `${absolute.white}c4`,
    strong: absolute.white,
    contrastSecondary: absolute.white
  },
  brand: {
    contrastPrimary: absolute.white,
    subtle: `${lightPalette.blue['800']}0d`,
    medium: lightPalette.blue['800'],
    DEFAULT: lightPalette.blue['800'],
    soft: lightPalette.blue['500'],
    strong: lightPalette.blue['1000'],
    contrastSecondary: absolute.black
  },
  danger: {
    contrastPrimary: absolute.white,
    subtle: `${lightPalette.red['800']}1a`,
    soft: lightPalette.red['500'],
    medium: lightPalette.red['800'],
    DEFAULT: lightPalette.red['800'],
    strong: lightPalette.red['900'],
    contrastSecondary: absolute.black
  },
  warning: {
    contrastPrimary: absolute.white,
    subtle: `${lightPalette.orange['700']}1a`,
    soft: lightPalette.orange['600'],
    medium: lightPalette.orange['700'],
    DEFAULT: lightPalette.orange['700'],
    strong: lightPalette.orange['800'],
    contrastSecondary: absolute.black
  }
};

const themeColorsDark: ThemeColors = {
  neutral: {
    contrastPrimary: absolute.black,
    subtle: `${absolute.white}24`,
    soft: `${absolute.white}4f`,
    medium: `${absolute.white}c4`,
    DEFAULT: `${absolute.white}c4`,
    strong: absolute.white,
    contrastSecondary: absolute.white
  },
  success: {
    contrastPrimary: absolute.white,
    subtle: `${darkPalette.green['1000']}33`,
    soft: darkPalette.green['600'],
    medium: darkPalette.green['900'],
    DEFAULT: darkPalette.green['900'],
    strong: darkPalette.green['1000'],
    contrastSecondary: absolute.black
  },
  inverse: {
    contrastPrimary: absolute.white,
    subtle: `${absolute.black}0f`,
    soft: `${absolute.black}73`,
    medium: `${absolute.black}c9`,
    DEFAULT: `${absolute.black}c9`,
    strong: absolute.black,
    contrastSecondary: absolute.black
  },
  brand: {
    contrastPrimary: absolute.white,
    subtle: `${darkPalette.blue['1000']}33`,
    soft: darkPalette.blue['700'],
    medium: darkPalette.blue['800'],
    DEFAULT: darkPalette.blue['800'],
    strong: darkPalette.blue['1000'],
    contrastSecondary: absolute.black
  },
  danger: {
    contrastPrimary: absolute.white,
    subtle: `${darkPalette.red['1000']}59`,
    soft: darkPalette.red['500'],
    medium: darkPalette.red['800'],
    DEFAULT: darkPalette.red['800'],
    strong: darkPalette.red['1000'],
    contrastSecondary: absolute.black
  },
  warning: {
    contrastPrimary: absolute.white,
    subtle: `${darkPalette.orange['1000']}59`,
    soft: darkPalette.orange['800'],
    medium: darkPalette.orange['900'],
    DEFAULT: darkPalette.orange['900'],
    strong: darkPalette.orange['1000'],
    contrastSecondary: absolute.black
  }
};

export default {
  light: themeColorsLight,
  dark: themeColorsDark
};
