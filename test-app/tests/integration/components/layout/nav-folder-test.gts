import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  rerender,
  find,
  click,
  focus,
  settled,
  triggerEvent,
  triggerKeyEvent
} from '@ember/test-helpers';
import { tracked } from '@glimmer/tracking';
import { htmlSafe } from '@ember/template';
import { AppLayout } from 'frontile';
import NavFolder from 'frontile/components/layout/nav-folder';
import { setPrefersReducedMotion } from 'frontile/test-support';
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

const TRIGGER = '[data-part="nav-folder-trigger"]';
const PANEL = '[data-part="nav-folder-panel"]';
const ROOT = '[data-component="nav-folder"]';

class State {
  @tracked active = false;
  @tracked hidden = false;
  @tracked showExtra = false;
  @tracked label = 'Reports';
}

module(
  'Integration | Component | NavFolder | frontile/layout',
  function (hooks) {
    setupRenderingTest(hooks);

    test('renders a button trigger with aria-expanded=false and a collapsed panel', async function (assert) {
      await render(
        <template>
          <NavFolder @label="Reports" @icon={{TestIcon}} as |folder|>
            <folder.Item @href="/a">A</folder.Item>
          </NavFolder>
        </template>
      );

      assert.dom(ROOT).exists({ count: 1 });
      assert.dom(ROOT).hasAttribute('data-part', 'nav-folder');
      assert.dom(ROOT).doesNotHaveAttribute('hidden');

      const trigger = find(TRIGGER)!;
      const panel = find(PANEL)!;
      assert.strictEqual(trigger.tagName, 'BUTTON');
      assert.dom(trigger).hasAttribute('type', 'button');
      assert.dom(trigger).hasAttribute('aria-expanded', 'false');
      assert.dom(trigger).hasAttribute('data-open', 'false');
      assert.dom(trigger).hasAttribute('aria-controls', panel.id);
      assert.dom(trigger).hasAttribute('class');
      assert.dom(trigger).hasText('Reports');
      assert.dom(`${TRIGGER} [data-test-icon]`).exists();
      assert.dom(`${TRIGGER} [data-part="nav-item-label"]`).hasText('Reports');
      assert
        .dom(`${TRIGGER} [data-part="nav-item-label"]`)
        .hasAttribute('data-sidebar-label');
      assert
        .dom(`${TRIGGER} [data-part="nav-folder-chevron"]`)
        .hasAttribute('data-open', 'false');

      assert.ok(panel.id, 'the panel has an id');
      assert.dom(panel).hasAttribute('role', 'group');
      assert.dom(panel).hasAttribute('aria-labelledby', trigger.id);
      assert.dom(panel).hasAttribute('inert', '', 'collapsed panel is inert');
      assert.dom(`${PANEL} [data-part="nav-item"]`).exists({ count: 1 });
    });

    test('clicking toggles aria-expanded and the panel', async function (assert) {
      const changes: boolean[] = [];
      const onOpenChange = (open: boolean) => changes.push(open);
      await render(
        <template>
          <NavFolder
            @label="Reports"
            @onOpenChange={{onOpenChange}}
            as |folder|
          >
            <folder.Item @href="/a">A</folder.Item>
          </NavFolder>
        </template>
      );

      await click(TRIGGER);
      assert.dom(TRIGGER).hasAttribute('aria-expanded', 'true');
      assert.dom(TRIGGER).hasAttribute('data-open', 'true');
      assert
        .dom(`${TRIGGER} [data-part="nav-folder-chevron"]`)
        .hasAttribute('data-open', 'true');
      assert.dom(PANEL).doesNotHaveAttribute('inert');
      assert.dom(`${PANEL} [data-part="nav-item"]`).isVisible();

      await click(TRIGGER);
      assert.dom(TRIGGER).hasAttribute('aria-expanded', 'false');
      assert.dom(PANEL).hasAttribute('inert');
      assert.deepEqual(changes, [true, false]);
    });

    test('@defaultOpen starts it open', async function (assert) {
      await render(
        <template>
          <NavFolder @label="Reports" @defaultOpen={{true}} as |folder|>
            <folder.Item @href="/a">A</folder.Item>
          </NavFolder>
        </template>
      );

      assert.dom(TRIGGER).hasAttribute('aria-expanded', 'true');
      assert.dom(PANEL).doesNotHaveAttribute('inert');
    });

    test('the trigger never has aria-current, even with an active child', async function (assert) {
      await render(
        <template>
          <NavFolder @label="Reports" as |folder|>
            <folder.Item @href="/a" @isActive={{true}}>A</folder.Item>
          </NavFolder>
        </template>
      );

      assert.dom(TRIGGER).doesNotHaveAttribute('aria-current');
      assert
        .dom(`${PANEL} [data-part="nav-item"]`)
        .hasAttribute('aria-current', 'page', 'the child is the current page');

      await click(TRIGGER);
      assert.dom(TRIGGER).doesNotHaveAttribute('aria-current');
    });

    test('opens on mount when a child is active, and marks the trigger data-active', async function (assert) {
      await render(
        <template>
          <NavFolder @label="Reports" as |folder|>
            <folder.Item @href="/a">A</folder.Item>
            <folder.Item @href="/b" @isActive={{true}}>B</folder.Item>
          </NavFolder>
        </template>
      );

      assert.dom(TRIGGER).hasAttribute('aria-expanded', 'true');
      assert.dom(TRIGGER).hasAttribute('data-active', 'true');
      assert.dom(PANEL).doesNotHaveAttribute('inert');
    });

    test('an inactive folder is not data-active and stays closed', async function (assert) {
      await render(
        <template>
          <NavFolder @label="Reports" as |folder|>
            <folder.Item @href="/a">A</folder.Item>
          </NavFolder>
        </template>
      );

      assert.dom(TRIGGER).hasAttribute('data-active', 'false');
      assert.dom(TRIGGER).hasAttribute('aria-expanded', 'false');
    });

    test('does not reopen after the user closes it on a later, unrelated render', async function (assert) {
      const state = new State();
      await render(
        <template>
          <NavFolder @label={{state.label}} as |folder|>
            <folder.Item @href="/a" @isActive={{true}}>A</folder.Item>
            {{#if state.showExtra}}
              <folder.Item @href="/c">C</folder.Item>
            {{/if}}
          </NavFolder>
        </template>
      );

      assert.dom(TRIGGER).hasAttribute('aria-expanded', 'true', 'auto-opened');
      await click(TRIGGER);
      assert.dom(TRIGGER).hasAttribute('aria-expanded', 'false', 'closed');

      state.label = 'Renamed';
      await settled();
      assert.dom(TRIGGER).hasAttribute('aria-expanded', 'false');

      state.showExtra = true;
      await settled();
      assert
        .dom(TRIGGER)
        .hasAttribute('aria-expanded', 'false', 'a new child does not reopen');
      assert.dom(TRIGGER).hasAttribute('data-active', 'true', 'still active');
    });

    test('opens when a child newly becomes active, even if the user closed it', async function (assert) {
      const state = new State();
      await render(
        <template>
          <NavFolder @label="Reports" as |folder|>
            <folder.Item @href="/a" @isActive={{state.active}}>A</folder.Item>
          </NavFolder>
        </template>
      );

      assert.dom(TRIGGER).hasAttribute('aria-expanded', 'false');
      await click(TRIGGER);
      await click(TRIGGER);
      assert.dom(TRIGGER).hasAttribute('aria-expanded', 'false', 'user closed');

      state.active = true;
      await settled();
      assert.dom(TRIGGER).hasAttribute('aria-expanded', 'true', 'opened');
      assert.dom(TRIGGER).hasAttribute('data-active', 'true');

      await click(TRIGGER);
      state.active = false;
      await settled();
      assert.dom(TRIGGER).hasAttribute('aria-expanded', 'false');
      assert.dom(TRIGGER).hasAttribute('data-active', 'false');

      state.active = true;
      await settled();
      assert
        .dom(TRIGGER)
        .hasAttribute(
          'aria-expanded',
          'true',
          'opens again on a new activation'
        );
    });

    test('controlled @open ignores clicks and calls @onOpenChange', async function (assert) {
      const changes: boolean[] = [];
      const onOpenChange = (open: boolean) => changes.push(open);
      await render(
        <template>
          <NavFolder
            @label="Reports"
            @open={{false}}
            @onOpenChange={{onOpenChange}}
            as |folder|
          >
            <folder.Item @href="/a">A</folder.Item>
          </NavFolder>
        </template>
      );

      await click(TRIGGER);
      assert.dom(TRIGGER).hasAttribute('aria-expanded', 'false');
      assert.deepEqual(changes, [true]);
    });

    test('controlled @open=true renders open and requests close on click', async function (assert) {
      const changes: boolean[] = [];
      const onOpenChange = (open: boolean) => changes.push(open);
      await render(
        <template>
          <NavFolder
            @label="Reports"
            @open={{true}}
            @onOpenChange={{onOpenChange}}
            as |folder|
          >
            <folder.Item @href="/a">A</folder.Item>
          </NavFolder>
        </template>
      );

      assert.dom(TRIGGER).hasAttribute('aria-expanded', 'true');
      await click(TRIGGER);
      assert.dom(TRIGGER).hasAttribute('aria-expanded', 'true');
      assert.deepEqual(changes, [false]);
    });

    test('in controlled mode an auto-open calls @onOpenChange(true)', async function (assert) {
      const changes: boolean[] = [];
      const onOpenChange = (open: boolean) => changes.push(open);
      await render(
        <template>
          <NavFolder
            @label="Reports"
            @open={{false}}
            @onOpenChange={{onOpenChange}}
            as |folder|
          >
            <folder.Item @href="/a" @isActive={{true}}>A</folder.Item>
          </NavFolder>
        </template>
      );

      assert.deepEqual(changes, [true]);
      assert
        .dom(TRIGGER)
        .hasAttribute('aria-expanded', 'false', 'the owner decides');
    });

    test('a hidden active child neither opens nor activates the folder', async function (assert) {
      await render(
        <template>
          <NavFolder @label="Reports" as |folder|>
            <folder.Item @href="/a">A</folder.Item>
            <folder.Item
              @href="/b"
              @isActive={{true}}
              @isHidden={{true}}
            >B</folder.Item>
          </NavFolder>
        </template>
      );

      assert.dom(ROOT).doesNotHaveAttribute('hidden');
      assert.dom(TRIGGER).hasAttribute('aria-expanded', 'false');
      assert.dom(TRIGGER).hasAttribute('data-active', 'false');
    });

    test('is hidden when every child is hidden', async function (assert) {
      const state = new State();
      await render(
        <template>
          <NavFolder @label="Reports" as |folder|>
            <folder.Item @href="/a" @isHidden={{true}}>A</folder.Item>
            <folder.Item @href="/b" @isHidden={{state.hidden}}>B</folder.Item>
          </NavFolder>
        </template>
      );

      assert.dom(ROOT).isVisible('one visible child keeps it shown');

      state.hidden = true;
      await settled();
      assert.dom(ROOT).hasAttribute('hidden');
      assert.dom(ROOT).isNotVisible();
      assert.strictEqual(
        getComputedStyle(find(ROOT)!).display,
        'none',
        'no utility class overrides the hidden attribute'
      );
    });

    test('is hidden when it has no children', async function (assert) {
      await render(<template><NavFolder @label="Reports" /></template>);

      assert.dom(ROOT).hasAttribute('hidden');
      assert.dom(ROOT).isNotVisible();
    });

    test('is hidden with @isHidden', async function (assert) {
      await render(
        <template>
          <NavFolder @label="Reports" @isHidden={{true}} as |folder|>
            <folder.Item @href="/a">A</folder.Item>
          </NavFolder>
        </template>
      );

      assert.dom(ROOT).hasAttribute('hidden');
      assert.dom(ROOT).isNotVisible();
    });

    test('with a @parent it registers a handle that follows its visible children', async function (assert) {
      type Handle = {
        readonly isActive: boolean;
        readonly isHidden: boolean;
        readonly hasBadge: boolean;
      };
      const handles: Handle[] = [];
      let unregistered = 0;
      const parent = {
        registerItem(item: Handle) {
          handles.push(item);
          return () => {
            unregistered++;
          };
        }
      };
      const state = new (class {
        @tracked show = true;
        @tracked active = false;
        @tracked hidden = false;
        @tracked folderHidden = false;
        @tracked badge: number | undefined;
      })();

      await render(
        <template>
          {{#if state.show}}
            <NavFolder
              @label="Reports"
              @parent={{parent}}
              @isHidden={{state.folderHidden}}
              as |folder|
            >
              <folder.Item
                @href="/a"
                @isActive={{state.active}}
                @isHidden={{state.hidden}}
                @badge={{state.badge}}
              >A</folder.Item>
              <folder.Item @href="/b">B</folder.Item>
            </NavFolder>
          {{/if}}
        </template>
      );

      assert.strictEqual(handles.length, 1, 'registered once');
      const handle = handles[0]!;
      assert.false(handle.isActive);
      assert.false(handle.isHidden);
      assert.false(handle.hasBadge);

      state.active = true;
      state.badge = 2;
      await settled();
      assert.true(handle.isActive, 'an active child makes it active');
      assert.true(handle.hasBadge, 'a badged child gives it a badge');

      state.hidden = true;
      await settled();
      assert.false(handle.isActive, 'a hidden child does not count');
      assert.false(handle.hasBadge, 'a hidden badged child does not count');
      assert.false(handle.isHidden, 'one child is still visible');

      state.folderHidden = true;
      await settled();
      assert.true(handle.isHidden, '@isHidden hides it');

      state.show = false;
      await settled();
      assert.strictEqual(unregistered, 1, 'unregistered on destroy');
    });

    test('with a @parent it is hidden when every child is hidden', async function (assert) {
      const handles: { readonly isHidden: boolean }[] = [];
      const parent = {
        registerItem(item: {
          readonly isActive: boolean;
          readonly isHidden: boolean;
          readonly hasBadge: boolean;
        }) {
          handles.push(item);
          return () => {};
        }
      };
      await render(
        <template>
          <NavFolder @label="Reports" @parent={{parent}} as |folder|>
            <folder.Item @href="/a" @isHidden={{true}}>A</folder.Item>
          </NavFolder>
        </template>
      );

      assert.true(handles[0]!.isHidden);
    });

    test('a removed child is unregistered', async function (assert) {
      const state = new State();
      state.showExtra = true;
      await render(
        <template>
          <NavFolder @label="Reports" as |folder|>
            {{#if state.showExtra}}
              <folder.Item @href="/c" @isActive={{true}}>C</folder.Item>
            {{/if}}
          </NavFolder>
        </template>
      );

      assert.dom(TRIGGER).hasAttribute('data-active', 'true');
      assert.dom(ROOT).doesNotHaveAttribute('hidden');

      state.showExtra = false;
      await settled();
      assert
        .dom(TRIGGER)
        .hasAttribute(
          'data-active',
          'false',
          'the removed child no longer counts'
        );
      assert.dom(ROOT).hasAttribute('hidden', '', 'no children left');

      state.showExtra = true;
      await settled();
      assert
        .dom(TRIGGER)
        .hasAttribute('data-active', 'true', 'registered again');
      assert.dom(ROOT).doesNotHaveAttribute('hidden');
    });

    test('the trigger is a native button and keeps focus when toggled', async function (assert) {
      await render(
        <template>
          <NavFolder @label="Reports" as |folder|>
            <folder.Item @href="/a">A</folder.Item>
          </NavFolder>
        </template>
      );

      // Enter and Space activate a native <button> with a click; synthetic
      // key events do not, so the click below stands in for both keys.
      const trigger = find(TRIGGER) as HTMLButtonElement;
      assert.strictEqual(trigger.tagName, 'BUTTON');
      assert.false(trigger.disabled);
      await focus(trigger);
      await click(trigger);
      assert.dom(trigger).isFocused();
      assert.dom(trigger).hasAttribute('aria-expanded', 'true');
      await click(trigger);
      assert.dom(trigger).isFocused();
      assert.dom(trigger).hasAttribute('aria-expanded', 'false');
    });

    test('@class is appended to the folder root', async function (assert) {
      await render(
        <template>
          <NavFolder @label="Reports" @class="custom-folder" as |folder|>
            <folder.Item @href="/a">A</folder.Item>
          </NavFolder>
        </template>
      );

      assert.dom(ROOT).hasClass('custom-folder');
    });

    test('@class wins over a conflicting theme class', async function (assert) {
      await render(
        <template>
          <NavFolder @label="Reports" @class="flex-row" as |folder|>
            <folder.Item @href="/a">A</folder.Item>
          </NavFolder>
        </template>
      );

      assert.dom(ROOT).hasClass('flex-row');
      assert.dom(ROOT).doesNotHaveClass('flex-col', 'merged away');
      assert.dom(ROOT).hasClass('flex', 'other theme classes stay');
      assert.strictEqual(getComputedStyle(find(ROOT)!).flexDirection, 'row');
    });

    test('the chevron points along the reading direction, and down when open', async function (assert) {
      class Dir {
        @tracked dir: 'ltr' | 'rtl' = 'ltr';
      }
      const state = new Dir();
      await render(
        <template>
          <div dir={{state.dir}}>
            <NavFolder @label="Reports" as |folder|>
              <folder.Item @href="/a">A</folder.Item>
            </NavFolder>
          </div>
        </template>
      );

      const chevron = `${TRIGGER} [data-part="nav-folder-chevron"]`;
      assert.strictEqual(await pointing(chevron), 'right', 'ltr closed');
      await click(TRIGGER);
      assert.strictEqual(await pointing(chevron), 'down', 'ltr open');

      state.dir = 'rtl';
      await settled();
      assert.strictEqual(await pointing(chevron), 'down', 'rtl open');
      await click(TRIGGER);
      assert.strictEqual(await pointing(chevron), 'left', 'rtl closed');
    });
  }
);

/**
 * Where a right-pointing chevron icon points once its computed `scale` and
 * `rotate` apply (CSS applies scale first, then rotate). Waits for any
 * transition to finish first.
 */
async function pointing(
  selector: string
): Promise<'right' | 'down' | 'left' | 'up'> {
  const el = find(selector) as SVGElement;
  await Promise.all(el.getAnimations().map((a) => a.finished));
  const style = getComputedStyle(el);
  const [sx = 1, sy = sx] =
    style.scale === 'none' ? [] : style.scale.split(' ').map(Number);
  const angle = style.rotate === 'none' ? 0 : parseFloat(style.rotate);
  const tip = new DOMMatrix()
    .rotate(angle)
    .scale(sx, sy)
    .transformPoint(new DOMPoint(1, 0));
  if (Math.abs(tip.x) > Math.abs(tip.y)) {
    return tip.x > 0 ? 'right' : 'left';
  }
  return tip.y > 0 ? 'down' : 'up';
}

/** The panel shows no sign of having animated: as if it had started open. */
function assertStartedOpen(assert: Assert, panel: HTMLElement): void {
  assert.dom(TRIGGER).hasAttribute('aria-expanded', 'true');
  assert.strictEqual(panel.style.height, '', 'no inline height');
  assert.strictEqual(panel.style.overflow, '', 'no inline overflow');
  assert.strictEqual(panel.style.transition, '', 'no transition');
  assert.strictEqual(panel.getAnimations().length, 0, 'nothing animates');
}

async function nextFrame(): Promise<void> {
  await new Promise((resolve) => requestAnimationFrame(() => resolve(null)));
}

module(
  'Integration | Component | NavFolder opening animation | frontile/layout',
  function (hooks) {
    setupRenderingTest(hooks);

    // The default path animates; reduced motion would hide the difference.
    hooks.beforeEach(function () {
      setPrefersReducedMotion(false);
    });

    hooks.afterEach(function () {
      setPrefersReducedMotion(undefined);
    });

    test('a folder holding the active item starts open, without animating', async function (assert) {
      await render(
        <template>
          <NavFolder @label="Reports" as |folder|>
            <folder.Item @href="/a" @isActive={{true}}>A</folder.Item>
          </NavFolder>
        </template>
      );

      assertStartedOpen(assert, find(PANEL) as HTMLElement);
    });

    test('a child that becomes active after mount still animates the open', async function (assert) {
      const state = new State();
      await render(
        <template>
          <NavFolder @label="Reports" as |folder|>
            <folder.Item @href="/a" @isActive={{state.active}}>A</folder.Item>
          </NavFolder>
        </template>
      );
      await nextFrame();

      const panel = find(PANEL) as HTMLElement;
      state.active = true;
      await rerender();
      assert.dom(TRIGGER).hasAttribute('aria-expanded', 'true');
      assert.ok(
        panel.style.transition.includes('height'),
        'a height transition was written'
      );
      await settled();
    });

    test('a user click after mount still animates the open', async function (assert) {
      await render(
        <template>
          <NavFolder @label="Reports" as |folder|>
            <folder.Item @href="/a">A</folder.Item>
          </NavFolder>
        </template>
      );
      await nextFrame();

      const panel = find(PANEL) as HTMLElement;
      (find(TRIGGER) as HTMLButtonElement).click();
      await rerender();
      assert.ok(
        panel.style.transition.includes('height'),
        'a height transition was written'
      );
      await settled();
    });

    test('controlled @open mounted true starts open', async function (assert) {
      await render(
        <template>
          <NavFolder @label="Reports" @open={{true}} as |folder|>
            <folder.Item @href="/a" @isActive={{true}}>A</folder.Item>
          </NavFolder>
        </template>
      );

      assertStartedOpen(assert, find(PANEL) as HTMLElement);
    });

    test('controlled: an owner granting the mount-time open starts open', async function (assert) {
      class Owner {
        @tracked open = false;
        onOpenChange = (open: boolean) => {
          this.open = open;
        };
      }
      const owner = new Owner();
      await render(
        <template>
          <NavFolder
            @label="Reports"
            @open={{owner.open}}
            @onOpenChange={{owner.onOpenChange}}
            as |folder|
          >
            <folder.Item @href="/a" @isActive={{true}}>A</folder.Item>
          </NavFolder>
        </template>
      );

      assert.true(owner.open);
      assertStartedOpen(assert, find(PANEL) as HTMLElement);
    });
  }
);

module(
  'Integration | Component | NavFolder in Sidebar | frontile/layout',
  function (hooks) {
    setupRenderingTest(hooks);

    let media: MatchMediaMock | undefined;

    hooks.afterEach(function () {
      media?.restore();
      media = undefined;
    });

    test('sidebar.Folder yields bound items', async function (assert) {
      media = mockMatchMedia(1200);
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>
                <sidebar.Folder @label="Reports" as |folder|>
                  <folder.Item @href="#a" @isActive={{true}} id="child-a">
                    A
                  </folder.Item>
                </sidebar.Folder>
              </sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert.dom(`nav[data-part="sidebar"] ${ROOT}`).exists();
      assert.dom('#child-a').hasAttribute('data-part', 'nav-item');
      assert.dom('#child-a').hasAttribute('class');
      assert.dom(TRIGGER).hasAttribute('aria-expanded', 'true');
      assert.dom(TRIGGER).hasAttribute('data-active', 'true');
    });

    test('clicking a folder child in the mobile drawer closes the drawer', async function (assert) {
      media = mockMatchMedia(500);
      await render(
        <template>
          <AppLayout @defaultMobileSidebarOpen={{true}} as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>
                <sidebar.Folder
                  @label="Reports"
                  @defaultOpen={{true}}
                  as |folder|
                >
                  <folder.Item @href="#a" id="child-a">A</folder.Item>
                </sidebar.Folder>
              </sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      const root = '[data-component="app-layout"]';
      assert.dom('[role="dialog"]').exists();
      assert.dom(`[role="dialog"] ${ROOT}`).exists('inline in the drawer');

      await click(TRIGGER);
      assert
        .dom(root)
        .hasAttribute('data-mobile-sidebar-open', 'true', 'trigger keeps it');

      await click(TRIGGER);
      await click('#child-a');
      assert.dom(root).hasAttribute('data-mobile-sidebar-open', 'false');
      assert.dom('[role="dialog"]').doesNotExist();
    });
  }
);

const MENU = '[role="menu"]';
const MENU_ITEM = `${MENU} [role="menuitem"]`;

/** The open rail menu, or null. It is portaled out of the sidebar. */
function menu(): HTMLElement | null {
  return document.querySelector(MENU);
}

/** True for a box shrunk to (at most) a pixel: the sr-only technique. */
function isVisiblyHidden(el: Element): boolean {
  const rect = el.getBoundingClientRect();
  return rect.width <= 1 && rect.height <= 1;
}

const SIDEBAR_TOGGLE = '[data-part="sidebar-toggle"]';

/**
 * Dispatches a raw event and waits only for the render, not for timers:
 * `triggerEvent` awaits `settled()`, which would wait out a pending tooltip
 * open delay and hide it.
 */
async function dispatchWithoutSettling(
  selector: string,
  type: string
): Promise<void> {
  find(selector)!.dispatchEvent(new MouseEvent(type, { bubbles: false }));
  await rerender();
}

class RailState {
  @tracked active = false;
  @tracked disabled = false;
  @tracked hidden = false;
  @tracked collapsed = true;
  @tracked side: 'start' | 'end' = 'start';

  setCollapsed = (value: boolean): void => {
    this.collapsed = value;
  };
}

module(
  'Integration | Component | NavFolder menu in the icon rail | frontile/layout',
  function (hooks) {
    setupRenderingTest(hooks);

    let media: MatchMediaMock | undefined;

    // Full size and unscaled for these tests: the menu is hidden (Velcro's
    // `hide`) while its trigger is clipped out of view, and a hidden menu
    // cannot take focus. In the small, scaled test container the rail
    // trigger can be clipped depending on where earlier tests left it.
    const FULL_SCREEN = 'ember-testing-container-full-screen';

    hooks.beforeEach(function () {
      media = mockMatchMedia(1200);
      document
        .getElementById('ember-testing-container')
        ?.classList.add(FULL_SCREEN);
    });

    hooks.afterEach(function () {
      media?.restore();
      media = undefined;
      document
        .getElementById('ember-testing-container')
        ?.classList.remove(FULL_SCREEN);
    });

    async function renderRail(
      state: RailState,
      options: { defaultOpen?: boolean } = {}
    ): Promise<void> {
      const defaultOpen = options.defaultOpen ?? false;
      await render(
        <template>
          <AppLayout
            @sidebarCollapsed={{state.collapsed}}
            @onSidebarCollapsedChange={{state.setCollapsed}}
            @sidebarSide={{state.side}}
            as |layout|
          >
            <layout.Navbar><layout.SidebarToggle /></layout.Navbar>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>
                <sidebar.Item @href="#plain" @icon={{TestIcon}} id="plain">
                  Plain
                </sidebar.Item>
                <sidebar.Folder
                  @label="Reports"
                  @icon={{TestIcon}}
                  @defaultOpen={{defaultOpen}}
                  as |folder|
                >
                  <folder.Item @href="#a" @icon={{TestIcon}} id="child-a">
                    A
                  </folder.Item>
                  <folder.Item
                    @href="#b"
                    @isActive={{state.active}}
                    @isHidden={{state.hidden}}
                    id="child-b"
                  >B</folder.Item>
                  <folder.Item
                    @href="#c"
                    @isDisabled={{state.disabled}}
                    id="child-c"
                  >C</folder.Item>
                </sidebar.Folder>
                <a href="#after" id="after">After</a>
              </sidebar.Body>
            </layout.Sidebar>
            <layout.Main><button type="button" id="outside">Outside</button>
            </layout.Main>
          </AppLayout>
        </template>
      );
    }

    test('in the rail the trigger is a menu button that opens a menu of links beside the rail', async function (assert) {
      await renderRail(new RailState());

      assert.dom(PANEL).doesNotExist('no inline panel in the rail');
      assert.dom(MENU).doesNotExist('closed until opened');
      const trigger = find(TRIGGER)!;
      assert.strictEqual(
        trigger.tagName,
        'BUTTON',
        'a button, so a click never follows a link'
      );
      assert.dom(trigger).hasAria('haspopup', 'true');
      assert.dom(trigger).hasAria('expanded', 'false');

      await click(trigger);
      assert.dom(trigger).hasAria('expanded', 'true');
      assert.dom(ROOT).hasAttribute('data-open', 'true');
      assert.dom(MENU).exists({ count: 1 });
      assert.dom(trigger).hasAria('controls', find(MENU)!.closest('[id]')!.id);
      assert
        .dom(MENU_ITEM)
        .exists({ count: 3 }, 'one menuitem per item, no extra rows');
      assert.dom('#child-a').hasAttribute('role', 'menuitem');
      assert.dom('#child-a a').hasAttribute('href', '#a');
      assert.dom('#child-a a').hasAttribute('tabindex', '-1');
      assert
        .dom(`${ROOT} ${MENU}`)
        .doesNotExist('portaled out of the sidebar, so it is never clipped');

      await click(trigger);
      assert.dom(trigger).hasAria('expanded', 'false', 'the trigger toggles');
      assert.dom(MENU).doesNotExist();
      assert.dom(ROOT).hasAttribute('data-open', 'false');
    });

    test('the menu has no heading and is named by the trigger', async function (assert) {
      await renderRail(new RailState());

      await click(TRIGGER);
      assert.dom(MENU).hasAria('labelledby', find(TRIGGER)!.id);
      assert
        .dom(`${MENU} [data-part="nav-folder-flyout-label"]`)
        .doesNotExist();
      assert
        .dom(MENU)
        .doesNotIncludeText('Reports', 'the folder name is not repeated');
      assert.strictEqual(
        menu()!.firstElementChild,
        find('#child-a'),
        'the first row is the first item'
      );
    });

    test('in the rail a folder holding the current page is active while its menu is closed', async function (assert) {
      const state = new RailState();
      state.active = true;
      await renderRail(state);

      assert.dom(TRIGGER).hasAttribute('data-active', 'true');
      assert.dom(TRIGGER).hasAria('expanded', 'false', 'no menu on load');
      assert.dom(TRIGGER).doesNotHaveAttribute('aria-current');
      assert.dom(MENU).doesNotExist();
      assert.strictEqual(
        document.querySelectorAll('#child-b').length,
        0,
        'the closed menu renders no item, so no id is duplicated'
      );
      assert.strictEqual(
        find(ROOT)!.querySelectorAll('a, button, [tabindex]').length,
        1,
        'the trigger is the only focusable element in the folder'
      );

      state.active = false;
      await settled();
      assert.dom(TRIGGER).hasAttribute('data-active', 'false');

      state.active = true;
      await settled();
      assert.dom(TRIGGER).hasAttribute('data-active', 'true', 'and back');

      await click(TRIGGER);
      assert.strictEqual(
        document.querySelectorAll('#child-b').length,
        1,
        'each item is rendered once while open'
      );
      assert.dom('#child-b').hasAria('current', 'page');
      assert.strictEqual(
        document.querySelectorAll('[role="menuitem"][aria-current="page"]')
          .length,
        1,
        'one current-page row'
      );
      assert
        .dom(TRIGGER)
        .hasAttribute('data-active', 'true', 'still active while open');

      await click(TRIGGER);
      assert
        .dom(TRIGGER)
        .hasAttribute('data-active', 'true', 'and after it closed');
    });

    test('in the rail a hidden active item does not make the folder active', async function (assert) {
      const state = new RailState();
      state.active = true;
      state.hidden = true;
      await renderRail(state);

      assert.dom(TRIGGER).hasAttribute('data-active', 'false');
      await click(TRIGGER);
      assert.dom('#child-b').doesNotExist('a hidden item is not in the menu');
      assert.dom(MENU_ITEM).exists({ count: 2 });
    });

    test('in the rail a newly active child does not pop the menu open, but opens the inline state', async function (assert) {
      const state = new RailState();
      await renderRail(state);

      state.active = true;
      await settled();
      assert.dom(TRIGGER).hasAttribute('data-active', 'true');
      assert.dom(TRIGGER).hasAria('expanded', 'false');
      assert.dom(MENU).doesNotExist();

      await click(SIDEBAR_TOGGLE);
      assert.dom(PANEL).exists('expanded: inline again');
      assert
        .dom(TRIGGER)
        .hasAria(
          'expanded',
          'true',
          'the auto-open landed on the inline state'
        );
    });

    test('keyboard: ArrowDown, Enter and Space open the menu onto the first item', async function (assert) {
      await renderRail(new RailState());

      for (const key of ['ArrowDown', 'Enter', ' '] as const) {
        await focus(TRIGGER);
        // ArrowDown: only the keyup. Its keydown also opens (Popover), and in
        // a browser focus is in the menu by the keyup; a synthetic keyup on
        // the trigger would toggle it shut again.
        if (key !== 'ArrowDown') {
          await triggerKeyEvent(TRIGGER, 'keydown', key);
        }
        await triggerKeyEvent(TRIGGER, 'keyup', key);
        assert.ok(menu(), `${JSON.stringify(key)} opened the menu`);
        assert
          .dom('#child-a')
          .hasAttribute('data-active', 'true', 'onto the first item');

        await triggerKeyEvent(MENU, 'keydown', 'Escape');
        assert.dom(MENU).doesNotExist();
      }
    });

    for (const key of ['Enter', ' ', 'ArrowDown'] as const) {
      test(`a real ${JSON.stringify(key)} press on the trigger puts focus in the menu at once, and ArrowDown then moves within it`, async function (assert) {
        await renderRail(new RailState());
        await focus(TRIGGER);

        // Real key presses: keydown, then keyup on whatever has focus by
        // then. Only renders are awaited, never timers, so focus has to be
        // in the menu before the next key event, as it is for a person
        // typing quickly.
        const press = (el: Element | null, type: string, k: string): void => {
          el?.dispatchEvent(
            new KeyboardEvent(type, { key: k, bubbles: true, cancelable: true })
          );
        };
        press(find(TRIGGER), 'keydown', key);
        await rerender();
        press(document.activeElement, 'keyup', key);
        await rerender();

        assert.ok(menu(), 'open');
        assert.strictEqual(
          document.activeElement,
          menu(),
          'focus is in the menu'
        );
        assert.dom('#child-a').hasAttribute('data-active', 'true');

        // The list's 1ms bookkeeping flush, far inside any human gap between
        // two keys.
        await settled();
        press(document.activeElement, 'keydown', 'ArrowDown');
        await rerender();
        press(document.activeElement, 'keyup', 'ArrowDown');
        await settled();

        assert.ok(menu(), 'still open');
        assert.dom(TRIGGER).hasAria('expanded', 'true');
        assert.dom('#child-b').hasAttribute('data-active', 'true');

        await triggerKeyEvent(MENU, 'keydown', 'Escape');
        assert.dom(MENU).doesNotExist();
        assert.dom(TRIGGER).isFocused('Escape returns focus to the trigger');
      });
    }

    test('keyboard: the arrows move between items and skip a disabled one', async function (assert) {
      const state = new RailState();
      state.disabled = true;
      await renderRail(state);

      await focus(TRIGGER);
      await triggerKeyEvent(TRIGGER, 'keyup', 'ArrowDown');
      assert.dom('#child-a').hasAttribute('data-active', 'true');

      await triggerKeyEvent(MENU, 'keydown', 'ArrowDown');
      assert.dom('#child-b').hasAttribute('data-active', 'true');
      assert.dom('#child-a').hasAttribute('data-active', 'false');

      await triggerKeyEvent(MENU, 'keydown', 'ArrowDown');
      assert
        .dom('#child-c')
        .hasAttribute('data-active', 'false', 'the disabled item is skipped');

      await triggerKeyEvent(MENU, 'keydown', 'ArrowUp');
      assert.dom('#child-a').hasAttribute('data-active', 'true');
    });

    test('an action item with no href calls @onActivate once on click and on Enter, and closes the menu', async function (assert) {
      const state = new RailState();
      let calls = 0;
      const onActivate = (): void => {
        calls++;
      };
      await render(
        <template>
          <AppLayout
            @sidebarCollapsed={{state.collapsed}}
            @onSidebarCollapsedChange={{state.setCollapsed}}
            as |layout|
          >
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>
                <sidebar.Folder @label="Account" @icon={{TestIcon}} as |folder|>
                  <folder.Item @onActivate={{onActivate}} id="logout">
                    Log out
                  </folder.Item>
                </sidebar.Folder>
              </sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Main</layout.Main>
          </AppLayout>
        </template>
      );

      await click(TRIGGER);
      await click('#logout');
      assert.strictEqual(calls, 1, 'click called it once');
      assert.dom(MENU).doesNotExist('click closed the menu');

      await focus(TRIGGER);
      await triggerKeyEvent(TRIGGER, 'keyup', 'ArrowDown');
      await triggerKeyEvent(MENU, 'keydown', 'Enter');
      assert.strictEqual(calls, 2, 'Enter called it once more');
      assert.dom(MENU).doesNotExist('Enter closed the menu');
    });

    test('a disabled item has no live link', async function (assert) {
      const state = new RailState();
      state.disabled = true;
      await renderRail(state);

      await click(TRIGGER);
      assert.dom('#child-c').hasAria('disabled', 'true');
      assert.dom('#child-c a[href]').doesNotExist('no href to follow');
      assert.dom('#child-c').hasText('C');

      await click('#child-c');
      assert.ok(menu(), 'clicking it does nothing, the menu stays open');
    });

    test('keyboard: Enter on an item follows its link and closes the menu', async function (assert) {
      await renderRail(new RailState());

      let followed = '';
      const onClick = (event: MouseEvent): void => {
        const anchor = (event.target as Element).closest('a');
        if (anchor) {
          followed = anchor.getAttribute('href') ?? '';
          event.preventDefault();
        }
      };
      document.addEventListener('click', onClick, true);

      try {
        await focus(TRIGGER);
        await triggerKeyEvent(TRIGGER, 'keyup', 'ArrowDown');
        await triggerKeyEvent(MENU, 'keydown', 'ArrowDown');
        await triggerKeyEvent(MENU, 'keydown', 'Enter');

        assert.strictEqual(
          followed,
          '#b',
          "the active item's link was clicked"
        );
        assert.dom(MENU).doesNotExist('following it closed the menu');
        assert.dom(TRIGGER).hasAria('expanded', 'false');
      } finally {
        document.removeEventListener('click', onClick, true);
      }
    });

    test('Escape closes the menu and returns focus to the trigger', async function (assert) {
      await renderRail(new RailState());

      await focus(TRIGGER);
      await triggerKeyEvent(TRIGGER, 'keyup', 'ArrowDown');
      assert.ok(menu(), 'open');
      assert.ok(
        menu()!
          .closest('[data-component="overlay"]')!
          .contains(document.activeElement),
        'focus moved into the menu'
      );

      await triggerKeyEvent(MENU, 'keydown', 'Escape');
      assert.dom(MENU).doesNotExist();
      assert.dom(TRIGGER).hasAria('expanded', 'false');
      assert.dom(TRIGGER).isFocused();

      await click(TRIGGER);
      await triggerKeyEvent(TRIGGER, 'keydown', 'Escape');
      assert.dom(TRIGGER).hasAria('expanded', 'false', 'from the trigger too');
      assert.dom(TRIGGER).isFocused();
    });

    test('Tab out of the menu closes it', async function (assert) {
      await renderRail(new RailState());

      await focus(TRIGGER);
      await triggerKeyEvent(TRIGGER, 'keyup', 'ArrowDown');
      assert.ok(menu(), 'open');

      await triggerKeyEvent(MENU, 'keydown', 'Tab');
      assert.dom(MENU).doesNotExist('Tab closed it');
      assert.dom(TRIGGER).hasAria('expanded', 'false');
      assert.dom(TRIGGER).isFocused('focus is back on the trigger');

      await triggerKeyEvent(TRIGGER, 'keyup', 'ArrowDown');
      await triggerKeyEvent(MENU, 'keydown', 'Tab', { shiftKey: true });
      assert.dom(MENU).doesNotExist('Shift+Tab closed it too');
    });

    test('clicking an item or outside closes the menu', async function (assert) {
      await renderRail(new RailState());

      await click(TRIGGER);
      await click('#child-a');
      assert.dom(TRIGGER).hasAria('expanded', 'false', 'item click');
      assert.dom(MENU).doesNotExist();

      await click(TRIGGER);
      await click('#outside');
      assert.dom(TRIGGER).hasAria('expanded', 'false', 'outside click');
      assert.dom(MENU).doesNotExist();
    });

    test('the rail trigger tooltip opens with no delay', async function (assert) {
      await renderRail(new RailState());

      await dispatchWithoutSettling(TRIGGER, 'mouseenter');
      assert
        .dom('[role="tooltip"]')
        .exists('open after one render, no timer waited out');
      assert.dom('[role="tooltip"]').hasText('Reports');
      await triggerEvent(TRIGGER, 'mouseleave');
      assert.dom('[role="tooltip"]').doesNotExist();
    });

    test('the tooltip is not shown while the menu is open', async function (assert) {
      await renderRail(new RailState());

      await triggerEvent(TRIGGER, 'mouseenter');
      assert.dom('[role="tooltip"]').exists('hovering names the icon');

      await click(TRIGGER);
      assert.ok(menu(), 'the menu opened');
      assert
        .dom('[role="tooltip"]')
        .doesNotExist('it closed as the menu opened');
      assert.dom(TRIGGER).hasAria('expanded', 'true');

      await triggerEvent(TRIGGER, 'mouseleave');
      await dispatchWithoutSettling(TRIGGER, 'mouseenter');
      await settled();
      assert
        .dom('[role="tooltip"]')
        .doesNotExist('hovering the open trigger shows none');

      await triggerEvent(TRIGGER, 'mouseleave');
      await click('#outside');
      assert.dom(MENU).doesNotExist();
      await triggerEvent(TRIGGER, 'mouseenter');
      assert.dom('[role="tooltip"]').exists('back once the menu closed');
    });

    test('a keyboard open hides a tooltip shown on focus', async function (assert) {
      await renderRail(new RailState());

      await focus(TRIGGER);
      assert.dom('[role="tooltip"]').exists('focus shows the tooltip');
      await triggerKeyEvent(TRIGGER, 'keyup', 'ArrowDown');
      assert.ok(menu(), 'open');
      assert.dom('[role="tooltip"]').doesNotExist();
      assert.dom(TRIGGER).hasAria('expanded', 'true');
    });

    test('the expanded sidebar shows no folder tooltip and no menu', async function (assert) {
      const state = new RailState();
      state.collapsed = false;
      await renderRail(state);

      await triggerEvent(TRIGGER, 'mouseenter');
      assert.dom('[role="tooltip"]').doesNotExist();
      assert.dom(TRIGGER).doesNotHaveAria('haspopup');
      await click(TRIGGER);
      assert.dom(MENU).doesNotExist('inline disclosure');
      assert.dom(PANEL).exists();
      assert.dom(TRIGGER).hasAria('expanded', 'true');
      assert.dom(TRIGGER).hasAria('controls', find(PANEL)!.id);
    });

    test('expanding the sidebar while the menu is open closes it and keeps the inline state', async function (assert) {
      const state = new RailState();
      await renderRail(state);

      await click(TRIGGER);
      assert.dom(TRIGGER).hasAria('expanded', 'true');

      // Expanded from outside, with no click that would dismiss the menu.
      state.collapsed = false;
      await settled();
      assert.dom(MENU).doesNotExist('no menu outside the rail');
      assert.dom(PANEL).exists();
      assert.dom(TRIGGER).hasAria('expanded', 'false', 'inline state: closed');
      assert.dom(TRIGGER).hasAria('controls', find(PANEL)!.id);
      assert.dom(TRIGGER).doesNotHaveAria('haspopup');

      state.collapsed = true;
      await settled();
      assert.dom(MENU).doesNotExist('the menu starts closed again');
      assert.dom(TRIGGER).hasAria('expanded', 'false');
      await click(TRIGGER);
      assert.ok(menu(), 'and still opens');
    });

    test('data-active and a user-closed inline state survive collapse/expand cycles', async function (assert) {
      const state = new RailState();
      state.active = true;
      state.collapsed = false;
      await renderRail(state);

      assert.dom(TRIGGER).hasAttribute('data-active', 'true', 'inline');
      assert.dom(TRIGGER).hasAria('expanded', 'true', 'auto-opened');

      await click(TRIGGER);
      assert.dom(TRIGGER).hasAria('expanded', 'false', 'the user closed it');

      await click(SIDEBAR_TOGGLE);
      assert.dom(PANEL).doesNotExist('rail');
      assert.dom(TRIGGER).hasAttribute('data-active', 'true', 'rail');

      await click(SIDEBAR_TOGGLE);
      assert.dom(PANEL).exists('inline again');
      assert.dom(TRIGGER).hasAttribute('data-active', 'true', 'inline again');
      assert
        .dom(TRIGGER)
        .hasAria('expanded', 'false', 'the user-closed folder stays closed');

      await click(SIDEBAR_TOGGLE);
      await click(SIDEBAR_TOGGLE);
      assert.dom(TRIGGER).hasAttribute('data-active', 'true', 'second cycle');
      assert.dom(TRIGGER).hasAria('expanded', 'false', 'still closed');
    });

    test('the inline open state survives the menu and collapse cycles', async function (assert) {
      const state = new RailState();
      state.collapsed = false;
      await renderRail(state, { defaultOpen: true });

      assert.dom(TRIGGER).hasAria('expanded', 'true', 'inline: open');

      await click(SIDEBAR_TOGGLE);
      assert.dom(PANEL).doesNotExist('collapsing hides the inline panel');
      assert.dom(TRIGGER).hasAria('expanded', 'false', 'the menu is closed');

      await click(TRIGGER);
      await click(TRIGGER);
      await click(SIDEBAR_TOGGLE);
      assert.dom(TRIGGER).hasAria('expanded', 'true', 'inline: still open');
      assert.dom(`${PANEL} #child-a`).isVisible();

      await click(TRIGGER);
      assert.dom(TRIGGER).hasAria('expanded', 'false', 'inline: closed');
      await click(SIDEBAR_TOGGLE);
      await click(TRIGGER);
      assert.dom(TRIGGER).hasAria('expanded', 'true', 'menu open');
      await click(SIDEBAR_TOGGLE);
      assert.dom(TRIGGER).hasAria('expanded', 'false', 'inline: still closed');
    });

    test('in the mobile drawer the folder is inline even when collapsed', async function (assert) {
      media!.setWidth(500);
      await render(
        <template>
          <AppLayout
            @defaultSidebarCollapsed={{true}}
            @defaultMobileSidebarOpen={{true}}
            as |layout|
          >
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>
                <sidebar.Folder @label="Reports" as |folder|>
                  <folder.Item @href="#a" id="child-a">A</folder.Item>
                </sidebar.Folder>
              </sidebar.Body>
            </layout.Sidebar>
            <layout.Main>Content</layout.Main>
          </AppLayout>
        </template>
      );

      assert.dom(`[role="dialog"] ${ROOT}`).exists();
      assert.dom(PANEL).exists();
      assert.dom(TRIGGER).doesNotHaveAria('haspopup');

      await click(TRIGGER);
      assert.dom(TRIGGER).hasAria('expanded', 'true');
      assert.dom(`${PANEL} #child-a`).isVisible();
      assert.dom(MENU).doesNotExist();
    });

    test('menu items show their icons and labels, with no tooltip', async function (assert) {
      await renderRail(new RailState());

      await click(TRIGGER);
      const label = find('#child-a [data-part="nav-item-label"]')!;
      assert.false(isVisiblyHidden(label), 'the label is visible');
      assert.dom('#child-a [data-part="nav-item-icon"] svg').exists();
      assert
        .dom('#child-a [data-part="nav-item-icon"]')
        .hasAria('hidden', 'true');

      await triggerEvent('#child-a', 'mouseenter');
      assert.dom('[role="tooltip"]').doesNotExist('no rail tooltip');
    });

    test('long labels truncate in a menu of bounded width', async function (assert) {
      const long =
        'A remarkably long report name that would otherwise stretch '.repeat(4);
      // Measures real CSS, so it needs the shipped menu styles rather than
      // the class markers other test files register globally.
      const { listbox, listboxItem, popover } = useStyles();
      registerCustomStyles({
        listbox: realStyles.listbox,
        listboxItem: realStyles.listboxItem,
        popover: realStyles.popover
      });

      try {
        await render(
          <template>
            <AppLayout @defaultSidebarCollapsed={{true}} as |layout|>
              <layout.Sidebar as |sidebar|>
                <sidebar.Body>
                  <sidebar.Folder
                    @label={{long}}
                    @icon={{TestIcon}}
                    as |folder|
                  >
                    <folder.Item @href="#a" id="child-a">{{long}}</folder.Item>
                  </sidebar.Folder>
                </sidebar.Body>
              </layout.Sidebar>
              <layout.Main>Content</layout.Main>
            </AppLayout>
          </template>
        );

        await click(TRIGGER);
        const box = menu()!.getBoundingClientRect();
        assert.true(
          box.width <= 320,
          `the menu is at most 20rem wide (${box.width}px)`
        );
        // The menu row's label box (Listbox's `label` slot) does the cutting.
        const label = find('#child-a [data-part="label"]')!;
        assert.strictEqual(getComputedStyle(label).textOverflow, 'ellipsis');
        assert.true(
          label.scrollWidth > label.clientWidth,
          'the label is cut off with an ellipsis'
        );
        assert.true(
          label.getBoundingClientRect().right <= box.right,
          'the label stays inside the menu'
        );
      } finally {
        registerCustomStyles({ listbox, listboxItem, popover });
      }
    });

    test('the collapsed trigger shows only its icon, centered like other rail items', async function (assert) {
      await renderRail(new RailState());

      const label = find(`${TRIGGER} [data-part="nav-item-label"]`)!;
      assert.true(isVisiblyHidden(label), 'label is sr-only');
      assert.dom(TRIGGER).hasText('Reports', 'still names the trigger');
      assert.strictEqual(
        getComputedStyle(find(`${TRIGGER} [data-part="nav-folder-chevron"]`)!)
          .display,
        'none',
        'no chevron'
      );
      const folderIcon = find(`${TRIGGER} [data-part="nav-item-icon"]`)!;
      const plainIcon = find('#plain [data-part="nav-item-icon"]')!;
      assert.true(
        Math.abs(
          folderIcon.getBoundingClientRect().left -
            plainIcon.getBoundingClientRect().left
        ) < 1,
        'same column as a plain rail item'
      );
    });

    /** Whether the menu is what a pointer at its centre would hit. */
    function menuIsOnTop(): boolean {
      const el = menu()!;
      const rect = el.getBoundingClientRect();
      const hit = document.elementFromPoint(
        rect.left + rect.width / 2,
        rect.top + rect.height / 2
      );
      return Boolean(hit && el.contains(hit));
    }

    // A positioned block in Main covering where the menu opens.
    for (const [scrollMode, variant, side, cover] of [
      ['content', 'attached', 'start', 'relative'],
      ['page', 'attached', 'start', 'relative'],
      ['page', 'attached', 'start', 'sticky'],
      ['page', 'inset', 'start', 'relative'],
      ['page', 'attached', 'end', 'relative']
    ] as const) {
      const coverStyle = htmlSafe(
        `position: ${cover}; top: 0; height: 2000px; background: white`
      );
      test(`the open menu is on top of ${cover} content in Main (${scrollMode} scroll, ${variant}, ${side})`, async function (assert) {
        await render(
          <template>
            <AppLayout
              @defaultSidebarCollapsed={{true}}
              @scrollMode={{scrollMode}}
              @variant={{variant}}
              @sidebarSide={{side}}
              as |layout|
            >
              <layout.Sidebar as |sidebar|>
                <sidebar.Body>
                  <sidebar.Folder
                    @label="Reports"
                    @icon={{TestIcon}}
                    as |folder|
                  >
                    <folder.Item @href="#a" id="child-a">A</folder.Item>
                    <folder.Item @href="#b" id="child-b">B</folder.Item>
                  </sidebar.Folder>
                </sidebar.Body>
              </layout.Sidebar>
              <layout.Main>
                {{! template-lint-disable no-inline-styles }}
                <div id="cover" style={{coverStyle}}>Cover</div>
              </layout.Main>
            </AppLayout>
          </template>
        );

        await click(TRIGGER);

        assert.dom(MENU).isVisible();
        const box = menu()!.getBoundingClientRect();
        const coverBox = find('#cover')!.getBoundingClientRect();
        assert.true(
          box.right > coverBox.left && box.left < coverBox.right,
          'the cover overlaps the menu'
        );
        assert.true(menuIsOnTop(), 'the menu, not Main, takes the pointer');
        await click('#child-a');
        assert
          .dom(TRIGGER)
          .hasAria('expanded', 'false', 'its items are clickable');
        assert.strictEqual(
          getComputedStyle(find('[data-part="sidebar"]')!).zIndex,
          'auto',
          'the sidebar is never lifted over other overlays'
        );
      });
    }

    test('the menu opens toward the content: right of a start sidebar, left of an end one', async function (assert) {
      const state = new RailState();
      await renderRail(state);

      await click(TRIGGER);

      let trigger = find(TRIGGER)!.getBoundingClientRect();
      let box = menu()!.getBoundingClientRect();
      assert.true(
        box.left >= trigger.right - 1,
        `start: menu ${box.left} is right of trigger ${trigger.right}`
      );
      assert.true(
        Math.abs(box.top - trigger.top) < 2,
        `start: aligned with the trigger's top (${box.top} vs ${trigger.top})`
      );

      await click(TRIGGER);
      state.side = 'end';
      await settled();
      await click(TRIGGER);

      trigger = find(TRIGGER)!.getBoundingClientRect();
      box = menu()!.getBoundingClientRect();
      assert.true(
        box.right <= trigger.left + 1,
        `end: menu ${box.right} is left of trigger ${trigger.left}`
      );
    });
  }
);
