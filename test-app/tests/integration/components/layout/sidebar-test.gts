import type { TOC } from '@ember/component/template-only';
import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find, click, settled } from '@ember/test-helpers';
import { cell } from 'ember-resources';
import { AppLayout, AppLayoutState, Sidebar, SidebarToggle } from 'frontile';
import { registerCustomStyles, useStyles } from '@frontile/theme';
import { realStyles } from 'test-app/tests/helpers/real-theme-styles';
import {
  mockMatchMedia,
  type MatchMediaMock
} from 'test-app/tests/helpers/match-media';

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

  test('SidebarToggle reports expanded when the sidebar ignores collapse', async function (assert) {
    await render(
      <template>
        <AppLayout @defaultSidebarCollapsed={{true}} as |layout|>
          <layout.Navbar><layout.SidebarToggle /></layout.Navbar>
          <layout.Sidebar @collapsible="none" />
          <layout.Main>Content</layout.Main>
        </AppLayout>
      </template>
    );

    assert
      .dom('[data-part="sidebar-toggle"]')
      .hasAria('expanded', 'true', 'collapsible=none is never collapsed');
  });

  test('icon rail hides labels in the header and footer too', async function (assert) {
    await render(
      <template>
        <AppLayout @defaultSidebarCollapsed={{true}} as |layout|>
          <layout.Sidebar as |sidebar|>
            <sidebar.Header><span
                data-sidebar-label
              >Acme</span></sidebar.Header>
            <sidebar.Footer><span
                data-sidebar-label
              >Settings</span></sidebar.Footer>
          </layout.Sidebar>
          <layout.Main>Content</layout.Main>
        </AppLayout>
      </template>
    );

    for (const label of document.querySelectorAll('[data-sidebar-label]')) {
      assert.true(isVisiblyHidden(label), `${label.textContent} is hidden`);
    }
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

  test('Toggle in Sidebar.Header collapses and expands the sidebar', async function (assert) {
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Sidebar as |sidebar|>
            <sidebar.Header><sidebar.Toggle /></sidebar.Header>
          </layout.Sidebar>
          <layout.Main>Content</layout.Main>
        </AppLayout>
      </template>
    );

    const sidebar = find('[data-part="sidebar"]')!;
    const toggle = find(
      '[data-part="sidebar-header"] [data-part="sidebar-toggle"]'
    )!;
    assert.ok(toggle, 'toggle renders in the header');
    assert.dom(toggle).hasAria('expanded', 'true');
    assert.dom(toggle).hasAria('controls', sidebar.id);

    await click(toggle);
    assert.dom(sidebar).hasAttribute('data-collapsed', 'true');
    assert.dom(toggle).hasAria('expanded', 'false');

    await click(toggle);
    assert.dom(sidebar).hasAttribute('data-collapsed', 'false');
    assert.dom(toggle).hasAria('expanded', 'true');
  });

  test('Toggle in Sidebar.Footer collapses and expands the sidebar', async function (assert) {
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Sidebar as |sidebar|>
            <sidebar.Footer><sidebar.Toggle /></sidebar.Footer>
          </layout.Sidebar>
          <layout.Main>Content</layout.Main>
        </AppLayout>
      </template>
    );

    const sidebar = find('[data-part="sidebar"]')!;
    const toggle = find(
      '[data-part="sidebar-footer"] [data-part="sidebar-toggle"]'
    )!;
    assert.ok(toggle, 'toggle renders in the footer');

    await click(toggle);
    assert.dom(sidebar).hasAttribute('data-collapsed', 'true');
    assert.dom(toggle).hasAria('expanded', 'false');

    await click(toggle);
    assert.dom(sidebar).hasAttribute('data-collapsed', 'false');
    assert.dom(toggle).hasAria('expanded', 'true');
  });

  test('Toggle stays rendered, focusable and named in the collapsed rail', async function (assert) {
    await render(
      <template>
        <AppLayout @defaultSidebarCollapsed={{true}} as |layout|>
          <layout.Sidebar as |sidebar|>
            <sidebar.Header><sidebar.Toggle /></sidebar.Header>
          </layout.Sidebar>
          <layout.Main>Content</layout.Main>
        </AppLayout>
      </template>
    );

    assert.dom('[data-part="sidebar"]').hasAttribute('data-collapsed', 'true');
    const toggle = find('[data-part="sidebar-toggle"]') as HTMLElement;
    assert.ok(toggle, 'toggle renders in the rail');
    assert.dom(toggle).hasAria('label', 'Toggle sidebar');
    assert.dom(toggle).hasAria('expanded', 'false');
    assert.false(isVisiblyHidden(toggle), 'toggle is visible');
    toggle.focus();
    assert.strictEqual(document.activeElement, toggle, 'toggle takes focus');
  });

  test('Toggle passes attributes and @label through', async function (assert) {
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Sidebar as |sidebar|>
            <sidebar.Header><sidebar.Toggle
                @label="Shrink menu"
                data-test-x
              /></sidebar.Header>
          </layout.Sidebar>
          <layout.Main>Content</layout.Main>
        </AppLayout>
      </template>
    );

    assert.dom('[data-part="sidebar-toggle"]').hasAria('label', 'Shrink menu');
    assert.dom('[data-part="sidebar-toggle"]').hasAttribute('data-test-x');
  });

  test('standalone Sidebar Toggle toggles the passed @state', async function (assert) {
    const state = new AppLayoutState();

    await render(
      <template>
        <Sidebar @state={{state}} as |sidebar|>
          <sidebar.Header><sidebar.Toggle /></sidebar.Header>
        </Sidebar>
      </template>
    );

    const toggle = find('[data-part="sidebar-toggle"]')!;
    assert.dom(toggle).hasAria('expanded', 'true');

    await click(toggle);
    assert.true(state.sidebarCollapsed);
    assert.dom('[data-part="sidebar"]').hasAttribute('data-collapsed', 'true');
    assert.dom(toggle).hasAria('expanded', 'false');

    await click(toggle);
    assert.false(state.sidebarCollapsed);
    assert.dom(toggle).hasAria('expanded', 'true');
  });
});

module(
  'Integration | Component | Sidebar Toggle in the drawer | frontile/layout',
  function (hooks) {
    setupRenderingTest(hooks);

    let media: MatchMediaMock | undefined;

    hooks.afterEach(function () {
      media?.restore();
      media = undefined;
    });

    test('Toggle renders nothing in the phone drawer', async function (assert) {
      media = mockMatchMedia(500);
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Navbar><layout.MenuToggle /></layout.Navbar>
            <layout.Sidebar as |sidebar|>
              <sidebar.Header><span data-test-brand>Acme</span><sidebar.Toggle
                  data-test-toggle
                /></sidebar.Header>
              <sidebar.Body><a href="#a">Home</a></sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      await click('[data-part="menu-toggle"]');
      assert.dom('[data-part="mobile-sidebar"]').exists('the drawer is open');
      assert.dom('[data-test-brand]').exists('the rest of the header renders');
      assert.dom('[data-part="sidebar-toggle"]').doesNotExist();
      assert.dom('[data-test-toggle]').doesNotExist();
    });
  }
);

module(
  'Integration | Component | Sidebar size | frontile/layout',
  function (hooks) {
    setupRenderingTest(hooks);

    let previous: Partial<ReturnType<typeof useStyles>>;

    hooks.beforeEach(function () {
      previous = { appLayout: useStyles().appLayout };
      registerCustomStyles({ appLayout: realStyles.appLayout });
    });

    hooks.afterEach(function () {
      registerCustomStyles(previous);
    });

    // The test container is scaled, so read the computed width (layout px).
    function widthOf(selector = '[data-part="sidebar"]'): number {
      const el = find(selector)!;
      (el as HTMLElement).style.transition = 'none';
      return parseFloat(getComputedStyle(el).width);
    }

    test('@class replaces the theme width, on its own', async function (assert) {
      await render(
        <template>
          <div style="height: 200px">
            <Sidebar @class="w-72" @collapsible="none" as |sidebar|>
              <sidebar.Body>Items</sidebar.Body>
            </Sidebar>
          </div>
        </template>
      );

      assert.strictEqual(widthOf(), 288);
      assert.dom('[data-part="sidebar"]').doesNotHaveClass('w-64');
    });

    test('@class replaces the theme width in an AppLayout', async function (assert) {
      await render(
        <template>
          <AppLayout @variant="attached" as |layout|>
            <layout.Sidebar @class="w-72" @collapsible="none" as |sidebar|>
              <sidebar.Body>Items</sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert.strictEqual(widthOf(), 288);
    });

    test('@class merges with @classes.sidebar from the layout', async function (assert) {
      const classes = { sidebar: 'custom-from-layout' };
      await render(
        <template>
          <AppLayout @classes={{classes}} as |layout|>
            <layout.Sidebar @class="custom-from-sidebar" as |sidebar|>
              <sidebar.Body>Items</sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert
        .dom('[data-part="sidebar"]')
        .hasClass('custom-from-layout')
        .hasClass('custom-from-sidebar');
    });

    test('size="rail" is 80px wide in the attached variant', async function (assert) {
      await render(
        <template>
          <AppLayout @variant="attached" as |layout|>
            <layout.Sidebar @size="rail" @collapsible="none" as |sidebar|>
              <sidebar.Body>Items</sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert.strictEqual(widthOf(), 80);
    });

    test('size="rail" in the inset variant is 92px including the gutter', async function (assert) {
      await render(
        <template>
          <AppLayout @variant="inset" as |layout|>
            <layout.Sidebar @size="rail" @collapsible="none" as |sidebar|>
              <sidebar.Body>Items</sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert.strictEqual(widthOf(), 92);
    });

    test('rail width with collapsible="none" ignores collapse', async function (assert) {
      const state = new AppLayoutState({ sidebarCollapsed: true });
      await render(
        <template>
          <AppLayout @variant="attached" @state={{state}} as |layout|>
            <layout.Sidebar @size="rail" @collapsible="none" as |sidebar|>
              <sidebar.Body>Items</sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert.true(state.sidebarCollapsed, 'the layout is collapsed');
      assert.strictEqual(widthOf(), 80);
    });

    test('default size is unchanged (16rem attached, 15rem inset)', async function (assert) {
      await render(
        <template>
          <AppLayout @variant="attached" as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>Items</sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );
      assert.strictEqual(widthOf(), 256);

      await render(
        <template>
          <AppLayout @variant="inset" as |layout|>
            <layout.Sidebar @size="default" as |sidebar|>
              <sidebar.Body>Items</sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );
      assert.strictEqual(widthOf(), 240);
    });

    test('on its own the sidebar draws no background or border', async function (assert) {
      await render(
        <template>
          <div style="height: 200px">
            <Sidebar as |sidebar|>
              <sidebar.Body>Items</sidebar.Body>
            </Sidebar>
          </div>
        </template>
      );

      const style = getComputedStyle(find('[data-part="sidebar"]')!);
      assert.strictEqual(style.backgroundColor, 'rgba(0, 0, 0, 0)');
      assert.strictEqual(style.borderInlineEndWidth, '0px');
      assert.strictEqual(style.borderInlineStartWidth, '0px');
    });

    test('the attached layout gives its sidebar a ground and a border facing the content', async function (assert) {
      await render(
        <template>
          <AppLayout @variant="attached" as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>Items</sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const style = getComputedStyle(find('[data-part="sidebar"]')!);
      assert.notStrictEqual(style.backgroundColor, 'rgba(0, 0, 0, 0)');
      assert.strictEqual(style.borderInlineEndWidth, '1px');

      await render(
        <template>
          <AppLayout @variant="attached" @sidebarSide="end" as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>Items</sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const endStyle = getComputedStyle(find('[data-part="sidebar"]')!);
      assert.strictEqual(endStyle.borderInlineStartWidth, '1px');
      assert.strictEqual(endStyle.borderInlineEndWidth, '0px');
    });
  }
);

module(
  'Integration | Component | Sidebar rail stacked item | frontile/layout',
  function (hooks) {
    setupRenderingTest(hooks);

    let previous: Partial<ReturnType<typeof useStyles>>;

    hooks.beforeEach(function () {
      previous = {
        appLayout: useStyles().appLayout,
        navItem: useStyles().navItem
      };
      registerCustomStyles({
        appLayout: realStyles.appLayout,
        navItem: realStyles.navItem
      });
    });

    hooks.afterEach(function () {
      registerCustomStyles(previous);
    });

    // The test container is scaled, so compare scroll and client widths
    // (layout px) and positions relative to each other, not sizes.
    function measure() {
      const body = find('[data-part="sidebar-body"]') as HTMLElement;
      const item = find('[data-part="nav-item"]') as HTMLElement;
      const bodyRect = body.getBoundingClientRect();
      const itemRect = item.getBoundingClientRect();
      const scale = bodyRect.width / body.offsetWidth;
      const style = getComputedStyle(body);
      const padStart = parseFloat(style.paddingLeft) * scale;
      const padEnd = parseFloat(style.paddingRight) * scale;
      return {
        overflow: body.scrollWidth - body.clientWidth,
        leftGap: itemRect.left - bodyRect.left - padStart,
        rightGap: bodyRect.right - itemRect.right - padEnd,
        scale
      };
    }

    for (const variant of ['attached', 'inset'] as const) {
      test(`a stacked item fits and is centered in the ${variant} rail`, async function (assert) {
        await render(
          <template>
            <AppLayout @variant={{variant}} as |layout|>
              <layout.Sidebar @size="rail" @collapsible="none" as |sidebar|>
                <sidebar.Body>
                  <sidebar.Item @href="/a" @layout="stacked">Home</sidebar.Item>
                </sidebar.Body>
              </layout.Sidebar>
              <layout.Main>Content</layout.Main>
            </AppLayout>
          </template>
        );

        const { overflow, leftGap, rightGap, scale } = measure();
        assert.true(overflow <= 0, `no horizontal overflow (${overflow})`);
        assert.true(
          Math.abs(leftGap - rightGap) <= 1 * scale,
          `centered: left gap ${leftGap}, right gap ${rightGap}`
        );
      });
    }
  }
);

const TestIcon: TOC<{ Element: SVGSVGElement }> = <template>
  <svg viewBox="0 0 20 20" width="20" height="20" ...attributes>
    <rect width="20" height="20" />
  </svg>
</template>;

module(
  'Integration | Component | Sidebar alignment | frontile/layout',
  function (hooks) {
    setupRenderingTest(hooks);

    let previous: Partial<ReturnType<typeof useStyles>>;

    hooks.beforeEach(function () {
      previous = {
        appLayout: useStyles().appLayout,
        navItem: useStyles().navItem
      };
      registerCustomStyles({
        appLayout: realStyles.appLayout,
        navItem: realStyles.navItem
      });
    });

    hooks.afterEach(function () {
      registerCustomStyles(previous);
    });

    // The test container is scaled, so work in layout px: divide every
    // measured distance by the sidebar's own scale.
    function geometry() {
      const sidebar = find('[data-part="sidebar"]') as HTMLElement;
      const rect = sidebar.getBoundingClientRect();
      const scale = rect.width / sidebar.offsetWidth;
      const x = (el: Element, inset = 0) =>
        (el.getBoundingClientRect().left - rect.left) / scale + inset;
      return { sidebar, scale, x };
    }

    // The sidebar's width transitions when it collapses; wait for it to stop.
    async function widthSettled() {
      const sidebar = find('[data-part="sidebar"]') as HTMLElement;
      let last = -1;
      for (let i = 0; i < 40 && sidebar.offsetWidth !== last; i++) {
        last = sidebar.offsetWidth;
        await new Promise((resolve) => setTimeout(resolve, 100));
      }
    }

    for (const variant of ['attached', 'inset'] as const) {
      test(`the ${variant} header, items, group labels and footer share one content line`, async function (assert) {
        await render(
          <template>
            <AppLayout @variant={{variant}} as |layout|>
              <layout.Sidebar as |sidebar|>
                <sidebar.Header>
                  <TestIcon data-test-brand />
                  <sidebar.Toggle class="ml-auto" />
                </sidebar.Header>
                <sidebar.Body>
                  <sidebar.Group @label="Projects">
                    <sidebar.Item
                      @href="#a"
                      @icon={{TestIcon}}
                    >Alpha</sidebar.Item>
                  </sidebar.Group>
                </sidebar.Body>
                <sidebar.Footer><sidebar.Toggle
                    data-test-footer-toggle
                  /></sidebar.Footer>
              </layout.Sidebar>
              <layout.Main>Content</layout.Main>
            </AppLayout>
          </template>
        );

        const { x } = geometry();
        const icon = x(find('[data-part="nav-item-icon"]')!);
        const brand = x(find('[data-test-brand]')!);
        // The toggle's 20px icon sits 8px inside its 36px button.
        const footerToggle = x(find('[data-test-footer-toggle]')!, 8);
        const group = find('[data-part="sidebar-group-label"]') as HTMLElement;
        const groupText =
          x(group) + parseFloat(getComputedStyle(group).paddingLeft);

        assert.true(
          Math.abs(brand - icon) <= 1,
          `brand ${brand}, icon ${icon}`
        );
        assert.true(
          Math.abs(footerToggle - icon) <= 1,
          `footer toggle ${footerToggle}, icon ${icon}`
        );
        assert.true(
          Math.abs(groupText - icon) <= 1,
          `group label ${groupText}, icon ${icon}`
        );
      });

      test(`${variant} rows inset their trailing chevron like their icon, and the header toggle lines up with it`, async function (assert) {
        await render(
          <template>
            <AppLayout @variant={{variant}} as |layout|>
              <layout.Sidebar as |sidebar|>
                <sidebar.Header>
                  <TestIcon data-test-brand />
                  <sidebar.Toggle class="ml-auto" />
                </sidebar.Header>
                <sidebar.Body>
                  <sidebar.Folder
                    @label="Alpha"
                    @icon={{TestIcon}}
                    as |folder|
                  >
                    <folder.Item @href="#a">One</folder.Item>
                  </sidebar.Folder>
                </sidebar.Body>
              </layout.Sidebar>
              <layout.Main>Content</layout.Main>
            </AppLayout>
          </template>
        );

        const { x, scale } = geometry();
        const width = (el: Element) => el.getBoundingClientRect().width / scale;
        const row = find('[data-part="nav-folder-trigger"]')!;
        const icon = find('[data-part="nav-item-icon"]')!;
        const chevron = find('[data-part="nav-folder-chevron"]')!;
        const toggleIcon = find('[data-part="sidebar-toggle"] svg')!;

        const leading = x(icon) - x(row);
        const rowEnd = x(row) + width(row);
        const trailing = rowEnd - (x(chevron) + width(chevron));
        const toggleEnd = x(toggleIcon) + width(toggleIcon);
        const brand = x(find('[data-test-brand]')!);

        assert.true(
          Math.abs(leading - trailing) <= 1,
          `icon inset ${leading}, chevron inset ${trailing}`
        );
        assert.true(
          Math.abs(toggleEnd - (rowEnd - trailing)) <= 1,
          `toggle icon ends at ${toggleEnd}, chevron at ${rowEnd - trailing}`
        );
        assert.true(
          Math.abs(brand - x(icon)) <= 1,
          `brand ${brand}, icon ${x(icon)}`
        );
      });

      test(`${variant} rows are 4px apart in the body and in a group`, async function (assert) {
        await render(
          <template>
            <AppLayout @variant={{variant}} as |layout|>
              <layout.Sidebar as |sidebar|>
                <sidebar.Body>
                  <sidebar.Item @href="#a">A</sidebar.Item>
                  <sidebar.Item @href="#b">B</sidebar.Item>
                  <sidebar.Group @label="More">
                    <sidebar.Item @href="#c">C</sidebar.Item>
                    <sidebar.Item @href="#d">D</sidebar.Item>
                  </sidebar.Group>
                </sidebar.Body>
              </layout.Sidebar>
              <layout.Main>Content</layout.Main>
            </AppLayout>
          </template>
        );

        const { scale } = geometry();
        const rows = [
          ...document.querySelectorAll('[data-part="nav-item"]')
        ].map((el) => el.getBoundingClientRect());
        const gap = (a: number, b: number) =>
          (rows[b]!.top - rows[a]!.bottom) / scale;

        assert.true(Math.abs(gap(0, 1) - 4) <= 0.5, `body gap ${gap(0, 1)}`);
        assert.true(Math.abs(gap(2, 3) - 4) <= 0.5, `group gap ${gap(2, 3)}`);
      });

      test(`the ${variant} collapsed rail keeps the icon and centers the header toggle`, async function (assert) {
        await render(
          <template>
            <AppLayout @variant={{variant}} as |layout|>
              <layout.Sidebar as |sidebar|>
                <sidebar.Header>
                  <sidebar.Toggle class="ml-auto" />
                </sidebar.Header>
                <sidebar.Body>
                  <sidebar.Item @href="#a" @icon={{TestIcon}}>A</sidebar.Item>
                </sidebar.Body>
              </layout.Sidebar>
              <layout.Main>Content</layout.Main>
            </AppLayout>
          </template>
        );

        const before = x2();
        await click('[data-part="sidebar-toggle"]');
        await widthSettled();
        const after = x2();

        assert.true(
          Math.abs(after.icon - before.icon) <= 1,
          `icon stays put: ${before.icon} -> ${after.icon}`
        );
        assert.true(
          Math.abs(after.toggleCenter - (after.icon + 10)) <= 1,
          `toggle centered on the icon: ${after.toggleCenter} vs ${after.icon + 10}`
        );

        function x2() {
          const { x } = geometry();
          const icon = x(find('[data-part="nav-item-icon"]')!);
          const toggle = find('[data-part="sidebar-toggle"]') as HTMLElement;
          const { scale } = geometry();
          return {
            icon,
            toggleCenter:
              x(toggle) + toggle.getBoundingClientRect().width / scale / 2
          };
        }
      });
    }

    for (const variant of ['attached', 'inset'] as const) {
      test(`the ${variant} header keeps its brand in place and stacks the toggle below it`, async function (assert) {
        await render(
          <template>
            <AppLayout @variant={{variant}} as |layout|>
              <layout.Sidebar as |sidebar|>
                <sidebar.Header>
                  <TestIcon data-test-brand />
                  <sidebar.Toggle class="ml-auto" />
                </sidebar.Header>
                <sidebar.Body>
                  <sidebar.Item @href="#a">A</sidebar.Item>
                </sidebar.Body>
              </layout.Sidebar>
              <layout.Main>Content</layout.Main>
            </AppLayout>
          </template>
        );

        const spot = () => {
          const { sidebar, scale } = geometry();
          const header = find('[data-part="sidebar-header"]') as HTMLElement;
          const hRect = header.getBoundingClientRect();
          const brand = (
            find('[data-test-brand]') as Element
          ).getBoundingClientRect();
          const toggle = (
            find('[data-part="sidebar-toggle"]') as Element
          ).getBoundingClientRect();
          const sRect = sidebar.getBoundingClientRect();
          return {
            height: hRect.height / scale,
            brandX: (brand.left - sRect.left) / scale,
            brandY: (brand.top - hRect.top) / scale,
            toggleBelow: (toggle.top - brand.bottom) / scale
          };
        };

        const open = spot();
        await click('[data-part="sidebar-toggle"]');
        await widthSettled();
        await new Promise((resolve) => setTimeout(resolve, 100));
        const rail = spot();

        assert.true(
          Math.abs(open.height - 48) <= 1,
          `row height ${open.height}`
        );
        assert.true(
          Math.abs(rail.height - 88) <= 1,
          `stacked height ${rail.height}`
        );
        assert.true(
          Math.abs(rail.brandX - open.brandX) <= 1,
          `brand x ${open.brandX} -> ${rail.brandX}`
        );
        assert.true(
          Math.abs(rail.brandY - open.brandY) <= 1,
          `brand y ${open.brandY} -> ${rail.brandY}`
        );
        assert.true(
          rail.toggleBelow >= 0,
          `toggle is below the brand (${rail.toggleBelow})`
        );
      });
    }

    test('a header that is only a Toggle stays one row when collapsed', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Header><sidebar.Toggle /></sidebar.Header>
              <sidebar.Body>
                <sidebar.Item @href="#a">A</sidebar.Item>
              </sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      await click('[data-part="sidebar-toggle"]');
      await widthSettled();
      await new Promise((resolve) => setTimeout(resolve, 100));

      const { scale } = geometry();
      const header = find('[data-part="sidebar-header"]') as HTMLElement;
      assert.true(
        Math.abs(header.getBoundingClientRect().height / scale - 48) <= 1,
        'the header is still the navbar height'
      );
    });

    test('inset rows start at the sidebar edge: the frame padding is the gutter', async function (assert) {
      await render(
        <template>
          <AppLayout @variant="inset" as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body><sidebar.Item
                  @href="#a"
                >A</sidebar.Item></sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const { x } = geometry();
      assert.true(Math.abs(x(find('[data-part="nav-item"]')!)) <= 1);
    });

    test('with no header or footer, the body insets its first and last rows like their sides', async function (assert) {
      await render(
        <template>
          <AppLayout @variant="attached" as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>
                <sidebar.Item @href="#a" data-test-first>A</sidebar.Item>
                <sidebar.Item @href="#b" data-test-last>B</sidebar.Item>
              </sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const { sidebar, scale, x } = geometry();
      const rect = sidebar.getBoundingClientRect();
      const first = find('[data-test-first]')!.getBoundingClientRect();
      const last = find('[data-test-last]')!.getBoundingClientRect();
      const side = x(find('[data-test-first]')!);
      const top = (first.top - rect.top) / scale;
      const bottom = (rect.bottom - last.bottom) / scale;

      assert.true(side > 0, `side inset ${side}`);
      assert.true(Math.abs(top - side) <= 1, `top ${top}, side ${side}`);
      // The body fills the sidebar, so the last row is far from the bottom;
      // its own bottom padding is what keeps a full body off the edge.
      const body = find('[data-part="sidebar-body"]')!;
      assert.strictEqual(
        getComputedStyle(body).paddingBottom,
        `${side}px`,
        `bottom padding, row ${bottom}px from the bottom`
      );
    });
  }
);
