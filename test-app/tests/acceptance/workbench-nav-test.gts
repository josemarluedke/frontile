import { module, test } from 'qunit';
import { setupApplicationTest } from 'ember-qunit';
import { visit, currentURL, click } from '@ember/test-helpers';

const GROUPS: [label: string, links: number][] = [
  ['Foundations', 4],
  ['Components', 3],
  ['Demos', 2]
];

const FIXTURES = [
  '/sidebar-demo',
  '/platform-demo',
  '/breadcrumbs-demo',
  '/tab-nav-demo'
];

function rootSidebar(): HTMLElement {
  return document.querySelector<HTMLElement>('[data-part="sidebar"]')!;
}

function hrefsIn(root: Element): string[] {
  return Array.from(root.querySelectorAll<HTMLAnchorElement>('a[href]')).map(
    (a) => a.getAttribute('href') as string
  );
}

module('Acceptance | workbench nav', function (hooks) {
  setupApplicationTest(hooks);

  test('every sidebar entry resolves', async function (assert) {
    await visit('/');

    // Collect once from `/`: fixture pages render their own sidebars.
    const sidebar = rootSidebar();
    assert.ok(sidebar, 'root sidebar renders');
    const hrefs = hrefsIn(sidebar);

    // Home + 4 + 3 + 2 + 4 fixtures (rendered, though the folder is closed).
    assert.strictEqual(hrefs.length, 14, '14 sidebar links');
    for (const old of [
      '/buttons',
      '/core',
      '/forms',
      '/forms-legacy',
      '/changeset-form'
    ]) {
      assert.notOk(hrefs.includes(old), `${old} is not in the sidebar`);
    }

    // Workbench pages must render without console errors or warnings. The
    // demo and fixture pages are not held to that.
    const original = { error: console.error, warn: console.warn };
    const logged: string[] = [];
    try {
      for (const href of hrefs) {
        const strict =
          href.startsWith('/foundations') || href.startsWith('/components');
        const before = logged.length;
        if (strict) {
          console.error = (...args: unknown[]) =>
            logged.push(`error: ${args.map(String).join(' ')}`);
          console.warn = (...args: unknown[]) =>
            logged.push(`warn: ${args.map(String).join(' ')}`);
        }
        await visit(href);
        console.error = original.error;
        console.warn = original.warn;

        assert.strictEqual(currentURL(), href, `${href} resolves`);
        if (strict) {
          assert.dom('h1').exists(`${href} has an h1`);
          assert.deepEqual(
            logged.slice(before),
            [],
            `${href} logs no console errors or warnings`
          );
        } else {
          // Demo and fixture pages may have no h1, so only require content.
          assert.dom('main *').exists(`${href} renders content in main`);
        }
      }
    } finally {
      console.error = original.error;
      console.warn = original.warn;
    }
  });

  test('sidebar groups are unnumbered, in order, with exact link counts', async function (assert) {
    await visit('/');
    const sidebar = rootSidebar();

    const groups = Array.from(
      sidebar.querySelectorAll<HTMLElement>('[data-part="sidebar-group"]')
    );
    const labels = groups.map((g) =>
      g.querySelector('[data-part="sidebar-group-label"]')!.textContent!.trim()
    );
    assert.deepEqual(
      labels,
      GROUPS.map(([label]) => label),
      'group labels in order'
    );
    for (const label of labels) {
      assert.notOk(/^\d+ /.test(label), `"${label}" is not numbered`);
    }
    GROUPS.forEach(([label, count], i) => {
      assert.strictEqual(
        hrefsIn(groups[i]!).length,
        count,
        `${label} has ${count} links`
      );
    });

    // Home is a plain item at the top, outside every group.
    const first = sidebar.querySelector<HTMLAnchorElement>('a[href]')!;
    assert.strictEqual(first.getAttribute('href'), '/', 'Home comes first');
    assert.dom(first).hasText('Home');
    assert.notOk(
      first.closest('[data-part="sidebar-group"]'),
      'Home is not in a group'
    );

    // Fixtures is a folder after the groups, closed on a non-fixture page.
    const folders = sidebar.querySelectorAll('[data-part="nav-folder"]');
    assert.strictEqual(folders.length, 1, 'one folder');
    const folder = folders[0]!;
    assert
      .dom('[data-part="nav-folder-trigger"]', folder)
      .hasText('Fixtures')
      .hasAttribute('aria-expanded', 'false');
    assert.true(
      Boolean(
        groups[groups.length - 1]!.compareDocumentPosition(folder) &
        Node.DOCUMENT_POSITION_FOLLOWING
      ),
      'Fixtures comes after the groups'
    );
    assert.deepEqual(hrefsIn(folder), FIXTURES, 'Fixtures holds the fixtures');
  });

  test('collapsed Fixtures links are reachable by opening the folder', async function (assert) {
    await visit('/');
    const folder = rootSidebar().querySelector('[data-part="nav-folder"]')!;
    const panel = folder.querySelector('[data-part="nav-folder-panel"]')!;
    assert.dom(panel).hasAttribute('inert', '', 'closed panel is inert');

    await click(folder.querySelector('[data-part="nav-folder-trigger"]')!);
    assert
      .dom('[data-part="nav-folder-trigger"]', folder)
      .hasAttribute('aria-expanded', 'true');
    assert.dom(panel).doesNotHaveAttribute('inert', 'open panel is not inert');

    await click(
      panel.querySelector<HTMLAnchorElement>('a[href="/sidebar-demo"]')!
    );
    assert.strictEqual(currentURL(), '/sidebar-demo', 'fixture link followed');
  });

  test('Home links resolve, grouped like the sidebar', async function (assert) {
    await visit('/');

    const home = document.querySelector('[data-home-links]')!;
    const sections = Array.from(
      home.querySelectorAll<HTMLElement>('[data-home-section]')
    );
    assert.deepEqual(
      sections.map((s) => s.querySelector('h3')!.textContent!.trim()),
      ['Foundations', 'Components', 'Demos', 'Fixtures'],
      'Home sections match the sidebar'
    );
    assert.deepEqual(
      sections.map((s) => hrefsIn(s).length),
      [4, 3, 2, 4],
      'Home link count per section'
    );

    const foundations = '[data-home-section="foundations"]';
    assert
      .dom(foundations)
      .includesText(
        'radius, elevation, icon sizes, disabled opacity, breakpoints',
        'Global is described by what it shows'
      )
      .includesText(
        'the raw color ramps from the theme source, theme-independent',
        'Palette is described by what it shows'
      )
      .includesText(
        'the semantic roles at each level, surfaces, overlays & lifts, utility colors',
        'Theme is described by what it shows'
      );

    const hrefs = hrefsIn(home);
    assert.strictEqual(hrefs.length, 13, 'one Home link per page');
    assert.deepEqual(
      hrefs,
      hrefsIn(rootSidebar()).filter((href) => href !== '/'),
      'Home links the same pages as the sidebar, in the same order'
    );

    for (const href of hrefs) {
      await visit(href);
      assert.strictEqual(currentURL(), href, `${href} resolves`);
    }
  });

  test('the removed legacy demo pages no longer resolve', async function (assert) {
    for (const url of ['/forms-legacy', '/changeset-form']) {
      let failed = false;
      try {
        await visit(url);
      } catch (e) {
        failed = /UnrecognizedURLError|unrecognized/i.test(String(e));
      }
      assert.true(failed, `${url} is an unrecognized URL`);
    }
  });
});
