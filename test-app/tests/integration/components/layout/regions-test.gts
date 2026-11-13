import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  click,
  settled,
  setupOnerror,
  resetOnerror
} from '@ember/test-helpers';
import { tracked } from '@glimmer/tracking';
import { run } from '@ember/runloop';
import {
  AppLayout,
  AppLayoutState,
  LayoutRegion,
  LayoutAside,
  breadcrumb
} from 'frontile';
import {
  mockMatchMedia,
  type MatchMediaMock
} from 'test-app/tests/helpers/match-media';
import type AppLayoutService from 'frontile/services/app-layout';

class Flags {
  @tracked target = true;
  @tracked first = true;
  @tracked second = false;
  @tracked third = false;
  @tracked label = 'Orders';
}

function targetChildren(name: string): Element[] {
  const target = document.querySelector(`[data-region="${name}"]`);
  return target ? Array.from(target.children) : [];
}

module('Integration | Layout regions | frontile/layout', function (hooks) {
  setupRenderingTest(hooks);

  let media: MatchMediaMock | undefined;

  hooks.beforeEach(function () {
    media = mockMatchMedia(1200);
  });

  hooks.afterEach(function () {
    media?.restore();
    media = undefined;
  });

  test('a source renders its block into the target with no wrapper', async function (assert) {
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Navbar><layout.Region @name="actions" /></layout.Navbar>
          <layout.Main>
            <LayoutRegion @name="actions">
              <button type="button" data-test-action>Save</button>
            </LayoutRegion>
          </layout.Main>
        </AppLayout>
      </template>
    );

    const children = targetChildren('actions');
    assert.strictEqual(children.length, 1, 'one child in the target');
    assert.ok(
      children[0]!.matches('[data-test-action]'),
      'the block itself is the child: no wrapper'
    );
    assert
      .dom('[data-part="main"] [data-test-action]')
      .doesNotExist('nothing renders where the source sits');
    assert
      .dom('[data-region="actions"]')
      .hasAttribute('data-has-content', 'true');
  });

  test('order independence: the target may mount after the source', async function (assert) {
    const flags = new Flags();
    flags.target = false;
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Navbar>
            {{#if flags.target}}<layout.Region @name="actions" />{{/if}}
          </layout.Navbar>
          <layout.Main>
            <LayoutRegion @name="actions"><b data-test-a>A</b></LayoutRegion>
          </layout.Main>
        </AppLayout>
      </template>
    );
    assert.dom('[data-test-a]').doesNotExist('no target, nothing rendered');

    flags.target = true;
    await settled();
    assert.dom('[data-region="actions"] [data-test-a]').exists();

    flags.target = false;
    await settled();
    flags.target = true;
    await settled();
    assert
      .dom('[data-region="actions"] [data-test-a]')
      .exists({ count: 1 }, 'a remounted target gets the content back, once');
  });

  test('the source may also sit before the layout in the tree', async function (assert) {
    await render(
      <template>
        <LayoutRegion @name="actions"><b
            data-test-early
          >Early</b></LayoutRegion>
        <AppLayout as |layout|>
          <layout.Navbar><layout.Region @name="actions" /></layout.Navbar>
          <layout.Main>Content</layout.Main>
        </AppLayout>
      </template>
    );
    assert.dom('[data-region="actions"] [data-test-early]').exists();
  });

  test('stacking: the most recent source wins, and an exit restores the previous', async function (assert) {
    const flags = new Flags();
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Navbar><layout.Region @name="actions" /></layout.Navbar>
          <layout.Main>
            {{#if flags.first}}
              <LayoutRegion @name="actions"><b data-test-a>A</b></LayoutRegion>
            {{/if}}
            {{#if flags.second}}
              <LayoutRegion @name="actions"><b data-test-b>B</b></LayoutRegion>
            {{/if}}
          </layout.Main>
        </AppLayout>
      </template>
    );
    assert.deepEqual(
      targetChildren('actions').map((e) => e.textContent),
      ['A']
    );

    flags.second = true;
    await settled();
    assert.deepEqual(
      targetChildren('actions').map((e) => e.textContent),
      ['B'],
      'the newer source replaces the older'
    );

    flags.second = false;
    await settled();
    assert.deepEqual(
      targetChildren('actions').map((e) => e.textContent),
      ['A'],
      'the older source comes back'
    );

    flags.first = false;
    await settled();
    assert.strictEqual(targetChildren('actions').length, 0);
    assert
      .dom('[data-region="actions"]')
      .hasAttribute('data-has-content', 'false');
  });

  test('@multiple accumulates every source in render order', async function (assert) {
    const flags = new Flags();
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Navbar>
            <layout.Region @name="actions" @multiple={{true}} />
          </layout.Navbar>
          <layout.Main>
            {{#if flags.first}}
              <LayoutRegion @name="actions"><b>A</b></LayoutRegion>
            {{/if}}
            {{#if flags.second}}
              <LayoutRegion @name="actions"><b>B</b></LayoutRegion>
            {{/if}}
          </layout.Main>
        </AppLayout>
      </template>
    );
    flags.second = true;
    await settled();
    assert.deepEqual(
      targetChildren('actions').map((e) => e.textContent),
      ['A', 'B']
    );

    flags.first = false;
    await settled();
    assert.deepEqual(
      targetChildren('actions').map((e) => e.textContent),
      ['B']
    );
  });

  test('a target renders its own block while no source fills it', async function (assert) {
    const flags = new Flags();
    flags.first = false;
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Navbar>
            <layout.Region @name="actions"><i
                data-test-fallback
              >Default</i></layout.Region>
          </layout.Navbar>
          <layout.Main>
            {{#if flags.first}}
              <LayoutRegion @name="actions"><b data-test-a>A</b></LayoutRegion>
            {{/if}}
          </layout.Main>
        </AppLayout>
      </template>
    );
    assert.dom('[data-test-fallback]').exists();

    flags.first = true;
    await settled();
    assert.dom('[data-test-fallback]').doesNotExist();
    assert.dom('[data-region="actions"] [data-test-a]').exists();
  });

  test('the service reports whether each region has content', async function (assert) {
    const flags = new Flags();
    flags.first = false;
    const service = this.owner.lookup('service:app-layout') as AppLayoutService;
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Navbar><layout.Region @name="actions" /></layout.Navbar>
          <layout.Main>
            {{#if flags.first}}
              <LayoutRegion @name="actions"><b>A</b></LayoutRegion>
            {{/if}}
          </layout.Main>
        </AppLayout>
      </template>
    );
    assert.false(service.hasContent('actions'));
    flags.first = true;
    await settled();
    assert.true(service.hasContent('actions'));
    assert.ok(service.layout, 'the mounted layout registered itself');
  });

  test('a route-driven aside: no column or toggle while nothing fills it', async function (assert) {
    const flags = new Flags();
    flags.first = false;
    const state = new AppLayoutState();
    await render(
      <template>
        <AppLayout @state={{state}} as |layout|>
          <layout.Navbar><layout.AsideToggle /></layout.Navbar>
          <layout.Main>
            {{#if flags.first}}
              <LayoutAside><p data-test-aside-body>Order details</p></LayoutAside>
            {{/if}}
          </layout.Main>
          <layout.Aside @region="aside" />
        </AppLayout>
      </template>
    );
    assert.dom('[data-part="aside-toggle"]').doesNotExist('no toggle');
    assert.dom('aside').doesNotExist('no column');

    flags.first = true;
    await settled();
    assert
      .dom('[data-part="aside-toggle"]')
      .exists('a filled aside has a toggle');
    assert.dom('aside').doesNotExist('still closed');

    await click('[data-part="aside-toggle"]');
    assert.dom('aside [data-test-aside-body]').exists('content in the column');
    assert.true(state.asideOpen);

    flags.first = false;
    await settled();
    assert.false(state.asideOpen, 'emptying the aside closes it');
    assert.dom('aside').doesNotExist();
    assert.dom('[data-part="aside-toggle"]').doesNotExist();
  });

  test('the aside stays open when another source replaces the current one', async function (assert) {
    const flags = new Flags();
    const state = new AppLayoutState({ asideOpen: true });
    await render(
      <template>
        <AppLayout @state={{state}} as |layout|>
          <layout.Main>
            {{#if flags.first}}
              <LayoutAside><p>First</p></LayoutAside>
            {{/if}}
            {{#if flags.second}}
              <LayoutAside><p>Second</p></LayoutAside>
            {{/if}}
          </layout.Main>
          <layout.Aside @region="aside" />
        </AppLayout>
      </template>
    );
    assert.dom('aside').hasText('First');
    flags.first = false;
    flags.second = true;
    await settled();
    assert.true(state.asideOpen, 'a swap in one render does not close it');
    assert.dom('aside').hasText('Second');
  });

  test('below lg the content follows the target into the drawer', async function (assert) {
    media?.setWidth(500);
    const state = new AppLayoutState();
    await render(
      <template>
        <AppLayout @state={{state}} as |layout|>
          <layout.Navbar><layout.AsideToggle /></layout.Navbar>
          <layout.Main>
            <LayoutAside><p data-test-aside-body>Order details</p></LayoutAside>
          </layout.Main>
          <layout.Aside @region="aside" />
        </AppLayout>
      </template>
    );
    await click('[data-part="aside-toggle"]');
    assert
      .dom('[role="dialog"] aside [data-test-aside-body]', document.body)
      .exists('rendered inside the drawer');

    state.asideOpen = false;
    await settled();
    media?.setWidth(1200);
    state.asideOpen = true;
    await settled();
    assert
      .dom('[data-part="aside"] [data-test-aside-body]')
      .exists('and back into the column from lg up');
    assert
      .dom('[data-test-aside-body]', document.body)
      .exists({ count: 1 }, 'never twice');
  });

  test('breadcrumbs stack in render order and pop on exit', async function (assert) {
    const flags = new Flags();
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Navbar><layout.Breadcrumbs /></layout.Navbar>
          <layout.Main>
            {{breadcrumb "Home" href="/"}}
            {{#if flags.first}}
              {{breadcrumb flags.label href="/orders"}}
              {{#if flags.second}}
                {{breadcrumb "Order 1" href="/orders/1"}}
              {{/if}}
            {{/if}}
          </layout.Main>
        </AppLayout>
      </template>
    );
    const crumbs = () =>
      Array.from(document.querySelectorAll('[data-component="breadcrumbs"] li'))
        .map((e) => e.textContent?.trim())
        .filter(Boolean);

    assert.deepEqual(crumbs(), ['Home', 'Orders']);

    flags.second = true;
    await settled();
    assert.deepEqual(crumbs(), ['Home', 'Orders', 'Order 1']);

    flags.label = 'All orders';
    await settled();
    assert.deepEqual(
      crumbs(),
      ['Home', 'All orders', 'Order 1'],
      'an updated crumb keeps its place'
    );

    flags.first = false;
    await settled();
    assert.deepEqual(crumbs(), ['Home']);
  });

  test('the deferred fill lands in the same runloop, before the browser can paint', async function (assert) {
    const flags = new Flags();
    flags.first = false;
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Navbar><layout.Region @name="actions" /></layout.Navbar>
          <layout.Main>
            {{#if flags.first}}
              <LayoutRegion @name="actions"><b data-test-a>A</b></LayoutRegion>
            {{/if}}
          </layout.Main>
        </AppLayout>
      </template>
    );
    run(() => {
      flags.first = true;
    });
    // Still synchronous: no task boundary, so no paint, has happened since
    // the render that created the source.
    assert
      .dom('[data-region="actions"] [data-test-a]')
      .exists('filled by the time the runloop returns');
  });

  test('writing a region synchronously during render trips the backtracking assertion', async function (assert) {
    const service = this.owner.lookup('service:app-layout') as AppLayoutService;
    service.syncWritesForTesting = true;
    let error: unknown;
    setupOnerror((e: unknown) => {
      error ??= e;
    });
    try {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Navbar><layout.Region @name="actions" /></layout.Navbar>
            <layout.Main>
              <LayoutRegion @name="actions"><b>A</b></LayoutRegion>
            </layout.Main>
          </AppLayout>
        </template>
      );
    } catch (e) {
      error ??= e;
    } finally {
      resetOnerror();
    }
    assert.ok(
      /You attempted to update `sources`/.test(String(error)),
      `got: ${String(error)}`
    );
  });
});
