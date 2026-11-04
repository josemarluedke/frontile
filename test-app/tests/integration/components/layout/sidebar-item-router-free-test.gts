import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import Service from '@ember/service';
import { AppLayout } from 'frontile';

class ThrowingRouter extends Service {
  constructor(...args: ConstructorParameters<typeof Service>) {
    super(...args);
    throw new Error('service:router must not be resolved');
  }
}

module(
  'Integration | Component | Sidebar.Item | router-free items',
  function (hooks) {
    setupRenderingTest(hooks);

    hooks.beforeEach(function () {
      this.owner.register('service:router', ThrowingRouter);
    });

    test('an @href item never resolves the router service', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>
                <sidebar.Item @href="/one" @isActive={{false}}>
                  One
                </sidebar.Item>
                <sidebar.Item @href="/two">Two</sidebar.Item>
              </sidebar.Body>
            </layout.Sidebar>
          </AppLayout>
        </template>
      );

      assert.dom('a[href="/one"]').exists();
      assert.dom('a[href="/two"]').exists();
    });

    test('an @isActive item never resolves the router service', async function (assert) {
      await render(
        <template>
          <AppLayout as |layout|>
            <layout.Sidebar as |sidebar|>
              <sidebar.Body>
                <sidebar.Item @href="/one" @isActive={{true}}>
                  One
                </sidebar.Item>
              </sidebar.Body>
            </layout.Sidebar>
          </AppLayout>
        </template>
      );

      assert.dom('a[href="/one"]').hasAttribute('aria-current', 'page');
    });
  }
);
