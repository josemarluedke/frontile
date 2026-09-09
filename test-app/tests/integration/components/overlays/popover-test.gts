import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  click,
  render,
  triggerEvent,
  triggerKeyEvent,
  find,
  settled,
  setupOnerror,
  resetOnerror,
  waitUntil
} from '@ember/test-helpers';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import { Popover } from 'frontile/overlays';
import { on } from '@ember/modifier';
import { cell } from 'ember-resources';

/**
 * `Popover` measures width inside a `requestAnimationFrame`, which does not
 * reliably land within `settled()` on a slow CI runner. Poll for the expected
 * value, then assert — the assertion still runs after a timeout so a genuine
 * mismatch reports a readable diff rather than a bare timeout.
 */
async function waitForTriggerWidth(
  content: HTMLElement,
  expected: string
): Promise<void> {
  try {
    await waitUntil(
      () => content.style.getPropertyValue('--trigger-width') === expected,
      { timeout: 2000 }
    );
  } catch {
    // fall through to the assertion for a readable failure
  }
}

/**
 * `triggerKeyEvent` never populates `event.code`, and the trigger's type-ahead
 * check is written against `code`. Dispatch the keydown directly so `code` and
 * the modifier flags are both what a real browser would send.
 */
function pressLetter(
  selector: string,
  key: string,
  options: Record<string, unknown> = {}
): Promise<void> {
  return triggerEvent(selector, 'keydown', {
    key,
    code: `Key${key.toUpperCase()}`,
    ...options
  });
}

module(
  'Integration | Component | Popover | @frontile/overlays',
  function (hooks) {
    setupRenderingTest(hooks);

    hooks.afterEach(function () {
      resetOnerror();
    });

    registerCustomStyles({
      backdrop: tv({ base: 'overlay__backdrop' }) as never,
      overlay: tv({
        base: 'overlay__content',
        variants: {
          inPlace: {
            true: 'overlay--in-place'
          }
        }
      }) as never
    });

    test('it works with trigger and opening content', async function (assert) {
      await render(
        <template>
          <Popover as |p|>
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger}}
              {{p.anchor}}
            >
              Trigger
            </button>

            <p.Content data-test-id="content">
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      assert.dom('[data-test-id="content"]').doesNotExist();
      await click('[data-test-id="trigger"]');

      assert.dom('[data-test-id="content"]').exists();
      assert.dom('[data-test-id="content"]').containsText('Content here');
      assert
        .dom(document.activeElement)
        .hasAttribute(
          'data-test-id',
          'content',
          'should have focused in the content'
        );
    });

    test('it works with trigger hover mode, never steals focus', async function (assert) {
      await render(
        <template>
          <button type="button" data-test-id="focused-element">Button</button>
          <Popover as |p|>
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger "hover"}}
              {{p.anchor}}
            >
              Trigger
            </button>

            <p.Content data-test-id="content">
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      (find('[data-test-id="focused-element"]') as HTMLButtonElement).focus();

      assert.dom('[data-test-id="content"]').doesNotExist();
      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');

      assert.dom('[data-test-id="content"]').exists();
      assert.dom('[data-test-id="content"]').containsText('Content here');
      // Hover must not move focus. Focusing the portaled overlay is what made
      // hover popovers visibly jump -- the browser scrolls the newly focused
      // element into view inside whatever scroll container it landed in.
      assert
        .dom(document.activeElement)
        .hasAttribute(
          'data-test-id',
          'focused-element',
          'should have left focus on the element that had it'
        );

      await triggerEvent('[data-test-id="trigger"]', 'mouseleave');
      assert.dom('[data-test-id="content"]').doesNotExist();

      // Focus was never moved by hover in the first place, so there is
      // nothing to "restore" -- it simply stays where it always was.
      assert
        .dom(document.activeElement)
        .hasAttribute(
          'data-test-id',
          'focused-element',
          'should still have focus on the element that had it'
        );
    });

    test('it renders accessibility attributes', async function (assert) {
      await render(
        <template>
          <Popover as |p|>
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger}}
              {{p.anchor}}
            >
              Trigger
            </button>

            <p.Content data-test-id="content">
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      assert.dom('[data-test-id="trigger"]').hasAria('haspopup', 'true');
      assert.dom('[data-test-id="trigger"]').hasAria('expanded', 'false');
      assert.dom('[data-test-id="trigger"]').hasAttribute('aria-controls');

      await click('[data-test-id="trigger"]');

      assert.dom('[data-test-id="trigger"]').hasAria('expanded', 'true');
      assert.dom('[data-test-id="content"]').hasAttribute('id');
    });

    test('it shows backdrop when @backdrop=none', async function (assert) {
      const backdrop = cell<'none' | 'faded' | undefined>('none');

      await render(
        <template>
          <Popover as |p|>
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger}}
              {{p.anchor}}
            >
              Trigger
            </button>

            <p.Content
              @backdrop={{backdrop.current}}
              @disableTransitions={{true}}
              data-test-id="content"
            >
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      await click('[data-test-id="trigger"]');

      assert.dom('.overlay__backdrop').doesNotExist();

      backdrop.current = 'faded';
      await settled();

      assert.dom('.overlay__backdrop').exists();
    });

    test('clicking outside closes menu', async function (assert) {
      let calledClosed = false;
      const didClose = () => {
        calledClosed = true;
      };

      await render(
        <template>
          <div id="outside" tabindex="0"></div>
          <Popover @didClose={{didClose}} as |p|>
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger}}
              {{p.anchor}}
            >
              Trigger
            </button>

            <p.Content @disableTransitions={{true}} data-test-id="content">
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      assert.dom('[data-test-id="content"]').doesNotExist();
      await click('[data-test-id="trigger"]');
      assert.dom('[data-test-id="content"]').exists();

      await click('#outside');
      assert.dom('[data-test-id="content"]').doesNotExist();
      assert.equal(calledClosed, true, 'should called didClose argument');
      assert
        .dom(document.activeElement)
        .hasAttribute(
          'data-test-id',
          'trigger',
          'should have restored the focus to the triggeer'
        );
    });

    test('controlled isOpen', async function (assert) {
      let isOpenValue = false;
      const isOpen = cell(false);
      const onOpenChange = (value: boolean) => {
        isOpenValue = value;
        isOpen.current = value;
      };

      await render(
        <template>
          <div id="outside" tabindex="0"></div>
          <Popover
            @isOpen={{isOpen.current}}
            @onOpenChange={{onOpenChange}}
            as |p|
          >
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger}}
              {{p.anchor}}
            >
              Trigger
            </button>

            <p.Content @disableTransitions={{true}} data-test-id="content">
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      assert.dom('[data-test-id="content"]').doesNotExist();
      await click('[data-test-id="trigger"]');
      assert.dom('[data-test-id="content"]').exists();
      assert.equal(isOpenValue, true);

      await click('#outside');
      assert.dom('[data-test-id="content"]').doesNotExist();
      assert.equal(isOpenValue, false);

      isOpen.current = true;
      await settled();
      assert.dom('[data-test-id="content"]').exists();

      isOpen.current = false;
      await settled();
      assert.dom('[data-test-id="content"]').doesNotExist();
    });

    test('it prevents trigger event bubbling', async function (assert) {
      assert.expect(1);

      const parentClick = () => {
        assert.ok(false, 'popover trigger should not bubble click event');
      };

      await render(
        <template>
          <Popover as |p|>
            <button type="button" {{on "click" parentClick}}>
              <button
                data-test-id="trigger"
                type="button"
                {{p.trigger}}
                {{p.anchor}}
              >
                Trigger
              </button>
            </button>
            <p.Content data-test-id="content">
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      await click('[data-test-id="trigger"]');

      assert.dom('[data-test-id="content"]').exists();
    });
    test('Escape on the trigger closes the popover', async function (assert) {
      await render(
        <template>
          <Popover as |p|>
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger}}
              {{p.anchor}}
            >
              Trigger
            </button>

            <p.Content @disableTransitions={{true}} data-test-id="content">
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      await click('[data-test-id="trigger"]');
      assert.dom('[data-test-id="content"]').exists();

      await triggerKeyEvent('[data-test-id="trigger"]', 'keydown', 'Escape');
      assert.dom('[data-test-id="content"]').doesNotExist();
    });

    test('ArrowDown and ArrowUp open the popover', async function (assert) {
      await render(
        <template>
          <Popover as |p|>
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger}}
              {{p.anchor}}
            >
              Trigger
            </button>

            <p.Content @disableTransitions={{true}} data-test-id="content">
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      await triggerKeyEvent('[data-test-id="trigger"]', 'keydown', 'ArrowDown');
      assert.dom('[data-test-id="content"]').exists('ArrowDown opens');

      await triggerKeyEvent('[data-test-id="trigger"]', 'keydown', 'Escape');
      assert.dom('[data-test-id="content"]').doesNotExist();

      // The `isClosing` window swallows a re-open for 90ms after a close.
      await new Promise((resolve) => setTimeout(resolve, 150));
      await settled();

      await triggerKeyEvent('[data-test-id="trigger"]', 'keydown', 'ArrowUp');
      assert.dom('[data-test-id="content"]').exists('ArrowUp opens');
    });

    test('Tab closes the popover without restoring focus to the trigger', async function (assert) {
      await render(
        <template>
          <Popover as |p|>
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger}}
              {{p.anchor}}
            >
              Trigger
            </button>

            <p.Content @disableTransitions={{true}} data-test-id="content">
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      await click('[data-test-id="trigger"]');
      assert.dom('[data-test-id="content"]').exists();

      await triggerKeyEvent('[data-test-id="trigger"]', 'keydown', 'Tab');
      assert.dom('[data-test-id="content"]').doesNotExist();
      assert
        .dom(document.activeElement)
        .doesNotHaveAttribute(
          'data-test-id',
          'focus was not pulled back to the trigger'
        );
    });

    test('a bare letter opens the popover, and Shift + letter still does', async function (assert) {
      await render(
        <template>
          <Popover as |p|>
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger}}
              {{p.anchor}}
            >
              Trigger
            </button>

            <p.Content @disableTransitions={{true}} data-test-id="content">
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      await pressLetter('[data-test-id="trigger"]', 'r');
      assert
        .dom('[data-test-id="content"]')
        .exists('a bare letter opens for type-ahead');

      await triggerKeyEvent('[data-test-id="trigger"]', 'keydown', 'Escape');
      await new Promise((resolve) => setTimeout(resolve, 150));
      await settled();
      assert.dom('[data-test-id="content"]').doesNotExist();

      // A capital letter is a legitimate type-ahead key, so Shift must not be
      // treated like the other modifiers.
      await pressLetter('[data-test-id="trigger"]', 'R', { shiftKey: true });
      assert
        .dom('[data-test-id="content"]')
        .exists('Shift + letter still opens');
    });

    test('a modifier + letter does not open the popover', async function (assert) {
      await render(
        <template>
          <Popover as |p|>
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger}}
              {{p.anchor}}
            >
              Trigger
            </button>

            <p.Content @disableTransitions={{true}} data-test-id="content">
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      // Cmd+R, Ctrl+F and Alt+C belong to the browser or the OS. They still
      // deliver a letter `key`, and the popover must stay out of the way.
      await pressLetter('[data-test-id="trigger"]', 'r', { metaKey: true });
      assert.dom('[data-test-id="content"]').doesNotExist('Cmd + R is ignored');

      await pressLetter('[data-test-id="trigger"]', 'f', { ctrlKey: true });
      assert
        .dom('[data-test-id="content"]')
        .doesNotExist('Ctrl + F is ignored');

      await pressLetter('[data-test-id="trigger"]', 'c', { altKey: true });
      assert.dom('[data-test-id="content"]').doesNotExist('Alt + C is ignored');

      // ...and the plain key still works, so the guard is not just disabling
      // type-ahead altogether.
      await pressLetter('[data-test-id="trigger"]', 'r');
      assert.dom('[data-test-id="content"]').exists();
    });

    test('aria-expanded tracks the open state, including external @isOpen changes', async function (assert) {
      const isOpen = cell(false);
      const onOpenChange = (value: boolean) => {
        isOpen.current = value;
      };

      await render(
        <template>
          <Popover
            @isOpen={{isOpen.current}}
            @onOpenChange={{onOpenChange}}
            as |p|
          >
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger}}
              {{p.anchor}}
            >
              Trigger
            </button>

            <p.Content @disableTransitions={{true}} data-test-id="content">
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      assert.dom('[data-test-id="trigger"]').hasAria('expanded', 'false');

      await click('[data-test-id="trigger"]');
      assert.dom('[data-test-id="trigger"]').hasAria('expanded', 'true');

      // Flipped from outside rather than through the trigger: the attribute has
      // to follow the arg, not just the interaction.
      isOpen.current = false;
      await settled();
      assert.dom('[data-test-id="trigger"]').hasAria('expanded', 'false');

      isOpen.current = true;
      await settled();
      assert.dom('[data-test-id="trigger"]').hasAria('expanded', 'true');
    });

    test('@didClose fires after the content is torn down, not synchronously on close', async function (assert) {
      const contentPresentAtCallTime: boolean[] = [];
      const didClose = () => {
        contentPresentAtCallTime.push(
          !!document.querySelector('[data-test-id="content"]')
        );
      };

      await render(
        <template>
          <Popover @didClose={{didClose}} as |p|>
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger}}
              {{p.anchor}}
            >
              Trigger
            </button>

            <p.Content data-test-id="content">
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      await click('[data-test-id="trigger"]');
      assert.dom('[data-test-id="content"]').exists();

      // Dispatch the closing click without settling, so we can see whether the
      // callback ran inside the event handler. Transitions are disabled in
      // tests (`Overlay.isAnimationEnabled` is false), so the exit is a
      // zero-duration `later` -- but it is still a `later`, scheduled from the
      // Overlay's teardown, and that ordering is what is under test.
      (find('[data-test-id="trigger"]') as HTMLElement).click();
      assert.deepEqual(
        contentPresentAtCallTime,
        [],
        '@didClose did not fire synchronously on close'
      );

      await settled();
      assert.strictEqual(
        contentPresentAtCallTime.length,
        1,
        '@didClose fired exactly once'
      );
      assert.false(
        contentPresentAtCallTime[0],
        'the content was already gone when @didClose fired'
      );
    });

    test('@didClose does not fire for a popover that was never open', async function (assert) {
      let calls = 0;
      const didClose = () => {
        calls += 1;
      };

      await render(
        <template>
          <Popover @didClose={{didClose}} as |p|>
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger}}
              {{p.anchor}}
            >
              Trigger
            </button>
            <button data-test-id="close" type="button" {{on "click" p.close}}>
              Close
            </button>

            <p.Content @disableTransitions={{true}} data-test-id="content">
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      await click('[data-test-id="close"]');
      await new Promise((resolve) => setTimeout(resolve, 150));
      await settled();

      assert.dom('[data-test-id="content"]').doesNotExist();
      assert.strictEqual(calls, 0, 'closing a closed popover closes nothing');
    });

    test('a declined close in controlled mode does not leave @didClose armed', async function (assert) {
      // In controlled mode `close()` only *asks* -- it calls `onOpenChange(false)`
      // and the consumer decides. A consumer that declines keeps the content
      // mounted, so the close never finishes and no `@didClose` is owed. The
      // debt must not sit armed waiting for some unrelated later teardown to
      // pay it out.
      let calls = 0;
      const didClose = () => {
        calls += 1;
      };

      const isOpen = cell(false);
      // Opens on request, but refuses every request to close.
      const onOpenChange = (value: boolean) => {
        if (value) {
          isOpen.current = true;
        }
      };

      await render(
        <template>
          <Popover
            @isOpen={{isOpen.current}}
            @onOpenChange={{onOpenChange}}
            @didClose={{didClose}}
            as |p|
          >
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger}}
              {{p.anchor}}
            >
              Trigger
            </button>
            <button data-test-id="open" type="button" {{on "click" p.open}}>
              Open
            </button>

            <p.Content
              @disableTransitions={{true}}
              @closeOnOutsideClick={{false}}
              data-test-id="content"
            >
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      await click('[data-test-id="trigger"]');
      assert.dom('[data-test-id="content"]').exists('the popover opened');

      // Ask to close; the consumer declines, so nothing closes.
      await click('[data-test-id="trigger"]');
      // Past the 90ms `isClosing` window, so the popover will accept an open
      // again -- the same as a person clicking twice rather than instantly.
      await new Promise((resolve) => setTimeout(resolve, 150));
      await settled();
      assert
        .dom('[data-test-id="content"]')
        .exists('the content is still mounted after the declined close');
      assert.strictEqual(calls, 0, '@didClose did not fire while still open');

      // Re-affirm that it is open. Nothing about the state changes, but any
      // outstanding "close in progress" is definitively over.
      await click('[data-test-id="open"]');
      assert.dom('[data-test-id="content"]').exists('still open');

      // Now tear the content down from outside, without going through
      // `close()`. A popover closed this way owes no `@didClose` -- and it must
      // not inherit one from the close the consumer declined earlier.
      isOpen.current = false;
      await settled();
      await new Promise((resolve) => setTimeout(resolve, 150));
      await settled();

      assert
        .dom('[data-test-id="content"]')
        .doesNotExist('the content is gone');
      assert.strictEqual(
        calls,
        0,
        '@didClose did not fire for the close the consumer declined'
      );
    });

    test('closing and unmounting in the same turn tears down cleanly', async function (assert) {
      const show = cell(true);
      const errors: unknown[] = [];
      setupOnerror((error: unknown) => {
        errors.push(error);
      });

      await render(
        <template>
          {{#if show.current}}
            <Popover as |p|>
              <button
                data-test-id="trigger"
                type="button"
                {{p.trigger}}
                {{p.anchor}}
              >
                Trigger
              </button>

              <p.Content @disableTransitions={{true}} data-test-id="content">
                Content here
              </p.Content>
            </Popover>
          {{/if}}
        </template>
      );

      await click('[data-test-id="trigger"]');
      assert.dom('[data-test-id="content"]').exists();

      // Close and unmount in the same turn, inside the 90ms `isClosing`
      // debounce window.
      (find('[data-test-id="trigger"]') as HTMLElement).click();
      show.current = false;
      await settled();

      // The debounce is 90ms; make sure it really has run, whether or not
      // `settled()` waited for it.
      await new Promise((resolve) => setTimeout(resolve, 150));
      await settled();

      assert.dom('[data-test-id="content"]').doesNotExist();
      assert.deepEqual(
        errors,
        [],
        'no error was raised while the popover tore down'
      );
    });

    test('the closing callback does not write tracked state while the popover is tearing down', async function (assert) {
      // `EmberGlimmerComponentManager#destroyComponent` flips the destroying
      // flag and only *schedules* the destruction, so the rest of that runloop
      // runs with `isDestroying === true` and `isDestroyed === false`. A
      // `debounce`/`later` callback whose timer expires in the same tick lands
      // right there, which is the case the guard in the closing callback exists
      // for. `willDestroy` runs inside that same window, so it is a faithful
      // place to run the callback from -- and Ember 6 does not throw for a
      // tracked write on a destroying component, so the tracked setter is
      // watched directly rather than waiting for an assertion that never comes.
      const isClosingDescriptor = Object.getOwnPropertyDescriptor(
        Popover.prototype,
        'isClosing'
      ) as PropertyDescriptor;
      assert.ok(
        typeof isClosingDescriptor?.set === 'function',
        '`isClosing` is a tracked accessor on the prototype'
      );

      let writesWhileDestroying = 0;
      let flagsInWindow:
        { destroying: boolean; destroyed: boolean } | undefined;

      Object.defineProperty(Popover.prototype, 'isClosing', {
        ...isClosingDescriptor,
        set(this: { isDestroying: boolean; isDestroyed: boolean }, value) {
          if (this.isDestroying || this.isDestroyed) {
            writesWhileDestroying += 1;
          }
          isClosingDescriptor.set?.call(this, value);
        }
      });

      const originalWillDestroy = Popover.prototype.willDestroy;
      Popover.prototype.willDestroy = function (this: Popover) {
        flagsInWindow = {
          destroying: this.isDestroying,
          destroyed: this.isDestroyed
        };
        (this as unknown as { didClose: () => void }).didClose();
        originalWillDestroy.call(this);
      };

      const show = cell(true);

      try {
        await render(
          <template>
            {{#if show.current}}
              <Popover as |p|>
                <button
                  data-test-id="trigger"
                  type="button"
                  {{p.trigger}}
                  {{p.anchor}}
                >
                  Trigger
                </button>

                <p.Content @disableTransitions={{true}} data-test-id="content">
                  Content here
                </p.Content>
              </Popover>
            {{/if}}
          </template>
        );

        await click('[data-test-id="trigger"]');

        // Close and unmount in the same turn.
        (find('[data-test-id="trigger"]') as HTMLElement).click();
        show.current = false;
        await settled();
      } finally {
        Object.defineProperty(
          Popover.prototype,
          'isClosing',
          isClosingDescriptor
        );
        Popover.prototype.willDestroy = originalWillDestroy;
      }

      assert.deepEqual(
        flagsInWindow,
        { destroying: true, destroyed: false },
        'the callback really ran in the destroying-but-not-destroyed window'
      );
      assert.strictEqual(
        writesWhileDestroying,
        0,
        'nothing was written to `isClosing` while destroying'
      );
    });

    test('trigger width comes from the trigger element by default', async function (assert) {
      await render(
        <template>
          <div style="width: 400px">
            <Popover as |p|>
              <button
                data-test-id="trigger"
                type="button"
                style="width: 120px"
                {{p.trigger}}
                {{p.anchor}}
              >
                Trigger
              </button>
              <p.Content data-test-id="content" @size="trigger">
                Content here
              </p.Content>
            </Popover>
          </div>
        </template>
      );

      await click('[data-test-id="trigger"]');

      const content = find('[data-test-id="content"]') as HTMLElement;
      await waitForTriggerWidth(content, '120px');
      assert.strictEqual(
        content.style.getPropertyValue('--trigger-width'),
        '120px',
        'the trigger element is the width reference'
      );
    });

    test('p.measureWidth overrides the trigger as the width reference', async function (assert) {
      await render(
        <template>
          <div style="width: 400px">
            <Popover as |p|>
              <div data-test-id="field" {{p.measureWidth}} style="width: 300px">
                <button
                  data-test-id="trigger"
                  type="button"
                  style="width: 120px"
                  {{p.trigger}}
                  {{p.anchor}}
                >
                  Trigger
                </button>
              </div>
              <p.Content data-test-id="content" @size="trigger">
                Content here
              </p.Content>
            </Popover>
          </div>
        </template>
      );

      await click('[data-test-id="trigger"]');

      const content = find('[data-test-id="content"]') as HTMLElement;
      await waitForTriggerWidth(content, '300px');
      assert.strictEqual(
        content.style.getPropertyValue('--trigger-width'),
        '300px',
        'the measured element wins over the trigger, regardless of install order'
      );
    });

    test('p.measureWidth keeps precedence when the trigger is resized', async function (assert) {
      await render(
        <template>
          <div style="width: 400px">
            <Popover as |p|>
              <div data-test-id="field" {{p.measureWidth}} style="width: 300px">
                <button
                  data-test-id="trigger"
                  type="button"
                  style="width: 120px"
                  {{p.trigger}}
                  {{p.anchor}}
                >
                  Trigger
                </button>
              </div>
              <p.Content data-test-id="content" @size="trigger">
                Content here
              </p.Content>
            </Popover>
          </div>
        </template>
      );

      await click('[data-test-id="trigger"]');

      // Resizing the trigger must not steal the width back from the measured
      // element: both modifiers observe their own element, so this would race
      // without an explicit precedence rule.
      (find('[data-test-id="trigger"]') as HTMLElement).style.width = '80px';
      await settled();
      await new Promise((resolve) => requestAnimationFrame(resolve));
      await settled();

      const content = find('[data-test-id="content"]') as HTMLElement;
      assert.strictEqual(
        content.style.getPropertyValue('--trigger-width'),
        '300px',
        'the trigger resize is ignored while measureWidth is installed'
      );
    });

    test('p.measureWidth tracks its own element resizing', async function (assert) {
      await render(
        <template>
          <div style="width: 400px">
            <Popover as |p|>
              <div data-test-id="field" {{p.measureWidth}} style="width: 300px">
                <button
                  data-test-id="trigger"
                  type="button"
                  {{p.trigger}}
                  {{p.anchor}}
                >
                  Trigger
                </button>
              </div>
              <p.Content data-test-id="content" @size="trigger">
                Content here
              </p.Content>
            </Popover>
          </div>
        </template>
      );

      await click('[data-test-id="trigger"]');

      (find('[data-test-id="field"]') as HTMLElement).style.width = '250px';
      await settled();
      await new Promise((resolve) => requestAnimationFrame(resolve));
      await settled();

      const content = find('[data-test-id="content"]') as HTMLElement;
      await waitForTriggerWidth(content, '250px');
      assert.strictEqual(
        content.style.getPropertyValue('--trigger-width'),
        '250px',
        'the measured element is re-measured when it changes size'
      );
    });

    test('hover: leaving and re-entering within the delay does not close it', async function (assert) {
      await render(
        <template>
          <Popover @openDelay={{10}} @closeDelay={{100}} as |p|>
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger "hover"}}
              {{p.anchor}}
            >
              Trigger
            </button>
            <p.Content data-test-id="content">Content here</p.Content>
          </Popover>
        </template>
      );

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');
      assert.dom('[data-test-id="content"]').exists('opens on enter');

      // Leave (schedules a close after closeDelay=100ms) and immediately
      // re-enter (should cancel that close outright, since the popover is
      // already open by the time it arrives). Dispatch the raw DOM events
      // directly rather than through `triggerEvent`: `triggerEvent` calls
      // `settled()` internally, and `settled()` waits out *any* pending
      // run-loop timer, however far out it is scheduled -- awaiting between
      // the two events would let the close fire before the re-entry could
      // ever race it.
      const trigger = find('[data-test-id="trigger"]') as HTMLElement;
      trigger.dispatchEvent(new MouseEvent('mouseleave', { bubbles: true }));
      trigger.dispatchEvent(new MouseEvent('mouseenter', { bubbles: true }));
      await settled();

      // openDelay (10ms) is deliberately much shorter than closeDelay
      // (100ms). Before this fix, `open` and `close` were scheduled on
      // separate debounce targets that could not cancel each other: the
      // re-entry's open debounce would fire (a no-op, already open) but the
      // earlier leave's close debounce would still be alive and independent,
      // firing 90ms later and closing the content anyway. `settled()`
      // blocks until that stray close timer fires, so if it were still
      // pending this assertion would see the content already closed.
      assert
        .dom('[data-test-id="content"]')
        .exists('re-entering cancels the pending close');
    });

    test('hover: moving the pointer into the content keeps it open', async function (assert) {
      await render(
        <template>
          <Popover @openDelay={{0}} @closeDelay={{20}} as |p|>
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger "hover"}}
              {{p.anchor}}
            >
              Trigger
            </button>
            <p.Content data-test-id="content">Content here</p.Content>
          </Popover>
        </template>
      );

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');
      assert.dom('[data-test-id="content"]').exists();

      // Crossing the offset gap: leave the trigger, arrive on the content
      // inside the close delay. Dispatched raw, not through `triggerEvent`,
      // so the still-pending close from the `mouseleave` cannot fire (via
      // `settled()`'s wait) before the `mouseenter` on the content has a
      // chance to cancel it.
      const trigger = find('[data-test-id="trigger"]') as HTMLElement;
      const content = find('[data-test-id="content"]') as HTMLElement;
      trigger.dispatchEvent(new MouseEvent('mouseleave', { bubbles: true }));
      content.dispatchEvent(new MouseEvent('mouseenter', { bubbles: true }));
      await settled();

      assert
        .dom('[data-test-id="content"]')
        .exists('content hover cancels the pending close');

      await triggerEvent('[data-test-id="content"]', 'mouseleave');
      assert
        .dom('[data-test-id="content"]')
        .doesNotExist('leaving the content closes it');
    });

    test('hover: @disableInteractive closes when the pointer moves onto the content', async function (assert) {
      await render(
        <template>
          <Popover @openDelay={{0}} @closeDelay={{50}} as |p|>
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger "hover"}}
              {{p.anchor}}
            >
              Trigger
            </button>
            <p.Content @disableInteractive={{true}} data-test-id="content">
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');
      assert.dom('[data-test-id="content"]').exists();

      // Leave the trigger and land on the content before the close fires --
      // exactly the sequence that keeps a popover open when the content is
      // interactive (see "moving the pointer into the content keeps it
      // open" above). `@disableInteractive` exists to make this the
      // opposite: `trackContentHover` never installs its listeners when it
      // is set, so nothing on the content can cancel the pending close.
      // Dispatched raw, and awaited once at the end, for the same reason as
      // the interactive-content test above.
      const trigger = find('[data-test-id="trigger"]') as HTMLElement;
      const content = find('[data-test-id="content"]') as HTMLElement;
      trigger.dispatchEvent(new MouseEvent('mouseleave', { bubbles: true }));
      content.dispatchEvent(new MouseEvent('mouseenter', { bubbles: true }));
      await settled();

      assert
        .dom('[data-test-id="content"]')
        .doesNotExist(
          '@disableInteractive ignores the pointer arriving on the content'
        );
    });

    test('hover: an adjacent trigger can open right after the first closes', async function (assert) {
      await render(
        <template>
          <Popover @openDelay={{0}} @closeDelay={{0}} as |p|>
            <button
              data-test-id="trigger-one"
              type="button"
              {{p.trigger "hover"}}
              {{p.anchor}}
            >
              One
            </button>
            <p.Content @disableTransitions={{true}} data-test-id="content-one">
              One content
            </p.Content>
          </Popover>
        </template>
      );

      await triggerEvent('[data-test-id="trigger-one"]', 'mouseenter');
      assert.dom('[data-test-id="content-one"]').exists();

      // Leave (closeDelay=0, so this closes synchronously and arms the 90ms
      // `isClosing` window that `close()` debounces `resetIsClosing` with)
      // and immediately re-enter (openDelay=0, so the reopen attempt also
      // runs synchronously, landing well inside that window). `isClosing`
      // used to block `open()` for the full 90ms after any close, so a
      // re-entry straight after leaving was swallowed. Dispatched raw and
      // settled once at the end, not through `triggerEvent`: `close()`'s
      // own `resetIsClosing` debounce is itself a run-loop timer, so
      // `await triggerEvent(...)` between the two events would wait it out
      // first via its internal `settled()` -- clearing `isClosing` before
      // the re-entry ever had a chance to land inside the window this test
      // needs to probe.
      const trigger = find('[data-test-id="trigger-one"]') as HTMLElement;
      trigger.dispatchEvent(new MouseEvent('mouseleave', { bubbles: true }));
      trigger.dispatchEvent(new MouseEvent('mouseenter', { bubbles: true }));
      await settled();

      assert
        .dom('[data-test-id="content-one"]')
        .exists('re-opening is not blocked by the closing window');
    });

    test('hover: keyboard focus opens it and blur closes it', async function (assert) {
      await render(
        <template>
          <Popover @openDelay={{0}} @closeDelay={{0}} as |p|>
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger "hover"}}
              {{p.anchor}}
            >
              Trigger
            </button>
            <p.Content data-test-id="content">Content here</p.Content>
          </Popover>
        </template>
      );

      // `focus()` alone does not set `:focus-visible` in every browser, so
      // dispatch a keyboard-origin focus the way a Tab would.
      const trigger = find('[data-test-id="trigger"]') as HTMLButtonElement;
      await triggerKeyEvent(document.body, 'keydown', 'Tab');
      trigger.focus();
      await triggerEvent(trigger, 'focusin');

      assert.dom('[data-test-id="content"]').exists('focus opens it');

      trigger.blur();
      await triggerEvent(trigger, 'focusout');
      assert.dom('[data-test-id="content"]').doesNotExist('blur closes it');
    });

    test('hover: a keyboard user can tab from the trigger into focusable content without it closing', async function (assert) {
      await render(
        <template>
          <Popover @openDelay={{0}} @closeDelay={{20}} as |p|>
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger "hover"}}
              {{p.anchor}}
            >
              Trigger
            </button>
            <p.Content data-test-id="content">
              <button data-test-id="content-button" type="button">
                Inside
              </button>
            </p.Content>
          </Popover>
        </template>
      );

      const trigger = find('[data-test-id="trigger"]') as HTMLButtonElement;
      await triggerKeyEvent(document.body, 'keydown', 'Tab');
      trigger.focus();
      await triggerEvent(trigger, 'focusin');
      assert.dom('[data-test-id="content"]').exists('focus opens it');

      // Tabbing from the trigger into a focusable element inside the content
      // fires the trigger's `focusout` (which schedules a close) and then
      // the content's `focusin` (which must cancel it). Dispatched raw and
      // awaited once, for the same reason as the pointer interleaving tests
      // above: `triggerEvent`'s internal `settled()` would otherwise block
      // on the pending close and let it fire before the content's `focusin`
      // had a chance to cancel it.
      const contentButton = find(
        '[data-test-id="content-button"]'
      ) as HTMLButtonElement;
      trigger.dispatchEvent(new FocusEvent('focusout', { bubbles: true }));
      contentButton.focus();
      contentButton.dispatchEvent(new FocusEvent('focusin', { bubbles: true }));
      await settled();

      assert
        .dom('[data-test-id="content"]')
        .exists('focus moving into the content cancels the pending close');

      contentButton.blur();
      await triggerEvent(contentButton, 'focusout');
      assert
        .dom('[data-test-id="content"]')
        .doesNotExist('leaving the content by blur still closes it');
    });

    test('hover: Escape closes it', async function (assert) {
      await render(
        <template>
          <Popover @openDelay={{0}} @closeDelay={{0}} as |p|>
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger "hover"}}
              {{p.anchor}}
            >
              Trigger
            </button>
            <p.Content data-test-id="content">Content here</p.Content>
          </Popover>
        </template>
      );

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');
      assert.dom('[data-test-id="content"]').exists();

      // Focus is nowhere near the trigger in hover mode, so the listener has
      // to be on the document.
      await triggerKeyEvent(document, 'keydown', 'Escape');
      assert.dom('[data-test-id="content"]').doesNotExist();
    });

    test('trigger aria="describedby" wires aria-describedby, not menu attributes', async function (assert) {
      await render(
        <template>
          <Popover @openDelay={{0}} @closeDelay={{0}} as |p|>
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger "hover" aria="describedby"}}
              {{p.anchor}}
            >
              Trigger
            </button>
            <p.Content data-test-id="content">Content here</p.Content>
          </Popover>
        </template>
      );

      assert
        .dom('[data-test-id="trigger"]')
        .doesNotHaveAttribute('aria-haspopup', 'a description is not a popup');
      assert
        .dom('[data-test-id="trigger"]')
        .doesNotHaveAttribute('aria-expanded');
      assert
        .dom('[data-test-id="trigger"]')
        .doesNotHaveAttribute(
          'aria-describedby',
          'nothing to describe while closed'
        );

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');

      const contentId = (find('[data-test-id="content"]') as HTMLElement).id;
      assert.ok(contentId, 'the content has an id');
      assert
        .dom('[data-test-id="trigger"]')
        .hasAttribute('aria-describedby', contentId);

      await triggerEvent('[data-test-id="trigger"]', 'mouseleave');
      await waitUntil(() => !find('[data-test-id="content"]'), {
        timeout: 2000
      });

      assert
        .dom('[data-test-id="trigger"]')
        .doesNotHaveAttribute(
          'aria-describedby',
          'removed once there is nothing to describe'
        );
    });

    test('trigger aria="none" sets no aria attributes', async function (assert) {
      await render(
        <template>
          <Popover as |p|>
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger "click" aria="none"}}
              {{p.anchor}}
            >
              Trigger
            </button>
            <p.Content data-test-id="content">Content here</p.Content>
          </Popover>
        </template>
      );

      assert
        .dom('[data-test-id="trigger"]')
        .doesNotHaveAttribute('aria-haspopup');
      assert
        .dom('[data-test-id="trigger"]')
        .doesNotHaveAttribute('aria-expanded');
      assert
        .dom('[data-test-id="trigger"]')
        .doesNotHaveAttribute('aria-controls');
      assert
        .dom('[data-test-id="trigger"]')
        .doesNotHaveAttribute('aria-describedby');
    });

    test('it renders an arrow and exposes the resolved placement', async function (assert) {
      // Pinned flush against the viewport's top edge, with no room above it
      // to render a "top" placement: floating-ui's `flip` middleware (wired
      // up by default in `Velcro`) must resolve to a `bottom*` placement
      // instead. Requesting `@placement="top"` and asserting the resolved
      // value starts with "bottom" is what proves `data-placement` tracks
      // `velcro.data.placement` rather than merely echoing back `@placement`
      // -- a buggy `data-placement={{@placement}}` would still read "top"
      // here and fail this assertion.
      await render(
        <template>
          <div style="position: fixed; top: 0; left: 0;">
            <Popover @placement="top" as |p|>
              <button
                data-test-id="trigger"
                type="button"
                {{p.trigger}}
                {{p.anchor}}
              >
                Trigger
              </button>
              <p.Content @arrow={{true}} data-test-id="content">
                Content here
              </p.Content>
            </Popover>
          </div>
        </template>
      );

      await click('[data-test-id="trigger"]');

      assert.dom('[data-test-id="content"] [data-part="arrow"]').exists();
      assert
        .dom('[data-test-id="content"]')
        .hasAttribute(
          'data-placement',
          /^bottom/,
          'carries the placement actually resolved by flip, not the requested "top"'
        );

      // The arrow only gets an inline offset once floating-ui's `arrow`
      // middleware has run against the *real* arrow element -- which only
      // happens once the `middleware` getter's `@cached` value has been
      // invalidated by `arrowEl` going from undefined to set, and produced a
      // fresh array containing `arrowMiddleware({ element: this.arrowEl })`.
      // A non-empty offset here is evidence that the appear-then-position
      // path still works under caching, not just that the element rendered.
      const arrowEl = find(
        '[data-test-id="content"] [data-part="arrow"]'
      ) as HTMLElement;
      const hasOffset = arrowEl.style.left !== '' || arrowEl.style.top !== '';
      assert.ok(
        hasOffset,
        'arrow element received a computed inline offset from the arrow middleware'
      );
    });

    test('it renders no arrow by default', async function (assert) {
      await render(
        <template>
          <Popover as |p|>
            <button
              data-test-id="trigger"
              type="button"
              {{p.trigger}}
              {{p.anchor}}
            >
              Trigger
            </button>
            <p.Content data-test-id="content">Content here</p.Content>
          </Popover>
        </template>
      );

      await click('[data-test-id="trigger"]');

      assert.dom('[data-test-id="content"] [data-part="arrow"]').doesNotExist();
    });
  }
);
