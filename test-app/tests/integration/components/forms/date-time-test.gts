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
import { cell } from 'ember-resources';
import { DateInput, DatePicker, Form } from 'frontile';
import { fillDate, fillDateRange } from 'frontile/test-support';

/** The text of each segment of the (first) group, keyed by type. */
function segments(group = 0): Record<string, string | undefined> {
  const root = findAll('[data-part="group"]')[group];
  const out: Record<string, string | undefined> = {};
  root?.querySelectorAll('[data-part="segment"]').forEach((segment) => {
    out[(segment as HTMLElement).dataset['type']!] =
      segment.textContent?.trim();
  });
  return out;
}

/** Local `yyyy-MM-dd HH:mm`, or null. */
function stamp(date: Date | null | undefined): string | null {
  if (!date) return null;
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

function captureSubmit() {
  const submitted = cell<Record<string, unknown> | null>(null);
  return {
    submitted,
    onSubmit: ({ data }: { data: Record<string, unknown> }) => {
      submitted.current = data;
    }
  };
}

module(
  'Integration | Component | DateInput and DatePicker with a time | frontile/forms',
  function (hooks) {
    setupRenderingTest(hooks);

    test('a minute DateInput composes the date and the time', async function (assert) {
      const seen = cell<Date | null>(null);
      const onChange = (value: Date | null) => (seen.current = value);

      await render(
        <template>
          <DateInput
            @label="Starts"
            @locale="en-US"
            @granularity="minute"
            @onChange={{onChange}}
            data-test-starts
          />
        </template>
      );

      await fillDate('[data-test-starts]', '2026-01-20T21:05');

      assert.strictEqual(stamp(seen.current), '2026-01-20 21:05');
      assert.deepEqual(segments(), {
        month: '01',
        day: '20',
        year: '2026',
        hour: '09',
        minute: '05',
        dayPeriod: 'PM'
      });
    });

    test('AM/PM is typed by its letter', async function (assert) {
      const seen = cell<Date | null>(null);
      const onChange = (value: Date | null) => (seen.current = value);
      const morning = new Date(2026, 0, 20, 9, 15);

      await render(
        <template>
          <DateInput
            @label="Starts"
            @locale="en-US"
            @granularity="minute"
            @defaultValue={{morning}}
            @onChange={{onChange}}
          />
        </template>
      );

      const dayPeriod = find('[data-type="dayPeriod"]') as HTMLElement;
      assert.dom(dayPeriod).hasAttribute('inputmode', 'text');
      assert.dom(dayPeriod).hasAttribute('aria-valuetext', 'AM');

      await focus(dayPeriod);
      await triggerKeyEvent(dayPeriod, 'keydown', 'P');

      assert.strictEqual(stamp(seen.current), '2026-01-20 21:15');
      assert.dom(dayPeriod).hasText('PM');
    });

    test('a 24-hour locale has no AM/PM', async function (assert) {
      await render(
        <template>
          <DateInput @label="Začátek" @locale="cs-CZ" @granularity="minute" />
        </template>
      );

      assert.dom('[data-type="hour"]').hasAttribute('aria-valuemax', '23');
      assert.dom('[data-type="dayPeriod"]').doesNotExist();
    });

    test('a DateInput in a Form submits and takes a local date-time', async function (assert) {
      const { submitted, onSubmit } = captureSubmit();
      const data = { start: '2026-01-20T09:15' };

      await render(
        <template>
          <Form @data={{data}} @onSubmit={{onSubmit}} as |form|>
            <form.Field @name="start" as |field|>
              <field.DateInput
                @label="Starts"
                @locale="cs-CZ"
                @granularity="minute"
                data-test-starts
              />
            </form.Field>
            <button type="submit">Save</button>
          </Form>
        </template>
      );

      assert.deepEqual(segments(), {
        day: '20',
        month: '01',
        year: '2026',
        hour: '09',
        minute: '15'
      });

      await fillDate('[data-test-starts]', '2026-01-21T17:45');
      await click('button[type="submit"]');

      assert.deepEqual(submitted.current, { start: '2026-01-21T17:45' });
    });

    test('picking a day in the calendar keeps the typed time', async function (assert) {
      const seen = cell<Date | null>(null);
      const onChange = (value: Date | null) => (seen.current = value);

      await render(
        <template>
          <DatePicker
            @label="Starts"
            @locale="cs-CZ"
            @granularity="minute"
            @onChange={{onChange}}
            data-test-starts
          />
        </template>
      );

      // The time first, before any day exists.
      const hour = find('[data-type="hour"]') as HTMLElement;
      await focus(hour);
      for (const key of ['0', '9', '1', '5']) {
        await triggerKeyEvent(find(':focus')!, 'keydown', key);
      }
      assert.strictEqual(seen.current, null, 'no day yet, so no value');

      await click('[data-part="calendar-button"]');
      const day = find('[data-part="day"][data-outside="false"]');
      await click(day!);

      assert.strictEqual(seen.current?.getHours(), 9);
      assert.strictEqual(seen.current?.getMinutes(), 15);
    });

    test('picking a day with no time entered gives midnight', async function (assert) {
      const seen = cell<Date | null>(null);
      const onChange = (value: Date | null) => (seen.current = value);

      await render(
        <template>
          <DatePicker
            @label="Starts"
            @locale="cs-CZ"
            @granularity="minute"
            @onChange={{onChange}}
          />
        </template>
      );

      await click('[data-part="calendar-button"]');
      await click(find('[data-part="day"][data-outside="false"]')!);

      assert.strictEqual(seen.current?.getHours(), 0);
      assert.strictEqual(seen.current?.getMinutes(), 0);
      assert.strictEqual(segments()['hour'], '00', 'and shows it');
    });

    test('picking another day keeps the time the field shows', async function (assert) {
      const seen = cell<Date | null>(null);
      const onChange = (value: Date | null) => (seen.current = value);
      const start = new Date(2026, 0, 20, 14, 30);

      await render(
        <template>
          <DatePicker
            @label="Starts"
            @locale="cs-CZ"
            @granularity="minute"
            @defaultValue={{start}}
            @onChange={{onChange}}
          />
        </template>
      );

      await click('[data-part="calendar-button"]');
      await click('[data-part="day"][data-key="2026-01-22"]');

      assert.strictEqual(stamp(seen.current), '2026-01-22 14:30');
    });

    test('a range keeps each end its own time, and round-trips form data', async function (assert) {
      const { submitted, onSubmit } = captureSubmit();
      const data = {
        shift: { start: '2026-01-20T08:00', end: '2026-01-20T16:30' }
      };

      await render(
        <template>
          <Form @data={{data}} @onSubmit={{onSubmit}} as |form|>
            <form.Field @name="shift" as |field|>
              <field.DateRangePicker
                @label="Shift"
                @locale="cs-CZ"
                @granularity="minute"
                data-test-shift
              />
            </form.Field>
            <button type="submit">Save</button>
          </Form>
        </template>
      );

      assert.strictEqual(segments(1)['hour'], '16', 'the end shows its time');

      await click('button[type="submit"]');
      assert.deepEqual(
        submitted.current,
        data,
        'unchanged, it submits as it came'
      );

      await fillDateRange(
        '[data-test-shift]',
        '2026-01-21T07:15',
        '2026-01-21T15:45'
      );
      await click('button[type="submit"]');
      assert.deepEqual(submitted.current, {
        shift: { start: '2026-01-21T07:15', end: '2026-01-21T15:45' }
      });
    });

    test('the button trigger shows the time by default', async function (assert) {
      const value = new Date(2026, 0, 20, 21, 5);

      await render(
        <template>
          <DatePicker
            @label="Starts"
            @locale="en-US"
            @granularity="minute"
            @isEditable={{false}}
            @value={{value}}
          />
        </template>
      );

      assert.dom('[data-part="input"]').includesText('Jan 20, 2026');
      assert.dom('[data-part="input"]').includesText('9:05');
    });
  }
);
