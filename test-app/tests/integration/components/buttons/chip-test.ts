import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';

registerCustomStyles({
  chip: tv({
    slots: {
      base: ['chip'],
      content: ['chip-content'],
      dot: ['chip-dot'],
      closeButton: ['chip-close-button']
    },
    variants: {
      appearance: {
        default: 'chip-default',
        outlined: 'chip-outlined',
        faded: 'chip-faded'
      },
      intent: {
        default: 'intent-default',
        primary: 'intent-primary',
        success: 'intent-success',
        warning: 'intent-warning',
        danger: 'intent-danger'
      },
      size: {
        sm: 'chip-sm',
        md: 'chip-md',
        lg: 'chip-lg'
      },
      radius: {
        none: 'radius-none',
        sm: 'radius-sm',
        lg: 'radius-lg',
        full: 'radius-full'
      }
    },
    defaultVariants: {
      size: 'md',
      intent: 'primary'
    }
  }) as never
});

module('Integration | Component | Chip | @frontile/buttons', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function (assert) {
    await render(hbs`<Chip data-test-id="button">My Chip</Chip>`);

    assert.dom('[data-test-id="button"]').hasText('My Chip');
  });

  module('Style classes', () => {
    module('@appearance', () => {
      test('it adds class for default appearance', async function (assert) {
        await render(hbs`<Chip data-test-id="button">My Chip</Chip>`);

        assert.dom('[data-test-id="button"]').doesNotHaveClass('chip-outlined');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('chip-faded');
        assert.dom('[data-test-id="button"]').hasClass('chip-default');
      });

      test('it adds class for outlined appearance', async function (assert) {
        await render(
          hbs`<Chip @appearance="outlined" data-test-id="button">My Chip</Chip>`
        );

        assert.dom('[data-test-id="button"]').doesNotHaveClass('chip-default');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('chip-faded');
        assert.dom('[data-test-id="button"]').hasClass('chip-outlined');
      });

      test('it adds class for faded appearance', async function (assert) {
        await render(
          hbs`<Chip @appearance="faded" data-test-id="button">My Chip</Chip>`
        );

        assert.dom('[data-test-id="button"]').doesNotHaveClass('chip-default');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('chip-outlined');
        assert.dom('[data-test-id="button"]').hasClass('chip-faded');
      });

      test('it adds class for custom appearance', async function (assert) {
        await render(
          hbs`<Chip @appearance="custom" data-test-id="button">My Chip</Chip>`
        );

        assert.dom('[data-test-id="button"]').doesNotHaveClass('chip-default');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('chip-outlined');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('chip-faded');
      });
    });

    module('@intent', () => {
      test('it adds class for the an intent', async function (assert) {
        await render(
          hbs`<Chip @intent="primary" data-test-id="button">My Chip</Chip>`
        );

        assert.dom('[data-test-id="button"]').hasClass('intent-primary');
      });
    });

    module('@size', () => {
      test('it adds class size sm"', async function (assert) {
        await render(
          hbs`<Chip @size="sm" data-test-id="button">My Chip</Chip>`
        );

        assert.dom('[data-test-id="button"]').hasClass('chip-sm');
      });

      test('it adds class size lg', async function (assert) {
        await render(
          hbs`<Chip @size="lg" data-test-id="button">My Chip</Chip>`
        );

        assert.dom('[data-test-id="button"]').hasClass('chip-lg');
      });
    });

    module('@withDot', () => {
      test('it adds dot when argument is passed in', async function (assert) {
        await render(
          hbs`<Chip @withDot={{true}} data-test-id="button">My Chip</Chip>`
        );

        assert.dom('[data-test-id="button"] .chip-dot').exists();
      });
    });

    module('@onClose', () => {
      test('adds close button when onClose argument is passed in', async function (assert) {
        await render(
          hbs`<Chip @onClose={{true}} data-test-id="button">My Chip</Chip>`
        );

        assert.dom('[data-test-id="button"] .chip-close-button').exists();
      });
    });
  });
});
