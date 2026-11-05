import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  rerender,
  find,
  click,
  focus,
  settled
} from '@ember/test-helpers';
import { tracked } from '@glimmer/tracking';
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
