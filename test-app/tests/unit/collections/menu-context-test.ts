import { module, test } from 'qunit';
import {
  createRootMenuContext,
  createChildMenuContext,
  type MenuContext,
  type SubHandle
} from 'frontile/components/collections/dropdown/menu-context';

function noop() {}

function buildRoot(
  overrides: Partial<Parameters<typeof createRootMenuContext>[0]> = {}
) {
  return createRootMenuContext({
    close: noop,
    subs: new Map<string, SubHandle>(),
    selectionMode: 'single',
    selectedKeys: ['a'],
    disabledKeys: ['b'],
    allowEmpty: true,
    onAction: noop,
    onSelectionChange: noop,
    variant: 'subtle',
    intent: 'primary',
    shortcutVariant: 'inherit',
    closeOnItemSelect: true,
    disableTransitions: true,
    transitionDuration: 0,
    ...overrides
  });
}

module('Unit | Collections | menu-context', function () {
  test('a root context is at depth 0 and closes itself as the root', function (assert) {
    let closed = 0;
    const context = buildRoot({
      close: () => {
        closed++;
      }
    });

    assert.strictEqual(context.depth, 0);

    context.closeRoot();
    context.closeSelf();
    assert.strictEqual(closed, 2, 'both close paths reach the root close');
  });

  test('a child context deepens, keeps the root close, and gets its own closeSelf', function (assert) {
    let rootClosed = 0;
    let selfClosed = 0;
    const root = buildRoot({
      close: () => {
        rootClosed++;
      }
    });

    const child = createChildMenuContext(root, {
      closeSelf: () => {
        selfClosed++;
      },
      subs: new Map<string, SubHandle>()
    });

    assert.strictEqual(child.depth, 1, 'one level deeper');

    child.closeRoot();
    assert.strictEqual(rootClosed, 1, 'closeRoot still reaches the root');
    assert.strictEqual(selfClosed, 0);

    child.closeSelf();
    assert.strictEqual(selfClosed, 1, 'closeSelf is the level own close');
    assert.strictEqual(rootClosed, 1, 'closeSelf did not close the root');
  });

  test('a child inherits every shared listbox setting', function (assert) {
    const root = buildRoot();
    const child = createChildMenuContext(root, {
      closeSelf: noop,
      subs: new Map<string, SubHandle>()
    });

    assert.strictEqual(child.selectionMode, 'single');
    assert.deepEqual(child.selectedKeys, ['a']);
    assert.deepEqual(child.disabledKeys, ['b']);
    assert.true(child.allowEmpty);
    assert.strictEqual(child.variant, 'subtle');
    assert.strictEqual(child.intent, 'primary');
    assert.strictEqual(child.shortcutVariant, 'inherit');
    assert.true(child.closeOnItemSelect);
    assert.true(child.disableTransitions);
    assert.strictEqual(child.transitionDuration, 0);
    assert.strictEqual(child.onAction, root.onAction, 'the same handler');
  });

  test('grandchildren keep deepening and still reach the root', function (assert) {
    let rootClosed = 0;
    const root = buildRoot({
      close: () => {
        rootClosed++;
      }
    });
    const child = createChildMenuContext(root, {
      closeSelf: noop,
      subs: new Map<string, SubHandle>()
    });
    const grandchild = createChildMenuContext(child, {
      closeSelf: noop,
      subs: new Map<string, SubHandle>()
    });

    assert.strictEqual(grandchild.depth, 2);
    grandchild.closeRoot();
    assert.strictEqual(rootClosed, 1);
  });

  test('each level registers subs into its own map', function (assert) {
    const rootSubs = new Map<string, SubHandle>();
    const childSubs = new Map<string, SubHandle>();
    const handle: SubHandle = { open: noop, close: noop };

    const root = buildRoot({ subs: rootSubs });
    const child = createChildMenuContext(root, {
      closeSelf: noop,
      subs: childSubs
    });

    root.registerSub('root-sub', handle);
    child.registerSub('child-sub', handle);

    assert.strictEqual(rootSubs.get('root-sub'), handle);
    assert.false(rootSubs.has('child-sub'), 'levels do not share a registry');
    assert.strictEqual(childSubs.get('child-sub'), handle);

    root.unregisterSub('root-sub');
    assert.false(rootSubs.has('root-sub'), 'unregister removes it');
  });

  test('the subs map identity is the caller own, so registration survives re-renders', function (assert) {
    const subs = new Map<string, SubHandle>();
    const first: MenuContext = buildRoot({ subs });
    const second: MenuContext = buildRoot({ subs });

    first.registerSub('x', { open: noop, close: noop });

    assert.true(
      second.subs.has('x'),
      'a context rebuilt around the same map sees earlier registrations'
    );
  });
});
