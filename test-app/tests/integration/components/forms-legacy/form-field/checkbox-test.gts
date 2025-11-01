import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, settled } from '@ember/test-helpers';
import Checkbox from '@frontile/forms-legacy/components/form-field/checkbox';
import { cell } from 'ember-resources';

module(
  'Integration | Component | @frontile/forms-legacy/FormField::Checkbox',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders with html attributes', async function (assert) {
      await render(
        <template><Checkbox name="some-name" data-test-checkbox /></template>
      );

      assert.dom('[data-test-checkbox]').exists();
      assert.dom('[name="some-name"]').exists();
    });

    test('it renders @id arg', async function (assert) {
      await render(
        <template><Checkbox @id="my-id" data-test-checkbox /></template>
      );

      assert.dom('[data-test-checkbox]').hasAttribute('id', 'my-id');
    });

    test('it renders id html attribute', async function (assert) {
      await render(
        <template><Checkbox id="my-id" data-test-checkbox /></template>
      );

      assert.dom('[data-test-checkbox]').hasAttribute('id', 'my-id');
    });

    test('it renders @name arg', async function (assert) {
      await render(
        <template><Checkbox @name="my-name" data-test-checkbox /></template>
      );

      assert.dom('[data-test-checkbox]').hasAttribute('name', 'my-name');
    });

    test('it renders name html attribute', async function (assert) {
      await render(
        <template><Checkbox name="my-name" data-test-checkbox /></template>
      );

      assert.dom('[data-test-checkbox]').hasAttribute('name', 'my-name');
    });

    test('renders @checed arg, does not mutate it by default', async function (assert) {
      const value = cell(true);

      await render(
        <template>
          <Checkbox data-test-checkbox @checked={{value.current}} />
        </template>
      );

      assert.dom('[data-test-checkbox]').isChecked();
      await click('[data-test-checkbox]');

      assert.equal(value.current, true, 'should have not mutated the value');
    });

    test('should call @onChange function arg', async function (assert) {
      assert.expect(4);
      const value = cell<boolean | undefined>(undefined);

      const setName = (val: boolean) => {
        value.current = val;
        assert.ok(true, 'should have called function');
      };

      await render(
        <template>
          <Checkbox
            data-test-checkbox
            @value={{value.current}}
            @onChange={{setName}}
          />
        </template>
      );

      assert.dom('[data-test-checkbox]').isNotChecked();

      await click('[data-test-checkbox]');

      assert.dom('[data-test-checkbox]').isChecked();
      assert.equal(value.current, true, 'should have mutated the value');
    });

    test('it sets as checked if value is truthy', async function (assert) {
      const value = cell<boolean | undefined>(undefined);

      await render(
        <template>
          <Checkbox data-test-checkbox @checked={{value.current}} />
        </template>
      );

      assert.dom('[data-test-checkbox]').isNotChecked();

      value.current = true;
      await settled();
      assert.dom('[data-test-checkbox]').isChecked();

      value.current = false;
      await settled();
      assert.dom('[data-test-checkbox]').isNotChecked();
    });
  }
);
