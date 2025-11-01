import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, settled } from '@ember/test-helpers';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import Hint from '@frontile/forms-legacy/components/form-field/hint';
import { cell } from 'ember-resources';

registerCustomStyles({
  formDescription: tv({
    base: 'form-field-hint' as never,
    variants: {
      size: {
        sm: 'form-field-hint--sm',
        md: '',
        lg: 'form-field-hint--lg'
      }
    },
    defaultVariants: {
      size: 'md'
    }
  })
});

module(
  'Integration | Component | @frontile/forms-legacy/FormField::Hint',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders content, attributes and args', async function (assert) {
      await render(
        <template>
          <Hint @id="some-hint-id" class="something-else">Content</Hint>
        </template>
      );
      assert
        .dom('[data-test-id="form-field-hint"]')
        .hasAttribute('id', 'some-hint-id');

      assert
        .dom('[data-test-id="form-field-hint"]')
        .hasClass('form-field-hint');
      assert.dom('[data-test-id="form-field-hint"]').hasClass('something-else');
      assert
        .dom('[data-test-id="form-field-hint"]')
        .hasTextContaining('Content');
    });

    test('it adds size classes for @size', async function (assert) {
      const size = cell<string>('sm');

      await render(
        <template><Hint data-test-input @size={{size.current}} /></template>
      );

      assert.dom('[data-test-input]').hasClass('form-field-hint--sm');
      size.current = 'lg';
      await settled();
      assert.dom('[data-test-input]').hasClass('form-field-hint--lg');
    });
  }
);
