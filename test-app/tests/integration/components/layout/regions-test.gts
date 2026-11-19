import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, settled, click } from '@ember/test-helpers';
import { tracked } from '@glimmer/tracking';
import { run } from '@ember/runloop';
import { registerWarnHandler } from '@ember/debug';
import { AppLayout, AppLayoutState, Aside, InLayoutRegion } from 'frontile';
import {
  mockMatchMedia,
  type MatchMediaMock
} from 'test-app/tests/helpers/match-media';

const DESKTOP = 1200;
const MOBILE = 500;

class Flags {
  @tracked layout = true;
  @tracked target = true;
  @tracked first = true;
  @tracked second = false;
}

function targetChildren(name: string): Element[] {
  const target = document.querySelector(`[data-region="${name}"]`);
  return target ? Array.from(target.children) : [];
}

function targetText(name: string): (string | null)[] {
  return targetChildren(name).map((element) => element.textContent);
}

module('Integration | Layout regions | frontile/layout', function (hooks) {
  setupRenderingTest(hooks);

  let media: MatchMediaMock | undefined;

  let warnings: string[] = [];
  let collecting = false;

  // Handlers cannot be unregistered, so this one is installed once and
  // only records while a test of this module runs.
  registerWarnHandler((message, options, next) => {
    if (collecting && options?.id?.startsWith('frontile.layout-region.')) {
      warnings.push(`${options.id}: ${message}`);
      return;
    }
    next(message, options);
  });

  hooks.beforeEach(function () {
    media = mockMatchMedia(DESKTOP);
    warnings = [];
    collecting = true;
  });

  hooks.afterEach(function () {
    media?.restore();
    media = undefined;
    collecting = false;
  });

  test('a source renders its block into the target with no wrapper', async function (assert) {
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Navbar><layout.Region @name="actions" /></layout.Navbar>
          <layout.Main>
            <InLayoutRegion @name="actions">
              <button type="button" data-test-action>Save</button>
            </InLayoutRegion>
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
            <InLayoutRegion @name="actions"><b
                data-test-a
              >A</b></InLayoutRegion>
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
        <InLayoutRegion @name="actions"><b
            data-test-early
          >Early</b></InLayoutRegion>
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
              <InLayoutRegion @name="actions"><b>A</b></InLayoutRegion>
            {{/if}}
            {{#if flags.second}}
              <InLayoutRegion @name="actions"><b>B</b></InLayoutRegion>
            {{/if}}
          </layout.Main>
        </AppLayout>
      </template>
    );
    assert.deepEqual(targetText('actions'), ['A']);

    flags.second = true;
    await settled();
    assert.deepEqual(
      targetText('actions'),
      ['B'],
      'the newer source replaces the older'
    );

    flags.second = false;
    await settled();
    assert.deepEqual(targetText('actions'), ['A'], 'the older source is back');

    flags.first = false;
    await settled();
    assert.strictEqual(targetChildren('actions').length, 0);
  });

  test('a source rendered after another covers it, whatever their nesting', async function (assert) {
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Navbar><layout.Region @name="actions" /></layout.Navbar>
          <layout.Main>
            <InLayoutRegion @name="actions"><b>Child</b></InLayoutRegion>
            <InLayoutRegion @name="actions"><b>Parent</b></InLayoutRegion>
          </layout.Main>
        </AppLayout>
      </template>
    );
    assert.deepEqual(
      targetText('actions'),
      ['Parent'],
      'a parent source placed after its child wins'
    );
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
              <InLayoutRegion @name="actions"><b>A</b></InLayoutRegion>
            {{/if}}
            {{#if flags.second}}
              <InLayoutRegion @name="actions"><b>B</b></InLayoutRegion>
            {{/if}}
          </layout.Main>
        </AppLayout>
      </template>
    );
    flags.second = true;
    await settled();
    assert.deepEqual(targetText('actions'), ['A', 'B']);

    flags.first = false;
    await settled();
    assert.deepEqual(targetText('actions'), ['B']);
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
              <InLayoutRegion @name="actions"><b
                  data-test-a
                >A</b></InLayoutRegion>
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

    flags.first = false;
    await settled();
    assert.dom('[data-test-fallback]').exists('back when emptied');
  });

  test('data-has-content reflects whether a source fills the region', async function (assert) {
    const flags = new Flags();
    flags.first = false;
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Navbar><layout.Region @name="actions" /></layout.Navbar>
          <layout.Main>
            {{#if flags.first}}
              <InLayoutRegion @name="actions"><b>A</b></InLayoutRegion>
            {{/if}}
          </layout.Main>
        </AppLayout>
      </template>
    );
    assert
      .dom('[data-region="actions"]')
      .hasAttribute('data-has-content', 'false');

    flags.first = true;
    await settled();
    assert
      .dom('[data-region="actions"]')
      .hasAttribute('data-has-content', 'true');
  });

  test('the deferred fill lands in the same runloop', async function (assert) {
    const flags = new Flags();
    flags.first = false;
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Navbar><layout.Region @name="actions" /></layout.Navbar>
          <layout.Main>
            {{#if flags.first}}
              <InLayoutRegion @name="actions"><b
                  data-test-a
                >A</b></InLayoutRegion>
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

  test('tearing down the layout and its sources together does not throw', async function (assert) {
    const flags = new Flags();
    await render(
      <template>
        {{#if flags.layout}}
          <AppLayout as |layout|>
            <layout.Navbar><layout.Region @name="actions" /></layout.Navbar>
            <layout.Main>
              <InLayoutRegion @name="actions"><b
                  data-test-a
                >A</b></InLayoutRegion>
            </layout.Main>
          </AppLayout>
        {{/if}}
      </template>
    );
    assert.dom('[data-region="actions"] [data-test-a]').exists();

    flags.layout = false;
    await settled();
    assert.dom('[data-region="actions"]').doesNotExist();
    assert.dom('[data-test-a]').doesNotExist();

    flags.layout = true;
    await settled();
    assert
      .dom('[data-region="actions"] [data-test-a]')
      .exists({ count: 1 }, 'and a fresh mount fills again');
  });

  test('warns once when a source names a region nothing declares', async function (assert) {
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Navbar><layout.Region @name="actions" /></layout.Navbar>
          <layout.Main>
            <InLayoutRegion @name="actoins"><b>A</b></InLayoutRegion>
            <InLayoutRegion @name="actoins"><b>B</b></InLayoutRegion>
          </layout.Main>
        </AppLayout>
      </template>
    );
    assert.strictEqual(warnings.length, 1, 'one warning for the name');
    assert.ok(
      warnings[0]?.startsWith('frontile.layout-region.undeclared:'),
      warnings[0]
    );
    assert.ok(warnings[0]?.includes('"actoins"'), 'it names the region');
  });

  test('does not warn when the target is declared in the same render, in any order', async function (assert) {
    await render(
      <template>
        <InLayoutRegion @name="actions"><b>Early</b></InLayoutRegion>
        <AppLayout as |layout|>
          <layout.Navbar><layout.Region @name="actions" /></layout.Navbar>
          <layout.Main>Content</layout.Main>
        </AppLayout>
      </template>
    );
    assert.deepEqual(warnings, []);
  });

  test('warns when a second live target registers for the same name', async function (assert) {
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Navbar>
            <layout.Region @name="actions" data-test-first />
            <layout.Region @name="actions" data-test-second />
          </layout.Navbar>
          <layout.Main>
            <InLayoutRegion @name="actions"><b
                data-test-a
              >A</b></InLayoutRegion>
          </layout.Main>
        </AppLayout>
      </template>
    );
    assert.strictEqual(warnings.length, 1);
    assert.ok(
      warnings[0]?.startsWith('frontile.layout-region.duplicate-target:'),
      warnings[0]
    );
    assert.dom('[data-test-second] [data-test-a]').exists('the newest wins');
  });

  test('a remounted target raises no duplicate-target warning', async function (assert) {
    const flags = new Flags();
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Navbar>
            {{#if flags.target}}<layout.Region @name="actions" />{{/if}}
          </layout.Navbar>
          <layout.Main>
            <InLayoutRegion @name="actions"><b>A</b></InLayoutRegion>
          </layout.Main>
        </AppLayout>
      </template>
    );
    flags.target = false;
    await settled();
    flags.target = true;
    await settled();
    assert.deepEqual(warnings, []);
  });

  test('a route-driven aside: no column or toggle while nothing fills it', async function (assert) {
    const flags = new Flags();
    flags.first = false;
    await render(
      <template>
        <AppLayout @defaultAsideOpen={{true}} as |layout|>
          <layout.Navbar><layout.AsideToggle /></layout.Navbar>
          <layout.Main>
            {{#if flags.first}}
              <InLayoutRegion @name="aside"><p
                  data-test-aside-body
                >Order</p></InLayoutRegion>
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
    assert.dom('[data-part="aside-toggle"]').exists('a filled aside has one');
    assert.dom('[data-part="aside"]').exists('and its column');
    assert.strictEqual(
      document.querySelector('[data-test-aside-body]')?.parentElement,
      document.querySelector('[data-part="aside"]'),
      'the content sits directly in the aside element'
    );
  });

  test('the aside stays open when another source replaces the current one', async function (assert) {
    const flags = new Flags();
    const state = new AppLayoutState({ asideOpen: true });
    await render(
      <template>
        <AppLayout @state={{state}} as |layout|>
          <layout.Main>
            {{#if flags.first}}
              <InLayoutRegion @name="aside"><p>First</p></InLayoutRegion>
            {{/if}}
            {{#if flags.second}}
              <InLayoutRegion @name="aside"><p>Second</p></InLayoutRegion>
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
    const state = new AppLayoutState({ asideOpen: true });
    await render(
      <template>
        <AppLayout @state={{state}} as |layout|>
          <layout.Navbar><layout.AsideToggle /></layout.Navbar>
          <layout.Main>
            <InLayoutRegion @name="aside"><p
                data-test-aside-body
              >Order</p></InLayoutRegion>
          </layout.Main>
          <layout.Aside @region="aside" />
        </AppLayout>
      </template>
    );
    assert.dom('[data-part="aside"] [data-test-aside-body]').exists();
    assert
      .dom('[data-test-aside-body]', document.body)
      .exists({ count: 1 }, 'once, in the column');

    media?.setWidth(MOBILE);
    await settled();
    state.asideOpen = true;
    await settled();
    assert
      .dom(
        '[role="dialog"] [data-part="mobile-aside"] [data-test-aside-body]',
        document.body
      )
      .exists('rendered inside the drawer');
    assert
      .dom('[data-test-aside-body]', document.body)
      .exists({ count: 1 }, 'once, in the drawer');

    state.asideOpen = false;
    await settled();
    media?.setWidth(DESKTOP);
    await settled();
    state.asideOpen = true;
    await settled();
    assert
      .dom('[data-part="aside"] [data-test-aside-body]')
      .exists('and back into the column from lg up');
    assert
      .dom('[data-test-aside-body]', document.body)
      .exists({ count: 1 }, 'never twice');
    assert.deepEqual(warnings, [], 'the move is not a duplicate target');
  });

  test('below lg an empty route-driven aside renders no drawer', async function (assert) {
    media?.setWidth(MOBILE);
    await render(
      <template>
        <AppLayout @defaultAsideOpen={{true}} as |layout|>
          <layout.Navbar><layout.AsideToggle /></layout.Navbar>
          <layout.Main>Content</layout.Main>
          <layout.Aside @region="aside" />
        </AppLayout>
      </template>
    );
    assert.dom('[role="dialog"]', document.body).doesNotExist();
    assert.dom('[data-part="aside-toggle"]').doesNotExist();
  });

  test('an Aside without @region is unchanged, with or without a block', async function (assert) {
    await render(
      <template>
        <AppLayout @defaultAsideOpen={{true}} as |layout|>
          <layout.Navbar><layout.AsideToggle /></layout.Navbar>
          <layout.Main>
            <InLayoutRegion @name="aside"><p
                data-test-stray
              >Stray</p></InLayoutRegion>
          </layout.Main>
          <layout.Aside />
        </AppLayout>
      </template>
    );
    assert.dom('[data-part="aside"]').exists('an empty panel, as before');
    assert.dom('[data-part="aside"]').hasText('');
    assert.dom('[data-part="aside-toggle"]').exists();
    assert.dom('[data-test-stray]').doesNotExist('it is not a region target');
  });

  test('a standalone Aside with @region and @state is filled by a source', async function (assert) {
    const state = new AppLayoutState({ asideOpen: true });
    await render(
      <template>
        <InLayoutRegion @name="details"><p
            data-test-aside-body
          >Order</p></InLayoutRegion>
        <Aside @state={{state}} @region="details" />
      </template>
    );
    assert.strictEqual(
      document.querySelector('[data-test-aside-body]')?.parentElement,
      document.querySelector('[data-part="aside"]')
    );
  });

  test('at lg and up an emptied aside keeps asideOpen and is open again when refilled', async function (assert) {
    const flags = new Flags();
    const state = new AppLayoutState();
    await render(
      <template>
        <AppLayout @state={{state}} as |layout|>
          <layout.Navbar><layout.AsideToggle /></layout.Navbar>
          <layout.Main>
            {{#if flags.first}}
              <InLayoutRegion @name="aside"><p>Order</p></InLayoutRegion>
            {{/if}}
          </layout.Main>
          <layout.Aside @region="aside" />
        </AppLayout>
      </template>
    );
    await click('[data-part="aside-toggle"]');
    assert.dom('[data-part="aside"]').exists();

    flags.first = false;
    await settled();
    assert.dom('[data-part="aside"]').doesNotExist('hidden while empty');
    assert.true(state.asideOpen, 'the open state is left alone');

    flags.first = true;
    await settled();
    assert.dom('[data-part="aside"]').exists('open again without a click');
  });

  test('at lg and up a pass through empty between two sources leaves the panel open', async function (assert) {
    const flags = new Flags();
    const state = new AppLayoutState({ asideOpen: true });
    await render(
      <template>
        <AppLayout @state={{state}} as |layout|>
          <layout.Main>
            {{#if flags.first}}
              <InLayoutRegion @name="aside"><p>First</p></InLayoutRegion>
            {{/if}}
            {{#if flags.second}}
              <InLayoutRegion @name="aside"><p>Second</p></InLayoutRegion>
            {{/if}}
          </layout.Main>
          <layout.Aside @region="aside" />
        </AppLayout>
      </template>
    );
    // A loading state between two routes that each fill the aside.
    flags.first = false;
    await settled();
    flags.second = true;
    await settled();
    assert.dom('[data-part="aside"]').hasText('Second');
  });

  test('below lg an emptied aside closes and stays closed', async function (assert) {
    media?.setWidth(MOBILE);
    const flags = new Flags();
    const state = new AppLayoutState();
    await render(
      <template>
        <AppLayout @state={{state}} as |layout|>
          <layout.Navbar><layout.AsideToggle /></layout.Navbar>
          <layout.Main>
            {{#if flags.first}}
              <InLayoutRegion @name="aside"><p
                  data-test-aside-body
                >Order</p></InLayoutRegion>
            {{/if}}
          </layout.Main>
          <layout.Aside @region="aside" />
        </AppLayout>
      </template>
    );
    await click('[data-part="aside-toggle"]');
    assert
      .dom('[role="dialog"] [data-test-aside-body]', document.body)
      .exists();

    flags.first = false;
    await settled();
    assert.false(state.asideOpen, 'emptying the drawer closes it');

    flags.first = true;
    await settled();
    assert
      .dom('[data-test-aside-body]', document.body)
      .doesNotExist('no drawer opens when content returns');
    assert.dom('[data-part="aside-toggle"]').exists('the toggle is back');
  });

  test('at lg and up a controlled @asideOpen is not told to close when emptied', async function (assert) {
    const flags = new Flags();
    const calls: boolean[] = [];
    const record = (value: boolean) => calls.push(value);
    await render(
      <template>
        <AppLayout
          @asideOpen={{true}}
          @onAsideOpenChange={{record}}
          as |layout|
        >
          <layout.Main>
            {{#if flags.first}}
              <InLayoutRegion @name="aside"><p>Order</p></InLayoutRegion>
            {{/if}}
          </layout.Main>
          <layout.Aside @region="aside" />
        </AppLayout>
      </template>
    );
    flags.first = false;
    await settled();
    assert.deepEqual(calls, []);
  });

  test('below lg a controlled @asideOpen is told to close when emptied', async function (assert) {
    media?.setWidth(MOBILE);
    const flags = new Flags();
    const calls: boolean[] = [];
    const record = (value: boolean) => calls.push(value);
    await render(
      <template>
        <AppLayout
          @asideOpen={{true}}
          @onAsideOpenChange={{record}}
          as |layout|
        >
          <layout.Main>
            {{#if flags.first}}
              <InLayoutRegion @name="aside"><p>Order</p></InLayoutRegion>
            {{/if}}
          </layout.Main>
          <layout.Aside @region="aside" />
        </AppLayout>
      </template>
    );
    assert.deepEqual(calls, [], 'nothing before it empties');

    flags.first = false;
    await settled();
    assert.deepEqual(calls, [false]);
  });

  test('below lg a swap of sources in one render keeps the drawer open', async function (assert) {
    media?.setWidth(MOBILE);
    const flags = new Flags();
    const state = new AppLayoutState({ asideOpen: true });
    await render(
      <template>
        <AppLayout @state={{state}} as |layout|>
          <layout.Main>
            {{#if flags.first}}
              <InLayoutRegion @name="aside"><p>First</p></InLayoutRegion>
            {{/if}}
            {{#if flags.second}}
              <InLayoutRegion @name="aside"><p>Second</p></InLayoutRegion>
            {{/if}}
          </layout.Main>
          <layout.Aside @region="aside" />
        </AppLayout>
      </template>
    );
    assert.dom('[role="dialog"] aside', document.body).hasText('First');

    // The outgoing source is torn down in the same render that creates the
    // incoming one, so the region is never seen empty.
    flags.first = false;
    flags.second = true;
    await settled();
    assert.true(state.asideOpen, 'the drawer was not closed by the swap');
    assert.dom('[role="dialog"] aside', document.body).hasText('Second');
  });
});
