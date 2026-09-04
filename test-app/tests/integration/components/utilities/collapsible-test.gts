import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, rerender, settled } from '@ember/test-helpers';
import { getPendingWaiterState, getWaiters } from '@ember/test-waiters';
import { Collapsible } from 'frontile';
import { cell } from 'ember-resources';

const WAITER_NAME = 'frontile:collapsible';

function collapsibleWaiter() {
  const waiter = getWaiters().find((w) => w.name === WAITER_NAME);

  if (!waiter) {
    throw new Error(`Could not find the '${WAITER_NAME}' test waiter`);
  }

  return waiter;
}

function isCollapsibleWaiterPending(): boolean {
  return WAITER_NAME in getPendingWaiterState().waiters;
}

function collapsibleElement(): HTMLElement {
  const element = document.querySelector('[data-test-id=collapsible]');

  if (!element) {
    throw new Error('Could not find the collapsible element');
  }

  return element as HTMLElement;
}

// `expand`/`contract` apply their target styles inside nested rAF callbacks.
async function flushAnimationFrames(count = 2): Promise<void> {
  for (let i = 0; i < count; i++) {
    await new Promise((resolve) => requestAnimationFrame(() => resolve(null)));
  }
}

// Polls instead of `settled()` so a leaked waiter fails the assertion below
// rather than hanging the test (and the whole suite) until QUnit times out.
async function waitForCollapsibleWaiter(timeout = 3000): Promise<void> {
  const start = Date.now();

  while (Date.now() - start < timeout) {
    if (!isCollapsibleWaiterPending()) {
      return;
    }
    await new Promise((resolve) => setTimeout(resolve, 25));
  }
}

module(
  'Integration | Component | @frontile/utilities/Collapsible',
  function (hooks) {
    setupRenderingTest(hooks);

    test('renders content and starts closed', async function (assert) {
      const isOpen = cell(false);
      await render(
        <template>
          <Collapsible @isOpen={{isOpen.current}} data-test-id="collapsible">
            Content
          </Collapsible>
        </template>
      );

      assert.dom('[data-test-id=collapsible]').hasText('Content');
      assert.dom('[data-test-id=collapsible]').hasStyle({ height: '0px' });
      assert.dom('[data-test-id=collapsible]').hasStyle({ opacity: '0' });
      assert.dom('[data-test-id=collapsible]').hasStyle({ overflow: 'hidden' });
    });

    test('renders content and starts open', async function (assert) {
      const isOpen = cell(true);
      await render(
        <template>
          <Collapsible @isOpen={{isOpen.current}} data-test-id="collapsible">
            Content
          </Collapsible>
        </template>
      );

      assert.dom('[data-test-id=collapsible]').hasText('Content');
      assert
        .dom('[data-test-id=collapsible]')
        .doesNotHaveStyle({ height: '0px' });
      assert.dom('[data-test-id=collapsible]').hasStyle({ opacity: '1' });
      assert
        .dom('[data-test-id=collapsible]')
        .hasStyle({ overflow: 'visible' });
    });

    test('expands content when opened; closes content when closed', async function (assert) {
      const isOpen = cell(false);
      await render(
        <template>
          <Collapsible @isOpen={{isOpen.current}} data-test-id="collapsible">
            Content
          </Collapsible>
        </template>
      );

      isOpen.current = true;
      await settled();

      assert.dom('[data-test-id=collapsible]').hasStyle({ opacity: '1' });
      assert.dom('[data-test-id=collapsible]').hasText('Content');
      assert
        .dom('[data-test-id=collapsible]')
        .hasStyle({ overflow: 'visible' });
      assert
        .dom('[data-test-id=collapsible]')
        .doesNotHaveStyle({ height: '0px' });

      isOpen.current = false;
      await settled();

      assert.dom('[data-test-id=collapsible]').hasStyle({ opacity: '0' });
      assert.dom('[data-test-id=collapsible]').hasStyle({ height: '0px' });
      assert.dom('[data-test-id=collapsible]').hasStyle({ overflow: 'hidden' });
    });

    test('renders initial height when set', async function (assert) {
      const isOpen = cell(false);
      await render(
        <template>
          <Collapsible
            @isOpen={{isOpen.current}}
            @initialHeight="2px"
            data-test-id="collapsible"
          >
            Content
          </Collapsible>
        </template>
      );

      assert.dom('[data-test-id=collapsible]').hasText('Content');
      assert.dom('[data-test-id=collapsible]').hasStyle({ height: '2px' });
      assert.dom('[data-test-id=collapsible]').hasStyle({ opacity: '1' });
      assert.dom('[data-test-id=collapsible]').hasStyle({ overflow: 'hidden' });

      isOpen.current = true;
      await settled();

      assert.dom('[data-test-id=collapsible]').hasStyle({ opacity: '1' });
      assert
        .dom('[data-test-id=collapsible]')
        .hasStyle({ overflow: 'visible' });
      assert.dom('[data-test-id=collapsible]').hasText('Content');
      assert
        .dom('[data-test-id=collapsible]')
        .doesNotHaveStyle({ height: '2px' });

      isOpen.current = false;
      await settled();

      assert.dom('[data-test-id=collapsible]').hasStyle({ opacity: '1' });
      assert.dom('[data-test-id=collapsible]').hasStyle({ height: '2px' });
      assert.dom('[data-test-id=collapsible]').hasStyle({ overflow: 'hidden' });
    });

    test('does not let @initialHeight inject extra CSS declarations', async function (assert) {
      await render(
        <template>
          <Collapsible
            @isOpen={{false}}
            @initialHeight="10px; position: fixed"
            data-test-id="collapsible"
          >
            Content
          </Collapsible>
        </template>
      );

      assert
        .dom('[data-test-id=collapsible]')
        .hasStyle(
          { position: 'static' },
          'the injected declaration is not applied'
        );
      assert.dom('[data-test-id=collapsible]').hasStyle({ overflow: 'hidden' });
    });

    test('keeps every legitimate @initialHeight value', async function (assert) {
      // `''` would mean the value was rejected, so assert on the inline style
      // the component actually wrote rather than the computed one. The CSSOM
      // re-serialises the math functions (Chrome reorders `calc` operands), so
      // those are matched loosely.
      const cases: [input: string, expected: string | RegExp][] = [
        ['10px', '10px'],
        ['2rem', '2rem'],
        ['50%', '50%'],
        ['0', '0px'],
        ['calc(1rem + 2px)', /^calc\(.*1rem.*\)$/],
        ['min(10px, 2rem)', /^min\(.*2rem.*\)$/],
        ['clamp(1px, 2rem, 3rem)', /^clamp\(.*2rem.*\)$/],
        ['var(--collapsible-height, 4px)', 'var(--collapsible-height, 4px)']
      ];

      for (const [input, expected] of cases) {
        const initialHeight = cell(input);

        await render(
          <template>
            <Collapsible
              @isOpen={{false}}
              @initialHeight={{initialHeight.current}}
              data-test-id="collapsible"
            >
              Content
            </Collapsible>
          </template>
        );

        const height = collapsibleElement().style.height;

        if (typeof expected === 'string') {
          assert.strictEqual(
            height,
            expected,
            `@initialHeight="${input}" is applied`
          );
        } else {
          assert.ok(
            expected.test(height),
            `@initialHeight="${input}" is applied (got "${height}")`
          );
        }
        assert.strictEqual(
          collapsibleElement().style.opacity,
          '1',
          `@initialHeight="${input}" counts as a real height, so content stays visible`
        );
      }
    });

    test('does not modify descendants when a transitionend bubbles up from a child', async function (assert) {
      await render(
        <template>
          <Collapsible @isOpen={{true}} data-test-id="collapsible">
            <div data-test-id="child">Content</div>
          </Collapsible>
        </template>
      );

      const collapsible = collapsibleElement();
      const child = document.querySelector(
        '[data-test-id=child]'
      ) as HTMLElement;

      for (const propertyName of ['height', 'opacity']) {
        child.dispatchEvent(
          new TransitionEvent('transitionend', {
            propertyName,
            bubbles: true
          })
        );
      }
      await settled();

      assert.strictEqual(
        child.style.height,
        '',
        'the child keeps its own height'
      );
      assert.strictEqual(
        child.style.overflow,
        '',
        'the child keeps its own overflow'
      );
      assert.strictEqual(
        collapsible.style.height,
        '',
        'a descendant transition does not resize the collapsible either'
      );

      // The collapsible's own transitions must still be handled.
      collapsible.dispatchEvent(
        new TransitionEvent('transitionend', { propertyName: 'height' })
      );
      await settled();

      assert.strictEqual(
        collapsible.style.height,
        'auto',
        'its own transitionend still resets the collapsible to height auto'
      );
      assert.strictEqual(
        child.style.height,
        '',
        'the child is still untouched'
      );
    });

    test('resets its own height and overflow when the open transition ends', async function (assert) {
      const isOpen = cell(false);
      await render(
        <template>
          <Collapsible @isOpen={{isOpen.current}} data-test-id="collapsible">
            Content
          </Collapsible>
        </template>
      );

      isOpen.current = true;
      await settled();

      const collapsible = collapsibleElement();

      assert.strictEqual(collapsible.style.height, 'auto', 'height is auto');
      assert.strictEqual(collapsible.style.overflow, '', 'overflow is cleared');
    });

    test('does not leak a test waiter when toggled twice before the transition finishes', async function (assert) {
      const isOpen = cell(false);
      await render(
        <template>
          <Collapsible @isOpen={{isOpen.current}} data-test-id="collapsible">
            Content
          </Collapsible>
        </template>
      );

      try {
        isOpen.current = true;
        await rerender();

        isOpen.current = false;
        await rerender();

        await waitForCollapsibleWaiter();

        assert.false(
          isCollapsibleWaiterPending(),
          'no collapsible test waiter is left pending after a rapid double toggle'
        );
      } finally {
        // Keep a leak from hanging teardown (and every test after it).
        collapsibleWaiter().reset();
      }

      await settled();
      assert.dom('[data-test-id=collapsible]').hasStyle({ height: '0px' });
    });

    test('ends the test waiter only once per toggle', async function (assert) {
      const waiter = collapsibleWaiter();
      const originalEndAsync = waiter.endAsync;
      let endCount = 0;

      waiter.endAsync = function (token: unknown) {
        endCount++;
        return originalEndAsync.call(this, token);
      };

      try {
        const isOpen = cell(false);
        await render(
          <template>
            <Collapsible @isOpen={{isOpen.current}} data-test-id="collapsible">
              Content
            </Collapsible>
          </template>
        );

        const collapsible = collapsibleElement();

        isOpen.current = true;
        await rerender();
        await flushAnimationFrames();

        assert.strictEqual(collapsible.style.opacity, '1', 'is expanding');

        // Both the opacity and the height transition can satisfy the
        // "opening finished" condition; only the first one may end the waiter.
        for (const propertyName of ['opacity', 'height']) {
          collapsible.dispatchEvent(
            new TransitionEvent('transitionend', { propertyName })
          );
        }

        await settled();

        assert.strictEqual(
          endCount,
          1,
          'endAsync is called exactly once for a single open toggle'
        );
        assert.false(isCollapsibleWaiterPending(), 'no waiter is left pending');
      } finally {
        waiter.endAsync = originalEndAsync;
        collapsibleWaiter().reset();
      }
    });
  }
);
