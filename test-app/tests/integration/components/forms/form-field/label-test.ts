import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';

registerCustomStyles({
  label: tv({
    base: 'form-field-label' as never,
    variants: {
      size: {
        sm: 'form-field-label--sm',
        md: '',
        lg: 'form-field-label--lg'
      }
    },
    defaultVariants: {
      size: 'md'
    }
  })
});
module(
  'Integration | Component | @frontile/forms/FormField::Label',
  function(hooks) {
    setupRenderingTest(hooks);

    test('it renders content, attributes and args', async function(assert) {
      await render(
        hbs`<FormField::Label @for="some-input-id" class="something-else">My Label</FormField::Label>`
      );
      assert
        .dom('[data-test-id="form-field-label"]')
        .hasAttribute('for', 'some-input-id');

      assert
        .dom('[data-test-id="form-field-label"]')
        .hasClass('form-field-label');
      assert
        .dom('[data-test-id="form-field-label"]')
        .hasClass('something-else');
      assert
        .dom('[data-test-id="form-field-label"]')
        .hasTextContaining('My Label');
    });

    test('it adds size classes for @size', async function(assert) {
      this.set('size', 'sm');

      await render(
        hbs`<FormField::Label data-test-input @size={{this.size}} />`
      );

      assert.dom('[data-test-input]').hasClass('form-field-label--sm');
      this.set('size', 'lg');
      assert.dom('[data-test-input]').hasClass('form-field-label--lg');
    });
  }
);
