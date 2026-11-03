import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { checkCss, readProbes } from '../check-css.mjs';

/** A theme entry in a temp dir, with an optional source file to scan. */
function fixture(css, source) {
  const root = mkdtempSync(join(tmpdir(), 'check-css-'));
  writeFileSync(join(root, 'index.css'), `@source './';\n${css}`);
  if (source) writeFileSync(join(root, 'component.ts'), source);
  return join(root, 'index.css');
}

test('readProbes: one class per custom variant and static utility', () => {
  assert.deepEqual(
    readProbes(`
      @custom-variant aria-invalid (&[aria-invalid="true"]);
      @custom-variant dark (&:is(.dark *));
      @utility focus-ring { outline: 2px solid; }
      @utility tab-* { tab-size: --value(integer); }
    `),
    ['aria-invalid:underline', 'dark:underline', 'focus-ring']
  );
});

test('a valid custom variant passes', async () => {
  const entry = fixture(
    '@custom-variant group-data-is-active (&:is(:where(.group):is([data-active="true"]) *));',
    "const c = 'group-data-is-active:text-inherit';"
  );
  assert.deepEqual(await checkCss({ entry }), []);
});

test('an invalid variant is reported once per rule, with the rule', async () => {
  const entry = fixture(
    '@custom-variant group-data-is-active (:merge(.group)[data-active="true"] &, :merge(.group)[data-open="true"] &);',
    "const c = 'group-data-is-active:text-inherit';"
  );
  const problems = await checkCss({ entry });
  // The used class and the probe each produce one rule.
  assert.equal(problems.length, 2);
  assert.match(problems[0].message, /'merge' is not recognized/);
  assert.ok(problems.some((p) => p.rule.includes('text-inherit')));
  assert.ok(problems.some((p) => p.rule.includes('underline')));
});

test('an invalid variant nothing uses yet is still reported', async () => {
  const entry = fixture('@custom-variant nope (&:nope);');
  const problems = await checkCss({ entry });
  assert.equal(problems.length, 1);
  assert.match(problems[0].rule, /nope\\:underline/);
});

test('the theme compiles to valid CSS', async () => {
  assert.deepEqual(
    await checkCss({ entry: 'packages/theme/src/index.css' }),
    []
  );
});
