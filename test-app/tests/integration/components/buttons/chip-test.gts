import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import { Chip } from '@frontile/buttons';

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
    await render(
      <template>
        <Chip data-test-id="button">My Chip</Chip>
      </template>
    );

    assert.dom('[data-test-id="button"]').hasText('My Chip');
  });

  module('Style classes', () => {
    module('@appearance', () => {
      test('it adds class for default appearance', async function (assert) {
        await render(
          <template>
            <Chip data-test-id="button">My Chip</Chip>
          </template>
        );

        assert.dom('[data-test-id="button"]').doesNotHaveClass('chip-outlined');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('chip-faded');
        assert.dom('[data-test-id="button"]').hasClass('chip-default');
      });

      test('it adds class for outlined appearance', async function (assert) {
        await render(
          <template>
            <Chip @appearance="outlined" data-test-id="button">My Chip</Chip>
          </template>
        );

        assert.dom('[data-test-id="button"]').doesNotHaveClass('chip-default');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('chip-faded');
        assert.dom('[data-test-id="button"]').hasClass('chip-outlined');
      });

      test('it adds class for faded appearance', async function (assert) {
        await render(
          <template>
            <Chip @appearance="faded" data-test-id="button">My Chip</Chip>
          </template>
        );

        assert.dom('[data-test-id="button"]').doesNotHaveClass('chip-default');
        assert.dom('[data-test-id="button"]').doesNotHaveClass('chip-outlined');
        assert.dom('[data-test-id="button"]').hasClass('chip-faded');
      });
    });

    module('@intent', () => {
      test('it adds class for the an intent', async function (assert) {
        await render(
          <template>
            <Chip @intent="primary" data-test-id="button">My Chip</Chip>
          </template>
        );

        assert.dom('[data-test-id="button"]').hasClass('intent-primary');
      });
    });

    module('@size', () => {
      test('it adds class size sm"', async function (assert) {
        await render(
          <template>
            <Chip @size="sm" data-test-id="button">My Chip</Chip>
          </template>
        );

        assert.dom('[data-test-id="button"]').hasClass('chip-sm');
      });

      test('it adds class size lg', async function (assert) {
        await render(
          <template>
            <Chip @size="lg" data-test-id="button">My Chip</Chip>
          </template>
        );

        assert.dom('[data-test-id="button"]').hasClass('chip-lg');
      });
    });

    module('@withDot', () => {
      test('it adds dot when argument is passed in', async function (assert) {
        await render(
          <template>
            <Chip @withDot={{true}} data-test-id="button">My Chip</Chip>
          </template>
        );

        assert.dom('[data-test-id="button"] .chip-dot').exists();
      });
    });

    module('@onClose', () => {
      test('adds close button when onClose argument is passed in', async function (assert) {
        const onClose = () => {};
        await render(
          <template>
            <Chip @onClose={{onClose}} data-test-id="button">My Chip</Chip>
          </template>
        );

        assert.dom('[data-test-id="button"] .chip-close-button').exists();
      });
    });
  });
});
