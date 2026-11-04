import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  find,
  click,
  settled,
  triggerKeyEvent
} from '@ember/test-helpers';
import { cell } from 'ember-resources';
import { on } from '@ember/modifier';
import { AppLayout, AppLayoutState } from 'frontile';
import { mockMatchMedia } from 'test-app/tests/helpers/match-media';

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
  }
);

const hashClasses = {
  base: 'custom-base',
  navbar: 'custom-navbar',
  main: 'custom-main',
  mainCard: 'custom-card'
};
