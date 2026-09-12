import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, triggerKeyEvent, settled } from '@ember/test-helpers';
import { cell } from 'ember-resources';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import { DatePicker, Form } from 'frontile';

const jan20 = new Date(2026, 0, 20);
const janAnchor = { start: new Date(2026, 0, 5), end: new Date(2026, 0, 6) };

// `Date` is not a template helper; a plain function stands in.
const Date_ = (y: number, m: number, d: number) => new Date(y, m, d);

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

    test('clicking the trigger opens a calendar in a dialog', async function (assert) {
      await render(
        <template>
          <DatePicker @label="Start" @defaultValue={{jan20}} @locale="en-US" />
        </template>
      );

      assert
        .dom('[data-component="calendar"]')
        .doesNotExist('closed initially');

      await click('[data-part="input"]');

      assert.dom('[data-component="calendar"]').exists('the calendar opens');
      assert.dom('[role="dialog"]').exists('the popover content is a dialog');
      assert
        .dom('[data-part="title"]')
        .hasText('January 2026', 'it opens on the selected month');
    });

    test('picking a day sets the value, closes, and restores focus', async function (assert) {
      const picked = cell<Date | null>(null);
      const onChange = (value: Date | null) => (picked.current = value);

      await render(
        <template>
          <DatePicker
            @label="Start"
            @defaultValue={{jan20}}
            @locale="en-US"
            @onChange={{onChange}}
          />
        </template>
      );

      await click('[data-part="input"]');
      await click('[data-part="day"][data-key="2026-01-22"]');

      assert.strictEqual(picked.current?.getDate(), 22, 'onChange fires');
      assert
        .dom('[data-component="calendar"]')
        .doesNotExist('single mode closes');
      assert.dom('[data-part="input"]').hasText('Jan 22, 2026');
      assert
        .dom('[data-part="input"]')
        .isFocused('focus returns to the trigger');
    });

    test('a controlled value does not change on its own', async function (assert) {
      await render(
        <template>
          <DatePicker @label="Start" @value={{jan20}} @locale="en-US" />
        </template>
      );

      await click('[data-part="input"]');
      await click('[data-part="day"][data-key="2026-01-22"]');

      assert
        .dom('[data-part="input"]')
        .hasText(
          'Jan 20, 2026',
          'the trigger still shows the controlled value'
        );
    });

    test('escape closes and returns focus to the trigger', async function (assert) {
      await render(
        <template>
          <DatePicker @label="Start" @defaultValue={{jan20}} @locale="en-US" />
        </template>
      );

      await click('[data-part="input"]');
      await triggerKeyEvent('[data-component="calendar"]', 'keydown', 'Escape');

      assert.dom('[data-component="calendar"]').doesNotExist();
      assert.dom('[data-part="input"]').isFocused();
    });

    test('opening moves focus onto the selected day', async function (assert) {
      await render(
        <template>
          <DatePicker @label="Start" @defaultValue={{jan20}} @locale="en-US" />
        </template>
      );

      await click('[data-part="input"]');

      assert.dom('[data-part="day"][data-key="2026-01-20"]').isFocused();
    });

    test('min and max bounds reach the calendar', async function (assert) {
      const min = new Date(2026, 0, 15);
      const max = new Date(2026, 0, 25);
      const picked = cell<Date | null>(null);
      const onChange = (value: Date | null) => (picked.current = value);

      await render(
        <template>
          <DatePicker
            @label="Start"
            @defaultValue={{jan20}}
            @locale="en-US"
            @minValue={{min}}
            @maxValue={{max}}
            @onChange={{onChange}}
          />
        </template>
      );

      await click('[data-part="input"]');

      // Calendar deliberately never sets the native `disabled` attribute on a
      // day button -- a disabled day must stay focusable so the grid can
      // still be read and navigated with the keyboard (see Calendar's own
      // `@isDisabled`/`@isReadOnly` docs). It signals the state with
      // `data-disabled`/`aria-disabled` instead, exactly as Calendar's own
      // test suite asserts.
      assert
        .dom('[data-part="day"][data-key="2026-01-10"]')
        .hasAttribute('data-disabled', 'true');
      assert
        .dom('[data-part="day"][data-key="2026-01-20"]')
        .hasAttribute('data-disabled', 'false');

      // Attribute presence alone doesn't prove the day is unselectable
      // through DatePicker's own wiring -- click it and confirm handleChange
      // and close() are never reached.
      await click('[data-part="day"][data-key="2026-01-10"]');

      assert.strictEqual(
        picked.current,
        null,
        'clicking an out-of-range day does not fire onChange'
      );
      assert
        .dom('[data-part="input"]')
        .hasText('Jan 20, 2026', 'the trigger text is unchanged');
      assert
        .dom('[data-component="calendar"]')
        .exists('the popover stays open');
    });

    test('isDateUnavailable reaches the calendar', async function (assert) {
      // Every Sunday is unavailable. 2026-01-25 is a Sunday; 2026-01-26 is not.
      const isDateUnavailable = (date: Date) => date.getDay() === 0;

      await render(
        <template>
          <DatePicker
            @label="Start"
            @defaultValue={{jan20}}
            @locale="en-US"
            @isDateUnavailable={{isDateUnavailable}}
          />
        </template>
      );

      await click('[data-part="input"]');

      assert
        .dom('[data-part="day"][data-key="2026-01-25"]')
        .hasAttribute('data-disabled', 'true');
      assert
        .dom('[data-part="day"][data-key="2026-01-26"]')
        .hasAttribute('data-disabled', 'false');
    });

    test('range mode renders both ends in the trigger', async function (assert) {
      const range = { start: new Date(2026, 0, 20), end: new Date(2026, 1, 9) };

      await render(
        <template>
          <DatePicker
            @label="Stay"
            @mode="range"
            @value={{range}}
            @locale="en-US"
          />
        </template>
      );

      assert.dom('[data-part="input"]').hasText('Jan 20, 2026 – Feb 9, 2026');
    });

    test('range mode stays open until both ends are chosen', async function (assert) {
      const seen = cell<string>('');
      const onChange = (value: { start: Date; end: Date | null } | null) => {
        seen.current = `${value?.start.getDate()}-${value?.end?.getDate() ?? 'null'}`;
      };

      await render(
        <template>
          <DatePicker
            @label="Stay"
            @mode="range"
            @defaultValue={{janAnchor}}
            @locale="en-US"
            @onChange={{onChange}}
          />
        </template>
      );

      await click('[data-part="input"]');
      await click('[data-part="day"][data-key="2026-01-20"]');

      assert
        .dom('[data-component="calendar"]')
        .exists('still open after the anchor');
      assert.strictEqual(seen.current, '20-null', 'the anchor is reported');

      await click('[data-part="day"][data-key="2026-01-25"]');

      assert.strictEqual(seen.current, '20-25', 'both ends are reported');
      assert
        .dom('[data-component="calendar"]')
        .doesNotExist('closes once the range is complete');
      assert.dom('[data-part="input"]').isFocused();
    });

    test('range mode shows the anchor alone while mid-selection', async function (assert) {
      await render(
        <template>
          <DatePicker
            @label="Stay"
            @mode="range"
            @defaultValue={{janAnchor}}
            @locale="en-US"
          />
        </template>
      );

      await click('[data-part="input"]');
      await click('[data-part="day"][data-key="2026-01-20"]');

      assert
        .dom('[data-part="input"]')
        .hasText('Jan 20, 2026', 'no trailing dash, no placeholder');
    });

    test('range mode accepts string ends', async function (assert) {
      const range = { start: '2026-01-20', end: '2026-02-09' };

      await render(
        <template>
          <DatePicker
            @label="Stay"
            @mode="range"
            @value={{range}}
            @locale="en-US"
          />
        </template>
      );

      assert.dom('[data-part="input"]').hasText('Jan 20, 2026 – Feb 9, 2026');
    });

    test('single mode submits one input under the given name', async function (assert) {
      const submitted = cell<Record<string, unknown> | null>(null);
      const onSubmit = ({ data }: { data: Record<string, unknown> }) => {
        submitted.current = data;
      };

      await render(
        <template>
          <Form @onSubmit={{onSubmit}}>
            <DatePicker @label="Start" @name="start" @defaultValue={{jan20}} />
            <button type="submit">Save</button>
          </Form>
        </template>
      );

      await click('button[type="submit"]');

      assert.deepEqual(
        submitted.current,
        { start: '2026-01-20' },
        'the wire value is yyyy-MM-dd'
      );
    });

    test('range mode submits dotted names that unflatten to an object', async function (assert) {
      const submitted = cell<Record<string, unknown> | null>(null);
      const onSubmit = ({ data }: { data: Record<string, unknown> }) => {
        submitted.current = data;
      };
      const range = { start: new Date(2026, 0, 20), end: new Date(2026, 1, 9) };

      await render(
        <template>
          <Form @onSubmit={{onSubmit}}>
            <DatePicker
              @label="Stay"
              @mode="range"
              @name="stay"
              @defaultValue={{range}}
            />
            <button type="submit">Save</button>
          </Form>
        </template>
      );

      await click('button[type="submit"]');

      assert.deepEqual(
        submitted.current,
        { stay: { start: '2026-01-20', end: '2026-02-09' } },
        'Form unflattens the dotted names into one object'
      );
    });

    test('an empty value submits an empty string', async function (assert) {
      const submitted = cell<Record<string, unknown> | null>(null);
      const onSubmit = ({ data }: { data: Record<string, unknown> }) => {
        submitted.current = data;
      };

      await render(
        <template>
          <Form @onSubmit={{onSubmit}}>
            <DatePicker @label="Start" @name="start" />
            <button type="submit">Save</button>
          </Form>
        </template>
      );

      await click('button[type="submit"]');

      assert.deepEqual(submitted.current, { start: '' });
    });

    test('a late-evening date submits the same calendar day', async function (assert) {
      const submitted = cell<Record<string, unknown> | null>(null);
      const onSubmit = ({ data }: { data: Record<string, unknown> }) => {
        submitted.current = data;
      };
      // 23:30 local — toISOString() would report the next day in many zones.
      const late = new Date(2026, 0, 20, 23, 30);

      await render(
        <template>
          <Form @onSubmit={{onSubmit}}>
            <DatePicker @label="Start" @name="start" @defaultValue={{late}} />
            <button type="submit">Save</button>
          </Form>
        </template>
      );

      await click('button[type="submit"]');

      assert.deepEqual(submitted.current, { start: '2026-01-20' });
    });

    test('no name renders no hidden input', async function (assert) {
      await render(
        <template>
          <DatePicker @label="Start" @defaultValue={{jan20}} />
        </template>
      );

      assert.dom('input[type="hidden"]').doesNotExist();
    });

    test('the footer block renders presets that set the value and close', async function (assert) {
      await render(
        <template>
          <DatePicker @label="Start" @defaultValue={{jan20}} @locale="en-US">
            <:footer as |f|>
              <button
                type="button"
                data-test-preset
                {{on "click" (fn f.setValue (Date_ 2026 0 31))}}
              >End of month</button>
              <span data-test-open>{{if f.isOpen "open" "closed"}}</span>
            </:footer>
          </DatePicker>
        </template>
      );

      await click('[data-part="input"]');

      assert.dom('[data-part="footer"]').exists('the footer renders its slot');
      assert.dom('[data-test-open]').hasText('open');

      await click('[data-test-preset]');

      assert.dom('[data-part="input"]').hasText('Jan 31, 2026');
      assert
        .dom('[data-component="calendar"]')
        .doesNotExist('setValue with a complete value closes');
    });

    test('the calendar block replaces the default calendar', async function (assert) {
      await render(
        <template>
          <DatePicker @label="Start" @defaultValue={{jan20}} @locale="en-US">
            <:calendar as |args|>
              <div data-test-custom>{{args.mode}}</div>
            </:calendar>
          </DatePicker>
        </template>
      );

      await click('[data-part="input"]');

      assert.dom('[data-test-custom]').hasText('single');
      assert
        .dom('[data-component="calendar"]')
        .doesNotExist('the default calendar is replaced, not supplemented');
    });

    test('the value block owns the trigger content and names the button', async function (assert) {
      await render(
        <template>
          <DatePicker @label="Start" @value={{jan20}} @locale="en-US">
            <:value as |v|>
              <span data-test-custom-value>{{v.formatted}}!</span>
            </:value>
          </DatePicker>
        </template>
      );

      assert.dom('[data-test-custom-value]').hasText('Jan 20, 2026!');
      assert
        .dom('[data-part="input"]')
        .hasAttribute(
          'aria-label',
          'Start, Jan 20, 2026',
          'the block may render nothing readable, so the button is named explicitly'
        );
    });

    test('isClearable shows a clear button that empties the value', async function (assert) {
      const cleared = cell(false);
      const onChange = (value: Date | null) => {
        if (value === null) cleared.current = true;
      };

      await render(
        <template>
          <DatePicker
            @label="Start"
            @placeholder="Pick a date"
            @defaultValue={{jan20}}
            @locale="en-US"
            @isClearable={{true}}
            @onChange={{onChange}}
          />
        </template>
      );

      await click('[data-part="clear-button"]');

      assert.true(cleared.current, 'onChange is called with null');
      assert.dom('[data-part="input"]').hasText('Pick a date');
    });

    test('no clear button without a value or when disabled', async function (assert) {
      await render(
        <template><DatePicker @label="Start" @isClearable={{true}} /></template>
      );
      assert.dom('[data-part="clear-button"]').doesNotExist('nothing to clear');

      await render(
        <template>
          <DatePicker
            @label="Start"
            @defaultValue={{jan20}}
            @isClearable={{true}}
            @isDisabled={{true}}
          />
        </template>
      );
      assert
        .dom('[data-part="clear-button"]')
        .doesNotExist('a disabled field offers no clear button');
    });

    test('onBlur does not fire when focus moves into the calendar', async function (assert) {
      const blurs = cell(0);
      const onBlur = () => blurs.current++;

      await render(
        <template>
          <DatePicker
            @label="Start"
            @defaultValue={{jan20}}
            @locale="en-US"
            @onBlur={{onBlur}}
          />
        </template>
      );

      await click('[data-part="input"]');

      assert.strictEqual(
        blurs.current,
        0,
        'entering the popover is not leaving the control'
      );
    });

    test('Field yields a bound DatePicker', async function (assert) {
      const submitted = cell<Record<string, unknown> | null>(null);
      const onSubmit = ({ data }: { data: Record<string, unknown> }) => {
        submitted.current = data;
      };

      await render(
        <template>
          <Form @onSubmit={{onSubmit}} as |form|>
            <form.Field @name="start" as |field|>
              <field.DatePicker @label="Start" @defaultValue={{jan20}} />
            </form.Field>
            <button type="submit">Save</button>
          </Form>
        </template>
      );

      await click('button[type="submit"]');

      assert.deepEqual(submitted.current, { start: '2026-01-20' });
    });

    test('Field yields a bound DateRangePicker that round-trips form data', async function (assert) {
      const submitted = cell<Record<string, unknown> | null>(null);
      const onSubmit = ({ data }: { data: Record<string, unknown> }) => {
        submitted.current = data;
      };
      const initial = { stay: { start: '2026-01-20', end: '2026-02-09' } };

      await render(
        <template>
          <Form @data={{initial}} @onSubmit={{onSubmit}} as |form|>
            <form.Field @name="stay" as |field|>
              <field.DateRangePicker @label="Stay" @locale="en-US" />
            </form.Field>
            <button type="submit">Save</button>
          </Form>
        </template>
      );

      assert
        .dom('[data-part="input"]')
        .hasText(
          'Jan 20, 2026 – Feb 9, 2026',
          'form data strings are parsed back into the trigger'
        );

      await click('button[type="submit"]');

      assert.deepEqual(submitted.current, {
        stay: { start: '2026-01-20', end: '2026-02-09' }
      });
    });
  }
);
