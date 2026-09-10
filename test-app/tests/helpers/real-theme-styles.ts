import { useStyles } from '@frontile/theme';

// `@frontile/theme`'s `useStyles()`/`registerCustomStyles()` share a single
// module-level mutable slot (see `packages/theme/src/index.ts`): once any
// test file overrides a component's styles (as several files under
// `tests/integration/components/` do, to get short, stable class markers to
// assert against), that override replaces the shipped classes for every
// other test file loaded in the same run -- there is no per-file isolation.
//
// `test-helper.js` imports this module before it calls `loadTests()` (which
// is what actually evaluates every `*-test.gts` file's module-level code,
// including their own `registerCustomStyles` calls), so the values captured
// here at import time are guaranteed to be the real, shipped theme -- not
// whichever mock happened to load first. Any test that needs to render
// against the real classes (e.g. a real-CSS layout assertion that a mocked
// marker class could not exercise) should import from here instead of
// calling `useStyles()` itself.
export const realStyles = useStyles();
