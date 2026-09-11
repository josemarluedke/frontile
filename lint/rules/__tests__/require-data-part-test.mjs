import { test } from 'node:test';
import assert from 'node:assert/strict';
import Linter from 'ember-template-lint';
import plugin from '../../frontile-template-lint-plugin.mjs';

async function lint(template) {
  const linter = new Linter({
    config: {
      plugins: [plugin],
      rules: { 'frontile/require-data-part': true },
    },
  });
  const results = await linter.verify({
    source: template,
    filePath: 'a.hbs',
    moduleId: 'a',
  });
  return results.map((r) => r.message);
}

test('accepts an element whose data-part matches its slot', async () => {
  assert.deepEqual(await lint('<div data-part="trigger" class={{this.styles.trigger}}></div>'), []);
});

test('accepts a kebab-cased part for a camelCase slot', async () => {
  assert.deepEqual(
    await lint('<div data-part="start-content" class={{this.styles.startContent}}></div>'),
    []
  );
});

test('accepts a root carrying both attributes before ...attributes', async () => {
  assert.deepEqual(
    await lint('<div data-component="accordion" data-part="base" class={{this.styles.base}} ...attributes></div>'),
    []
  );
});

test('ignores elements that render no slot', async () => {
  assert.deepEqual(await lint('<div class="plain"></div>'), []);
});

test('accepts classNames as well as styles', async () => {
  assert.deepEqual(await lint('<div data-part="td" class={{this.classNames.td}}></div>'), []);
});

test('flags a missing data-part', async () => {
  assert.deepEqual(await lint('<div class={{this.styles.trigger}}></div>'), [
    'Element renders slot "trigger" but is missing data-part="trigger"',
  ]);
});

test('flags a misspelled data-part', async () => {
  assert.deepEqual(await lint('<div data-part="triger" class={{this.styles.trigger}}></div>'), [
    'data-part="triger" does not match the rendered slot; expected "trigger"',
  ]);
});

test('flags a camelCase data-part', async () => {
  assert.deepEqual(
    await lint('<div data-part="startContent" class={{this.styles.startContent}}></div>'),
    ['data-part="startContent" does not match the rendered slot; expected "start-content"']
  );
});

test('flags data-part written after ...attributes', async () => {
  assert.deepEqual(
    await lint('<div ...attributes data-part="base" class={{this.styles.base}}></div>'),
    ['data-part must be written before ...attributes so a caller value can override it']
  );
});

test('flags a data-test-id duplicating data-part', async () => {
  assert.deepEqual(
    await lint('<div data-part="trigger" data-test-id="trigger" class={{this.styles.trigger}}></div>'),
    ['data-test-id="trigger" duplicates data-part="trigger"; remove it']
  );
});
