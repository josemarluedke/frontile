import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';

module(
  'Integration | Component | ButtonGroup | @frontile/buttons',
  function (hooks) {
    setupRenderingTest(hooks);

    registerCustomStyles({
      button: tv({
        base: [],
        variants: {
          isInGroup: { true: ['in-group'] },
          appearance: {
            default: 'btn-default',
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
        }
      }) as never,
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
        }
      }) as never
    });

    test('it renders', async function (assert) {
      await render(
        hbs`<ButtonGroup data-test-id="group" as |g|>
          <g.Button data-test-id="button">Button</g.Button>
          <g.ToggleButton data-test-id="toggle">Toggle</g.ToggleButton>
        </ButtonGroup>`
      );

      assert.dom('[data-test-id="group"]').exists();
      assert.dom('[data-test-id="button"]').hasClass('in-group');
      assert.dom('[data-test-id="toggle"]').hasClass('in-group');
    });

    module('Style classes', () => {
      module('@appearance', () => {
        test('it adds class for default appearance', async function (assert) {
          this.set('appearance', '');
          await render(
            hbs`<ButtonGroup data-test-id="group" @appearance={{this.appearance}} as |g|>
              <g.Button data-test-id="button">Button</g.Button>
              <g.ToggleButton data-test-id="toggle">Toggle</g.ToggleButton>
            </ButtonGroup>`
          );

          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('btn-outlined');
          assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-minimal');
          assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-custom');
          assert.dom('[data-test-id="button"]').hasClass('btn');
        });

        test('it adds class for outlined appearance', async function (assert) {
          this.set('appearance', 'outlined');
          await render(
            hbs`<ButtonGroup data-test-id="group" @appearance={{this.appearance}} as |g|>
              <g.Button data-test-id="button">Button</g.Button>
              <g.ToggleButton data-test-id="toggle">Toggle</g.ToggleButton>
            </ButtonGroup>`
          );

          assert.dom('[data-test-id="button"]').doesNotHaveClass('btn');
          assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-minimal');
          assert.dom('[data-test-id="button"]').doesNotHaveClass('btn-custom');
          assert.dom('[data-test-id="button"]').hasClass('btn-outlined');
        });
      });

      module('@intent', () => {
        test('it adds class for the an intent', async function (assert) {
          this.set('intent', 'primary');
          await render(
            hbs`<ButtonGroup data-test-id="group" @intent={{this.intent}} as |g|>
              <g.Button data-test-id="button">Button</g.Button>
              <g.ToggleButton data-test-id="toggle">Toggle</g.ToggleButton>
            </ButtonGroup>`
          );
          assert.dom('[data-test-id="button"]').hasClass('intent-primary');
          assert.dom('[data-test-id="toggle"]').hasClass('intent-primary');

          this.set('intent', 'danger');
          assert.dom('[data-test-id="button"]').hasClass('intent-danger');
          assert.dom('[data-test-id="toggle"]').hasClass('intent-danger');
        });
      });

      module('@size', () => {
        test('it adds class for the an intent', async function (assert) {
          this.set('size', 'sm');
          await render(
            hbs`<ButtonGroup data-test-id="group" @size={{this.size}} as |g|>
              <g.Button data-test-id="button">Button</g.Button>
              <g.ToggleButton data-test-id="toggle">Toggle</g.ToggleButton>
            </ButtonGroup>`
          );
          assert.dom('[data-test-id="button"]').hasClass('btn-sm');
          assert.dom('[data-test-id="toggle"]').hasClass('toggle-button-sm');

          this.set('size', 'lg');
          assert.dom('[data-test-id="button"]').hasClass('btn-lg');
          assert.dom('[data-test-id="toggle"]').hasClass('toggle-button-lg');
        });
      });
    });
  }
);
