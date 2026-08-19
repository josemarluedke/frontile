/**
 * Frontile Semantic Colors
 *
 * Semantic color mappings for light and dark themes.
 *
 * Values are transcribed from the Beacon design tokens (Figma), where alpha is
 * expressed as a 0–1 float. Here it is folded into the color as a two-digit
 * hex suffix — e.g. 20% becomes `33` (round(0.2 * 255) = 51 = 0x33).
 */

import * as palette from './palette';
import * as absolute from './palette-absolute';

import type { ThemeColors } from './types';

const themeColorsLight: ThemeColors = {
  neutral: {
    subtle: palette.gray['50'],
    muted: palette.gray['100'],
    soft: palette.gray['200'],
    mild: palette.gray['300'],
    DEFAULT: palette.gray['500'],
    firm: palette.gray['700'],
    strong: palette.gray['800'],
    bolder: palette.gray['900']
  },
  primary: {
    subtle: palette.teal['50'],
    muted: palette.teal['100'],
    soft: `${palette.teal['600']}1a`, // palette.teal['600'] @ 10%
    mild: palette.teal['400'],
    DEFAULT: palette.teal['600'],
    firm: palette.teal['700'],
    strong: palette.teal['900'],
    bolder: palette.teal['950']
  },
  secondary: {
    subtle: palette.orange['50'],
    muted: palette.orange['100'],
    soft: `${palette.orange['300']}33`, // palette.orange['300'] @ 20%
    mild: palette.orange['200'],
    DEFAULT: palette.orange['300'],
    firm: palette.orange['400'],
    strong: palette.orange['500'],
    bolder: palette.orange['700']
  },
  tertiary: {
    subtle: palette.pink['100'],
    muted: palette.pink['200'],
    soft: `${palette.pink['400']}40`, // palette.pink['400'] @ 25%
    mild: palette.pink['300'],
    DEFAULT: palette.pink['400'],
    firm: palette.pink['500'],
    strong: palette.pink['600'],
    bolder: palette.pink['700']
  },
  success: {
    subtle: palette.green['50'],
    muted: palette.green['100'],
    soft: `${palette.green['400']}40`, // palette.green['400'] @ 25%
    mild: palette.green['200'],
    DEFAULT: palette.green['400'],
    firm: palette.green['600'],
    strong: palette.green['800'],
    bolder: palette.green['900']
  },
  warning: {
    subtle: palette.orange['50'],
    muted: palette.orange['100'],
    soft: `${palette.orange['300']}33`, // palette.orange['300'] @ 20%
    mild: palette.orange['200'],
    DEFAULT: palette.orange['300'],
    firm: palette.orange['400'],
    strong: palette.orange['500'],
    bolder: palette.orange['700']
  },
  danger: {
    subtle: palette.red['50'],
    muted: palette.red['100'],
    soft: `${palette.red['500']}26`, // palette.red['500'] @ 15%
    mild: palette.red['300'],
    DEFAULT: palette.red['500'],
    firm: palette.red['600'],
    strong: palette.red['800'],
    bolder: palette.red['900']
  },
  // Contrast colors for the translucent `soft` level. These are the one set
  // we cannot auto-generate: the generator measures the raw RGBA value, not
  // the composite over the page, and lands on the inverse of what is legible.
  // Facet specifies black for every role here.
  'on-neutral': { soft: absolute.black },
  'on-primary': { soft: absolute.black },
  'on-secondary': { soft: absolute.black },
  'on-tertiary': { soft: absolute.black },
  'on-success': { soft: absolute.black },
  'on-warning': { soft: absolute.black },
  'on-danger': { soft: absolute.black },
  surface: {
    overlay: {
      subtle: `${absolute.black}0d`, // absolute.black @ 5%
      soft: `${absolute.black}14`, // absolute.black @ 8%
      mild: `${absolute.black}1c`, // absolute.black @ 11%
      firm: `${absolute.black}26`, // absolute.black @ 15%
      strong: `${absolute.black}bf` // absolute.black @ 75%, scheme-invariant
    },
    lift: {
      subtle: `${absolute.white}4d`, // absolute.white @ 30%
      soft: `${absolute.white}80`, // absolute.white @ 50%
      mild: `${absolute.white}b2`, // absolute.white @ 70%
      firm: `${absolute.white}e5`, // absolute.white @ 90%
      strong: `${absolute.white}f2` // absolute.white @ 95%
    },
    app: absolute.white,
    canvas: palette.gray['50'],
    card: absolute.white,
    input: absolute.white,
    modal: absolute.white
  }
};

const themeColorsDark: ThemeColors = {
  neutral: {
    subtle: palette.gray['900'],
    muted: palette.gray['800'],
    soft: palette.gray['700'],
    mild: palette.gray['500'],
    DEFAULT: palette.gray['400'],
    firm: palette.gray['300'],
    strong: palette.gray['200'],
    bolder: palette.gray['100']
  },
  primary: {
    subtle: palette.teal['900'],
    muted: palette.teal['700'],
    soft: `${palette.teal['300']}40`, // palette.teal['300'] @ 25%
    mild: palette.teal['500'],
    DEFAULT: palette.teal['300'],
    firm: palette.teal['200'],
    strong: palette.teal['100'],
    bolder: palette.teal['50']
  },
  secondary: {
    subtle: palette.orange['600'],
    muted: palette.orange['500'],
    soft: `${palette.orange['300']}33`, // palette.orange['300'] @ 20%
    mild: palette.orange['400'],
    DEFAULT: palette.orange['300'],
    firm: palette.orange['200'],
    strong: palette.orange['200'], // = firm in the Beacon dark tokens
    bolder: palette.orange['100']
  },
  tertiary: {
    subtle: palette.pink['900'],
    muted: palette.pink['700'],
    soft: `${palette.pink['500']}33`, // palette.pink['500'] @ 20%
    mild: palette.pink['600'],
    DEFAULT: palette.pink['500'],
    firm: palette.pink['400'],
    strong: palette.pink['300'],
    bolder: palette.pink['200']
  },
  success: {
    subtle: palette.green['950'],
    muted: palette.green['900'],
    soft: `${palette.green['400']}33`, // palette.green['400'] @ 20%
    mild: palette.green['600'],
    DEFAULT: palette.green['400'],
    firm: palette.green['300'],
    strong: palette.green['200'],
    bolder: palette.green['100']
  },
  warning: {
    subtle: palette.orange['600'],
    muted: palette.orange['500'],
    soft: `${palette.orange['300']}33`, // palette.orange['300'] @ 20%
    mild: palette.orange['400'],
    DEFAULT: palette.orange['300'],
    firm: palette.orange['200'],
    strong: palette.orange['200'], // = firm in the Beacon dark tokens
    bolder: palette.orange['100']
  },
  danger: {
    subtle: palette.red['900'],
    muted: palette.red['700'],
    soft: `${palette.red['400']}26`, // palette.red['400'] @ 15%
    mild: palette.red['600'],
    DEFAULT: palette.red['400'],
    firm: palette.red['300'],
    strong: palette.red['100'],
    bolder: palette.red['50']
  },
  // Contrast colors for the translucent `soft` level. These are the one set
  // we cannot auto-generate: the generator measures the raw RGBA value, not
  // the composite over the page, and lands on the inverse of what is legible.
  // Facet specifies white for every role here.
  'on-neutral': { soft: absolute.white },
  'on-primary': { soft: absolute.white },
  'on-secondary': { soft: absolute.white },
  'on-tertiary': { soft: absolute.white },
  'on-success': { soft: absolute.white },
  'on-warning': { soft: absolute.white },
  'on-danger': { soft: absolute.white },
  surface: {
    overlay: {
      subtle: `${absolute.white}12`, // absolute.white @ 7%
      soft: `${absolute.white}26`, // absolute.white @ 15%
      mild: `${absolute.white}40`, // absolute.white @ 25%
      firm: `${absolute.white}59`, // absolute.white @ 35%
      strong: `${absolute.black}bf` // absolute.black @ 75%
    },
    lift: {
      subtle: `${absolute.black}33`, // absolute.black @ 20%
      soft: `${absolute.black}4d`, // absolute.black @ 30%
      mild: `${absolute.black}80`, // absolute.black @ 50%
      firm: `${absolute.black}99`, // absolute.black @ 60%
      strong: `${absolute.black}f2` // absolute.black @ 95%
    },
    app: absolute.black,
    canvas: palette.gray['950'],
    card: palette.gray['800'],
    input: absolute.black,
    modal: palette.gray['950']
  }
};

export default {
  light: themeColorsLight,
  dark: themeColorsDark
};
