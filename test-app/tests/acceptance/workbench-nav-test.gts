import { module, test } from 'qunit';
import { setupApplicationTest } from 'ember-qunit';
import { visit, currentURL } from '@ember/test-helpers';

module('Acceptance | workbench nav', function (hooks) {
  setupApplicationTest(hooks);

  test('every sidebar entry resolves', async function (assert) {
    await visit('/');

    // Collect once from `/`: fixture pages render their own sidebars.
    const sidebar = document.querySelector('[data-part="sidebar"]');
    assert.ok(sidebar, 'root sidebar renders');
    const hrefs = Array.from(
      sidebar!.querySelectorAll<HTMLAnchorElement>('a[href]')
    ).map((a) => a.getAttribute('href') as string);

    assert.ok(hrefs.length === 16, `16 sidebar links (got ${hrefs.length})`);
    for (const old of ['/buttons', '/core', '/forms']) {
      assert.notOk(hrefs.includes(old), `${old} is not in the sidebar`);
    }

    for (const href of hrefs) {
      await visit(href);
      assert.strictEqual(currentURL(), href, `${href} resolves`);
      if (href.startsWith('/foundations') || href.startsWith('/components')) {
        assert.dom('h1').exists(`${href} has an h1`);
      } else {
        assert.dom('main *').exists(`${href} renders content in main`);
      }
    }
  });

  test('sidebar groups are numbered in order', async function (assert) {
    await visit('/');
    const text = document.querySelector('[data-part="sidebar"]')!.textContent!;
    const labels = [
      '0 Overview',
      '1 Global',
      '2 Palette',
      '3 Theme',
      '4 Typography',
      '5 Components',
      '6 Live demos',
      '7 Legacy packages',
      '8 Fixtures'
    ];
    let last = -1;
    for (const label of labels) {
      const at = text.indexOf(label);
      assert.true(at > last, `${label} appears in order`);
      last = at;
    }
  });
});
