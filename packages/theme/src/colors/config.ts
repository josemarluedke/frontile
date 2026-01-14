import * as colors from './palette';
import * as absolute from './palette-absolute';

import type { SemanticBaseColors } from './types';
import tokens from './semantic';

const base: SemanticBaseColors = {
  light: {
    focus: colors.blue[800],
    divider: 'rgba(17, 17, 17, 0.15)'
  },
  dark: {
    focus: colors.blue[800],
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
