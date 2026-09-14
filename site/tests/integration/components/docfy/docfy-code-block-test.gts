import { DocfyCodeBlock } from '@docfy/ember';
import { render } from '@ember/test-helpers';
import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';

module('Integration | Component | docfy/docfy-code-block', function (hooks) {
  setupRenderingTest(hooks);

  let originalClipboardDescriptor: PropertyDescriptor | undefined;

  hooks.beforeEach(function () {
    originalClipboardDescriptor = Object.getOwnPropertyDescriptor(
      navigator,
      'clipboard'
    );

    Object.defineProperty(navigator, 'clipboard', {
      configurable: true,
      value: {
        writeText: () => Promise.resolve(),
      },
    });
  });

  hooks.afterEach(function () {
    if (originalClipboardDescriptor) {
      Object.defineProperty(
        navigator,
        'clipboard',
        originalClipboardDescriptor
      );
    } else {
      delete (navigator as unknown as Record<string, unknown>)['clipboard'];
    }
  });

  test('the copy button is visible and interactive before hover', async function (assert) {
    await render(
      <template>
        <DocfyCodeBlock @language="js">
          <pre><code>const visible = true;</code></pre>
        </DocfyCodeBlock>
      </template>
    );

    const copyButton = document.querySelector<HTMLElement>(
      '[data-test-id="code-block-copy"]'
    );

    assert.dom(copyButton).exists();
    assert.strictEqual(
      window.getComputedStyle(copyButton!).opacity,
      '1',
      'the copy affordance is visible at rest'
    );
    assert.strictEqual(
      window.getComputedStyle(copyButton!).zIndex,
      '10',
      'the copy affordance is layered above the code content'
    );
  });
});
