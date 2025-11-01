import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render } from '@ember/test-helpers';
import { Changeset } from 'ember-changeset';
import { run } from '@ember/runloop';
import Radio from '@frontile/changeset-form/components/changeset-form/fields/radio';

module(
  'Integration | Component | @frontile/changeset-form/ChangesetForm::Fields::Radio',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders with initial model value', async function (assert) {
      const model = {
        color: 'blue'
      };
      const changeset = Changeset(model);

      await render(
        <template>
          <Radio
            @changeset={{changeset}}
            @fieldName="color"
            @value="blue"
            name="color"
            data-test-radio-blue
          />
          <Radio
            @changeset={{changeset}}
            @fieldName="color"
            @value="green"
            name="color"
            data-test-radio-green
          />
          <Radio
            @changeset={{changeset}}
            @fieldName="color"
            @value="red"
            name="color"
            data-test-radio-red
          />
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
      const changeset = Changeset(model);

      await render(
        <template>
          <Radio
            @changeset={{changeset}}
            @fieldName="color"
            @value="blue"
            name="color"
            data-test-radio-blue
          />
          <Radio
            @changeset={{changeset}}
            @fieldName="color"
            @value="green"
            name="color"
            data-test-radio-green
          />
          <Radio
            @changeset={{changeset}}
            @fieldName="color"
            @value="red"
            name="color"
            data-test-radio-red
          />
        </template>
      );

      await click('[data-test-radio-green]');
      await click('[data-test-radio-red]');

      assert.equal(changeset.get('color'), 'red');
    });

    test('it receives original input values on rollback', async function (assert) {
      const model = {
        color: 'blue'
      };
      const changeset = Changeset(model);

      await render(
        <template>
          <Radio
            @changeset={{changeset}}
            @fieldName="color"
            @value="blue"
            name="color"
            data-test-radio-blue
          />
          <Radio
            @changeset={{changeset}}
            @fieldName="color"
            @value="green"
            name="color"
            data-test-radio-green
          />
          <Radio
            @changeset={{changeset}}
            @fieldName="color"
            @value="red"
            name="color"
            data-test-radio-red
          />
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
