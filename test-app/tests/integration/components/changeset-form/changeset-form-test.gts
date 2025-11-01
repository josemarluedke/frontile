/* eslint-disable ember/no-get */
import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, fillIn, render, blur, settled } from '@ember/test-helpers';
import validateFormat from 'ember-changeset-validations/validators/format';
import validatePresence from 'ember-changeset-validations/validators/presence';
import { Changeset } from 'ember-changeset';
import lookupValidator from 'ember-changeset-validations';
import ChangesetForm from '@frontile/changeset-form/components/changeset-form/index';
import { cell } from 'ember-resources';

interface Model {
  name: {
    first: string;
    last: string;
  };
  email: string;
}

declare module '@ember/test-helpers' {
  interface TestContext {
    model: Model;
  }
}

module(
  'Integration | Component | @frontile/changeset-form/ChangesetForm',
  function (hooks) {
    setupRenderingTest(hooks);

    hooks.beforeEach(async function beforeEach(this: {
      set: (key: string, val: unknown) => void;
      onSubmit: ReturnType<typeof cell>;
      onReset: ReturnType<typeof cell>;
      validateOnInit: ReturnType<typeof cell>;
      alwaysShowErrors: ReturnType<typeof cell>;
    }) {
      const model = {
        name: {
          first: 'Chim',
          last: 'Richolds'
        },
        email: 'chim.richolds@example.com'
      };
      const validations = {
        'name.first': validatePresence(true),
        'name.last': validatePresence(true),
        email: validateFormat({ type: 'email' })
      };
      this.set('model', model);
      this.set('validations', validations);

      const changesetObj = Changeset(model, lookupValidator(validations));
      this.onSubmit = cell<(() => void) | undefined>(undefined);
      this.onReset = cell<(() => void) | undefined>(undefined);
      this.validateOnInit = cell<boolean | undefined>(undefined);
      this.alwaysShowErrors = cell<boolean | undefined>(undefined);

      // Create wrapper functions that call the cell values
      const onSubmit = () => {
        if (this.onSubmit.current) {
          this.onSubmit.current();
        }
      };
      const onReset = () => {
        if (this.onReset.current) {
          this.onReset.current();
        }
      };

      await render(
        <template>
          <ChangesetForm
            @changeset={{changesetObj}}
            @onSubmit={{onSubmit}}
            @onReset={{onReset}}
            @validateOnInit={{this.validateOnInit.current}}
            @alwaysShowErrors={{this.alwaysShowErrors.current}}
            data-test-changeset-form
            as |Form|
          >
            <div data-test-id="has-submitted">{{Form.state.hasSubmitted}}</div>
            {{#if changesetObj.isInvalid}}
              <p data-test-id="form-error">There were one or more errors in your
                form.</p>
            {{/if}}
            <Form.Input
              @fieldName="name.first"
              @label="First Name"
              data-test-name-first-input
            />
            <div data-test-name-first>{{changesetObj.name.first}}</div>

            <Form.Input
              @fieldName="name.last"
              @label="Last Name"
              data-test-name-last-input
            />
            <div data-test-name-last>{{changesetObj.name.last}}</div>
            <Form.Input
              @containerClass="email-field"
              @fieldName="email"
              @label="Email Address"
              data-test-email-input
            />
            <div data-test-email>{{changesetObj.email}}</div>

            <button type="submit" data-test-submit>Submit</button>
            <button type="reset" data-test-reset>Reset</button>
          </ChangesetForm>
        </template>
      );
    });

    test('it renders with initial value from model', async function (assert) {
      assert
        .dom('[data-test-changeset-form]')
        .exists('The ChangesetForm failed to render');

      assert
        .dom('[data-test-name-first-input]')
        .hasValue(this.model.name.first);

      assert.dom('[data-test-name-last-input]').hasValue(this.model.name.last);

      assert.dom('[data-test-email-input]').hasValue(this.model.email);
    });

    test('it validates and then updates the changeset on input', async function (assert) {
      await fillIn('[data-test-email-input]', 'notanemailaddress');
      await blur('[data-test-email-input]');

      assert
        .dom('.email-field')
        .hasTextContaining('Email must be a valid email address');

      assert.dom('[data-test-email]').hasTextContaining('notanemailaddress');
    });

    test('it rolls-back the changeset, and calls onReset when reset is clicked', async function (assert) {
      assert.expect(7);
      await fillIn('[data-test-name-first-input]', 'James');
      await fillIn('[data-test-name-last-input]', 'Silva');
      await fillIn('[data-test-email-input]', 'james.silva@gmail.com');

      assert.dom('[data-test-name-first-input]').hasValue('James');
      assert.dom('[data-test-name-last-input]').hasValue('Silva');
      assert.dom('[data-test-email-input]').hasValue('james.silva@gmail.com');

      this.onReset.current = () => {
        assert.ok(true, 'onSubmit called');
      };

      await click('[data-test-reset]');

      assert.dom('[data-test-name-first-input]').hasValue('Chim');
      assert.dom('[data-test-name-last-input]').hasValue('Richolds');
      assert
        .dom('[data-test-email-input]')
        .hasValue('chim.richolds@example.com');
    });

    test('it calls onSubmit when the submit button is clicked and marks hasSubmitted to true', async function (assert) {
      assert.expect(8);
      await fillIn('[data-test-name-first-input]', 'James');
      await fillIn('[data-test-name-last-input]', 'Silva');
      await fillIn('[data-test-email-input]', 'james.silva@gmail.com');

      this.onSubmit.current = () => {
        assert.ok(true, 'onSubmit called');
      };

      assert.dom('[data-test-id="has-submitted"]').hasText('false');
      await click('[data-test-submit]');

      assert.dom('[data-test-id="has-submitted"]').hasText('true');

      const model = this.model;
      assert.equal(
        model.name.first.trim(),
        'James',
        'First name did not update on save'
      );
      assert.equal(
        model.name.last.trim(),
        'Silva',
        'Last name did not update on save'
      );
      assert.equal(
        model.email.trim(),
        'james.silva@gmail.com',
        'Email address did not update on save'
      );

      assert.dom('[data-test-name-first]').hasTextContaining('James');
      assert.dom('[data-test-name-last]').hasTextContaining('Silva');

      // https://github.com/poteto/ember-changeset/pull/404
      // await fillIn('[data-test-name-first-input]', 'James2');

      // assert.dom('[data-test-name-first]').hasTextContaining('James2');
      // assert.dom('[data-test-name-last]').hasTextContaining('Silva');
    });

    test('it shows error message when the changeset is invalid', async function (assert) {
      assert.expect(1);
      await fillIn('[data-test-email-input]', '');
      await click('[data-test-submit]');
      assert.dom('[data-test-id="form-error"]').exists();
    });

    test.skip('it shows error message immediately when the changeset is invalid if alwaysShowErrors is true', async function (assert) {
      const invalidModel = {
        email: 'invalidemail'
      };
      const validationsTwo = {
        email: validateFormat({ type: 'email' })
      };
      const changesetObj2 = Changeset(
        invalidModel,
        lookupValidator(validationsTwo)
      );
      await changesetObj2.validate();
      await settled();
      const onSubmitCell = cell<(() => void) | undefined>(undefined);
      const onResetCell = cell<(() => void) | undefined>(undefined);

      const onSubmit = () => {
        if (onSubmitCell.current) {
          onSubmitCell.current();
        }
      };
      const onReset = () => {
        if (onResetCell.current) {
          onResetCell.current();
        }
      };

      await render(
        <template>
          <ChangesetForm
            @changeset={{changesetObj2}}
            @onSubmit={{onSubmit}}
            @onReset={{onReset}}
            @validateOnInit={{true}}
            @alwaysShowErrors={{false}}
            data-test-changeset-form-two
            as |Form changeset|
          >
            {{#if changesetObj2.isInvalid}}
              <p data-test-id="form-error-two">There were one or more errors in
                your form.</p>
            {{/if}}

            <Form.Input
              @containerClass="email-field"
              @fieldName="email"
              @label="Email Address"
              data-test-email-input-two
            />
            <div data-test-email-two>{{changeset.email}}</div>

            <button type="submit" data-test-submit-two>Submit</button>
            <button type="reset" data-test-reset-two>Reset</button>
          </ChangesetForm>
        </template>
      );

      assert.expect(1);

      assert.dom('[data-test-id="form-error-two"]').exists();
    });
  }
);
