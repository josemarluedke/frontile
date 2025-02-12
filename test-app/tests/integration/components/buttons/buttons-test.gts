import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { registerCustomStyles, tv } from '@frontile/theme';
import { Button } from '@frontile/buttons';

registerCustomStyles({
  button: tv({
    base: [],
    variants: {
      isInGroup: { true: ['in-group'] },
      appearance: {
        default: 'btn',
        outlined: 'btn-outlined',
        minimal: 'btn-minimal',
        custom: 'btn-custom'
      },
      intent: {
        default: 'intent-default',
        primary: 'intent-primary',
        success: 'intent-success',
        warning: 'intent-warning',
        danger: 'intent-danger'
      },
      size: {
        xs: 'btn-xs',
        sm: 'btn-sm',
        md: 'btn-md',
        lg: 'btn-lg',
        xl: 'btn-xl'
      }
    },
    defaultVariants: {
      size: 'md',
      intent: 'primary'
    }
  }) as never
});

module(
  'Integration | Component | Button | @frontile/buttons',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders', async function (assert) {
      await render(
        <template>
          <Button data-test-id="button">My Button</Button>
        </template>
      );

      assert.dom('[data-test-id="button"]').hasText('My Button');
      assert.dom('[data-test-id="button"]').hasAttribute('type', 'button');
    });

    test('it accepts @type argument', async function (assert) {
      await render(
        <template>
          <Button @type="submit" data-test-id="button">My Button</Button>
        </template>
      );

      assert.dom('[data-test-id="button"]').hasAttribute('type', 'submit');
    });

    module('Style classes', () => {
      module('@appearance', () => {
        test('it adds class for default appearance', async function (assert) {
          await render(
            <template>
              <Button data-test-id="button">My Button</Button>
            </template>
          );

          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('btn-outlined');
          assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-minimal');
          assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-custom');
          assert.dom('[data-test-id="button"]').hasClass('btn');
        });

        test('it adds class for outlined appearance', async function (assert) {
          await render(
            <template>
              <Button @appearance="outlined" data-test-id="button">My Button</Button>
            </template>
          );

          assert.dom('[data-test-id="button"]').doesNotHaveClass('btn');
          assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-minimal');
          assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-custom');
          assert.dom('[data-test-id="button"]').hasClass('btn-outlined');
        });

        test('it adds class for minimal appearance', async function (assert) {
          await render(
            <template>
              <Button @appearance="minimal" data-test-id="button">My Button</Button>
            </template>
          );

          assert.dom('[data-test-id="button"]').doesNotHaveClass('btn');
          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('btn-outlined');
          assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-custom');
          assert.dom('[data-test-id="button"]').hasClass('btn-minimal');
        });

        test('it adds class for custom appearance', async function (assert) {
          await render(
            <template>
              <Button @appearance="custom" data-test-id="button">My Button</Button>
            </template>
          );

          assert.dom('[data-test-id="button"]').doesNotHaveClass('btn');
          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('btn-outlined');
          assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-minimal');
          assert.dom('[data-test-id="button"]').hasClass('btn-custom');
        });
      });

      module('@intent', () => {
        test('it adds class for the an intent', async function (assert) {
          await render(
            <template>
              <Button @intent="primary" data-test-id="button">My Button</Button>
            </template>
          );

          assert.dom('[data-test-id="button"]').hasClass('intent-primary');
        });
      });

      module('sizes', () => {
        test('it adds class size xs"', async function (assert) {
          await render(
            <template>
              <Button @size="xs" data-test-id="button">My Button</Button>
            </template>
          );

          assert.dom('[data-test-id="button"]').hasClass('btn-xs');
        });

        test('it adds class size xl', async function (assert) {
          await render(
            <template>
              <Button @size="xl" data-test-id="button">My Button</Button>
            </template>
          );

          assert.dom('[data-test-id="button"]').hasClass('btn-xl');
        });
      });
    });

    test('it yields classNames when renderless', async function (assert) {
      await render(
        <template>
          <Button @isRenderless={{true}} as |btn|>
            <div data-test-id="my-div">{{btn.classNames}}</div>
          </Button>
        </template>
      );
      assert
        .dom('[data-test-id="my-div"]')
        .hasText('btn intent-default btn-md');
    });
  }
);
