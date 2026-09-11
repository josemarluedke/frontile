import assert from 'node:assert/strict';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

import { lintDoc } from './lint-docs.mjs';

const fixtures = join(dirname(fileURLToPath(import.meta.url)), 'fixtures');

test('component API sections require generated signatures', () => {
  const findings = lintDoc(join(fixtures, 'packages/frontile/src/components/example.md'));
  assert.ok(findings.some(({ message }) => message.includes('has no `<Signature />`')));
});

test('modifier API sections allow hand-written typed tables', () => {
  const findings = lintDoc(join(fixtures, 'packages/frontile/src/modifiers/example.md'));
  assert.ok(!findings.some(({ message }) => message.includes('has no `<Signature />`')));
  assert.equal(findings.filter(({ level }) => level === 'error').length, 0);
});
