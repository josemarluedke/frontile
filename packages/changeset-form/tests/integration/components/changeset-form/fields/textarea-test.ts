import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { blur, fillIn, render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';
import { Changeset } from 'ember-changeset';
import lookupValidator from 'ember-changeset-validations';
import validatePresence from 'ember-changeset-validations/validators/presence';
import { run } from '@ember/runloop';

module(
  'Integration | Component | ChangesetForm::Fields::Textarea',
  function (hooks) {
    setupRenderingTest(hooks);

    hooks.beforeEach(async function beforeEach(this: {
      set: (key: string, val: unknown) => void;
    }) {
      const model = {
        notification: {
          message: 'EmberJS'
        }
      };
      const validations = {
        notification: {
          message: validatePresence(true)
        }
      };
      this.set('changeset', Changeset(model, lookupValidator(validations)));

      await render(hbs`
        <ChangesetForm::Fields::Textarea
          @containerClass="field-container"
          @changeset={{this.changeset}}
          @fieldName="notification.message"
          @hasError={{this.hasError}}
          @showError={{this.showError}}
          data-test-text-input
        />
    `);
    });

    test('it renders with initial model value', async function (assert) {
      assert.dom('[data-test-text-input]').hasValue('EmberJS');
    });

    test('it updates the changeset on input', async function (assert) {
      await fillIn('[data-test-text-input]', 'Glimmer');

      assert.equal(this.changeset.get('notification.message'), 'Glimmer');
    });

    test('it displays error message on focus out', async function (assert) {
      await fillIn('[data-test-text-input]', '');
      assert
        .dom('.field-container')
        .doesNotHaveTextContaining("message can't be blank");

      await blur('[data-test-text-input]');

      assert
        .dom('.field-container')
        .matchesText(/Notification.message can't be blank/);
    });

    test('it displays error message immediately if hasError is true and showError', async function (assert) {
      this.set('hasError', true);
      this.set('showError', true);

      await fillIn('[data-test-text-input]', '');

      assert
        .dom('.field-container')
        .matchesText(/Notification.message can't be blank/);
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
