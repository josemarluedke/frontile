import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render } from '@ember/test-helpers';
import { Changeset } from 'ember-changeset';
import { run } from '@ember/runloop';
import CheckboxGroup from '@frontile/changeset-form/components/changeset-form/fields/checkbox-group';

module(
  'Integration | Component | @frontile/changeset-form/ChangesetForm::Fields::CheckboxGroup',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders with initial model value', async function (assert) {
      const model = {
        colors: {
          blue: true,
          green: false,
          red: false
        }
      };
      const changeset = Changeset(model);

      await render(
        <template>
          <CheckboxGroup
            @changeset={{changeset}}
            @groupName="colors"
            @label="Colors"
            as |Checkbox|
          >
            <Checkbox @fieldName="blue" @label="blue" data-test-checkbox-blue />
            <Checkbox
              @fieldName="green"
              @label="green"
              data-test-checkbox-green
            />
            <Checkbox @fieldName="red" @label="red" data-test-checkbox-red />
          </CheckboxGroup>
        </template>
      );

      assert.dom('[data-test-checkbox-blue]').isChecked();
      assert.dom('[data-test-checkbox-green]').isNotChecked();
      assert.dom('[data-test-checkbox-red]').isNotChecked();
    });

    test('it updates the changeset on input', async function (assert) {
      const model = {
        colors: {
          blue: true,
          green: false,
          red: false
        }
      };
      const changeset = Changeset(model);

      await render(
        <template>
          <CheckboxGroup
            @changeset={{changeset}}
            @groupName="colors"
            @label="Colors"
            as |Checkbox|
          >
            <Checkbox @fieldName="blue" @label="blue" data-test-checkbox-blue />
            <Checkbox
              @fieldName="green"
              @label="green"
              data-test-checkbox-green
            />
            <Checkbox @fieldName="red" @label="red" data-test-checkbox-red />
          </CheckboxGroup>
        </template>
      );

      await click('[data-test-checkbox-blue]');
      await click('[data-test-checkbox-green]');
      await click('[data-test-checkbox-red]');

      assert.equal(changeset.get('colors.blue'), false);
      assert.equal(changeset.get('colors.green'), true);
      assert.equal(changeset.get('colors.red'), true);
    });

    test('it receives original input values on rollback', async function (assert) {
      const model = {
        colors: {
          blue: true,
          green: false,
          red: false
        }
      };
      const changeset = Changeset(model);

      await render(
        <template>
          <CheckboxGroup
            @changeset={{changeset}}
            @groupName="colors"
            @label="Colors"
            as |Checkbox|
          >
            <Checkbox @fieldName="blue" @label="blue" data-test-checkbox-blue />
            <Checkbox
              @fieldName="green"
              @label="green"
              data-test-checkbox-green
            />
            <Checkbox @fieldName="red" @label="red" data-test-checkbox-red />
          </CheckboxGroup>
        </template>
      );

      await click('[data-test-checkbox-green]');

      assert.dom('[data-test-checkbox-blue]').isChecked();
      assert.dom('[data-test-checkbox-red]').isNotChecked();

      run(() => {
        changeset.rollback();
      });
      assert.dom('[data-test-checkbox-blue]').isChecked();
      assert.dom('[data-test-checkbox-green]').isNotChecked();
      assert.dom('[data-test-checkbox-red]').isNotChecked();
    });
  }
);
