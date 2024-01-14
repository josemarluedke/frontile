import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';

module(
  'Integration | Component | ToggleButton | @frontile/buttons',
  function (hooks) {
    setupRenderingTest(hooks);

    registerCustomStyles({
      toggleButton: tv({
        base: 'toggle-button',
        variants: {
          isInGroup: { true: ['in-group'] },
          intent: {
            default: 'intent-default',
            primary: 'intent-primary',
            success: 'intent-success',
            warning: 'intent-warning',
            danger: 'intent-danger'
          },
          size: {
            xs: 'toggle-button-xs',
            sm: 'toggle-button-sm',
            md: 'toggle-button-md',
            lg: 'toggle-button-lg',
            xl: 'toggle-button-xl'
          }
        },
        defaultVariants: {
          size: 'md',
          intent: 'default'
        }
      }) as never
    });

    test('it renders', async function (assert) {
      await render(
        hbs`<ToggleButton data-test-id="button">My ToggleButton</ToggleButton>`
      );

      assert.dom('[data-test-id="button"]').hasText('My ToggleButton');
    });

    module('@isSelected', () => {
      test('adds aria-pressed', async function (assert) {
        this.set('isSelected', false);
        await render(
          hbs`<ToggleButton @isSelected={{this.isSelected}} data-test-id="button">My ToggleButton</ToggleButton>`
        );

        assert.dom('[data-test-id="button"]').hasAria('pressed', 'false');
        this.set('isSelected', true);

        assert.dom('[data-test-id="button"]').hasAria('pressed', 'true');
      });
    });

    module('@onChange', () => {
      test('calls onChange argument', async function (assert) {
        this.set('onChange', (val: boolean) => {
          assert.equal(val, true);
        });
        await render(
          hbs`<ToggleButton @isSelected={{false}} @onChange={{this.onChange}} data-test-id="button">My ToggleButton</ToggleButton>`
        );
        await click('[data-test-id="button"]');

        assert.expect(1);
      });
    });

    module('Style classes', () => {
      module('@intent', () => {
        test('it adds class for the an intent', async function (assert) {
          await render(
            hbs`<ToggleButton @intent="primary" data-test-id="button">My ToggleButton</ToggleButton>`
          );

          assert.dom('[data-test-id="button"]').hasClass('intent-primary');
        });
      });

      module('@size', () => {
        test('it adds class size sm"', async function (assert) {
          await render(
            hbs`<ToggleButton @size="sm" data-test-id="button">My ToggleButton</ToggleButton>`
          );

          assert.dom('[data-test-id="button"]').hasClass('toggle-button-sm');
        });

        test('it adds class size lg', async function (assert) {
          await render(
            hbs`<ToggleButton @size="lg" data-test-id="button">My ToggleButton</ToggleButton>`
          );

          assert.dom('[data-test-id="button"]').hasClass('toggle-button-lg');
        });
      });
    });
  }
);
