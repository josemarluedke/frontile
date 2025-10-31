import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, settled } from '@ember/test-helpers';

import { FormFeedback, type FormFeedbackSignature } from 'frontile';
import { cell } from 'ember-resources';

module(
  'Integration | Component | @frontile/forms/FormFeedback',
  function (hooks) {
    setupRenderingTest(hooks);

    const messages = cell<string[] | string>();
    const intent = cell<FormFeedbackSignature['Args']['intent']>('danger');

    hooks.beforeEach(async function () {
      await render(
        <template>
          <FormFeedback
            @id="feedback"
            @messages={{messages.current}}
            @intent={{intent.current}}
          />
        </template>
      );
    });

    test('it renders a list of messages', async function (assert) {
      messages.current = ['Item 1', 'Error 2'];
      await settled();

      assert.dom('[data-component="form-feedback"]').hasText('Item 1; Error 2');
      assert
        .dom('[data-component="form-feedback"]')
        .hasAttribute('id', 'feedback');
    });

    test('it renders a single string of message', async function (assert) {
      messages.current = 'My message';
      await settled();

      assert.dom('[data-component="form-feedback"]').hasText('My message');
      assert
        .dom('[data-component="form-feedback"]')
        .hasAttribute('id', 'feedback');
    });

    test('it renders aria-live', async function (assert) {
      messages.current = 'My message';
      intent.current = 'danger';
      await settled();

      assert
        .dom('[data-component="form-feedback"]')
        .hasAria('live', 'assertive');

      intent.current = 'primary';
      await settled();

      assert.dom('[data-component="form-feedback"]').hasAria('live', 'polite');
    });
  }
);
