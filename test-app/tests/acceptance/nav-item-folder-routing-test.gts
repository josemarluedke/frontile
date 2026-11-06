import { module, test } from 'qunit';
import { setupApplicationTest } from 'ember-qunit';
import { visit, click } from '@ember/test-helpers';
import { NavItem, NavLink } from 'frontile';

interface Handle {
  readonly isActive: boolean;
  readonly isHidden: boolean;
}

module('Acceptance | NavItem folder routing', function (hooks) {
  setupApplicationTest(hooks);

  const handles: Record<string, Handle> = {};
  const folderFor = (name: string) => ({
    registerItem(item: Handle) {
      handles[name] = item;
      return () => {};
    }
  });
  const first = folderFor('first');
  const second = folderFor('second');
  const override = folderFor('override');

  hooks.beforeEach(function () {
    for (const key of Object.keys(handles)) {
      delete handles[key];
    }
    this.owner.register(
      'template:sidebar-demo/second',
      <template>
        <NavItem @route="sidebar-demo.index" @folder={{first}}>First</NavItem>
        <NavItem
          @route="sidebar-demo.second"
          @folder={{second}}
        >Second</NavItem>
        <NavItem
          @route="sidebar-demo.second"
          @isActive={{false}}
          @folder={{override}}
        >Override</NavItem>
        <NavLink @route="sidebar-demo.index" id="to-first">Go</NavLink>
      </template>
    );
  });

  test('the folder handle reports route-derived active state', async function (assert) {
    await visit('/sidebar-demo/second');

    assert.true(handles['second']!.isActive, 'active on the current route');
    assert.false(handles['first']!.isActive, 'inactive on another route');
    assert.false(
      handles['override']!.isActive,
      '@isActive={{false}} wins over the router'
    );

    await click('#to-first');
    assert.false(handles['second']!.isActive, 'flips after a transition');
  });
});
