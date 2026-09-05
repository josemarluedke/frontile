import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  click,
  find,
  findAll,
  focus,
  settled,
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
      let calls = 0;
      const onChange = (next: string): void => {
        calls += 1;
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

      // `click`/`triggerEvent` refuse disabled elements outright, so dispatch
      // the event directly: this asserts the item's own guard rather than only
      // the browser's, and keeps holding once the item moves to aria-disabled.
      items[1]!.dispatchEvent(new MouseEvent('click', { bubbles: true }));
      await settled();
      assert.strictEqual(calls, 0, 'clicking the disabled item calls nothing');
      assert.strictEqual(value.current, 'day', 'the selection did not change');
      assert.dom(findAll('[role="radio"]')[1]!).hasAria('checked', 'false');

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

      const items = findAll('[role="radio"]') as HTMLButtonElement[];

      items[1]!.dispatchEvent(new MouseEvent('click', { bubbles: true }));
      await settled();
      assert.strictEqual(calls, 0, 'clicking an item selects nothing');

      items[0]!.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true })
      );
      await settled();
      assert.strictEqual(calls, 0, 'keyboard activation selects nothing');

      assert.dom(items[0]!).hasAria('checked', 'true', 'selection unchanged');
      assert.dom(items[1]!).hasAria('checked', 'false');
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

    test('exactly one item is tabbable, and it is the selected one', async function (assert) {
      await render(
        <template>
          <SegmentedControl @value="week" as |Ctl|>
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
            <Ctl.Item @value="month">Month</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const items = findAll('[role="radio"]') as HTMLButtonElement[];
      const tabbable = items.filter((item) => item.tabIndex === 0);

      assert.strictEqual(tabbable.length, 1, 'a single tab stop');
      assert.strictEqual(
        tabbable[0],
        items[1],
        'the tab stop is the selected item'
      );
      assert.strictEqual(items[0]!.tabIndex, -1);
      assert.strictEqual(items[2]!.tabIndex, -1);
    });

    test('the indicator stays ready while selection moves in either direction', async function (assert) {
      // Regression: the outgoing item's modifier teardown used to re-measure
      // synchronously, stripping data-fr-si-ready before the incoming item
      // could claim the target. The theme gates opacity *and* the transition
      // on that attribute, so the indicator blinked out and jumped instead of
      // sliding -- and only when moving to a later item, because that is the
      // order in which Glimmer runs teardown before setup.
      //
      // The flicker is transient: by the time the render settles the attribute
      // is back, so an end-state assertion cannot see it. Watch the attribute
      // for the duration of the interaction instead.
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

      const container = find('[role="radiogroup"]') as HTMLElement;
      const items = findAll('[role="radio"]') as HTMLButtonElement[];

      assert.ok(
        container.hasAttribute('data-fr-si-ready'),
        'ready after the first measurement'
      );

      // The observer's own callback is what drains the record queue, so
      // accumulate there rather than relying on takeRecords().
      let flickers: MutationRecord[] = [];
      const observer = new MutationObserver((records) => {
        flickers.push(...records);
      });
      observer.observe(container, {
        attributes: true,
        attributeFilter: ['data-fr-si-ready']
      });

      try {
        // Forwards: teardown of the outgoing item runs before setup of the
        // incoming one. This is the direction that used to break.
        await click(items[2]!);

        flickers.push(...observer.takeRecords());
        assert.strictEqual(
          flickers.length,
          0,
          'data-fr-si-ready never flickered while selecting a later item'
        );
        flickers = [];
        assert.ok(
          container.hasAttribute('data-fr-si-ready'),
          'still ready after selecting a later item'
        );
        assert.strictEqual(
          container.style.getPropertyValue('--fr-si-x'),
          `${items[2]!.offsetLeft}px`,
          'indicator moved to the later item'
        );

        // Backwards: setup of the incoming item runs first.
        await click(items[0]!);

        flickers.push(...observer.takeRecords());
        assert.strictEqual(
          flickers.length,
          0,
          'data-fr-si-ready never flickered while selecting an earlier item'
        );
        assert.ok(
          container.hasAttribute('data-fr-si-ready'),
          'still ready after selecting an earlier item'
        );
        assert.strictEqual(
          container.style.getPropertyValue('--fr-si-x'),
          `${items[0]!.offsetLeft}px`,
          'indicator moved back to the earlier item'
        );
      } finally {
        observer.disconnect();
      }
    });

    test('@name renders native radio inputs that submit with the form', async function (assert) {
      const value = cell('day');
      const onChange = (next: string): void => {
        value.current = next;
      };

      await render(
        <template>
          <form data-test-form>
            <SegmentedControl
              @value={{value.current}}
              @onChange={{onChange}}
              @name="range"
              as |Ctl|
            >
              <Ctl.Item @value="day">Day</Ctl.Item>
              <Ctl.Item @value="week">Week</Ctl.Item>
            </SegmentedControl>
          </form>
        </template>
      );

      const inputs = findAll('input[type="radio"]') as HTMLInputElement[];
      assert.strictEqual(inputs.length, 2, 'renders one native radio per item');
      assert.dom(inputs[0]!).hasAttribute('name', 'range');
      assert.true(inputs[0]!.checked, 'the matching input is checked');
      assert.false(inputs[1]!.checked);

      assert
        .dom('[role="radio"]')
        .doesNotExist(
          'form mode leans on native radio semantics rather than adding its own'
        );

      const formEl = find('[data-test-form]') as HTMLFormElement;
      assert.strictEqual(
        new FormData(formEl).get('range'),
        'day',
        'the control submits its value'
      );

      await click(inputs[1]!);
      assert.strictEqual(value.current, 'week', 'onChange still fires');
      assert.strictEqual(
        new FormData(formEl).get('range'),
        'week',
        'the submitted value follows the selection'
      );
    });

    test('form mode keeps the typed value in onChange', async function (assert) {
      const received: unknown[] = [];
      const onChange = (next: number): void => {
        received.push(next);
      };

      await render(
        <template>
          <SegmentedControl
            @value={{1}}
            @onChange={{onChange}}
            @name="n"
            as |Ctl|
          >
            <Ctl.Item @value={{1}}>One</Ctl.Item>
            <Ctl.Item @value={{2}}>Two</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const inputs = findAll('input[type="radio"]') as HTMLInputElement[];
      assert.dom(inputs[1]!).hasValue('2', 'the input value is stringified');

      await click(inputs[1]!);
      assert.deepEqual(received, [2], 'onChange receives the original number');
    });

    test('form mode draws its focus ring on the label', async function (assert) {
      // The radio input is `sr-only`, so focusing it shows nothing unless the
      // wrapping label carries the ring. This is the whole reason the theme has
      // a `mode` variant.
      await render(
        <template>
          <SegmentedControl @value="day" @name="range" as |Ctl|>
            <Ctl.Item @value="day">Day</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const label = find('label') as HTMLLabelElement;
      assert.ok(
        Array.from(label.classList).some((c) =>
          c.includes('has-focus-visible')
        ),
        'the label carries the focus-visible-within ring, not the hidden input'
      );
    });

    test('form mode still tracks the indicator', async function (assert) {
      const value = cell('day');
      const onChange = (next: string): void => {
        value.current = next;
      };

      await render(
        <template>
          <SegmentedControl
            @value={{value.current}}
            @onChange={{onChange}}
            @name="range"
            as |Ctl|
          >
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">A much longer label</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const container = find('[role="radiogroup"]') as HTMLElement;
      const labels = findAll('label') as HTMLLabelElement[];

      await click(findAll('input[type="radio"]')[1]!);

      assert.strictEqual(
        container.style.getPropertyValue('--fr-si-width'),
        `${labels[1]!.offsetWidth}px`,
        'the indicator measures the label, not the hidden input'
      );
    });
  }
);
