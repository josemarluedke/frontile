import { swapColorValues } from './util';
import { gray, blue } from './palette-light';

import type { SemanticBaseColors } from './types';
import tokens from './semantic';

const base: SemanticBaseColors = {
  light: {
    background: {
      DEFAULT: '#FFFFFF'
    },
    foreground: {
      ...gray,
      DEFAULT: gray[800]
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
      foreground: gray[800]
    },
    content2: {
      DEFAULT: gray[100],
      foreground: gray[800]
    },
    content3: {
      DEFAULT: gray[200],
      foreground: gray[800]
    },
    content4: {
      DEFAULT: gray[300],
      foreground: gray[800]
    }
  },
  dark: {
    background: {
      DEFAULT: gray[1000]
      // DEFAULT: gray[950]
    },
    foreground: {
      ...swapColorValues(gray),
      DEFAULT: gray[200]
    },
    focus: {
      DEFAULT: blue[400]
    },
    overlay: {
      DEFAULT: '#000000'
    },
    divider: {
      DEFAULT: 'rgba(255, 255, 255, 0.15)'
    },
    content1: {
      DEFAULT: gray[900],
      foreground: gray[200]
    },
    content2: {
      DEFAULT: gray[800],
      foreground: gray[200]
    },
    content3: {
      DEFAULT: gray[700],
      foreground: gray[100]
    },
    content4: {
      DEFAULT: gray[600],
      // foreground: gray[50]
      foreground: gray[100]
    }
  }
};

export const semanticColors = {
  light: {
    ...base.light,
    ...tokens.light
  },
  dark: {
    ...base.dark,
    ...tokens.dark
  }
};
