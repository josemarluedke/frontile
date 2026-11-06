import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  find,
  click,
  settled,
  triggerKeyEvent
} from '@ember/test-helpers';
import { tracked } from '@glimmer/tracking';
import { AppLayout, AppLayoutState } from 'frontile';
import { registerCustomStyles, useStyles } from '@frontile/theme';
import { realStyles } from 'test-app/tests/helpers/real-theme-styles';
import {
  mockMatchMedia,
  type MatchMediaMock
} from 'test-app/tests/helpers/match-media';
import type { TOC } from '@ember/component/template-only';

const TestIcon: TOC<{ Element: SVGSVGElement }> = <template>
  <svg data-test-icon viewBox="0 0 16 16" width="16" height="16" ...attributes>
    <rect width="16" height="16" />
  </svg>
</template>;

// Matches the platform check in AppLayout: Cmd on Apple platforms, else Ctrl.
function modKeys(): { metaKey: boolean; ctrlKey: boolean } {
  const nav = navigator as Navigator & {
    userAgentData?: { platform?: string };
  };
  const platform = nav.userAgentData?.platform || nav.platform || '';
  const apple = /mac|iphone|ipad|ipod/i.test(platform);
  return { metaKey: apple, ctrlKey: !apple };
}

async function pressModB(): Promise<void> {
  await triggerKeyEvent(document.body, 'keydown', 'B', modKeys());
}

const MOBILE = 500;
const DESKTOP = 1200;

const ROOT = '[data-component="app-layout"]';
const BAR = 'nav[data-part="bottom-nav"]';
const MORE_TAB = `${BAR} [aria-haspopup="dialog"]`;

// Both rects are in the scaled container, so they compare directly.
function edgesMatch(
  assert: Assert,
  inner: Element,
  outer: Element,
  label: string
): void {
  const a = inner.getBoundingClientRect();
  const b = outer.getBoundingClientRect();
  assert.true(Math.abs(a.left - b.left) < 0.5, `${label}: left edge`);
  assert.true(Math.abs(a.right - b.right) < 0.5, `${label}: right edge`);
  assert.true(Math.abs(a.bottom - b.bottom) < 0.5, `${label}: bottom edge`);
}

class MobileNavHolder {
  @tracked value: 'drawer' | 'bottom' = 'bottom';
}

function readVar(name: string): string {
  return getComputedStyle(find(ROOT)!).getPropertyValue(name).trim();
}

// The #ember-testing container is scaled, so lengths are resolved through a
// probe in the root and compared with `offsetHeight` (layout pixels).
function resolveLength(value: string): number {
  const probe = document.createElement('div');
  probe.style.height = value;
  probe.style.width = '0';
  probe.style.position = 'absolute';
  find(ROOT)!.appendChild(probe);
  const height = probe.offsetHeight;
  probe.remove();
  return height;
}

module(
  'Integration | Component | AppLayout bottom nav | frontile/layout',
  function (hooks) {
    setupRenderingTest(hooks);

    let media: MatchMediaMock | undefined;
    let previous: Partial<ReturnType<typeof useStyles>>;

    // Other test files replace these with class markers; the geometry and
    // position checks here need the shipped classes.
    hooks.beforeEach(function () {
      const current = useStyles();
      previous = {
        navItem: current.navItem,
        bottomNav: current.bottomNav,
        appLayout: current.appLayout,
        drawer: current.drawer,
        overlay: current.overlay,
        backdrop: current.backdrop
      };
      registerCustomStyles({
        navItem: realStyles.navItem,
        bottomNav: realStyles.bottomNav,
        appLayout: realStyles.appLayout,
        drawer: realStyles.drawer,
        overlay: realStyles.overlay,
        backdrop: realStyles.backdrop
      });
    });

    hooks.afterEach(function () {
      media?.restore();
      media = undefined;
      registerCustomStyles(previous);
    });

    test('default mobileNav keeps the drawer and MenuToggle', async function (assert) {
      media = mockMatchMedia(MOBILE);
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Navbar><layout.MenuToggle /></layout.Navbar>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body><a href="#a" id="home">Home</a></sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
            <layout.BottomNav as |bar|>
              <bar.Item @href="#a" @icon={{TestIcon}}>A</bar.Item>
            </layout.BottomNav>
          </AppLayout>
        </template>
      );

      assert.dom('[data-part="menu-toggle"]').exists();
      assert.dom(BAR).doesNotExist('no bar in drawer mode');
      await click('[data-part="menu-toggle"]');
      assert
        .dom('[role="dialog"] nav[data-part="mobile-sidebar"]')
        .exists('the drawer opens as before');
    });

    test('bottom mode below the breakpoint renders the BottomNav and not the sidebar', async function (assert) {
      media = mockMatchMedia(MOBILE);
      const state = new AppLayoutState({ mobileSidebarOpen: true });
      await render(
        <template>
          <AppLayout @mobileNav="bottom" @state={{state}} as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body><a href="#a" id="home">Home</a></sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
            <layout.BottomNav as |bar|>
              <bar.Item @href="#a" @icon={{TestIcon}}>A</bar.Item>
            </layout.BottomNav>
          </AppLayout>
        </template>
      );

      assert.dom(BAR).exists({ count: 1 });
      assert.dom('[data-part="sidebar"]').doesNotExist();
      assert.dom('[data-part="mobile-sidebar"]').doesNotExist();
      assert
        .dom('[role="dialog"]')
        .doesNotExist('an open mobileSidebarOpen is ignored');
      assert.dom('#home').doesNotExist('the sidebar block is not rendered');
    });

    test('bottom mode renders no MenuToggle or SidebarToggle below the breakpoint', async function (assert) {
      media = mockMatchMedia(MOBILE);
      await render(
        <template>
          <AppLayout @mobileNav="bottom" as |layout|>
            <layout.Navbar>
              <layout.MenuToggle />
              <layout.SidebarToggle />
            </layout.Navbar>
            <layout.Sidebar />
            <layout.Main>Content</layout.Main>
            <layout.BottomNav as |bar|>
              <bar.Item @href="#a" @icon={{TestIcon}}>A</bar.Item>
            </layout.BottomNav>
          </AppLayout>
        </template>
      );

      assert.dom('[data-part="menu-toggle"]').doesNotExist();
      assert.dom('[data-part="sidebar-toggle"]').doesNotExist();
    });

    test('bottom mode at desktop width renders the sidebar and no BottomNav', async function (assert) {
      media = mockMatchMedia(DESKTOP);
      await render(
        <template>
          <AppLayout @mobileNav="bottom" as |layout|>
            <layout.Navbar><layout.SidebarToggle /></layout.Navbar>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body><a href="#a" id="home">Home</a></sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
            <layout.BottomNav as |bar|>
              <bar.Item @href="#a" @icon={{TestIcon}}>A</bar.Item>
            </layout.BottomNav>
          </AppLayout>
        </template>
      );

      assert.dom(`${ROOT} > nav[data-part="sidebar"]`).exists();
      assert.dom('[data-part="sidebar-toggle"]').exists();
      assert.dom(BAR).doesNotExist();
    });

    test('viewport switching: resizing from desktop to mobile swaps the sidebar for the bar and back', async function (assert) {
      media = mockMatchMedia(DESKTOP);
      await render(
        <template>
          <AppLayout @mobileNav="bottom" as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>Items</sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
            <layout.BottomNav as |bar|>
              <bar.Item @href="#a" @icon={{TestIcon}}>A</bar.Item>
            </layout.BottomNav>
          </AppLayout>
        </template>
      );

      assert.dom('[data-part="sidebar"]').exists();
      assert.dom(BAR).doesNotExist();

      media.setWidth(MOBILE);
      await settled();
      assert.dom('[data-part="sidebar"]').doesNotExist();
      assert.dom('[data-part="mobile-sidebar"]').doesNotExist();
      assert.dom(BAR).exists();

      media.setWidth(DESKTOP);
      await settled();
      assert.dom('[data-part="sidebar"]').exists();
      assert.dom(BAR).doesNotExist();
    });

    test('resizing wide while the More sheet is open closes it and leaves nothing mounted', async function (assert) {
      media = mockMatchMedia(MOBILE);
      await render(
        <template>
          <AppLayout @mobileNav="bottom" as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>Items</sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
            <layout.BottomNav as |bar|>
              <bar.Item @href="#a" @icon={{TestIcon}}>A</bar.Item>
              <bar.More as |more|>
                <more.Item @href="#b" @icon={{TestIcon}}>B</more.Item>
              </bar.More>
            </layout.BottomNav>
          </AppLayout>
        </template>
      );

      await click(MORE_TAB);
      assert.dom('[role="dialog"]').exists('the sheet is open');

      media.setWidth(DESKTOP);
      await settled();

      assert.dom(BAR).doesNotExist();
      assert.dom('[role="dialog"]').doesNotExist('the sheet closed');
      assert.dom('[data-part="bottom-nav-more-sheet"]').doesNotExist();
      assert.dom('[data-part="bottom-nav-more-registry"]').doesNotExist();
      assert.true(
        document.activeElement === null || document.activeElement.isConnected,
        'focus is not left on a removed element'
      );

      media.setWidth(MOBILE);
      await settled();
      assert.dom(BAR).exists();
      assert
        .dom('[role="dialog"]')
        .doesNotExist('the sheet does not reopen with the bar');
    });

    test('mod+b does nothing below the breakpoint in bottom mode', async function (assert) {
      media = mockMatchMedia(MOBILE);
      const state = new AppLayoutState();
      await render(
        <template>
          <AppLayout @mobileNav="bottom" @state={{state}} as |layout|>
            <layout.Sidebar />
            <layout.Main>Content</layout.Main>
            <layout.BottomNav as |bar|>
              <bar.Item @href="#a" @icon={{TestIcon}}>A</bar.Item>
            </layout.BottomNav>
          </AppLayout>
        </template>
      );

      await pressModB();
      assert.false(state.mobileSidebarOpen);
      assert.false(state.sidebarCollapsed);
      assert.dom('[role="dialog"]').doesNotExist();
    });

    test('mod+b still collapses the sidebar at desktop width in bottom mode', async function (assert) {
      media = mockMatchMedia(DESKTOP);
      const state = new AppLayoutState();
      await render(
        <template>
          <AppLayout @mobileNav="bottom" @state={{state}} as |layout|>
            <layout.Sidebar />
            <layout.Main>Content</layout.Main>
            <layout.BottomNav as |bar|>
              <bar.Item @href="#a" @icon={{TestIcon}}>A</bar.Item>
            </layout.BottomNav>
          </AppLayout>
        </template>
      );

      await pressModB();
      assert.true(state.sidebarCollapsed);
      assert.dom(ROOT).hasAttribute('data-sidebar-collapsed', 'true');
    });

    test('--app-bottomnav-height is 0px with no BottomNav and equals the row height with one', async function (assert) {
      media = mockMatchMedia(MOBILE);
      await render(
        <template>
          <AppLayout @mobileNav="bottom" as |layout|>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );
      assert.strictEqual(readVar('--app-bottomnav-height'), '0px');

      await render(
        <template>
          <AppLayout @mobileNav="bottom" as |layout|>
            <layout.Main>Content</layout.Main>
            <layout.BottomNav as |bar|>
              <bar.Item @href="#a" @icon={{TestIcon}}>A</bar.Item>
            </layout.BottomNav>
          </AppLayout>
        </template>
      );
      const row = resolveLength('3.75rem');
      assert.strictEqual(
        resolveLength('var(--app-bottomnav-height)'),
        row,
        'the token is the row height with a zero inset'
      );
      assert.strictEqual(
        (find(BAR) as HTMLElement).offsetHeight,
        row,
        'the bar is the row height'
      );
    });

    test('--app-bottomnav-height is 0px at desktop width with a BottomNav', async function (assert) {
      media = mockMatchMedia(DESKTOP);
      await render(
        <template>
          <AppLayout @mobileNav="bottom" as |layout|>
            <layout.Main>Content</layout.Main>
            <layout.BottomNav as |bar|>
              <bar.Item @href="#a" @icon={{TestIcon}}>A</bar.Item>
            </layout.BottomNav>
          </AppLayout>
        </template>
      );
      assert.strictEqual(readVar('--app-bottomnav-height'), '0px');
    });

    test('a non-zero safe-area inset grows --app-bottomnav-height and the bar', async function (assert) {
      media = mockMatchMedia(MOBILE);
      await render(
        <template>
          <AppLayout @mobileNav="bottom" as |layout|>
            <layout.Main>Content</layout.Main>
            <layout.BottomNav as |bar|>
              <bar.Item @href="#a" @icon={{TestIcon}}>A</bar.Item>
            </layout.BottomNav>
          </AppLayout>
        </template>
      );
      (find(ROOT) as HTMLElement).style.setProperty(
        '--bottomnav-safe-area',
        '20px'
      );
      const expected = resolveLength('3.75rem') + 20;
      assert.strictEqual(
        resolveLength('var(--app-bottomnav-height)'),
        expected
      );
      assert.strictEqual((find(BAR) as HTMLElement).offsetHeight, expected);
    });

    test('bottom row is below main', async function (assert) {
      media = mockMatchMedia(MOBILE);
      await render(
        <template>
          <AppLayout @mobileNav="bottom" as |layout|>
            <layout.Navbar>Top</layout.Navbar>
            <layout.Main>Content</layout.Main>
            <layout.BottomNav as |bar|>
              <bar.Item @href="#a" @icon={{TestIcon}}>A</bar.Item>
            </layout.BottomNav>
          </AppLayout>
        </template>
      );
      const bar = find(BAR)!.getBoundingClientRect();
      const main = find('main')!.getBoundingClientRect();
      assert.true(bar.top >= main.bottom - 0.5, 'the bar is under main');
      assert.strictEqual(
        getComputedStyle(find(BAR)!).position,
        'static',
        'a grid row in content scroll mode, not fixed'
      );
    });

    test('page scroll mode makes the bar sticky', async function (assert) {
      media = mockMatchMedia(MOBILE);
      await render(
        <template>
          <AppLayout @mobileNav="bottom" @scrollMode="page" as |layout|>
            <layout.Main>Content</layout.Main>
            <layout.BottomNav as |bar|>
              <bar.Item @href="#a" @icon={{TestIcon}}>A</bar.Item>
            </layout.BottomNav>
          </AppLayout>
        </template>
      );
      const style = getComputedStyle(find(BAR)!);
      assert.strictEqual(style.position, 'sticky');
      assert.strictEqual(style.bottom, '0px');
      assert.strictEqual(style.zIndex, '10');
    });

    test('@classes.bottomNav is merged into the bar', async function (assert) {
      media = mockMatchMedia(MOBILE);
      const classes = { bottomNav: 'custom-bottom-nav' };
      await render(
        <template>
          <AppLayout @mobileNav="bottom" @classes={{classes}} as |layout|>
            <layout.Main>Content</layout.Main>
            <layout.BottomNav as |bar|>
              <bar.Item @href="#a" @icon={{TestIcon}}>A</bar.Item>
            </layout.BottomNav>
          </AppLayout>
        </template>
      );
      assert.dom(BAR).hasClass('custom-bottom-nav');
    });

    test('inset variant bottom bar reaches the left, right and bottom edges of the layout root', async function (assert) {
      media = mockMatchMedia(MOBILE);
      await render(
        <template>
          <AppLayout @mobileNav="bottom" as |layout|>
            <layout.Navbar>Top</layout.Navbar>
            <layout.Main>Content</layout.Main>
            <layout.BottomNav as |bar|>
              <bar.Item @href="#a" @icon={{TestIcon}}>A</bar.Item>
            </layout.BottomNav>
          </AppLayout>
        </template>
      );
      assert.dom(ROOT).hasAttribute('data-variant', 'inset');
      edgesMatch(assert, find(BAR)!, find(ROOT)!, 'content scroll mode');
    });

    test('inset variant in page scroll mode: the sticky bar reaches the edges', async function (assert) {
      media = mockMatchMedia(MOBILE);
      await render(
        <template>
          <AppLayout @mobileNav="bottom" @scrollMode="page" as |layout|>
            <layout.Navbar>Top</layout.Navbar>
            <layout.Main>Content</layout.Main>
            <layout.BottomNav as |bar|>
              <bar.Item @href="#a" @icon={{TestIcon}}>A</bar.Item>
            </layout.BottomNav>
          </AppLayout>
        </template>
      );
      const bar = find(BAR)!;
      const root = find(ROOT)!;
      const style = getComputedStyle(bar);
      assert.strictEqual(style.position, 'sticky');
      const barRect = bar.getBoundingClientRect();
      const rootRect = root.getBoundingClientRect();
      assert.true(Math.abs(barRect.left - rootRect.left) < 0.5, 'left edge');
      assert.true(Math.abs(barRect.right - rootRect.right) < 0.5, 'right edge');
      // The bar is stuck to the bottom of the scroll container, which can
      // end above the root, so the bottom edge is checked through the
      // margin that cancels the frame's bottom gutter.
      assert.strictEqual(
        style.marginBottom,
        `-${getComputedStyle(root).paddingBottom}`,
        'the bar pulls over the bottom gutter'
      );
    });

    test('bottom mode closes an open mobile sidebar below the breakpoint', async function (assert) {
      media = mockMatchMedia(MOBILE);
      const state = new AppLayoutState({ mobileSidebarOpen: true });
      const mobileNav = new MobileNavHolder();
      await render(
        <template>
          <AppLayout
            @mobileNav={{mobileNav.value}}
            @state={{state}}
            as |layout|
          >
            <layout.Sidebar />
            <layout.Main>Content</layout.Main>
            <layout.BottomNav as |bar|>
              <bar.Item @href="#a" @icon={{TestIcon}}>A</bar.Item>
            </layout.BottomNav>
          </AppLayout>
        </template>
      );
      assert.false(state.mobileSidebarOpen, 'a seeded open flag is cleared');

      state.mobileSidebarOpen = true;
      await settled();
      assert.false(state.mobileSidebarOpen, 'a later open is cleared too');

      mobileNav.value = 'drawer';
      await settled();
      assert
        .dom('[role="dialog"]')
        .doesNotExist('switching to drawer mode does not open the drawer');
      assert.dom('[data-part="menu-toggle"]').doesNotExist();
    });

    test('the existing Navbar still renders as the phone top bar', async function (assert) {
      media = mockMatchMedia(MOBILE);
      await render(
        <template>
          <AppLayout @mobileNav="bottom" as |layout|>
            <layout.Navbar>Top bar</layout.Navbar>
            <layout.Sidebar />
            <layout.Main>Content</layout.Main>
            <layout.BottomNav as |bar|>
              <bar.Item @href="#a" @icon={{TestIcon}}>A</bar.Item>
            </layout.BottomNav>
          </AppLayout>
        </template>
      );
      assert.dom('[data-part="navbar"]').isVisible();
      assert.dom('[data-part="navbar"]').hasText('Top bar');
    });
  }
);
