import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render } from '@ember/test-helpers';
import { hash } from '@ember/helper';
import { registerCustomStyles, useStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import { Alert } from 'frontile';
import { ownParts } from 'frontile/test-support';

// Captured before the registerCustomStyles call below swaps the recipe
// out for the placeholder these tests render against — this is the real
// shipped recipe, and the icon-clamp test below asserts against it.
const shippedAlert = useStyles().alert;

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
      layout: {
        inline: 'layout-inline',
        banner: {
          base: ['layout-banner'],
          inner: ['banner-inner'],
          content: ['banner-content'],
          closeButton: ['banner-close']
        }
      },
      hasDescription: {
        true: { inner: ['has-description'] },
        false: { inner: ['no-description'] }
      },
      // The component always passes `hasCloseButton` (see alert.gts), so the
      // placeholder recipe needs the variant declared even though none of
      // these tests assert on it.
      hasCloseButton: {
        true: {},
        false: {}
      }
    },
    defaultVariants: {
      intent: 'default',
      variant: 'default',
      layout: 'inline',
      hasDescription: false,
      hasCloseButton: false
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

      assert.dom('[data-component="alert"]').exists();
      assert.dom('[data-component="alert"]').hasAttribute('data-part', 'base');
      assert.dom('[data-part="title"]').hasText('Update available');
      assert
        .dom('[data-part="description"]')
        .hasText('A new version is ready.');
    });

    test('it omits the title and description elements when neither is given', async function (assert) {
      await render(<template><Alert /></template>);

      assert.dom('[data-component="alert"]').exists();
      assert.dom('[data-part="title"]').doesNotExist();
      assert.dom('[data-part="description"]').doesNotExist();
    });

    test('the title block overrides @title', async function (assert) {
      await render(
        <template>
          <Alert @title="From the argument">
            <:title>From the block</:title>
          </Alert>
        </template>
      );

      assert.dom('[data-part="title"]').hasText('From the block');
      assert.dom('[data-part="title"]').doesNotContainText('argument');
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

      assert.dom('[data-part="description"]').doesNotContainText('argument');
      assert.dom('[data-part="description"] li').exists({ count: 2 });
      assert
        .dom('[data-part="description"] li')
        .hasText('Check your internet connection');
    });

    test('attributes are forwarded to the root element', async function (assert) {
      await render(
        <template>
          <Alert @title="Saved" data-extra="yes" aria-label="Saved alert" />
        </template>
      );

      assert.dom('[data-component="alert"]').hasAttribute('data-extra', 'yes');
      assert
        .dom('[data-component="alert"]')
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

      assert.dom('[data-part="icon"]').doesNotExist();
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

      assert.dom('[data-part="icon"]').doesNotExist();
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

        const slot = document.querySelector('[data-part="icon"]');
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

  module('shipped recipe', function () {
    test('the real icon slot recipe carries the oversized-content clamp', function (assert) {
      // The "icon slot sizing" test above proves the *technique* works, but
      // it does so against a custom recipe registered locally in this file
      // (`customAlertStyles`) rather than the recipe Alert actually ships
      // with. If someone reverted the `icon` slot in
      // `packages/theme/src/components/alert.ts` back to a plain
      // `shrink-0 size-5`, that test would keep passing — nothing in it
      // touches the shipped recipe. This test closes that gap by asserting
      // against `shippedAlert`, the real `alert` recipe captured at module
      // scope (above) before `registerCustomStyles` replaced it, and
      // checking its generated `icon` class string still contains the
      // clamp.
      //
      // `shippedAlert` is captured via `useStyles().alert` at the top of
      // this file, above the `registerCustomStyles({ alert:
      // customAlertStyles() })` call. ES module imports are hoisted and
      // module-scope statements then run in source order, so that capture
      // happens before the placeholder recipe is registered — giving this
      // test the real production recipe rather than the placeholder that
      // `useStyles().alert` returns for the rest of this module's run.
      const classes = shippedAlert().icon();

      assert.true(
        classes.includes('[&>*]:size-full'),
        `expected the shipped icon slot to clamp yielded content with [&>*]:size-full, got: ${classes}`
      );
    });

    test('the real base recipe clips the tonal tint to its rounded corners', function (assert) {
      // `base` owns the radius, but `tonal` paints its tint on `inner`,
      // which has square corners. Without `overflow-hidden` on `base` that
      // tint paints over all four corners and a tonal Alert renders as a
      // rectangle with a rounded border drawn through it. That regressed
      // once already, and it is invisible to every other test here: they
      // render against the placeholder recipe, so only the shipped string
      // can be checked. Asserted against `shippedAlert` for the same reason
      // the icon-clamp test above is.
      const classes = shippedAlert().base();

      assert.true(
        classes.includes('overflow-hidden'),
        `expected the shipped base slot to clip the tonal tint with overflow-hidden, got: ${classes}`
      );
    });

    test('the real banner layout drops the radius and the border', function (assert) {
      // `rounded-none` and `border-0` are bare classes in a theme string, and
      // every other test in this file renders against the placeholder recipe
      // registered at module scope — so nothing else here can see whether the
      // shipped recipe still carries them. Same reasoning as the
      // `overflow-hidden` and icon-clamp guards above. The close-button
      // classes are pinned down here too: pulling the button out of the flex
      // flow is what keeps the centred text from shifting when the alert is
      // dismissible, so a dismissible and a non-dismissible banner still line
      // up — losing `absolute` or `mr-0` would silently undo that.
      const banner = shippedAlert({ layout: 'banner' });
      const base = banner.base();

      assert.true(
        base.includes('rounded-none'),
        `expected the shipped banner base to drop the radius, got: ${base}`
      );
      assert.true(
        base.includes('border-0'),
        `expected the shipped banner base to drop the border, got: ${base}`
      );
      assert.true(
        banner.inner().includes('justify-center'),
        `expected the shipped banner inner slot to centre the row, got: ${banner.inner()}`
      );
      assert.true(
        banner.content().includes('grow-0'),
        `expected the shipped banner content slot to drop grow, got: ${banner.content()}`
      );
      assert.true(
        banner.content().includes('text-center'),
        `expected the shipped banner content slot to centre its text, got: ${banner.content()}`
      );
      assert.true(
        banner.closeButton().includes('absolute'),
        `expected the shipped banner close button to be pinned out of the flex flow with absolute, got: ${banner.closeButton()}`
      );
      assert.true(
        banner.closeButton().includes('mr-0'),
        `expected the shipped banner close button to cancel the inline layout's margin with mr-0, got: ${banner.closeButton()}`
      );
    });

    test('the real banner layout reserves symmetric padding only when a close button is present', function (assert) {
      // The close button is pinned out of flow (see the test above), so
      // nothing about the row's own layout keeps a centred, wrapping title
      // from running underneath it. `inner` must gain horizontal padding
      // wide enough to clear the button when one is present, and must not
      // gain it — losing the alert's usable width for nothing — when it
      // isn't.
      const withCloseButton = shippedAlert({
        layout: 'banner',
        hasCloseButton: true
      }).inner();
      const withoutCloseButton = shippedAlert({
        layout: 'banner',
        hasCloseButton: false
      }).inner();

      assert.true(
        withCloseButton.includes('px-11'),
        `expected a dismissible banner's inner slot to reserve horizontal padding for the close button, got: ${withCloseButton}`
      );
      assert.false(
        withoutCloseButton.includes('px-11'),
        `expected a non-dismissible banner's inner slot to not reserve padding for a close button, got: ${withoutCloseButton}`
      );
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

      assert.dom('[data-part="actions"]').exists();
      assert.dom('[data-part="actions"] [data-test-id="retry"]').exists();
    });

    test('there is no actions element when the block is not passed', async function (assert) {
      await render(<template><Alert @title="Saved" /></template>);

      assert.dom('[data-part="actions"]').doesNotExist();
    });

    test('the close button appears only when @onClose is passed', async function (assert) {
      await render(<template><Alert @title="Saved" /></template>);

      assert.dom('[data-part="close-button"]').doesNotExist();
    });

    test('clicking the close button calls @onClose', async function (assert) {
      let closed = 0;
      const onClose = () => {
        closed++;
      };

      await render(
        <template><Alert @title="Saved" @onClose={{onClose}} /></template>
      );

      assert.dom('[data-part="close-button"]').exists();

      await click('[data-part="close-button"]');

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
        .dom('[data-test-id="default-title"] [data-part="close-button"]')
        .hasText('Close');
      assert
        .dom('[data-test-id="custom-title"] [data-part="close-button"]')
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

      // Scoped via `ownParts`, not a plain `[data-part="icon"]` selector:
      // the `<CloseButton>` this test also renders (via @onClose) has its
      // own `icon` part on its internal fallback svg, which a plain
      // descendant/global selector would also match.
      const root = document.querySelector(
        '[data-component="alert"]'
      ) as Element;
      assert.dom(root).hasClass('alert-base');
      assert.dom('[data-part="content"]').hasClass('alert-content');
      assert.dom('[data-part="title"]').hasClass('alert-title');
      assert.dom('[data-part="description"]').hasClass('alert-description');
      assert.dom(ownParts(root, 'icon')[0]).hasClass('alert-icon');
      assert.dom('[data-part="actions"]').hasClass('alert-actions');
      assert.dom('[data-part="close-button"]').hasClass('alert-close-button');
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

      assert.dom('[data-component="alert"]').hasClass('my-alert');
      assert.dom('[data-component="alert"]').hasClass('alert-base');
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

      // See `ownParts` note above: @onClose renders a `<CloseButton>` with
      // its own `icon` part, so `icon` must be selected via `ownParts`.
      const root = document.querySelector(
        '[data-component="alert"]'
      ) as Element;
      assert.dom(root).hasClass('my-base');
      assert.dom('[data-part="title"]').hasClass('my-title');
      assert.dom('[data-part="description"]').hasClass('my-description');
      assert.dom(ownParts(root, 'icon')[0]).hasClass('my-icon');
      assert.dom('[data-part="actions"]').hasClass('my-actions');
      assert.dom('[data-part="close-button"]').hasClass('my-close');
    });
  });

  module('layout', function () {
    test('it renders the inline layout by default', async function (assert) {
      await render(<template><Alert @title="Saved" /></template>);

      assert.dom('[data-component="alert"]').hasClass('layout-inline');
      assert.dom('[data-component="alert"]').doesNotHaveClass('layout-banner');
    });

    test('@layout=banner puts the banner classes on the right slots', async function (assert) {
      const onClose = () => {};

      await render(
        <template>
          <Alert
            @layout="banner"
            @title="Scheduled maintenance"
            @onClose={{onClose}}
          />
        </template>
      );

      assert.dom('[data-component="alert"]').hasClass('layout-banner');
      assert.dom('[data-component="alert"] .banner-inner').exists();
      assert.dom('[data-part="content"]').hasClass('banner-content');
      assert.dom('[data-part="close-button"]').hasClass('banner-close');
    });

    test('a banner still renders its actions and calls @onClose', async function (assert) {
      let closed = 0;
      const onClose = () => {
        closed++;
      };

      await render(
        <template>
          <Alert
            @layout="banner"
            @title="Update available"
            @onClose={{onClose}}
          >
            <:actions><button
                type="button"
                data-test-id="refresh"
              >Refresh</button></:actions>
          </Alert>
        </template>
      );

      assert
        .dom('[data-part="actions"] [data-test-id="refresh"]')
        .exists('the actions block still renders in banner mode');

      await click('[data-part="close-button"]');

      assert.strictEqual(
        closed,
        1,
        'the pinned close button still fires @onClose'
      );
    });
  });

  module('anatomy', function () {
    test('renders data-component="alert" on the root only, with data-part on every slot', async function (assert) {
      const onClose = () => {};

      await render(
        <template>
          <Alert
            @title="Update available"
            @description="A new version is ready."
            @onClose={{onClose}}
          >
            <:actions><button type="button">Undo</button></:actions>
          </Alert>
        </template>
      );

      const root = document.querySelector(
        '[data-component="alert"]'
      ) as Element;
      assert.dom(root).hasAttribute('data-part', 'base');
      assert.dom('[data-component="alert"] [data-part="inner"]').exists();
      // The `<CloseButton>` rendered below (via @onClose) has its own
      // `icon` part on its internal fallback svg, so alert's own `icon`
      // part must be resolved via `ownParts`, not a plain descendant
      // selector — otherwise this assertion would pass even if alert's own
      // icon never rendered at all.
      assert.strictEqual(ownParts(root, 'icon').length, 1);
      assert.dom('[data-component="alert"] [data-part="content"]').exists();
      assert.dom('[data-component="alert"] [data-part="title"]').exists();
      assert.dom('[data-component="alert"] [data-part="description"]').exists();
      assert.dom('[data-component="alert"] [data-part="actions"]').exists();
      assert
        .dom('[data-component="alert"] [data-part="close-button"]')
        .exists();
      assert.strictEqual(
        document.querySelectorAll('[data-component="alert"]').length,
        1,
        'data-component="alert" marks the root only, never a part'
      );
    });
  });
});
