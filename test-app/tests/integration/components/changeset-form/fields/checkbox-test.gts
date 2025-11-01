import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render } from '@ember/test-helpers';
import { Changeset } from 'ember-changeset';
import { run } from '@ember/runloop';
import Checkbox from '@frontile/changeset-form/components/changeset-form/fields/checkbox';

module(
  'Integration | Component | @frontile/changeset-form/ChangesetForm::Fields::Checkbox',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders with initial model value', async function (assert) {
      const model = {
        blue: true,
        green: false,
        red: false
      };
      const changeset = Changeset(model);

      await render(
        <template>
          <Checkbox
            @changeset={{changeset}}
            @fieldName="blue"
            @label="blue"
            data-test-checkbox-blue
          />
          <Checkbox
            @changeset={{changeset}}
            @fieldName="green"
            @label="green"
            data-test-checkbox-green
          />
          <Checkbox
            @changeset={{changeset}}
            @fieldName="red"
            @label="red"
            data-test-checkbox-red
          />
        </template>
      );

      assert.dom('[data-test-checkbox-blue]').isChecked();
      assert.dom('[data-test-checkbox-green]').isNotChecked();
      assert.dom('[data-test-checkbox-red]').isNotChecked();
    });

    test('it updates the changeset on input', async function (assert) {
      const model = {
        blue: true,
        green: false,
        red: false
      };
      const changeset = Changeset(model);

      await render(
        <template>
          <Checkbox
            @changeset={{changeset}}
            @fieldName="blue"
            @label="blue"
            data-test-checkbox-blue
          />
          <Checkbox
            @changeset={{changeset}}
            @fieldName="green"
            @label="green"
            data-test-checkbox-green
          />
          <Checkbox
            @changeset={{changeset}}
            @fieldName="red"
            @label="red"
            data-test-checkbox-red
          />
        </template>
      );

      await click('[data-test-checkbox-blue]');
      await click('[data-test-checkbox-green]');
      await click('[data-test-checkbox-red]');

      assert.equal(changeset.get('blue'), false);
      assert.equal(changeset.get('green'), true);
      assert.equal(changeset.get('red'), true);
    });

    test('it receives original input values on rollback', async function (assert) {
      const model = {
        blue: true,
        green: false,
        red: false
      };
      const changeset = Changeset(model);

      await render(
        <template>
          <Checkbox
            @changeset={{changeset}}
            @fieldName="blue"
            @label="blue"
            data-test-checkbox-blue
          />
          <Checkbox
            @changeset={{changeset}}
            @fieldName="green"
            @label="green"
            data-test-checkbox-green
          />
          <Checkbox
            @changeset={{changeset}}
            @fieldName="red"
            @label="red"
            data-test-checkbox-red
          />
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
