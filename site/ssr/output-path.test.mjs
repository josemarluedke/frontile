import { test } from 'node:test';
import assert from 'node:assert/strict';

import { outputPathForUrl } from './output-path.mjs';

test('the root route is the deployed index.html', () => {
  assert.equal(outputPathForUrl('/dist', '/'), '/dist/index.html');
});

test('a plain route becomes a flat sibling file', () => {
  assert.equal(
    outputPathForUrl('/dist', '/docs/components/buttons/button'),
    '/dist/docs/components/buttons/button.html',
  );
});

test('an index route drops its trailing slash rather than nesting', () => {
  // Netlify serves /docs/get-started from docs/get-started.html; writing
  // docs/get-started/index.html would only answer at /docs/get-started/.
  assert.equal(
    outputPathForUrl('/dist', '/docs/get-started/'),
    '/dist/docs/get-started.html',
  );
});

test('an index route and its children coexist', () => {
  assert.equal(
    outputPathForUrl('/dist', '/docs/migrations/v0-18/'),
    '/dist/docs/migrations/v0-18.html',
  );
  assert.equal(
    outputPathForUrl('/dist', '/docs/migrations/v0-18/semantic-colors'),
    '/dist/docs/migrations/v0-18/semantic-colors.html',
  );
});
