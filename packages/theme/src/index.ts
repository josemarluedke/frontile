import * as components from './components';
import type { ClassValue } from 'tailwind-variants';
export type * from './components';
export * from './tw';

let localStyles = components;

function registerCustomStyles(styles: Partial<typeof components>): void {
  localStyles = { ...localStyles, ...styles };
}

function useStyles(): typeof components {
  return localStyles;
}

export type SlotsToClasses<S extends string> = {
  [key in S]?: ClassValue;
};

export { useStyles, registerCustomStyles };
export type { ClassValue };
