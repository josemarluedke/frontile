import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  triggerEvent,
  triggerKeyEvent,
  find,
  settled,
  setupOnerror,
  resetOnerror,
  waitUntil
} from '@ember/test-helpers';
import { Tooltip } from 'frontile/overlays';
import { cell } from 'ember-resources';

module(
  'Integration | Component | Tooltip | @frontile/overlays',
  function (hooks) {
    setupRenderingTest(hooks);

    hooks.afterEach(function () {
      resetOnerror();
    });

    test('it renders @content on hover and closes on leave', async function (assert) {
      await render(
        <template>
          <Tooltip
            @content="Add to library"
            @openDelay={{0}}
            @closeDelay={{0}}
            as |t|
          >
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Top</button>
          </Tooltip>
        </template>
      );

      assert.dom('[data-test-id="tooltip-content"]').doesNotExist();

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');
      assert.dom('[role="tooltip"]').exists();
      assert.dom('[role="tooltip"]').hasText('Add to library');

      await triggerEvent('[data-test-id="trigger"]', 'mouseleave');
      await waitUntil(() => !find('[role="tooltip"]'), { timeout: 2000 });
      assert.dom('[role="tooltip"]').doesNotExist();
    });

    test('it renders a rich content block', async function (assert) {
      await render(
        <template>
          <Tooltip @openDelay={{0}} @closeDelay={{0}} as |t|>
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Help</button>
            <t.Content>
              <div data-test-id="title">Help Information</div>
            </t.Content>
          </Tooltip>
        </template>
      );

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');
      assert
        .dom('[role="tooltip"] [data-test-id="title"]')
        .hasText('Help Information');
    });

    test('it is not a tab stop and carries role=tooltip', async function (assert) {
      await render(
        <template>
          <Tooltip @content="Hi" @openDelay={{0}} @closeDelay={{0}} as |t|>
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Trigger</button>
          </Tooltip>
        </template>
      );

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');

      assert.dom('[role="tooltip"]').hasAttribute('tabindex', '-1');
    });

    test('it wires aria-describedby only while open', async function (assert) {
      await render(
        <template>
          <Tooltip @content="Hi" @openDelay={{0}} @closeDelay={{0}} as |t|>
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Trigger</button>
          </Tooltip>
        </template>
      );

      assert
        .dom('[data-test-id="trigger"]')
        .doesNotHaveAttribute('aria-describedby');
      assert
        .dom('[data-test-id="trigger"]')
        .doesNotHaveAttribute('aria-haspopup');

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');

      const id = (find('[role="tooltip"]') as HTMLElement).id;
      assert
        .dom('[data-test-id="trigger"]')
        .hasAttribute('aria-describedby', id);
    });

    test('hovering the content keeps it open', async function (assert) {
      await render(
        <template>
          <Tooltip @content="Hi" @openDelay={{0}} @closeDelay={{30}} as |t|>
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Trigger</button>
          </Tooltip>
        </template>
      );

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');
      assert.dom('[role="tooltip"]').exists();

      // Crossing the offset gap: leave the trigger, arrive on the content
      // inside the close delay. Dispatched raw, not through `triggerEvent` --
      // `triggerEvent` awaits `settled()` after firing, which would wait out
      // the still-pending close from `mouseleave` (a real, runloop-tracked
      // timer) before the `mouseenter` on the content ever got a chance to
      // cancel it. See `popover-test.gts`'s "hover: moving the pointer into
      // the content keeps it open" for the same pattern.
      const trigger = find('[data-test-id="trigger"]') as HTMLElement;
      trigger.dispatchEvent(new MouseEvent('mouseleave', { bubbles: true }));
      (find('[role="tooltip"]') as HTMLElement).dispatchEvent(
        new MouseEvent('mouseenter', { bubbles: true })
      );
      await settled();

      assert.dom('[role="tooltip"]').exists('surviving the gap crossing');
    });

    test('Escape closes it', async function (assert) {
      await render(
        <template>
          <Tooltip @content="Hi" @openDelay={{0}} @closeDelay={{0}} as |t|>
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Trigger</button>
          </Tooltip>
        </template>
      );

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');
      assert.dom('[role="tooltip"]').exists();

      await triggerKeyEvent(document, 'keydown', 'Escape');
      await waitUntil(() => !find('[role="tooltip"]'), { timeout: 2000 });
      assert.dom('[role="tooltip"]').doesNotExist();
    });

    test('it renders an arrow and the resolved placement', async function (assert) {
      await render(
        <template>
          <Tooltip
            @content="Hi"
            @arrow={{true}}
            @placement="top"
            @openDelay={{0}}
            @closeDelay={{0}}
            as |t|
          >
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Trigger</button>
          </Tooltip>
        </template>
      );

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');

      assert.dom('[role="tooltip"] [data-part="arrow"]').exists();
      assert
        .dom('[role="tooltip"]')
        .hasAttribute('data-placement', /^(top|bottom)/);
    });

    test('the content does not clip the arrow', async function (assert) {
      // Regression test: the arrow element existing in the DOM (as the test
      // above asserts) is not enough to prove it is actually visible. The
      // `overlay` tv base this content inherits from sets `overflow-auto`,
      // which establishes a scrollport that clips anything protruding past
      // the box -- including half of the arrow, which sits centered on the
      // content's edge by design (see `positionArrow` in `popover.gts`). That
      // bug shipped with the arrow element present and correctly rotated and
      // positioned, so `[data-part="arrow"] exists()` passed throughout --
      // only the *rendered visibility* was broken.
      //
      // Asserting a computed style (e.g. `getComputedStyle(...).overflow`)
      // would not reliably constrain this in this suite: several sibling
      // test files (`overlay-test.gts`, `modal-test.gts`, `drawer-test.gts`,
      // `popover-test.gts`, `dropdown-test.gts`, `command-test.gts`) call
      // `registerCustomStyles` at module scope to replace the shared
      // `overlay` recipe with a bare `overlay__content` fixture that carries
      // no CSS at all -- and since `registerCustomStyles` mutates a
      // module-level singleton in `@frontile/theme` with no reset, that
      // override is live for the rest of the suite once any of those modules
      // loads, regardless of which test the runner actually executes.
      // Checking the literal class name is what survives that: the fix
      // (`overflow-visible` added to the `tooltip` theme's own `base`, unlike
      // the mocked-out `overlay` base) is asserted as a string, independent
      // of whether a real stylesheet is attached in this environment.
      await render(
        <template>
          <Tooltip
            @content="Hi"
            @arrow={{true}}
            @openDelay={{0}}
            @closeDelay={{0}}
            as |t|
          >
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Trigger</button>
          </Tooltip>
        </template>
      );

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');

      assert
        .dom('[role="tooltip"]')
        .hasClass(
          'overflow-visible',
          'the tooltip requests overflow: visible so it never clips the arrow protruding past its edge'
        );
    });

    test('@intent and @size apply theme classes', async function (assert) {
      await render(
        <template>
          <Tooltip
            @content="Hi"
            @intent="danger"
            @size="lg"
            @openDelay={{0}}
            @closeDelay={{0}}
            as |t|
          >
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Trigger</button>
          </Tooltip>
        </template>
      );

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');

      assert.dom('[role="tooltip"]').hasClass('bg-danger');
      assert.dom('[role="tooltip"]').hasClass('px-3');
    });

    test('@isDisabled never opens', async function (assert) {
      const isDisabled = cell(true);

      await render(
        <template>
          <Tooltip
            @content="Hi"
            @isDisabled={{isDisabled.current}}
            @openDelay={{0}}
            as |t|
          >
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Trigger</button>
          </Tooltip>
        </template>
      );

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');

      assert
        .dom('[role="tooltip"]')
        .doesNotExist('does not open while @isDisabled is true');

      await triggerEvent('[data-test-id="trigger"]', 'mouseleave');

      isDisabled.current = false;
      await settled();

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');

      assert
        .dom('[role="tooltip"]')
        .exists('the same markup opens once @isDisabled is false');
    });

    test('it supports controlled mode', async function (assert) {
      const isOpen = cell(false);
      const onOpenChange = (next: boolean) => {
        isOpen.current = next;
      };

      await render(
        <template>
          <Tooltip
            @content="Hi"
            @isOpen={{isOpen.current}}
            @onOpenChange={{onOpenChange}}
            @openDelay={{0}}
            @closeDelay={{0}}
            as |t|
          >
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Trigger</button>
          </Tooltip>
        </template>
      );

      assert.dom('[role="tooltip"]').doesNotExist();

      isOpen.current = true;
      await settled();
      assert.dom('[role="tooltip"]').exists('opens from the outside');

      isOpen.current = false;
      await settled();
      assert.dom('[role="tooltip"]').doesNotExist();
    });

    test('the anchor installs once across multiple open/close cycles', async function (assert) {
      // Proves the anchor-churn guard in `Tooltip.ensureAnchor`: without it,
      // `makeTrigger`'s wrapper modifier reinstalls `p.anchor` on every open
      // and close (because it also re-runs `p.trigger`, whose body reads
      // `this.isOpen` transitively to keep `aria-describedby` in sync), which
      // tears down and restarts floating-ui's `autoUpdate` loop each time.
      //
      // `ensureAnchor` is the one place that ever calls the real anchor
      // function, and it's declared as a regular (prototype) method
      // specifically so it can be wrapped here. Rather than inferring "did a
      // real install happen" from `this.anchoredElement` (which would just
      // re-implement the guard's own logic in the test and pass regardless of
      // whether the guard is actually there), the wrapper below substitutes
      // the `anchor` argument itself with a counting proxy before delegating
      // to the original method unconditionally -- so the counter increments
      // once for every *actual* invocation of the real anchor function, no
      // matter what `ensureAnchor`'s internals do.
      const originalEnsureAnchor = Tooltip.prototype.ensureAnchor;
      let anchorInvocationCount = 0;

      Tooltip.prototype.ensureAnchor = function (
        this: InstanceType<typeof Tooltip>,
        anchor: unknown,
        element: HTMLElement | SVGElement
      ) {
        const countingAnchor = (el: HTMLElement | SVGElement) => {
          anchorInvocationCount++;
          return (anchor as (el: HTMLElement | SVGElement) => unknown)(el);
        };

        originalEnsureAnchor.call(this, countingAnchor, element);
      };

      try {
        await render(
          <template>
            <Tooltip @content="Hi" @openDelay={{0}} @closeDelay={{0}} as |t|>
              <button
                data-test-id="trigger"
                type="button"
                {{t.trigger}}
              >Trigger</button>
            </Tooltip>
          </template>
        );

        // Two full open/close cycles -- the second is what would expose
        // churn: the guard must not call the real anchor again for an
        // element it already anchored.
        await triggerEvent('[data-test-id="trigger"]', 'mouseenter');
        assert.dom('[role="tooltip"]').exists('first cycle: open');
        await triggerEvent('[data-test-id="trigger"]', 'mouseleave');
        await waitUntil(() => !find('[role="tooltip"]'), { timeout: 2000 });

        await triggerEvent('[data-test-id="trigger"]', 'mouseenter');
        assert.dom('[role="tooltip"]').exists('second cycle: open');
        await triggerEvent('[data-test-id="trigger"]', 'mouseleave');
        await waitUntil(() => !find('[role="tooltip"]'), { timeout: 2000 });

        assert.strictEqual(
          anchorInvocationCount,
          1,
          'the anchor is installed exactly once across multiple open/close cycles'
        );
      } finally {
        Tooltip.prototype.ensureAnchor = originalEnsureAnchor;
      }
    });

    test('the anchor is torn down when the trigger element is removed while Tooltip survives', async function (assert) {
      // Proves fix round 2: fix round 1's anchor-churn guard (above) stopped
      // the anchor from being reinstalled on every open/close, but the only
      // teardown paths left reachable were `ensureAnchor` (a *different*
      // element arrives) and `Tooltip.willDestroy` (the whole component is
      // destroyed). Neither fires when the trigger element itself is removed
      // out from under a *surviving* `Tooltip` -- e.g. `{{#if this.show}}`
      // toggling to false -- so the anchor's `autoUpdate` loop leaked,
      // pointing at a detached element, until `Tooltip` itself unmounted.
      //
      // Same technique as the churn test above: `ensureAnchor` is the one
      // place that ever calls the real anchor function, so it's wrapped to
      // substitute `anchor` with a proxy. This time the proxy still invokes
      // the real anchor function (to preserve its real side effects -- it
      // sets `ember-velcro`'s tracked `hook` field), but discards whatever it
      // returns (in practice, nothing: `ember-velcro`'s `hook` returns no
      // cleanup at all) and substitutes a synthetic counting teardown of its
      // own. That measures the thing this test actually cares about --
      // whether `Tooltip`'s own bookkeeping (`ensureAnchor` /
      // `confirmAnchorTeardown` / `willDestroy`) calls whatever teardown it
      // was handed at the right time -- independent of what the real anchor
      // function happens to return.
      const originalEnsureAnchor = Tooltip.prototype.ensureAnchor;
      let anchorTeardownCount = 0;

      Tooltip.prototype.ensureAnchor = function (
        this: InstanceType<typeof Tooltip>,
        anchor: unknown,
        element: HTMLElement | SVGElement
      ) {
        const countingAnchor = (el: HTMLElement | SVGElement) => {
          (anchor as (el: HTMLElement | SVGElement) => unknown)(el);

          return () => {
            anchorTeardownCount++;
          };
        };

        originalEnsureAnchor.call(this, countingAnchor, element);
      };

      try {
        const show = cell(true);

        await render(
          <template>
            <Tooltip @content="Hi" @openDelay={{0}} @closeDelay={{0}} as |t|>
              {{#if show.current}}
                <button
                  data-test-id="trigger"
                  type="button"
                  {{t.trigger}}
                >Trigger</button>
              {{/if}}
            </Tooltip>
          </template>
        );

        assert.dom('[data-test-id="trigger"]').exists();
        assert.strictEqual(
          anchorTeardownCount,
          0,
          'the anchor has not been torn down while the trigger is still mounted'
        );

        show.current = false;
        await settled();

        assert.dom('[data-test-id="trigger"]').doesNotExist();
        assert.strictEqual(
          anchorTeardownCount,
          1,
          'the anchor is torn down once the trigger element is removed, even though Tooltip itself keeps rendering'
        );
      } finally {
        Tooltip.prototype.ensureAnchor = originalEnsureAnchor;
      }
    });

    test('it asserts when both @content and a <t.Content> block are used', async function (assert) {
      const errors: unknown[] = [];
      setupOnerror((error: unknown) => {
        errors.push(error);
      });

      await render(
        <template>
          <Tooltip @content="Add to library" as |t|>
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Top</button>
            <t.Content>Also here</t.Content>
          </Tooltip>
        </template>
      );

      assert.strictEqual(
        errors.length,
        1,
        'rendering both @content and a <t.Content> block raised exactly one error'
      );
      assert.ok(
        String((errors[0] as Error)?.message ?? errors[0]).includes(
          'received both @content and a <t.Content> block'
        ),
        'the raised error is the mutual-exclusion assertion, not some other failure'
      );
    });

    test('keyboard focus-visible opens it and blur closes it', async function (assert) {
      await render(
        <template>
          <Tooltip @content="Hi" @openDelay={{0}} @closeDelay={{0}} as |t|>
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Trigger</button>
          </Tooltip>
        </template>
      );

      // `focus()` alone does not set `:focus-visible` in every browser, so
      // dispatch a keyboard-origin focus the way a Tab would. Same technique
      // as `popover-test.gts`'s "hover: keyboard focus opens it and blur
      // closes it" -- this version goes through `Tooltip`'s own `t.trigger`,
      // which is what proves `Tooltip` wires the focus path at all.
      const trigger = find('[data-test-id="trigger"]') as HTMLButtonElement;
      await triggerKeyEvent(document.body, 'keydown', 'Tab');
      trigger.focus();
      await triggerEvent(trigger, 'focusin');

      assert.dom('[role="tooltip"]').exists('focus opens it');

      trigger.blur();
      await triggerEvent(trigger, 'focusout');
      assert.dom('[role="tooltip"]').doesNotExist('blur closes it');
    });

    test('@disableInteractive closes when the trigger is left', async function (assert) {
      await render(
        <template>
          <Tooltip
            @content="Hi"
            @disableInteractive={{true}}
            @openDelay={{0}}
            @closeDelay={{50}}
            as |t|
          >
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Trigger</button>
          </Tooltip>
        </template>
      );

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');
      assert.dom('[role="tooltip"]').exists();

      // Leave the trigger and land on the content before the close fires --
      // exactly the sequence that keeps a tooltip open when it's interactive
      // (see "hovering the content keeps it open" above). `@disableInteractive`
      // exists to make this the opposite, so this test must actually touch
      // the content -- a test that never moves the pointer onto it would pass
      // even with `disableInteractive` unimplemented. Dispatched raw, not
      // through `triggerEvent`, for the same reason as the other tests in
      // this file that interleave events inside a delay window: `triggerEvent`
      // awaits `settled()`, which would wait out the pending close timer
      // before the content's `mouseenter` had a chance to (wrongly) cancel it.
      const trigger = find('[data-test-id="trigger"]') as HTMLElement;
      trigger.dispatchEvent(new MouseEvent('mouseleave', { bubbles: true }));
      (find('[role="tooltip"]') as HTMLElement).dispatchEvent(
        new MouseEvent('mouseenter', { bubbles: true })
      );
      await settled();

      assert
        .dom('[role="tooltip"]')
        .doesNotExist(
          '@disableInteractive ignores the pointer arriving on the content'
        );
    });

    test('it honours non-zero @openDelay / @closeDelay', async function (assert) {
      await render(
        <template>
          <Tooltip @content="Hi" @openDelay={{120}} @closeDelay={{40}} as |t|>
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Trigger</button>
          </Tooltip>
        </template>
      );

      // Dispatched raw, not through `triggerEvent`: `triggerEvent` awaits
      // `settled()` internally, which would wait out the pending open timer
      // before this test ever got to assert on the not-yet-open state.
      //
      // Every other open/close test in this file uses `@openDelay={{0}}`/
      // `@closeDelay={{0}}`, so none of them proves the delay is actually
      // observed -- a scheduled callback resolves on the next runloop turn
      // either way, `@openDelay` honoured or not. Asserting "not open on the
      // very next tick" alone doesn't distinguish a real ~120ms delay from a
      // broken one that opens after 0ms: both are still closed one
      // microtask after `mouseenter`. So this measures wall-clock elapsed
      // time against `Date.now()` and asserts it actually took at least
      // close to the requested delay, not merely that it was asynchronous.
      const trigger = find('[data-test-id="trigger"]') as HTMLElement;
      const openStart = Date.now();
      trigger.dispatchEvent(new MouseEvent('mouseenter', { bubbles: true }));

      assert
        .dom('[role="tooltip"]')
        .doesNotExist('not yet open immediately after mouseenter');

      await waitUntil(() => find('[role="tooltip"]'), { timeout: 2000 });
      const openElapsed = Date.now() - openStart;
      assert.dom('[role="tooltip"]').exists('open once @openDelay elapses');
      assert.ok(
        openElapsed >= 100,
        `opening took at least close to the 120ms @openDelay (took ${openElapsed}ms)`
      );

      const closeStart = Date.now();
      trigger.dispatchEvent(new MouseEvent('mouseleave', { bubbles: true }));

      assert
        .dom('[role="tooltip"]')
        .exists('still open immediately after mouseleave');

      await waitUntil(() => !find('[role="tooltip"]'), { timeout: 2000 });
      const closeElapsed = Date.now() - closeStart;
      assert
        .dom('[role="tooltip"]')
        .doesNotExist('closed once @closeDelay elapses');
      assert.ok(
        closeElapsed >= 25,
        `closing took at least close to the 40ms @closeDelay (took ${closeElapsed}ms)`
      );
    });
  }
);
