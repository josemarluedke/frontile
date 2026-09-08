import * as components from './components';
import type { ClassValue } from 'tailwind-variants';
export type * from './components';
export * from './tw';

// A value export of the `alert` recipe specifically, so tests can assert
// against the real shipped recipe directly rather than through
// `useStyles()` (which returns whatever `registerCustomStyles` last set —
// see `alert-test.gts`, which replaces it at module scope). The rest of the
// component recipes stay accessible only via `useStyles()`/
// `registerCustomStyles()`, matching this file's existing type-only bulk
// re-export.
export { alert } from './components';

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
