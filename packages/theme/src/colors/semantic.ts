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
    subtle: 'oklch(0.9249395393966913 0 none / 0.40)', // palette.gray['200']
    soft: palette.gray['300'],
    medium: palette.gray['600'],
    DEFAULT: palette.gray['600'],
    strong: absolute.black
  },
  success: {
    subtle:
      'oklch(0.6701782338799871 0.1660193399912415 137.91471894298314 / 0.50)', // palette.green['400']
    soft: palette.green['400'],
    medium: palette.green['700'],
    DEFAULT: palette.green['700'],
    strong: palette.green['900']
  },
  brand: {
    subtle:
      'oklch(0.8334804533340187 0.08227285341373448 265.6191364888125 / 0.40)', // palette.blue['400']
    soft: palette.blue['600'],
    medium: palette.blue['800'],
    DEFAULT: palette.blue['800'],
    strong: palette.blue['900']
  },
  danger: {
    subtle:
      'oklch(0.5160127267768225 0.20199443805857392 25.160626829693395 / 0.48)', // palette.red['700']
    soft: palette.red['500'],
    medium: palette.red['600'],
    DEFAULT: palette.red['600'],
    strong: palette.red['800']
  },
  warning: {
    subtle:
      'oklch(0.7994650092129404 0.11472572871410483 25.784374346748162 / 0.40)', // palette.red['200']
    soft: palette.red['100'],
    medium: palette.red['300'],
    DEFAULT: palette.red['300'],
    strong: palette.red['400']
  },
  accent: {
    subtle:
      'oklch(0.436200827023848 0.14666713062553813 308.08046229842176 / 0.48)', // palette.violet['800']
    soft: palette.violet['300'],
    medium: palette.violet['800'],
    DEFAULT: palette.violet['800'],
    strong: palette.violet['900']
  },
  surface: {
    overlay: {
      subtle: 'oklch(0 0 none / 0.0196078431372549)',
      soft: 'oklch(0 0 none / 0.0392156862745098)',
      medium: 'oklch(0 0 none / 0.07058823529411765)',
      strong: 'oklch(0 0 none / 0.10980392156862745)',
      inverse: {
        subtle: 'oklch(1.0000000000000002 0 none / 0.30196078431372547)',
        soft: 'oklch(1.0000000000000002 0 none / 0.5019607843137255)',
        medium: 'oklch(1.0000000000000002 0 none / 0.7019607843137254)',
        strong: 'oklch(1.0000000000000002 0 none / 0.9019607843137255)'
      }
    },
    solid: {
      '0': absolute.white,
      '1': palette.gray['100'],
      '2': palette.gray['200'],
      '3': palette.gray['300'],
      '4': palette.gray['400'],
      '5': palette.gray['500'],
      '6': palette.gray['600'],
      '7': palette.gray['700'],
      '8': palette.gray['800'],
      '9': palette.gray['900'],
      '10': palette.gray['950'],
      '11': absolute.black
    },
    canvas: 'var(--color-surface-solid-1)',
    card: 'var(--color-surface-solid-0)',
    panel: 'var(--color-surface-solid-0)',
    popover: 'var(--color-surface-solid-0)',
    inset: 'var(--color-surface-solid-2)',
    overlayContent: 'var(--color-surface-solid-0)'
  }
};

const themeColorsDark: ThemeColors = {
  neutral: {
    subtle: 'oklch(1.0000000000000002 0 none / 0.10)', // absolute.white
    soft: 'oklch(0.5760991529940905 0 none / 0.90)', // palette.gray['500']
    medium: palette.gray['400'],
    DEFAULT: palette.gray['400'],
    strong: absolute.white
  },
  success: {
    subtle:
      'oklch(0.4875663445983234 0.14082662498103163 137.93529361897015 / 0.25)', // palette.green['700']
    soft: palette.green['950'],
    medium: palette.green['700'],
    DEFAULT: palette.green['700'],
    strong: palette.green['900']
  },
  brand: {
    subtle:
      'oklch(0.5891390171822783 0.2183146361066054 270.27610610400785 / 0.40)', // palette.blue['700']
    soft: palette.blue['700'],
    medium: palette.blue['900'],
    DEFAULT: palette.blue['900'],
    strong: palette.blue['950']
  },
  danger: {
    subtle:
      'oklch(0.5160127267768225 0.20199443805857392 25.160626829693395 / 0.35)', // palette.red['700']
    soft: palette.red['900'],
    medium: palette.red['800'],
    DEFAULT: palette.red['800'],
    strong: palette.red['700']
  },
  warning: {
    subtle:
      'oklch(0.5675786223079923 0.21108128310001628 25.1133132141515 / 0.48)', // palette.red['600']
    soft: palette.red['400'],
    medium: palette.red['700'],
    DEFAULT: palette.red['700'],
    strong: palette.red['200']
  },
  accent: {
    subtle:
      'oklch(0.436200827023848 0.14666713062553813 308.08046229842176 / 0.35)', // palette.violet['800']
    soft: palette.violet['800'],
    medium: palette.violet['900'],
    DEFAULT: palette.violet['900'],
    strong: palette.violet['950']
  },
  surface: {
    overlay: {
      subtle: 'oklch(1.0000000000000002 0 none / 0.03137254901960784)',
      soft: 'oklch(1.0000000000000002 0 none / 0.058823529411764705)',
      medium: 'oklch(1.0000000000000002 0 none / 0.14901960784313725)',
      strong: 'oklch(1.0000000000000002 0 none / 0.23921568627450981)',
      inverse: {
        subtle: 'oklch(0 0 none / 0.14901960784313725)',
        soft: 'oklch(0 0 none / 0.2)',
        medium: 'oklch(0 0 none / 0.30196078431372547)',
        strong: 'oklch(0 0 none / 0.45098039215686275)'
      }
    },
    solid: {
      '0': palette.gray['950'],
      '1': palette.gray['900'],
      '2': palette.gray['800'],
      '3': palette.gray['700'],
      '4': palette.gray['600'],
      '5': palette.gray['500'],
      '6': palette.gray['400'],
      '7': palette.gray['300'],
      '8': palette.gray['200'],
      '9': palette.gray['100'],
      '10': palette.gray['50'],
      '11': absolute.white
    },
    canvas: 'var(--color-surface-solid-1)',
    card: 'var(--color-surface-solid-2)',
    panel: 'var(--color-surface-solid-2)',
    popover: 'var(--color-surface-solid-3)',
    inset: 'var(--color-surface-solid-0)',
    overlayContent: 'var(--color-surface-solid-3)'
  }
};

export default {
  light: themeColorsLight,
  dark: themeColorsDark
};
