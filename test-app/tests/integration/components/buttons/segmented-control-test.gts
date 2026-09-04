import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  click,
  find,
  findAll,
  focus,
  triggerKeyEvent
} from '@ember/test-helpers';
import { hash } from '@ember/helper';
import { SegmentedControl } from 'frontile';
import { cell } from 'ember-resources';

module(
  'Integration | Component | SegmentedControl | @frontile/buttons',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders items and reflects the selected value', async function (assert) {
      const value = cell('week');

      await render(
        <template>
          <SegmentedControl @value={{value.current}} as |Ctl|>
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
            <Ctl.Item @value="month">Month</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const items = findAll('[role="radio"]');
      assert.strictEqual(items.length, 3, 'renders one radio per item');
      assert
        .dom(items[1]!)
        .hasAria('checked', 'true', 'the matching item is checked');
      assert.dom(items[0]!).hasAria('checked', 'false');
      assert.dom(items[2]!).hasAria('checked', 'false');
    });

    test('clicking an item calls onChange with that value', async function (assert) {
      const value = cell('day');
      const onChange = (next: string): void => {
        value.current = next;
      };

      await render(
        <template>
          <SegmentedControl
            @value={{value.current}}
            @onChange={{onChange}}
            as |Ctl|
          >
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      await click(findAll('[role="radio"]')[1]!);
      assert.strictEqual(
        value.current,
        'week',
        'onChange received the clicked value'
      );
      assert.dom(findAll('[role="radio"]')[1]!).hasAria('checked', 'true');
    });

    test('the container carries radiogroup semantics', async function (assert) {
      await render(
        <template>
          <SegmentedControl @value="day" aria-label="Range" as |Ctl|>
            <Ctl.Item @value="day">Day</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      assert.dom('[role="radiogroup"]').exists('container is a radiogroup');
      assert.dom('[role="radiogroup"]').hasAria('orientation', 'horizontal');
      assert.dom('[role="radiogroup"]').hasAria('label', 'Range');
    });

    test('arrow keys move selection', async function (assert) {
      const value = cell('day');
      const onChange = (next: string): void => {
        value.current = next;
      };

      await render(
        <template>
          <SegmentedControl
            @value={{value.current}}
            @onChange={{onChange}}
            as |Ctl|
          >
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
            <Ctl.Item @value="month">Month</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const items = findAll('[role="radio"]') as HTMLButtonElement[];
      await focus(items[0]!);
      await triggerKeyEvent(items[0]!, 'keydown', 'ArrowRight');

      assert.strictEqual(value.current, 'week', 'selection follows focus');
      assert.dom(findAll('[role="radio"]')[1]!).hasAria('checked', 'true');
    });

    test('vertical orientation reports itself and uses vertical arrows', async function (assert) {
      const value = cell('day');
      const onChange = (next: string): void => {
        value.current = next;
      };

      await render(
        <template>
          <SegmentedControl
            @value={{value.current}}
            @onChange={{onChange}}
            @orientation="vertical"
            as |Ctl|
          >
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      assert.dom('[role="radiogroup"]').hasAria('orientation', 'vertical');

      const items = findAll('[role="radio"]') as HTMLButtonElement[];
      await focus(items[0]!);
      await triggerKeyEvent(items[0]!, 'keydown', 'ArrowDown');
      assert.strictEqual(value.current, 'week', 'ArrowDown moves selection');
    });

    test('a disabled item is skipped and cannot be clicked', async function (assert) {
      const value = cell('day');
      const onChange = (next: string): void => {
        value.current = next;
      };

      await render(
        <template>
          <SegmentedControl
            @value={{value.current}}
            @onChange={{onChange}}
            as |Ctl|
          >
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week" @isDisabled={{true}}>Week</Ctl.Item>
            <Ctl.Item @value="month">Month</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const items = findAll('[role="radio"]') as HTMLButtonElement[];
      assert.dom(items[1]!).isDisabled('the disabled item is disabled');

      await focus(items[0]!);
      await triggerKeyEvent(items[0]!, 'keydown', 'ArrowRight');
      assert.strictEqual(value.current, 'month', 'arrow navigation skips it');
    });

    test('@isDisabled on the control disables every item', async function (assert) {
      let calls = 0;
      const onChange = (): void => {
        calls += 1;
      };

      await render(
        <template>
          <SegmentedControl
            @value="day"
            @onChange={{onChange}}
            @isDisabled={{true}}
            as |Ctl|
          >
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      assert.dom('[role="radiogroup"]').hasAria('disabled', 'true');
      findAll('[role="radio"]').forEach((item) => {
        assert.dom(item).isDisabled();
      });
      assert.strictEqual(calls, 0, 'nothing was selected');
    });

    test('the indicator tracks the selected item', async function (assert) {
      const value = cell('day');
      const onChange = (next: string): void => {
        value.current = next;
      };

      await render(
        <template>
          <SegmentedControl
            @value={{value.current}}
            @onChange={{onChange}}
            as |Ctl|
          >
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">A much longer label</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const container = find('[role="radiogroup"]') as HTMLElement;
      const items = findAll('[role="radio"]') as HTMLButtonElement[];

      assert.strictEqual(
        container.style.getPropertyValue('--fr-si-width'),
        `${items[0]!.offsetWidth}px`,
        'indicator sized to the first item'
      );

      await click(items[1]!);

      assert.strictEqual(
        container.style.getPropertyValue('--fr-si-width'),
        `${items[1]!.offsetWidth}px`,
        'indicator resized to the newly selected item'
      );
      assert.strictEqual(
        container.style.getPropertyValue('--fr-si-x'),
        `${items[1]!.offsetLeft}px`,
        'indicator moved to the newly selected item'
      );
    });

    test('a value matching no item leaves the indicator hidden', async function (assert) {
      await render(
        <template>
          <SegmentedControl @value="nothing" as |Ctl|>
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const container = find('[role="radiogroup"]') as HTMLElement;
      assert.notOk(
        container.hasAttribute('data-fr-si-ready'),
        'the indicator never became ready'
      );
      findAll('[role="radio"]').forEach((item) => {
        assert.dom(item).hasAria('checked', 'false');
      });
    });

    test('duplicate values select together', async function (assert) {
      // Values are compared with ===, so two items sharing a value are two
      // views of the same choice and both read as checked. Documented rather
      // than defended against: silently de-duplicating would be surprising.
      await render(
        <template>
          <SegmentedControl @value="day" as |Ctl|>
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="day">Also day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const items = findAll('[role="radio"]');
      assert.dom(items[0]!).hasAria('checked', 'true');
      assert.dom(items[1]!).hasAria('checked', 'true');
      assert.dom(items[2]!).hasAria('checked', 'false');
    });

    test('items yield isSelected', async function (assert) {
      await render(
        <template>
          <SegmentedControl @value="week" as |Ctl|>
            <Ctl.Item @value="day" as |item|>
              {{#if item.isSelected}}
                <span data-test-on>Day</span>
              {{else}}
                <span data-test-off>Day</span>
              {{/if}}
            </Ctl.Item>
            <Ctl.Item @value="week" as |item|>
              {{#if item.isSelected}}
                <span data-test-on>Week</span>
              {{else}}
                <span data-test-off>Week</span>
              {{/if}}
            </Ctl.Item>
          </SegmentedControl>
        </template>
      );

      assert
        .dom('[data-test-on]')
        .hasText('Week', 'only the selected item renders its selected branch');
      assert.dom('[data-test-off]').hasText('Day');
    });

    test('class and classes slots merge with the theme', async function (assert) {
      await render(
        <template>
          <SegmentedControl
            @value="day"
            @classes={{hash
              base="custom-base"
              item="custom-item"
              indicator="custom-indicator"
            }}
            as |Ctl|
          >
            <Ctl.Item @value="day" @class="custom-single">Day</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      assert.dom('[role="radiogroup"]').hasClass('custom-base');
      assert.dom('[role="radio"]').hasClass('custom-item');
      assert.dom('[role="radio"]').hasClass('custom-single');
      assert.dom('[aria-hidden="true"]').hasClass('custom-indicator');
    });
  }
);
