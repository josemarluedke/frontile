import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, find, settled } from '@ember/test-helpers';
import 'qunit-dom';
import FormCheckbox from '@frontile/forms-legacy/components/form-checkbox';
import { cell } from 'ember-resources';

module(
  'Integration | Component | @frontile/forms-legacy/FormCheckbox',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders with the label from argument', async function (assert) {
      await render(
        <template>
          <FormCheckbox data-test-input @label="My Checkbox Input" />
        </template>
      );
      assert
        .dom('[data-test-id="form-field-label"]')
        .hasText('My Checkbox Input');
    });

    test('it renders the label from block param', async function (assert) {
      await render(
        <template>
          <FormCheckbox data-test-input>My Block Label</FormCheckbox>
        </template>
      );

      assert.dom('[data-test-id="form-field-label"]').hasText('My Block Label');
    });

    test('it should have id attr with matching label attr `for`', async function (assert) {
      await render(
        <template>
          <FormCheckbox @label="Something Else" data-test-input />
        </template>
      );

      const el = find('[data-test-input]') as HTMLInputElement;
      const id = el.getAttribute('id') || '';

      assert.ok(/ember[1-9.]/.test(id), 'should have generated an id');

      assert.dom('[data-test-id="form-field-label"]').hasAttribute('for', id);
    });

    test('it renders the `name` from args', async function (assert) {
      await render(
        <template><FormCheckbox data-test-input @name="my-input" /></template>
      );

      assert.dom('[data-test-input]').hasAttribute('name', 'my-input');
    });

    test('it does not mutates the value directly', async function (assert) {
      const myValue = cell<boolean | undefined>(undefined);

      await render(
        <template>
          <FormCheckbox
            data-test-input
            name="my-input"
            @label="My Checkbox Input"
            @checked={{myValue.current}}
          />
        </template>
      );

      await click('[data-test-input]');
      assert.equal(myValue.current, undefined);
    });

    test('it calls onChange function to change value', async function (assert) {
      const myValue = cell<boolean | undefined>(undefined);
      const setMyValue = (value: boolean) => {
        myValue.current = value;
      };

      await render(
        <template>
          <FormCheckbox
            data-test-input
            name="my-input"
            @label="My Checkbox Input"
            @checked={{myValue.current}}
            @onChange={{setMyValue}}
          />
        </template>
      );

      await click('[data-test-input]');
      assert.equal(myValue.current, true);
    });

    test('it marks the input as checked if value matches', async function (assert) {
      const myValue = cell(false);

      await render(
        <template>
          <FormCheckbox
            data-test-input
            @label="My Checkbox Input"
            @checked={{myValue.current}}
          />
        </template>
      );

      assert.dom('[data-test-input]').isNotChecked();
      myValue.current = true;
      await settled();

      assert.dom('[data-test-input]').isChecked();
    });

    test('input id should match label for attribute', async function (assert) {
      await render(
        <template>
          <FormCheckbox data-test-input @label="My Checkbox Input" />
        </template>
      );

      const inputId = find('[data-test-input]')?.getAttribute('id');
      const labelFor = find('[data-test-id="form-field-label"]')?.getAttribute(
        'for'
      );

      assert.ok(inputId, 'input should have an id attribute');
      assert.equal(
        inputId,
        labelFor,
        'id attribute of input should be equal to for attribute of label'
      );
    });

    test('it adds container class from @containerClass arg', async function (assert) {
      await render(
        <template>
          <FormCheckbox @containerClass="my-container-class" />
        </template>
      );

      assert.dom('.my-container-class').exists();
    });
  }
);
