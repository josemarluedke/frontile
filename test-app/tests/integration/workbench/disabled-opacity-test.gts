import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find, waitUntil } from '@ember/test-helpers';
import { useRealStyles } from '../../helpers/scoped-styles';
import DisabledOpacity from 'test-app/components/foundations/disabled-opacity';

module('Integration | Workbench | disabled opacity', function (hooks) {
  setupRenderingTest(hooks);

  // Measures real CSS, so render against the shipped classes.
  useRealStyles(hooks, ['button']);

  test('reports the disabled button opacity', async function (assert) {
    await render(<template><DisabledOpacity /></template>);
    await waitUntil(
      () =>
        document
          .querySelector('[data-token-value="opacity"]')
          ?.textContent?.trim() !== ''
    );
    const shown = document
      .querySelector('[data-token-value="opacity"]')!
      .textContent!.trim();
    const actual = getComputedStyle(find('button[disabled]')!).opacity;
    assert.strictEqual(shown, actual, 'readout equals computed opacity');
    assert.true(parseFloat(shown) < 1, `disabled is dimmed (${shown})`);
  });
});
