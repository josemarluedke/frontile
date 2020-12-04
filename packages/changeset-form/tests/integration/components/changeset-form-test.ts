/* eslint-disable ember/no-get */
import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, fillIn, render, blur } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';
import validateFormat from 'ember-changeset-validations/validators/format';
import validatePresence from 'ember-changeset-validations/validators/presence';

interface Model {
  name: {
    first: string;
    last: string;
  };
  email: string;
}

declare module 'ember-test-helpers' {
  interface TestContext {
    model: Model;
  }
}

module('Integration | Component | ChangesetForm', function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(async function beforeEach(this: {
    set: (key: string, val: unknown) => void;
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

    await render(hbs`
      {{#let (changeset this.model this.validations) as |changesetObj|}}
        <ChangesetForm
          @changeset={{changesetObj}}
          @onSubmit={{this.onSubmit}}
          @onReset={{this.onReset}}
          data-test-changeset-form
          as |Form changeset state|
        >
        {{log changesetObj changeset}}
          <div data-test-id="has-submitted">{{state.hasSubmitted}}</div>
          {{#if changeset.isInvalid}}
            <p data-test-id="form-error">There were one or more errors in your form.</p>
          {{/if}}
          <Form.Input
            @fieldName="name.first"
            @label="First Name"
            data-test-name-first-input
          />
          <div data-test-name-first>{{changeset.name.first}}</div>
          
          <Form.Input
            @fieldName="name.last"
            @label="Last Name"
            data-test-name-last-input
          />
          <div data-test-name-last>{{changeset.name.last}}</div>
          <Form.Input
            @containerClass="email-field"
            @fieldName="email"
            @label="Email Address"
            data-test-email-input
          />
          <div data-test-email>{{changeset.email}}</div>

          <button type="submit" data-test-submit>Submit</button>
          <button type="reset" data-test-reset>Reset</button>
        </ChangesetForm>
      {{/let}}
    `);
  });

  test('it renders with initial value from model', async function (assert) {
    assert
      .dom('[data-test-changeset-form]')
      .exists('The ChangesetForm failed to render');

    assert
      .dom('[data-test-name-first-input]')
      .hasValue(this.get('model.name.first'));

    assert
      .dom('[data-test-name-last-input]')
      .hasValue(this.get('model.name.last'));

    assert.dom('[data-test-email-input]').hasValue(this.get('model.email'));
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

    this.set('onReset', () => {
      assert.ok(true, 'onSubmit called');
    });

    await click('[data-test-reset]');

    assert.dom('[data-test-name-first-input]').hasValue('Chim');
    assert.dom('[data-test-name-last-input]').hasValue('Richolds');
    assert.dom('[data-test-email-input]').hasValue('chim.richolds@example.com');
  });

  test('it calls onSubmit when the submit button is clicked and marks hasSubmitted to true', async function (assert) {
    assert.expect(8);
    await fillIn('[data-test-name-first-input]', 'James');
    await fillIn('[data-test-name-last-input]', 'Silva');
    await fillIn('[data-test-email-input]', 'james.silva@gmail.com');

    this.set('onSubmit', () => {
      assert.ok(true, 'onSubmit called');
    });

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
});
