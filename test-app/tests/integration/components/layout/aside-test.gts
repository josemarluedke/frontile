import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  find,
  click,
  settled,
  triggerKeyEvent
} from '@ember/test-helpers';
import { AppLayout, AppLayoutState } from 'frontile';
import {
  mockMatchMedia,
  type MatchMediaMock
} from 'test-app/tests/helpers/match-media';

const MOBILE = 500;
const DESKTOP = 1200;

function width(selector: string): number {
  return find(selector)!.getBoundingClientRect().width;
}

module('Integration | Component | Aside | frontile/layout', function (hooks) {
  setupRenderingTest(hooks);

  let media: MatchMediaMock | undefined;

  hooks.afterEach(function () {
    media?.restore();
    media = undefined;
  });

  test('renders in flow beside Main from lg up and narrows it', async function (assert) {
    media = mockMatchMedia(DESKTOP);
    const state = new AppLayoutState();
    await render(
      <template>
        <AppLayout @state={{state}} as |layout|>
          <layout.Navbar>Nav</layout.Navbar>
          <layout.Main>Content</layout.Main>
          <layout.Aside>Details here</layout.Aside>
        </AppLayout>
      </template>
    );

    assert.dom('[data-part="aside"]').doesNotExist('closed: nothing rendered');
    const closedWidth = width('main');

    state.asideOpen = true;
    await settled();

    assert.dom('[data-part="aside"]').exists({ count: 1 });
    assert.dom('[role="dialog"]').doesNotExist('no drawer at lg and up');
    const aside = find('[data-part="aside"]')!.getBoundingClientRect();
    const main = find('main')!.getBoundingClientRect();
    assert.true(
      aside.left >= main.right - 0.5,
      'aside is beside Main, after it'
    );
    assert.true(main.width < closedWidth - 100, 'Main narrows when it opens');
    assert.true(
      aside.right <=
        find('[data-part="main-card"]')!.getBoundingClientRect().right + 0.5,
      'inside the card'
    );
  });

  test('below lg it renders in a right Drawer, once', async function (assert) {
    media = mockMatchMedia(MOBILE);
    const state = new AppLayoutState({ asideOpen: true });
    await render(
      <template>
        <AppLayout @state={{state}} as |layout|>
          <layout.Main>Content</layout.Main>
          <layout.Aside><span id="payload">Details</span></layout.Aside>
        </AppLayout>
      </template>
    );

    assert.dom('[role="dialog"]').exists({ count: 1 });
    assert.dom('[data-part="aside"]').doesNotExist('no inline copy');
    assert.dom('#payload').exists({ count: 1 }, 'content rendered once');
    const names = [...find('[role="dialog"]')!.classList];
    assert.true(
      names.some((n) => n.includes('right')) &&
        !names.some((n) => n.includes('left')),
      'placed right'
    );
    assert.dom('[role="dialog"] aside').exists({ count: 1 });
  });

  test('narrowing below lg closes an open aside instead of popping a drawer', async function (assert) {
    media = mockMatchMedia(DESKTOP);
    const changes: boolean[] = [];
    const onChange = (value: boolean) => changes.push(value);
    await render(
      <template>
        <AppLayout
          @defaultAsideOpen={{true}}
          @onAsideOpenChange={{onChange}}
          as |layout|
        >
          <layout.Navbar><layout.AsideToggle /></layout.Navbar>
          <layout.Main>Content</layout.Main>
          <layout.Aside><span class="payload">Details</span></layout.Aside>
        </AppLayout>
      </template>
    );
    assert.dom('[data-part="aside"]').exists();

    media.setWidth(MOBILE);
    await settled();
    assert.dom('[data-part="aside"]').doesNotExist();
    assert.dom('[role="dialog"]').doesNotExist('no drawer opens by itself');
    assert
      .dom('[data-component="app-layout"]')
      .hasAttribute('data-aside-open', 'false');
    assert.deepEqual(changes, [false]);

    await click('[data-part="aside-toggle"]');
    assert
      .dom('[role="dialog"] .payload')
      .exists({ count: 1 }, 'the toggle still opens the drawer below lg');

    await triggerKeyEvent('[role="dialog"]', 'keydown', 'Escape');
    media.setWidth(DESKTOP);
    await settled();
    assert
      .dom('[data-part="aside"]')
      .doesNotExist('stays closed when widening');
    await click('[data-part="aside-toggle"]');
    assert.dom('[data-part="aside"] .payload').exists({ count: 1 });
    assert.dom('[role="dialog"]').doesNotExist();
  });

  test('the aside breakpoint is lg whatever @breakpoint is', async function (assert) {
    media = mockMatchMedia(800);
    const state = new AppLayoutState({ asideOpen: true });
    await render(
      <template>
        <AppLayout @state={{state}} @breakpoint="sm" as |layout|>
          <layout.Main>Content</layout.Main>
          <layout.Aside>Details</layout.Aside>
        </AppLayout>
      </template>
    );
    assert.dom('[role="dialog"] aside').exists('800px is below lg');
  });

  test('AsideToggle toggles asideOpen with aria-expanded', async function (assert) {
    media = mockMatchMedia(DESKTOP);
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Navbar>
            <layout.AsideToggle />
          </layout.Navbar>
          <layout.Main>Content</layout.Main>
          <layout.Aside>Details</layout.Aside>
        </AppLayout>
      </template>
    );

    const toggle = '[data-part="aside-toggle"]';
    assert.dom(toggle).hasAria('label', 'Toggle details');
    assert.dom(toggle).hasAria('expanded', 'false');
    await click(toggle);
    assert.dom(toggle).hasAria('expanded', 'true');
    assert
      .dom('[data-component="app-layout"]')
      .hasAttribute('data-aside-open', 'true');
    assert.dom('[data-part="aside"]').exists();
    assert
      .dom(toggle)
      .hasAttribute('aria-controls', find('[data-part="aside"]')!.id);
    await click(toggle);
    assert.dom(toggle).hasAria('expanded', 'false');
    assert.dom('[data-part="aside"]').doesNotExist();
  });

  test('has the aside landmark, named by @label (default Details)', async function (assert) {
    media = mockMatchMedia(DESKTOP);
    await render(
      <template>
        <AppLayout @defaultAsideOpen={{true}} as |layout|>
          <layout.Main>Content</layout.Main>
          <layout.Aside>Details</layout.Aside>
        </AppLayout>
      </template>
    );
    assert.dom('aside').hasAria('label', 'Details');

    await render(
      <template>
        <AppLayout @defaultAsideOpen={{true}} as |layout|>
          <layout.Main>Content</layout.Main>
          <layout.Aside @label="Filters">Details</layout.Aside>
        </AppLayout>
      </template>
    );
    assert.dom('aside').hasAria('label', 'Filters');
  });

  test('the drawer has an aside landmark and a name', async function (assert) {
    media = mockMatchMedia(MOBILE);
    await render(
      <template>
        <AppLayout @defaultAsideOpen={{true}} as |layout|>
          <layout.Main>Content</layout.Main>
          <layout.Aside @label="Filters">Details</layout.Aside>
        </AppLayout>
      </template>
    );
    assert.dom('[role="dialog"]').hasAria('label', 'Filters');
    assert.dom('[role="dialog"] aside').hasAria('label', 'Filters');
  });

  test('closing the drawer with Escape sets asideOpen false', async function (assert) {
    media = mockMatchMedia(MOBILE);
    const state = new AppLayoutState({ asideOpen: true });
    await render(
      <template>
        <AppLayout @state={{state}} as |layout|>
          <layout.Main>Content</layout.Main>
          <layout.Aside><button type="button" id="in">x</button></layout.Aside>
        </AppLayout>
      </template>
    );
    assert.dom('[role="dialog"]').exists();
    await triggerKeyEvent('#in', 'keydown', 'Escape');

    assert.false(state.asideOpen);
    assert.dom('[role="dialog"]').doesNotExist();
  });

  test('closing the drawer by its backdrop sets asideOpen false', async function (assert) {
    media = mockMatchMedia(MOBILE);
    const state = new AppLayoutState({ asideOpen: true });
    await render(
      <template>
        <AppLayout @state={{state}} as |layout|>
          <layout.Main>Content</layout.Main>
          <layout.Aside>Details</layout.Aside>
        </AppLayout>
      </template>
    );
    await click('.overlay__backdrop');
    assert.false(state.asideOpen);
  });

  test('the drawer toggle returns focus to AsideToggle on close', async function (assert) {
    media = mockMatchMedia(MOBILE);
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Navbar>
            <layout.AsideToggle class="lg:inline-flex" />
          </layout.Navbar>
          <layout.Main>Content</layout.Main>
          <layout.Aside><button type="button" id="in">x</button></layout.Aside>
        </AppLayout>
      </template>
    );
    await click('[data-part="aside-toggle"]');
    assert.dom('[role="dialog"]').exists();
    await triggerKeyEvent('#in', 'keydown', 'Escape');

    assert.dom('[data-part="aside-toggle"]').isFocused();
  });

  test('sidebarSide=end keeps the aside on the opposite (start) side', async function (assert) {
    media = mockMatchMedia(DESKTOP);
    await render(
      <template>
        <AppLayout @sidebarSide="end" @defaultAsideOpen={{true}} as |layout|>
          <layout.Navbar>Nav</layout.Navbar>
          <layout.Sidebar />
          <layout.Main>Content</layout.Main>
          <layout.Aside>Details</layout.Aside>
        </AppLayout>
      </template>
    );
    const aside = find('[data-part="aside"]')!.getBoundingClientRect();
    const main = find('main')!.getBoundingClientRect();
    const sidebar = find('[data-part="sidebar"]')!.getBoundingClientRect();
    const card = find('[data-part="main-card"]')!.getBoundingClientRect();
    assert.true(aside.right <= main.left + 0.5, 'aside before Main');
    assert.true(main.right <= sidebar.left + 0.5, 'sidebar after Main');
    assert.true(aside.left >= card.left - 0.5, 'aside inside the card');
    const header = find('header')!.getBoundingClientRect();
    assert.true(header.left <= aside.left + 0.5, 'navbar spans over the aside');
    assert.true(
      header.right <= sidebar.left + 0.5,
      'navbar stops at the sidebar'
    );
  });
});
