import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import Service from '@ember/service';
import { TabNav } from 'frontile';

class ThrowingRouter extends Service {
  constructor(...args: ConstructorParameters<typeof Service>) {
    super(...args);
    throw new Error('service:router must not be resolved');
  }
}

module(
  'Integration | Component | TabNav | router-free items',
  function (hooks) {
    setupRenderingTest(hooks);

    hooks.beforeEach(function () {
      this.owner.register('service:router', ThrowingRouter);
    });

    test('an @href item never resolves the router service', async function (assert) {
      await render(
        <template>
          <TabNav @label="Sections" as |nav|>
            <nav.Item @href="/one" @isActive={{false}}>One</nav.Item>
            <nav.Item @href="/two">Two</nav.Item>
          </TabNav>
        </template>
      );

      assert.dom('a[href="/one"]').exists();
      assert.dom('a[href="/two"]').exists();
    });

    test('an @isActive item with @route never resolves the router service', async function (assert) {
      await render(
        <template>
          <TabNav @label="Sections" as |nav|>
            <nav.Item @href="/one" @isActive={{true}}>One</nav.Item>
          </TabNav>
        </template>
      );

      assert.dom('a[href="/one"]').hasAttribute('aria-current', 'page');
    });
  }
);
