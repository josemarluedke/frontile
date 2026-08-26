import { module, test } from 'qunit';
import { ListManager, canDeselectKey } from 'frontile/utils/listManager';

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

    test('canDeselect reports what selecting the item would do', function (assert) {
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

        const canDeselect = manager.canDeselect('a');
        manager.selectItem(manager.atKey('a'));

        assert.strictEqual(
          canDeselect,
          !reported[0]?.includes('a'),
          `canDeselect matches the selection the list produces (${label})`
        );

        container.replaceChildren();
      }
    });

    test('canDeselect is false for a key that is not selected', function (assert) {
      const { manager } = buildSelection({
        selectionMode: 'multiple',
        allowEmpty: true,
        keys: ['a', 'b'],
        selectedKeys: ['a']
      });

      assert.false(manager.canDeselect('b'));
    });

    test('canDeselect counts selections whose items are not rendered', function (assert) {
      const { manager } = buildSelection({
        selectionMode: 'multiple',
        allowEmpty: false,
        keys: ['a'],
        selectedKeys: ['a', 'filtered-out']
      });

      assert.true(
        manager.canDeselect('a'),
        'a selection hidden by a filter still counts as a second selection'
      );
    });
  });
});
