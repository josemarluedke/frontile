import * as light from './palette-light';
import * as dark from './palette-dark';

import type { SemanticBaseColors } from './types';
import tokens from './semantic';

const base: SemanticBaseColors = {
  light: {
    background: {
      DEFAULT: '#FFFFFF'
    },
    focus: {
      DEFAULT: light.blue[800]
    },
    divider: {
      DEFAULT: 'rgba(17, 17, 17, 0.15)'
    }
  },
  dark: {
    background: {
      DEFAULT: dark.gray[100]
    },
    focus: {
      DEFAULT: dark.blue[800]
    },
    divider: {
      DEFAULT: 'rgba(255, 255, 255, 0.15)'
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
