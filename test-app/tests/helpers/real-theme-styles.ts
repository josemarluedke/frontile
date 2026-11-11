import { useStyles } from '@frontile/theme';

// `@frontile/theme`'s `useStyles()`/`registerCustomStyles()` share a single
// module-level mutable slot (see `packages/theme/src/index.ts`), so a test
// that overrides a component's styles (to get short, stable class markers to
// assert against) changes them for every test that runs after it. Tests scope
// their overrides with `useCustomStyles`/`useRealStyles` from
// `./scoped-styles`, and `test-helper.js` fails the run if a module leaves one
// behind.
//
// `test-helper.js` imports this module before any test file loads, so the
// values captured here are the real, shipped theme. Code that needs the real
// classes outside a rendering test (e.g. asserting on a recipe's class
// string) should read them from here rather than calling `useStyles()`, which
// returns whatever the enclosing module registered.
export const realStyles = useStyles();
