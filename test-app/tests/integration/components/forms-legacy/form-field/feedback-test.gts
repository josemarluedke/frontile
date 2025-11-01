import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, settled } from '@ember/test-helpers';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import FormFieldFeedback from '@frontile/forms-legacy/components/form-field/feedback';
import { cell } from 'ember-resources';

registerCustomStyles({
  formFeedback: tv({
    base: 'form-field-feedback' as never,
    variants: {
      intent: {
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
  })
});

module(
  'Integration | Component | @frontile/forms-legacy/FormField::Feedback',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders an array of errors', async function (assert) {
      const errors = cell<string[]>(['Some error']);
      await render(
        <template>
          <FormFieldFeedback @id="feedback-id" @errors={{errors.current}} />
        </template>
      );

      assert
        .dom('[data-test-id="form-field-feedback"]')
        .hasAttribute('id', 'feedback-id');

      assert
        .dom('[data-test-id="form-field-feedback"]')
        .containsText('Some error');
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .hasClass('form-field-feedback--error');
    });

    test('it renders an array of errors by joing elements', async function (assert) {
      const errors = cell<string[]>(['Some error', 'Another error']);
      await render(
        <template>
          <FormFieldFeedback @id="feedback-id" @errors={{errors.current}} />
        </template>
      );
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .containsText('Some error; Another error');
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .hasClass('form-field-feedback--error');
    });

    test('it renders when passing an string', async function (assert) {
      const errors = cell<string>('Another error');
      await render(
        <template>
          <FormFieldFeedback @id="feedback-id" @errors={{errors.current}} />
        </template>
      );
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .containsText('Another error');
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .hasClass('form-field-feedback--error');
    });

    test('it adds aria-live as assertive', async function (assert) {
      const errors = cell<string>('An error');
      await render(
        <template>
          <FormFieldFeedback @id="feedback-id" @errors={{errors.current}} />
        </template>
      );
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .hasAttribute('aria-live', 'assertive');
    });

    test('it adds size classes for @size', async function (assert) {
      const size = cell<string>('sm');

      await render(
        <template>
          <FormFieldFeedback data-test-input @size={{size.current}} />
        </template>
      );

      assert.dom('[data-test-input]').hasClass('form-field-feedback--sm');
      size.current = 'lg';
      await settled();
      assert.dom('[data-test-input]').hasClass('form-field-feedback--lg');
    });

    test('it does not break if passed an undefined arg', async function (assert) {
      const errors = cell<undefined>(undefined);
      await render(
        <template>
          <FormFieldFeedback @id="feedback-id" @errors={{errors.current}} />
        </template>
      );
      assert.dom('[data-test-id="form-field-feedback"]').exists();
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .doesNotHaveClass('form-field-feedback--error');
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .hasAttribute('aria-live', 'polite');
    });

    test('it renders passed in block', async function (assert) {
      await render(
        <template>
          <FormFieldFeedback>Block content</FormFieldFeedback>
        </template>
      );
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .doesNotHaveClass('form-field-feedback--error');
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .containsText('Block content');
    });

    test('it adds errors class if @isError is passed in', async function (assert) {
      await render(
        <template>
          <FormFieldFeedback @isError={{true}}>Block content</FormFieldFeedback>
        </template>
      );
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .hasClass('form-field-feedback--error');
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .containsText('Block content');
    });
  }
);
