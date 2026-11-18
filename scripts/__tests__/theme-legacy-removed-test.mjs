import { test } from 'node:test';
import assert from 'node:assert/strict';

// v0.19 removed ember-power-select support from the theme. Reads the built
// plugin entry, so run it after `pnpm --filter @frontile/theme build`. The
// test-app cannot import this entry: it pulls in `tailwindcss/plugin`, which
// hangs the browser test page.
test('the theme safelist has no ember-power-select classes', async () => {
  const { safelist } = await import('../../packages/theme/dist/plugin.js');
  assert.ok(Array.isArray(safelist) && safelist.length > 0, 'safelist loads');
  assert.deepEqual(
    safelist.filter((cls) => cls.includes('ember-power-select')),
    []
  );
});
