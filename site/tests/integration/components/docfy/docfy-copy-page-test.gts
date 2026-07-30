import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click } from '@ember/test-helpers';
import DocfyCopyPage from 'site/components/docfy/docfy-copy-page';

module('Integration | Component | docfy/docfy-copy-page', function (hooks) {
  setupRenderingTest(hooks);

  let originalFetch: typeof window.fetch;
  let originalOpen: typeof window.open;
  let originalClipboardDescriptor:
    | PropertyDescriptor
    | undefined;

  hooks.beforeEach(function () {
    originalFetch = window.fetch;
    originalOpen = window.open;
    originalClipboardDescriptor = Object.getOwnPropertyDescriptor(
      navigator,
      'clipboard'
    );
  });

  hooks.afterEach(function () {
    window.fetch = originalFetch;
    window.open = originalOpen;
    if (originalClipboardDescriptor) {
      Object.defineProperty(
        navigator,
        'clipboard',
        originalClipboardDescriptor
      );
    }
  });

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
  });

  test('copyPage shows an error state when the markdown URL 404s', async function (assert) {
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
  });

  test('the "Copy Page" menu item also triggers copyPage', async function (assert) {
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

    await click('[data-test-id="copy-page-trigger"]');
    await click('[data-key="copy-page"]');

    assert.strictEqual(copiedText, '# ButtonGroup\n\nExample content.');
  });

  test('the dropdown lists all four actions', async function (assert) {
    await render(
      <template>
        <DocfyCopyPage
          @url="/docs/components/buttons/button-group"
          @title="ButtonGroup"
        />
      </template>
    );

    await click('[data-test-id="copy-page-trigger"]');

    assert.dom('[data-key="view-as-markdown"]').hasText('View as markdown');
    assert.dom('[data-key="copy-page"]').hasText('Copy Page');
    assert.dom('[data-key="open-chatgpt"]').hasText('Open in ChatGPT');
    assert.dom('[data-key="open-claude"]').hasText('Open in Claude');
  });

  test('"View as markdown" carries the .md URL as a real href, and also opens via keyboard/click through the menu action', async function (assert) {
    const openedUrls: string[] = [];

    window.open = ((url: string) => {
      openedUrls.push(url);
      return null;
    }) as typeof window.open;

    await render(
      <template>
        <DocfyCopyPage
          @url="/docs/components/buttons/button-group"
          @title="ButtonGroup"
        />
      </template>
    );

    await click('[data-test-id="copy-page-trigger"]');

    assert
      .dom('[data-test-id="copy-page-view-markdown"]')
      .hasAttribute(
        'href',
        `${window.location.origin}/docs/components/buttons/button-group.md`
      )
      .hasAttribute('target', '_blank')
      .hasAttribute('rel', 'noopener noreferrer');

    await click('[data-key="view-as-markdown"]');

    assert.strictEqual(
      openedUrls[0],
      `${window.location.origin}/docs/components/buttons/button-group.md`
    );
  });

  test('"Open in ChatGPT" and "Open in Claude" open the expected launch URLs', async function (assert) {
    const openedUrls: string[] = [];

    window.open = ((url: string) => {
      openedUrls.push(url);
      return null;
    }) as typeof window.open;

    await render(
      <template>
        <DocfyCopyPage
          @url="/docs/components/buttons/button-group"
          @title="ButtonGroup"
        />
      </template>
    );

    await click('[data-test-id="copy-page-trigger"]');
    await click('[data-key="open-chatgpt"]');

    const expectedPrompt =
      'Use web browsing to access this Frontile documentation page: ' +
      `${window.location.origin}/docs/components/buttons/button-group.md. ` +
      'I want to ask some questions about the ButtonGroup component.';

    assert.strictEqual(
      openedUrls[0],
      `https://chatgpt.com/?hints=search&q=${encodeURIComponent(expectedPrompt)}`
    );

    await click('[data-test-id="copy-page-trigger"]');
    await click('[data-key="open-claude"]');

    assert.strictEqual(
      openedUrls[1],
      `https://claude.ai/new?q=${encodeURIComponent(expectedPrompt)}`
    );
  });
});
