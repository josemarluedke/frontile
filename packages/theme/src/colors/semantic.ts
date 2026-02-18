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
    subtle: 'oklch(0.5658363307995767 0 none / 0.10)', // palette.gray['500']
    muted: 'oklch(0.832793817744683 0 none / 0.20)', // palette.gray['400']
    soft: palette.gray['200'],
    medium: palette.gray['500'],
    DEFAULT: palette.gray['500'],
    firm: palette.gray['600'],
    strong: palette.gray['700'],
    bolder: palette.gray['800'],
    boldest: absolute.black
  },
  brand: {
    subtle:
      'oklch(0.5891390171822783 0.2183146361066054 270.27610610400785 / 0.07)', // palette.blue['700']
    muted:
      'oklch(0.8956673519109596 0.05034841747138009 264.279641807641 / 0.50)', // palette.blue['300']
    soft: palette.blue['500'],
    medium: palette.blue['700'],
    DEFAULT: palette.blue['700'],
    firm: palette.blue['800'],
    strong: palette.blue['800'],
    bolder: palette.blue['900'],
    boldest: palette.blue['900']
  },
  accent: {
    subtle:
      'oklch(0.8392444068650814 0.11971427543297068 316.07694780747 / 0.40)', // palette.violet['200']
    muted:
      'oklch(0.7841890479703253 0.15804101819779556 313.91484825673484 / 0.50)', // palette.violet['300']
    soft: palette.violet['500'],
    medium: palette.violet['700'],
    DEFAULT: palette.violet['700'],
    firm: palette.violet['800'],
    strong: palette.violet['800'],
    bolder: palette.violet['900'],
    boldest: palette.violet['900']
  },
  success: {
    subtle:
      'oklch(0.8140290632003326 0.12876068370580535 138.0684773124124 / 0.40)', // palette.green['200']
    muted:
      'oklch(0.7526263938794876 0.15295637357993222 137.88187468791435 / 0.50)', // palette.green['300']
    soft: palette.green['500'],
    medium: palette.green['700'],
    DEFAULT: palette.green['700'],
    firm: palette.green['800'],
    strong: palette.green['800'],
    bolder: palette.green['900'],
    boldest: palette.green['900']
  },
  warning: {
    subtle:
      'oklch(0.8360803572549059 0.10545253383961584 54.984627515020065 / 0.40)', // palette.orange['200']
    muted:
      'oklch(0.778843730146193 0.14518925772622943 51.828175949938846 / 0.50)', // palette.orange['300']
    soft: palette.orange['500'],
    medium: palette.orange['500'],
    DEFAULT: palette.orange['500'],
    firm: palette.orange['600'],
    strong: palette.orange['700'],
    bolder: palette.orange['700'],
    boldest: palette.orange['800']
  },
  danger: {
    subtle:
      'oklch(0.7994650092129404 0.11472572871410483 25.784374346748162 / 0.15)', // palette.red['200']
    muted:
      'oklch(0.742837144188543 0.15606209617102812 25.234207587526186 / 0.50)', // palette.red['300']
    soft: palette.red['500'],
    medium: palette.red['700'],
    DEFAULT: palette.red['700'],
    firm: palette.red['800'],
    strong: palette.red['800'],
    bolder: palette.red['900'],
    boldest: palette.red['900']
  },
  // warmth: {
  //   subtle:
  //     'oklch(0.7994650092129404 0.11472572871410483 25.784374346748162 / 0.12)', // palette.red['200']
  //   muted:
  //     'oklch(0.7994650092129404 0.11472572871410483 25.784374346748162 / 0.25)', // palette.red['200']
  //   soft: 'oklch(0.7994650092129404 0.11472572871410483 25.784374346748162 / 0.30)', // palette.red['200']
  //   medium:
  //     'oklch(0.742837144188543 0.15606209617102812 25.234207587526186 / 0.25)', // palette.red['300']
  //   DEFAULT:
  //     'oklch(0.742837144188543 0.15606209617102812 25.234207587526186 / 0.25)', // palette.red[&#x27;300&#x27;]
  //   firm: 'oklch(0.692906161548449 0.19694061557721862 25.106953444547084 / 0.25)', // palette.red['400']
  //   strong:
  //     'oklch(0.6221049708726409 0.2138755156794795 25.28122130481719 / 0.20)', // palette.red['500']
  //   bolder:
  //     'oklch(0.5675786223079923 0.21108128310001628 25.1133132141515 / 0.20)', // palette.red['600']
  //   boldest:
  //     'oklch(0.5160127267768225 0.20199443805857392 25.160626829693395 / 0.15)' // palette.red['700']
  // },
  // growth: {
  //   subtle:
  //     'oklch(0.6748093064370979 0.10397547519174243 189.2942701830159 / 0.12)', // palette.teal['400']
  //   muted:
  //     'oklch(0.6748093064370979 0.10397547519174243 189.2942701830159 / 0.30)', // palette.teal['400']
  //   soft: 'oklch(0.6154699084245361 0.1016563596641955 189.7401459454096 / 0.25)', // palette.teal['500']
  //   medium:
  //     'oklch(0.5561552213143053 0.09628651933170361 189.22129328102463 / 0.20)', // palette.teal['600']
  //   DEFAULT:
  //     'oklch(0.5561552213143053 0.09628651933170361 189.22129328102463 / 0.20)', // palette.teal[&#x27;600&#x27;]
  //   firm: 'oklch(0.4885559104036135 0.08455107562611164 189.33094593406554 / 0.20)', // palette.teal['700']
  //   strong:
  //     'oklch(0.4885559104036135 0.08455107562611164 189.33094593406554 / 0.15)', // palette.teal['700']
  //   bolder:
  //     'oklch(0.40869912844440903 0.0707307358491973 189.33121420748455 / 0.15)', // palette.teal['800']
  //   boldest:
  //     'oklch(0.30365399505940693 0.05263735882731203 188.86590563994713 / 0.10)' // palette.teal['900']
  // },
  // innovation: {
  //   subtle:
  //     'oklch(0.7680306891358843 0.1175698143772996 267.0732875604487 / 0.10)', // palette.blue['500']
  //   muted:
  //     'oklch(0.7680306891358843 0.1175698143772996 267.0732875604487 / 0.30)', // palette.blue['500']
  //   soft: 'oklch(0.6864029217124858 0.16426216212206252 269.40053325002714 / 0.30)', // palette.blue['600']
  //   medium:
  //     'oklch(0.5891390171822783 0.2183146361066054 270.27610610400785 / 0.25)', // palette.blue['700']
  //   DEFAULT:
  //     'oklch(0.5891390171822783 0.2183146361066054 270.27610610400785 / 0.25)', // palette.blue[&#x27;700&#x27;]
  //   firm: 'oklch(0.48752777517453255 0.20297483483379505 270.17773026634876 / 0.20)', // palette.blue['800']
  //   strong:
  //     'oklch(0.48752777517453255 0.20297483483379505 270.17773026634876 / 0.20)', // palette.blue['800']
  //   bolder:
  //     'oklch(0.303291267015569 0.13746649905191705 270.43050625576757 / 0.15)', // palette.blue['900']
  //   boldest:
  //     'oklch(0.303291267015569 0.13746649905191705 270.43050625576757 / 0.10)' // palette.blue['900']
  // },
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
    app: 'var(--color-surface-solid-1)',
    canvas: 'var(--color-surface-solid-2)',
    card: 'var(--color-surface-solid-0)',
    panel: 'var(--color-surface-solid-0)',
    popover: 'var(--color-surface-solid-0)',
    inset: 'oklch(0 0 none / 0.07)', // absolute.black
    overlayContent: 'var(--color-surface-solid-0)'
  }
  // text: {
  //   high: palette.gray['950'],
  //   medium: palette.gray['700'],
  //   DEFAULT: palette.gray['700'],
  //   low: palette.gray['500'],
  //   muted: palette.gray['400'],
  //   disabled: palette.gray['300']
  // }
};

const themeColorsDark: ThemeColors = {
  neutral: {
    subtle: 'oklch(0.832793817744683 0 none / 0.05)', // palette.gray['400']
    muted: 'oklch(0.5658363307995767 0 none / 0.25)', // palette.gray['500']
    soft: palette.gray['700'],
    medium: palette.gray['600'],
    DEFAULT: palette.gray['600'],
    firm: palette.gray['500'],
    strong: palette.gray['300'],
    bolder: palette.gray['200'],
    boldest: absolute.white
  },
  brand: {
    subtle:
      'oklch(0.5891390171822783 0.2183146361066054 270.27610610400785 / 0.07)', // palette.blue['700']
    muted:
      'oklch(0.6864029217124858 0.16426216212206252 269.40053325002714 / 0.40)', // palette.blue['600']
    soft: palette.blue['700'],
    medium: palette.blue['600'],
    DEFAULT: palette.blue['600'],
    firm: palette.blue['500'],
    strong: palette.blue['500'],
    bolder: palette.blue['400'],
    boldest: palette.blue['300']
  },
  accent: {
    subtle:
      'oklch(0.436200827023848 0.14666713062553813 308.08046229842176 / 0.35)', // palette.violet['800']
    muted:
      'oklch(0.5897220235228543 0.1874408792931166 307.9133296711274 / 0.40)', // palette.violet['600']
    soft: palette.violet['700'],
    medium: palette.violet['600'],
    DEFAULT: palette.violet['600'],
    firm: palette.violet['500'],
    strong: palette.violet['500'],
    bolder: palette.violet['400'],
    boldest: palette.violet['300']
  },
  success: {
    subtle:
      'oklch(0.4081897515156614 0.12130761743803167 137.8718056016263 / 0.25)', // palette.green['800']
    muted:
      'oklch(0.5529863134806796 0.15392579851496643 137.7826483752204 / 0.40)', // palette.green['600']
    soft: palette.green['700'],
    medium: palette.green['600'],
    DEFAULT: palette.green['600'],
    firm: palette.green['500'],
    strong: palette.green['500'],
    bolder: palette.green['400'],
    boldest: palette.green['300']
  },
  warning: {
    subtle:
      'oklch(0.5844619845347756 0.16712933275834083 44.988919529305285 / 0.48)', // palette.orange['600']
    muted:
      'oklch(0.6465205454682947 0.17987039107296038 46.6428219795767 / 0.40)', // palette.orange['500']
    soft: palette.orange['700'],
    medium: palette.orange['600'],
    DEFAULT: palette.orange['600'],
    firm: palette.orange['500'],
    strong: palette.orange['500'],
    bolder: palette.orange['400'],
    boldest: palette.orange['300']
  },
  danger: {
    subtle:
      'oklch(0.5160127267768225 0.20199443805857392 25.160626829693395 / 0.15)', // palette.red['700']
    muted:
      'oklch(0.5675786223079923 0.21108128310001628 25.1133132141515 / 0.40)', // palette.red['600']
    soft: palette.red['700'],
    medium: palette.red['600'],
    DEFAULT: palette.red['600'],
    firm: palette.red['500'],
    strong: palette.red['500'],
    bolder: palette.red['400'],
    boldest: palette.red['300']
  },
  // warmth: {
  //   subtle:
  //     'oklch(0.742837144188543 0.15606209617102812 25.234207587526186 / 0.15)', // palette.red['300']
  //   muted:
  //     'oklch(0.742837144188543 0.15606209617102812 25.234207587526186 / 0.25)', // palette.red['300']
  //   soft: 'oklch(0.5160127267768225 0.20199443805857392 25.160626829693395 / 0.20)', // palette.red['700']
  //   medium:
  //     'oklch(0.5675786223079923 0.21108128310001628 25.1133132141515 / 0.20)', // palette.red['600']
  //   DEFAULT:
  //     'oklch(0.5675786223079923 0.21108128310001628 25.1133132141515 / 0.20)', // palette.red[&#x27;600&#x27;]
  //   firm: 'oklch(0.6221049708726409 0.2138755156794795 25.28122130481719 / 0.25)', // palette.red['500']
  //   strong:
  //     'oklch(0.692906161548449 0.19694061557721862 25.106953444547084 / 0.25)', // palette.red['400']
  //   bolder:
  //     'oklch(0.742837144188543 0.15606209617102812 25.234207587526186 / 0.30)', // palette.red['300']
  //   boldest:
  //     'oklch(0.7994650092129404 0.11472572871410483 25.784374346748162 / 0.30)' // palette.red['200']
  // },
  // growth: {
  //   subtle:
  //     'oklch(0.6748093064370979 0.10397547519174243 189.2942701830159 / 0.15)', // palette.teal['400']
  //   muted:
  //     'oklch(0.6154699084245361 0.1016563596641955 189.7401459454096 / 0.30)', // palette.teal['500']
  //   soft: 'oklch(0.4885559104036135 0.08455107562611164 189.33094593406554 / 0.20)', // palette.teal['700']
  //   medium:
  //     'oklch(0.5561552213143053 0.09628651933170361 189.22129328102463 / 0.20)', // palette.teal['600']
  //   DEFAULT:
  //     'oklch(0.5561552213143053 0.09628651933170361 189.22129328102463 / 0.20)', // palette.teal[&#x27;600&#x27;]
  //   firm: 'oklch(0.6154699084245361 0.1016563596641955 189.7401459454096 / 0.25)', // palette.teal['500']
  //   strong:
  //     'oklch(0.6748093064370979 0.10397547519174243 189.2942701830159 / 0.25)', // palette.teal['400']
  //   bolder:
  //     'oklch(0.6748093064370979 0.10397547519174243 189.2942701830159 / 0.30)', // palette.teal['400']
  //   boldest:
  //     'oklch(0.7545935627067466 0.09575046318048248 189.32706498020022 / 0.30)' // palette.teal['300']
  // },
  // innovation: {
  //   subtle:
  //     'oklch(0.7680306891358843 0.1175698143772996 267.0732875604487 / 0.15)', // palette.blue['500']
  //   muted:
  //     'oklch(0.7680306891358843 0.1175698143772996 267.0732875604487 / 0.30)', // palette.blue['500']
  //   soft: 'oklch(0.5891390171822783 0.2183146361066054 270.27610610400785 / 0.25)', // palette.blue['700']
  //   medium:
  //     'oklch(0.6864029217124858 0.16426216212206252 269.40053325002714 / 0.25)', // palette.blue['600']
  //   DEFAULT:
  //     'oklch(0.6864029217124858 0.16426216212206252 269.40053325002714 / 0.25)', // palette.blue[&#x27;600&#x27;]
  //   firm: 'oklch(0.7680306891358843 0.1175698143772996 267.0732875604487 / 0.30)', // palette.blue['500']
  //   strong:
  //     'oklch(0.8334804533340187 0.08227285341373448 265.6191364888125 / 0.30)', // palette.blue['400']
  //   bolder:
  //     'oklch(0.8334804533340187 0.08227285341373448 265.6191364888125 / 0.30)', // palette.blue['400']
  //   boldest:
  //     'oklch(0.8956673519109596 0.05034841747138009 264.279641807641 / 0.35)' // palette.blue['300']
  // },
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
    app: 'var(--color-surface-solid-1)',
    canvas: 'var(--color-surface-solid-2)',
    card: 'var(--color-surface-solid-3)',
    panel: 'var(--color-surface-solid-2)',
    popover: 'var(--color-surface-solid-3)',
    inset: 'oklch(0 0 none / 0.07)', // absolute.black
    overlayContent: 'var(--color-surface-solid-3)'
  }
  // text: {
  //   high: palette.gray['50'],
  //   medium: palette.gray['400'],
  //   DEFAULT: palette.gray['400'],
  //   low: palette.gray['500'],
  //   muted: palette.gray['600'],
  //   disabled: palette.gray['700']
  // }
};

export default {
  light: themeColorsLight,
  dark: themeColorsDark
};
