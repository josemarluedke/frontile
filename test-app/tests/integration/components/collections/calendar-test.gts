import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, findAll, find, click, settled } from '@ember/test-helpers';
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
  }
);
