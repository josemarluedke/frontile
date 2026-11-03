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
import { DatePicker, Form } from 'frontile';

/** Local `yyyy-MM-dd HH:mm`, or null. */
function stamp(date: Date | null | undefined): string | null {
  if (!date) return null;
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

/** The text of each segment, keyed by type. */
function segments(): Record<string, string | undefined> {
  const out: Record<string, string | undefined> = {};
  findAll('[data-part="segment"]').forEach((segment) => {
    out[(segment as HTMLElement).dataset['type']!] =
      segment.textContent?.trim();
  });
  return out;
}

const list = (type: string) => `[data-part="time-list"][data-type="${type}"]`;

const option = (type: string, value: number) =>
  `${list(type)} [data-part="time-option"][data-value="${value}"]`;

/** The options a column lists, as shown. */
function texts(type: string): string[] {
  return findAll(`${list(type)} [data-part="time-option"]`).map(
    (el) => el.textContent?.trim() ?? ''
  );
}

function selectedIn(type: string): string[] {
  return findAll(`${list(type)} [aria-selected="true"]`).map(
    (el) => el.textContent?.trim() ?? ''
  );
}

function tabStopsIn(type: string): string[] {
  return findAll(`${list(type)} [tabindex="0"]`).map(
    (el) => el.textContent?.trim() ?? ''
  );
}

const isOpen = () => find('[role="dialog"]') !== null;

module(
  'Integration | Component | DatePicker time columns | frontile/forms',
  function (hooks) {
    setupRenderingTest(hooks);

    module('rendering', function () {
      test('a minute field lists hours and minutes beside the calendar', async function (assert) {
        await render(
          <template>
            <DatePicker @label="Starts" @locale="cs-CZ" @granularity="minute" />
          </template>
        );
        await click('[data-part="calendar-button"]');

        assert
          .dom('[data-part="panels"] [data-component="calendar"]')
          .exists('the calendar is one panel');
        assert
          .dom('[data-part="panels"] [role="group"][aria-label="Time"]')
          .exists('the time is the other, a named group');
        assert.deepEqual(
          findAll('[data-part="time-list"]').map(
            (el) => (el as HTMLElement).dataset['type']
          ),
          ['hour', 'minute'],
          'in the order the field writes them'
        );
        assert.deepEqual(texts('hour'), [
          '00',
          '01',
          '02',
          '03',
          '04',
          '05',
          '06',
          '07',
          '08',
          '09',
          '10',
          '11',
          '12',
          '13',
          '14',
          '15',
          '16',
          '17',
          '18',
          '19',
          '20',
          '21',
          '22',
          '23'
        ]);
        assert.deepEqual(
          texts('minute'),
          [
            '00',
            '05',
            '10',
            '15',
            '20',
            '25',
            '30',
            '35',
            '40',
            '45',
            '50',
            '55'
          ],
          'minutes step by five'
        );
      });

      test('each column is a listbox named by its visible heading', async function (assert) {
        await render(
          <template>
            <DatePicker @label="Starts" @locale="cs-CZ" @granularity="minute" />
          </template>
        );
        await click('[data-part="calendar-button"]');

        for (const type of ['hour', 'minute']) {
          const listbox = find(list(type))!;
          assert.dom(listbox).hasAttribute('role', 'listbox');
          const heading = find(`#${listbox.getAttribute('aria-labelledby')}`);
          assert
            .dom(heading)
            .hasText(type, `the ${type} column is named by its heading`);
          assert
            .dom(heading)
            .hasAttribute('data-part', 'time-column-label', 'which is visible');
        }
        assert
          .dom(`${list('hour')} [data-part="time-option"]`)
          .hasAttribute('role', 'option')
          .hasAttribute('type', 'button');
      });

      test('a 12-hour locale lists 12 first and adds an AM/PM column', async function (assert) {
        await render(
          <template>
            <DatePicker @label="Starts" @locale="en-US" @granularity="minute" />
          </template>
        );
        await click('[data-part="calendar-button"]');

        assert.deepEqual(
          findAll('[data-part="time-list"]').map(
            (el) => (el as HTMLElement).dataset['type']
          ),
          ['hour', 'minute', 'dayPeriod']
        );
        assert.deepEqual(texts('hour'), [
          '12',
          '01',
          '02',
          '03',
          '04',
          '05',
          '06',
          '07',
          '08',
          '09',
          '10',
          '11'
        ]);
        assert.deepEqual(texts('dayPeriod'), ['AM', 'PM']);
        assert
          .dom(`#${find(list('dayPeriod'))!.getAttribute('aria-labelledby')}`)
          .hasText('AM/PM');
      });

      test('an hour field lists hours only', async function (assert) {
        await render(
          <template>
            <DatePicker @label="Starts" @locale="cs-CZ" @granularity="hour" />
          </template>
        );
        await click('[data-part="calendar-button"]');

        assert.dom('[data-part="time-list"]').exists({ count: 1 });
        assert.dom(list('hour')).exists();
      });

      test('no columns without a time, in a range, on the button trigger, or when turned off', async function (assert) {
        const range = {
          start: new Date(2026, 0, 20, 8),
          end: new Date(2026, 0, 21, 9)
        };

        await render(
          <template>
            <div data-test-day>
              <DatePicker @label="Day" @locale="cs-CZ" />
            </div>
            <div data-test-range>
              <DatePicker
                @label="Range"
                @locale="cs-CZ"
                @mode="range"
                @granularity="minute"
                @defaultValue={{range}}
              />
            </div>
            <div data-test-button>
              <DatePicker
                @label="Button"
                @locale="cs-CZ"
                @granularity="minute"
                @isEditable={{false}}
              />
            </div>
            <div data-test-off>
              <DatePicker
                @label="Off"
                @locale="cs-CZ"
                @granularity="minute"
                @showTimeColumns={{false}}
              />
            </div>
          </template>
        );

        for (const which of ['day', 'range', 'off']) {
          await click(`[data-test-${which}] [data-part="calendar-button"]`);
          assert.dom('[data-component="calendar"]').exists(`${which}: open`);
          assert.dom('[data-part="time"]').doesNotExist(`${which}: no columns`);
          await triggerKeyEvent(find(':focus')!, 'keydown', 'Escape');
        }

        await click('[data-test-button] [data-part="input"]');
        assert.dom('[data-component="calendar"]').exists('button: open');
        assert.dom('[data-part="time"]').doesNotExist('button: no columns');
      });

      test('@minuteStep sets the minutes offered', async function (assert) {
        await render(
          <template>
            <DatePicker
              @label="Starts"
              @locale="cs-CZ"
              @granularity="minute"
              @minuteStep={{15}}
            />
          </template>
        );
        await click('[data-part="calendar-button"]');

        assert.deepEqual(texts('minute'), ['00', '15', '30', '45']);
      });

      test('a minute off the step is still listed, as picked', async function (assert) {
        const value = new Date(2026, 0, 20, 10, 7);

        await render(
          <template>
            <DatePicker
              @label="Starts"
              @locale="cs-CZ"
              @granularity="minute"
              @minuteStep={{15}}
              @defaultValue={{value}}
            />
          </template>
        );
        await click('[data-part="calendar-button"]');

        assert.deepEqual(texts('minute'), ['00', '07', '15', '30', '45']);
        assert.deepEqual(selectedIn('minute'), ['07']);
      });

      test('a nonsense @minuteStep falls back to five', async function (assert) {
        await render(
          <template>
            <DatePicker
              @label="Starts"
              @locale="cs-CZ"
              @granularity="minute"
              @minuteStep={{0}}
            />
          </template>
        );
        await click('[data-part="calendar-button"]');

        assert.strictEqual(texts('minute').length, 12);
      });

      test("the value is picked, and is each column's one tab stop", async function (assert) {
        const value = new Date(2026, 0, 20, 14, 30);

        await render(
          <template>
            <DatePicker
              @label="Starts"
              @locale="cs-CZ"
              @granularity="minute"
              @defaultValue={{value}}
            />
          </template>
        );
        await click('[data-part="calendar-button"]');

        assert.deepEqual(selectedIn('hour'), ['14']);
        assert.deepEqual(selectedIn('minute'), ['30']);
        assert.deepEqual(tabStopsIn('hour'), ['14']);
        assert.deepEqual(tabStopsIn('minute'), ['30']);
        assert
          .dom(option('hour', 13))
          .hasAttribute('aria-selected', 'false', 'the others say so too');
      });

      test('an empty field picks nothing, and tabs in at @placeholderValue', async function (assert) {
        const placeholder = new Date(2026, 0, 20, 16, 37);

        await render(
          <template>
            <DatePicker
              @label="Starts"
              @locale="cs-CZ"
              @granularity="minute"
              @placeholderValue={{placeholder}}
            />
          </template>
        );
        await click('[data-part="calendar-button"]');

        assert.deepEqual(selectedIn('hour'), []);
        assert.deepEqual(selectedIn('minute'), []);
        assert.deepEqual(tabStopsIn('hour'), ['16']);
        assert.deepEqual(tabStopsIn('minute'), ['35'], 'the step before :37');
      });

      test('the selected option scrolls into view within its column', async function (assert) {
        const value = new Date(2026, 0, 20, 22, 0);

        await render(
          <template>
            <DatePicker
              @label="Starts"
              @locale="cs-CZ"
              @granularity="minute"
              @defaultValue={{value}}
            />
          </template>
        );
        await click('[data-part="calendar-button"]');

        const hours = find(list('hour')) as HTMLElement;
        assert.true(
          hours.scrollHeight > hours.clientHeight,
          'the hours scroll within the column'
        );
        assert.true(hours.scrollTop > 0, '22 is scrolled to');
      });

      test('the labels can be translated', async function (assert) {
        const labels = { time: 'Čas' };
        const segmentLabels = { hour: 'hodina', minute: 'minuta' };

        await render(
          <template>
            <DatePicker
              @label="Začátek"
              @locale="cs-CZ"
              @granularity="minute"
              @labels={{labels}}
              @segmentLabels={{segmentLabels}}
            />
          </template>
        );
        await click('[data-part="calendar-button"]');

        assert
          .dom('[data-part="time-columns"]')
          .hasAttribute('aria-label', 'Čas');
        assert.deepEqual(
          findAll('[data-part="time-column-label"]').map((el) =>
            el.textContent?.trim()
          ),
          ['hodina', 'minuta']
        );
      });

      test("the picked option takes the calendar's color", async function (assert) {
        await render(
          <template>
            <DatePicker
              @label="Starts"
              @locale="cs-CZ"
              @granularity="minute"
              @color="success"
            />
          </template>
        );
        await click('[data-part="calendar-button"]');

        assert
          .dom(option('hour', 9))
          .hasClass('data-[selected=true]:bg-success');
      });
    });

    module('pointer', function () {
      test('picking a day leaves the popover open for the time', async function (assert) {
        const seen = cell<Date | null>(null);
        const onChange = (value: Date | null) => (seen.current = value);
        const value = new Date(2026, 0, 20, 14, 30);

        await render(
          <template>
            <DatePicker
              @label="Starts"
              @locale="cs-CZ"
              @granularity="minute"
              @defaultValue={{value}}
              @onChange={{onChange}}
            />
          </template>
        );
        await click('[data-part="calendar-button"]');
        await click('[data-part="day"][data-key="2026-01-22"]');

        assert.strictEqual(stamp(seen.current), '2026-01-22 14:30');
        assert.true(isOpen(), 'still open');
      });

      test('without the columns, picking a day closes it as before', async function (assert) {
        await render(
          <template>
            <DatePicker
              @label="Starts"
              @locale="cs-CZ"
              @granularity="minute"
              @showTimeColumns={{false}}
            />
          </template>
        );
        await click('[data-part="calendar-button"]');
        await click('[data-part="day"][data-outside="false"]');

        assert.false(isOpen());
      });

      test('an hour and then a minute: each shows at once, and the minute closes', async function (assert) {
        const seen = cell<Date | null>(null);
        const onChange = (value: Date | null) => (seen.current = value);
        const value = new Date(2026, 0, 20, 14, 30);

        await render(
          <template>
            <DatePicker
              @label="Starts"
              @locale="cs-CZ"
              @granularity="minute"
              @defaultValue={{value}}
              @onChange={{onChange}}
            />
          </template>
        );
        await click('[data-part="calendar-button"]');

        await click(option('hour', 9));
        assert.strictEqual(stamp(seen.current), '2026-01-20 09:30');
        assert.strictEqual(segments()['hour'], '09', 'the segments show it');
        assert.deepEqual(selectedIn('hour'), ['09']);
        assert.true(isOpen(), 'an hour is not the whole time');

        await click(option('minute', 45));
        assert.strictEqual(stamp(seen.current), '2026-01-20 09:45');
        assert.strictEqual(segments()['minute'], '45');
        assert.false(isOpen(), 'the minute finishes it');
        assert
          .dom('[data-part="segment"][data-type="day"]')
          .isFocused('focus goes back to the field');
      });

      test('on a 12-hour clock the AM/PM column is the last', async function (assert) {
        const seen = cell<Date | null>(null);
        const onChange = (value: Date | null) => (seen.current = value);
        const value = new Date(2026, 0, 20, 9, 0);

        await render(
          <template>
            <DatePicker
              @label="Starts"
              @locale="en-US"
              @granularity="minute"
              @defaultValue={{value}}
              @onChange={{onChange}}
            />
          </template>
        );
        await click('[data-part="calendar-button"]');

        await click(option('hour', 12));
        assert.strictEqual(stamp(seen.current), '2026-01-20 00:00', '12 AM');
        await click(option('minute', 15));
        assert.true(isOpen(), 'minutes are not last here');
        await click(option('dayPeriod', 1));
        assert.strictEqual(stamp(seen.current), '2026-01-20 12:15', '12:15 PM');
        assert.false(isOpen());
      });

      test('an hour picked on an empty time reads as on the hour', async function (assert) {
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

        await click(option('hour', 10));
        assert.strictEqual(seen.current, null, 'no day yet, so no value');
        assert.strictEqual(segments()['hour'], '10');
        assert.strictEqual(segments()['minute'], '00');

        await click('[data-part="day"][data-key]:not([data-outside="true"])');
        assert.strictEqual(seen.current?.getHours(), 10, 'the day takes it');
        assert.strictEqual(seen.current?.getMinutes(), 0);
      });

      test("a minute picked on an empty time takes the placeholder's hour", async function (assert) {
        const placeholder = new Date(2026, 0, 20, 16, 37);

        await render(
          <template>
            <DatePicker
              @label="Starts"
              @locale="cs-CZ"
              @granularity="minute"
              @placeholderValue={{placeholder}}
            />
          </template>
        );
        await click('[data-part="calendar-button"]');
        await click(option('minute', 20));

        assert.strictEqual(segments()['hour'], '16');
        assert.strictEqual(segments()['minute'], '20');
      });

      test('a read-only field shows the time and picks nothing', async function (assert) {
        const seen = cell(0);
        const onChange = () => (seen.current += 1);
        const value = new Date(2026, 0, 20, 14, 30);

        await render(
          <template>
            <DatePicker
              @label="Starts"
              @locale="cs-CZ"
              @granularity="minute"
              @isReadOnly={{true}}
              @defaultValue={{value}}
              @onChange={{onChange}}
            />
          </template>
        );
        await click('[data-part="calendar-button"]');

        assert.dom(list('hour')).hasAttribute('aria-readonly', 'true');
        await click(option('hour', 9));
        assert.strictEqual(seen.current, 0, 'nothing reported');
        assert.deepEqual(selectedIn('hour'), ['14']);

        await focus(option('hour', 14));
        await triggerKeyEvent(option('hour', 14), 'keydown', 'ArrowDown');
        assert.dom(option('hour', 15)).isFocused('the keys still move');
        assert.deepEqual(selectedIn('hour'), ['14'], 'but pick nothing');
      });

      test('the picked time submits with the form', async function (assert) {
        const submitted = cell<Record<string, unknown> | null>(null);
        const onSubmit = ({ data }: { data: Record<string, unknown> }) =>
          (submitted.current = data);
        const data = { starts: '2026-01-20T14:30' };

        await render(
          <template>
            <Form @data={{data}} @onSubmit={{onSubmit}} as |form|>
              <form.Field @name="starts" as |field|>
                <field.DatePicker
                  @label="Starts"
                  @locale="cs-CZ"
                  @granularity="minute"
                />
              </form.Field>
              <button type="submit">Save</button>
            </Form>
          </template>
        );
        await click('[data-part="calendar-button"]');
        await click(option('hour', 8));
        await click(option('minute', 5));
        await click('button[type="submit"]');

        assert.deepEqual(submitted.current, { starts: '2026-01-20T08:05' });
      });
    });

    module('keyboard', function () {
      async function openAt(type: string, value: number) {
        await click('[data-part="calendar-button"]');
        await focus(option(type, value));
      }

      test('the arrow keys move and pick together', async function (assert) {
        const seen = cell<Date | null>(null);
        const onChange = (value: Date | null) => (seen.current = value);
        const value = new Date(2026, 0, 20, 14, 30);

        await render(
          <template>
            <DatePicker
              @label="Starts"
              @locale="cs-CZ"
              @granularity="minute"
              @defaultValue={{value}}
              @onChange={{onChange}}
            />
          </template>
        );
        await openAt('hour', 14);

        await triggerKeyEvent(find(':focus')!, 'keydown', 'ArrowDown');
        assert.dom(option('hour', 15)).isFocused();
        assert.strictEqual(stamp(seen.current), '2026-01-20 15:30');
        assert.deepEqual(tabStopsIn('hour'), ['15'], 'the tab stop follows');

        await triggerKeyEvent(find(':focus')!, 'keydown', 'ArrowUp');
        await triggerKeyEvent(find(':focus')!, 'keydown', 'ArrowUp');
        assert.strictEqual(stamp(seen.current), '2026-01-20 13:30');
        assert.true(isOpen(), 'moving never closes');
      });

      test('Home, End, PageUp and PageDown', async function (assert) {
        const value = new Date(2026, 0, 20, 14, 30);

        await render(
          <template>
            <DatePicker
              @label="Starts"
              @locale="cs-CZ"
              @granularity="minute"
              @defaultValue={{value}}
            />
          </template>
        );
        await openAt('hour', 14);

        await triggerKeyEvent(find(':focus')!, 'keydown', 'End');
        assert.dom(option('hour', 23)).isFocused('End');
        await triggerKeyEvent(find(':focus')!, 'keydown', 'ArrowDown');
        assert.dom(option('hour', 23)).isFocused('stops at the end, no wrap');
        await triggerKeyEvent(find(':focus')!, 'keydown', 'PageUp');
        assert.dom(option('hour', 18)).isFocused('PageUp is five');
        await triggerKeyEvent(find(':focus')!, 'keydown', 'Home');
        assert.dom(option('hour', 0)).isFocused('Home');
        await triggerKeyEvent(find(':focus')!, 'keydown', 'PageDown');
        assert.dom(option('hour', 5)).isFocused('PageDown is five');
        assert.deepEqual(selectedIn('hour'), ['05']);
      });

      test('ArrowLeft and ArrowRight go between the columns', async function (assert) {
        const value = new Date(2026, 0, 20, 14, 30);

        await render(
          <template>
            <DatePicker
              @label="Starts"
              @locale="cs-CZ"
              @granularity="minute"
              @defaultValue={{value}}
            />
          </template>
        );
        await openAt('hour', 14);

        await triggerKeyEvent(find(':focus')!, 'keydown', 'ArrowRight');
        assert.dom(option('minute', 30)).isFocused('onto the picked minute');
        await triggerKeyEvent(find(':focus')!, 'keydown', 'ArrowRight');
        assert.dom(option('minute', 30)).isFocused('nothing past the last');
        await triggerKeyEvent(find(':focus')!, 'keydown', 'ArrowLeft');
        assert.dom(option('hour', 14)).isFocused();
        assert.deepEqual(
          selectedIn('hour'),
          ['14'],
          'moving across picks nothing'
        );
      });

      test('Enter picks and finishes, from any column', async function (assert) {
        const seen = cell<Date | null>(null);
        const onChange = (value: Date | null) => (seen.current = value);
        const value = new Date(2026, 0, 20, 14, 30);

        await render(
          <template>
            <DatePicker
              @label="Starts"
              @locale="cs-CZ"
              @granularity="minute"
              @defaultValue={{value}}
              @onChange={{onChange}}
            />
          </template>
        );
        await openAt('hour', 14);
        await focus(option('hour', 11));

        // A button clicks on Enter itself; the keydown only says how.
        await triggerKeyEvent(option('hour', 11), 'keydown', 'Enter');
        await click(option('hour', 11));

        assert.strictEqual(stamp(seen.current), '2026-01-20 11:30');
        assert.false(isOpen());
        assert
          .dom('[data-part="segment"][data-type="day"]')
          .isFocused('focus goes back to the field');
      });

      test('Space picks and stays, even in the last column', async function (assert) {
        const seen = cell<Date | null>(null);
        const onChange = (value: Date | null) => (seen.current = value);
        const value = new Date(2026, 0, 20, 14, 30);

        await render(
          <template>
            <DatePicker
              @label="Starts"
              @locale="cs-CZ"
              @granularity="minute"
              @defaultValue={{value}}
              @onChange={{onChange}}
            />
          </template>
        );
        await openAt('minute', 30);
        await focus(option('minute', 50));

        await triggerKeyEvent(option('minute', 50), 'keydown', ' ');
        await click(option('minute', 50));

        assert.strictEqual(stamp(seen.current), '2026-01-20 14:50');
        assert.true(isOpen());
      });

      test('typing jumps to a value', async function (assert) {
        const value = new Date(2026, 0, 20, 8, 30);

        await render(
          <template>
            <DatePicker
              @label="Starts"
              @locale="cs-CZ"
              @granularity="minute"
              @defaultValue={{value}}
            />
          </template>
        );
        await openAt('hour', 8);

        await triggerKeyEvent(find(':focus')!, 'keydown', '1');
        assert.dom(option('hour', 1)).isFocused("1 is one o'clock");
        await triggerKeyEvent(find(':focus')!, 'keydown', '7');
        assert.dom(option('hour', 17)).isFocused('then 7 makes 17');
        assert.deepEqual(selectedIn('hour'), ['17']);

        await triggerKeyEvent(find(':focus')!, 'keydown', 'ArrowRight');
        await triggerKeyEvent(find(':focus')!, 'keydown', '4');
        assert.dom(option('minute', 40)).isFocused('4 finds 40');
      });

      test('typing a letter picks AM or PM', async function (assert) {
        const seen = cell<Date | null>(null);
        const onChange = (value: Date | null) => (seen.current = value);
        const value = new Date(2026, 0, 20, 9, 0);

        await render(
          <template>
            <DatePicker
              @label="Starts"
              @locale="en-US"
              @granularity="minute"
              @defaultValue={{value}}
              @onChange={{onChange}}
            />
          </template>
        );
        await openAt('dayPeriod', 0);

        await triggerKeyEvent(find(':focus')!, 'keydown', 'P');
        assert.strictEqual(stamp(seen.current), '2026-01-20 21:00');
      });

      test('Escape closes and keeps what was picked', async function (assert) {
        const seen = cell<Date | null>(null);
        const onChange = (value: Date | null) => (seen.current = value);
        const value = new Date(2026, 0, 20, 14, 30);

        await render(
          <template>
            <DatePicker
              @label="Starts"
              @locale="cs-CZ"
              @granularity="minute"
              @defaultValue={{value}}
              @onChange={{onChange}}
            />
          </template>
        );
        await openAt('hour', 14);
        await triggerKeyEvent(find(':focus')!, 'keydown', 'ArrowDown');
        await triggerKeyEvent(find(':focus')!, 'keydown', 'Escape');

        assert.false(isOpen());
        assert.strictEqual(stamp(seen.current), '2026-01-20 15:30');
        assert.strictEqual(segments()['hour'], '15');
      });

      test('the columns see what was typed into the segments', async function (assert) {
        await render(
          <template>
            <DatePicker @label="Starts" @locale="cs-CZ" @granularity="minute" />
          </template>
        );

        await focus('[data-part="segment"][data-type="hour"]');
        for (const key of ['0', '7', '2', '0']) {
          await triggerKeyEvent(find(':focus')!, 'keydown', key);
        }
        await click('[data-part="calendar-button"]');

        assert.deepEqual(selectedIn('hour'), ['07']);
        assert.deepEqual(selectedIn('minute'), ['20']);
      });
    });
  }
);
