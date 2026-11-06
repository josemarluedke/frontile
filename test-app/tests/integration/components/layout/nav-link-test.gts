import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, find, settled } from '@ember/test-helpers';
import Service from '@ember/service';
import { on } from '@ember/modifier';
import { array, hash } from '@ember/helper';
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

  test('@route renders a LinkTo anchor with the resolved href', async function (assert) {
    await render(
      <template>
        <NavLink @route="tab-nav-demo.index">Home</NavLink>
        <NavLink @route="tab-nav-demo.item" @model={{7}} id="with-model">
          Model
        </NavLink>
        <NavLink
          @route="tab-nav-demo.item"
          @models={{array 8}}
          id="with-models"
        >
          Models
        </NavLink>
        <NavLink
          @route="tab-nav-demo.second"
          @query={{hash page="2"}}
          id="with-query"
        >Query</NavLink>
      </template>
    );

    assert.dom('a').exists({ count: 4 });
    assert.dom('a').hasText('Home');
    assert.ok(
      find('a')!.getAttribute('href')?.endsWith('/tab-nav-demo'),
      'plain route href'
    );
    assert.dom('#with-model').hasAttribute('href', /\/tab-nav-demo\/item\/7$/);
    assert.dom('#with-models').hasAttribute('href', /\/tab-nav-demo\/item\/8$/);
    assert
      .dom('#with-query')
      .hasAttribute('href', /\/tab-nav-demo\/second\?page=2$/);
    assert.dom('#with-model').hasAttribute('aria-disabled', 'false');
    assert.dom('#with-model').hasAttribute('data-disabled', 'false');
  });

  test('a disabled @route renders a plain anchor with no href', async function (assert) {
    await render(
      <template>
        <NavLink @route="tab-nav-demo.index" @isDisabled={{true}}>One</NavLink>
      </template>
    );

    assert.dom('a').exists({ count: 1 });
    assert.dom('a').doesNotHaveAttribute('href');
    assert.dom('a').hasAttribute('aria-disabled', 'true');
    assert.dom('a').hasAttribute('data-disabled', 'true');
    assert.dom('a').doesNotHaveClass('disabled');
  });

  test('a button with @isActive gets aria-current', async function (assert) {
    await render(
      <template>
        <NavLink @isActive={{true}}>Go</NavLink>
      </template>
    );

    assert.dom('button').hasAttribute('aria-current', 'page');
    assert.dom('button').hasAttribute('data-active', 'true');
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
