import { test } from 'node:test';
import assert from 'node:assert/strict';

import { fontUrls, routeBundles, routeChunksFor } from './preload.mjs';

const ENTRY = 'app/-embroider-route-entrypoint.js:route=';

/** Shaped like a real Vite manifest, trimmed to what these functions read. */
const manifest = {
  // The top-level `docs` bundle: no `_route_` marker in its filename.
  [`${ENTRY}docs`]: {
    file: 'assets/-embroider-route-entrypoint-aaaaaaaa.js',
    imports: ['_shared-bbbbbbbb.js'],
  },
  // Keyed by whichever route was seen first, not by the split point.
  [`${ENTRY}docs.components.buttons.button-group`]: {
    file: 'assets/-embroider-route-entrypoint.js_route_docs.components.buttons-cccccccc.js',
    imports: ['_shared-bbbbbbbb.js', '_signature-dddddddd.js'],
  },
  [`${ENTRY}docs.theming.component-styles`]: {
    file: 'assets/-embroider-route-entrypoint.js_route_docs.theming-eeeeeeee.js',
    imports: [],
  },
  '_shared-bbbbbbbb.js': { file: 'assets/shared-bbbbbbbb.js' },
  '_signature-dddddddd.js': { file: 'assets/signature-dddddddd.js' },
  'index.html': {
    file: 'assets/main-ffffffff.js',
    css: ['assets/main-11111111.css'],
  },
};

test('split points come from the filename, not the manifest key', () => {
  const bundles = routeBundles(manifest);

  assert.deepEqual([...bundles.keys()].sort(), [
    'docs',
    'docs.components.buttons',
    'docs.theming',
  ]);
});

test('a page pulls its own bundle and every ancestor split point', () => {
  const bundles = routeBundles(manifest);

  // Visiting a buttons page activates the `docs` route too, so both load.
  assert.deepEqual(routeChunksFor(bundles, 'docs.components.buttons.button'), [
    'assets/-embroider-route-entrypoint-aaaaaaaa.js',
    'assets/-embroider-route-entrypoint.js_route_docs.components.buttons-cccccccc.js',
    'assets/shared-bbbbbbbb.js',
    'assets/signature-dddddddd.js',
  ]);
});

test('static imports are followed, so shared chunks are not a third wave', () => {
  const bundles = routeBundles(manifest);

  assert.ok(
    routeChunksFor(bundles, 'docs.components.buttons.button').includes(
      'assets/signature-dddddddd.js',
    ),
  );
});

test('a sibling section does not pull another section', () => {
  const bundles = routeBundles(manifest);
  const files = routeChunksFor(bundles, 'docs.theming.overview');

  assert.ok(
    !files.some((file) => file.includes('docs.components.buttons')),
    'the buttons bundle is unrelated to a theming page',
  );
});

test('a split point is matched on dot boundaries', () => {
  const bundles = routeBundles(manifest);

  // `docs.theming-extras` must not match the `docs.theming` split point.
  assert.deepEqual(routeChunksFor(bundles, 'docs.theming-extras.index'), [
    'assets/-embroider-route-entrypoint-aaaaaaaa.js',
    'assets/shared-bbbbbbbb.js',
  ]);
});

test('an unsplit route needs nothing extra', () => {
  const bundles = routeBundles(manifest);

  assert.deepEqual(routeChunksFor(bundles, 'index'), []);
});

test('a missing route name is not an error', () => {
  assert.deepEqual(routeChunksFor(routeBundles(manifest), undefined), []);
});

test('font URLs are read out of the stylesheet, hash included', () => {
  const css = `
    @font-face{font-family:Open Sans;src:url(/assets/open-sans-variable-B73aTk82.woff2)format("woff2-variations")}
    @font-face{font-family:Domine;src:url(/assets/domine-variable-B3iTxHSC.woff2)format("woff2-variations")}
  `;

  assert.deepEqual(fontUrls(css, ['open-sans-variable', 'domine-variable']), [
    '/assets/open-sans-variable-B73aTk82.woff2',
    '/assets/domine-variable-B3iTxHSC.woff2',
  ]);
});

test('a font that is not in the stylesheet is skipped', () => {
  assert.deepEqual(fontUrls('', ['open-sans-variable']), []);
});
