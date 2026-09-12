import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { DatePicker } from 'frontile';

const jan20 = new Date(2026, 0, 20);

module(
  'Integration | Component | DatePicker | frontile/forms',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders the field with a label and a placeholder', async function (assert) {
      await render(
        <template>
          <DatePicker @label="Start date" @placeholder="Pick a date" />
        </template>
      );

      assert
        .dom('[data-component="date-picker"]')
        .exists('the root carries the anatomy attribute');
      assert.dom('label').hasText('Start date');

      const trigger = '[data-component="date-picker"] [data-part="input"]';
      assert.dom(trigger).hasTagName('button');
      assert.dom(trigger).hasAttribute('type', 'button');
      assert.dom(trigger).hasText('Pick a date');
      assert
        .dom('[data-part="placeholder"]')
        .exists('placeholder is its own part');
    });

    test('it renders a formatted value in place of the placeholder', async function (assert) {
      await render(
        <template>
          <DatePicker
            @label="Start date"
            @placeholder="Pick a date"
            @value={{jan20}}
            @locale="en-US"
          />
        </template>
      );

      assert.dom('[data-part="input"]').hasText('Jan 20, 2026');
      assert.dom('[data-part="placeholder"]').doesNotExist();
    });

    test('it accepts a yyyy-MM-dd string value', async function (assert) {
      await render(
        <template>
          <DatePicker @label="Start" @value="2026-01-20" @locale="en-US" />
        </template>
      );

      assert.dom('[data-part="input"]').hasText('Jan 20, 2026');
    });

    test('it honours formatOptions', async function (assert) {
      const full = { dateStyle: 'full' as const };

      await render(
        <template>
          <DatePicker
            @label="Start"
            @value={{jan20}}
            @locale="en-US"
            @formatOptions={{full}}
          />
        </template>
      );

      assert.dom('[data-part="input"]').hasText('Tuesday, January 20, 2026');
    });

    test('it reflects disabled and invalid state on the trigger', async function (assert) {
      const errors = ['Required'];

      await render(
        <template>
          <DatePicker @label="Start" @isDisabled={{true}} @errors={{errors}} />
        </template>
      );

      assert.dom('[data-part="input"]').isDisabled();
      assert.dom('[data-part="input"]').hasAttribute('data-invalid', 'true');
      assert.dom('[data-part="input"]').hasAttribute('data-disabled', 'true');
    });
  }
);
