import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  find,
  click,
  settled,
  triggerEvent,
  triggerKeyEvent
} from '@ember/test-helpers';
import { AppLayout, MenuToggle, AppLayoutState } from 'frontile';
import { registerCustomStyles, useStyles } from '@frontile/theme';
import { realStyles } from 'test-app/tests/helpers/real-theme-styles';
import {
  mockMatchMedia,
  removeMatchMedia,
  type MatchMediaMock
} from 'test-app/tests/helpers/match-media';

// Matches the platform check in AppLayout: Cmd on Apple platforms, else Ctrl.
function modKeys(): { metaKey: boolean; ctrlKey: boolean } {
  const nav = navigator as Navigator & {
    userAgentData?: { platform?: string };
  };
  const platform = nav.userAgentData?.platform || nav.platform || '';
  const apple = /mac|iphone|ipad|ipod/i.test(platform);
  return { metaKey: apple, ctrlKey: !apple };
}

async function pressModB(target: Element | Document | string): Promise<void> {
  await triggerKeyEvent(target, 'keydown', 'B', modKeys());
}

// The theme classes differ between the real theme and test-app's registered
// styles (`left-2` vs `drawer--left`); both name the placement.
function isPlaced(dialog: Element, side: 'left' | 'right'): boolean {
  const other = side === 'left' ? 'right' : 'left';
  const names = [...dialog.classList];
  return (
    names.some((name) => name.includes(side)) &&
    !names.some((name) => name.includes(other))
  );
}

const MOBILE = 500;
const DESKTOP = 1200;

// matchMedia is mocked but CSS still answers to the real (wide) test
// viewport, where `md:hidden` hides MenuToggle and a hidden button cannot
// take focus. The focus tests keep it displayed.
const shownToggle = { menuToggle: 'md:inline-flex' };

module(
  'Integration | Component | AppLayout mobile sidebar | frontile/layout',
  function (hooks) {
    setupRenderingTest(hooks);

    let media: MatchMediaMock | undefined;

    hooks.afterEach(function () {
      media?.restore();
      media = undefined;
    });

    test('MenuToggle opens a left Drawer below the breakpoint', async function (assert) {
      media = mockMatchMedia(MOBILE);
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Navbar><layout.MenuToggle /></layout.Navbar>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body><a href="#a" id="home">Home</a></sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const toggle = find('[data-part="menu-toggle"]')!;
      assert.strictEqual(toggle.tagName, 'BUTTON');
      assert.dom(toggle).hasAria('label', 'Open menu');
      assert.dom(toggle).hasAria('expanded', 'false');
      assert.dom('[role="dialog"]').doesNotExist('closed until opened');
      assert
        .dom('[data-component="app-layout"] > nav[data-part="sidebar"]')
        .doesNotExist('the sidebar is not rendered inline on mobile');

      await click(toggle);

      assert.dom(toggle).hasAria('expanded', 'true');
      assert
        .dom('[data-component="app-layout"]')
        .hasAttribute('data-mobile-sidebar-open', 'true');
      const dialog = find('[role="dialog"]')!;
      assert.ok(dialog, 'the drawer is open');
      assert.dom(dialog).hasAria('label', 'Main');
      assert.true(isPlaced(dialog, 'left'), 'slides from the left');
      assert
        .dom(dialog.querySelector('nav[data-part="mobile-sidebar"]'))
        .exists('the drawer holds the sidebar nav');
      assert.dom(dialog.querySelector('#home')).hasText('Home');
      assert.strictEqual(
        document.querySelectorAll('#home').length,
        1,
        'the sidebar content is rendered once'
      );
      const nav = dialog.querySelector('nav')!;
      assert.dom(toggle).hasAria('controls', nav.id);
    });

    test('right Drawer when sidebarSide=end', async function (assert) {
      media = mockMatchMedia(MOBILE);
      await render(
        <template>
          <AppLayout
            @sidebarSide="end"
            @defaultMobileSidebarOpen={{true}}
            as |layout|
          >
            <layout.Sidebar />
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert.true(isPlaced(find('[role="dialog"]')!, 'right'));
    });

    test('Drawer does not mount above the breakpoint', async function (assert) {
      media = mockMatchMedia(DESKTOP);
      await render(
        <template>
          <AppLayout @defaultMobileSidebarOpen={{true}} as |layout|>
            <layout.Navbar><layout.MenuToggle /></layout.Navbar>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body><a href="#a" id="home">Home</a></sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert.dom('[role="dialog"]').doesNotExist();
      assert
        .dom('[data-component="app-layout"] > nav[data-part="sidebar"]')
        .exists('the sidebar renders inline');
      assert.dom('#home').exists();
    });

    test('growing past the breakpoint closes the drawer', async function (assert) {
      media = mockMatchMedia(MOBILE);
      const changes: boolean[] = [];
      const onChange = (value: boolean) => changes.push(value);
      await render(
        <template>
          <AppLayout @onMobileSidebarOpenChange={{onChange}} as |layout|>
            <layout.Navbar><layout.MenuToggle /></layout.Navbar>
            <layout.Sidebar />
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      await click('[data-part="menu-toggle"]');
      assert.dom('[role="dialog"]').exists();

      media.setWidth(DESKTOP);
      await settled();

      assert.dom('[role="dialog"]').doesNotExist();
      assert
        .dom('[data-component="app-layout"]')
        .hasAttribute('data-mobile-sidebar-open', 'false');
      assert.deepEqual(changes, [true, false]);
      assert
        .dom('[data-component="app-layout"] > nav[data-part="sidebar"]')
        .exists('the inline sidebar is back');

      media.setWidth(MOBILE);
      await settled();
      assert.dom('[role="dialog"]').doesNotExist('stays closed when shrinking');
    });

    test('closing returns focus to MenuToggle', async function (assert) {
      media = mockMatchMedia(MOBILE);
      await render(
        <template>
          <AppLayout @classes={{shownToggle}} as |layout|>
            <layout.Navbar><layout.MenuToggle /></layout.Navbar>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body><a href="#a">Home</a></sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      await click('[data-part="menu-toggle"]');
      await click('[role="dialog"] [data-part="close-button"]');

      assert.dom('[role="dialog"]').doesNotExist();
      assert.dom('[data-part="menu-toggle"]').isFocused();
    });

    test('closing returns focus to MenuToggle when opened by the shortcut', async function (assert) {
      media = mockMatchMedia(MOBILE);
      await render(
        <template>
          <AppLayout @classes={{shownToggle}} as |layout|>
            <layout.Navbar><layout.MenuToggle /></layout.Navbar>
            <layout.Sidebar />
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      await pressModB(document.body);
      assert.dom('[role="dialog"]').exists();
      await triggerKeyEvent('[role="dialog"]', 'keydown', 'Escape');

      assert.dom('[role="dialog"]').doesNotExist();
      assert.dom('[data-part="menu-toggle"]').isFocused();
    });

    test('closing returns focus to the element that had focus when the shortcut opened it', async function (assert) {
      media = mockMatchMedia(MOBILE);
      await render(
        <template>
          <AppLayout @classes={{shownToggle}} as |layout|>
            <layout.Navbar>
              <layout.MenuToggle />
              <button type="button" id="inside">Inside</button>
            </layout.Navbar>
            <layout.Sidebar />
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const inside = find('#inside') as HTMLElement;
      inside.focus();
      await pressModB(inside);
      assert.dom('[role="dialog"]').exists();
      await triggerKeyEvent('[role="dialog"]', 'keydown', 'Escape');

      assert.dom('[role="dialog"]').doesNotExist();
      assert.dom('#inside').isFocused();
    });

    test('Esc closes', async function (assert) {
      media = mockMatchMedia(MOBILE);
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Navbar><layout.MenuToggle /></layout.Navbar>
            <layout.Sidebar />
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      await click('[data-part="menu-toggle"]');
      await triggerKeyEvent('[role="dialog"]', 'keydown', 'Escape');

      assert.dom('[role="dialog"]').doesNotExist();
      assert.dom('[data-part="menu-toggle"]').hasAria('expanded', 'false');
    });

    test('mod+b toggles the sidebar', async function (assert) {
      media = mockMatchMedia(DESKTOP);
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Navbar>
              <layout.MenuToggle />
              <button type="button" id="inside">Inside</button>
            </layout.Navbar>
            <layout.Sidebar />
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const root = '[data-component="app-layout"]';
      await pressModB('#inside');
      assert.dom(root).hasAttribute('data-sidebar-collapsed', 'true');
      await pressModB(document.body);
      assert
        .dom(root)
        .hasAttribute('data-sidebar-collapsed', 'false', 'from body too');

      await triggerKeyEvent('#inside', 'keydown', 'B');
      assert
        .dom(root)
        .hasAttribute(
          'data-sidebar-collapsed',
          'false',
          'b alone does nothing'
        );

      media.setWidth(MOBILE);
      await settled();
      await pressModB('#inside');
      assert.dom(root).hasAttribute('data-mobile-sidebar-open', 'true');
      assert
        .dom(root)
        .hasAttribute('data-sidebar-collapsed', 'false', 'collapse untouched');
      assert.dom('[role="dialog"]').exists('below the breakpoint it opens');

      await pressModB('[role="dialog"]');
      assert
        .dom(root)
        .hasAttribute('data-mobile-sidebar-open', 'false', 'and closes');
    });

    test('mod+b is ignored when toggleShortcut=false', async function (assert) {
      media = mockMatchMedia(DESKTOP);
      await render(
        <template>
          <AppLayout @toggleShortcut={{false}} as |layout|>
            <layout.Navbar>
              <button type="button" id="inside">Inside</button>
            </layout.Navbar>
            <layout.Sidebar />
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      await pressModB('#inside');
      assert
        .dom('[data-component="app-layout"]')
        .hasAttribute('data-sidebar-collapsed', 'false');
    });

    test('mod+b inside one layout does not toggle a second layout', async function (assert) {
      media = mockMatchMedia(DESKTOP);
      await render(
        <template>
          <AppLayout id="one" as |layout|>
            <layout.Navbar>
              <button type="button" id="in-one">One</button>
            </layout.Navbar>
            <layout.Sidebar />
            <layout.Main>One</layout.Main>
          </AppLayout>
          <AppLayout id="two" as |layout|>
            <layout.Sidebar />
            <layout.Main>Two</layout.Main>
          </AppLayout>
        </template>
      );

      await pressModB('#in-one');
      assert.dom('#one').hasAttribute('data-sidebar-collapsed', 'true');
      assert.dom('#two').hasAttribute('data-sidebar-collapsed', 'false');
    });

    test('no matchMedia: renders desktop and does not throw', async function (assert) {
      const restore = removeMatchMedia();
      try {
        await render(
          <template>
            <AppLayout @defaultMobileSidebarOpen={{true}} as |layout|>
              <layout.Navbar><layout.MenuToggle /></layout.Navbar>
              <layout.Sidebar />
              <layout.Main>Content</layout.Main>
            </AppLayout>
          </template>
        );

        assert
          .dom('[data-component="app-layout"] > nav[data-part="sidebar"]')
          .exists();
        assert.dom('[role="dialog"]').doesNotExist();
      } finally {
        restore();
      }
    });

    test('below the breakpoint SidebarToggle opens the drawer', async function (assert) {
      media = mockMatchMedia(MOBILE);
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Navbar><layout.SidebarToggle /></layout.Navbar>
            <layout.Sidebar />
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const root = '[data-component="app-layout"]';
      const toggle = '[data-part="sidebar-toggle"]';
      assert.dom(toggle).hasAria('expanded', 'false', 'reports the drawer');
      await click(toggle);

      assert.dom('[role="dialog"]').exists('the drawer opens');
      assert.dom(root).hasAttribute('data-mobile-sidebar-open', 'true');
      assert
        .dom(root)
        .hasAttribute('data-sidebar-collapsed', 'false', 'collapse untouched');
      assert.dom(toggle).hasAria('expanded', 'true');
      assert
        .dom(toggle)
        .hasAria('controls', find('[role="dialog"] nav')!.id, 'the drawer nav');

      await triggerKeyEvent('[role="dialog"]', 'keydown', 'Escape');
      assert.dom(toggle).hasAria('expanded', 'false');

      media.setWidth(DESKTOP);
      await settled();
      await click(toggle);
      assert
        .dom(root)
        .hasAttribute('data-sidebar-collapsed', 'true', 'collapses when wide');
      assert.dom('[role="dialog"]').doesNotExist();
    });

    test('activating an Item in the drawer closes it; a disabled one does not', async function (assert) {
      media = mockMatchMedia(MOBILE);
      await render(
        <template>
          <AppLayout @defaultMobileSidebarOpen={{true}} as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>
                <sidebar.Item @href="#item-a" id="item-a">A</sidebar.Item>
                <sidebar.Item @href="#item-b" @isDisabled={{true}} id="item-b">
                  B
                </sidebar.Item>
              </sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const root = '[data-component="app-layout"]';
      assert.dom('[role="dialog"]').exists();

      await click('#item-b');
      assert
        .dom(root)
        .hasAttribute('data-mobile-sidebar-open', 'true', 'disabled: open');

      await click('#item-a');
      assert.dom(root).hasAttribute('data-mobile-sidebar-open', 'false');
      assert.dom('[role="dialog"]').doesNotExist();
    });

    test('activating an inline Item does not touch the drawer state', async function (assert) {
      media = mockMatchMedia(DESKTOP);
      const state = new AppLayoutState({ mobileSidebarOpen: true });
      await render(
        <template>
          <AppLayout @state={{state}} as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>
                <sidebar.Item @href="#item-a" id="item-a">A</sidebar.Item>
              </sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      await click('#item-a');
      assert.true(state.mobileSidebarOpen);
    });

    test('mod+b ignores key repeat', async function (assert) {
      media = mockMatchMedia(DESKTOP);
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Navbar>
              <button type="button" id="inside">Inside</button>
            </layout.Navbar>
            <layout.Sidebar />
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const root = '[data-component="app-layout"]';
      await pressModB('#inside');
      assert.dom(root).hasAttribute('data-sidebar-collapsed', 'true');
      await triggerEvent('#inside', 'keydown', {
        key: 'b',
        repeat: true,
        ...modKeys()
      });
      assert
        .dom(root)
        .hasAttribute('data-sidebar-collapsed', 'true', 'a held key repeats');
    });

    test('mod+b is left to a contenteditable element', async function (assert) {
      media = mockMatchMedia(DESKTOP);
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Main>
              <div id="editor" contenteditable="true">Text</div>
            </layout.Main>
            <layout.Sidebar />
          </AppLayout>
        </template>
      );

      // `window` hears the event after the layout's `document` listener.
      let prevented: boolean | undefined;
      const record = (event: Event): void => {
        prevented = event.defaultPrevented;
      };
      window.addEventListener('keydown', record);
      try {
        await triggerEvent('#editor', 'keydown', {
          key: 'b',
          ...modKeys()
        });
      } finally {
        window.removeEventListener('keydown', record);
      }
      assert
        .dom('[data-component="app-layout"]')
        .hasAttribute('data-sidebar-collapsed', 'false');
      assert.false(prevented, 'the browser keeps its own bold');
    });

    test('an alt shortcut matches by key code (Option changes the key on macOS)', async function (assert) {
      media = mockMatchMedia(DESKTOP);
      await render(
        <template>
          <AppLayout @toggleShortcut="alt+b" as |layout|>
            <layout.Navbar>
              <button type="button" id="inside">Inside</button>
            </layout.Navbar>
            <layout.Sidebar />
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      await triggerEvent('#inside', 'keydown', {
        key: '∫',
        code: 'KeyB',
        altKey: true
      });
      assert
        .dom('[data-component="app-layout"]')
        .hasAttribute('data-sidebar-collapsed', 'true');
    });

    test('data-sidebar-collapsed is false for a sidebar with collapsible=none', async function (assert) {
      media = mockMatchMedia(DESKTOP);
      await render(
        <template>
          <AppLayout @defaultSidebarCollapsed={{true}} as |layout|>
            <layout.Sidebar @collapsible="none" />
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert
        .dom('[data-component="app-layout"]')
        .hasAttribute('data-sidebar-collapsed', 'false');
    });

    test('in the drawer the header clears the close button', async function (assert) {
      media = mockMatchMedia(MOBILE);
      // Other test files replace the drawer's theme with class markers; this
      // geometry needs the shipped classes (see real-theme-styles).
      const previous = {
        drawer: useStyles().drawer,
        overlay: useStyles().overlay,
        backdrop: useStyles().backdrop
      };
      registerCustomStyles({
        drawer: realStyles.drawer,
        overlay: realStyles.overlay,
        backdrop: realStyles.backdrop
      });
      try {
        await render(
          <template>
            <AppLayout @defaultMobileSidebarOpen={{true}} as |layout|>
              <layout.Sidebar as |sidebar|>
                <sidebar.Header>
                  <span id="header-end" class="ms-auto">End</span>
                </sidebar.Header>
              </layout.Sidebar>
              <layout.Main>Content</layout.Main>
            </AppLayout>
          </template>
        );

        const end = find('#header-end')!.getBoundingClientRect();
        const close = find(
          '[role="dialog"] [data-part="close-button"]'
        )!.getBoundingClientRect();
        assert.true(
          end.right <= close.left + 0.5,
          `header content (right ${end.right}) ends before the close button (left ${close.left})`
        );
      } finally {
        registerCustomStyles(previous);
      }
    });

    test('standalone MenuToggle opens @state', async function (assert) {
      const state = new AppLayoutState();
      await render(
        <template>
          <MenuToggle @state={{state}} @controls="my-nav" @label="Menu" />
        </template>
      );

      assert.dom('[data-part="menu-toggle"]').hasAria('controls', 'my-nav');
      assert.dom('[data-part="menu-toggle"]').hasAria('label', 'Menu');
      await click('[data-part="menu-toggle"]');
      assert.true(state.mobileSidebarOpen);
    });
  }
);
