import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  findAll,
  find,
  click,
  settled,
  focus,
  fillIn,
  triggerKeyEvent,
  triggerEvent
} from '@ember/test-helpers';
import { on } from '@ember/modifier';
import { cell } from 'ember-resources';
import { Calendar } from 'frontile';
import type { DateRange } from 'frontile';

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

    test('the <:day> block replaces cell content and yields day state', async function (assert) {
      const priceFor = (date: Date) =>
        date.getDay() === 0 || date.getDay() === 6 ? '$120' : '$100';

      await render(
        <template>
          <Calendar @defaultMonth={{sep2026}} @locale="en-US">
            <:day as |day|>
              <span data-test-num>{{day.dayOfMonth}}</span>
              {{#unless day.isOutside}}
                <span data-test-price>{{priceFor day.date}}</span>
              {{/unless}}
            </:day>
          </Calendar>
        </template>
      );

      const cellSel = '[data-fr-calendar-day][data-key="2026-09-09"]';
      assert.dom(`${cellSel} [data-test-num]`).hasText('9');
      assert.dom(`${cellSel} [data-test-price]`).hasText('$100');
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-05"] [data-test-price]')
        .hasText('$120', 'Saturday is priced higher');
      assert
        .dom('[data-fr-calendar-day][data-key="2026-08-30"] [data-test-price]')
        .doesNotExist('outside days opt out');
    });

    test('the <:header> block replaces the header and yields navigation', async function (assert) {
      await render(
        <template>
          <Calendar @defaultMonth={{sep2026}} @locale="en-US">
            <:header as |ctx|>
              <h2 data-test-caption>{{ctx.title}}</h2>
              <button
                type="button"
                data-test-next
                {{on "click" ctx.goToNext}}
              >next</button>
            </:header>
          </Calendar>
        </template>
      );

      assert
        .dom('[data-fr-calendar-prev]')
        .doesNotExist('default header replaced');
      assert.dom('[data-test-caption]').hasText('September 2026');

      await click('[data-test-next]');
      assert.dom('[data-test-caption]').hasText('October 2026');
    });

    test('a custom <:header> block can open the year grid via the yielded context', async function (assert) {
      await render(
        <template>
          <Calendar @defaultMonth={{sep2026}} @locale="en-US">
            <:header as |ctx|>
              <h2 data-test-caption>{{ctx.title}}</h2>
              <button
                type="button"
                data-test-year-trigger
                aria-expanded={{if ctx.isYearGridOpen "true" "false"}}
                {{on "click" ctx.toggleYearGrid}}
              >year</button>
            </:header>
          </Calendar>
        </template>
      );

      assert.dom('[data-fr-calendar-year-grid]').doesNotExist();
      assert.dom('[data-test-year-trigger]').hasAria('expanded', 'false');

      await click('[data-test-year-trigger]');

      assert.dom('[data-fr-calendar-year-grid]').exists('year grid opens');
      assert.dom('[data-test-year-trigger]').hasAria('expanded', 'true');

      await click('[data-fr-calendar-year][data-year="2029"]');

      assert.dom('[data-fr-calendar-year-grid]').doesNotExist('closes on pick');
      assert.dom('[data-test-caption]').hasText('September 2029');
      assert.notStrictEqual(
        document.activeElement,
        document.body,
        'focus does not fall to <body> -- there is no default year trigger to restore it to'
      );
      assert
        .dom('[data-fr-calendar-day][tabindex="0"]')
        .isFocused(
          'focus falls back to the roving day cell when a custom <:header> replaced the year trigger'
        );
    });

    test('the <:weekday> block customizes the column headers', async function (assert) {
      await render(
        <template>
          <Calendar @defaultMonth={{sep2026}} @locale="en-US">
            <:weekday as |wd|><abbr
                title={{wd.long}}
              >{{wd.narrow}}</abbr></:weekday>
          </Calendar>
        </template>
      );

      const first = findAll('[data-fr-calendar-weekday]')[0]!;
      assert.dom(first.querySelector('abbr')).hasText('S');
      assert.dom(first.querySelector('abbr')).hasAttribute('title', 'Sunday');
    });

    test('the <:footer> block renders below the grids', async function (assert) {
      await render(
        <template>
          <Calendar @defaultMonth={{sep2026}} @locale="en-US">
            <:footer><button
                type="button"
                data-test-today
              >Today</button></:footer>
          </Calendar>
        </template>
      );

      assert.dom('[data-fr-calendar-footer] [data-test-today]').exists();
    });

    test('no footer wrapper renders when no <:footer> block is supplied', async function (assert) {
      await render(
        <template>
          <Calendar @defaultMonth={{sep2026}} @locale="en-US" />
        </template>
      );

      assert.dom('[data-fr-calendar-footer]').doesNotExist();
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

    test('min/max clamp month navigation against the whole multi-month landing window, not just its first month', async function (assert) {
      // Window is Mar+Apr 2026. Going back one window (@pageBehavior
      // defaults to 'visible', so the whole window moves) lands on
      // Jan+Feb 2026. @minValue falls inside February, the *second* month
      // of that landing window -- checking only January (the first month)
      // would wrongly leave Previous disabled even though Feb 15-28 are
      // reachable and selectable.
      const min = new Date(2026, 1, 15); // Feb 15 2026
      const mar2026 = new Date(2026, 2, 1);

      await render(
        <template>
          <Calendar
            @defaultMonth={{mar2026}}
            @locale="en-US"
            @visibleMonths={{2}}
            @minValue={{min}}
          />
        </template>
      );

      assert
        .dom('[data-fr-calendar-prev]')
        .isNotDisabled(
          'February 15-28 are still reachable, so Previous must stay enabled'
        );

      await click('[data-fr-calendar-prev]');

      assert
        .dom(findAll('[data-fr-calendar-grid]')[0]!)
        .hasAria('label', 'January 2026');
      assert
        .dom(findAll('[data-fr-calendar-grid]')[1]!)
        .hasAria('label', 'February 2026');
      assert
        .dom('[data-fr-calendar-day][data-key="2026-02-15"]')
        .hasAttribute(
          'data-disabled',
          'false',
          'the min bound itself is reachable and selectable'
        );
      assert
        .dom('[data-fr-calendar-day][data-key="2026-01-31"]')
        .hasAttribute('data-disabled', 'true', 'January is fully out of range');
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

    test('@autofocus only focuses the grid once, not on every subsequent focus recompute', async function (assert) {
      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @autofocus={{true}}
          />
        </template>
      );

      assert
        .dom('[data-fr-calendar-day][tabindex="0"]')
        .isFocused('the initial insert still autofocuses the grid');

      // Paging away from today moves `defaultFocusedDate` (today is no
      // longer in the visible window), which reruns the focus modifier --
      // `@autofocus` must not use that rerun as a fresh excuse to yank
      // focus back into the grid.
      await click('[data-fr-calendar-next]');
      assert
        .dom('[data-fr-calendar-next]')
        .isFocused(
          'focus stays on the nav button after paging once'
        );

      await click('[data-fr-calendar-next]');
      assert
        .dom('[data-fr-calendar-next]')
        .isFocused('focus stays on the nav button after paging twice');
    });

    test('range mode commits on the second click', async function (assert) {
      const seen: (DateRange | null)[] = [];
      const onChange = (r: DateRange | null) => seen.push(r);

      await render(
        <template>
          <Calendar
            @mode="range"
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @onChange={{onChange}}
          />
        </template>
      );

      await click('[data-fr-calendar-day][data-key="2026-09-09"]');
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-09"]')
        .hasAttribute('data-range-start', 'true');

      await click('[data-fr-calendar-day][data-key="2026-09-18"]');

      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-18"]')
        .hasAttribute('data-range-end', 'true');
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-13"]')
        .hasAttribute('data-in-range', 'true');
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-19"]')
        .hasAttribute('data-in-range', 'false');

      const committed = seen.at(-1)!;
      assert.strictEqual(committed.start.getDate(), 9);
      assert.strictEqual(committed.end!.getDate(), 18);
    });

    test('a backwards drag still yields an ordered range', async function (assert) {
      const seen: (DateRange | null)[] = [];
      const onChange = (r: DateRange | null) => seen.push(r);

      await render(
        <template>
          <Calendar
            @mode="range"
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @onChange={{onChange}}
          />
        </template>
      );

      await click('[data-fr-calendar-day][data-key="2026-09-18"]');
      await click('[data-fr-calendar-day][data-key="2026-09-09"]');

      const committed = seen.at(-1)!;
      assert.strictEqual(
        committed.start.getDate(),
        9,
        'start is the earlier day'
      );
      assert.strictEqual(committed.end!.getDate(), 18);
    });

    test('hovering previews the pending range', async function (assert) {
      await render(
        <template>
          <Calendar @mode="range" @defaultMonth={{sep2026}} @locale="en-US" />
        </template>
      );

      await click('[data-fr-calendar-day][data-key="2026-09-09"]');
      await triggerEvent(
        '[data-fr-calendar-day][data-key="2026-09-14"]',
        'mouseenter'
      );

      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-12"]')
        .hasAttribute('data-preview', 'true');
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-16"]')
        .hasAttribute('data-preview', 'false');
    });

    test('the range preview stops at an unavailable day it cannot select', async function (assert) {
      const isBooked = (d: Date) => d.getMonth() === 8 && d.getDate() === 14;

      await render(
        <template>
          <Calendar
            @mode="range"
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @isDateUnavailable={{isBooked}}
          />
        </template>
      );

      await click('[data-fr-calendar-day][data-key="2026-09-09"]');
      await triggerEvent(
        '[data-fr-calendar-day][data-key="2026-09-18"]',
        'mouseenter'
      );

      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-13"]')
        .hasAttribute(
          'data-in-range',
          'true',
          'the preview reaches right up to the day before the blocked date'
        );
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-13"]')
        .hasAttribute(
          'data-range-end',
          'true',
          'the preview band ends at the last reachable day, not the hovered one'
        );
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-14"]')
        .hasAttribute(
          'data-in-range',
          'false',
          'the booked night itself is never painted as reachable'
        );
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-18"]')
        .hasAttribute(
          'data-in-range',
          'false',
          'the band does not paint through to the actually-hovered day'
        );
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-18"]')
        .hasAttribute('data-disabled', 'true', 'and it cannot be selected');
    });

    test('arrow-key movement advances the range preview after anchoring', async function (assert) {
      await render(
        <template>
          <Calendar @mode="range" @defaultMonth={{sep2026}} @locale="en-US" />
        </template>
      );

      const anchor = '[data-fr-calendar-day][data-key="2026-09-09"]';
      await click(anchor);
      await focus(anchor);

      // Move focus two days forward: 9 -> 10 -> 11.
      await triggerKeyEvent(anchor, 'keydown', 'ArrowRight');
      await triggerKeyEvent(
        '[data-fr-calendar-day][data-key="2026-09-10"]',
        'keydown',
        'ArrowRight'
      );

      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-11"]')
        .hasAttribute(
          'data-range-end',
          'true',
          'the preview end follows the focused day'
        );
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-10"]')
        .hasAttribute(
          'data-in-range',
          'true',
          'a day newly covered by the extended preview is marked in-range'
        );
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-12"]')
        .hasAttribute(
          'data-in-range',
          'false',
          'a day beyond the preview is not covered'
        );

      // Pointer hover still works after keyboard movement took over.
      await triggerEvent(
        '[data-fr-calendar-day][data-key="2026-09-14"]',
        'mouseenter'
      );
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-12"]')
        .hasAttribute(
          'data-in-range',
          'true',
          'hover regains control of the preview'
        );
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-11"]')
        .hasAttribute('data-range-end', 'false', 'hover replaced the end day');
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-14"]')
        .hasAttribute('data-range-end', 'true');

      // And keyboard movement can take control back from a hover.
      await triggerKeyEvent(
        '[data-fr-calendar-day][data-key="2026-09-10"]',
        'keydown',
        'ArrowRight'
      );
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-11"]')
        .hasAttribute(
          'data-range-end',
          'true',
          'arrow-key movement regains control of the preview from hover'
        );
    });

    test('Escape cancels a pending range without emitting', async function (assert) {
      const seen: (DateRange | null)[] = [];
      const onChange = (r: DateRange | null) => seen.push(r);

      await render(
        <template>
          <Calendar
            @mode="range"
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @onChange={{onChange}}
          />
        </template>
      );

      await click('[data-fr-calendar-day][data-key="2026-09-09"]');
      const afterFirst = seen.length;

      await triggerKeyEvent(
        '[data-fr-calendar-day][data-key="2026-09-09"]',
        'keydown',
        'Escape'
      );

      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-09"]')
        .hasAttribute('data-range-start', 'false', 'the anchor is cleared');
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-09"]')
        .hasAttribute(
          'data-selected',
          'false',
          'the half-open commit made at anchor time is retracted, not just hidden from the range band'
        );
      assert.strictEqual(
        seen.length,
        afterFirst + 1,
        'the retraction is reported via @onChange'
      );
      assert.strictEqual(
        seen.at(-1),
        null,
        'the retraction commits null, clearing the half-open range'
      );
    });

    test('controlled range mode does not self-select; @onChange receives a normalized range', async function (assert) {
      const seen: (DateRange | null)[] = [];
      const onChange = (r: DateRange | null) => seen.push(r);
      const value = cell<DateRange | null>(null);

      await render(
        <template>
          <Calendar
            @mode="range"
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @value={{value.current}}
            @onChange={{onChange}}
          />
        </template>
      );

      await click('[data-fr-calendar-day][data-key="2026-09-18"]');
      await click('[data-fr-calendar-day][data-key="2026-09-09"]');

      // The component never wrote its own selection: with @value still
      // null, nothing is painted as selected/in-range.
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-09"]')
        .hasAttribute(
          'data-range-start',
          'false',
          'painted selection stays driven by @value, not internal state'
        );
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-13"]')
        .hasAttribute('data-in-range', 'false');

      const anchored = seen[0]!;
      assert.strictEqual(anchored?.start.getDate(), 18, 'anchor step emits');
      assert.strictEqual(anchored?.end, null);

      const committed = seen.at(-1)!;
      assert.strictEqual(
        committed.start.getDate(),
        9,
        'the normalized range starts at the earlier day'
      );
      assert.strictEqual(committed.end!.getDate(), 18);
    });

    test('a range cannot straddle an unavailable date', async function (assert) {
      const isBooked = (d: Date) => d.getMonth() === 8 && d.getDate() === 14;

      await render(
        <template>
          <Calendar
            @mode="range"
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @isDateUnavailable={{isBooked}}
          />
        </template>
      );

      await click('[data-fr-calendar-day][data-key="2026-09-09"]');

      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-13"]')
        .hasAttribute(
          'data-disabled',
          'false',
          'reachable before the booked night'
        );
      assert
        .dom('[data-fr-calendar-day][data-key="2026-09-18"]')
        .hasAttribute('data-disabled', 'true', 'unreachable past it');
    });

    test('@visibleMonths renders side-by-side grids', async function (assert) {
      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @visibleMonths={{2}}
          />
        </template>
      );

      const grids = findAll('[data-fr-calendar-grid]');
      assert.strictEqual(grids.length, 2);
      assert.dom(grids[0]!).hasAria('label', 'September 2026');
      assert.dom(grids[1]!).hasAria('label', 'October 2026');
    });

    test('@pageBehavior controls how far next advances', async function (assert) {
      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @visibleMonths={{2}}
          />
        </template>
      );

      await click('[data-fr-calendar-next]');
      assert
        .dom(findAll('[data-fr-calendar-grid]')[0]!)
        .hasAria('label', 'November 2026', 'default advances by the window');
    });

    test('@pageBehavior="single" advances one month at a time', async function (assert) {
      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @visibleMonths={{2}}
            @pageBehavior="single"
          />
        </template>
      );

      await click('[data-fr-calendar-next]');
      assert
        .dom(findAll('[data-fr-calendar-grid]')[0]!)
        .hasAria('label', 'October 2026');
    });

    test('clicking a day in the second visible month does not scroll the window', async function (assert) {
      const seen: Date[] = [];
      const onMonthChange = (m: Date) => seen.push(m);

      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @visibleMonths={{2}}
            @onMonthChange={{onMonthChange}}
          />
        </template>
      );

      // "2026-10-05" only exists inside the second grid -- it is not an
      // "outside day" of the first grid, since both months are fully
      // within the visible window.
      await click('[data-fr-calendar-day][data-key="2026-10-05"]');

      assert.strictEqual(
        seen.length,
        0,
        'selecting a day already inside the window must not page it'
      );
      const grids = findAll('[data-fr-calendar-grid]');
      assert.dom(grids[0]!).hasAria('label', 'September 2026');
      assert.dom(grids[1]!).hasAria('label', 'October 2026');
      assert
        .dom('[data-fr-calendar-day][data-key="2026-10-05"]')
        .hasAttribute('data-selected', 'true');
    });

    test('arrow keys crossing into the second visible month do not re-page', async function (assert) {
      const seen: Date[] = [];
      const onMonthChange = (m: Date) => seen.push(m);

      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @visibleMonths={{2}}
            @onMonthChange={{onMonthChange}}
          />
        </template>
      );

      const last = '[data-fr-calendar-day][data-key="2026-09-30"]';
      await focus(last);
      await triggerKeyEvent(last, 'keydown', 'ArrowRight');

      assert.strictEqual(
        seen.length,
        0,
        'moving focus into a month already inside the window must not page it'
      );
      const grids = findAll('[data-fr-calendar-grid]');
      assert.dom(grids[0]!).hasAria('label', 'September 2026');
      assert.dom(grids[1]!).hasAria('label', 'October 2026');
      assert
        .dom('[data-fr-calendar-day][data-key="2026-10-01"]')
        .isFocused('focus moved into the second grid');
    });

    test('@visibleMonths={{2}} hides outside days by default so a boundary date renders exactly once', async function (assert) {
      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @visibleMonths={{2}}
          />
        </template>
      );

      // "2026-10-01" is a real day in the October grid and, with outside
      // days shown, would also render as a trailing outside day in the
      // September grid -- the default for a multi-month window must
      // suppress that duplicate.
      assert
        .dom('[data-fr-calendar-day][data-key="2026-10-01"]')
        .exists({ count: 1 });
    });

    test('explicit @showOutsideDays={{true}} overrides the multi-month default', async function (assert) {
      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @visibleMonths={{2}}
            @showOutsideDays={{true}}
          />
        </template>
      );

      assert
        .dom('[data-fr-calendar-day][data-key="2026-10-01"]')
        .exists(
          { count: 2 },
          'an explicit true must still render the boundary day in both grids'
        );
    });

    test('single-month default still shows outside days', async function (assert) {
      await render(
        <template>
          <Calendar @defaultMonth={{sep2026}} @locale="en-US" />
        </template>
      );

      assert
        .dom('[data-fr-calendar-day][data-key="2026-08-30"]')
        .exists('single-month window keeps showing outside days by default');
    });

    test('@captionLayout="dropdown" renders a month select and a year trigger', async function (assert) {
      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @captionLayout="dropdown"
          />
        </template>
      );

      assert.dom('[data-fr-calendar-month-select]').exists();
      assert
        .dom('[data-fr-calendar-month-select]')
        .hasValue('8', 'September is month index 8');

      assert.dom('[data-fr-calendar-year-trigger]').hasText('2026');
      assert
        .dom('[data-fr-calendar-year-trigger]')
        .hasAria('expanded', 'false', 'the grid starts closed');
      assert
        .dom('[data-fr-calendar-title]')
        .doesNotExist('the plain label is replaced');
    });

    test('choosing a month from the dropdown navigates', async function (assert) {
      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @captionLayout="dropdown"
          />
        </template>
      );

      await fillIn('[data-fr-calendar-month-select]', '11');

      assert
        .dom(findAll('[data-fr-calendar-grid]')[0]!)
        .hasAria('label', 'December 2026');
    });

    test('the year grid opens from the trigger and picks a year', async function (assert) {
      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @captionLayout="dropdown"
          />
        </template>
      );

      assert
        .dom('[data-fr-calendar-year-grid]')
        .doesNotExist('closed by default');

      await click('[data-fr-calendar-year-trigger]');

      assert.dom('[data-fr-calendar-year-grid]').exists();
      assert.dom('[data-fr-calendar-year-trigger]').hasAria('expanded', 'true');
      assert
        .dom('[data-fr-calendar-year][data-selected="true"]')
        .hasText('2026', 'the current year is marked');

      await click('[data-fr-calendar-year][data-year="2029"]');

      assert.dom('[data-fr-calendar-year-grid]').doesNotExist('closes on pick');
      assert
        .dom(findAll('[data-fr-calendar-grid]')[0]!)
        .hasAria('label', 'September 2029');
      assert
        .dom('[data-fr-calendar-year-trigger]')
        .isFocused('focus returns to the trigger after a click pick');
    });

    test('picking a year via keyboard (Enter) also returns focus to the trigger', async function (assert) {
      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @captionLayout="dropdown"
          />
        </template>
      );

      await click('[data-fr-calendar-year-trigger]');

      await triggerKeyEvent(
        '[data-fr-calendar-year][data-year="2026"]',
        'keydown',
        'ArrowRight'
      );
      assert.dom('[data-fr-calendar-year][data-year="2027"]').isFocused();

      // A focused native <button> fires a click when Enter is pressed on
      // it; test-helper `triggerKeyEvent` dispatches an untrusted event, so
      // it does not trigger that native default action -- fire the click
      // that a real keyboard commit would produce.
      await triggerEvent('[data-fr-calendar-year][data-year="2027"]', 'click');

      assert.dom('[data-fr-calendar-year-grid]').doesNotExist('closes on pick');
      assert
        .dom(findAll('[data-fr-calendar-grid]')[0]!)
        .hasAria('label', 'September 2027');
      assert
        .dom('[data-fr-calendar-year-trigger]')
        .isFocused('focus returns to the trigger after a keyboard pick');
    });

    test('the year grid is clamped by min/max', async function (assert) {
      const min = new Date(2025, 0, 1);
      const max = new Date(2027, 11, 31);

      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @captionLayout="dropdown"
            @minValue={{min}}
            @maxValue={{max}}
          />
        </template>
      );

      await click('[data-fr-calendar-year-trigger]');

      assert.deepEqual(
        findAll('[data-fr-calendar-year]').map((el) => el.textContent?.trim()),
        ['2025', '2026', '2027']
      );
    });

    test('the year grid is keyboard navigable and Escape closes it', async function (assert) {
      await render(
        <template>
          <Calendar
            @defaultMonth={{sep2026}}
            @locale="en-US"
            @captionLayout="dropdown"
          />
        </template>
      );

      await click('[data-fr-calendar-year-trigger]');

      assert
        .dom('[data-fr-calendar-year][data-year="2026"]')
        .isFocused('opening moves focus to the current year');

      // The grid is three columns wide, so Down moves by three years.
      await triggerKeyEvent(
        '[data-fr-calendar-year][data-year="2026"]',
        'keydown',
        'ArrowRight'
      );
      assert.dom('[data-fr-calendar-year][data-year="2027"]').isFocused();

      await triggerKeyEvent(
        '[data-fr-calendar-year][data-year="2027"]',
        'keydown',
        'ArrowDown'
      );
      assert.dom('[data-fr-calendar-year][data-year="2030"]').isFocused();

      await triggerKeyEvent(
        '[data-fr-calendar-year][data-year="2030"]',
        'keydown',
        'Escape'
      );

      assert.dom('[data-fr-calendar-year-grid]').doesNotExist('Escape closes');
      assert
        .dom('[data-fr-calendar-year-trigger]')
        .isFocused('focus returns to the trigger');
    });
  }
);
