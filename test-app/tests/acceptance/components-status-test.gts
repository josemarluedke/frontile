import { module, test } from 'qunit';
import { setupApplicationTest } from 'ember-qunit';
import { click, visit } from '@ember/test-helpers';
import { registerCustomStyles, useStyles } from '@frontile/theme';
import { realStyles } from '../helpers/real-theme-styles';
import {
  ALERT_STATUSES,
  ALERT_VARIANTS,
  PROGRESS_BAR_COLORS,
  PROGRESS_BAR_RADII,
  PROGRESS_BAR_SIZES,
  PROGRESS_BAR_VALUES
} from 'test-app/utils/workbench/options';

module('Acceptance | components status', function (hooks) {
  setupApplicationTest(hooks);

  // Other test files replace component styles process-wide; the style
  // assertions below need the shipped classes. Restore afterwards.
  let previous: ReturnType<typeof useStyles>;
  hooks.before(function () {
    previous = useStyles();
    registerCustomStyles({
      alert: realStyles.alert,
      progressBar: realStyles.progressBar
    });
  });
  hooks.after(function () {
    if (previous) {
      registerCustomStyles({
        alert: previous.alert,
        progressBar: previous.progressBar
      });
    }
  });

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

  test('ARIA role follows status: alert for warning and danger only', async function (assert) {
    await visit('/components/status');

    for (const status of ALERT_STATUSES) {
      const expected =
        status === 'warning' || status === 'danger' ? 'alert' : 'status';
      const alerts = document.querySelectorAll(
        `#alert-matrix [data-alert-row="${status}"] [data-component="alert"]`
      );
      assert.strictEqual(
        alerts.length,
        3 * ALERT_VARIANTS.length,
        `${status} renders every variant in each pane`
      );
      assert.true(
        Array.from(alerts).every((el) => el.getAttribute('role') === expected),
        `${status} alerts have role=${expected}`
      );
    }
    assert
      .dom('#alert-matrix [role="alert"]')
      .exists(
        { count: 2 * ALERT_VARIANTS.length * 3 },
        'role=alert only on warning and danger rows'
      );
  });

  test('banner layout drops the radius and border', async function (assert) {
    await visit('/components/status');

    // Other test files replace component styles process-wide, so compare the
    // classes the recipe applies rather than computed values.
    const inline = document.querySelector(
      '#alert-layout [data-layout="inline"] [data-component="alert"]'
    )!;
    const banner = document.querySelector(
      '#alert-layout [data-layout="banner"] [data-component="alert"]'
    )!;
    assert.ok(inline && banner, 'both layouts render');
    assert.notStrictEqual(
      banner.className,
      inline.className,
      'banner applies different base classes'
    );
    const inlineStyle = window.getComputedStyle(inline);
    const bannerStyle = window.getComputedStyle(banner);
    assert.notStrictEqual(
      inlineStyle.borderTopLeftRadius,
      '0px',
      'inline alert is rounded'
    );
    assert.strictEqual(
      bannerStyle.borderTopLeftRadius,
      '0px',
      'banner is square'
    );
    assert.strictEqual(
      bannerStyle.borderTopWidth,
      '0px',
      'banner has no border'
    );
  });

  test('Alert content: close does not hide the alert', async function (assert) {
    await visit('/components/status');

    const before = document.querySelectorAll(
      '#alert-content [data-component="alert"]'
    ).length;
    await click('#alert-content [data-part="close-button"]');
    assert
      .dom('#alert-content [data-component="alert"]')
      .exists({ count: before }, 'alert stays in the DOM');
  });

  test('indeterminate bars ignore @progress and omit aria-valuenow', async function (assert) {
    await visit('/components/status');

    const bars = document.querySelectorAll(
      '#progress-bar-indeterminate [role="progressbar"]'
    );
    assert.strictEqual(
      bars.length,
      PROGRESS_BAR_COLORS.length,
      'one per color'
    );
    assert
      .dom(
        '#progress-bar-indeterminate [role="progressbar"]:not([aria-valuenow])'
      )
      .exists({ count: PROGRESS_BAR_COLORS.length });
    assert.true(
      Array.from(bars).every((b) => (b as HTMLElement).style.width === '50%'),
      'fill is always half the track'
    );
  });

  test('Radius section applies each radius to the track', async function (assert) {
    await visit('/components/status');

    for (const radius of PROGRESS_BAR_RADII) {
      assert
        .dom(
          `#progress-bar-radius [data-radius="${radius}"] [data-part="base"].rounded-${radius}`
        )
        .exists({ count: 1 }, `${radius} track has rounded-${radius}`);
    }
  });

  test('Labels section shows label, value label and description', async function (assert) {
    await visit('/components/status');

    const text = (sel: string): string =>
      document.querySelector(sel)?.textContent?.replace(/\s+/g, ' ').trim() ??
      '';
    assert.true(
      text(
        '#progress-bar-labels [data-case="label"] [data-part="label"]'
      ).includes('50%'),
      'label brings the percentage value label'
    );
    assert.true(
      text(
        '#progress-bar-labels [data-case="custom"] [data-part="label"]'
      ).includes('2 of 4'),
      'custom value label'
    );
    assert.false(
      text(
        '#progress-bar-labels [data-case="hidden"] [data-part="label"]'
      ).includes('%'),
      'value label hidden'
    );
    assert.strictEqual(
      text(
        '#progress-bar-labels [data-case="description"] [data-part="description"]'
      ),
      'Copying 12 of 24 files'
    );
  });
});
