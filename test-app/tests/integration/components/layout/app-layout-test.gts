import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  find,
  click,
  settled,
  triggerKeyEvent,
  waitUntil
} from '@ember/test-helpers';
import { cell } from 'ember-resources';
import { on } from '@ember/modifier';
import { AppLayout, AppLayoutState, Sidebar } from 'frontile';
import { mockMatchMedia } from 'test-app/tests/helpers/match-media';
import { registerCustomStyles, useStyles } from '@frontile/theme';
import { realStyles } from 'test-app/tests/helpers/real-theme-styles';
import type { TOC } from '@ember/component/template-only';
import { useRealStyles } from 'test-app/tests/helpers/scoped-styles';

// The navbar sits inside the card when its box lies within the card's box.
function isWithin(inner: Element, outer: Element): boolean {
  const a = inner.getBoundingClientRect();
  const b = outer.getBoundingClientRect();
  return (
    a.top >= b.top - 0.5 &&
    a.bottom <= b.bottom + 0.5 &&
    a.left >= b.left - 0.5 &&
    a.right <= b.right + 0.5
  );
}

module(
  'Integration | Component | AppLayout | frontile/layout',
  function (hooks) {
    setupRenderingTest(hooks);

    test('renders inset by default', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Navbar>Navbar</layout.Navbar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert
        .dom('[data-component="app-layout"]')
        .hasAttribute('data-variant', 'inset');
      assert
        .dom('[data-component="app-layout"]')
        .hasAttribute('data-navbar-placement', 'frame');
      assert.dom('[data-part="main-card"]').exists('the inset card is drawn');
      assert
        .dom('[data-part="main-card"]')
        .hasAria('hidden', 'true', 'the card is decorative');
    });

    test('attached renders no card', async function (assert) {
      await render(
        <template>
          <AppLayout @variant="attached" as |layout|>
            <layout.Navbar>Navbar</layout.Navbar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert
        .dom('[data-component="app-layout"]')
        .hasAttribute('data-variant', 'attached');
      assert.dom('[data-part="main-card"]').doesNotExist();
    });

    test('navbarPlacement=frame puts the navbar outside the card', async function (assert) {
      await render(
        <template>
          <AppLayout @navbarPlacement="frame" as |layout|>
            <layout.Navbar>Navbar</layout.Navbar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const card = find('[data-part="main-card"]')!;
      const navbar = find('header')!;
      const main = find('main')!;

      assert.false(isWithin(navbar, card), 'navbar lies outside the card');
      assert.true(isWithin(main, card), 'main lies inside the card');
      assert.true(
        navbar.getBoundingClientRect().bottom <=
          card.getBoundingClientRect().top + 0.5,
        'navbar sits above the card'
      );
    });

    test('navbarPlacement=content puts the navbar inside the card', async function (assert) {
      await render(
        <template>
          <AppLayout @navbarPlacement="content" as |layout|>
            <layout.Navbar>Navbar</layout.Navbar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const card = find('[data-part="main-card"]')!;

      assert.true(
        isWithin(find('header')!, card),
        'navbar lies inside the card'
      );
      assert.true(isWithin(find('main')!, card), 'main lies inside the card');
    });

    test('PageHeader renders inside Main in both placements', async function (assert) {
      const placement = cell<'frame' | 'content'>('frame');

      await render(
        <template>
          <AppLayout @navbarPlacement={{placement.current}} as |layout|>
            <layout.Navbar>Navbar</layout.Navbar>
            <layout.Main>
              <layout.PageHeader
                @title="Users"
                @description="Everyone with access."
              >
                <:actions><button type="button">Invite</button></:actions>
              </layout.PageHeader>
            </layout.Main>
          </AppLayout>
        </template>
      );

      for (const value of ['frame', 'content'] as const) {
        placement.current = value;
        await settled();

        const header = find('[data-part="page-header"]')!;
        assert.ok(
          header.closest('main'),
          `${value}: PageHeader is inside main`
        );
        assert.dom('[data-part="page-header-title"]').hasText('Users');
        assert
          .dom('[data-part="page-header-description"]')
          .hasText('Everyone with access.');
        assert
          .dom('[data-part="page-header-actions"] button')
          .hasText('Invite');
      }
    });

    test('landmarks and skip link', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Navbar><button type="button">Menu</button></layout.Navbar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert.dom('header').exists('renders a header landmark');
      assert.dom('main').exists('renders a main landmark');

      const focusable = find('[data-component="app-layout"]')!.querySelector(
        'a[href], button, [tabindex]:not([tabindex="-1"])'
      );
      assert.dom(focusable).hasAttribute('data-part', 'skip-link');
      assert.dom(focusable).hasText('Skip to main content');

      const main = find('main')!;
      assert.dom(focusable).hasAttribute('href', `#${main.id}`);

      await click(focusable!);
      assert.dom(main).isFocused('activating the skip link focuses main');
    });

    test('Enter on the skip link focuses main', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const link = find('[data-part="skip-link"]') as HTMLElement;
      link.focus();
      await triggerKeyEvent(link, 'keydown', 'Enter');
      assert.dom('main').isFocused();
    });

    test('two layouts on one page are independent', async function (assert) {
      await render(
        <template>
          <AppLayout id="one" as |layout|>
            <layout.Sidebar />
            <layout.Navbar><layout.SidebarToggle /></layout.Navbar>
            <layout.Main>One</layout.Main>
          </AppLayout>
          <AppLayout id="two" as |layout|>
            <layout.Sidebar />
            <layout.Navbar><layout.SidebarToggle /></layout.Navbar>
            <layout.Main>Two</layout.Main>
          </AppLayout>
        </template>
      );

      const mainOne = find('#one main')!;
      const mainTwo = find('#two main')!;
      assert.notStrictEqual(mainOne.id, mainTwo.id, 'main ids differ');
      assert.notStrictEqual(
        find('#one nav')!.id,
        find('#two nav')!.id,
        'sidebar ids differ'
      );

      await click('#one [data-part="sidebar-toggle"]');
      assert.dom('#one').hasAttribute('data-sidebar-collapsed', 'true');
      assert.dom('#two').hasAttribute('data-sidebar-collapsed', 'false');
      assert
        .dom('#two [data-part="sidebar-toggle"]')
        .hasAria('expanded', 'true');
    });

    test('@skipLink={{false}} removes the skip link', async function (assert) {
      await render(
        <template>
          <AppLayout @skipLink={{false}} as |layout|>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert.dom('[data-part="skip-link"]').doesNotExist();
    });

    test('scrollMode=page removes the content scroll container', async function (assert) {
      const mode = cell<'content' | 'page'>('content');

      await render(
        <template>
          <AppLayout @scrollMode={{mode.current}} as |layout|>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert
        .dom('main')
        .hasClass('overflow-y-auto', 'content mode scrolls main');

      mode.current = 'page';
      await settled();

      assert.dom('main').doesNotHaveClass('overflow-y-auto');
      assert
        .dom('[data-component="app-layout"]')
        .hasAttribute('data-scroll-mode', 'page');
    });

    test('inset scrollMode=page does not overflow the viewport by the gutter', async function (assert) {
      const media = mockMatchMedia(1200);
      try {
        await render(
          <template>
            <AppLayout @scrollMode="page" as |layout|>
              <layout.Sidebar />
              <layout.Main>Short</layout.Main>
            </AppLayout>
          </template>
        );

        const root = find('[data-component="app-layout"]') as HTMLElement;
        const sidebar = find('[data-part="sidebar"]') as HTMLElement;
        const viewport = window.innerHeight;
        assert.true(
          root.offsetHeight <= viewport + 1,
          `the layout (${root.offsetHeight}px) is no taller than the viewport (${viewport}px)`
        );
        assert.true(
          Math.abs(root.offsetHeight - sidebar.offsetHeight - 24) <= 1,
          'the sticky sidebar fills the frame inside the gutter'
        );
      } finally {
        media.restore();
      }
    });

    test('the skip link sits at the start edge, also right to left', async function (assert) {
      await render(
        <template>
          <div dir="rtl">
            <AppLayout as |layout|>
              <layout.Main>Content</layout.Main>
            </AppLayout>
          </div>
        </template>
      );

      const link = find('[data-part="skip-link"]') as HTMLElement;
      link.focus();
      const root = find(
        '[data-component="app-layout"]'
      )!.getBoundingClientRect();
      const rect = link.getBoundingClientRect();
      assert.true(
        root.right - rect.right < rect.left - root.left,
        'the focused link is nearer the right (start) edge'
      );
    });

    test('uncontrolled: seeds from @defaultAsideOpen and toggles itself', async function (assert) {
      const received: boolean[] = [];
      const onChange = (value: boolean): void => {
        received.push(value);
      };

      await render(
        <template>
          <AppLayout
            @defaultAsideOpen={{true}}
            @onAsideOpenChange={{onChange}}
            as |layout|
          >
            <layout.Main>
              <button
                type="button"
                data-test-toggle
                {{on "click" layout.state.toggleAside}}
              >Toggle</button>
            </layout.Main>
          </AppLayout>
        </template>
      );

      const root = '[data-component="app-layout"]';
      assert.dom(root).hasAttribute('data-aside-open', 'true');

      await click('[data-test-toggle]');
      assert.dom(root).hasAttribute('data-aside-open', 'false');
      assert.deepEqual(received, [false]);
    });

    test('controlled: calls @onAsideOpenChange and waits for the arg', async function (assert) {
      const open = cell(false);
      const received: boolean[] = [];
      const onChange = (value: boolean): void => {
        received.push(value);
      };

      await render(
        <template>
          <AppLayout
            @asideOpen={{open.current}}
            @onAsideOpenChange={{onChange}}
            as |layout|
          >
            <layout.Main>
              <button
                type="button"
                data-test-toggle
                {{on "click" layout.state.toggleAside}}
              >Toggle</button>
            </layout.Main>
          </AppLayout>
        </template>
      );

      const root = '[data-component="app-layout"]';
      assert.dom(root).hasAttribute('data-aside-open', 'false');

      await click('[data-test-toggle]');
      assert.deepEqual(received, [true], 'the change is requested');
      assert
        .dom(root)
        .hasAttribute(
          'data-aside-open',
          'false',
          'the arg has not changed yet'
        );

      open.current = true;
      await settled();
      assert.dom(root).hasAttribute('data-aside-open', 'true');
    });

    test('controlled sidebarCollapsed and mobileSidebarOpen follow their args', async function (assert) {
      const collapsed = cell(true);
      const mobile = cell(false);

      await render(
        <template>
          <AppLayout
            @sidebarCollapsed={{collapsed.current}}
            @mobileSidebarOpen={{mobile.current}}
            as |layout|
          >
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const root = '[data-component="app-layout"]';
      assert.dom(root).hasAttribute('data-sidebar-collapsed', 'true');
      assert.dom(root).hasAttribute('data-mobile-sidebar-open', 'false');

      collapsed.current = false;
      mobile.current = true;
      await settled();

      assert.dom(root).hasAttribute('data-sidebar-collapsed', 'false');
      assert.dom(root).hasAttribute('data-mobile-sidebar-open', 'true');
    });

    test('@state toggled from outside updates the layout', async function (assert) {
      const state = new AppLayoutState();

      await render(
        <template>
          <AppLayout @state={{state}} as |layout|>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const root = '[data-component="app-layout"]';
      assert.dom(root).hasAttribute('data-aside-open', 'false');

      state.toggleAside();
      await settled();
      assert.dom(root).hasAttribute('data-aside-open', 'true');
    });

    test('@state wins over @asideOpen when both are passed', async function (assert) {
      const state = new AppLayoutState({ asideOpen: false });
      const received: boolean[] = [];
      const onChange = (value: boolean): void => {
        received.push(value);
      };

      await render(
        <template>
          <AppLayout
            @state={{state}}
            @asideOpen={{true}}
            @onAsideOpenChange={{onChange}}
            as |layout|
          >
            <layout.Main>
              <button
                type="button"
                data-test-toggle
                {{on "click" layout.state.toggleAside}}
              >Toggle</button>
            </layout.Main>
          </AppLayout>
        </template>
      );

      const root = '[data-component="app-layout"]';
      assert
        .dom(root)
        .hasAttribute('data-aside-open', 'false', 'the arg is ignored');

      await click('[data-test-toggle]');
      assert.true(state.asideOpen, 'the yielded state is the passed object');
      assert.dom(root).hasAttribute('data-aside-open', 'true');
      assert.deepEqual(received, [], 'the arg callback is ignored too');
    });

    test('@classes are merged per slot', async function (assert) {
      await render(
        <template>
          <AppLayout @classes={{hashClasses}} as |layout|>
            <layout.Navbar>Navbar</layout.Navbar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert.dom('[data-component="app-layout"]').hasClass('custom-base');
      assert.dom('header').hasClass('custom-navbar');
      assert.dom('main').hasClass('custom-main');
      assert.dom('[data-part="main-card"]').hasClass('custom-card');
    });

    test('BottomNav renders nothing when mobileNav is drawer', async function (assert) {
      for (const width of [500, 1200]) {
        const media = mockMatchMedia(width);
        try {
          await render(
            <template>
              <AppLayout as |layout|>
                <layout.Sidebar />
                <layout.Main>Content</layout.Main>
                <layout.BottomNav as |bar|>
                  <bar.Item @href="#a">A</bar.Item>
                </layout.BottomNav>
              </AppLayout>
            </template>
          );
          assert
            .dom('[data-part="bottom-nav"]')
            .doesNotExist(`no bar at ${width}px in the default drawer mode`);
        } finally {
          media.restore();
        }
      }
    });
  }
);

const hashClasses = {
  base: 'custom-base',
  navbar: 'custom-navbar',
  main: 'custom-main',
  mainCard: 'custom-card'
};

function readVar(name: string): string {
  const root = find('[data-component="app-layout"]')!;
  return getComputedStyle(root).getPropertyValue(name).trim();
}

// The #ember-testing container is scaled, so `offsetWidth` (layout pixels)
// is compared against the variable resolved through a probe in the root.
function resolveLength(value: string): number {
  const probe = document.createElement('div');
  probe.style.width = value;
  probe.style.height = '0';
  probe.style.position = 'absolute';
  find('[data-component="app-layout"]')!.appendChild(probe);
  const width = probe.offsetWidth;
  probe.remove();
  return width;
}

module(
  'Integration | Component | AppLayout sizing tokens | frontile/layout',
  function (hooks) {
    setupRenderingTest(hooks);

    test('root exposes --app-navbar-height as 3rem', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Navbar>Navbar</layout.Navbar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert.strictEqual(readVar('--app-navbar-height'), '3rem');
    });

    test('--app-sidebar-width follows the collapsed state (16rem then 4rem)', async function (assert) {
      await render(
        <template>
          <AppLayout @variant="attached" as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>Items</sidebar.Body>
            </layout.Sidebar>
            <layout.Main>
              <button
                type="button"
                data-test-toggle
                {{on "click" layout.state.toggleSidebar}}
              >Toggle</button>
            </layout.Main>
          </AppLayout>
        </template>
      );

      assert.strictEqual(readVar('--app-sidebar-width'), '16rem');
      await click('[data-test-toggle]');
      assert.strictEqual(readVar('--app-sidebar-width'), '4rem');
      await click('[data-test-toggle]');
      assert.strictEqual(readVar('--app-sidebar-width'), '16rem');
    });

    test('inset values: 15rem expanded, 3.75rem collapsed', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>Items</sidebar.Body>
            </layout.Sidebar>
            <layout.Main>
              <button
                type="button"
                data-test-toggle
                {{on "click" layout.state.toggleSidebar}}
              >Toggle</button>
            </layout.Main>
          </AppLayout>
        </template>
      );

      assert.strictEqual(readVar('--app-sidebar-width'), '15rem');
      await click('[data-test-toggle]');
      assert.strictEqual(readVar('--app-sidebar-width'), '3.75rem');
    });

    test('--app-sidebar-width reports 5rem for an attached rail', async function (assert) {
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

      assert.strictEqual(readVar('--app-sidebar-width'), '5rem');
    });

    test('--app-sidebar-width reports 5.75rem for an inset rail', async function (assert) {
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

      assert.strictEqual(readVar('--app-sidebar-width'), '5.75rem');
    });

    test('--app-sidebar-width is 0px for an offcanvas sidebar while collapsed', async function (assert) {
      await render(
        <template>
          <AppLayout @defaultSidebarCollapsed={{true}} as |layout|>
            <layout.Sidebar @collapsible="offcanvas" as |sidebar|>
              <sidebar.Body>Items</sidebar.Body>
            </layout.Sidebar>
            <layout.Main>
              <button
                type="button"
                data-test-toggle
                {{on "click" layout.state.toggleSidebar}}
              >Toggle</button>
            </layout.Main>
          </AppLayout>
        </template>
      );

      assert.strictEqual(readVar('--app-sidebar-width'), '0px');
      await click('[data-test-toggle]');
      assert.strictEqual(readVar('--app-sidebar-width'), '15rem');
    });

    test('--app-sidebar-width is 0px with no Sidebar', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert.strictEqual(readVar('--app-sidebar-width'), '0px');
    });

    test('--app-sidebar-width is 0px below the breakpoint', async function (assert) {
      const media = mockMatchMedia(500);
      try {
        await render(
          <template>
            <AppLayout as |layout|>
              <layout.Sidebar as |sidebar|>
                <sidebar.Body>Items</sidebar.Body>
              </layout.Sidebar>
              <layout.Main>Content</layout.Main>
            </AppLayout>
          </template>
        );
        assert.strictEqual(readVar('--app-sidebar-width'), '0px');

        media.setWidth(1200);
        await settled();
        assert.strictEqual(readVar('--app-sidebar-width'), '15rem');
      } finally {
        media.restore();
      }
    });

    test('the variable equals the attached sidebar width, expanded and collapsed', async function (assert) {
      await render(
        <template>
          <AppLayout @variant="attached" as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>Items</sidebar.Body>
            </layout.Sidebar>
            <layout.Main>
              <button
                type="button"
                data-test-toggle
                {{on "click" layout.state.toggleSidebar}}
              >Toggle</button>
            </layout.Main>
          </AppLayout>
        </template>
      );

      const sidebar = find('[data-part="sidebar"]') as HTMLElement;
      assert.strictEqual(
        sidebar.offsetWidth,
        resolveLength(readVar('--app-sidebar-width')),
        'expanded'
      );
      assert.strictEqual(sidebar.offsetWidth, 256);

      await click('[data-test-toggle]');
      // The width transitions; wait for it to finish.
      await waitUntil(() => sidebar.offsetWidth === 64, { timeout: 2000 });
      assert.strictEqual(
        sidebar.offsetWidth,
        resolveLength(readVar('--app-sidebar-width')),
        'collapsed'
      );
    });

    test('the variable equals the inset sidebar width', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>Items</sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const sidebar = find('[data-part="sidebar"]') as HTMLElement;
      assert.strictEqual(
        sidebar.offsetWidth,
        resolveLength(readVar('--app-sidebar-width'))
      );
      assert.strictEqual(sidebar.offsetWidth, 240);
    });

    test('the sidebar width does not transition on first render', async function (assert) {
      const widthTransitions: string[] = [];
      const record = (event: Event): void => {
        const { propertyName, target } = event as TransitionEvent;
        if (
          propertyName === 'width' &&
          (target as HTMLElement).dataset['part'] === 'sidebar'
        ) {
          widthTransitions.push(event.type);
        }
      };
      document.addEventListener('transitionrun', record, true);
      document.addEventListener('transitionstart', record, true);
      try {
        await render(
          <template>
            <AppLayout @variant="attached" as |layout|>
              <layout.Sidebar as |sidebar|>
                <sidebar.Body>Items</sidebar.Body>
              </layout.Sidebar>
              <layout.Main>Content</layout.Main>
              <layout.Aside>Aside</layout.Aside>
            </AppLayout>
          </template>
        );
        const sidebar = find('[data-part="sidebar"]') as HTMLElement;
        // Right after render, before any settling or transition.
        assert.strictEqual(sidebar.offsetWidth, 256, 'drawn at 16rem at once');
        await new Promise((resolve) => setTimeout(resolve, 300));
        assert.deepEqual(widthTransitions, [], 'the width never transitioned');
      } finally {
        document.removeEventListener('transitionrun', record, true);
        document.removeEventListener('transitionstart', record, true);
      }
    });

    test('a standalone Sidebar keeps its width without a layout root', async function (assert) {
      await render(
        <template>
          <div data-test-host>
            <Sidebar as |sidebar|>
              <sidebar.Body>Items</sidebar.Body>
            </Sidebar>
          </div>
          <div data-test-host-collapsed>
            <Sidebar @defaultCollapsed={{true}} as |sidebar|>
              <sidebar.Body>Items</sidebar.Body>
            </Sidebar>
          </div>
        </template>
      );

      const expanded = find(
        '[data-test-host] [data-part="sidebar"]'
      ) as HTMLElement;
      const collapsed = find(
        '[data-test-host-collapsed] [data-part="sidebar"]'
      ) as HTMLElement;
      assert.strictEqual(expanded.offsetWidth, 256, '16rem expanded');
      assert.strictEqual(collapsed.offsetWidth, 64, '4rem collapsed');
    });

    test('the navbar and sidebar header are 3rem tall and aligned', async function (assert) {
      await render(
        <template>
          <AppLayout @variant="attached" as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Header>Brand</sidebar.Header>
              <sidebar.Body>Items</sidebar.Body>
            </layout.Sidebar>
            <layout.Navbar>Navbar</layout.Navbar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const navbar = find('[data-part="navbar"]') as HTMLElement;
      const header = find('[data-part="sidebar-header"]') as HTMLElement;
      assert.strictEqual(navbar.offsetHeight, 48);
      assert.strictEqual(header.offsetHeight, 48);
      assert.strictEqual(
        header.getBoundingClientRect().top,
        navbar.getBoundingClientRect().top,
        'same row'
      );
    });
  }
);

module(
  'Integration | Component | AppLayout alignment | frontile/layout',
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

    for (const placement of ['frame', 'content'] as const) {
      test(`navbar text lines up with the page header's (${placement})`, async function (assert) {
        await render(
          <template>
            <AppLayout @navbarPlacement={{placement}} as |layout|>
              <layout.Navbar><span
                  data-test-navbar-text
                >Crumb</span></layout.Navbar>
              <layout.Main>
                <layout.PageHeader @title="Overview" />
              </layout.Main>
            </AppLayout>
          </template>
        );

        const navbarText = find('[data-test-navbar-text]')!;
        const title = find('[data-part="page-header-title"]')!;
        const left = (el: Element) => el.getBoundingClientRect().left;

        assert.true(
          Math.abs(left(navbarText) - left(title)) <= 1,
          `navbar ${left(navbarText)}, title ${left(title)}`
        );
      });
    }

    // Resolves any CSS color (oklch included) to relative luminance.
    function luminance(color: string): number {
      const canvas = document.createElement('canvas');
      canvas.width = canvas.height = 1;
      const ctx = canvas.getContext('2d')!;
      ctx.fillStyle = color;
      ctx.fillRect(0, 0, 1, 1);
      const [r, g, b] = ctx.getImageData(0, 0, 1, 1).data;
      const lin = (c: number) => {
        const v = c / 255;
        return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4;
      };
      return 0.2126 * lin(r!) + 0.7152 * lin(g!) + 0.0722 * lin(b!);
    }

    for (const scheme of ['light', 'dark'] as const) {
      for (const variant of ['inset', 'attached'] as const) {
        test(`the content is lighter than the frame (${variant}, ${scheme})`, async function (assert) {
          await render(
            <template>
              <div class={{scheme}}>
                <AppLayout
                  @variant={{variant}}
                  @frameGradient={{false}}
                  as |layout|
                >
                  <layout.Sidebar as |sidebar|>
                    <sidebar.Body>Items</sidebar.Body>
                  </layout.Sidebar>
                  <layout.Main>Content</layout.Main>
                </AppLayout>
              </div>
            </template>
          );

          const bg = (selector: string) =>
            getComputedStyle(find(selector)!).backgroundColor;
          const frame =
            variant === 'inset'
              ? bg('[data-component="app-layout"]')
              : bg('[data-part="sidebar"]');
          const content =
            variant === 'inset'
              ? bg('[data-part="main-card"]')
              : bg('[data-component="app-layout"]');

          assert.true(
            luminance(content) > luminance(frame),
            `content ${content} (${luminance(content)}) vs frame ${frame} (${luminance(frame)})`
          );
        });
      }
    }

    test('in frame placement the navbar row is the top gutter', async function (assert) {
      await render(
        <template>
          <AppLayout @navbarPlacement="frame" as |layout|>
            <layout.Navbar>Crumb</layout.Navbar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const root = find('[data-component="app-layout"]')!;
      const scale =
        root.getBoundingClientRect().width / (root as HTMLElement).offsetWidth;
      const top = (selector: string) =>
        (find(selector)!.getBoundingClientRect().top -
          root.getBoundingClientRect().top) /
        scale;
      const navbar = find('[data-part="navbar"]')!.getBoundingClientRect();

      assert.strictEqual(top('[data-part="navbar"]'), 0, 'navbar at the top');
      assert.strictEqual(
        top('[data-part="main-card"]'),
        navbar.height / scale,
        'card right under the navbar row'
      );
    });

    test('with no navbar, or with the navbar in the card, the frame keeps its top gutter', async function (assert) {
      await render(
        <template>
          <div id="no-navbar">
            <AppLayout @navbarPlacement="frame" as |layout|>
              <layout.Main>Content</layout.Main>
            </AppLayout>
          </div>
          <div id="in-card">
            <AppLayout @navbarPlacement="content" as |layout|>
              <layout.Navbar>Crumb</layout.Navbar>
              <layout.Main>Content</layout.Main>
            </AppLayout>
          </div>
        </template>
      );

      for (const id of ['no-navbar', 'in-card']) {
        const root = find(`#${id} [data-component="app-layout"]`)!;
        assert.strictEqual(
          getComputedStyle(root).paddingTop,
          '12px',
          `${id}: 12px top gutter`
        );
      }
    });

    test('the root goes edge to edge below its own @breakpoint', async function (assert) {
      await render(
        <template>
          <AppLayout @breakpoint="lg" as |layout|>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert
        .dom('[data-component="app-layout"]')
        .hasClass('max-lg:p-0')
        .doesNotHaveClass('max-md:p-0');
    });
  }
);

module(
  'Integration | Component | AppLayout frame gradient | frontile/layout',
  function (hooks) {
    setupRenderingTest(hooks);
    useRealStyles(hooks, ['appLayout']);

    test('is flat with a solid card by default', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const root = find('[data-component="app-layout"]')!;
      assert.strictEqual(getComputedStyle(root).backgroundImage, 'none');
      assert
        .dom('[data-part="main-card"]')
        .doesNotHaveClass('bg-surface-app/50');
    });

    for (const color of ['neutral', 'primary'] as const) {
      test(`a ${color} frameGradient paints a gradient and a translucent card`, async function (assert) {
        await render(
          <template>
            <AppLayout @color={{color}} @frameGradient={{true}} as |layout|>
              <layout.Main>Content</layout.Main>
            </AppLayout>
          </template>
        );

        const root = find('[data-component="app-layout"]')!;
        assert.true(
          getComputedStyle(root).backgroundImage.includes('linear-gradient')
        );
        assert.dom('[data-part="main-card"]').hasClass('bg-surface-app/50');
      });
    }

    test('a stop override through @classes wins over the default', async function (assert) {
      const classes = { base: '[--app-frame-gradient-to:rgb(255,0,0)]' };

      await render(
        <template>
          <AppLayout
            @color="primary"
            @frameGradient={{true}}
            @classes={{classes}}
            as |layout|
          >
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const root = find('[data-component="app-layout"]')!;
      assert.true(
        getComputedStyle(root).backgroundImage.includes('255, 0, 0'),
        'the stop override wins'
      );
    });

    test('cardSurface=solid keeps the card opaque on a gradient frame', async function (assert) {
      await render(
        <template>
          <AppLayout
            @color="primary"
            @frameGradient={{true}}
            @cardSurface="solid"
            as |layout|
          >
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert
        .dom('[data-part="main-card"]')
        .doesNotHaveClass('bg-surface-app/50');
    });

    test('cardSurface=translucent makes the card see-through', async function (assert) {
      await render(
        <template>
          <AppLayout @cardSurface="translucent" as |layout|>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert
        .dom('[data-part="main-card"]')
        .hasClass('bg-surface-app/50')
        .doesNotHaveClass('bg-surface-app');
    });
  }
);

const ColorTestIcon: TOC<{ Element: SVGSVGElement }> = <template>
  <svg viewBox="0 0 16 16" width="16" height="16" ...attributes>
    <rect width="16" height="16" />
  </svg>
</template>;

// Resolves a CSS color expression (a `var()` or `color-mix()`) to its computed
// form, inside `scope` so the same light/dark tokens apply.
function resolveColor(expression: string, scope: Element): string {
  const probe = document.createElement('div');
  probe.style.color = expression;
  scope.appendChild(probe);
  const value = getComputedStyle(probe).color;
  probe.remove();
  return value;
}

// The current row's fill on a tinted part: the color at 18% (`navTint`).
function activeTint(color: string, scope: Element): string {
  return resolveColor(`color-mix(in oklab, ${color} 18%, transparent)`, scope);
}

module(
  'Integration | Component | AppLayout color | frontile/layout',
  function (hooks) {
    setupRenderingTest(hooks);
    useRealStyles(hooks, ['appLayout', 'navItem']);

    const activeRow = () =>
      find('[data-part="sidebar"] [aria-current="page"]')!;

    test('the default is neutral: rows keep their neutral fills', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Item @href="#a" @isActive={{true}}>A</sidebar.Item>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const row = activeRow();
      assert.strictEqual(
        getComputedStyle(row).backgroundColor,
        resolveColor('var(--color-neutral-soft)', row)
      );
      assert.strictEqual(
        getComputedStyle(find('[data-part="sidebar"]')!)
          .getPropertyValue('--nav-item-active-bg')
          .trim(),
        '',
        'a neutral sidebar sets no row colors, so the fallbacks apply'
      );
    });

    test('@color tints the sidebar rows', async function (assert) {
      await render(
        <template>
          <AppLayout @color="primary" as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Item @href="#a" @isActive={{true}}>A</sidebar.Item>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const row = activeRow();
      assert.strictEqual(
        getComputedStyle(row).backgroundColor,
        activeTint('var(--color-primary)', row),
        'the current row is filled with the color'
      );
      assert.strictEqual(
        getComputedStyle(row).color,
        resolveColor('var(--color-primary-strong)', row),
        'and labelled in its strong level'
      );
    });

    test("a Sidebar @color overrides the layout's", async function (assert) {
      await render(
        <template>
          <AppLayout @color="primary" as |layout|>
            <layout.Sidebar @color="success" as |sidebar|>
              <sidebar.Item @href="#a" @isActive={{true}}>A</sidebar.Item>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const row = activeRow();
      assert.strictEqual(
        getComputedStyle(row).backgroundColor,
        activeTint('var(--color-success)', row)
      );
    });

    for (const scheme of ['light', 'dark'] as const) {
      for (const variant of ['inset', 'attached'] as const) {
        test(`@navbarSurface=solid fills the navbar (${variant}, ${scheme})`, async function (assert) {
          await render(
            <template>
              <div class={{scheme}}>
                <AppLayout
                  @variant={{variant}}
                  @color="primary"
                  @navbarSurface="solid"
                  as |layout|
                >
                  <layout.Navbar>Title</layout.Navbar>
                  <layout.Main>Content</layout.Main>
                </AppLayout>
              </div>
            </template>
          );

          const navbar = find('[data-part="navbar"]')!;
          assert.strictEqual(
            getComputedStyle(navbar).backgroundColor,
            resolveColor('var(--color-primary)', navbar)
          );
          assert.strictEqual(
            getComputedStyle(navbar).color,
            resolveColor('var(--color-on-primary)', navbar)
          );
        });
      }
    }

    test('a standalone solid Sidebar fills itself and inverts its rows', async function (assert) {
      await render(
        <template>
          <Sidebar @color="danger" @surface="solid" as |sidebar|>
            <sidebar.Item @href="#a" @isActive={{true}}>A</sidebar.Item>
          </Sidebar>
        </template>
      );

      const sidebar = find('[data-part="sidebar"]')!;
      const row = activeRow();
      assert.strictEqual(
        getComputedStyle(sidebar).backgroundColor,
        resolveColor('var(--color-danger)', sidebar)
      );
      assert.strictEqual(
        getComputedStyle(row).color,
        resolveColor('var(--color-on-danger)', row)
      );
    });

    test('a solid sidebar in the drawer falls back to tinted rows', async function (assert) {
      const media = mockMatchMedia(500);
      try {
        await render(
          <template>
            <AppLayout @color="primary" @sidebarSurface="solid" as |layout|>
              <layout.Navbar><layout.MenuToggle /></layout.Navbar>
              <layout.Sidebar as |sidebar|>
                <sidebar.Item @href="#a" @isActive={{true}}>A</sidebar.Item>
              </layout.Sidebar>
              <layout.Main>Content</layout.Main>
            </AppLayout>
          </template>
        );
        await click('[data-part="menu-toggle"]');

        const row = document.querySelector(
          '[data-part="mobile-sidebar"] [aria-current="page"]'
        )!;
        assert.ok(row, 'the drawer is open');
        assert.strictEqual(
          getComputedStyle(row).backgroundColor,
          activeTint('var(--color-primary)', row),
          'the drawer is its own surface, so the rows are tinted, not inverted'
        );
      } finally {
        media.restore();
      }
    });

    test('@frameGradient draws from the layout color', async function (assert) {
      await render(
        <template>
          <AppLayout @color="success" @frameGradient={{true}} as |layout|>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const root = find('[data-component="app-layout"]')!;
      const style = getComputedStyle(root);
      assert.true(style.backgroundImage.includes('linear-gradient'));
      assert.strictEqual(
        style.getPropertyValue('--app-layout-color').trim(),
        style.getPropertyValue('--color-success').trim(),
        'the layout color is the success color'
      );
      assert.true(
        style
          .getPropertyValue('--app-frame-gradient-from')
          .includes(style.getPropertyValue('--color-success').trim()),
        'the first stop is mixed from it'
      );
    });
    test('a color set through @classes on the root reaches the sidebar rows', async function (assert) {
      const classes = { base: '[--app-layout-color:rgb(255,0,0)]' };

      await render(
        <template>
          <AppLayout @color="primary" @classes={{classes}} as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Item @href="#a" @isActive={{true}}>A</sidebar.Item>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const row = activeRow();
      assert.strictEqual(
        getComputedStyle(row).backgroundColor,
        activeTint('rgb(255,0,0)', row)
      );
    });

    test('a solid sidebar draws rows, group labels and its toggle in the contrast color', async function (assert) {
      await render(
        <template>
          <AppLayout @color="primary" @sidebarSurface="solid" as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Header><sidebar.Toggle /></sidebar.Header>
              <sidebar.Group @label="Workspace">
                <sidebar.Item @href="#a" id="rest">A</sidebar.Item>
              </sidebar.Group>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const sidebar = find('[data-part="sidebar"]')!;
      const onColor = resolveColor('var(--color-on-primary)', sidebar);
      assert.strictEqual(
        getComputedStyle(find('#rest')!).color,
        onColor,
        'row'
      );
      assert.strictEqual(
        getComputedStyle(find('[data-part="sidebar-group-label"]')!).color,
        onColor,
        'group label'
      );
      assert.strictEqual(
        getComputedStyle(find('[data-part="sidebar-toggle"]')!).color,
        onColor,
        'toggle'
      );
    });

    // The row's start, from the sidebar's edge.
    const rowInset = () =>
      find('[data-part="sidebar"] a')!.getBoundingClientRect().left -
      find('[data-part="sidebar"]')!.getBoundingClientRect().left;

    test('a plain sidebar on the inset frame runs its rows to its edge', async function (assert) {
      await render(
        <template>
          <AppLayout @color="primary" as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body><sidebar.Item
                  @href="#a"
                >A</sidebar.Item></sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert.strictEqual(rowInset(), 0, 'the frame is the gutter');
    });

    test('a solid sidebar on the inset frame keeps its rows off the edge', async function (assert) {
      await render(
        <template>
          <AppLayout @color="primary" @sidebarSurface="solid" as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body><sidebar.Item
                  @href="#a"
                >A</sidebar.Item></sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert.true(rowInset() > 0, 'the row is inset from the fill');
      assert.notStrictEqual(
        getComputedStyle(find('[data-part="sidebar"]')!).borderTopLeftRadius,
        '0px',
        'rounded'
      );
    });

    test("a row property set through a colored Sidebar's @class wins", async function (assert) {
      await render(
        <template>
          <AppLayout @color="primary" as |layout|>
            <layout.Sidebar
              @class="[--nav-item-active-bg:rgb(0,0,255)]"
              as |sidebar|
            >
              <sidebar.Item @href="#a" @isActive={{true}}>A</sidebar.Item>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert.strictEqual(
        getComputedStyle(activeRow()).backgroundColor,
        'rgb(0, 0, 255)'
      );
    });

    test("a Navbar @color and @surface override the layout's", async function (assert) {
      await render(
        <template>
          <AppLayout @color="primary" as |layout|>
            <layout.Navbar
              @color="warning"
              @surface="solid"
            >Title</layout.Navbar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const navbar = find('[data-part="navbar"]')!;
      assert.strictEqual(
        getComputedStyle(navbar).backgroundColor,
        resolveColor('var(--color-warning)', navbar)
      );
    });

    test('the bottom bar is tinted with the layout color', async function (assert) {
      const media = mockMatchMedia(500);
      try {
        await render(
          <template>
            <AppLayout @color="primary" @mobileNav="bottom" as |layout|>
              <layout.Sidebar />
              <layout.Main>Content</layout.Main>
              <layout.BottomNav as |bar|>
                <bar.Item
                  @href="#a"
                  @icon={{ColorTestIcon}}
                  @isActive={{true}}
                >A</bar.Item>
              </layout.BottomNav>
            </AppLayout>
          </template>
        );

        const item = find('[data-part="bottom-nav"] [aria-current="page"]')!;
        assert.strictEqual(
          getComputedStyle(item).backgroundColor,
          activeTint('var(--color-primary)', item)
        );
      } finally {
        media.restore();
      }
    });

    for (const [side, dir, expected] of [
      ['start', 'ltr', 'to right'],
      ['end', 'ltr', 'to left'],
      ['start', 'rtl', 'to left'],
      ['end', 'rtl', 'to right']
    ] as const) {
      test(`the frame gradient starts behind the sidebar (${side}, ${dir})`, async function (assert) {
        await render(
          <template>
            <div dir={{dir}}>
              <AppLayout
                @color="primary"
                @frameGradient={{true}}
                @sidebarSide={{side}}
                as |layout|
              >
                <layout.Main>Content</layout.Main>
              </AppLayout>
            </div>
          </template>
        );

        assert.true(
          getComputedStyle(
            find('[data-component="app-layout"]')!
          ).backgroundImage.startsWith(`linear-gradient(${expected},`)
        );
      });
    }
  }
);
