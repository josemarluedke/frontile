import { registerCustomStyles, useStyles } from '@frontile/theme';
import { realStyles } from './real-theme-styles';

type Styles = ReturnType<typeof useStyles>;
type StyleKey = keyof Styles;

/**
 * Register style overrides for every test in one QUnit module (and its nested
 * modules), putting back whatever was registered before after each test.
 *
 * `registerCustomStyles` writes to one slot shared by the whole test run, so a
 * call at module load -- or in a `module()` callback body, which also runs at
 * load -- replaces those styles for every file in the run, and which file wins
 * depends on load order. Calling this from a module callback instead scopes
 * the override to the tests that asked for it:
 *
 * ```ts
 * module('Integration | Component | Chip', function (hooks) {
 *   setupRenderingTest(hooks);
 *   useCustomStyles(hooks, { chip: chipStubStyles });
 * });
 * ```
 *
 * It is applied per test (`beforeEach`/`afterEach`) rather than once per
 * module because `ember exam --random` interleaves tests from different
 * modules, so a module-wide `before`/`after` pair would leave its override in
 * place for other modules' tests. Nested modules stack: the outer override is
 * applied first and restored last.
 *
 * Nothing is registered while files load, so read the shipped styles from
 * `realStyles`, not by calling `useStyles()` at module scope.
 */
export function useCustomStyles(
  hooks: NestedHooks,
  styles: Partial<Styles>
): void {
  let previous: Partial<Styles> | undefined;

  hooks.beforeEach(function () {
    const current = useStyles();
    previous = Object.fromEntries(
      (Object.keys(styles) as StyleKey[]).map((key) => [key, current[key]])
    ) as Partial<Styles>;
    registerCustomStyles(styles);
  });

  hooks.afterEach(function () {
    if (previous) {
      registerCustomStyles(previous);
      previous = undefined;
    }
  });
}

/**
 * Render one QUnit module (and its nested modules) against the shipped
 * `@frontile/theme` styles for `keys`, regardless of what an enclosing module
 * registered. For tests that assert on real CSS (computed styles, layout)
 * rather than on stub class markers.
 */
export function useRealStyles(hooks: NestedHooks, keys: StyleKey[]): void {
  useCustomStyles(
    hooks,
    Object.fromEntries(
      keys.map((key) => [key, realStyles[key]])
    ) as Partial<Styles>
  );
}

/**
 * Keys whose registered style differs from the shipped one. Used by
 * `test-helper.js` to fail a test that leaves an override behind.
 */
export function leakedStyleKeys(): StyleKey[] {
  const current = useStyles();
  return (Object.keys(current) as StyleKey[]).filter(
    (key) => current[key] !== realStyles[key]
  );
}

/** Put every key back to the shipped style. */
export function restoreRealStyles(): void {
  registerCustomStyles({ ...realStyles });
}
