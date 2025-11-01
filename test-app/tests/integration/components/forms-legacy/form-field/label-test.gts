import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, settled } from '@ember/test-helpers';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import Label from '@frontile/forms-legacy/components/form-field/label';
import { cell } from 'ember-resources';

registerCustomStyles({
  label: tv({
    slots: {
      base: 'form-field-label',
      asterisk: ''
    },
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
  }) as never
});
module(
  'Integration | Component | @frontile/forms-legacy/FormField::Label',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders content, attributes and args', async function (assert) {
      await render(
        <template>
          <Label @for="some-input-id" class="something-else">My Label</Label>
        </template>
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

    test('it adds size classes for @size', async function (assert) {
      const size = cell<string>('sm');

      await render(
        <template><Label data-test-input @size={{size.current}} /></template>
      );

      assert.dom('[data-test-input]').hasClass('form-field-label--sm');
      size.current = 'lg';
      await settled();
      assert.dom('[data-test-input]').hasClass('form-field-label--lg');
    });
  }
);
