import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find } from '@ember/test-helpers';
import { Portal, PortalTarget } from 'frontile';
import { ref } from 'frontile';

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

  // Ids only have to be non-empty and whitespace-free to be valid HTML, so
  // plenty of legal ids are not valid CSS identifiers. Each of these takes
  // down the render if the id is interpolated into a selector unescaped.
  const nonIdentifierIds = [
    { id: '1foo', name: 'leading digit' },
    { id: 'my.target', name: 'dot' },
    { id: 'a:b', name: 'colon' },
    { id: 'has space', name: 'space' },
    { id: 'bracket]end', name: 'closing bracket' }
  ];

  test('it renders inside target element by id when the id is not a CSS identifier', async function (assert) {
    await render(
      <template>
        {{#each nonIdentifierIds as |testCase|}}
          <div data-test-id={{testCase.name}} id={{testCase.id}}></div>

          <Portal data-test-id="portal" @target="#{{testCase.id}}">
            Portal
          </Portal>
        {{/each}}
      </template>
    );

    for (const testCase of nonIdentifierIds) {
      assert.ok(
        find(`[data-test-id="${testCase.name}"]`)?.querySelector(
          '[data-test-id="portal"]'
        ),
        `should have portaled into the element with a ${testCase.name} in its id`
      );
    }
  });

  test('it renders nothing for an empty id target', async function (assert) {
    // The truthiness check this replaced degraded `#` to "any element that
    // carries an id at all", portaling into an arbitrary element.
    await render(
      <template>
        <div data-test-id="decoy" id="decoy"></div>

        <Portal data-test-id="portal-1" @target="#">
          Portal
        </Portal>
      </template>
    );

    // Scoped to the whole document on purpose: `assert.dom` only looks inside
    // the testing container, and the element this used to resolve to is the
    // first one in the *document* carrying an id, which is outside it.
    assert.strictEqual(
      document.querySelectorAll('[data-test-id="portal-1"]').length,
      0,
      'should not have resolved a destination anywhere in the document'
    );
  });

  test('it does not portal into an unintended element for an injection-shaped target', async function (assert) {
    // Naive interpolation would turn this into
    // `[id=x], [data-portal-target]` and portal into the decoy.
    await render(
      <template>
        <div data-test-id="decoy" data-portal-target="true"></div>

        <Portal data-test-id="portal-1" @target="#x], [data-portal-target">
          Portal
        </Portal>
      </template>
    );

    assert.notOk(
      find('[data-test-id="decoy"]')?.querySelector(
        '[data-test-id="portal-1"]'
      ),
      'should not have portaled into the decoy element'
    );
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

  // A named target's name is arbitrary consumer text, so unlike an id it can
  // carry whitespace — newlines included. A CSS string cannot carry a raw
  // newline, so it has to be escaped as `\a `; replacing it with some other
  // character instead would silently query for a *different* name and match
  // the wrong target, or none at all, with no error to point at.
  const newlineTargetName = 'target\nwith-newline';

  test('it renders inside named portal target whose name contains a newline', async function (assert) {
    await render(
      <template>
        <PortalTarget />
        <PortalTarget data-test-id="decoy" @for="target with-newline" />
        <PortalTarget data-test-id="real" @for={{newlineTargetName}} />

        <Portal data-test-id="portal-1" @target={{newlineTargetName}}>
          Portal
        </Portal>
      </template>
    );

    assert.ok(
      find('[data-test-id="real"]')?.querySelector('[data-test-id="portal-1"]'),
      'should have portaled into the target whose name contains the newline'
    );
    assert.notOk(
      find('[data-test-id="decoy"]')?.querySelector(
        '[data-test-id="portal-1"]'
      ),
      'should not have portaled into the target whose name has a space instead'
    );
  });

  test('it renders inside named portal target whose name is not a CSS identifier', async function (assert) {
    await render(
      <template>
        <PortalTarget />
        <PortalTarget @for="target.1" />

        <Portal data-test-id="portal-1" @target="target.1">
          Portal
        </Portal>
      </template>
    );

    assert.dom('[data-portal-for="target.1"]').exists();

    const wrapper = find('[data-portal-for="target.1"]');
    const portal = wrapper?.querySelector('[data-test-id="portal-1"]');
    assert.ok(portal, 'should have found a portal inside of named target');
  });
});
