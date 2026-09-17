import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { PropertiesTable } from 'site/components/signature';
import type { ComponentDoc } from 'site/components/signature-data';

// Mirrors the real shape of a deprecated argument: the whole JSDoc body is
// the `@deprecated` tag, so `description` comes back empty and the migration
// instruction lives only in `tags.deprecated.value`. See
// site/lib/docfy-plugin-signature-markdown.test.mjs for the parallel
// Markdown-renderer fixture this is kept consistent with.
const args: ComponentDoc['Args'] = [
  {
    identifier: 'appearance',
    type: { type: 'string' },
    isRequired: false,
    isInternal: false,
    description: 'The button appearance',
    tags: {},
  },
  {
    identifier: 'intent',
    type: { type: "'default' | 'primary'", raw: "'default' | 'primary'" },
    isRequired: false,
    isInternal: false,
    description: '',
    tags: {
      deprecated: {
        name: 'deprecated',
        value: 'Use `color`. `default` is now\n`neutral`.',
      },
    },
  },
];

module('Integration | Component | signature', function (hooks) {
  setupRenderingTest(hooks);

  test('a deprecated argument renders a deprecation marker and its migration text', async function (assert) {
    await render(<template><PropertiesTable @items={{args}} /></template>);

    const rows = Array.from(document.querySelectorAll('tbody tr'));
    const intentRow = rows.find((row) => row.textContent?.includes('intent'));

    assert.ok(intentRow, 'expected a row for the deprecated argument');
    assert.ok(
      intentRow?.textContent?.includes('Deprecated'),
      'the row shows a deprecation marker'
    );
    assert.ok(
      intentRow?.textContent?.includes('Use `color`'),
      'the row includes the migration instruction from the tag value'
    );
    assert.ok(
      intentRow?.textContent?.includes('neutral'),
      'the full migration text is present, not truncated'
    );
  });

  test('a non-deprecated argument renders without any deprecation marker', async function (assert) {
    await render(<template><PropertiesTable @items={{args}} /></template>);

    const rows = Array.from(document.querySelectorAll('tbody tr'));
    const appearanceRow = rows.find((row) =>
      row.textContent?.includes('appearance')
    );

    assert.ok(appearanceRow, 'expected a row for the non-deprecated argument');
    assert.notOk(
      appearanceRow?.textContent?.includes('Deprecated'),
      'no deprecation marker leaks onto a normal argument row'
    );
    assert.ok(
      appearanceRow?.textContent?.includes('The button appearance'),
      'its own description still renders'
    );
  });
});
