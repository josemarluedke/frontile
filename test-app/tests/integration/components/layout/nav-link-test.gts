import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, find, settled } from '@ember/test-helpers';
import Service from '@ember/service';
import { on } from '@ember/modifier';
import { NavLink } from 'frontile';

class ThrowingRouter extends Service {
  constructor(...args: ConstructorParameters<typeof Service>) {
    super(...args);
    throw new Error('service:router must not be resolved');
  }
}

module('Integration | Component | NavLink | frontile/layout', function (hooks) {
  setupRenderingTest(hooks);

  test('href renders an anchor', async function (assert) {
    await render(
      <template>
        <NavLink @href="/reports">Reports</NavLink>
      </template>
    );

    assert.dom('a').exists({ count: 1 });
    assert.dom('a').hasAttribute('href', '/reports');
    assert.dom('a').hasText('Reports');
    assert.dom('a').doesNotHaveAttribute('aria-current');
    assert.dom('a').hasAttribute('aria-disabled', 'false');
    assert.dom('a').hasAttribute('data-active', 'false');
    assert.dom('a').hasAttribute('data-disabled', 'false');
    assert.dom('a').doesNotHaveAttribute('data-part');
  });

  test('no route or href renders a button', async function (assert) {
    await render(
      <template>
        <NavLink>Do it</NavLink>
      </template>
    );

    assert.dom('button').exists({ count: 1 });
    assert.dom('button').hasAttribute('type', 'button');
    assert.dom('button').hasText('Do it');
    assert.dom('a').doesNotExist();
  });

  test('isActive sets aria-current and data-active', async function (assert) {
    await render(
      <template>
        <NavLink @href="/one" @isActive={{true}}>One</NavLink>
      </template>
    );

    assert.dom('a').hasAttribute('aria-current', 'page');
    assert.dom('a').hasAttribute('data-active', 'true');
  });

  test('disabled drops href and sets aria-disabled', async function (assert) {
    await render(
      <template>
        <NavLink @href="/one" @isDisabled={{true}}>One</NavLink>
      </template>
    );

    assert.dom('a').doesNotHaveAttribute('href');
    assert.dom('a').hasAttribute('aria-disabled', 'true');
    assert.dom('a').hasAttribute('data-disabled', 'true');
  });

  test('a disabled button cannot be activated', async function (assert) {
    let clicks = 0;
    const handler = () => clicks++;

    await render(
      <template>
        <NavLink @isDisabled={{true}} {{on "click" handler}}>Nope</NavLink>
      </template>
    );

    assert.dom('button').hasAttribute('aria-disabled', 'true');
    assert.dom('button').hasAttribute('data-disabled', 'true');
    assert.dom('button').isDisabled();
    // `click` from @ember/test-helpers refuses a disabled element, so dispatch
    // the native click directly.
    (find('button') as HTMLButtonElement).click();
    await settled();
    assert.strictEqual(clicks, 0, 'click handler did not fire');
  });

  test('an enabled button fires click handlers', async function (assert) {
    let clicks = 0;
    const handler = () => clicks++;

    await render(
      <template>
        <NavLink {{on "click" handler}}>Go</NavLink>
      </template>
    );

    await click('button');
    assert.strictEqual(clicks, 1);
  });

  test('spreads attributes onto the element', async function (assert) {
    await render(
      <template>
        <NavLink @href="/x" data-part="nav-item" class="custom">X</NavLink>
      </template>
    );

    assert.dom('a').hasAttribute('data-part', 'nav-item');
    assert.dom('a').hasClass('custom');
  });

  test('hidden renders nothing', async function (assert) {
    await render(
      <template>
        <NavLink @href="/one" @isHidden={{true}}>One</NavLink>
      </template>
    );

    assert.dom('a').doesNotExist();
    assert.dom('button').doesNotExist();
  });

  module('router-free', function (hooks) {
    hooks.beforeEach(function () {
      this.owner.register('service:router', ThrowingRouter);
    });

    test('an @href link never resolves the router service', async function (assert) {
      await render(
        <template>
          <NavLink @href="/one" @isActive={{false}}>One</NavLink>
          <NavLink @href="/two">Two</NavLink>
          <NavLink>Three</NavLink>
        </template>
      );

      assert.dom('a[href="/one"]').exists();
      assert.dom('a[href="/two"]').exists();
      assert.dom('button').exists();
    });

    test('an @isActive link never resolves the router service', async function (assert) {
      await render(
        <template>
          <NavLink @href="/one" @isActive={{true}}>One</NavLink>
        </template>
      );

      assert.dom('a[href="/one"]').hasAttribute('aria-current', 'page');
    });
  });
});
