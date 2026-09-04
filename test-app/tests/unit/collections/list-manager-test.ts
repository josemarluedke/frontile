import { module, test } from 'qunit';
import { ListManager, canDeselectKey } from 'frontile/utils/listManager';
// eslint-disable-next-line ember/no-runloop
import { run } from '@ember/runloop';
import { settled, getSettledState } from '@ember/test-helpers';

module('Unit | Utils | ListManager', function (hooks) {
  let container: HTMLUListElement;

  hooks.beforeEach(function () {
    container = document.createElement('ul');
    document.body.appendChild(container);
  });

  hooks.afterEach(function () {
    container.remove();
  });

  const buildManager = () =>
    new ListManager({
      selectionMode: 'single',
      autoActivateMode: 'none'
    });

  const addItem = (manager: ListManager, key: string) => {
    const el = document.createElement('li');
    el.dataset['key'] = key;
    container.appendChild(el);
    manager.register(el, {
      key,
      textValue: key,
      isActive: false,
      isDisabled: false,
      isSelected: false
    });
    return el;
  };

  const domOrder = () =>
    [...container.children].map((el) => (el as HTMLElement).dataset['key']);

  const walkDown = (manager: ListManager, steps: number) => {
    const visited: (string | undefined)[] = [];
    for (let i = 0; i < steps; i++) {
      manager.setNextOptionActive();
      visited.push(
        domOrder().find((key) => key && manager.atKey(key)?.isActive)
      );
    }
    return visited;
  };

  test('navigation follows DOM order after an element is moved without re-registering', function (assert) {
    const manager = buildManager();
    ['a', 'b', 'c'].forEach((key) => addItem(manager, key));

    // Glimmer moves the element of an item that persists across an update
    // instead of re-creating it, so no registration happens to trigger a
    // re-sort. Ordering must still come from the DOM.
    const last = container.lastElementChild as HTMLElement;
    container.insertBefore(last, container.firstChild);

    assert.deepEqual(domOrder(), ['c', 'a', 'b'], 'DOM was reordered');
    assert.deepEqual(
      walkDown(manager, 3),
      ['c', 'a', 'b'],
      'ArrowDown walks the list in DOM order'
    );
  });

  test('navigation follows DOM order while a previous generation is still registered with detached elements', function (assert) {
    const manager = buildManager();

    // Generation one.
    const oldEls = ['old-1', 'old-2', 'old-3'].map((key) =>
      addItem(manager, key)
    );

    // An async result replaces the list. Glimmer inserts the new elements and
    // installs their modifiers (register) before tearing down the old ones, so
    // for a moment the old, already-detached items are still registered.
    oldEls.forEach((el) => el.remove());
    const newKeys = ['new-1', 'new-2', 'new-3', 'new-4', 'new-5', 'new-6'];
    newKeys.forEach((key) => addItem(manager, key));
    oldEls.forEach((el) => manager.unregister(el));

    assert.deepEqual(domOrder(), newKeys, 'DOM holds only the new generation');
    assert.deepEqual(
      walkDown(manager, newKeys.length),
      newKeys,
      'ArrowDown walks the list in DOM order'
    );
  });

  test('detached items are skipped by navigation', function (assert) {
    const manager = buildManager();
    ['a', 'b', 'c'].forEach((key) => addItem(manager, key));

    // Detached but not yet unregistered.
    (container.children[1] as HTMLElement).remove();

    assert.deepEqual(
      walkDown(manager, 2),
      ['a', 'c'],
      'navigation visits only items still in the DOM'
    );
  });

  test('setLastOptionActive and setPreviousOptionActive use DOM order', function (assert) {
    const manager = buildManager();
    ['a', 'b', 'c'].forEach((key) => addItem(manager, key));

    const last = container.lastElementChild as HTMLElement;
    container.insertBefore(last, container.firstChild);
    // DOM is now c, a, b

    manager.setLastOptionActive();
    assert.true(manager.atKey('b')?.isActive, 'last in DOM order is active');

    manager.setPreviousOptionActive();
    assert.true(
      manager.atKey('a')?.isActive,
      'previous in DOM order is active'
    );

    manager.setFirstOptionActive();
    assert.true(manager.atKey('c')?.isActive, 'first in DOM order is active');
  });

  module('the allowEmpty deselect rule', function () {
    const buildSelection = (options: {
      selectionMode: 'single' | 'multiple';
      allowEmpty: boolean;
      keys: string[];
      selectedKeys: string[];
    }) => {
      const reported: string[][] = [];
      const manager = new ListManager({
        selectionMode: options.selectionMode,
        allowEmpty: options.allowEmpty,
        selectedKeys: options.selectedKeys,
        autoActivateMode: 'none',
        onSelectionChange: (keys) => reported.push(keys)
      });

      options.keys.forEach((key) => {
        const el = document.createElement('li');
        el.dataset['key'] = key;
        container.appendChild(el);
        manager.register(el, {
          key,
          textValue: key,
          isActive: false,
          isDisabled: false,
          isSelected: options.selectedKeys.includes(key)
        });
      });

      return { manager, reported };
    };

    test('canDeselectKey answers for the keys of a selection', function (assert) {
      assert.false(
        canDeselectKey(['a'], 'a'),
        'the last selection stays put when allowEmpty is left off'
      );
      assert.true(
        canDeselectKey(['a'], 'a', true),
        'allowEmpty lets the last selection go'
      );
      assert.true(
        canDeselectKey(['a', 'b'], 'a'),
        'one of several always goes'
      );
      assert.false(
        canDeselectKey(['a', 'b'], 'c'),
        'a key that is not selected has nothing to remove'
      );
      assert.false(canDeselectKey([], 'a', true), 'nothing to remove');
    });

    // Guards that the two call sites agree: the free `canDeselectKey` -- which
    // Select's chip close buttons ask directly -- and the deselect decision
    // `selectItem`/`#toggleSelectedItem` actually acts on. If one side is ever
    // changed without the other, a chip and its option would disagree about
    // the same removal, and this goes red.
    //
    // It does NOT check that the rule itself is right: both sides route through
    // `canDeselectKey`, so an inverted rule would agree with itself here. The
    // direct `canDeselectKey` assertions above are what pin the rule down.
    test('canDeselectKey agrees with what toggling the item does', function (assert) {
      const cases = [
        {
          selectionMode: 'multiple' as const,
          allowEmpty: false,
          selectedKeys: ['a']
        },
        {
          selectionMode: 'multiple' as const,
          allowEmpty: true,
          selectedKeys: ['a']
        },
        {
          selectionMode: 'multiple' as const,
          allowEmpty: false,
          selectedKeys: ['a', 'b']
        },
        {
          selectionMode: 'multiple' as const,
          allowEmpty: true,
          selectedKeys: ['a', 'b']
        },
        {
          selectionMode: 'single' as const,
          allowEmpty: false,
          selectedKeys: ['a']
        },
        {
          selectionMode: 'single' as const,
          allowEmpty: true,
          selectedKeys: ['a']
        }
      ];

      for (const testCase of cases) {
        const { manager, reported } = buildSelection({
          ...testCase,
          keys: ['a', 'b', 'c']
        });
        const label = `${testCase.selectionMode}, allowEmpty=${testCase.allowEmpty}, selected=[${testCase.selectedKeys.join()}]`;

        // Every key of the selection is rendered here, so the manager's own
        // selection snapshot is exactly `selectedKeys`.
        const canDeselect = canDeselectKey(
          testCase.selectedKeys,
          'a',
          testCase.allowEmpty
        );
        manager.selectItem(manager.atKey('a'));

        assert.strictEqual(
          canDeselect,
          !reported[0]?.includes('a'),
          `canDeselectKey matches the selection the list produces (${label})`
        );

        container.replaceChildren();
      }
    });

    test('the rule counts selections whose items are not rendered', function (assert) {
      const { manager, reported } = buildSelection({
        selectionMode: 'multiple',
        allowEmpty: false,
        keys: ['a'],
        selectedKeys: ['a', 'filtered-out']
      });

      manager.selectItem(manager.atKey('a'));

      assert.deepEqual(
        reported[0],
        ['filtered-out'],
        'a selection hidden by a filter still counts as a second selection, so `a` goes'
      );
    });
  });
  /**
   * Registration is per item, but the work that follows it -- ordering the
   * list against the document and telling the consumer what the list now
   * holds -- is per *batch*. Doing it once per registration made a 500-option
   * Select order 500 nodes 500 times over and queue 500 timers, each ordering
   * them again, none of them cancelled.
   */
  module('coalescing the work a batch of registrations causes', function () {
    type Report = { count: number; action: string; keys: string[] };

    const buildReporting = (
      autoActivateMode: 'none' | 'first' | 'selected'
    ): { manager: ListManager; reports: Report[] } => {
      const reports: Report[] = [];
      const manager = new ListManager({
        selectionMode: 'single',
        autoActivateMode,
        onListItemsChange: (items, action): void => {
          reports.push({
            count: items.length,
            action,
            keys: items.map((item) => item.key)
          });
        }
      });
      return { manager, reports };
    };

    test('a batch of registrations reports the list once, in DOM order', async function (assert) {
      const { manager, reports } = buildReporting('none');
      const keys = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

      run(() => {
        keys.forEach((key) => addItem(manager, key));
      });
      await settled();

      assert.strictEqual(
        reports.length,
        1,
        'eight registrations produced one report, not eight'
      );
      assert.deepEqual(reports[0]?.keys, keys, 'the report is in DOM order');
      assert.strictEqual(reports[0]?.action, 'add');
    });

    test('a batch of unregistrations reports the remaining list once', async function (assert) {
      const { manager, reports } = buildReporting('none');
      const els = ['a', 'b', 'c', 'd'].map((key) => addItem(manager, key));
      await settled();
      reports.length = 0;

      run(() => {
        els.slice(0, 2).forEach((el) => {
          el.remove();
          manager.unregister(el);
        });
      });
      await settled();

      assert.strictEqual(reports.length, 1, 'one report for the whole batch');
      assert.deepEqual(reports[0]?.keys, ['c', 'd']);
      assert.strictEqual(reports[0]?.action, 'remove');
    });

    test('a batch that replaces the list reports it once', async function (assert) {
      const { manager, reports } = buildReporting('none');
      const oldEls = ['old-1', 'old-2'].map((key) => addItem(manager, key));
      await settled();
      reports.length = 0;

      // The real shape of a Glimmer update: the new elements are inserted and
      // their modifiers installed before the old ones are torn down.
      run(() => {
        oldEls.forEach((el) => el.remove());
        ['new-1', 'new-2', 'new-3'].forEach((key) => addItem(manager, key));
        oldEls.forEach((el) => manager.unregister(el));
      });
      await settled();

      assert.strictEqual(reports.length, 1, 'one report for the whole batch');
      assert.deepEqual(
        reports[0]?.keys,
        ['new-1', 'new-2', 'new-3'],
        'and it holds only what is in the document once the batch has settled'
      );
    });

    test('the deferred activation runs once for the whole batch', async function (assert) {
      const activations: (string | undefined)[] = [];
      const manager = new ListManager({
        selectionMode: 'single',
        autoActivateMode: 'first',
        onActiveItemChange: (key): void => {
          activations.push(key);
        }
      });

      run(() => {
        ['a', 'b', 'c', 'd'].forEach((key) => addItem(manager, key));
      });
      await settled();

      assert.deepEqual(
        activations,
        ['a'],
        'the first item was activated once, not once per registration'
      );
      assert.true(manager.atKey('a')?.isActive);
    });

    test('teardown drops the work a batch had queued', async function (assert) {
      const { manager, reports } = buildReporting('first');

      // `ListManager` is a plain class, so the only teardown hook it has is
      // the destructor of the `setup` modifier that installed it. What that
      // destructor calls is this.
      run(() => {
        ['a', 'b', 'c'].forEach((key) => addItem(manager, key));
      });

      assert.true(
        getSettledState().hasPendingTimers,
        'the batch queued work for after the render'
      );

      manager.teardown();

      assert.false(
        getSettledState().hasPendingTimers,
        'teardown cancelled it rather than leaving it to fire against a torn-down tree'
      );

      await settled();
      assert.deepEqual(reports, [], 'the cancelled work never ran');
    });
  });

  module('the cost of moving the active item', function () {
    /**
     * How many times `fn` ordered the list against the document.
     *
     * Ordering starts by filtering the registered items on
     * `el.isConnected`, so one ordered scan reads `isConnected` exactly once
     * per registered item -- an exact, engine-independent count, where the
     * number of `compareDocumentPosition` calls a sort makes is not. Both are
     * recorded; only the scan count is asserted on.
     */
    const measureOrderedScans = (
      fn: () => void,
      itemCount: number
    ): { reads: number; comparisons: number; scans: number } => {
      const descriptor = Object.getOwnPropertyDescriptor(
        Node.prototype,
        'isConnected'
      ) as PropertyDescriptor;
      const readIsConnected = descriptor.get as () => boolean;
      const compare = Element.prototype.compareDocumentPosition;
      let reads = 0;
      let comparisons = 0;

      Object.defineProperty(Node.prototype, 'isConnected', {
        ...descriptor,
        get(this: Node): boolean {
          reads++;
          return readIsConnected.call(this);
        }
      });
      Element.prototype.compareDocumentPosition = function (
        this: Element,
        other: Node
      ): number {
        comparisons++;
        return compare.call(this, other);
      };

      try {
        fn();
      } finally {
        Object.defineProperty(Node.prototype, 'isConnected', descriptor);
        Element.prototype.compareDocumentPosition = compare;
      }

      return { reads, comparisons, scans: reads / itemCount };
    };

    // `activateItem` schedules a frame to scroll the new item into view, and
    // that callback reads `isConnected` too. Draining it before measuring
    // keeps it out of the count; a frame queued *during* the measured window
    // cannot pollute it, because rAF never runs synchronously.
    const nextFrame = (): Promise<void> =>
      new Promise<void>((resolve) => requestAnimationFrame(() => resolve()));

    test('an arrow keypress orders the document once, not twice', async function (assert) {
      const manager = buildManager();
      const itemCount = 50;
      for (let i = 0; i < itemCount; i++) {
        addItem(manager, `item-${i}`);
      }
      await settled();

      // Get to steady-state navigation, so the measured keypress is a plain
      // move rather than the first activation.
      manager.setFirstOptionActive();
      await settled();
      await nextFrame();

      const { reads, comparisons, scans } = measureOrderedScans(() => {
        manager.setNextOptionActive();
      }, itemCount);

      assert.strictEqual(
        scans,
        1,
        `one keypress ordered the list once (${reads} isConnected reads over ` +
          `${itemCount} items, ${comparisons} compareDocumentPosition calls); ` +
          `deriving the tab stop from the item being activated is what keeps ` +
          `this off a second ordered scan`
      );
      assert.true(
        manager.atKey('item-1')?.isActive,
        'and the active item still moved'
      );
      assert.true(
        manager.isTabStop('item-1'),
        'and the tab stop still followed it'
      );

      await settled();
      await nextFrame();
    });

    test('the tab stop still falls back to an ordered scan with nothing active', async function (assert) {
      const manager = buildManager();
      const itemCount = 20;
      for (let i = 0; i < itemCount; i++) {
        addItem(manager, `item-${i}`);
      }
      await settled();

      // No active item, so the shortcut cannot apply and the ordered scan is
      // genuinely needed to find the first option a user can act on.
      assert.true(
        manager.isTabStop('item-0'),
        'the first option owns the stop while nothing is active'
      );

      const { scans } = measureOrderedScans(() => {
        manager.updateArgs({ selectedKeys: ['item-3'] });
      }, itemCount);

      assert.strictEqual(
        scans,
        1,
        'the fallback path still orders the list, once'
      );
      assert.true(
        manager.isTabStop('item-3'),
        'and the stop moved to the selection'
      );

      await settled();
      await nextFrame();
    });
  });
});
