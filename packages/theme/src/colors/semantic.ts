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
    mild: palette.gray['200'], // TODO: confirm "mild" value
    DEFAULT: palette.gray['500'],
    firm: palette.gray['600'],
    strong: palette.gray['700'],
    bolder: palette.gray['800']
  },
  // Confirmed against Facet 2.0 (Figma): subtle/muted/mild/firm/strong/bolder
  // all moved steps from the previous mapping — this is a full remap, not just
  // an insertion of `mild`.
  primary: {
    subtle: palette.teal['50'],
    muted: palette.teal['100'],
    soft: `${palette.teal['600']}1a`, // palette.teal['600'] @ 10%
    mild: palette.teal['400'],
    DEFAULT: palette.teal['600'],
    firm: palette.teal['700'], // was teal-900
    strong: palette.teal['900'], // was teal-600
    bolder: palette.teal['950'] // was teal-900
  },
  accent: {
    subtle: `${palette.violet['600']}1a`, // palette.violet['600'] @ 10%
    muted: `${palette.violet['600']}33`, // palette.violet['600'] @ 20%
    soft: palette.violet['500'], // bg-hover
    mild: palette.violet['500'], // TODO: confirm "mild" value
    DEFAULT: palette.violet['600'],
    firm: palette.violet['800'], // bg-pressed
    strong: palette.violet['700'], // text
    bolder: palette.violet['900'] // text-strong
  },
  success: {
    subtle: `${palette.green['400']}1a`, // palette.green['400'] @ 10%
    muted: `${palette.green['400']}33`, // palette.green['400'] @ 20%
    soft: palette.green['300'], // bg-hover
    mild: palette.green['300'], // TODO: confirm "mild" value
    DEFAULT: palette.green['400'],
    firm: palette.green['500'], // bg-pressed
    strong: palette.green['800'], // text (darker than bg-rest for legibility)
    bolder: palette.green['900'] // text-strong
  },
  warning: {
    subtle: `${palette.orange['300']}1a`, // palette.orange['300'] @ 10%
    muted: `${palette.orange['300']}33`, // palette.orange['300'] @ 20%
    soft: palette.orange['200'], // bg-hover
    mild: palette.orange['200'], // TODO: confirm "mild" value
    DEFAULT: palette.orange['300'],
    firm: palette.orange['400'], // bg-pressed
    strong: palette.orange['600'], // text (darker than bg-rest for legibility)
    bolder: palette.orange['900'] // text-strong
  },
  danger: {
    subtle: `${palette.red['600']}1a`, // palette.red['600'] @ 10%
    muted: `${palette.red['600']}33`, // palette.red['600'] @ 20%
    soft: palette.red['500'], // bg-hover (lightens too)
    mild: palette.red['500'], // TODO: confirm "mild" value
    DEFAULT: palette.red['600'],
    firm: palette.red['700'], // bg-pressed
    strong: palette.red['600'], // text (= bg-rest for danger)
    bolder: palette.red['900'] // text-strong
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
    mild: palette.gray['700'], // TODO: confirm "mild" value
    DEFAULT: palette.gray['600'],
    firm: palette.gray['500'],
    strong: palette.gray['300'],
    bolder: palette.gray['200']
  },
  // Dark stays unchanged for now (per confirmation, only light was remapped);
  // `mild` is a placeholder pending dark-mode values.
  primary: {
    subtle: `${palette.teal['300']}29`, // palette.teal['300'] @ 16% — bg-tonal
    muted: `${palette.teal['300']}59`, // palette.teal['300'] @ 35%
    soft: palette.teal['500'], // bg-hover (darkens)
    mild: palette.teal['500'], // TODO: confirm "mild" value
    DEFAULT: palette.teal['300'],
    firm: palette.teal['100'], // bg-pressed (flashes light)
    strong: palette.teal['300'], // text (= bg-rest for primary)
    bolder: palette.teal['100'] // text-strong (= bg-pressed for primary)
  },
  accent: {
    subtle: `${palette.violet['300']}29`, // palette.violet['300'] @ 16%
    muted: `${palette.violet['300']}59`, // palette.violet['300'] @ 35%
    soft: palette.violet['500'], // bg-hover
    mild: palette.violet['500'], // TODO: confirm "mild" value
    DEFAULT: palette.violet['300'],
    firm: palette.violet['800'], // bg-pressed (presses deep, unlike primary's flash)
    strong: palette.violet['300'], // text
    bolder: palette.violet['100'] // text-strong
  },
  success: {
    subtle: `${palette.green['400']}29`, // palette.green['400'] @ 16%
    muted: `${palette.green['400']}59`, // palette.green['400'] @ 35%
    soft: palette.green['700'], // bg-hover (darkens)
    mild: palette.green['700'], // TODO: confirm "mild" value
    DEFAULT: palette.green['400'],
    firm: palette.green['900'], // bg-pressed
    strong: palette.green['300'], // text
    bolder: palette.green['100'] // text-strong
  },
  warning: {
    subtle: `${palette.orange['300']}29`, // palette.orange['300'] @ 16%
    muted: `${palette.orange['300']}59`, // palette.orange['300'] @ 35%
    soft: palette.orange['500'], // bg-hover (darkens)
    mild: palette.orange['500'], // TODO: confirm "mild" value
    DEFAULT: palette.orange['300'],
    firm: palette.orange['700'], // bg-pressed
    strong: palette.orange['300'], // text (= bg-rest)
    bolder: palette.orange['100'] // text-strong
  },
  danger: {
    subtle: `${palette.red['400']}29`, // palette.red['400'] @ 16%
    muted: `${palette.red['400']}59`, // palette.red['400'] @ 35%
    soft: palette.red['500'], // bg-hover
    mild: palette.red['500'], // TODO: confirm "mild" value
    DEFAULT: palette.red['400'],
    firm: palette.red['700'], // bg-pressed
    strong: palette.red['300'], // text
    bolder: palette.red['100'] // text-strong
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
    card: palette.gray['900'],
    input: absolute.black,
    modal: absolute.black
  }
};

export default {
  light: themeColorsLight,
  dark: themeColorsDark
};
