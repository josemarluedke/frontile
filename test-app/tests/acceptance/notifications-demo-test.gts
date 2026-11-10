import { module, test } from 'qunit';
import { setupApplicationTest } from 'ember-qunit';
import { visit, click, waitFor } from '@ember/test-helpers';

module('Acceptance | notifications demo', function (hooks) {
  setupApplicationTest(hooks);

  test('submitting the form shows a notification', async function (assert) {
    await visit('/notifications');
    // Preserve it: `click` waits for pending run-loop timers, so an auto-removed
    // notification would be gone again before the assertion runs.
    await click('input[name="preserve"]');
    await click('button[type=submit]');
    // Form's submit handler is async, so the card lands after `click` settles.
    await waitFor('[data-component="notification-card"]', { timeout: 2000 });

    assert
      .dom('[data-component="notification-card"]')
      .exists('a notification card is rendered')
      .includesText('Sed diam nonumy');
  });
});
