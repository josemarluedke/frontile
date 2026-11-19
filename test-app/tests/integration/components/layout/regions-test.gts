import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, settled } from '@ember/test-helpers';
import { tracked } from '@glimmer/tracking';
import { run } from '@ember/runloop';
import { AppLayout, InLayoutRegion } from 'frontile';
import {
  mockMatchMedia,
  type MatchMediaMock
} from 'test-app/tests/helpers/match-media';

const DESKTOP = 1200;

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

  hooks.beforeEach(function () {
    media = mockMatchMedia(DESKTOP);
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
});
