import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  findAll,
  find,
  click,
  settled,
  focus,
  triggerKeyEvent
} from '@ember/test-helpers';
import { cell } from 'ember-resources';
import { Calendar } from 'frontile';

const sep2026 = new Date(2026, 8, 1);

module(
  'Integration | Component | Calendar | frontile/collections',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders a month as an accessible grid', async function (assert) {
      await render(
        <template>
          <Calendar @defaultMonth={{sep2026}} @locale="en-US" />
        </template>
      );

      assert.dom('[data-fr-calendar]').exists('renders the root');

      const grid = find('[data-fr-calendar-grid]');
      assert.dom(grid).hasTagName('table');
      assert.dom(grid).hasAttribute('role', 'grid');

      assert.dom('[data-fr-calendar-title]').hasText('September 2026');

      const weekdays = findAll('[data-fr-calendar-weekday]');
      assert.strictEqual(weekdays.length, 7, 'seven weekday headers');
      assert.dom(weekdays[0]!).hasText('Sun', 'en-US starts on Sunday');
      assert.dom(weekdays[0]!).hasAttribute('scope', 'col');

      const days = findAll('[data-fr-calendar-day]');
      assert.strictEqual(days.length, 35, 'September 2026 fills five rows');
      assert.dom(days[0]!).hasTagName('button');
      assert.dom(days[0]!).hasAttribute('type', 'button');
      assert.dom(days[0]!).hasAttribute('data-key', '2026-08-30');
      assert.dom(days[0]!).hasAttribute('data-outside', 'true');
      assert.dom(days[2]!).hasAttribute('data-key', '2026-09-01');
      assert.dom(days[2]!).hasAttribute('data-outside', 'false');
      assert.dom(days[2]!).hasText('1', 'the day number renders');
      assert.dom(days[9]!).hasText('8');
    });

    test('a supplied <:day> block overrides the default day content', async function (assert) {
      await render(
        <template>
          <Calendar @defaultMonth={{sep2026}} @locale="en-US">
            <:day as |day|>
              <span data-test-custom-day>Day
                {{day.dayOfMonth}}!</span>
            </:day>
          </Calendar>
        </template>
      );

      const days = findAll('[data-fr-calendar-day]');
      assert
        .dom(days[2]!.querySelector('[data-fr-calendar-day-content]'))
        .doesNotExist('default day-number content is not also rendered');
      assert
        .dom(days[2]!.querySelector('[data-test-custom-day]'))
        .hasText('Day 1!', 'the supplied block content renders instead');
    });

    test('@weekStartsOn overrides the locale', async function (assert) {
      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @weekStartsOn={{1}}
          />
        </template>
      );

      assert.dom(findAll('[data-fr-calendar-weekday]')[0]!).hasText('Mon');
      assert
        .dom(findAll('[data-fr-calendar-day]')[0]!)
        .hasAttribute('data-key', '2026-08-31');
    });

    test('@locale localizes the caption and weekday labels', async function (assert) {
      await render(
        <template>
          <Calendar @defaultMonth={{sep2026}} @locale="nl-NL" />
        </template>
      );

      assert.dom('[data-fr-calendar-title]').hasText('september 2026');
      assert
        .dom(findAll('[data-fr-calendar-weekday]')[0]!)
        .hasText('ma', 'nl-NL starts on Monday');
    });

    test('@showOutsideDays={{false}} blanks the padding cells but keeps alignment', async function (assert) {
      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @showOutsideDays={{false}}
          />
        </template>
      );

      const cells = findAll('[data-fr-calendar-cell]');
      assert.strictEqual(cells.length, 35, 'every grid position still exists');
      assert.strictEqual(
        findAll('[data-fr-calendar-day]').length,
        30,
        'only September days render a button'
      );
    });

    test('@fixedWeeks always renders six rows', async function (assert) {
      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @fixedWeeks={{true}}
          />
        </template>
      );

      assert.strictEqual(findAll('[data-fr-calendar-week]').length, 6);
    });

    test('today is marked with aria-current', async function (assert) {
      await render(<template><Calendar @locale="en-US" /></template>);

      assert
        .dom('[data-fr-calendar-day][data-today="true"]')
        .hasAria('current', 'date', 'exactly one day is today');
    });

    test('it navigates months when uncontrolled', async function (assert) {
      await render(
        <template>
          <Calendar @defaultMonth={{sep2026}} @locale="en-US" />
        </template>
      );

      assert.dom('[data-fr-calendar-title]').hasText('September 2026');

      await click('[data-fr-calendar-next]');
      assert.dom('[data-fr-calendar-title]').hasText('October 2026');

      await click('[data-fr-calendar-prev]');
      await click('[data-fr-calendar-prev]');
      assert.dom('[data-fr-calendar-title]').hasText('August 2026');
    });

    test('@month makes the visible month controlled', async function (assert) {
      const month = cell(sep2026);
      const seen: Date[] = [];
      const onMonthChange = (m: Date) => seen.push(m);

      await render(
        <template>
          <Calendar
            @month={{month.current}}
            @onMonthChange={{onMonthChange}}
            @locale="en-US"
          />
        </template>
      );

      await click('[data-fr-calendar-next]');

      assert
        .dom('[data-fr-calendar-title]')
        .hasText('September 2026', 'controlled mode does not move on its own');
      assert.strictEqual(seen.length, 1, 'it reports the requested month');
      assert.strictEqual(seen[0]!.getMonth(), 9, 'October');

      month.current = new Date(2026, 9, 1);
      await settled();
      assert.dom('[data-fr-calendar-title]').hasText('October 2026');
    });

    test('month changes are announced politely', async function (assert) {
      await render(
        <template>
          <Calendar @defaultMonth={{sep2026}} @locale="en-US" />
        </template>
      );

      const live = find('[data-fr-calendar-live]');
      assert.dom(live).hasAttribute('aria-live', 'polite');
      assert.dom(live).hasText('September 2026');

      await click('[data-fr-calendar-next]');
      assert.dom('[data-fr-calendar-live]').hasText('October 2026');
    });

    test('the initial month falls back to the month of the value', async function (assert) {
      const value = new Date(2027, 2, 15);

      await render(
        <template>
          <Calendar @defaultValue={{value}} @locale="en-US" />
        </template>
      );

      assert
        .dom('[data-fr-calendar-title]')
        .hasText('March 2027', 'opens on the selection, not on today');
    });

    test('it selects a day when uncontrolled', async function (assert) {
      const seen: (Date | null)[] = [];
      const onChange = (d: Date | null) => seen.push(d);

      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @onChange={{onChange}}
          />
        </template>
      );

      await click('[data-fr-calendar-day][data-key="2026-09-09"]');

      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-09"]')
        .hasAttribute('data-selected', 'true');
      // `aria-selected` belongs on the gridcell, not the button inside it.
      const selectedCell = find(
        '[data-fr-calendar-day][data-key="2026-09-09"]'
      )!.closest('td');
      assert.dom(selectedCell).hasAria('selected', 'true');
      assert.strictEqual(seen.length, 1);
      assert.strictEqual(seen[0]!.getDate(), 9);
    });

    test('@value makes selection controlled', async function (assert) {
      const value = cell<Date | null>(null);
      const seen: (Date | null)[] = [];
      const onChange = (d: Date | null) => seen.push(d);

      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @value={{value.current}}
            @onChange={{onChange}}
          />
        </template>
      );

      await click('[data-fr-calendar-day][data-key="2026-09-09"]');

      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-09"]')
        .hasAttribute(
          'data-selected',
          'false',
          'controlled mode does not self-select'
        );
      assert.strictEqual(seen.length, 1, 'but it does report the request');

      value.current = new Date(2026, 8, 9);
      await settled();
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-09"]')
        .hasAttribute('data-selected', 'true');
    });

    test('@defaultValue seeds the selection', async function (assert) {
      const value = new Date(2026, 8, 12);

      await render(
        <template>
          <Calendar @defaultValue={{value}} @locale="en-US" />
        </template>
      );

      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-12"]')
        .hasAttribute('data-selected', 'true');
    });

    test('selecting an outside day scrolls to its month', async function (assert) {
      await render(
        <template>
          <Calendar @defaultMonth={{sep2026}} @locale="en-US" />
        </template>
      );

      await click('[data-fr-calendar-day][data-key="2026-10-01"]');

      assert
        .dom('[data-fr-calendar-title]')
        .hasText(
          'October 2026',
          'the newly selected day is never left off screen'
        );
    });

    test('explicitly controlled month with no value falls back to seedMonth via @value', async function (assert) {
      const value = new Date(2027, 5, 20);

      await render(
        <template>
          <Calendar @month={{undefined}} @value={{value}} @locale="en-US" />
        </template>
      );

      assert
        .dom('[data-fr-calendar-title]')
        .hasText('June 2027', 'opens on the selection, not on today');
    });

    test('@minValue and @maxValue disable out-of-range days', async function (assert) {
      const min = new Date(2026, 8, 5);
      const max = new Date(2026, 8, 20);

      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @minValue={{min}}
            @maxValue={{max}}
          />
        </template>
      );

      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-04"]')
        .hasAttribute('data-disabled', 'true');
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-05"]')
        .hasAttribute(
          'data-disabled',
          'false',
          'the bound itself is selectable'
        );
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-21"]')
        .hasAttribute('data-disabled', 'true');

      await click('[data-fr-calendar-day][data-key="2026-09-04"]');
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-04"]')
        .hasAttribute(
          'data-selected',
          'false',
          'a disabled day cannot be selected'
        );
    });

    test('min/max clamp month navigation', async function (assert) {
      const min = new Date(2026, 8, 5);
      const max = new Date(2026, 8, 20);

      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @minValue={{min}}
            @maxValue={{max}}
          />
        </template>
      );

      assert
        .dom('[data-fr-calendar-prev]')
        .isDisabled('no month before September');
      assert
        .dom('[data-fr-calendar-next]')
        .isDisabled('no month after September');
    });

    test('@isDateUnavailable marks days unavailable but not out of range', async function (assert) {
      const isWeekend = (d: Date) => d.getDay() === 0 || d.getDay() === 6;

      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @isDateUnavailable={{isWeekend}}
          />
        </template>
      );

      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-05"]')
        .hasAttribute('data-unavailable', 'true', 'Saturday');
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-05"]')
        .hasAttribute(
          'data-outside-range',
          'false',
          'unavailable is not out of range'
        );
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-09"]')
        .hasAttribute('data-unavailable', 'false', 'Wednesday');

      await click('[data-fr-calendar-day][data-key="2026-09-05"]');
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-05"]')
        .hasAttribute('data-selected', 'false');
    });

    test('@isReadOnly allows navigation but blocks selection', async function (assert) {
      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @isReadOnly={{true}}
          />
        </template>
      );

      await click('[data-fr-calendar-day][data-key="2026-09-09"]');
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-09"]')
        .hasAttribute('data-selected', 'false', 'not selectable');

      await click('[data-fr-calendar-next]');
      assert
        .dom('[data-fr-calendar-title]')
        .hasText('October 2026', 'still navigable');
    });

    test('@isDisabled blocks everything', async function (assert) {
      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @isDisabled={{true}}
          />
        </template>
      );

      assert.dom('[data-fr-calendar-prev]').isDisabled();
      assert.dom('[data-fr-calendar-next]').isDisabled();
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-09"]')
        .hasAttribute('data-disabled', 'true');
    });

    test('the grid is a single tab stop', async function (assert) {
      await render(
        <template>
          <Calendar @defaultMonth={{sep2026}} @locale="en-US" />
        </template>
      );

      const tabbable = findAll('[data-fr-calendar-day][tabindex="0"]');
      assert.strictEqual(tabbable.length, 1, 'exactly one day is tabbable');
    });

    test('it does not steal focus on render', async function (assert) {
      await render(
        <template>
          <Calendar @defaultMonth={{sep2026}} @locale="en-US" />
        </template>
      );

      assert.dom('[data-fr-calendar-day]').isNotFocused();
      assert.notOk(
        document.activeElement?.matches?.('[data-fr-calendar-day]'),
        'no calendar day is the active element'
      );
    });

    test('arrow keys move focus by day and by week', async function (assert) {
      await render(
        <template>
          <Calendar @defaultMonth={{sep2026}} @locale="en-US" />
        </template>
      );

      const start = '[data-fr-calendar-day][data-key="2026-09-09"]';
      await focus(start);

      await triggerKeyEvent(start, 'keydown', 'ArrowRight');
      assert
        .dom('[data-fr-calendar-day][data-focused="true"]')
        .hasAttribute('data-key', '2026-09-10');
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-10"]')
        .isFocused('DOM focus actually moved, not just the data attribute');

      await triggerKeyEvent(
        '[data-fr-calendar-day][data-key="2026-09-10"]',
        'keydown',
        'ArrowDown'
      );
      assert
        .dom('[data-fr-calendar-day][data-focused="true"]')
        .hasAttribute('data-key', '2026-09-17');
      assert.dom('[data-fr-calendar-day][data-key="2026-09-17"]').isFocused();

      await triggerKeyEvent(
        '[data-fr-calendar-day][data-key="2026-09-17"]',
        'keydown',
        'ArrowUp'
      );
      assert
        .dom('[data-fr-calendar-day][data-focused="true"]')
        .hasAttribute('data-key', '2026-09-10');
      assert.dom('[data-fr-calendar-day][data-key="2026-09-10"]').isFocused();
    });

    test('arrow keys focused on a header nav button do not hijack the day grid', async function (assert) {
      await render(
        <template>
          <Calendar @defaultMonth={{sep2026}} @locale="en-US" />
        </template>
      );

      const start = '[data-fr-calendar-day][data-key="2026-09-09"]';
      await focus(start);

      await focus('[data-fr-calendar-next]');
      await triggerKeyEvent('[data-fr-calendar-next]', 'keydown', 'ArrowRight');

      assert
        .dom('[data-fr-calendar-day][data-focused="true"]')
        .hasAttribute(
          'data-key',
          '2026-09-09',
          'the day-grid focused day did not change'
        );
      assert
        .dom('[data-fr-calendar-next]')
        .isFocused('the nav button kept DOM focus');
    });

    test('Home and End move to the week bounds', async function (assert) {
      await render(
        <template>
          <Calendar @defaultMonth={{sep2026}} @locale="en-US" />
        </template>
      );

      const start = '[data-fr-calendar-day][data-key="2026-09-09"]';
      await focus(start);

      await triggerKeyEvent(start, 'keydown', 'Home');
      assert
        .dom('[data-fr-calendar-day][data-focused="true"]')
        .hasAttribute('data-key', '2026-09-06');
      assert.dom('[data-fr-calendar-day][data-key="2026-09-06"]').isFocused();

      await triggerKeyEvent(
        '[data-fr-calendar-day][data-key="2026-09-06"]',
        'keydown',
        'End'
      );
      assert
        .dom('[data-fr-calendar-day][data-focused="true"]')
        .hasAttribute('data-key', '2026-09-12');
      assert.dom('[data-fr-calendar-day][data-key="2026-09-12"]').isFocused();
    });

    test('arrow keys cross the month boundary and move the window', async function (assert) {
      const seen: Date[] = [];
      const onMonthChange = (m: Date) => seen.push(m);

      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @onMonthChange={{onMonthChange}}
          />
        </template>
      );

      const last = '[data-fr-calendar-day][data-key="2026-09-30"]';
      await focus(last);
      await triggerKeyEvent(last, 'keydown', 'ArrowRight');

      assert.dom('[data-fr-calendar-title]').hasText('October 2026');
      assert.strictEqual(seen.length, 1, 'the month change is reported');
      assert
        .dom('[data-fr-calendar-day][data-focused="true"]')
        .hasAttribute('data-key', '2026-10-01');
      assert
        .dom('[data-fr-calendar-day][data-key="2026-10-01"]')
        .isFocused(
          'focus followed the re-rendered grid across the month boundary'
        );
    });

    test('PageUp/PageDown move a month, with Shift a year', async function (assert) {
      await render(
        <template>
          <Calendar @defaultMonth={{sep2026}} @locale="en-US" />
        </template>
      );

      const start = '[data-fr-calendar-day][data-key="2026-09-09"]';
      await focus(start);

      await triggerKeyEvent(start, 'keydown', 'PageDown');
      assert.dom('[data-fr-calendar-title]').hasText('October 2026');

      await triggerKeyEvent(
        '[data-fr-calendar-day][data-key="2026-10-09"]',
        'keydown',
        'PageUp'
      );
      assert.dom('[data-fr-calendar-title]').hasText('September 2026');

      await triggerKeyEvent(
        '[data-fr-calendar-day][data-key="2026-09-09"]',
        'keydown',
        'PageDown',
        { shiftKey: true }
      );
      assert.dom('[data-fr-calendar-title]').hasText('September 2027');
    });

    test('Enter selects the focused day', async function (assert) {
      await render(
        <template>
          <Calendar @defaultMonth={{sep2026}} @locale="en-US" />
        </template>
      );

      const start = '[data-fr-calendar-day][data-key="2026-09-09"]';
      await focus(start);
      await triggerKeyEvent(start, 'keydown', 'Enter');

      assert.dom(start).hasAttribute('data-selected', 'true');
    });

    test('@autofocus focuses the grid on insert', async function (assert) {
      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @autofocus={{true}}
          />
        </template>
      );

      assert.dom('[data-fr-calendar-day][tabindex="0"]').isFocused();
    });
  }
);
