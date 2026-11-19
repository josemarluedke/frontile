// PROTOTYPE: layout regions, second attempt (layout-owned region elements).
import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find, findAll, click, settled } from '@ember/test-helpers';
import { cell } from 'ember-resources';
import type Owner from '@ember/owner';
import { AppLayout, AppLayoutState, InRegion } from 'frontile';
import {
  mockMatchMedia,
  type MatchMediaMock
} from 'test-app/tests/helpers/match-media';

const MOBILE = 500;
const DESKTOP = 1200;

const REGION = '[data-part="region"]';
const TOGGLE = '[data-part="aside-toggle"]';

function display(selector: string): string {
  const element = find(selector);
  return element ? getComputedStyle(element).display : 'absent';
}

/** The text a user can see: `display: none` subtrees are left out. */
function visibleText(selector: string): string {
  return ((find(selector) as HTMLElement | null)?.innerText ?? '')
    .replace(/\s+/g, ' ')
    .trim();
}

/**
 * Counts Glimmer render transactions from now on, by wrapping Ember's
 * `RendererState#renderRoots` (private to Ember; fine for a measurement).
 * Returns a function that stops counting and gives the count.
 */
function countRenderPasses(owner: Owner): () => number {
  // Patched on the prototype: test templates render through their own
  // renderer, which shares the class with `renderer:-dom`.
  const proto = Object.getPrototypeOf(
    (owner.lookup('renderer:-dom') as unknown as { state: object }).state
  ) as { renderRoots(...args: unknown[]): unknown };
  const original = proto.renderRoots;
  let passes = 0;
  proto.renderRoots = function (this: unknown, ...args: unknown[]) {
    passes += 1;
    return original.apply(this, args);
  };
  return () => {
    proto.renderRoots = original;
    return passes;
  };
}

module('Integration | Component | Regions | frontile/layout', function (hooks) {
  setupRenderingTest(hooks);

  let media: MatchMediaMock | undefined;

  hooks.afterEach(function () {
    media?.restore();
    media = undefined;
  });

  test('a source inside Main renders into a region in the Navbar', async function (assert) {
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Navbar>
            <layout.Region @name="actions" />
          </layout.Navbar>
          <layout.Main>
            <p data-test-page>Page</p>
            <InRegion @name="actions"><button
                type="button"
                data-test-action
              >New</button></InRegion>
          </layout.Main>
        </AppLayout>
      </template>
    );

    assert
      .dom(`header ${REGION}[data-region="actions"] [data-test-action]`)
      .exists('the content is in the navbar region');
    assert.dom('main [data-test-action]').doesNotExist('and not in Main');
    assert
      .dom('main script[data-region-source="actions"]')
      .exists('the source leaves a marker where it was written');
  });

  test('the fill is complete in the first render pass, and nothing changes after it', async function (assert) {
    media = mockMatchMedia(DESKTOP);
    const firstPass: Record<string, string> = {};
    const mutations: MutationRecord[] = [];
    let observer: MutationObserver | undefined;

    // Rendered last, so it runs at the end of the first pass, while Glimmer
    // is still rendering. Whatever it sees was produced with no second pass.
    const probe = (): void => {
      firstPass['actions'] = visibleText('header');
      firstPass['aside'] = visibleText('[data-part="aside"]');
      firstPass['toggle'] = display(TOGGLE);
      observer = new MutationObserver((records) => mutations.push(...records));
      observer.observe(find('[data-component="app-layout"]')!, {
        subtree: true,
        childList: true,
        attributes: true,
        characterData: true
      });
    };

    await render(
      <template>
        <AppLayout @defaultAsideOpen={{true}} as |layout|>
          <layout.Navbar>
            <layout.Region @name="actions">Fallback</layout.Region>
            <layout.AsideToggle />
          </layout.Navbar>
          <layout.Main>
            <InRegion @name="actions">Route actions</InRegion>
            <InRegion @name="aside">Route aside</InRegion>
          </layout.Main>
          <layout.Aside />
        </AppLayout>
        {{(probe)}}
      </template>
    );
    mutations.push(...(observer?.takeRecords() ?? []));
    observer?.disconnect();

    assert.strictEqual(firstPass['actions'], 'Route actions');
    assert.strictEqual(firstPass['aside'], 'Route aside');
    assert.notStrictEqual(firstPass['toggle'], 'none', 'the toggle is shown');
    assert.notStrictEqual(firstPass['toggle'], 'absent');
    assert.deepEqual(
      mutations.map((m) => `${m.type} ${m.attributeName ?? ''}`.trim()),
      [],
      'no DOM mutation after the first pass: no second render'
    );
  });

  test('a source written before the region is displayed still fills it', async function (assert) {
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Main>
            <InRegion @name="footer">Late region</InRegion>
          </layout.Main>
          <layout.Navbar>
            <layout.Region @name="footer" />
          </layout.Navbar>
        </AppLayout>
      </template>
    );

    assert.dom(`header ${REGION}`).hasText('Late region');
  });

  test('only the first source in the template is rendered; a later one comes back when it leaves', async function (assert) {
    const child = cell(false);
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Navbar><layout.Region @name="actions" /></layout.Navbar>
          <layout.Main>
            {{! Where an outlet would be: the child comes first. }}
            {{#if child.current}}
              <InRegion @name="actions">Child</InRegion>
            {{/if}}
            <InRegion @name="actions"><span
                data-test-parent
              >Parent</span></InRegion>
          </layout.Main>
        </AppLayout>
      </template>
    );

    assert.strictEqual(visibleText('header'), 'Parent');

    const entering = countRenderPasses(this.owner);
    child.current = true;
    await settled();
    assert.strictEqual(entering(), 1, 'covering the parent took one pass');
    assert.strictEqual(visibleText('header'), 'Child');
    assert
      .dom('[data-test-parent]')
      .doesNotExist('the covered source is not in the DOM at all');

    const leaving = countRenderPasses(this.owner);
    child.current = false;
    await settled();
    assert.strictEqual(visibleText('header'), 'Parent', 'the parent is back');
    assert.strictEqual(
      leaving(),
      2,
      'uncovering it took two: the child is removed, then the parent renders'
    );
  });

  test('a deep render with both levels fills once: only the first source, in the first pass', async function (assert) {
    const firstPass: Record<string, string | boolean> = {};
    const mutations: MutationRecord[] = [];
    let observer: MutationObserver | undefined;
    const probe = (): void => {
      firstPass['actions'] = visibleText('header');
      firstPass['parentRendered'] = find('[data-test-parent]') !== null;
      observer = new MutationObserver((records) => mutations.push(...records));
      observer.observe(find('[data-component="app-layout"]')!, {
        subtree: true,
        childList: true,
        attributes: true,
        characterData: true
      });
    };
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Navbar><layout.Region @name="actions" /></layout.Navbar>
          <layout.Main>
            <InRegion @name="actions">Child</InRegion>
            <InRegion @name="actions"><span
                data-test-parent
              >Parent</span></InRegion>
          </layout.Main>
        </AppLayout>
        {{(probe)}}
      </template>
    );
    mutations.push(...(observer?.takeRecords() ?? []));
    observer?.disconnect();

    assert.strictEqual(firstPass['actions'], 'Child');
    assert.false(firstPass['parentRendered'], 'the parent never rendered');
    assert.strictEqual(mutations.length, 0, 'nothing changed after the pass');
  });

  test('@multiple shows every source, in render order', async function (assert) {
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Navbar>
            <layout.Region @name="actions" @multiple={{true}} />
          </layout.Navbar>
          <layout.Main>
            <InRegion @name="actions">One</InRegion>
            <InRegion @name="actions">Two</InRegion>
          </layout.Main>
        </AppLayout>
      </template>
    );

    assert.strictEqual(visibleText('header'), 'One Two');
  });

  test('the block of a Region is a fallback, shown only while nothing fills it', async function (assert) {
    const filled = cell(false);
    await render(
      <template>
        <AppLayout as |layout|>
          <layout.Navbar>
            <layout.Region @name="actions">Fallback</layout.Region>
          </layout.Navbar>
          <layout.Main>
            {{#if filled.current}}
              <InRegion @name="actions">Filled</InRegion>
            {{/if}}
          </layout.Main>
        </AppLayout>
      </template>
    );

    assert.strictEqual(visibleText('header'), 'Fallback');

    filled.current = true;
    await settled();
    assert.strictEqual(visibleText('header'), 'Filled');

    filled.current = false;
    await settled();
    assert.strictEqual(visibleText('header'), 'Fallback');
  });

  test('a region-driven Aside shows no column and no toggle while nothing fills it', async function (assert) {
    media = mockMatchMedia(DESKTOP);
    const filled = cell(false);
    const state = new AppLayoutState();
    await render(
      <template>
        <AppLayout @state={{state}} as |layout|>
          <layout.Navbar><layout.AsideToggle /></layout.Navbar>
          <layout.Main>
            {{#if filled.current}}
              <InRegion @name="aside">Order details</InRegion>
            {{/if}}
          </layout.Main>
          <layout.Aside />
        </AppLayout>
      </template>
    );

    assert.strictEqual(display(TOGGLE), 'none', 'no toggle');

    filled.current = true;
    await settled();
    assert.notStrictEqual(display(TOGGLE), 'none', 'toggle appears');
    assert.dom('[data-part="aside"]').doesNotExist('still closed');

    await click(TOGGLE);
    assert.dom('[data-part="aside"]').isVisible();
    assert.dom('[data-part="aside"]').hasText('Order details');

    filled.current = false;
    await settled();
    assert.false(state.asideOpen, 'emptying the aside closes it');
    assert.strictEqual(display(TOGGLE), 'none', 'and hides the toggle');

    filled.current = true;
    await settled();
    assert.false(state.asideOpen, 'it stays closed when filled again');
  });

  test('a stale asideOpen shows no empty column', async function (assert) {
    media = mockMatchMedia(DESKTOP);
    await render(
      <template>
        <AppLayout @defaultAsideOpen={{true}} as |layout|>
          <layout.Main>Page</layout.Main>
          <layout.Aside />
        </AppLayout>
      </template>
    );

    assert.strictEqual(display('[data-part="aside"]'), 'none');
  });

  test('KNOWN GAP: below lg, a stale asideOpen with nothing filling the aside opens an empty drawer', async function (assert) {
    media = mockMatchMedia(MOBILE);
    await render(
      <template>
        <AppLayout @defaultAsideOpen={{true}} as |layout|>
          <layout.Main>Page</layout.Main>
          <layout.Aside />
        </AppLayout>
      </template>
    );

    // The drawer is portalled out of the layout root, so the root's CSS
    // cannot hide it, and no source is ever destroyed to close it. Pinned
    // here so the gap is visible; it is not the behaviour to keep.
    assert.dom('[role="dialog"]').exists('an empty drawer is open');
    assert.dom('[role="dialog"] [data-part="mobile-aside"]').hasText('');
  });

  test('swapping one aside source for another does not close the aside', async function (assert) {
    media = mockMatchMedia(DESKTOP);
    const which = cell('a');
    const state = new AppLayoutState({ asideOpen: true });
    const isA = (value: string): boolean => value === 'a';
    await render(
      <template>
        <AppLayout @state={{state}} as |layout|>
          <layout.Main>
            {{#if (isA which.current)}}
              <InRegion @name="aside">Aside A</InRegion>
            {{else}}
              <InRegion @name="aside">Aside B</InRegion>
            {{/if}}
          </layout.Main>
          <layout.Aside />
        </AppLayout>
      </template>
    );

    const swapping = countRenderPasses(this.owner);
    which.current = 'b';
    await settled();

    assert.strictEqual(swapping(), 1, 'the swap took one pass');
    assert.true(state.asideOpen);
    assert.strictEqual(visibleText('[data-part="aside"]'), 'Aside B');
  });

  test('aside content keeps its state through close, reopen and the move into the drawer', async function (assert) {
    media = mockMatchMedia(DESKTOP);
    const state = new AppLayoutState({ asideOpen: true });
    await render(
      <template>
        <AppLayout @state={{state}} as |layout|>
          <layout.Navbar><layout.AsideToggle /></layout.Navbar>
          <layout.Main>
            <InRegion @name="aside"><input
                data-test-note
                aria-label="note"
              /></InRegion>
          </layout.Main>
          <layout.Aside />
        </AppLayout>
      </template>
    );

    const note = find('[data-test-note]') as HTMLInputElement;
    note.value = 'draft';

    state.asideOpen = false;
    await settled();
    assert.dom('[data-part="aside"]').doesNotExist();
    state.asideOpen = true;
    await settled();
    assert.strictEqual(
      find('[data-part="aside"] [data-test-note]'),
      note,
      'the same element after close and reopen'
    );

    state.asideOpen = false;
    await settled();
    media.setWidth(MOBILE);
    await settled();
    state.asideOpen = true;
    await settled();

    assert.strictEqual(
      find('[role="dialog"] [data-part="mobile-aside"] [data-test-note]'),
      note,
      'the same element inside the drawer'
    );
    assert.dom(note).hasValue('draft');
    assert.strictEqual(findAll('[data-test-note]').length, 1, 'never twice');
  });

  test('an Aside with a block is unchanged, and its toggle shows in the first pass', async function (assert) {
    media = mockMatchMedia(DESKTOP);
    let firstPassToggle = '';
    const probe = (): void => {
      firstPassToggle = display(TOGGLE);
    };
    await render(
      <template>
        <AppLayout @defaultAsideOpen={{true}} as |layout|>
          <layout.Navbar><layout.AsideToggle /></layout.Navbar>
          <layout.Main>Page</layout.Main>
          <layout.Aside>Static details</layout.Aside>
        </AppLayout>
        {{(probe)}}
      </template>
    );

    assert.notStrictEqual(firstPassToggle, 'none');
    assert.notStrictEqual(firstPassToggle, 'absent');
    assert.dom('[data-part="aside"]').hasText('Static details');
  });

  test('a source outside any layout renders nothing', async function (assert) {
    await render(
      <template>
        <div data-test-root><InRegion @name="actions">Lost</InRegion></div>
      </template>
    );

    assert.dom('[data-test-root]').hasText('');
  });
});
