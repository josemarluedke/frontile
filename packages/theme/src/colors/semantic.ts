/**
 * Frontile Semantic Colors
 *
 * Semantic color mappings for light and dark themes.
 */

import * as lightPalette from './palette-light';
import * as darkPalette from './palette-dark';
import * as absolute from './palette-absolute';

import type { ThemeColors } from './types';

const themeColorsLight: ThemeColors = {
  neutral: {
    subtle: `${absolute.black}0f`,
    soft: `${absolute.black}73`,
    medium: `${absolute.black}c9`,
    DEFAULT: `${absolute.black}c9`,
    strong: absolute.black,
    'contrast-1': absolute.white,
    'contrast-2': absolute.black
  },
  success: {
    subtle: `${lightPalette.green['400']}80`,
    soft: lightPalette.green['600'],
    medium: lightPalette.green['800'],
    DEFAULT: lightPalette.green['800'],
    strong: lightPalette.green['900'],
    'contrast-1': absolute.white,
    'contrast-2': absolute.black
  },
  brand: {
    subtle: `${lightPalette.blue['400']}80`,
    soft: lightPalette.blue['600'],
    medium: lightPalette.blue['800'],
    DEFAULT: lightPalette.blue['800'],
    strong: lightPalette.blue['900'],
    'contrast-1': absolute.white,
    'contrast-2': absolute.black
  },
  danger: {
    subtle: `${lightPalette.red['800']}59`,
    soft: lightPalette.red['800'],
    medium: lightPalette.red['900'],
    DEFAULT: lightPalette.red['900'],
    strong: lightPalette.red['950'],
    'contrast-1': absolute.white,
    'contrast-2': absolute.black
  },
  warning: {
    subtle: `${lightPalette.red['500']}59`,
    soft: lightPalette.red['500'],
    medium: lightPalette.red['700'],
    DEFAULT: lightPalette.red['700'],
    strong: lightPalette.red['800'],
    'contrast-1': absolute.white,
    'contrast-2': absolute.black
  },
  surface: {
    overlay: {
      subtle: '#00000005',
      soft: '#0000000a',
      medium: '#00000012',
      strong: '#0000001C',
      inverse: {
        subtle: '#ffffff4d',
        soft: '#ffffff80',
        medium: '#ffffffb3',
        strong: '#ffffffe6'
      }
    },
    solid: {
      '0': absolute.white,
      '1': lightPalette.gray['100'],
      '2': lightPalette.gray['200'],
      '3': lightPalette.gray['300'],
      '4': lightPalette.gray['400'],
      '5': lightPalette.gray['500'],
      '6': lightPalette.gray['600'],
      '7': lightPalette.gray['700'],
      '8': lightPalette.gray['800'],
      '9': lightPalette.gray['900'],
      '10': lightPalette.gray['950'],
      '11': absolute.black
    }
  }
};

const themeColorsDark: ThemeColors = {
  neutral: {
    subtle: `${absolute.white}24`,
    soft: `${absolute.white}4f`,
    medium: `${absolute.white}c4`,
    DEFAULT: `${absolute.white}c4`,
    strong: absolute.white,
    'contrast-1': absolute.black,
    'contrast-2': absolute.white
  },
  success: {
    subtle: `${darkPalette.green['200']}33`,
    soft: darkPalette.green['700'],
    medium: darkPalette.green['900'],
    DEFAULT: darkPalette.green['900'],
    strong: darkPalette.green['950'],
    'contrast-1': absolute.black,
    'contrast-2': absolute.white
  },
  brand: {
    subtle: `${darkPalette.blue['200']}33`,
    soft: darkPalette.blue['700'],
    medium: darkPalette.blue['900'],
    DEFAULT: darkPalette.blue['900'],
    strong: darkPalette.blue['950'],
    'contrast-1': absolute.black,
    'contrast-2': absolute.white
  },
  danger: {
    subtle: `${darkPalette.red['700']}59`,
    soft: darkPalette.red['800'],
    medium: darkPalette.red['900'],
    DEFAULT: darkPalette.red['900'],
    strong: darkPalette.red['950'],
    'contrast-1': absolute.black,
    'contrast-2': absolute.white
  },
  warning: {
    subtle: `${darkPalette.red['200']}59`,
    soft: darkPalette.red['400'],
    medium: darkPalette.red['500'],
    DEFAULT: darkPalette.red['500'],
    strong: darkPalette.red['600'],
    'contrast-1': absolute.black,
    'contrast-2': absolute.white
  },
  surface: {
    overlay: {
      subtle: '#ffffff08',
      soft: '#ffffff0f',
      medium: '#ffffff26',
      strong: '#ffffff3d',
      inverse: {
        subtle: '#00000026',
        soft: '#00000033',
        medium: '#0000004d',
        strong: '#00000073'
      }
    },
    solid: {
      '0': absolute.black,
      '1': darkPalette.gray['100'],
      '2': darkPalette.gray['200'],
      '3': darkPalette.gray['300'],
      '4': darkPalette.gray['400'],
      '5': darkPalette.gray['500'],
      '6': darkPalette.gray['600'],
      '7': darkPalette.gray['700'],
      '8': darkPalette.gray['800'],
      '9': darkPalette.gray['900'],
      '10': darkPalette.gray['950'],
      '11': absolute.white
    }
  }
};

export default {
  light: themeColorsLight,
  dark: themeColorsDark
};
