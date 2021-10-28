import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, blur } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';
import { Changeset } from 'ember-changeset';
import lookupValidator from 'ember-changeset-validations';
import { run } from '@ember/runloop';
import { selectChoose } from 'ember-power-select/test-support/helpers';

module(
  'Integration | Component | ChangesetForm::Fields::Select',
  function (hooks) {
    setupRenderingTest(hooks);

    hooks.beforeEach(async function beforeEach(this: {
      set: (key: string, val: unknown) => void;
    }) {
      const model = {
        framework: 'Ember'
      };
      const validations = {
        framework: (_: string, value: string | undefined) => {
          if (value === 'Ruby') {
            return 'Please select a Framework, not a language';
          }
          return true;
        }
      };
      this.set('changeset', Changeset(model, lookupValidator(validations)));
      this.set('frameworks', ['Ember', 'Glimmer', 'React', 'Vue', 'Ruby']);

      await render(hbs`
        <ChangesetForm::Fields::Select
          @containerClass="field-container"
          @changeset={{this.changeset}}
          @fieldName="framework"
          @options={{this.frameworks}}
          @hasError={{this.hasError}}
          data-test-text-input
          as |name|
        >
          {{name}}
        </ChangesetForm::Fields::Select>
    `);
    });

    test('it renders with initial model value', async function (assert) {
      assert
        .dom('.field-container .ember-power-select-trigger')
        .hasTextContaining('Ember');
    });

    test('it updates the changeset on input', async function (assert) {
      await selectChoose('.field-container', 'Glimmer');

      assert.equal(this.changeset.get('framework'), 'Glimmer');
    });

    test('it displays error message on focus out', async function (assert) {
      assert
        .dom('.field-container')
        .doesNotHaveTextContaining('Please select a Framework, not a language');

      await selectChoose('.field-container', 'Ruby');
      await blur('.field-container .ember-power-select-trigger');

      assert
        .dom('.field-container')
        .hasTextContaining('Please select a Framework, not a language');
    });

    test('it displays error message immediately if hasError is true', async function (assert) {
      this.set('hasError', true);

      await selectChoose('.field-container', 'Ruby');

      assert
        .dom('.field-container')
        .hasTextContaining('Please select a Framework, not a language');
    });

    test('it receives original input values on rollback', async function (assert) {
      await selectChoose('.field-container', 'Glimmer');

      run(() => {
        this.changeset.rollback();
      });

      assert
        .dom('.field-container .ember-power-select-trigger')
        .hasTextContaining('Ember');
    });
  }
);
