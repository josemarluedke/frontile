import { module, test } from 'qunit';
import { setupApplicationTest } from 'ember-qunit';
import { visit, waitUntil } from '@ember/test-helpers';

const ROLES = [
  'neutral',
  'primary',
  'secondary',
  'tertiary',
  'success',
  'warning',
  'danger'
];

module('Acceptance | foundations theme', function (hooks) {
  setupApplicationTest(hooks);

  test('renders every theme card with measured swatches', async function (assert) {
    await visit('/foundations/theme');

    const cards = document.querySelectorAll('[data-workbench-card]');
    assert.strictEqual(cards.length, 10, '10 cards');
    for (const id of [
      ...ROLES.map((r) => `theme-${r}`),
      'theme-surfaces',
      'theme-overlays',
      'theme-utility'
    ]) {
      assert.dom(`#${id}[data-workbench-card]`).exists(`${id} card`);
    }

    assert
      .dom('#theme-primary [data-workbench-swatch]')
      .exists({ count: 16 }, '8 levels x 2 panes');

    // Swatches measure after render.
    await waitUntil(
      () =>
        Array.from(document.querySelectorAll('[data-workbench-swatch]')).every(
          (s) =>
            /^#[0-9a-f]{6,8}$/.test(
              s.querySelector('[data-swatch-hex]')?.textContent?.trim() ?? ''
            )
        ),
      { timeout: 5000 }
    );

    for (const sw of document.querySelectorAll('[data-workbench-swatch]')) {
      const token = sw.getAttribute('data-token');
      assert.ok(
        /^#[0-9a-f]{6,8}$/.test(
          sw.querySelector('[data-swatch-hex]')!.textContent!.trim()
        ),
        `${token} shows a hex`
      );
    }

    for (const role of ROLES) {
      const swatches = document.querySelectorAll(
        `#theme-${role} [data-workbench-swatch]`
      );
      assert.strictEqual(swatches.length, 16, `${role} has 16 swatches`);
      for (const sw of swatches) {
        assert.ok(
          /\d+\.\d:1/.test(
            sw.querySelector('[data-swatch-ratio]')!.textContent!
          ),
          `${sw.getAttribute('data-token')} shows a ratio`
        );
      }
    }

    // Tokens without an `on-*` color show no ratio and are flagged.
    const card = document.querySelector(
      '#theme-surfaces [data-workbench-swatch][data-token="surface-card"]'
    )!;
    assert.ok(
      card.hasAttribute('data-on-token-missing'),
      'surface-card flagged'
    );
    assert.strictEqual(
      card.querySelector('[data-swatch-ratio]')!.textContent!.trim(),
      '',
      'no ratio without an on-token'
    );
    assert
      .dom(
        '#theme-surfaces [data-workbench-swatch][data-token="surface-input"]'
      )
      .doesNotHaveAttribute('data-on-token-missing', 'surface-input has one');
  });
});
