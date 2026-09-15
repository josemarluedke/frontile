import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import { ButtonGroup } from 'frontile';
import { cell } from 'ember-resources';
import { settled } from '@ember/test-helpers';
import { trackDeprecations } from '../../../helpers/deprecations';
import { deprecate } from '@ember/debug';

module(
  'Integration | Component | ButtonGroup | @frontile/buttons',
  function (hooks) {
    setupRenderingTest(hooks);

    registerCustomStyles({
      button: tv({
        base: [],
        variants: {
          isInGroup: { true: ['in-group'] },
          variant: {
            solid: 'button-solid',
            soft: 'button-soft',
            subtle: 'button-subtle',
            outline: 'button-outline',
            ghost: 'button-ghost',
            plain: 'button-plain',
            custom: 'button-custom'
          },
          color: {
            neutral: 'button-neutral',
            primary: 'button-primary',
            secondary: 'button-secondary',
            tertiary: 'button-tertiary',
            success: 'button-success',
            warning: 'button-warning',
            danger: 'button-danger'
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
          color: {
            neutral: 'button-neutral',
            primary: 'button-primary',
            secondary: 'button-secondary',
            tertiary: 'button-tertiary',
            success: 'button-success',
            warning: 'button-warning',
            danger: 'button-danger'
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
        <template>
          <ButtonGroup data-test-id="group" as |g|>
            <g.Button data-test-id="button">Button</g.Button>
            <g.ToggleButton data-test-id="toggle">Toggle</g.ToggleButton>
          </ButtonGroup>
        </template>
      );

      assert.dom('[data-test-id="group"]').exists();
      assert.dom('[data-test-id="button"]').hasClass('in-group');
      assert.dom('[data-test-id="toggle"]').hasClass('in-group');
    });

    module('Style classes', () => {
      module('@variant', () => {
        test('it adds class for default variant', async function (assert) {
          await render(
            <template>
              <ButtonGroup data-test-id="group" as |g|>
                <g.Button data-test-id="button">Button</g.Button>
                <g.ToggleButton data-test-id="toggle">Toggle</g.ToggleButton>
              </ButtonGroup>
            </template>
          );

          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-outline');
          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-plain');
          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-custom');
          assert.dom('[data-test-id="button"]').hasClass('button-solid');
        });

        test('it adds class for outline variant', async function (assert) {
          const variant = cell<'outline'>('outline');
          await render(
            <template>
              <ButtonGroup
                data-test-id="group"
                @variant={{variant.current}}
                as |g|
              >
                <g.Button data-test-id="button">Button</g.Button>
                <g.ToggleButton data-test-id="toggle">Toggle</g.ToggleButton>
              </ButtonGroup>
            </template>
          );

          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-solid');
          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-plain');
          assert
            .dom('[data-test-id="button"]')
            .doesNotHaveClass('button-custom');
          assert.dom('[data-test-id="button"]').hasClass('button-outline');
        });

        test('ButtonGroup forwards @variant to its buttons', async function (assert) {
          await render(
            <template>
              <ButtonGroup @variant="outline" as |g|>
                <g.Button data-test-id="button">x</g.Button>
              </ButtonGroup>
            </template>
          );

          assert.dom('[data-test-id="button"]').hasClass('button-outline');
        });

        test('DIAGNOSTIC 1: bare synthetic deprecate() reaches its own handler', function (assert) {
          const { ids } = trackDeprecations();

          deprecate('diagnostic synthetic', false, {
            id: 'diagnostic.synthetic-inline',
            until: '1.0.0',
            for: 'diagnostic',
            since: { available: '1.0.0', enabled: '1.0.0' }
          });

          assert.deepEqual(
            ids,
            ['diagnostic.synthetic-inline'],
            `DIAGNOSTIC 1 saw: ${JSON.stringify(ids)}; userAgent=${navigator.userAgent}`
          );
        });

        test('DIAGNOSTIC 2: same shape as the real appearance test, duplicated', async function (assert) {
          const { ids } = trackDeprecations();

          await render(
            <template>
              <ButtonGroup @appearance="outlined" as |g|>
                <g.Button data-test-id="button">x</g.Button>
              </ButtonGroup>
            </template>
          );

          assert.deepEqual(
            ids,
            ['frontile.button-group.appearance'],
            `DIAGNOSTIC 2 saw: ${JSON.stringify(ids)}`
          );
        });

        test('ButtonGroup @appearance deprecates exactly once', async function (assert) {
          const { ids } = trackDeprecations();

          await render(
            <template>
              <ButtonGroup @appearance="outlined" as |g|>
                <g.Button data-test-id="button">x</g.Button>
              </ButtonGroup>
            </template>
          );

          assert.dom('[data-test-id="button"]').hasClass('button-outline');
          assert.deepEqual(
            ids,
            ['frontile.button-group.appearance'],
            `real test saw: ${JSON.stringify(ids)}`
          );
        });
      });

      module('@color', () => {
        test('it adds class for the a color', async function (assert) {
          const color = cell<'primary' | 'danger'>('primary');
          await render(
            <template>
              <ButtonGroup data-test-id="group" @color={{color.current}} as |g|>
                <g.Button data-test-id="button">Button</g.Button>
                <g.ToggleButton data-test-id="toggle">Toggle</g.ToggleButton>
              </ButtonGroup>
            </template>
          );
          assert.dom('[data-test-id="button"]').hasClass('button-primary');
          assert.dom('[data-test-id="toggle"]').hasClass('button-primary');

          color.current = 'danger';
          await settled();
          assert.dom('[data-test-id="button"]').hasClass('button-danger');
          assert.dom('[data-test-id="toggle"]').hasClass('button-danger');
        });

        test('ButtonGroup @intent deprecates exactly once', async function (assert) {
          const { ids } = trackDeprecations();

          await render(
            <template>
              <ButtonGroup @intent="danger" as |g|>
                <g.Button data-test-id="button">x</g.Button>
                <g.ToggleButton data-test-id="toggle">x</g.ToggleButton>
              </ButtonGroup>
            </template>
          );

          assert.dom('[data-test-id="button"]').hasClass('button-danger');
          assert.dom('[data-test-id="toggle"]').hasClass('button-danger');
          assert.deepEqual(ids, ['frontile.button-group.intent']);
        });
      });

      module('@size', () => {
        test('it adds class for the an intent', async function (assert) {
          const size = cell<'sm' | 'lg'>('sm');
          await render(
            <template>
              <ButtonGroup data-test-id="group" @size={{size.current}} as |g|>
                <g.Button data-test-id="button">Button</g.Button>
                <g.ToggleButton data-test-id="toggle">Toggle</g.ToggleButton>
              </ButtonGroup>
            </template>
          );
          assert.dom('[data-test-id="button"]').hasClass('btn-sm');
          assert.dom('[data-test-id="toggle"]').hasClass('toggle-button-sm');

          size.current = 'lg';
          await settled();
          assert.dom('[data-test-id="button"]').hasClass('btn-lg');
          assert.dom('[data-test-id="toggle"]').hasClass('toggle-button-lg');
        });
      });
    });
  }
);
