import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click } from '@ember/test-helpers';
import DocfyCopyPage from 'site/components/docfy/docfy-copy-page';

module('Integration | Component | docfy/docfy-copy-page', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders the primary Copy Page button', async function (assert) {
    await render(
      <template>
        <DocfyCopyPage
          @url="/docs/components/buttons/button-group"
          @title="ButtonGroup"
        />
      </template>
    );

    assert.dom('[data-test-id="copy-page-primary"]').hasText('Copy Page');
  });

  test('copyPage fetches the markdown URL and copies it to the clipboard', async function (assert) {
    const originalFetch = window.fetch;
    let copiedText: string | undefined;

    window.fetch = (async () =>
      new Response('# ButtonGroup\n\nExample content.', {
        status: 200
      })) as typeof window.fetch;

    Object.defineProperty(navigator, 'clipboard', {
      configurable: true,
      value: {
        writeText: async (text: string) => {
          copiedText = text;
        }
      }
    });

    await render(
      <template>
        <DocfyCopyPage
          @url="/docs/components/buttons/button-group"
          @title="ButtonGroup"
        />
      </template>
    );

    await click('[data-test-id="copy-page-primary"]');

    assert.dom('[data-test-id="copy-page-primary"]').hasText('Copied!');
    assert.strictEqual(copiedText, '# ButtonGroup\n\nExample content.');

    window.fetch = originalFetch;
  });

  test('copyPage shows an error state when the markdown URL 404s', async function (assert) {
    const originalFetch = window.fetch;

    window.fetch = (async () =>
      new Response('', { status: 404 })) as typeof window.fetch;

    await render(
      <template>
        <DocfyCopyPage
          @url="/docs/components/buttons/button-group"
          @title="ButtonGroup"
        />
      </template>
    );

    await click('[data-test-id="copy-page-primary"]');

    assert.dom('[data-test-id="copy-page-primary"]').hasText('Unavailable');

    window.fetch = originalFetch;
  });
});
