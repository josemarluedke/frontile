import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render } from '@ember/test-helpers';
import { hash } from '@ember/helper';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import { Alert } from 'frontile';

/**
 * `iconSlot` is a parameter so the "icon slot sizing" test below can
 * register a variant that also carries the production centering/clamping
 * classes (`inline-flex items-center justify-center [&>*]:size-full`,
 * mirroring `packages/theme/src/components/alert.ts`) without disturbing
 * every other test in this file, which only cares that `alert-icon` landed
 * on the right element.
 */
function customAlertStyles(iconSlot: string[] = ['alert-icon']) {
  return tv({
    slots: {
      base: ['alert-base'],
      inner: ['alert-inner'],
      icon: iconSlot,
      content: ['alert-content'],
      title: ['alert-title'],
      description: ['alert-description'],
      actions: ['alert-actions'],
      closeButton: ['alert-close-button']
    },
    variants: {
      intent: {
        default: 'intent-default',
        info: 'intent-info',
        success: 'intent-success',
        warning: 'intent-warning',
        danger: 'intent-danger'
      },
      variant: {
        default: 'variant-default',
        tonal: 'variant-tonal',
        solid: 'variant-solid'
      },
      hasDescription: {
        true: { inner: ['has-description'] },
        false: { inner: ['no-description'] }
      }
    },
    defaultVariants: {
      intent: 'default',
      variant: 'default',
      hasDescription: false
    }
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
  }) as any;
}

registerCustomStyles({
  alert: customAlertStyles()
});

module('Integration | Component | Alert | @frontile/status', function (hooks) {
  setupRenderingTest(hooks);

  module('content', function () {
    test('it renders @title and @description', async function (assert) {
      await render(
        <template>
          <Alert
            @title="Update available"
            @description="A new version is ready."
          />
        </template>
      );

      assert.dom('[data-test-id="alert"]').exists();
      assert
        .dom('[data-test-id="alert"]')
        .hasAttribute('data-component', 'alert');
      assert.dom('[data-test-id="alert-title"]').hasText('Update available');
      assert
        .dom('[data-test-id="alert-description"]')
        .hasText('A new version is ready.');
    });

    test('it omits the title and description elements when neither is given', async function (assert) {
      await render(<template><Alert /></template>);

      assert.dom('[data-test-id="alert"]').exists();
      assert.dom('[data-test-id="alert-title"]').doesNotExist();
      assert.dom('[data-test-id="alert-description"]').doesNotExist();
    });

    test('the title block overrides @title', async function (assert) {
      await render(
        <template>
          <Alert @title="From the argument">
            <:title>From the block</:title>
          </Alert>
        </template>
      );

      assert.dom('[data-test-id="alert-title"]').hasText('From the block');
      assert.dom('[data-test-id="alert-title"]').doesNotContainText('argument');
    });

    test('the description block overrides @description and takes markup', async function (assert) {
      await render(
        <template>
          <Alert @title="Unable to connect" @description="From the argument">
            <:description>
              <ul>
                <li>Check your internet connection</li>
                <li>Refresh the page</li>
              </ul>
            </:description>
          </Alert>
        </template>
      );

      assert
        .dom('[data-test-id="alert-description"]')
        .doesNotContainText('argument');
      assert.dom('[data-test-id="alert-description"] li').exists({ count: 2 });
      assert
        .dom('[data-test-id="alert-description"] li')
        .hasText('Check your internet connection');
    });

    test('attributes are forwarded to the root element', async function (assert) {
      await render(
        <template>
          <Alert @title="Saved" data-extra="yes" aria-label="Saved alert" />
        </template>
      );

      assert.dom('[data-test-id="alert"]').hasAttribute('data-extra', 'yes');
      assert
        .dom('[data-test-id="alert"]')
        .hasAttribute('aria-label', 'Saved alert');
    });
  });

  module('icon', function () {
    test('each intent gets its own default glyph', async function (assert) {
      await render(
        <template>
          <Alert @title="Default" data-test-id="d" />
          <Alert @intent="info" @title="Info" data-test-id="i" />
          <Alert @intent="success" @title="Success" data-test-id="s" />
          <Alert @intent="warning" @title="Warning" data-test-id="w" />
          <Alert @intent="danger" @title="Danger" data-test-id="x" />
        </template>
      );

      // The `default` intent shares the info glyph, as NotificationCard does.
      assert.dom('[data-test-id="d"] [data-test-icon="info"]').exists();
      assert.dom('[data-test-id="i"] [data-test-icon="info"]').exists();
      assert.dom('[data-test-id="s"] [data-test-icon="success"]').exists();
      assert.dom('[data-test-id="w"] [data-test-icon="warning"]').exists();
      assert.dom('[data-test-id="x"] [data-test-icon="danger"]').exists();
    });

    test('the icon block replaces the default glyph', async function (assert) {
      await render(
        <template>
          <Alert @intent="success" @title="Saved">
            <:icon><span data-test-id="custom-icon">*</span></:icon>
          </Alert>
        </template>
      );

      assert.dom('[data-test-id="custom-icon"]').exists();
      assert.dom('[data-test-icon="success"]').doesNotExist();
    });

    test('@hideIcon removes the icon entirely', async function (assert) {
      await render(
        <template>
          <Alert @intent="danger" @title="Failed" @hideIcon={{true}} />
        </template>
      );

      assert.dom('[data-test-id="alert-icon"]').doesNotExist();
      assert.dom('[data-test-icon="danger"]').doesNotExist();
    });

    test('@hideIcon wins over the icon block', async function (assert) {
      await render(
        <template>
          <Alert @title="Saved" @hideIcon={{true}}>
            <:icon><span data-test-id="custom-icon">*</span></:icon>
          </Alert>
        </template>
      );

      assert.dom('[data-test-id="alert-icon"]').doesNotExist();
      assert.dom('[data-test-id="custom-icon"]').doesNotExist();
    });

    test('yielded icon-block content is clamped to the icon slot size, not its own intrinsic size', async function (assert) {
      // Pins the fix for the whole-branch review's Important finding: the
      // documented `<:icon><Spinner @size='sm' /></:icon>` pattern used to
      // render oversized (Spinner's 24px `sm` vs the 20px icon slot) because
      // the slot's classes landed on the wrapping `<span>` only, never on
      // the yielded content. The real recipe
      // (`packages/theme/src/components/alert.ts`) now makes the icon slot
      // `inline-flex items-center justify-center` at a fixed size, with
      // `[&>*]:size-full` forcing whatever lands inside — a `Spinner`, a raw
      // `<svg>`, or anything else — to fill that box instead of rendering at
      // its own size. This test registers that same pattern locally (this
      // file's shared custom recipe otherwise only tags slots with plain,
      // unstyled class names) and proves it against a deliberately
      // oversized yielded element.
      registerCustomStyles({
        alert: customAlertStyles([
          'alert-icon',
          'size-5 inline-flex items-center justify-center [&>*]:size-full'
        ])
      });

      try {
        await render(
          <template>
            <Alert @title="Syncing">
              <:icon>
                <svg
                  data-test-id="oversized-icon"
                  class="w-6 h-6"
                  viewBox="0 0 24 24"
                ><circle cx="12" cy="12" r="10" /></svg>
              </:icon>
            </Alert>
          </template>
        );

        const slot = document.querySelector('[data-test-id="alert-icon"]');
        const yielded = document.querySelector(
          '[data-test-id="oversized-icon"]'
        );
        assert.ok(slot, 'the icon slot wrapper renders');
        assert.ok(yielded, 'the yielded icon renders inside it');

        const slotRect = (slot as Element).getBoundingClientRect();
        const yieldedRect = (yielded as Element).getBoundingClientRect();

        assert.strictEqual(
          yieldedRect.width,
          slotRect.width,
          'the yielded icon is stretched to the slot width instead of keeping its own w-6 (24px)'
        );
        assert.strictEqual(
          yieldedRect.height,
          slotRect.height,
          'the yielded icon is stretched to the slot height instead of keeping its own h-6 (24px)'
        );
      } finally {
        // Restore the file's shared custom recipe so later tests in this
        // module see the plain, unstyled `alert-icon` class they expect.
        registerCustomStyles({ alert: customAlertStyles() });
      }
    });
  });

  module('actions and closing', function () {
    test('the actions block renders', async function (assert) {
      await render(
        <template>
          <Alert @intent="danger" @title="Unable to connect">
            <:actions><button
                type="button"
                data-test-id="retry"
              >Retry</button></:actions>
          </Alert>
        </template>
      );

      assert.dom('[data-test-id="alert-actions"]').exists();
      assert
        .dom('[data-test-id="alert-actions"] [data-test-id="retry"]')
        .exists();
    });

    test('there is no actions element when the block is not passed', async function (assert) {
      await render(<template><Alert @title="Saved" /></template>);

      assert.dom('[data-test-id="alert-actions"]').doesNotExist();
    });

    test('the close button appears only when @onClose is passed', async function (assert) {
      await render(<template><Alert @title="Saved" /></template>);

      assert.dom('[data-test-id="alert-close-button"]').doesNotExist();
    });

    test('clicking the close button calls @onClose', async function (assert) {
      let closed = 0;
      const onClose = () => {
        closed++;
      };

      await render(
        <template><Alert @title="Saved" @onClose={{onClose}} /></template>
      );

      assert.dom('[data-test-id="alert-close-button"]').exists();

      await click('[data-test-id="alert-close-button"]');

      assert.strictEqual(closed, 1, 'the close button called @onClose once');
    });

    test('@closeButtonTitle names the close button, defaulting to Close', async function (assert) {
      const onClose = () => {};

      await render(
        <template>
          <Alert
            @title="Alpha"
            @onClose={{onClose}}
            data-test-id="default-title"
          />
          <Alert
            @title="Beta"
            @onClose={{onClose}}
            @closeButtonTitle="Dismiss the beta alert"
            data-test-id="custom-title"
          />
        </template>
      );

      assert
        .dom(
          '[data-test-id="default-title"] [data-test-id="alert-close-button"]'
        )
        .hasText('Close');
      assert
        .dom(
          '[data-test-id="custom-title"] [data-test-id="alert-close-button"]'
        )
        .hasText('Dismiss the beta alert');
    });
  });

  module('role', function () {
    test('warning and danger are assertive; the rest are polite', async function (assert) {
      await render(
        <template>
          <Alert @title="Default" data-test-id="d" />
          <Alert @intent="info" @title="Info" data-test-id="i" />
          <Alert @intent="success" @title="Success" data-test-id="s" />
          <Alert @intent="warning" @title="Warning" data-test-id="w" />
          <Alert @intent="danger" @title="Danger" data-test-id="x" />
        </template>
      );

      assert.dom('[data-test-id="d"]').hasAttribute('role', 'status');
      assert.dom('[data-test-id="i"]').hasAttribute('role', 'status');
      assert.dom('[data-test-id="s"]').hasAttribute('role', 'status');
      assert.dom('[data-test-id="w"]').hasAttribute('role', 'alert');
      assert.dom('[data-test-id="x"]').hasAttribute('role', 'alert');
    });

    test('@role overrides the intent-derived default', async function (assert) {
      await render(
        <template>
          <Alert
            @intent="danger"
            @title="Quiet"
            @role="status"
            data-test-id="quiet"
          />
          <Alert
            @intent="info"
            @title="Loud"
            @role="alert"
            data-test-id="loud"
          />
        </template>
      );

      assert.dom('[data-test-id="quiet"]').hasAttribute('role', 'status');
      assert.dom('[data-test-id="loud"]').hasAttribute('role', 'alert');
    });

    test("@role='none' emits no role attribute", async function (assert) {
      await render(
        <template>
          <Alert
            @intent="danger"
            @title="Static"
            @role="none"
            data-test-id="static"
          />
        </template>
      );

      assert.dom('[data-test-id="static"]').exists();
      assert.dom('[data-test-id="static"]').doesNotHaveAttribute('role');
    });
  });

  module('custom styling', function () {
    test('the recipe puts each slot class on its own element', async function (assert) {
      const onClose = () => {};

      await render(
        <template>
          <Alert @title="Saved" @description="All good." @onClose={{onClose}}>
            <:actions><button type="button">Undo</button></:actions>
          </Alert>
        </template>
      );

      assert.dom('[data-test-id="alert"]').hasClass('alert-base');
      assert.dom('[data-test-id="alert-content"]').hasClass('alert-content');
      assert.dom('[data-test-id="alert-title"]').hasClass('alert-title');
      assert
        .dom('[data-test-id="alert-description"]')
        .hasClass('alert-description');
      assert.dom('[data-test-id="alert-icon"]').hasClass('alert-icon');
      assert.dom('[data-test-id="alert-actions"]').hasClass('alert-actions');
      assert
        .dom('[data-test-id="alert-close-button"]')
        .hasClass('alert-close-button');
    });

    test('hasDescription tracks the argument and the block', async function (assert) {
      await render(
        <template>
          <Alert @title="Bare" data-test-id="bare" />
          <Alert @title="Arg" @description="Some copy." data-test-id="arg" />
          <Alert @title="Block" data-test-id="block">
            <:description>Some copy.</:description>
          </Alert>
        </template>
      );

      assert
        .dom('[data-test-id="bare"] .alert-inner')
        .hasClass('no-description');
      assert
        .dom('[data-test-id="arg"] .alert-inner')
        .hasClass('has-description');
      assert
        .dom('[data-test-id="block"] .alert-inner')
        .hasClass('has-description');
    });

    test('@class merges onto the root element', async function (assert) {
      await render(
        <template><Alert @title="Saved" @class="my-alert" /></template>
      );

      assert.dom('[data-test-id="alert"]').hasClass('my-alert');
      assert.dom('[data-test-id="alert"]').hasClass('alert-base');
    });

    test('@classes targets individual slots', async function (assert) {
      const onClose = () => {};

      await render(
        <template>
          <Alert
            @title="Saved"
            @description="All good."
            @onClose={{onClose}}
            @classes={{hash
              base="my-base"
              title="my-title"
              description="my-description"
              icon="my-icon"
              actions="my-actions"
              closeButton="my-close"
            }}
          >
            <:actions><button type="button">Undo</button></:actions>
          </Alert>
        </template>
      );

      assert.dom('[data-test-id="alert"]').hasClass('my-base');
      assert.dom('[data-test-id="alert-title"]').hasClass('my-title');
      assert
        .dom('[data-test-id="alert-description"]')
        .hasClass('my-description');
      assert.dom('[data-test-id="alert-icon"]').hasClass('my-icon');
      assert.dom('[data-test-id="alert-actions"]').hasClass('my-actions');
      assert.dom('[data-test-id="alert-close-button"]').hasClass('my-close');
    });
  });
});
