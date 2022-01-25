import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { blur, fillIn, render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';
import { Changeset } from 'ember-changeset';
import lookupValidator from 'ember-changeset-validations';
import validatePresence from 'ember-changeset-validations/validators/presence';
import { run } from '@ember/runloop';

module(
  'Integration | Component | ChangesetForm::Fields::Input',
  function (hooks) {
    setupRenderingTest(hooks);

    hooks.beforeEach(async function beforeEach(this: {
      set: (key: string, val: unknown) => void;
    }) {
      const model = {
        message: 'EmberJS'
      };
      const validations = {
        message: validatePresence(true)
      };
      this.set('changeset', Changeset(model, lookupValidator(validations)));

      await render(hbs`
        <ChangesetForm::Fields::Input
          @containerClass="field-container"
          @changeset={{this.changeset}}
          @hasError={{this.hasError}}
          @fieldName="message"
          data-test-text-input
        />
    `);
    });

    test('it renders with initial model value', async function (assert) {
      assert.dom('[data-test-text-input]').hasValue('EmberJS');
    });

    test('it updates the changeset on input', async function (assert) {
      await fillIn('[data-test-text-input]', 'Glimmer');

      assert.equal(this.changeset.get('message'), 'Glimmer');
    });

    test('it displays error message on focus out', async function (assert) {
      await fillIn('[data-test-text-input]', '');
      assert
        .dom('.field-container')
        .doesNotHaveTextContaining("Message can't be blank");

      await blur('[data-test-text-input]');

      assert
        .dom('.field-container')
        .hasTextContaining("Message can't be blank");
    });

    test('it displays error message immediately if hasError is true', async function (assert) {
      this.set('hasError', true);

      await fillIn('[data-test-text-input]', '');

      assert
        .dom('.field-container')
        .hasTextContaining("Message can't be blank");
    });

    test('it receives original input values on rollback', async function (assert) {
      await fillIn('[data-test-text-input]', 'Glimmer');

      run(() => {
        this.changeset.rollback();
      });
      assert.dom('[data-test-text-input]').hasValue('EmberJS');
    });
  }
);
