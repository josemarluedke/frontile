import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { blur, fillIn, render, settled } from '@ember/test-helpers';
import { Changeset } from 'ember-changeset';
import lookupValidator from 'ember-changeset-validations';
import validatePresence from 'ember-changeset-validations/validators/presence';
import { run } from '@ember/runloop';
import Textarea from '@frontile/changeset-form/components/changeset-form/fields/textarea';
import { cell } from 'ember-resources';

module(
  'Integration | Component | @frontile/changeset-form/ChangesetForm::Fields::Textarea',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders with initial model value', async function (assert) {
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
      const changeset = Changeset(model, lookupValidator(validations));
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);

      await render(
        <template>
          <Textarea
            @containerClass="field-container"
            @changeset={{changeset}}
            @fieldName="notification.message"
            @hasError={{hasError.current}}
            @showError={{showError.current}}
            data-test-text-input
          />
        </template>
      );

      assert.dom('[data-test-text-input]').hasValue('EmberJS');
    });

    test('it updates the changeset on input', async function (assert) {
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
      const changeset = Changeset(model, lookupValidator(validations));
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);

      await render(
        <template>
          <Textarea
            @containerClass="field-container"
            @changeset={{changeset}}
            @fieldName="notification.message"
            @hasError={{hasError.current}}
            @showError={{showError.current}}
            data-test-text-input
          />
        </template>
      );

      await fillIn('[data-test-text-input]', 'Glimmer');

      assert.equal(changeset.get('notification.message'), 'Glimmer');
    });

    test('it displays error message on focus out', async function (assert) {
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
      const changeset = Changeset(model, lookupValidator(validations));
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);

      await render(
        <template>
          <Textarea
            @containerClass="field-container"
            @changeset={{changeset}}
            @fieldName="notification.message"
            @hasError={{hasError.current}}
            @showError={{showError.current}}
            data-test-text-input
          />
        </template>
      );

      await fillIn('[data-test-text-input]', '');
      assert
        .dom('.field-container')
        .doesNotHaveTextContaining("message can't be blank");

      await blur('[data-test-text-input]');

      assert
        .dom('.field-container')
        .matchesText(/Notification.message can't be blank/);
    });

    test.skip('it displays error message immediately if hasError is true and showError', async function (assert) {
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
      const changeset = Changeset(model, lookupValidator(validations));
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);

      await render(
        <template>
          <Textarea
            @containerClass="field-container"
            @changeset={{changeset}}
            @fieldName="notification.message"
            @hasError={{hasError.current}}
            @showError={{showError.current}}
            data-test-text-input
          />
        </template>
      );

      hasError.current = true;
      showError.current = true;
      await settled();

      await fillIn('[data-test-text-input]', '');

      assert
        .dom('.field-container')
        .matchesText(/Notification.message can't be blank/);
    });

    test('it receives original input values on rollback', async function (assert) {
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
      const changeset = Changeset(model, lookupValidator(validations));
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);

      await render(
        <template>
          <Textarea
            @containerClass="field-container"
            @changeset={{changeset}}
            @fieldName="notification.message"
            @hasError={{hasError.current}}
            @showError={{showError.current}}
            data-test-text-input
          />
        </template>
      );

      await fillIn('[data-test-text-input]', 'Glimmer');

      run(() => {
        changeset.rollback();
      });
      assert.dom('[data-test-text-input]').hasValue('EmberJS');
    });
  }
);
