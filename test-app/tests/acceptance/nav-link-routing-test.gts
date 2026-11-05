import { module, test } from 'qunit';
import { setupApplicationTest } from 'ember-qunit';
import { visit } from '@ember/test-helpers';
import { NavLink } from 'frontile';

module('Acceptance | NavLink routing', function (hooks) {
  setupApplicationTest(hooks);

  hooks.beforeEach(function () {
    // Reuse the existing sidebar-demo routes; only the leaf template is
    // swapped for NavLinks so the router is real.
    this.owner.register(
      'template:sidebar-demo/second',
      <template>
        <NavLink @route="sidebar-demo.index" id="nl-first">First</NavLink>
        <NavLink @route="sidebar-demo.second" id="nl-second">Second</NavLink>
        <NavLink
          @route="sidebar-demo.second"
          @isActive={{false}}
          id="nl-override"
        >Override</NavLink>
        <NavLink
          @route="sidebar-demo.second"
          @isDisabled={{true}}
          id="nl-disabled"
        >Disabled</NavLink>
      </template>
    );
  });

  test('router-derived active state, @isActive override and disabled route', async function (assert) {
    await visit('/sidebar-demo/second');

    assert.dom('#nl-second').hasAttribute('href', '/sidebar-demo/second');
    assert.dom('#nl-second').hasAttribute('aria-current', 'page');
    assert.dom('#nl-second').hasAttribute('data-active', 'true');

    assert.dom('#nl-first').hasAttribute('href', '/sidebar-demo');
    assert.dom('#nl-first').doesNotHaveAttribute('aria-current');
    assert.dom('#nl-first').hasAttribute('data-active', 'false');

    assert
      .dom('#nl-override')
      .doesNotHaveAttribute('aria-current', '@isActive={{false}} wins');
    assert.dom('#nl-override').hasAttribute('data-active', 'false');

    assert.dom('#nl-disabled').doesNotHaveAttribute('href');
    assert.dom('#nl-disabled').hasAttribute('aria-disabled', 'true');
    assert.dom('#nl-disabled').hasAttribute('data-disabled', 'true');
  });
});
