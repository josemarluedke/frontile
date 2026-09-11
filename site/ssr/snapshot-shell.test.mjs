import assert from 'node:assert/strict';
import { mkdir, mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';

import { assertCleanShell, snapshotShell } from './snapshot-shell.mjs';

test('snapshotShell replaces a stale snapshot with the current client shell', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'frontile-shell-'));
  const clientPath = join(dir, 'index.html');
  const snapshotPath = join(dir, 'dist-ssr', 'app-shell.html');
  const current = '<html><head><script type="module" src="/assets/current.js"></script></head><body></body></html>';

  await writeFile(clientPath, current);
  await mkdir(join(dir, 'dist-ssr'));
  await writeFile(snapshotPath, '<html>stale</html>');
  await snapshotShell(clientPath, snapshotPath);

  assert.equal(await readFile(snapshotPath, 'utf8'), current);
});

test('assertCleanShell rejects prerender output', () => {
  assert.throws(
    () => assertCleanShell('<head><meta name="x-prerendered"><script type="module"></script></head>'),
    /already-prerendered/,
  );
});
