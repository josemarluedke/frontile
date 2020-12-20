import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';
import { Changeset } from 'ember-changeset';
import { run } from '@ember/runloop';
import lookupValidator from 'ember-changeset-validations';

module(
  'Integration | Component | ChangesetForm::Fields::RadioGroup',
  function (hooks) {
    setupRenderingTest(hooks);

    hooks.beforeEach(async function beforeEach(this: {
      set: (key: string, val: unknown) => void;
    }) {
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
      this.set('changeset', Changeset(model, lookupValidator(validations)));

      await render(hbs`
        <ChangesetForm::Fields::RadioGroup
          @changeset={{this.changeset}}
          @fieldName="color"
          class="field-container"
          as |Radio|
        >
          <Radio
            @value="blue"
            data-test-radio-blue
          />
          <Radio
            @value="green"
            data-test-radio-green
          />
          <Radio
            @value="red"
            data-test-radio-red
          />
        </ChangesetForm::Fields::RadioGroup>
    `);
    });

    test('it renders with initial model value', async function (assert) {
      assert.dom('[data-test-radio-blue]').isChecked();
      assert.dom('[data-test-radio-green]').isNotChecked();
      assert.dom('[data-test-radio-red]').isNotChecked();
    });

    test('it updates the changeset on input', async function (assert) {
      await click('[data-test-radio-green]');
      await click('[data-test-radio-red]');

      assert.equal(this.changeset.get('color'), 'red');
    });

    test('it displays error message after option is selected', async function (assert) {
      await click('[data-test-radio-green]');

      assert
        .dom('.field-container')
        .hasTextContaining('Please select another color');
    });

    test('it receives original input values on rollback', async function (assert) {
      await click('[data-test-radio-green]');

      assert.dom('[data-test-radio-blue]').isNotChecked();
      assert.dom('[data-test-radio-red]').isNotChecked();

      run(() => {
        this.changeset.rollback();
      });
      assert.dom('[data-test-radio-blue]').isChecked();
    });
  }
);
