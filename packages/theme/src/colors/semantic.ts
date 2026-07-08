/**
 * Frontile Semantic Colors
 *
 * Semantic color mappings for light and dark themes.
 */

import * as palette from './palette';
import * as absolute from './palette-absolute';

import type { ThemeColors } from './types';

const themeColorsLight: ThemeColors = {
  neutral: {
    subtle: `${palette.gray['500']}1a`, // palette.gray['500'] @ 10%
    muted: `${palette.gray['400']}33`, // palette.gray['400'] @ 20%
    soft: palette.gray['200'],
    medium: palette.gray['500'],
    DEFAULT: palette.gray['500'],
    firm: palette.gray['600'],
    strong: palette.gray['700'],
    bolder: palette.gray['800'],
    boldest: absolute.black
  },
  primary: {
    subtle: `${palette.teal['700']}12`, // palette.teal['700'] @ 7%
    muted: `${palette.teal['300']}80`, // palette.teal['300'] @ 50%
    soft: palette.teal['500'],
    medium: palette.teal['700'],
    DEFAULT: palette.teal['700'],
    firm: palette.teal['800'],
    strong: palette.teal['800'],
    bolder: palette.teal['900'],
    boldest: palette.teal['900']
  },
  accent: {
    subtle: `${palette.violet['200']}66`, // palette.violet['200'] @ 40%
    muted: `${palette.violet['300']}80`, // palette.violet['300'] @ 50%
    soft: palette.violet['500'],
    medium: palette.violet['700'],
    DEFAULT: palette.violet['700'],
    firm: palette.violet['800'],
    strong: palette.violet['800'],
    bolder: palette.violet['900'],
    boldest: palette.violet['900']
  },
  success: {
    subtle: `${palette.green['200']}66`, // palette.green['200'] @ 40%
    muted: `${palette.green['300']}80`, // palette.green['300'] @ 50%
    soft: palette.green['500'],
    medium: palette.green['700'],
    DEFAULT: palette.green['700'],
    firm: palette.green['800'],
    strong: palette.green['800'],
    bolder: palette.green['900'],
    boldest: palette.green['900']
  },
  warning: {
    subtle: `${palette.orange['200']}66`, // palette.orange['200'] @ 40%
    muted: `${palette.orange['300']}80`, // palette.orange['300'] @ 50%
    soft: palette.orange['500'],
    medium: palette.orange['500'],
    DEFAULT: palette.orange['500'],
    firm: palette.orange['600'],
    strong: palette.orange['700'],
    bolder: palette.orange['700'],
    boldest: palette.orange['800']
  },
  danger: {
    subtle: `${palette.red['200']}26`, // palette.red['200'] @ 15%
    muted: `${palette.red['300']}80`, // palette.red['300'] @ 50%
    soft: palette.red['500'],
    medium: palette.red['700'],
    DEFAULT: palette.red['700'],
    firm: palette.red['800'],
    strong: palette.red['800'],
    bolder: palette.red['900'],
    boldest: palette.red['900']
  },
  surface: {
    overlay: {
      subtle: `${absolute.black}05`, // absolute.black @ 2%
      soft: `${absolute.black}0a`, // absolute.black @ 4%
      medium: `${absolute.black}12`, // absolute.black @ 7%
      strong: `${absolute.black}1c`, // absolute.black @ 11%
      scrim: `${absolute.black}bf` // absolute.black @ 75%, scheme-invariant
    },
    app: absolute.white,
    canvas: palette.gray['50'],
    card: `${absolute.white}e6`, // absolute.white @ 90%
    input: absolute.white,
    modal: absolute.white
  }
};

const themeColorsDark: ThemeColors = {
  neutral: {
    subtle: palette.gray['900'],
    muted: palette.gray['800'],
    soft: palette.gray['700'],
    medium: palette.gray['600'],
    DEFAULT: palette.gray['600'],
    firm: palette.gray['500'],
    strong: palette.gray['300'],
    bolder: palette.gray['200'],
    boldest: absolute.white
  },
  primary: {
    subtle: `${palette.teal['700']}12`, // palette.teal['700'] @ 7%
    muted: `${palette.teal['600']}66`, // palette.teal['600'] @ 40%
    soft: palette.teal['700'],
    medium: palette.teal['600'],
    DEFAULT: palette.teal['600'],
    firm: palette.teal['500'],
    strong: palette.teal['500'],
    bolder: palette.teal['400'],
    boldest: palette.teal['300']
  },
  accent: {
    subtle: `${palette.violet['800']}59`, // palette.violet['800'] @ 35%
    muted: `${palette.violet['600']}66`, // palette.violet['600'] @ 40%
    soft: palette.violet['700'],
    medium: palette.violet['600'],
    DEFAULT: palette.violet['600'],
    firm: palette.violet['500'],
    strong: palette.violet['500'],
    bolder: palette.violet['400'],
    boldest: palette.violet['300']
  },
  success: {
    subtle: `${palette.green['800']}40`, // palette.green['800'] @ 25%
    muted: `${palette.green['600']}66`, // palette.green['600'] @ 40%
    soft: palette.green['700'],
    medium: palette.green['600'],
    DEFAULT: palette.green['600'],
    firm: palette.green['500'],
    strong: palette.green['500'],
    bolder: palette.green['400'],
    boldest: palette.green['300']
  },
  warning: {
    subtle: `${palette.orange['600']}7a`, // palette.orange['600'] @ 48%
    muted: `${palette.orange['500']}66`, // palette.orange['500'] @ 40%
    soft: palette.orange['700'],
    medium: palette.orange['600'],
    DEFAULT: palette.orange['600'],
    firm: palette.orange['500'],
    strong: palette.orange['500'],
    bolder: palette.orange['400'],
    boldest: palette.orange['300']
  },
  danger: {
    subtle: `${palette.red['700']}26`, // palette.red['700'] @ 15%
    muted: `${palette.red['600']}66`, // palette.red['600'] @ 40%
    soft: palette.red['700'],
    medium: palette.red['600'],
    DEFAULT: palette.red['600'],
    firm: palette.red['500'],
    strong: palette.red['500'],
    bolder: palette.red['400'],
    boldest: palette.red['300']
  },
  surface: {
    overlay: {
      subtle: `${absolute.white}08`, // absolute.white @ 3%
      soft: `${absolute.white}0f`, // absolute.white @ 6%
      medium: `${absolute.white}26`, // absolute.white @ 15%
      strong: `${absolute.white}3d`, // absolute.white @ 24%
      scrim: `${absolute.black}bf` // absolute.black @ 75%
    },
    app: absolute.black,
    canvas: palette.gray['950'],
    card: palette.gray['800'],
    input: absolute.black,
    modal: palette.gray['700']
  }
};

export default {
  light: themeColorsLight,
  dark: themeColorsDark
};
