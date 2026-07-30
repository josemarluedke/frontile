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
      // clipboard had an own property on navigator (unusual, but possible in
      // some environments) — restore it exactly as it was.
      Object.defineProperty(
        navigator,
        'clipboard',
        originalClipboardDescriptor
      );
    } else if (
      Object.prototype.hasOwnProperty.call(navigator, 'clipboard')
    ) {
      // clipboard normally lives on Navigator.prototype, so there was no own
      // property to capture — remove the one a test may have defined, so it
      // doesn't leak into later tests.
      delete (navigator as unknown as Record<string, unknown>)['clipboard'];
    }
  });

  test('it renders the primary Copy Markdown button', async function (assert) {
    await render(
      <template>
        <DocfyCopyPage
          @url="/docs/components/buttons/button-group"
          @title="ButtonGroup"
        />
      </template>
    );

    assert.dom('[data-test-id="copy-page-primary"]').hasText('Copy Markdown');
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

  test('the dropdown lists the remaining three actions', async function (assert) {
    await render(
      <template>
        <DocfyCopyPage
          @url="/docs/components/buttons/button-group"
          @title="ButtonGroup"
        />
      </template>
    );

    await click('[data-test-id="copy-page-trigger"]');

    assert.dom('[data-key="view-as-markdown"]').hasText('View as Markdown');
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
