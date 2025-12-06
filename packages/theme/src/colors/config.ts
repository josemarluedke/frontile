import * as light from './palette-light';
import * as dark from './palette-dark';
import * as absolute from './palette-absolute';

import type { SemanticBaseColors } from './types';
import tokens from './semantic';

const base: SemanticBaseColors = {
  light: {
    background: absolute.white,
    focus: light.blue[800],
    divider: 'rgba(17, 17, 17, 0.15)'
  },
  dark: {
    background: dark.gray[100],
    focus: dark.blue[800],
    divider: 'rgba(255, 255, 255, 0.15)'
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
