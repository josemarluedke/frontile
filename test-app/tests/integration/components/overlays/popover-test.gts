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

    test('it works with trigger hover mode, prevents focus restore', async function (assert) {
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
      assert
        .dom(document.activeElement)
        .hasAttribute(
          'data-test-id',
          'content',
          'should have focused in the content'
        );

      await triggerEvent('[data-test-id="trigger"]', 'mouseleave');
      assert.dom('[data-test-id="content"]').doesNotExist();

      assert
        .dom(document.activeElement)
        .doesNotHaveAttribute(
          'data-test-id',
          'should have not restored the focus'
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
  }
);
