import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, triggerEvent } from '@ember/test-helpers';
import { registerCustomStyles, tv } from '@frontile/theme';
import { Button } from '@frontile/buttons';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';

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

    module('Press functionality', () => {
      test('it handles onPress callback', async function (assert) {
        let pressEventCount = 0;

        class TestComponent extends Component {
          handlePress = () => {
            pressEventCount++;
          };

          <template>
            <Button @onPress={{this.handlePress}} data-test-id="button">
              Press me
            </Button>
          </template>
        }

        await render(<template><TestComponent /></template>);

        await triggerEvent('[data-test-id="button"]', 'pointerdown');
        await triggerEvent('[data-test-id="button"]', 'pointerup');

        assert.strictEqual(
          pressEventCount,
          1,
          'onPress callback was called once'
        );
      });

      test('it sets data-pressed attribute when pressed', async function (assert) {
        await render(
          <template>
            <Button data-test-id="button">Press me</Button>
          </template>
        );

        assert
          .dom('[data-test-id="button"]')
          .doesNotHaveAttribute('data-pressed');

        await triggerEvent('[data-test-id="button"]', 'pointerdown');
        assert
          .dom('[data-test-id="button"]')
          .hasAttribute('data-pressed', 'true');

        await triggerEvent('[data-test-id="button"]', 'pointerup');
        assert
          .dom('[data-test-id="button"]')
          .doesNotHaveAttribute('data-pressed');
      });

      test('it works with renderless mode', async function (assert) {
        let pressEventCount = 0;

        class TestComponent extends Component {
          handlePress = () => {
            pressEventCount++;
          };

          <template>
            <Button
              @isRenderless={{true}}
              @onPress={{this.handlePress}}
              as |btn|
            >
              <div data-test-id="custom-button" class={{btn.classNames}}>
                Custom Button
              </div>
            </Button>
          </template>
        }

        await render(<template><TestComponent /></template>);

        // Renderless mode should not handle press events on its own
        await triggerEvent('[data-test-id="custom-button"]', 'pointerdown');
        await triggerEvent('[data-test-id="custom-button"]', 'pointerup');

        assert.strictEqual(
          pressEventCount,
          0,
          'onPress should not be called in renderless mode'
        );
      });
    });
  }
);
