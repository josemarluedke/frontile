import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, triggerKeyEvent, findAll, focus } from '@ember/test-helpers';
import { RovingFocus } from 'frontile';

module(
  'Integration | Utility | roving-focus | @frontile/utilities',
  function (hooks) {
    setupRenderingTest(hooks);

    test('arrow keys move focus horizontally and wrap', async function (assert) {
      const activated: string[] = [];
      const roving = new RovingFocus(() => ({
        orientation: 'horizontal' as const,
        activationMode: 'automatic' as const,
        onActivate: (el: HTMLElement) => activated.push(el.textContent ?? '')
      }));

      await render(
        <template>
          <div>
            <button type="button" {{roving.setupItem true false}}>A</button>
            <button type="button" {{roving.setupItem false false}}>B</button>
            <button type="button" {{roving.setupItem false false}}>C</button>
          </div>
        </template>
      );

      const items = findAll('button') as HTMLButtonElement[];
      await focus(items[0]!);

      await triggerKeyEvent(items[0]!, 'keydown', 'ArrowRight');
      assert.strictEqual(document.activeElement, items[1], 'moves to B');

      await triggerKeyEvent(items[1]!, 'keydown', 'ArrowRight');
      assert.strictEqual(document.activeElement, items[2], 'moves to C');

      await triggerKeyEvent(items[2]!, 'keydown', 'ArrowRight');
      assert.strictEqual(document.activeElement, items[0], 'wraps to A');

      await triggerKeyEvent(items[0]!, 'keydown', 'ArrowLeft');
      assert.strictEqual(
        document.activeElement,
        items[2],
        'wraps backwards to C'
      );

      assert.deepEqual(
        activated,
        ['B', 'C', 'A', 'C'],
        'automatic activation fires for every move'
      );
    });

    test('vertical orientation uses the up and down arrows', async function (assert) {
      const roving = new RovingFocus(() => ({
        orientation: 'vertical' as const
      }));

      await render(
        <template>
          <div>
            <button type="button" {{roving.setupItem true false}}>A</button>
            <button type="button" {{roving.setupItem false false}}>B</button>
          </div>
        </template>
      );

      const items = findAll('button') as HTMLButtonElement[];
      await focus(items[0]!);

      await triggerKeyEvent(items[0]!, 'keydown', 'ArrowDown');
      assert.strictEqual(
        document.activeElement,
        items[1],
        'ArrowDown moves forward'
      );

      await triggerKeyEvent(items[1]!, 'keydown', 'ArrowRight');
      assert.strictEqual(
        document.activeElement,
        items[1],
        'ArrowRight is ignored on a vertical group'
      );
    });

    test('Home and End jump to the first and last enabled items', async function (assert) {
      const roving = new RovingFocus(() => ({}));

      await render(
        <template>
          <div>
            <button type="button" {{roving.setupItem false true}}>A</button>
            <button type="button" {{roving.setupItem true false}}>B</button>
            <button type="button" {{roving.setupItem false false}}>C</button>
            <button type="button" {{roving.setupItem false true}}>D</button>
          </div>
        </template>
      );

      const items = findAll('button') as HTMLButtonElement[];
      await focus(items[1]!);

      await triggerKeyEvent(items[1]!, 'keydown', 'End');
      assert.strictEqual(
        document.activeElement,
        items[2],
        'End skips the disabled last item'
      );

      await triggerKeyEvent(items[2]!, 'keydown', 'Home');
      assert.strictEqual(
        document.activeElement,
        items[1],
        'Home skips the disabled first item'
      );
    });

    test('disabled items are skipped by arrow navigation', async function (assert) {
      const roving = new RovingFocus(() => ({}));

      await render(
        <template>
          <div>
            <button type="button" {{roving.setupItem true false}}>A</button>
            <button type="button" {{roving.setupItem false true}}>B</button>
            <button type="button" {{roving.setupItem false false}}>C</button>
          </div>
        </template>
      );

      const items = findAll('button') as HTMLButtonElement[];
      await focus(items[0]!);

      await triggerKeyEvent(items[0]!, 'keydown', 'ArrowRight');
      assert.strictEqual(
        document.activeElement,
        items[2],
        'skips the disabled B'
      );
    });

    test('exactly one item is tabbable, and it is the selected one', async function (assert) {
      const roving = new RovingFocus(() => ({}));

      await render(
        <template>
          <div>
            <button type="button" {{roving.setupItem false false}}>A</button>
            <button type="button" {{roving.setupItem true false}}>B</button>
            <button type="button" {{roving.setupItem false false}}>C</button>
          </div>
        </template>
      );

      const items = findAll('button') as HTMLButtonElement[];
      assert.deepEqual(
        items.map((i) => i.tabIndex),
        [-1, 0, -1],
        'only the selected item is tabbable'
      );
    });

    test('with nothing selected the first enabled item is tabbable', async function (assert) {
      const roving = new RovingFocus(() => ({}));

      await render(
        <template>
          <div>
            <button type="button" {{roving.setupItem false true}}>A</button>
            <button type="button" {{roving.setupItem false false}}>B</button>
            <button type="button" {{roving.setupItem false false}}>C</button>
          </div>
        </template>
      );

      const items = findAll('button') as HTMLButtonElement[];
      assert.deepEqual(
        items.map((i) => i.tabIndex),
        [-1, 0, -1],
        'the group is still reachable by Tab'
      );
    });

    test('manual activation moves focus without activating, until Enter', async function (assert) {
      const activated: string[] = [];
      const roving = new RovingFocus(() => ({
        activationMode: 'manual' as const,
        onActivate: (el: HTMLElement) => activated.push(el.textContent ?? '')
      }));

      await render(
        <template>
          <div>
            <button type="button" {{roving.setupItem true false}}>A</button>
            <button type="button" {{roving.setupItem false false}}>B</button>
          </div>
        </template>
      );

      const items = findAll('button') as HTMLButtonElement[];
      await focus(items[0]!);

      await triggerKeyEvent(items[0]!, 'keydown', 'ArrowRight');
      assert.strictEqual(document.activeElement, items[1], 'focus moved');
      assert.deepEqual(activated, [], 'nothing activated yet');

      await triggerKeyEvent(items[1]!, 'keydown', 'Enter');
      assert.deepEqual(activated, ['B'], 'Enter activates the focused item');
    });

    test('in RTL, horizontal arrows are swapped but vertical is unaffected', async function (assert) {
      const horizontal = new RovingFocus(() => ({
        orientation: 'horizontal' as const
      }));
      const vertical = new RovingFocus(() => ({
        orientation: 'vertical' as const
      }));

      await render(
        <template>
          <div dir="rtl">
            <div>
              <button
                type="button"
                {{horizontal.setupItem true false}}
              >A</button>
              <button
                type="button"
                {{horizontal.setupItem false false}}
              >B</button>
              <button
                type="button"
                {{horizontal.setupItem false false}}
              >C</button>
            </div>
            <div>
              <button type="button" {{vertical.setupItem true false}}>D</button>
              <button
                type="button"
                {{vertical.setupItem false false}}
              >E</button>
            </div>
          </div>
        </template>
      );

      const items = findAll('button') as HTMLButtonElement[];
      const [a, b, , d] = items;

      assert.strictEqual(
        getComputedStyle(a!).direction,
        'rtl',
        'the computed direction on the item itself is rtl'
      );

      await focus(a!);
      await triggerKeyEvent(a!, 'keydown', 'ArrowLeft');
      assert.strictEqual(
        document.activeElement,
        b,
        'ArrowLeft moves forward (to B) in RTL'
      );

      await triggerKeyEvent(b!, 'keydown', 'ArrowLeft');
      assert.strictEqual(
        document.activeElement,
        items[2],
        'ArrowLeft continues forward (to C) in RTL'
      );

      await triggerKeyEvent(items[2]!, 'keydown', 'ArrowLeft');
      assert.strictEqual(
        document.activeElement,
        a,
        'ArrowLeft wraps forward back to A in RTL'
      );

      await triggerKeyEvent(a!, 'keydown', 'ArrowRight');
      assert.strictEqual(
        document.activeElement,
        items[2],
        'ArrowRight moves backward, wrapping to C, in RTL'
      );

      await focus(d!);
      await triggerKeyEvent(d!, 'keydown', 'ArrowDown');
      assert.strictEqual(
        document.activeElement,
        items[4],
        'vertical ArrowDown still moves forward in an RTL context'
      );
    });

    test('a group with every item disabled does not throw and has no tab stop', async function (assert) {
      const roving = new RovingFocus(() => ({}));

      await render(
        <template>
          <div>
            <button type="button" {{roving.setupItem false true}}>A</button>
            <button type="button" {{roving.setupItem false true}}>B</button>
          </div>
        </template>
      );

      const items = findAll('button') as HTMLButtonElement[];
      assert.deepEqual(
        items.map((i) => i.tabIndex),
        [-1, -1],
        'nothing tabbable'
      );

      await triggerKeyEvent(items[0]!, 'keydown', 'ArrowRight');
      assert.ok(true, 'navigating an all-disabled group does not throw');
    });
  }
);
