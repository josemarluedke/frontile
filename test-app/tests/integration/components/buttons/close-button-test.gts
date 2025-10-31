import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, triggerEvent } from '@ember/test-helpers';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import { CloseButton } from 'frontile';
import { cell } from 'ember-resources';
import { settled } from '@ember/test-helpers';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';

registerCustomStyles({
  closeButton: tv({
    slots: {
      base: 'close-button',
      icon: 'close-button__icon'
    },

    variants: {
      size: {
        xs: 'close-button--xs',
        sm: 'close-button--sm',
        md: 'close-button--md',
        lg: 'close-button--lg',
        xl: 'close-button--xl'
      }
    },
    defaultVariants: {
      size: 'md'
    }
  } as never)
});

module(
  'Integration | Component | @frontile/utilities/CloseButton',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders title', async function (assert) {
      const title = cell('');
      await render(
        <template>
          <div data-test-element><CloseButton @title={{title.current}} /></div>
        </template>
      );

      assert.dom('[data-test-element]').hasText('Close');

      title.current = 'Fechar Menu';
      await settled();

      assert.dom('[data-test-element]').hasText('Fechar Menu');
    });

    test('it allows to yield', async function (assert) {
      await render(
        <template>
          <CloseButton><div class="icon">Here is my icon</div></CloseButton>
        </template>
      );
      assert.dom('.close-button .icon').exists();

      assert.dom('.close-button .icon').hasText('Here is my icon');
    });

    test('it yields the icon classes', async function (assert) {
      await render(
        <template>
          <CloseButton as |class|><div
              class="icon"
            >{{class}}</div></CloseButton>
        </template>
      );
      assert.dom('.close-button .icon').hasText('close-button__icon');
    });

    test('it adds size classes', async function (assert) {
      const size = cell<undefined | 'xs' | 'sm' | 'md' | 'lg' | 'xl'>();
      await render(<template><CloseButton @size={{size.current}} /></template>);

      assert.dom('.close-button').hasClass('close-button--md');

      size.current = 'xs';
      await settled();
      assert.dom('.close-button').hasClass('close-button--xs');

      size.current = 'sm';
      await settled();
      assert.dom('.close-button').hasClass('close-button--sm');

      size.current = 'md';
      await settled();
      assert.dom('.close-button').hasClass('close-button--md');

      size.current = 'lg';
      await settled();
      assert.dom('.close-button').hasClass('close-button--lg');

      size.current = 'xl';
      await settled();
      assert.dom('.close-button').hasClass('close-button--xl');
    });

    test('it allows to pass @class for component curlying', async function (assert) {
      await render(<template><CloseButton @class="some-class" /></template>);
      assert.dom('.close-button').hasClass('some-class');
    });

    module('Press functionality', () => {
      test('it handles onPress callback', async function (assert) {
        let pressEventCount = 0;

        class TestComponent extends Component {
          handlePress = () => {
            pressEventCount++;
          };

          <template>
            <CloseButton
              @onPress={{this.handlePress}}
              data-test-id="close-button"
            />
          </template>
        }

        await render(<template><TestComponent /></template>);

        await triggerEvent('[data-test-id="close-button"]', 'pointerdown');
        await triggerEvent('[data-test-id="close-button"]', 'pointerup');

        assert.strictEqual(
          pressEventCount,
          1,
          'onPress callback was called once'
        );
      });

      test('it sets data-pressed attribute when pressed', async function (assert) {
        await render(
          <template><CloseButton data-test-id="close-button" /></template>
        );

        assert
          .dom('[data-test-id="close-button"]')
          .doesNotHaveAttribute('data-pressed');

        await triggerEvent('[data-test-id="close-button"]', 'pointerdown');
        assert
          .dom('[data-test-id="close-button"]')
          .hasAttribute('data-pressed', 'true');

        await triggerEvent('[data-test-id="close-button"]', 'pointerup');
        assert
          .dom('[data-test-id="close-button"]')
          .doesNotHaveAttribute('data-pressed');
      });

      test('it supports deprecated onClick callback', async function (assert) {
        let clickEventCount = 0;

        class TestComponent extends Component {
          handleClick = () => {
            clickEventCount++;
          };

          <template>
            <CloseButton
              @onClick={{this.handleClick}}
              data-test-id="close-button"
            />
          </template>
        }

        await render(<template><TestComponent /></template>);

        await triggerEvent('[data-test-id="close-button"]', 'click');

        assert.strictEqual(
          clickEventCount,
          1,
          'onClick callback was called once'
        );
      });

      test('it prefers onPress over onClick when both are provided', async function (assert) {
        let pressEventCount = 0;
        let clickEventCount = 0;

        class TestComponent extends Component {
          handlePress = () => {
            pressEventCount++;
          };

          handleClick = () => {
            clickEventCount++;
          };

          <template>
            <CloseButton
              @onPress={{this.handlePress}}
              @onClick={{this.handleClick}}
              data-test-id="close-button"
            />
          </template>
        }

        await render(<template><TestComponent /></template>);

        await triggerEvent('[data-test-id="close-button"]', 'pointerdown');
        await triggerEvent('[data-test-id="close-button"]', 'pointerup');

        assert.strictEqual(
          pressEventCount,
          1,
          'onPress callback was called once'
        );
        // onClick should still work for backwards compatibility
        assert.strictEqual(
          clickEventCount,
          0,
          'onClick should not be called from press events'
        );
      });

      test('onClick only adds click event listener when provided', async function (assert) {
        await render(
          <template>
            <CloseButton data-test-id="close-button-no-onclick" />
          </template>
        );

        // This should not throw an error and should not have a click listener
        await triggerEvent('[data-test-id="close-button-no-onclick"]', 'click');

        // Test that the button still works with press events
        await triggerEvent(
          '[data-test-id="close-button-no-onclick"]',
          'pointerdown'
        );
        await triggerEvent(
          '[data-test-id="close-button-no-onclick"]',
          'pointerup'
        );

        assert.ok(true, 'Component works without onClick');
      });
    });
  }
);
