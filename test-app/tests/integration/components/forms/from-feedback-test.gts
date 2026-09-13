import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, settled } from '@ember/test-helpers';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';

import { FormFeedback, type FormFeedbackSignature } from 'frontile';
import { cell } from 'ember-resources';
import { trackDeprecations } from '../../../helpers/deprecations';

registerCustomStyles({
  formFeedback: tv({
    base: 'form-field-feedback' as never,
    variants: {
      status: {
        primary: 'status-primary',
        secondary: 'status-secondary',
        success: 'status-success',
        warning: 'status-warning',
        danger: 'form-field-feedback--error'
      },
      size: {
        sm: 'form-field-feedback--sm',
        md: '',
        lg: 'form-field-feedback--lg'
      }
    },
    defaultVariants: {
      size: 'sm'
    }
  }) as never
});

module(
  'Integration | Component | @frontile/forms/FormFeedback',
  function (hooks) {
    setupRenderingTest(hooks);

    const messages = cell<string[] | string>();
    const status = cell<FormFeedbackSignature['Args']['status']>('danger');

    hooks.beforeEach(async function () {
      await render(
        <template>
          <FormFeedback
            @id="feedback"
            @messages={{messages.current}}
            @status={{status.current}}
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

    test('it adds the class for the secondary status', async function (assert) {
      messages.current = 'My message';
      status.current = 'secondary';
      await settled();

      assert
        .dom('[data-component="form-feedback"]')
        .hasClass('status-secondary');
    });

    test('it renders aria-live', async function (assert) {
      messages.current = 'My message';
      status.current = 'danger';
      await settled();

      assert
        .dom('[data-component="form-feedback"]')
        .hasAria('live', 'assertive');

      status.current = 'primary';
      await settled();

      assert.dom('[data-component="form-feedback"]').hasAria('live', 'polite');
    });

    test('renders data-component="form-feedback" on the root only, with data-part="base"', async function (assert) {
      messages.current = 'My message';
      await settled();

      assert
        .dom('[data-component="form-feedback"]')
        .hasAttribute('data-part', 'base');
      assert.strictEqual(
        document.querySelectorAll('[data-component="form-feedback"]').length,
        1,
        'data-component="form-feedback" marks the root only'
      );
    });

    module('announcement', function () {
      test('omitting @status still announces assertively', async function (assert) {
        await render(
          <template><FormFeedback @messages="bad" data-test-id="f" /></template>
        );

        // The default is `danger`. The ABSENCE of the arg must not quietly
        // downgrade an error announcement to polite -- this is the whole
        // reason the prop is `@status` and not `@color`.
        assert.dom('[data-test-id="f"]').hasAttribute('aria-live', 'assertive');
      });

      test('a non-danger @status announces politely', async function (assert) {
        await render(
          <template>
            <FormFeedback @status="success" @messages="ok" data-test-id="f" />
          </template>
        );

        assert.dom('[data-test-id="f"]').hasAttribute('aria-live', 'polite');
      });

      test('deprecated @intent="danger" still announces assertively', async function (assert) {
        const { ids } = trackDeprecations();

        await render(
          <template>
            <FormFeedback @intent="danger" @messages="bad" data-test-id="f" />
          </template>
        );

        assert.dom('[data-test-id="f"]').hasAttribute('aria-live', 'assertive');
        assert.deepEqual(ids, ['frontile.form-feedback.intent']);
      });
    });
  }
);
