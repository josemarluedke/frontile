import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render } from '@ember/test-helpers';
import { Changeset } from 'ember-changeset';
import { run } from '@ember/runloop';
import lookupValidator from 'ember-changeset-validations';
import RadioGroup from '@frontile/changeset-form/components/changeset-form/fields/radio-group';

module(
  'Integration | Component | @frontile/changeset-form/ChangesetForm::Fields::RadioGroup',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders with initial model value', async function (assert) {
      const model = {
        color: 'blue'
      };
      const validations = {
        color: (_: string, value: string | undefined) => {
          if (value === 'green') {
            return 'Please select another color';
          }
          return true;
        }
      };
      const changeset = Changeset(model, lookupValidator(validations));

      await render(
        <template>
          <RadioGroup
            @changeset={{changeset}}
            @fieldName="color"
            class="field-container"
            as |Radio|
          >
            <Radio @value="blue" data-test-radio-blue />
            <Radio @value="green" data-test-radio-green />
            <Radio @value="red" data-test-radio-red />
          </RadioGroup>
        </template>
      );

      assert.dom('[data-test-radio-blue]').isChecked();
      assert.dom('[data-test-radio-green]').isNotChecked();
      assert.dom('[data-test-radio-red]').isNotChecked();
    });

    test('it updates the changeset on input', async function (assert) {
      const model = {
        color: 'blue'
      };
      const validations = {
        color: (_: string, value: string | undefined) => {
          if (value === 'green') {
            return 'Please select another color';
          }
          return true;
        }
      };
      const changeset = Changeset(model, lookupValidator(validations));

      await render(
        <template>
          <RadioGroup
            @changeset={{changeset}}
            @fieldName="color"
            class="field-container"
            as |Radio|
          >
            <Radio @value="blue" data-test-radio-blue />
            <Radio @value="green" data-test-radio-green />
            <Radio @value="red" data-test-radio-red />
          </RadioGroup>
        </template>
      );

      await click('[data-test-radio-green]');
      await click('[data-test-radio-red]');

      assert.equal(changeset.get('color'), 'red');
    });

    test('it displays error message after option is selected', async function (assert) {
      const model = {
        color: 'blue'
      };
      const validations = {
        color: (_: string, value: string | undefined) => {
          if (value === 'green') {
            return 'Please select another color';
          }
          return true;
        }
      };
      const changeset = Changeset(model, lookupValidator(validations));

      await render(
        <template>
          <RadioGroup
            @changeset={{changeset}}
            @fieldName="color"
            class="field-container"
            as |Radio|
          >
            <Radio @value="blue" data-test-radio-blue />
            <Radio @value="green" data-test-radio-green />
            <Radio @value="red" data-test-radio-red />
          </RadioGroup>
        </template>
      );

      await click('[data-test-radio-green]');

      assert
        .dom('.field-container')
        .hasTextContaining('Please select another color');
    });

    test('it receives original input values on rollback', async function (assert) {
      const model = {
        color: 'blue'
      };
      const validations = {
        color: (_: string, value: string | undefined) => {
          if (value === 'green') {
            return 'Please select another color';
          }
          return true;
        }
      };
      const changeset = Changeset(model, lookupValidator(validations));

      await render(
        <template>
          <RadioGroup
            @changeset={{changeset}}
            @fieldName="color"
            class="field-container"
            as |Radio|
          >
            <Radio @value="blue" data-test-radio-blue />
            <Radio @value="green" data-test-radio-green />
            <Radio @value="red" data-test-radio-red />
          </RadioGroup>
        </template>
      );

      await click('[data-test-radio-green]');

      assert.dom('[data-test-radio-blue]').isNotChecked();
      assert.dom('[data-test-radio-red]').isNotChecked();

      run(() => {
        changeset.rollback();
      });
      assert.dom('[data-test-radio-blue]').isChecked();
    });
  }
);
