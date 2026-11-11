import { module, test } from 'qunit';
import { setupApplicationTest } from 'ember-qunit';
import { visit, waitUntil } from '@ember/test-helpers';

const PX = /^\d+(\.\d+)?px$/;

const ROLE_COUNTS: Record<string, number> = {
  marquee: 11,
  header: 10,
  strong: 10,
  body: 11,
  label: 10,
  code: 2,
  caption: 2
};

async function measured(selector: string, count: number): Promise<void> {
  await waitUntil(
    () => {
      const els = document.querySelectorAll(selector);
      return (
        els.length === count &&
        Array.from(els).every((e) => (e.textContent ?? '').trim() !== '')
      );
    },
    { timeout: 5000 }
  );
}

module('Acceptance | foundations typography', function (hooks) {
  setupApplicationTest(hooks);

  test('renders one card per role plus the scale', async function (assert) {
    await visit('/foundations/typography');

    assert.dom('[data-workbench-card]').exists({ count: 8 });
    for (const role of [...Object.keys(ROLE_COUNTS), 'scale']) {
      assert.dom(`#type-${role}[data-workbench-card]`).exists(role);
    }
  });

  test('every role size is measured in px', async function (assert) {
    await visit('/foundations/typography');

    for (const [role, count] of Object.entries(ROLE_COUNTS)) {
      const sel = `#type-${role} [data-workbench-specimen] [data-measure="fontSize"]`;
      await measured(sel, count);
      const values = Array.from(document.querySelectorAll(sel)).map((e) =>
        (e.textContent ?? '').trim()
      );
      assert.strictEqual(values.length, count, `${role}: ${count} specimens`);
      for (const v of values) {
        assert.true(PX.test(v), `${role}: "${v}" is px`);
      }
    }
    assert.dom('[data-workbench-specimen]').exists({ count: 56 });
  });

  test('sizes within a role are not all identical', async function (assert) {
    await visit('/foundations/typography');
    const sel = '#type-header [data-measure="fontSize"]';
    await measured(sel, 10);
    const values = new Set(
      Array.from(document.querySelectorAll(sel)).map((e) => e.textContent)
    );
    assert.true(values.size > 5, `distinct sizes: ${values.size}`);
  });

  test('scale card shows the ratio and 35 px steps', async function (assert) {
    await visit('/foundations/typography');

    await waitUntil(
      () =>
        (
          document.querySelector('[data-token-value="--typescale-ratio"]')
            ?.textContent ?? ''
        ).trim() !== '',
      { timeout: 5000 }
    );
    assert
      .dom('[data-token-value="--typescale-ratio"]')
      .hasText('1.067', 'ratio');
    const sel = '#type-scale [data-scale-step] [data-token-value]';
    await measured(sel, 35);
    const values = Array.from(document.querySelectorAll(sel)).map((e) =>
      (e.textContent ?? '').trim()
    );
    assert.strictEqual(values.length, 35, '35 steps (0 to 34)');
    for (const v of values) {
      assert.true(PX.test(v), `"${v}" is px`);
    }
    assert.strictEqual(values[12], '16px', 'step 12 is the 1rem base');
  });
});
