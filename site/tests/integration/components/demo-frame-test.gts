import { click, find, render } from '@ember/test-helpers';
import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import DemoFrame from 'site/components/demo-frame';

const PARAM = 'demo-frame';

/** Adds `?demo-frame=<id>` to the current URL; returns a restore function. */
function visitAsFrame(id: string): () => void {
  const original = window.location.href;
  const url = new URL(original);
  url.searchParams.set(PARAM, id);
  window.history.replaceState(window.history.state, '', url);
  return () => {
    window.history.replaceState(window.history.state, '', original);
  };
}

module('Integration | Component | demo-frame', function (hooks) {
  setupRenderingTest(hooks);

  hooks.afterEach(function () {
    document.documentElement.classList.remove('demo-frame-mode');
  });

  test('renders the demo in a stage with an expand button', async function (assert) {
    await render(
      <template>
        <DemoFrame @id="shell" @label="App shell">
          <p id="payload">Layout</p>
        </DemoFrame>
      </template>
    );

    assert
      .dom('[data-demo-frame="shell"] [data-demo-frame-stage] #payload')
      .exists();
    assert
      .dom('[data-demo-frame="shell"] [data-demo-frame-expand]')
      .hasAttribute('aria-label', 'Expand App shell');
    assert
      .dom('[data-demo-frame="shell"]')
      .hasAttribute('data-fullscreen', 'false');
  });

  test('expanding opens a dialog with an iframe of this page in frame mode', async function (assert) {
    await render(
      <template>
        <DemoFrame @id="shell" @label="App shell">Layout</DemoFrame>
      </template>
    );

    await click('[data-demo-frame-expand]');

    assert.dom('[role="dialog"]').exists();
    const iframe = find('[role="dialog"] iframe') as HTMLIFrameElement;
    assert.ok(iframe, 'has an iframe');
    const src = new URL(iframe.src);
    assert.strictEqual(src.pathname, window.location.pathname);
    assert.strictEqual(src.searchParams.get(PARAM), 'shell');
    assert.dom(iframe).hasAttribute('title', 'App shell');
    assert
      .dom('[role="dialog"] a[data-demo-frame-open]')
      .hasAttribute('href', `${src.pathname}${src.search}`)
      .hasAttribute('target', '_blank');
  });

  test('the width buttons resize the iframe', async function (assert) {
    await render(
      <template>
        <DemoFrame @id="shell" @label="App shell">Layout</DemoFrame>
      </template>
    );
    await click('[data-demo-frame-expand]');

    const iframe = () => find('[role="dialog"] iframe') as HTMLIFrameElement;
    assert.strictEqual(iframe().style.width, '100%', 'desktop by default');

    await click('[role="dialog"] [role="radio"][data-value="phone"]');
    assert.strictEqual(iframe().style.width, '390px');

    await click('[role="dialog"] [role="radio"][data-value="tablet"]');
    assert.strictEqual(iframe().style.width, '768px');
  });

  test('in frame mode the matching frame fills the viewport', async function (assert) {
    const restore = visitAsFrame('shell');
    try {
      await render(
        <template>
          <DemoFrame @id="other" @label="Other">Other</DemoFrame>
          <DemoFrame @id="shell" @label="App shell">Layout</DemoFrame>
        </template>
      );

      assert
        .dom('[data-demo-frame="shell"]')
        .hasAttribute('data-fullscreen', 'true');
      assert
        .dom('[data-demo-frame="other"]')
        .hasAttribute('data-fullscreen', 'false');
      assert
        .dom('[data-demo-frame="shell"] [data-demo-frame-expand]')
        .doesNotExist();
      assert.true(
        document.documentElement.classList.contains('demo-frame-mode'),
        'the page is in frame mode'
      );
      assert.strictEqual(
        getComputedStyle(find('[data-demo-frame="shell"]')!).position,
        'fixed'
      );
    } finally {
      restore();
    }
  });
});
