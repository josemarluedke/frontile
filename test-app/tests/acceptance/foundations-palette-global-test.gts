import { module, test } from 'qunit';
import { setupApplicationTest } from 'ember-qunit';
import { visit, waitUntil } from '@ember/test-helpers';

const RAMPS = [
  'gray',
  'blue',
  'green',
  'orange',
  'pink',
  'red',
  'teal',
  'violet',
  'yellow'
];

async function settled(selector: string): Promise<void> {
  await waitUntil(
    () => {
      const els = document.querySelectorAll(selector);
      return (
        els.length > 0 &&
        Array.from(els).every((e) => (e.textContent ?? '').trim() !== '')
      );
    },
    { timeout: 5000 }
  );
}

module('Acceptance | foundations palette and global', function (hooks) {
  setupApplicationTest(hooks);

  test('palette renders a card per ramp plus absolute', async function (assert) {
    await visit('/foundations/palette');

    assert
      .dom('[data-workbench-card]')
      .exists({ count: 10 }, '9 ramps plus absolute');
    for (const name of [...RAMPS, 'absolute']) {
      assert.dom(`#palette-${name}[data-workbench-card]`).exists(name);
    }

    assert
      .dom('#palette-gray [data-palette-step]')
      .exists({ count: 22 }, '11 steps x 2 panes');
    assert
      .dom('#palette-gray [data-palette-step="500"] [data-step-value]')
      .exists({ count: 2 }, 'gray 500 value in both panes');
    const gray500 = document.querySelector(
      '#palette-gray [data-palette-step="500"] [data-step-value]'
    );
    assert.strictEqual(gray500?.textContent?.trim(), '#94918f');
    assert
      .dom('#palette-absolute [data-palette-step]')
      .exists({ count: 4 }, 'black and white x 2 panes');
    assert
      .dom('#palette-absolute')
      .includesText(
        'copied from palette-absolute.ts',
        'absolute says its values are copies'
      )
      .includesText('they are not live');
    assert.dom('#palette-gray').includesText('not emitted as CSS variables');
  });

  test('global cards show non-empty measured values', async function (assert) {
    await visit('/foundations/global');

    const counts: Record<string, number> = {
      'global-radius': 22,
      'global-elevation': 12,
      'global-icon-sizes': 28,
      'global-opacity': 2,
      'global-breakpoints': 10
    };
    for (const [id, count] of Object.entries(counts)) {
      assert.dom(`#${id}[data-workbench-card]`).exists(id);
      assert
        .dom(`#${id} [data-token-value]`)
        .exists({ count }, `${id} has ${count} values`);
      await settled(`#${id} [data-token-value]`);
      for (const el of document.querySelectorAll(`#${id} [data-token-value]`)) {
        assert.notStrictEqual(
          el.textContent?.trim(),
          '',
          `${id} ${el.getAttribute('data-token-value')} is non-empty`
        );
      }
    }

    assert
      .dom('#global-breakpoints [data-token-value="--breakpoint-md"]')
      .hasText(/\d/, 'breakpoint resolves to a length');
    assert
      .dom('#global-radius [data-token-value="--radius-pill"]')
      .hasText('9999px');
    // Computed tokens show the computed value; the tooltip names the token
    // and carries its raw value, where the variable is emitted at all.
    // (Tailwind emits only the theme variables something uses, so
    // `--radius-none` and `--radius-default` have no raw value here.)
    const radii = Array.from(
      document.querySelectorAll<HTMLElement>(
        '#global-radius [data-token-value]'
      )
    );
    let withRaw = 0;
    for (const el of radii) {
      const name = el.getAttribute('data-token-value')!;
      const raw = getComputedStyle(el).getPropertyValue(name).trim();
      if (raw) {
        withRaw++;
      }
      assert.strictEqual(
        el.getAttribute('title'),
        raw ? `${name}: ${raw}` : name,
        `${name} tooltip`
      );
    }
    assert.strictEqual(withRaw, 18, '9 emitted radius tokens x 2 panes');
    assert
      .dom('#global-radius [data-token-value="--radius-pill"]')
      .hasAttribute('title', /^--radius-pill: \S/);
    assert
      .dom('#global-opacity button[disabled]')
      .exists({ count: 2 }, 'a disabled button per pane');
  });
});
