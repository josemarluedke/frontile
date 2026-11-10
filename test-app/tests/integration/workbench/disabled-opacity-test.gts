import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find, waitUntil } from '@ember/test-helpers';
import { registerCustomStyles, useStyles } from '@frontile/theme';
import { realStyles } from '../../helpers/real-theme-styles';
import DisabledOpacity from 'test-app/components/foundations/disabled-opacity';

module('Integration | Workbench | disabled opacity', function (hooks) {
  setupRenderingTest(hooks);

  // Other test files replace `button` styles process-wide; swap the shipped
  // classes in for this module (see frozen-states-test).
  let previous: ReturnType<typeof useStyles>;
  hooks.before(function () {
    previous = useStyles();
    registerCustomStyles({ button: realStyles.button });
  });
  hooks.after(function () {
    registerCustomStyles({ button: previous.button });
  });

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
