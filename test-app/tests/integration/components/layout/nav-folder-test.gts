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
import { AppLayout, NavFolder } from 'frontile';
import { setPrefersReducedMotion } from 'frontile/test-support';
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
  }
);

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

const FLYOUT = '[data-part="nav-folder-flyout"]';

/** True for a box shrunk to (at most) a pixel: the sr-only technique. */
function isVisiblyHidden(el: Element): boolean {
  const rect = el.getBoundingClientRect();
  return rect.width <= 1 && rect.height <= 1;
}

// Matches the platform check in AppLayout: Cmd on Apple platforms, else Ctrl.
function modKeys(): { metaKey: boolean; ctrlKey: boolean } {
  const nav = navigator as Navigator & {
    userAgentData?: { platform?: string };
  };
  const platform = nav.userAgentData?.platform || nav.platform || '';
  const apple = /mac|iphone|ipad|ipod/i.test(platform);
  return { metaKey: apple, ctrlKey: !apple };
}

class RailState {
  @tracked active = false;
  @tracked side: 'start' | 'end' = 'start';
}

module(
  'Integration | Component | NavFolder flyout in the icon rail | frontile/layout',
  function (hooks) {
    setupRenderingTest(hooks);

    let media: MatchMediaMock | undefined;

    hooks.beforeEach(function () {
      media = mockMatchMedia(1200);
    });

    hooks.afterEach(function () {
      media?.restore();
      media = undefined;
    });

    async function renderRail(
      state: RailState,
      options: { collapsed?: boolean; defaultOpen?: boolean } = {}
    ): Promise<void> {
      const collapsed = options.collapsed ?? true;
      const defaultOpen = options.defaultOpen ?? false;
      await render(
        <template>
          <AppLayout
            @defaultSidebarCollapsed={{collapsed}}
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
                  <folder.Item @href="#a" id="child-a">A</folder.Item>
                  <folder.Item
                    @href="#b"
                    @isActive={{state.active}}
                    id="child-b"
                  >B</folder.Item>
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

    test('in a collapsed sidebar the folder opens a flyout instead of an inline panel', async function (assert) {
      await renderRail(new RailState());

      assert.dom(PANEL).doesNotExist('no inline panel in the rail');
      const trigger = find(TRIGGER)!;
      const flyout = find(FLYOUT)!;
      assert.ok(flyout, 'the flyout is rendered');
      assert.ok(flyout.id, 'the flyout has an id');
      assert.dom(flyout).hasAttribute('role', 'group');
      assert.dom(flyout).hasAttribute('aria-labelledby', trigger.id);
      assert.dom(flyout).hasAttribute('class');
      assert.dom(flyout).isNotVisible('closed until opened');
      assert.dom(trigger).hasAria('expanded', 'false');
      assert.dom(trigger).hasAria('controls', flyout.id);
      assert.dom(ROOT).hasAttribute('data-component', 'nav-folder');

      await click(trigger);
      assert.dom(trigger).hasAria('expanded', 'true');
      assert.dom(trigger).hasAttribute('data-open', 'true');
      assert.dom(trigger).hasAria('controls', flyout.id);
      assert.dom(flyout).isVisible();
      assert.dom(`${FLYOUT} #child-a`).isVisible();
      assert.dom(`${FLYOUT} #child-b`).isVisible();
      assert.dom(PANEL).doesNotExist();

      await click(trigger);
      assert.dom(trigger).hasAria('expanded', 'false', 'the trigger toggles');
      assert.dom(flyout).isNotVisible();
    });

    test('in the rail a folder holding the current page is active while its flyout is closed', async function (assert) {
      const state = new RailState();
      state.active = true;
      await renderRail(state);

      assert.dom(TRIGGER).hasAttribute('data-active', 'true');
      assert.dom(TRIGGER).hasAria('expanded', 'false', 'no flyout on load');
      assert.dom(TRIGGER).doesNotHaveAttribute('aria-current');
      assert.dom(FLYOUT).isNotVisible();
      assert.dom('#child-b').isNotVisible('not reachable until opened');
      assert.strictEqual(
        document.querySelectorAll('#child-b').length,
        1,
        'each child is rendered once'
      );
      assert.strictEqual(
        document.querySelectorAll('[aria-current="page"]').length,
        1,
        'one current-page link'
      );

      state.active = false;
      await settled();
      assert.dom(TRIGGER).hasAttribute('data-active', 'false');

      await click(TRIGGER);
      assert.dom('#child-b').isVisible('reachable once opened');
    });

    test('in the rail a newly active child does not pop the flyout open, but opens the inline state', async function (assert) {
      const state = new RailState();
      await renderRail(state);

      state.active = true;
      await settled();
      assert.dom(TRIGGER).hasAttribute('data-active', 'true');
      assert.dom(TRIGGER).hasAria('expanded', 'false');
      assert.dom(FLYOUT).isNotVisible();

      await click('[data-part="sidebar-toggle"]');
      assert.dom(PANEL).exists('expanded: inline again');
      assert
        .dom(TRIGGER)
        .hasAria(
          'expanded',
          'true',
          'the auto-open landed on the inline state'
        );
    });

    test('Escape closes the flyout and focuses the trigger', async function (assert) {
      await renderRail(new RailState());

      await click(TRIGGER);
      await focus('#child-a');
      await triggerKeyEvent('#child-a', 'keydown', 'Escape');
      assert.dom(TRIGGER).hasAria('expanded', 'false');
      assert.dom(FLYOUT).isNotVisible();
      assert.dom(TRIGGER).isFocused();

      await click(TRIGGER);
      await triggerKeyEvent(TRIGGER, 'keydown', 'Escape');
      assert.dom(TRIGGER).hasAria('expanded', 'false', 'from the trigger too');
      assert.dom(TRIGGER).isFocused();
    });

    test('clicking a flyout item closes the flyout', async function (assert) {
      await renderRail(new RailState());

      await click(TRIGGER);
      await click('#child-a');
      assert.dom(TRIGGER).hasAria('expanded', 'false');
      assert.dom(FLYOUT).isNotVisible();
    });

    test('clicking outside or tabbing out closes the flyout', async function (assert) {
      await renderRail(new RailState());

      await click(TRIGGER);
      await click('#outside');
      assert.dom(TRIGGER).hasAria('expanded', 'false', 'outside click');

      await click(TRIGGER);
      await click(FLYOUT);
      assert
        .dom(TRIGGER)
        .hasAria('expanded', 'true', 'a click inside keeps it');

      await triggerEvent('#child-b', 'focusout', {
        relatedTarget: find('#after')
      });
      assert.dom(TRIGGER).hasAria('expanded', 'false', 'focus left the folder');

      await click(TRIGGER);
      await triggerEvent(TRIGGER, 'focusout', {
        relatedTarget: find('#child-a')
      });
      assert
        .dom(TRIGGER)
        .hasAria('expanded', 'true', 'moving into the flyout keeps it');
    });

    test('the trigger is a disclosure, not a menu button', async function (assert) {
      await renderRail(new RailState());

      assert.dom(TRIGGER).doesNotHaveAttribute('aria-haspopup');
      assert.dom(FLYOUT).hasAttribute('role', 'group', 'not a menu');
      assert.dom(`${FLYOUT} [role="menuitem"]`).doesNotExist();
    });

    test('expanding the sidebar while the flyout is open closes it and keeps the inline state', async function (assert) {
      await renderRail(new RailState());

      await click(TRIGGER);
      assert.dom(TRIGGER).hasAria('expanded', 'true');

      // The keyboard shortcut collapses without a click outside the folder.
      await triggerKeyEvent(TRIGGER, 'keydown', 'B', modKeys());
      assert.dom(FLYOUT).doesNotExist('no flyout outside the rail');
      assert.dom(PANEL).exists();
      assert.dom(TRIGGER).hasAria('expanded', 'false', 'inline state: closed');
      assert.dom(TRIGGER).hasAria('controls', find(PANEL)!.id);

      await click('[data-part="sidebar-toggle"]');
      assert.dom(FLYOUT).isNotVisible('the flyout starts closed again');
      assert.dom(TRIGGER).hasAria('expanded', 'false');
    });

    test('expanding the sidebar with focus in the flyout moves focus to the trigger', async function (assert) {
      await renderRail(new RailState());

      await click(TRIGGER);
      await focus('#child-a');
      assert.dom('#child-a').isFocused();

      // The documented shortcut, pressed from inside the flyout.
      await triggerKeyEvent('#child-a', 'keydown', 'B', modKeys());
      assert.dom(FLYOUT).doesNotExist('the rail expanded');
      assert.dom(TRIGGER).isFocused('focus did not fall to <body>');
      assert.dom(TRIGGER).hasAria('expanded', 'false', 'inline: still closed');
    });

    test('expanding the sidebar with focus outside the flyout leaves focus alone', async function (assert) {
      await renderRail(new RailState());

      await click(TRIGGER);
      await focus('#plain');
      await triggerKeyEvent('#plain', 'keydown', 'B', modKeys());
      assert.dom(FLYOUT).doesNotExist('the rail expanded');
      assert.dom('#plain').isFocused('focus stays where it was');

      // Focus once in the flyout, then moved out, is not "in the flyout".
      await click('[data-part="sidebar-toggle"]');
      await click(TRIGGER);
      await focus('#child-a');
      await focus('#outside');
      await triggerKeyEvent('#outside', 'keydown', 'B', modKeys());
      assert.dom('#outside').isFocused('not pulled back to the trigger');
    });

    test('data-active and a user-closed inline state survive collapse/expand cycles', async function (assert) {
      const state = new RailState();
      state.active = true;
      await renderRail(state, { collapsed: false });

      assert.dom(TRIGGER).hasAttribute('data-active', 'true', 'inline');
      assert.dom(TRIGGER).hasAria('expanded', 'true', 'auto-opened');

      await click(TRIGGER);
      assert.dom(TRIGGER).hasAria('expanded', 'false', 'the user closed it');

      await click('[data-part="sidebar-toggle"]');
      assert.dom(FLYOUT).exists('rail');
      assert.dom(TRIGGER).hasAttribute('data-active', 'true', 'rail');

      await click('[data-part="sidebar-toggle"]');
      assert.dom(PANEL).exists('inline again');
      assert.dom(TRIGGER).hasAttribute('data-active', 'true', 'inline again');
      assert
        .dom(TRIGGER)
        .hasAria('expanded', 'false', 'the user-closed folder stays closed');

      await click('[data-part="sidebar-toggle"]');
      await click('[data-part="sidebar-toggle"]');
      assert.dom(TRIGGER).hasAttribute('data-active', 'true', 'second cycle');
      assert.dom(TRIGGER).hasAria('expanded', 'false', 'still closed');
    });

    test('the inline open state survives the flyout and collapse cycles', async function (assert) {
      await renderRail(new RailState(), {
        collapsed: false,
        defaultOpen: true
      });

      assert.dom(TRIGGER).hasAria('expanded', 'true', 'inline: open');

      await click('[data-part="sidebar-toggle"]');
      assert.dom(PANEL).doesNotExist('collapsing hides the inline panel');
      assert.dom(TRIGGER).hasAria('expanded', 'false', 'the flyout is closed');

      await click(TRIGGER);
      await click(TRIGGER);
      await click('[data-part="sidebar-toggle"]');
      assert.dom(TRIGGER).hasAria('expanded', 'true', 'inline: still open');
      assert.dom(`${PANEL} #child-a`).isVisible();

      await click(TRIGGER);
      assert.dom(TRIGGER).hasAria('expanded', 'false', 'inline: closed');
      await click('[data-part="sidebar-toggle"]');
      await click(TRIGGER);
      assert.dom(TRIGGER).hasAria('expanded', 'true', 'flyout open');
      await click('[data-part="sidebar-toggle"]');
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
      assert.dom(FLYOUT).doesNotExist();
      assert.dom(PANEL).exists();

      await click(TRIGGER);
      assert.dom(TRIGGER).hasAria('expanded', 'true');
      assert.dom(`${PANEL} #child-a`).isVisible();
      assert.dom(FLYOUT).doesNotExist();
    });

    test('flyout items show their labels, sensibly padded, with no tooltip', async function (assert) {
      await renderRail(new RailState());

      await click(TRIGGER);
      const item = find('#child-a')!;
      const label = item.querySelector('[data-part="nav-item-label"]')!;
      assert.false(isVisiblyHidden(label), 'the label is visible');
      assert.notStrictEqual(getComputedStyle(label).position, 'absolute');
      const style = getComputedStyle(item);
      assert.strictEqual(
        style.paddingInlineStart,
        style.paddingInlineEnd,
        'no rail-centering inset'
      );

      await triggerEvent(item, 'mouseenter');
      await focus(item);
      assert.dom('[role="tooltip"]').doesNotExist('no rail tooltip');
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

    /** Whether the flyout is what a pointer at its centre would hit. */
    function flyoutIsOnTop(): boolean {
      const flyout = find(FLYOUT)!;
      const rect = flyout.getBoundingClientRect();
      const hit = document.elementFromPoint(
        rect.left + rect.width / 2,
        rect.top + rect.height / 2
      );
      return Boolean(hit && flyout.contains(hit));
    }

    // A positioned block in Main covering where the flyout opens: in page
    // scroll mode the sticky sidebar is a stacking context, so a later
    // positioned sibling paints over the flyout unless the sidebar is lifted.
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
      test(`the open flyout is on top of ${cover} content in Main (${scrollMode} scroll, ${variant}, ${side})`, async function (assert) {
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

        assert.dom(FLYOUT).isVisible();
        const flyout = find(FLYOUT)!.getBoundingClientRect();
        const cover = find('#cover')!.getBoundingClientRect();
        assert.true(
          side === 'start'
            ? flyout.right > cover.left && flyout.left < cover.right
            : flyout.left < cover.right && flyout.right > cover.left,
          'the cover overlaps the flyout'
        );
        assert.true(flyoutIsOnTop(), 'the flyout, not Main, takes the pointer');
        await click('#child-a');
        assert
          .dom(TRIGGER)
          .hasAria('expanded', 'false', 'its items are clickable');
        // Lifted only while the flyout is open: overlays (Modal, Drawer,
        // Popover, Tooltip) have no z-index of their own and rely on coming
        // later in the DOM, so a sidebar lifted for good would cover them.
        assert.strictEqual(
          getComputedStyle(find('[data-part="sidebar"]')!).zIndex,
          'auto',
          'the sidebar is not lifted while the flyout is closed'
        );
      });
    }

    test('the flyout opens toward the content: right of a start sidebar, left of an end one', async function (assert) {
      const state = new RailState();
      await renderRail(state);

      await click(TRIGGER);

      let trigger = find(TRIGGER)!.getBoundingClientRect();
      let flyout = find(FLYOUT)!.getBoundingClientRect();
      assert.true(
        flyout.left >= trigger.right - 1,
        `start: flyout ${flyout.left} is right of trigger ${trigger.right}`
      );

      await click(TRIGGER);
      state.side = 'end';
      await settled();
      await click(TRIGGER);

      trigger = find(TRIGGER)!.getBoundingClientRect();
      flyout = find(FLYOUT)!.getBoundingClientRect();
      assert.true(
        flyout.right <= trigger.left + 1,
        `end: flyout ${flyout.right} is left of trigger ${trigger.left}`
      );
    });
  }
);
