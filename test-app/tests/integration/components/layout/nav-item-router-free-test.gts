import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import Service from '@ember/service';
import { NavItem } from 'frontile';

class ThrowingRouter extends Service {
  constructor(...args: ConstructorParameters<typeof Service>) {
    super(...args);
    throw new Error('service:router must not be resolved');
  }
}

module(
  'Integration | Component | NavItem | frontile/layout | router-free',
  function (hooks) {
    setupRenderingTest(hooks);

    hooks.beforeEach(function () {
      this.owner.register('service:router', ThrowingRouter);
    });

    test('an @href item never resolves the router service', async function (assert) {
      await render(
        <template>
          <NavItem @href="/one" @isActive={{false}}>One</NavItem>
          <NavItem @href="/two">Two</NavItem>
        </template>
      );

      assert.dom('a[href="/one"]').exists();
      assert.dom('a[href="/two"]').exists();
    });

    test('an @isActive item never resolves the router service', async function (assert) {
      await render(
        <template>
          <NavItem @href="/one" @isActive={{true}}>One</NavItem>
        </template>
      );

      assert.dom('a[href="/one"]').hasAttribute('aria-current', 'page');
    });
  }
);
