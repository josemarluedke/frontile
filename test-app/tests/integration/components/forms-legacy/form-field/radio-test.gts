import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, settled } from '@ember/test-helpers';
import Radio from '@frontile/forms-legacy/components/form-field/radio';
import { cell } from 'ember-resources';

module(
  'Integration | Component | @frontile/forms-legacy/FormField::Radio',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders with html attributes', async function (assert) {
      await render(
        <template><Radio name="some-name" data-test-radio /></template>
      );

      assert.dom('[data-test-radio]').exists();
      assert.dom('[name="some-name"]').exists();
    });

    test('it renders @id arg', async function (assert) {
      await render(<template><Radio @id="my-id" data-test-radio /></template>);

      assert.dom('[data-test-radio]').hasAttribute('id', 'my-id');
    });

    test('it renders id html attribute', async function (assert) {
      await render(<template><Radio id="my-id" data-test-radio /></template>);

      assert.dom('[data-test-radio]').hasAttribute('id', 'my-id');
    });

    test('it renders @name arg', async function (assert) {
      await render(
        <template><Radio @name="my-name" data-test-radio /></template>
      );

      assert.dom('[data-test-radio]').hasAttribute('name', 'my-name');
    });

    test('it renders name html attribute', async function (assert) {
      await render(
        <template><Radio name="my-name" data-test-radio /></template>
      );

      assert.dom('[data-test-radio]').hasAttribute('name', 'my-name');
    });

    test('it sets as checked if @value and @checked are equal', async function (assert) {
      const value = cell('something-else');

      await render(
        <template>
          <Radio
            data-test-radio
            @checked={{value.current}}
            @value="something"
          />
        </template>
      );

      assert.dom('[data-test-radio]').isNotChecked();

      value.current = 'something';
      await settled();
      assert.dom('[data-test-radio]').isChecked();
    });

    test('renders @checed arg, does not mutate it by default', async function (assert) {
      const value = cell<string | undefined>(undefined);

      await render(
        <template>
          <Radio
            data-test-radio
            @checked={{value.current}}
            @value="something"
          />
        </template>
      );

      assert.dom('[data-test-radio]').isNotChecked();
      await click('[data-test-radio]');

      assert.equal(
        value.current,
        undefined,
        'should have not mutated the value'
      );
    });

    test('should call @onChange function arg', async function (assert) {
      assert.expect(4);
      const value = cell<string | undefined>(undefined);

      const setName = (val: string) => {
        value.current = val;
        assert.ok(true, 'should have called function');
      };

      await render(
        <template>
          <Radio
            data-test-radio
            @value={{"my-value"}}
            @checked={{value.current}}
            @onChange={{setName}}
          />
        </template>
      );

      assert.dom('[data-test-radio]').isNotChecked();

      await click('[data-test-radio]');

      assert.dom('[data-test-radio]').isChecked();
      assert.equal(value.current, 'my-value', 'should have mutated the value');
    });
  }
);
