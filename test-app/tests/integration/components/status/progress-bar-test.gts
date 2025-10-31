import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import { ProgressBar } from 'frontile';
import { hash } from '@ember/helper';

registerCustomStyles({
  progressBar: tv({
    slots: {
      base: ['pb-base'],
      label: ['pb-label'],
      progress: ['pb-progress'],
      description: ['pb-description']
    },
    variants: {
      isIndeterminate: {
        true: {
          progress: ['pb-is-indeterminate']
        }
      },
      intent: {
        default: 'intent-default',
        primary: 'intent-primary',
        success: 'intent-success',
        warning: 'intent-warning',
        danger: 'intent-danger'
      },
      size: {
        xs: 'size-xs',
        sm: 'size-sm',
        md: 'size-md',
        lg: 'size-lg'
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
      intent: 'default',
      radius: 'sm'
    }
  }) as never
});

module(
  'Integration | Component | ProgressBar | @frontile/status',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders', async function (assert) {
      await render(
        <template><ProgressBar data-test-id="progress-bar" /></template>
      );
      assert.dom('[data-test-id="progress-bar"]').exists();
      assert.dom('[data-test-id="progress-bar"] [role="progressbar"]').exists();
    });

    module('style classes', () => {
      module('intent', () => {
        test('it adds class for the intent', async function (assert) {
          await render(
            <template>
              <ProgressBar @intent="primary" data-test-id="progress-bar" />
            </template>
          );

          assert
            .dom('[data-test-id="progress-bar"] > div.pb-base')
            .hasClass('intent-primary');
        });

        test('it adds class for the default intent', async function (assert) {
          await render(
            <template><ProgressBar data-test-id="progress-bar" /></template>
          );

          assert
            .dom('[data-test-id="progress-bar"] > div.pb-base')
            .hasClass('intent-default');
        });
      });

      module('sizes', () => {
        test('it adds class for default size"', async function (assert) {
          await render(
            <template><ProgressBar data-test-id="progress-bar" /></template>
          );

          assert
            .dom('[data-test-id="progress-bar"] > div.pb-base')
            .hasClass('size-md');
        });

        test('it adds class size xs"', async function (assert) {
          await render(
            <template>
              <ProgressBar @size="xs" data-test-id="progress-bar" />
            </template>
          );

          assert
            .dom('[data-test-id="progress-bar"] > div.pb-base')
            .hasClass('size-xs');
        });

        test('it adds class size lg', async function (assert) {
          await render(
            <template>
              <ProgressBar @size="lg" data-test-id="progress-bar" />
            </template>
          );

          assert
            .dom('[data-test-id="progress-bar"] > div.pb-base ')
            .hasClass('size-lg');
        });
      });

      module('radius', () => {
        test('it adds class default radius size sm"', async function (assert) {
          await render(
            <template><ProgressBar data-test-id="progress-bar" /></template>
          );

          assert
            .dom('[data-test-id="progress-bar"] > div.pb-base')
            .hasClass('radius-sm');
        });

        test('it adds class radius size lg"', async function (assert) {
          await render(
            <template>
              <ProgressBar @radius="lg" data-test-id="progress-bar" />
            </template>
          );

          assert
            .dom('[data-test-id="progress-bar"] > div.pb-base')
            .hasClass('radius-lg');
        });

        test('it adds class radius full', async function (assert) {
          await render(
            <template>
              <ProgressBar @radius="full" data-test-id="progress-bar" />
            </template>
          );

          assert
            .dom('[data-test-id="progress-bar"] > div.pb-base ')
            .hasClass('radius-full');
        });
      });

      module('is-indeterminate', () => {
        test('it adds class for indeterminate state "', async function (assert) {
          await render(
            <template>
              <ProgressBar
                @isIndeterminate={{true}}
                data-test-id="progress-bar"
              />
            </template>
          );

          assert
            .dom(
              '[data-test-id="progress-bar"] > div.pb-base > div.pb-progress'
            )
            .hasClass('pb-is-indeterminate');
        });
      });
    });

    module('progress value', () => {
      test('it renders value and arias', async function (assert) {
        await render(
          <template>
            <ProgressBar data-test-id="progress-bar" @progress={{50}} />
          </template>
        );

        const selector = '[data-test-id="progress-bar"] div.pb-progress';
        const width = document.querySelector(selector)?.getAttribute('style');

        assert.equal(width, 'width: 50%');
        assert.dom(selector).hasAttribute('role');
        assert.dom(selector).hasAria('valuenow', '50');
        assert.dom(selector).hasAria('valuemin', '0');
        assert.dom(selector).hasAria('valuemax', '100');
        assert.dom(selector).hasNoAria('labeledBy');
      });

      test('it interpolates values', async function (assert) {
        await render(
          <template>
            <ProgressBar
              data-test-id="progress-bar"
              @progress={{20}}
              @minValue={{10}}
              @maxValue={{30}}
            />
          </template>
        );

        const selector = '[data-test-id="progress-bar"] div.pb-progress';
        const width = document.querySelector(selector)?.getAttribute('style');

        assert.equal(width, 'width: 50%');
        assert.dom(selector).hasAttribute('role');
        assert.dom(selector).hasAria('valuenow', '20');
        assert.dom(selector).hasAria('valuemin', '10');
        assert.dom(selector).hasAria('valuemax', '30');
      });
    });

    module('progress label', () => {
      test('it renders label and arias', async function (assert) {
        await render(
          <template>
            <ProgressBar
              data-test-id="progress-bar"
              @progress={{50}}
              @label="Progress"
            />
          </template>
        );

        assert
          .dom('[data-test-id="progress-bar"] div.pb-progress')
          .hasAttribute('aria-labelledby');

        assert
          .dom('[data-test-id="progress-bar"] div.pb-label > label')
          .containsText('Progress');
        assert
          .dom('[data-test-id="progress-bar"] div.pb-label > div')
          .containsText('50%');
      });

      test('it renders value label', async function (assert) {
        await render(
          <template>
            <ProgressBar
              data-test-id="progress-bar"
              @progress={{50}}
              @label="Progress"
              @valueLabel="value 2/4"
            />
          </template>
        );
        assert
          .dom('[data-test-id="progress-bar"] div.pb-label > div')
          .containsText('value 2/4');
      });

      test('it formats value label', async function (assert) {
        await render(
          <template>
            <ProgressBar
              data-test-id="progress-bar"
              @progress={{50}}
              @label="Progress"
              @formatOptions={{(hash style="currency" currency="USD")}}
            />
          </template>
        );
        assert
          .dom('[data-test-id="progress-bar"] div.pb-label > div')
          .containsText('$50.00');
      });

      test('it formats value label interpolated', async function (assert) {
        await render(
          <template>
            <ProgressBar
              data-test-id="progress-bar"
              @progress={{20}}
              @label="Progress"
              @minValue={{10}}
              @maxValue={{30}}
              @formatOptions={{(hash style="currency" currency="USD")}}
            />
          </template>
        );
        assert
          .dom('[data-test-id="progress-bar"] div.pb-label > div')
          .containsText('$20.00');
      });

      test('it hides value label if showValueLabel false', async function (assert) {
        await render(
          <template>
            <ProgressBar
              data-test-id="progress-bar"
              @progress={{20}}
              @label="Progress"
              @showValueLabel={{false}}
            />
          </template>
        );
        assert
          .dom('[data-test-id="progress-bar"] div.pb-label > div')
          .doesNotExist();
      });
    });

    module('description', () => {
      test('it renders description text', async function (assert) {
        await render(
          <template>
            <ProgressBar
              data-test-id="progress-bar"
              @description="Progress description"
            />
          </template>
        );

        assert
          .dom('[data-test-id="progress-bar"] div.pb-description')
          .containsText('Progress description');
      });

      test('it does not render description element when not provided', async function (assert) {
        await render(
          <template><ProgressBar data-test-id="progress-bar" /></template>
        );

        assert
          .dom('[data-test-id="progress-bar"] div.pb-description')
          .doesNotExist();
      });

      test('it renders both label and description when both provided', async function (assert) {
        await render(
          <template>
            <ProgressBar
              data-test-id="progress-bar"
              @label="Loading files"
              @description="Please wait while we process your request"
              @progress={{75}}
            />
          </template>
        );

        assert.dom('[data-test-id="progress-bar"] div.pb-label').exists();
        assert
          .dom('[data-test-id="progress-bar"] div.pb-description')
          .containsText('Please wait while we process your request');
      });
    });
  }
);
