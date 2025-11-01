import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, blur, settled } from '@ember/test-helpers';
import { Changeset } from 'ember-changeset';
import lookupValidator from 'ember-changeset-validations';
import { run } from '@ember/runloop';
import { selectChoose } from 'ember-power-select/test-support';
import Select from '@frontile/changeset-form/components/changeset-form/fields/select';
import { cell } from 'ember-resources';

module(
  'Integration | Component | @frontile/changeset-form/ChangesetForm::Fields::Select',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders with initial model value', async function (assert) {
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
      const changeset = Changeset(model, lookupValidator(validations));
      const frameworks = ['Ember', 'Glimmer', 'React', 'Vue', 'Ruby'];
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);

      await render(
        <template>
          <Select
            @containerClass="field-container"
            @changeset={{changeset}}
            @fieldName="framework"
            @options={{frameworks}}
            @hasError={{hasError.current}}
            @showError={{showError.current}}
            @renderInPlace={{true}}
            data-test-text-input
            as |name|
          >
            {{name}}
          </Select>
        </template>
      );

      assert
        .dom('.field-container .ember-power-select-trigger')
        .hasTextContaining('Ember');
    });

    test('it updates the changeset on input', async function (assert) {
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
      const changeset = Changeset(model, lookupValidator(validations));
      const frameworks = ['Ember', 'Glimmer', 'React', 'Vue', 'Ruby'];
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);

      await render(
        <template>
          <Select
            @containerClass="field-container"
            @changeset={{changeset}}
            @fieldName="framework"
            @options={{frameworks}}
            @hasError={{hasError.current}}
            @showError={{showError.current}}
            @renderInPlace={{true}}
            data-test-text-input
            as |name|
          >
            {{name}}
          </Select>
        </template>
      );

      await selectChoose('.field-container', 'Glimmer');

      assert.equal(changeset.get('framework'), 'Glimmer');
    });

    test('it displays error message on focus out', async function (assert) {
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
      const changeset = Changeset(model, lookupValidator(validations));
      const frameworks = ['Ember', 'Glimmer', 'React', 'Vue', 'Ruby'];
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);

      await render(
        <template>
          <Select
            @containerClass="field-container"
            @changeset={{changeset}}
            @fieldName="framework"
            @options={{frameworks}}
            @hasError={{hasError.current}}
            @showError={{showError.current}}
            @renderInPlace={{true}}
            data-test-text-input
            as |name|
          >
            {{name}}
          </Select>
        </template>
      );

      assert
        .dom('.field-container')
        .doesNotHaveTextContaining('Please select a Framework, not a language');

      await selectChoose('.field-container', 'Ruby');
      await blur('.field-container .ember-power-select-trigger');

      assert
        .dom('.field-container')
        .hasTextContaining('Please select a Framework, not a language');
    });

    test.skip('it displays error message immediately if hasError is true and showError is true', async function (assert) {
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
      const changeset = Changeset(model, lookupValidator(validations));
      const frameworks = ['Ember', 'Glimmer', 'React', 'Vue', 'Ruby'];
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);

      await render(
        <template>
          <Select
            @containerClass="field-container"
            @changeset={{changeset}}
            @fieldName="framework"
            @options={{frameworks}}
            @hasError={{hasError.current}}
            @showError={{showError.current}}
            @renderInPlace={{true}}
            data-test-text-input
            as |name|
          >
            {{name}}
          </Select>
        </template>
      );

      hasError.current = true;
      showError.current = true;
      await settled();

      await selectChoose('.field-container', 'Ruby');

      assert
        .dom('.field-container')
        .hasTextContaining('Please select a Framework, not a language');
    });

    test('it receives original input values on rollback', async function (assert) {
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
      const changeset = Changeset(model, lookupValidator(validations));
      const frameworks = ['Ember', 'Glimmer', 'React', 'Vue', 'Ruby'];
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);

      await render(
        <template>
          <Select
            @containerClass="field-container"
            @changeset={{changeset}}
            @fieldName="framework"
            @options={{frameworks}}
            @hasError={{hasError.current}}
            @showError={{showError.current}}
            @renderInPlace={{true}}
            data-test-text-input
            as |name|
          >
            {{name}}
          </Select>
        </template>
      );

      await selectChoose('.field-container', 'Glimmer');

      run(() => {
        changeset.rollback();
      });

      assert
        .dom('.field-container .ember-power-select-trigger')
        .hasTextContaining('Ember');
    });
  }
);
