import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, fillIn } from '@ember/test-helpers';
import Input from '@frontile/forms-legacy/components/form-field/input';
import { cell } from 'ember-resources';

module(
  'Integration | Component | @frontile/forms-legacy/FormField::Input',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders with html attributes', async function (assert) {
      await render(
        <template><Input name="some-name" data-test-my-input /></template>
      );

      assert.dom('[data-test-my-input]').exists();
      assert.dom('[name="some-name"]').exists();
    });

    test('it should default type as text', async function (assert) {
      await render(<template><Input data-test-my-input /></template>);

      assert.dom('[data-test-my-input]').hasAttribute('type', 'text');
    });

    test('it should allow to change the input type', async function (assert) {
      await render(
        <template><Input @type="number" data-test-my-input /></template>
      );

      assert.dom('[data-test-my-input]').hasAttribute('type', 'number');
    });

    test('it renders @id arg', async function (assert) {
      await render(
        <template><Input @id="my-id" data-test-my-input /></template>
      );

      assert.dom('[data-test-my-input]').hasAttribute('id', 'my-id');
    });

    test('it renders id html attribute', async function (assert) {
      await render(
        <template><Input id="my-id" data-test-my-input /></template>
      );

      assert.dom('[data-test-my-input]').hasAttribute('id', 'my-id');
    });

    test('renders @value arg, does not mutate it by default', async function (assert) {
      const value = cell('Josemar');

      await render(
        <template><Input class="my-input" @value={{value.current}} /></template>
      );

      assert.dom('.my-input').hasValue('Josemar');

      await fillIn('.my-input', 'Sam');

      assert.equal(
        value.current,
        'Josemar',
        'should have not mutated the value'
      );
    });

    test('should call @onInput function arg', async function (assert) {
      assert.expect(4);
      const value = cell('Josemar');

      const setName = (val: string) => {
        value.current = val;
        assert.ok(true, 'should have called function');
      };

      await render(
        <template>
          <Input
            class="my-input"
            @value={{value.current}}
            @onInput={{setName}}
          />
        </template>
      );

      assert.dom('.my-input').hasValue('Josemar');

      await fillIn('.my-input', 'Sam');

      assert.dom('.my-input').hasValue('Sam');
      assert.equal(value.current, 'Sam', 'should have mutated the value');
    });

    test('should call @onChange function arg', async function (assert) {
      assert.expect(4);
      const value = cell('Josemar');

      const setName = (val: string) => {
        value.current = val;
        assert.ok(true, 'should have called function');
      };

      await render(
        <template>
          <Input
            class="my-input"
            @value={{value.current}}
            @onChange={{setName}}
          />
        </template>
      );

      assert.dom('.my-input').hasValue('Josemar');

      await fillIn('.my-input', 'Sam');

      assert.dom('.my-input').hasValue('Sam');
      assert.equal(value.current, 'Sam', 'should have mutated the value');
    });
  }
);
