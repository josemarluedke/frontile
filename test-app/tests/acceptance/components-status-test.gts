import { module, test } from 'qunit';
import { setupApplicationTest } from 'ember-qunit';
import { visit } from '@ember/test-helpers';
import {
  ALERT_STATUSES,
  ALERT_VARIANTS,
  PROGRESS_BAR_COLORS,
  PROGRESS_BAR_SIZES,
  PROGRESS_BAR_VALUES
} from 'test-app/utils/workbench/options';

module('Acceptance | components status', function (hooks) {
  setupApplicationTest(hooks);

  test('renders the two status cards', async function (assert) {
    await visit('/components/status');

    assert.dom('h1').hasText('Status');
    assert.dom('[data-workbench-card]').exists({ count: 2 });
    assert.dom('#alert[data-workbench-card]').exists('alert card');
    assert.dom('#progress-bar[data-workbench-card]').exists('progress card');
  });

  test('Alert matrix has one row per status in each pane', async function (assert) {
    await visit('/components/status');

    assert.true(ALERT_STATUSES.length > 0, 'there are statuses to check');
    for (const status of ALERT_STATUSES) {
      assert
        .dom(`#alert-matrix [data-alert-row="${status}"]`)
        .exists({ count: 3 }, `${status} has a row in LIGHT/DARK/INVERSE`);
      for (const variant of ALERT_VARIANTS) {
        assert
          .dom(
            `#alert-matrix [data-alert-row="${status}"] [data-component="alert"][data-test-status="${status}"][data-variant="${variant}"]`
          )
          .exists({ count: 3 }, `${status}/${variant} in each pane`);
      }
    }
    assert
      .dom('#alert-matrix [data-alert-row]')
      .exists({ count: ALERT_STATUSES.length * 3 });
  });

  test('Alert content section shows the optional parts', async function (assert) {
    await visit('/components/status');

    assert.dom('#alert-content [data-part="close-button"]').exists();
    assert.dom('#alert-content [data-part="actions"]').exists();
    assert.dom('#alert-content [data-part="title"]').exists();
    assert.dom('#alert-content [data-part="description"]').exists();
  });

  test('ProgressBar sizes and colors render at 0, 50 and 100', async function (assert) {
    await visit('/components/status');

    for (const size of PROGRESS_BAR_SIZES) {
      for (const value of PROGRESS_BAR_VALUES) {
        assert
          .dom(
            `#progress-bar-sizes [data-bar-size="${size}"] [role="progressbar"][aria-valuenow="${value}"]`
          )
          .exists({ count: 1 }, `${size} at ${value}`);
      }
    }
    for (const color of PROGRESS_BAR_COLORS) {
      for (const value of PROGRESS_BAR_VALUES) {
        assert
          .dom(
            `#progress-bar-colors [data-bar-color="${color}"] [role="progressbar"][aria-valuenow="${value}"]`
          )
          .exists({ count: 3 }, `${color} at ${value} in each pane`);
      }
    }
    const widths = Array.from(
      document.querySelectorAll<HTMLElement>(
        '#progress-bar-sizes [data-bar-size="md"] [role="progressbar"]'
      )
    ).map((el) => el.style.width);
    assert.deepEqual(widths, ['0%', '50%', '100%']);
  });
});
