import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find, click, settled } from '@ember/test-helpers';
import { cell } from 'ember-resources';
import { AppLayout, AppLayoutState, Sidebar, SidebarToggle } from 'frontile';

function isVisiblyHidden(el: Element): boolean {
  const rect = el.getBoundingClientRect();
  return rect.width <= 1 && rect.height <= 1;
}

module('Integration | Component | Sidebar | frontile/layout', function (hooks) {
  setupRenderingTest(hooks);

  test('is a nav landmark with an accessible name', async function (assert) {
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Sidebar as |sidebar|>
            <sidebar.Body><a href="#a">Home</a></sidebar.Body>
          </layout.Sidebar>
          <layout.Main>Content</layout.Main>
        </AppLayout>
      </template>
    );

    assert.dom('nav[data-part="sidebar"]').hasAria('label', 'Main');
  });

  test('@label sets the nav name', async function (assert) {
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Sidebar @label="Workspace" />
          <layout.Main>Content</layout.Main>
        </AppLayout>
      </template>
    );

    assert.dom('nav[data-part="sidebar"]').hasAria('label', 'Workspace');
  });

  test('yields Header, Body and Footer', async function (assert) {
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Sidebar as |sidebar|>
            <sidebar.Header>H</sidebar.Header>
            <sidebar.Body>B</sidebar.Body>
            <sidebar.Footer>F</sidebar.Footer>
          </layout.Sidebar>
        </AppLayout>
      </template>
    );

    assert.dom('[data-part="sidebar-header"]').hasText('H');
    assert.dom('[data-part="sidebar-body"]').hasText('B');
    assert.dom('[data-part="sidebar-footer"]').hasText('F');
  });

  test('icon rail hides labels visually but keeps them in the accessibility tree', async function (assert) {
    await render(
      <template>
        <AppLayout @defaultSidebarCollapsed={{true}} as |layout|>
          <layout.Sidebar as |sidebar|>
            <sidebar.Body>
              <a href="#a" id="link-a">
                <span data-sidebar-label>Dashboard</span>
              </a>
              <a href="#b" id="link-b">
                <span data-sidebar-label>Reports</span>
              </a>
            </sidebar.Body>
          </layout.Sidebar>
          <layout.Main>Content</layout.Main>
        </AppLayout>
      </template>
    );

    const labels = document.querySelectorAll('[data-sidebar-label]');
    assert.strictEqual(labels.length, 2);
    for (const label of labels) {
      const style = getComputedStyle(label);
      assert.notStrictEqual(style.display, 'none', 'not display:none');
      assert.notStrictEqual(
        style.visibility,
        'hidden',
        'not visibility:hidden'
      );
      assert.true(isVisiblyHidden(label), 'visually hidden');
      assert.strictEqual(style.position, 'absolute', 'sr-only technique');
    }
    assert.dom('#link-a').hasText('Dashboard', 'the text is still in the DOM');
  });

  test('expanded sidebar shows labels', async function (assert) {
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Sidebar as |sidebar|>
            <sidebar.Body>
              <a href="#a"><span data-sidebar-label>Dashboard</span></a>
            </sidebar.Body>
          </layout.Sidebar>
        </AppLayout>
      </template>
    );

    const label = find('[data-sidebar-label]')!;
    assert.false(isVisiblyHidden(label));
    assert.notStrictEqual(getComputedStyle(label).position, 'absolute');
  });

  test('icon collapse narrows the sidebar to a rail', async function (assert) {
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Sidebar as |sidebar|>
            <sidebar.Body>x</sidebar.Body>
          </layout.Sidebar>
          <layout.SidebarToggle />
        </AppLayout>
      </template>
    );

    const sidebar = find('[data-part="sidebar"]')!;
    // The width transition would otherwise be measured mid-flight.
    sidebar.style.transition = 'none';
    const wide = sidebar.getBoundingClientRect().width;
    await click('[data-part="sidebar-toggle"]');
    const rail = sidebar.getBoundingClientRect().width;
    assert.true(wide > 0 && rail > 0, 'still rendered');
    assert.true(rail < wide, `rail ${rail} is narrower than ${wide}`);
  });

  test('offcanvas hides the sidebar when collapsed', async function (assert) {
    await render(
      <template>
        <AppLayout @defaultSidebarCollapsed={{true}} as |layout|>
          <layout.Sidebar @collapsible="offcanvas" as |sidebar|>
            <sidebar.Body>x</sidebar.Body>
          </layout.Sidebar>
          <layout.Main>Content</layout.Main>
        </AppLayout>
      </template>
    );

    assert.strictEqual(
      getComputedStyle(find('[data-part="sidebar"]')!).display,
      'none'
    );
  });

  test('offcanvas shows the sidebar when expanded', async function (assert) {
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Sidebar @collapsible="offcanvas" as |sidebar|>
            <sidebar.Body>x</sidebar.Body>
          </layout.Sidebar>
          <layout.Main>Content</layout.Main>
        </AppLayout>
      </template>
    );

    assert.true(
      find('[data-part="sidebar"]')!.getBoundingClientRect().width > 100
    );
  });

  test('none ignores collapse', async function (assert) {
    await render(
      <template>
        <AppLayout @defaultSidebarCollapsed={{true}} as |layout|>
          <layout.Sidebar @collapsible="none" as |sidebar|>
            <sidebar.Body>
              <a href="#a"><span data-sidebar-label>Dashboard</span></a>
            </sidebar.Body>
          </layout.Sidebar>
        </AppLayout>
      </template>
    );

    const sidebar = find('[data-part="sidebar"]')!;
    assert.true(sidebar.getBoundingClientRect().width > 100, 'full width');
    assert.false(isVisiblyHidden(find('[data-sidebar-label]')!));
  });

  test('SidebarToggle sets aria-expanded to match and points at the sidebar', async function (assert) {
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Sidebar />
          <layout.Navbar><layout.SidebarToggle /></layout.Navbar>
          <layout.Main>Content</layout.Main>
        </AppLayout>
      </template>
    );

    const toggle = find('[data-part="sidebar-toggle"]')!;
    const sidebar = find('[data-part="sidebar"]')!;
    assert.strictEqual(toggle.tagName, 'BUTTON');
    assert.dom(toggle).hasAria('expanded', 'true');
    assert.dom(toggle).hasAria('label', 'Toggle sidebar');
    assert.ok(sidebar.id, 'sidebar has an id');
    assert.dom(toggle).hasAria('controls', sidebar.id);

    await click(toggle);
    assert.dom(toggle).hasAria('expanded', 'false');
    assert
      .dom('[data-component="app-layout"]')
      .hasAttribute('data-sidebar-collapsed', 'true');

    await click(toggle);
    assert.dom(toggle).hasAria('expanded', 'true');
  });

  test('SidebarToggle @label sets its name', async function (assert) {
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Sidebar />
          <layout.SidebarToggle @label="Shrink menu" />
        </AppLayout>
      </template>
    );

    assert.dom('[data-part="sidebar-toggle"]').hasAria('label', 'Shrink menu');
  });

  test('sidebarSide=start puts the sidebar first', async function (assert) {
    await render(
      <template>
        <AppLayout @variant="attached" as |layout|>
          <layout.Main>Content</layout.Main>
          <layout.Sidebar />
        </AppLayout>
      </template>
    );

    const sidebar = find('[data-part="sidebar"]')!.getBoundingClientRect();
    const main = find('main')!.getBoundingClientRect();
    assert.true(sidebar.right <= main.left + 0.5, 'sidebar left of main');
  });

  test('sidebarSide=end flips the order and the border side', async function (assert) {
    const side = cell<'start' | 'end'>('end');

    await render(
      <template>
        <AppLayout
          @variant="attached"
          @sidebarSide={{side.current}}
          as |layout|
        >
          <layout.Sidebar />
          <layout.Navbar>Nav</layout.Navbar>
          <layout.Main>Content</layout.Main>
        </AppLayout>
      </template>
    );

    const sidebarEl = find('[data-part="sidebar"]')!;
    const sidebar = sidebarEl.getBoundingClientRect();
    const main = find('main')!.getBoundingClientRect();
    const root = find('[data-component="app-layout"]')!.getBoundingClientRect();
    assert.true(sidebar.left >= main.right - 0.5, 'sidebar right of main');
    assert.true(Math.abs(sidebar.right - root.right) < 1, 'flush with the end');
    assert.true(
      find('header')!.getBoundingClientRect().right <= sidebar.left + 0.5,
      'navbar stays beside the sidebar'
    );
    const endStyle = getComputedStyle(sidebarEl);
    assert.strictEqual(
      endStyle.borderLeftWidth,
      '1px',
      'border on the inner side'
    );
    assert.strictEqual(endStyle.borderRightWidth, '0px');

    side.current = 'start';
    await settled();
    const startStyle = getComputedStyle(sidebarEl);
    assert.strictEqual(startStyle.borderRightWidth, '1px');
    assert.strictEqual(startStyle.borderLeftWidth, '0px');
  });

  test('inset sidebar keeps a gap before the card', async function (assert) {
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Sidebar />
          <layout.Main>Content</layout.Main>
        </AppLayout>
      </template>
    );

    const sidebar = find('[data-part="sidebar"]')!;
    const card = find('[data-part="main-card"]')!;
    const style = getComputedStyle(sidebar);
    assert.strictEqual(style.paddingRight, '12px');
    assert.true(
      sidebar.getBoundingClientRect().right <=
        card.getBoundingClientRect().left + 0.5,
      'sidebar does not overlap the card'
    );
  });

  test('inset sidebar with sidebarSide=end pads its inner side', async function (assert) {
    await render(
      <template>
        <AppLayout @sidebarSide="end" as |layout|>
          <layout.Sidebar />
          <layout.Main>Content</layout.Main>
        </AppLayout>
      </template>
    );

    const style = getComputedStyle(find('[data-part="sidebar"]')!);
    assert.strictEqual(style.paddingLeft, '12px');
    assert.strictEqual(style.paddingRight, '0px');
  });

  test('standalone Sidebar works with @state', async function (assert) {
    const state = new AppLayoutState();

    await render(
      <template>
        <div data-test-wrap class="flex">
          <Sidebar @state={{state}} @variant="attached" as |sidebar|>
            <sidebar.Body>
              <a href="#a"><span data-sidebar-label>Dashboard</span></a>
            </sidebar.Body>
          </Sidebar>
          <SidebarToggle @state={{state}} />
        </div>
      </template>
    );

    const sidebar = find('[data-part="sidebar"]')!;
    sidebar.style.transition = 'none';
    sidebar.parentElement!.style.height = '300px';
    const wide = sidebar.getBoundingClientRect();
    assert.true(wide.width > 100, 'shows at full width, not hidden');
    assert.true(
      Math.abs(
        wide.height - sidebar.parentElement!.getBoundingClientRect().height
      ) < 1,
      'full height'
    );
    assert.dom('[data-part="sidebar-toggle"]').hasAria('expanded', 'true');

    await click('[data-part="sidebar-toggle"]');
    assert.true(state.sidebarCollapsed);
    assert.true(sidebar.getBoundingClientRect().width < wide.width);
    assert.true(isVisiblyHidden(find('[data-sidebar-label]')!));
  });
});
