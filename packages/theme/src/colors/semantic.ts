import * as lightPalette from './palette-light';
import * as darkPalette from './palette-dark';
import * as absolute from './palette-absolute';

import type { ThemeColors } from './types';

const themeColorsLight: ThemeColors = {
  neutral: {
    'contrast-1': absolute.white,
    strong: absolute.black,
    medium: `${absolute.black}c9`,
    DEFAULT: `${absolute.black}c9`,
    soft: `${absolute.black}73`,
    subtle: `${absolute.black}0f`,
    'contrast-2': absolute.black
  },
  success: {
    'contrast-1': absolute.white,
    subtle: `${lightPalette.green['400']}80`,
    medium: lightPalette.green['800'],
    DEFAULT: lightPalette.green['800'],
    strong: lightPalette.green['900'],
    soft: lightPalette.green['600'],
    'contrast-2': absolute.black
  },
  inverse: {
    'contrast-1': absolute.black,
    subtle: `${absolute.white}24`,
    soft: `${absolute.white}4f`,
    medium: `${absolute.white}c4`,
    DEFAULT: `${absolute.white}c4`,
    strong: absolute.white,
    'contrast-2': absolute.white
  },
  brand: {
    'contrast-1': absolute.white,
    subtle: `${lightPalette.blue['800']}0d`,
    medium: lightPalette.blue['800'],
    DEFAULT: lightPalette.blue['800'],
    soft: lightPalette.blue['500'],
    strong: lightPalette.blue['1000'],
    'contrast-2': absolute.black
  },
  danger: {
    'contrast-1': absolute.white,
    subtle: `${lightPalette.red['800']}1a`,
    soft: lightPalette.red['500'],
    medium: lightPalette.red['800'],
    DEFAULT: lightPalette.red['800'],
    strong: lightPalette.red['900'],
    'contrast-2': absolute.black
  },
  warning: {
    'contrast-1': absolute.white,
    subtle: `${lightPalette.orange['700']}1a`,
    soft: lightPalette.orange['600'],
    medium: lightPalette.orange['700'],
    DEFAULT: lightPalette.orange['700'],
    strong: lightPalette.orange['800'],
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
      '10': lightPalette.gray['1000'],
      '11': absolute.black
    }
  }
};

const themeColorsDark: ThemeColors = {
  neutral: {
    'contrast-1': absolute.black,
    subtle: `${absolute.white}24`,
    soft: `${absolute.white}4f`,
    medium: `${absolute.white}c4`,
    DEFAULT: `${absolute.white}c4`,
    strong: absolute.white,
    'contrast-2': absolute.white
  },
  success: {
    'contrast-1': absolute.white,
    subtle: `${darkPalette.green['1000']}33`,
    soft: darkPalette.green['600'],
    medium: darkPalette.green['900'],
    DEFAULT: darkPalette.green['900'],
    strong: darkPalette.green['1000'],
    'contrast-2': absolute.black
  },
  inverse: {
    'contrast-1': absolute.white,
    subtle: `${absolute.black}0f`,
    soft: `${absolute.black}73`,
    medium: `${absolute.black}c9`,
    DEFAULT: `${absolute.black}c9`,
    strong: absolute.black,
    'contrast-2': absolute.black
  },
  brand: {
    'contrast-1': absolute.white,
    subtle: `${darkPalette.blue['1000']}33`,
    soft: darkPalette.blue['700'],
    medium: darkPalette.blue['800'],
    DEFAULT: darkPalette.blue['800'],
    strong: darkPalette.blue['1000'],
    'contrast-2': absolute.black
  },
  danger: {
    'contrast-1': absolute.white,
    subtle: `${darkPalette.red['1000']}59`,
    soft: darkPalette.red['500'],
    medium: darkPalette.red['800'],
    DEFAULT: darkPalette.red['800'],
    strong: darkPalette.red['1000'],
    'contrast-2': absolute.black
  },
  warning: {
    'contrast-1': absolute.white,
    subtle: `${darkPalette.orange['1000']}59`,
    soft: darkPalette.orange['800'],
    medium: darkPalette.orange['900'],
    DEFAULT: darkPalette.orange['900'],
    strong: darkPalette.orange['1000'],
    'contrast-2': absolute.black
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
      '10': darkPalette.gray['1000'],
      '11': absolute.white
    }
  }
};

export default {
  light: themeColorsLight,
  dark: themeColorsDark
};
