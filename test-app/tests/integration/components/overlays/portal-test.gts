import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find } from '@ember/test-helpers';
import { Portal, PortalTarget } from '@frontile/overlays';
import { ref } from '@frontile/utilities';

module('Integration | Component | @frontile/overlays/Portal', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders the yielded content, appending/nesting new portals', async function (assert) {
    await render(
      <template>
        <Portal data-test-id="portal-1">
          First portal

          <Portal data-test-id="portal-1-nested">
            Second portal

            <Portal data-test-id="portal-1-nested-nested">
              Last portal
            </Portal>
          </Portal>
        </Portal>
        <Portal data-test-id="portal-2">
          Last portal
        </Portal>
      </template>
    );

    assert.dom('[data-portal-target]').exists();
    assert.dom('[data-test-id="portal-1"]').exists();
    assert.dom('[data-test-id="portal-2"]').exists();
    assert.dom('[data-test-id="portal-1-nested"]').exists();
    assert.dom('[data-test-id="portal-1-nested-nested"]').exists();

    const portal1 = find('[data-test-id="portal-1"]');

    const portal1Nested = portal1?.querySelector(
      '[data-test-id="portal-1-nested"]'
    );

    assert.ok(
      portal1Nested,
      'should have found a nested portal inside of portal-1'
    );

    const portal1NestedNested = portal1?.querySelector(
      '[data-test-id="portal-1-nested-nested"]'
    );

    assert.ok(
      portal1NestedNested,
      'should have found a nested portal inside of portal-1-nested'
    );

    const portal2 = portal1?.querySelector('[data-test-id="portal-2"]');
    assert.notOk(portal2, 'should have not found portal-2 inside of portal-1');
  });

  test('it renders inside the closest portal target', async function (assert) {
    await render(
      <template>
        <div data-test-id="portal-wrapper">
          <PortalTarget />
        </div>

        <Portal data-test-id="portal-1">
          Portal
        </Portal>
      </template>
    );

    assert.dom('[data-portal-target]').exists();
    assert.dom('[data-test-id="portal-wrapper"]').exists();
    assert.dom('[data-test-id="portal-1"]').exists();

    const wrapper = find('[data-test-id="portal-wrapper"]');
    const portal = wrapper?.querySelector('[data-test-id="portal-1"]');
    assert.ok(portal, 'should have found a portal inside of portal-wrapper');

    await render(
      <template>
        <div data-test-id="portal-wrapper">
          <PortalTarget />
        </div>
        <div data-test-id="portal-wrapper-2">
          <PortalTarget />

          <Portal data-test-id="portal-1">
            Portal
          </Portal>
        </div>
      </template>
    );

    const wrapper2 = find('[data-test-id="portal-wrapper-2"]');
    const portal2 = wrapper2?.querySelector('[data-test-id="portal-1"]');
    assert.ok(portal2, 'should have found a portal inside of portal-wrapper-2');
  });

  test('it does not nest portal if argument  is passed in', async function (assert) {
    await render(
      <template>
        <Portal data-test-id="portal-1">
          First portal

          <Portal
            data-test-id="portal-1-not-nested"
            @appendToParentPortal={{false}}
          >
            Second portal
          </Portal>
        </Portal>
      </template>
    );

    assert.dom('[data-portal-target]').exists();
    assert.dom('[data-test-id="portal-1"]').exists();
    assert.dom('[data-test-id="portal-1-not-nested"]').exists();

    const portal1 = find('[data-test-id="portal-1"]');

    const portal1NotNested = portal1?.querySelector(
      '[data-test-id="portal-1-not-nested"]'
    );

    assert.notOk(
      portal1NotNested,
      'should have not found nested portal inside of portal-1'
    );
  });

  test('it renders inline when argument is passed in', async function (assert) {
    await render(
      <template>
        <div data-test-id="wrapper">
          <Portal data-test-id="portal-1" @renderInPlace={{true}}>
            Portal
          </Portal>
        </div>
      </template>
    );

    assert.dom('[data-test-id="wrapper"]').exists();
    assert.dom('[data-portal-target]').doesNotExist();
    assert.dom('[data-test-id="portal-1"]').exists();

    const wrapper = find('[data-test-id="wrapper"]');
    const portal = wrapper?.querySelector('[data-test-id="portal-1"]');
    assert.ok(portal, 'should have found a portal inside of wrapper');
  });

  test('it renders inside target element by id', async function (assert) {
    await render(
      <template>
        <div data-test-id="wrapper" id="target"></div>

        <Portal data-test-id="portal-1" @target="#target">
          Portal
        </Portal>
      </template>
    );

    assert.dom('[data-test-id="wrapper"]').exists();
    assert.dom('[data-portal-target]').doesNotExist();
    assert.dom('[data-test-id="portal-1"]').exists();

    const wrapper = find('[data-test-id="wrapper"]');
    const portal = wrapper?.querySelector('[data-test-id="portal-1"]');
    assert.ok(portal, 'should have found a portal inside of wrapper');
  });

  test('it renders inside target element', async function (assert) {
    const myRef = ref();

    await render(
      <template>
        <div data-test-id="wrapper" {{myRef.setup}}></div>

        <Portal data-test-id="portal-1" @target={{myRef.current}}>
          Portal
        </Portal>
      </template>
    );

    assert.dom('[data-test-id="wrapper"]').exists();
    assert.dom('[data-portal-target]').doesNotExist();
    assert.dom('[data-test-id="portal-1"]').exists();

    const wrapper = find('[data-test-id="wrapper"]');
    const portal = wrapper?.querySelector('[data-test-id="portal-1"]');
    assert.ok(portal, 'should have found a portal inside of wrapper');
  });

  test('it renders inside named portal target ', async function (assert) {
    await render(
      <template>
        <PortalTarget />
        <PortalTarget @for="target-1" />
        <PortalTarget @for="target-2" />

        <Portal data-test-id="portal-1" @target="target-2">
          Portal
        </Portal>
      </template>
    );

    assert.dom('[data-portal-for="target-2"]').exists();
    assert.dom('[data-test-id="portal-1"]').exists();

    const wrapper = find('[data-portal-for="target-2"]');
    const portal = wrapper?.querySelector('[data-test-id="portal-1"]');
    assert.ok(portal, 'should have found a portal inside of named target');
  });
});
