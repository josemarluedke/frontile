import { test } from 'node:test';
import assert from 'node:assert/strict';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  docfyPluginPageDescriptions,
  loadInventory,
} from './docfy-plugin-page-descriptions.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const fixtureInventory = [
  {
    path: '/docs/components/buttons/button',
    description: 'A clickable button.',
  },
  { path: '/docs/components/forms/input', description: 'A text field.' },
];

function makePage(url, frontmatter = {}) {
  return {
    meta: { url, frontmatter },
  };
}

test('sets meta.frontmatter.description on a page matching an inventory entry', () => {
  const page = makePage('/docs/components/buttons/button');
  const plugin = docfyPluginPageDescriptions(fixtureInventory);

  plugin.runAfter({ pages: [page] });

  assert.strictEqual(page.meta.frontmatter.description, 'A clickable button.');
});

test('does not overwrite a description already declared in page frontmatter', () => {
  const page = makePage('/docs/components/buttons/button', {
    description: 'A custom, hand-written description.',
  });
  const plugin = docfyPluginPageDescriptions(fixtureInventory);

  plugin.runAfter({ pages: [page] });

  assert.strictEqual(
    page.meta.frontmatter.description,
    'A custom, hand-written description.',
  );
});

test('tolerates a trailing slash on the page URL', () => {
  const page = makePage('/docs/components/buttons/button/');
  const plugin = docfyPluginPageDescriptions(fixtureInventory);

  plugin.runAfter({ pages: [page] });

  assert.strictEqual(page.meta.frontmatter.description, 'A clickable button.');
});

test('tolerates a trailing slash on the inventory item path', () => {
  const inventory = [
    {
      path: '/docs/components/buttons/button/',
      description: 'A clickable button.',
    },
  ];
  const page = makePage('/docs/components/buttons/button');
  const plugin = docfyPluginPageDescriptions(inventory);

  plugin.runAfter({ pages: [page] });

  assert.strictEqual(page.meta.frontmatter.description, 'A clickable button.');
});

test('warns when an inventory item matches no page', () => {
  const page = makePage('/docs/components/buttons/button');
  const plugin = docfyPluginPageDescriptions(fixtureInventory);

  const originalWarn = console.warn;
  const warnings = [];
  console.warn = (message) => warnings.push(message);

  try {
    plugin.runAfter({ pages: [page] });
  } finally {
    console.warn = originalWarn;
  }

  assert.strictEqual(warnings.length, 1);
  assert.ok(warnings[0].includes('[docfy-plugin-page-descriptions]'));
  assert.ok(warnings[0].includes('/docs/components/forms/input'));
});

test('does not warn and does not touch a page with no inventory entry', () => {
  const page = makePage('/docs/guide-page');
  const plugin = docfyPluginPageDescriptions(fixtureInventory);

  const originalWarn = console.warn;
  const warnings = [];
  console.warn = (message) => warnings.push(message);

  try {
    plugin.runAfter({ pages: [page] });
  } finally {
    console.warn = originalWarn;
  }

  // Both inventory items are unmatched here (there's only one page, and it
  // matches neither), so two warnings are expected - but none should mention
  // the guide page itself, and the guide page's frontmatter stays untouched.
  assert.strictEqual(warnings.length, 2);
  assert.strictEqual(page.meta.frontmatter.description, undefined);
});

test('loadInventory parses the real component-inventory.json and returns non-empty items with path and description', () => {
  const inventoryPath = path.resolve(
    __dirname,
    '../app/components/component-inventory.json',
  );

  const items = loadInventory(inventoryPath);

  assert.ok(Array.isArray(items));
  assert.ok(items.length > 0);

  items.forEach((item) => {
    assert.strictEqual(typeof item.path, 'string');
    assert.ok(item.path.length > 0, 'expected a non-empty path');
    assert.strictEqual(typeof item.description, 'string');
    assert.ok(
      item.description.length > 0,
      `expected a non-empty description for ${item.path}`,
    );
  });
});

test('loadInventory throws a clear error when the file does not exist', () => {
  const dir = path.dirname(fileURLToPath(import.meta.url));
  const badPath = path.join(dir, 'does-not-exist-inventory.json');

  assert.throws(() => {
    loadInventory(badPath);
  });
});
