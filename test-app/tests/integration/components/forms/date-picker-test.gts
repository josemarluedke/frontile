import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  click,
  find,
  findAll,
  focus,
  settled,
  triggerEvent,
  triggerKeyEvent
} from '@ember/test-helpers';
import { cell } from 'ember-resources';
import { trackDeprecations } from '../../../helpers/deprecations';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import { DatePicker, Form } from 'frontile';

const jan20 = new Date(2026, 0, 20);
const janAnchor = { start: new Date(2026, 0, 5), end: new Date(2026, 0, 6) };

// `Date` is not a template helper; a plain function stands in.
const Date_ = (y: number, m: number, d: number) => new Date(y, m, d);

/**
 * The submit capture every Form test here needs, so each test is left with
 * only the render and the assertions that make it distinct.
 */
function captureSubmit(): {
  submitted: ReturnType<typeof cell<Record<string, unknown> | null>>;
  onSubmit: (result: { data: Record<string, unknown> }) => void;
} {
  const submitted = cell<Record<string, unknown> | null>(null);
  return {
    submitted,
    onSubmit: ({ data }) => {
      submitted.current = data;
    }
  };
}

/**
 * The segmented trigger's displayed value. Each non-year segment renders at
 * its full width, so a month reads "01" rather than "1", and an empty one
 * reads its placeholder ("mm", "dd", "yyyy").
 */
function segmentText(): { month?: string; day?: string; year?: string } {
  const read = (type: string) =>
    find(`[data-part="segment"][data-type="${type}"]`)?.textContent?.trim();

  return { month: read('month'), day: read('day'), year: read('year') };
}

module(
  'Integration | Component | DatePicker | frontile/forms',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders the field with a label and a placeholder', async function (assert) {
      await render(
        <template>
          <DatePicker
            @label="Start date"
            @placeholder="Pick a date"
            @isEditable={{false}}
          />
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
            @isEditable={{false}}
          />
        </template>
      );

      assert.dom('[data-part="input"]').hasText('Jan 20, 2026');
      assert.dom('[data-part="placeholder"]').doesNotExist();
    });

    test('it accepts a yyyy-MM-dd string value', async function (assert) {
      // Kept on the default (segmented) path: parsing a wire string into a
      // value is the same contract either way, and this is the path a
      // consumer gets without opting out.
      await render(
        <template>
          <DatePicker @label="Start" @value="2026-01-20" @locale="en-US" />
        </template>
      );

      assert.deepEqual(
        segmentText(),
        { month: '01', day: '20', year: '2026' },
        'the string is parsed into the segments'
      );
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
            @isEditable={{false}}
          />
        </template>
      );

      assert.dom('[data-part="input"]').hasText('Tuesday, January 20, 2026');
    });

    test('it reflects disabled and invalid state on the trigger', async function (assert) {
      const errors = ['Required'];

      await render(
        <template>
          <DatePicker
            @label="Start"
            @isDisabled={{true}}
            @errors={{errors}}
            @isEditable={{false}}
          />
        </template>
      );

      assert.dom('[data-part="input"]').isDisabled();
      assert.dom('[data-part="input"]').hasAttribute('data-invalid', 'true');
      assert.dom('[data-part="input"]').hasAttribute('data-disabled', 'true');
    });

    test('it reflects disabled and invalid state on the segments', async function (assert) {
      const errors = ['Required'];

      await render(
        <template>
          <DatePicker @label="Start" @isDisabled={{true}} @errors={{errors}} />
        </template>
      );

      // There is no <button> to carry the state on this path. It lands on the
      // field shell (the inner container, which draws the border) and on the
      // segments themselves -- `role="group"` supports neither aria-invalid
      // nor aria-disabled as a styling hook, so the group mirrors it as data.
      assert
        .dom('[data-part="inner-container"]')
        .hasAttribute('data-invalid', 'true');
      assert
        .dom('[data-part="inner-container"]')
        .hasAttribute('data-disabled', 'true');
      assert.dom('[data-part="group"]').hasAttribute('data-invalid', 'true');
      assert.dom('[data-part="group"]').hasAttribute('aria-disabled', 'true');
      assert
        .dom('[data-part="segment"][data-type="month"]')
        .hasAttribute('aria-invalid', 'true');
      assert
        .dom('[data-part="segment"][data-type="month"]')
        .doesNotHaveAttribute(
          'tabindex',
          'a disabled field takes no keyboard focus'
        );
    });

    test('clicking the trigger opens a calendar in a dialog', async function (assert) {
      await render(
        <template>
          <DatePicker
            @label="Start"
            @defaultValue={{jan20}}
            @locale="en-US"
            @isEditable={{false}}
          />
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
            @isEditable={{false}}
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

    test('@value is pushed into the field whenever it changes', async function (assert) {
      const external = cell<Date>(jan20);

      await render(
        <template>
          <DatePicker
            @label="Start"
            @value={{external.current}}
            @locale="en-US"
          />
        </template>
      );

      assert.deepEqual(segmentText(), {
        month: '01',
        day: '20',
        year: '2026'
      });

      external.current = new Date(2026, 1, 14);
      await settled();

      assert.deepEqual(
        segmentText(),
        { month: '02', day: '14', year: '2026' },
        'a new @value replaces what is displayed'
      );
    });

    test('picking a date updates the field without waiting for @value', async function (assert) {
      // The field renders its own state and treats @value as something to
      // sync *from*, the way Select does -- it does not read through to the
      // argument. Reading through deadlocks it inside a Form, where @value is
      // bound to data this component is itself the only source of.
      const seen = cell<Date | null>(null);
      const onChange = (value: Date | null) => (seen.current = value);

      await render(
        <template>
          <DatePicker
            @label="Start"
            @value={{jan20}}
            @locale="en-US"
            @onChange={{onChange}}
          />
        </template>
      );

      await click('[data-part="calendar-button"]');
      await click('[data-part="day"][data-key="2026-01-22"]');

      assert.strictEqual(seen.current?.getDate(), 22, 'onChange still fires');
      assert.deepEqual(
        segmentText(),
        { month: '01', day: '22', year: '2026' },
        'the field moved although @value is pinned to the 20th'
      );
    });

    test('escape closes and returns focus to the trigger', async function (assert) {
      await render(
        <template>
          <DatePicker
            @label="Start"
            @defaultValue={{jan20}}
            @locale="en-US"
            @isEditable={{false}}
          />
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

      await click('[data-part="calendar-button"]');

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

      await click('[data-part="calendar-button"]');

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
      assert.deepEqual(
        segmentText(),
        { month: '01', day: '20', year: '2026' },
        'the displayed value is unchanged'
      );
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

      await click('[data-part="calendar-button"]');

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
            @isEditable={{false}}
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
            @isEditable={{false}}
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
            @isEditable={{false}}
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

      // The default trigger is segmented, so each end is read from its own
      // group rather than from one formatted string.
      const ends = findAll('[data-part="group"]').map((group) =>
        Array.from(group.querySelectorAll('[data-part="segment"]'))
          .map((segment) => segment.textContent?.trim())
          .join('/')
      );

      assert.deepEqual(ends, ['01/20/2026', '02/09/2026']);
    });

    test('single mode submits one input under the given name', async function (assert) {
      const { submitted, onSubmit } = captureSubmit();

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
      const { submitted, onSubmit } = captureSubmit();
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
      const { submitted, onSubmit } = captureSubmit();

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
      const { submitted, onSubmit } = captureSubmit();
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

      await click('[data-part="calendar-button"]');

      assert.dom('[data-part="footer"]').exists('the footer renders its slot');
      assert.dom('[data-test-open]').hasText('open');

      await click('[data-test-preset]');

      assert.deepEqual(
        segmentText(),
        { month: '01', day: '31', year: '2026' },
        'f.setValue writes the field'
      );
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

      await click('[data-part="calendar-button"]');

      assert.dom('[data-test-custom]').hasText('single');
      assert
        .dom('[data-component="calendar"]')
        .doesNotExist('the default calendar is replaced, not supplemented');
    });

    test('the value block owns the trigger content and names the button', async function (assert) {
      await render(
        <template>
          <DatePicker
            @label="Start"
            @value={{jan20}}
            @locale="en-US"
            @isEditable={{false}}
          >
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
      assert.deepEqual(
        segmentText(),
        { month: 'mm', day: 'dd', year: 'yyyy' },
        'and the segments fall back to their placeholders'
      );
    });

    test('the clear button restores the placeholder on the button trigger', async function (assert) {
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
            @isEditable={{false}}
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

    test('no clear button on a read-only field', async function (assert) {
      await render(
        <template>
          <DatePicker
            @label="Start"
            @defaultValue={{jan20}}
            @isClearable={{true}}
            @isReadOnly={{true}}
          />
        </template>
      );

      assert
        .dom('[data-part="clear-button"]')
        .doesNotExist('a read-only field offers no clear button either');
    });

    test('clearing while the popover is open keeps focus on the trigger', async function (assert) {
      await render(
        <template>
          <DatePicker
            @label="Start"
            @defaultValue={{jan20}}
            @locale="en-US"
            @isClearable={{true}}
            @isEditable={{false}}
          />
        </template>
      );

      await click('[data-part="input"]');
      assert.dom('[data-component="calendar"]').exists('the calendar is open');

      await click('[data-part="clear-button"]');

      assert.dom('[data-part="clear-button"]').doesNotExist('value is cleared');
      assert
        .dom('[data-part="input"]')
        .isFocused('focus lands on the trigger, not <body>');
      assert.notStrictEqual(
        document.activeElement,
        document.body,
        'focus does not fall to <body>'
      );
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
            @isEditable={{false}}
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
      const { submitted, onSubmit } = captureSubmit();

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
      const { submitted, onSubmit } = captureSubmit();
      const initial = { stay: { start: '2026-01-20', end: '2026-02-09' } };

      await render(
        <template>
          <Form @data={{initial}} @onSubmit={{onSubmit}} as |form|>
            <form.Field @name="stay" as |field|>
              <field.DateRangePicker
                @label="Stay"
                @locale="en-US"
                @isEditable={{false}}
              />
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
    test('the end-content cluster lets clicks fall through to the trigger', async function (assert) {
      await render(
        <template>
          <DatePicker
            @label="Start"
            @placeholder="Pick a date"
            @isEditable={{false}}
          />
        </template>
      );

      // The cluster is absolutely positioned over the right edge of the field.
      // With pointer events on, it swallows the click and the calendar icon
      // becomes a dead zone -- the picker will not open when you click it.
      assert.strictEqual(
        getComputedStyle(find('[data-part="end-content"]')!).pointerEvents,
        'none',
        'the cluster is transparent to pointer events'
      );
      assert.strictEqual(
        getComputedStyle(find('[data-part="icon"]')!).pointerEvents,
        'none',
        'so is the calendar icon inside it'
      );
    });

    test('the clear button stays clickable inside the transparent cluster', async function (assert) {
      await render(
        <template>
          <DatePicker
            @label="Start"
            @defaultValue={{jan20}}
            @isClearable={{true}}
            @isEditable={{false}}
          />
        </template>
      );

      // Only meaningful on the button-trigger path: that is the one whose
      // cluster is `pointer-events: none`, so this is where the clear button
      // has something to opt back out of. On the segmented path the whole
      // cluster is clickable already.
      assert.strictEqual(
        getComputedStyle(find('[data-part="end-content"]')!).pointerEvents,
        'none',
        'the surrounding cluster is transparent'
      );
      assert.strictEqual(
        getComputedStyle(find('[data-part="clear-button"]')!).pointerEvents,
        'auto',
        'the clear button opts back in, or it could never be clicked'
      );
    });

    test('the popover sizes to the calendar rather than a fixed width', async function (assert) {
      await render(
        <template><DatePicker @label="Start" @locale="en-US" /></template>
      );

      await click('[data-part="calendar-button"]');

      const content = find('[data-component="calendar"]')!.parentElement!;

      // Popover.Content defaults to `md` (w-64, 256px), which is narrower
      // than the calendar grid and clips the Saturday column. `auto` sizes to
      // the content instead, which also absorbs @visibleMonths changing the
      // calendar's width.
      //
      // Asserted as the applied class rather than by measuring: #ember-testing
      // is a narrow container, and an absolutely-positioned `width: auto` box
      // shrink-to-fits against available width, so the measured width here
      // reflects the test container rather than the rule under test.
      assert.dom(content).hasClass('w-auto', 'sized to its content');
      assert
        .dom(content)
        .doesNotHaveClass('w-64', 'not the default fixed size');
    });

    test('a consumer can still override the popover size', async function (assert) {
      await render(
        <template>
          <DatePicker @label="Start" @locale="en-US" @popoverSize="lg" />
        </template>
      );

      await click('[data-part="calendar-button"]');

      assert
        .dom(find('[data-component="calendar"]')!.parentElement)
        .hasClass('w-96', '@popoverSize is forwarded to the popover content');
    });
    test('a Field-bound range keeps working after a submit', async function (assert) {
      const { submitted, onSubmit } = captureSubmit();

      await render(
        <template>
          <Form @onSubmit={{onSubmit}} as |form|>
            <form.Field @name="stay" as |field|>
              <field.DateRangePicker
                @label="Stay"
                @locale="en-US"
                @isEditable={{false}}
                @defaultValue={{janAnchor}}
              />
            </form.Field>
            <button type="submit">Save</button>
          </Form>
        </template>
      );

      // Submitting puts data in the Form, which Field then binds back to
      // @value -- from that point the picker counts as controlled.
      await click('button[type="submit"]');
      assert.deepEqual(
        submitted.current,
        { stay: { start: '2026-01-05', end: '2026-01-06' } },
        'the seeded range submits'
      );

      // Picking a new range must still work. It only can if the component
      // tells the Form its value moved -- the hidden inputs are written
      // programmatically and fire no input event of their own.
      await click('[data-part="input"]');
      await click('[data-part="day"][data-key="2026-01-20"]');
      await click('[data-part="day"][data-key="2026-01-25"]');

      assert
        .dom('[data-part="input"]')
        .hasText('Jan 20, 2026 – Jan 25, 2026', 'the new range took effect');

      await click('button[type="submit"]');

      assert.deepEqual(
        submitted.current,
        { stay: { start: '2026-01-20', end: '2026-01-25' } },
        'and it is what submits'
      );
    });

    test('an empty trigger is as tall as one showing a value', async function (assert) {
      await render(
        <template>
          <div data-test-empty>
            <DatePicker @label="Empty" @isEditable={{false}} />
          </div>
          <div data-test-filled>
            <DatePicker
              @label="Filled"
              @value={{jan20}}
              @locale="en-US"
              @isEditable={{false}}
            />
          </div>
        </template>
      );

      // The trigger is a <button> whose text is the value, so with neither a
      // value nor a @placeholder it has no content to give it height.
      const empty = find('[data-test-empty] [data-part="input"]')!;
      const filled = find('[data-test-filled] [data-part="input"]')!;

      assert.strictEqual(
        empty.getBoundingClientRect().height,
        filled.getBoundingClientRect().height,
        'an empty field does not collapse'
      );
    });
    test('raises no deprecations', async function (assert) {
      // DatePicker is new in 0.18, so it has nothing to be deprecated from.
      // Any id here means it is calling a sibling through a renamed argument
      // or a renamed value -- the CloseButton in its end-content cluster and
      // the Button in its docs demo both have deprecated spellings that still
      // work, so nothing else would catch it.
      const { ids } = trackDeprecations();

      await render(
        <template>
          <DatePicker
            @label="Start"
            @defaultValue={{jan20}}
            @locale="en-US"
            @isClearable={{true}}
          />
        </template>
      );

      await click('[data-part="calendar-button"]');
      await click('[data-part="day"][data-key="2026-01-22"]');

      assert.deepEqual(ids, [], `no deprecations, got: ${ids.join(', ')}`);
    });
    test('@color reaches the calendar', async function (assert) {
      await render(
        <template>
          <DatePicker
            @label="Start"
            @defaultValue={{jan20}}
            @locale="en-US"
            @color="success"
          />
        </template>
      );

      await click('[data-part="calendar-button"]');

      // Calendar colors the selected day and the range band from @color, as
      // utility classes rather than a marker class -- so this asserts the
      // colour is present rather than pinning the exact spelling.
      const day = find('[data-part="day"][data-key="2026-01-20"]')!;

      assert.ok(
        day.className.includes('success'),
        `the selected day is coloured by @color, got: ${day.className}`
      );
      assert.notOk(
        day.className.includes('bg-primary'),
        'and no longer carries the default primary'
      );
    });

    test('the calendar block arg carries @color', async function (assert) {
      await render(
        <template>
          <DatePicker @label="Start" @locale="en-US" @color="danger">
            <:calendar as |args|>
              <div data-test-color>{{args.color}}</div>
            </:calendar>
          </DatePicker>
        </template>
      );

      await click('[data-part="calendar-button"]');

      assert
        .dom('[data-test-color]')
        .hasText('danger', 'so a custom calendar can spread it');
    });
  }
);

module(
  'Integration | Component | DatePicker | segmented trigger',
  function (hooks) {
    setupRenderingTest(hooks);

    /** The focused segment, which every typing test types into. */
    function active(): Element {
      return document.activeElement as Element;
    }

    async function type(digits: string): Promise<void> {
      for (const digit of digits) {
        await triggerKeyEvent(active(), 'keydown', digit);
      }
    }

    test('renders segments by default, not a button trigger', async function (assert) {
      await render(
        <template><DatePicker @label="Start date" @locale="en-US" /></template>
      );

      assert.dom('[data-part="segment"]').exists({ count: 3 });
      assert
        .dom('button[data-part="input"]')
        .doesNotExist('the old trigger is gone');
    });

    test('@isEditable={{false}} restores the button trigger', async function (assert) {
      await render(
        <template>
          <DatePicker
            @label="Start date"
            @locale="en-US"
            @isEditable={{false}}
          />
        </template>
      );

      assert.dom('button[data-part="input"]').exists();
      assert.dom('[data-part="segment"]').doesNotExist();
    });

    test('the calendar button opens the popover', async function (assert) {
      await render(
        <template><DatePicker @label="Start date" @locale="en-US" /></template>
      );

      assert.dom('[role="dialog"]').doesNotExist();
      await click('[data-part="calendar-button"]');
      assert
        .dom('[role="dialog"]')
        .exists('typing and opening are separate gestures');
    });

    test('typing does not open the popover', async function (assert) {
      await render(
        <template><DatePicker @label="Start date" @locale="en-US" /></template>
      );

      await focus(
        find('[data-part="segment"][data-type="month"]') as HTMLElement
      );
      await type('1');

      assert.dom('[role="dialog"]').doesNotExist();
      // Padded, because a non-year segment always renders at its full width.
      assert.dom('[data-part="segment"][data-type="month"]').hasText('01');
    });

    test('@value writes the segments', async function (assert) {
      const value = new Date(2026, 0, 20);

      await render(
        <template>
          <DatePicker @label="Start date" @locale="en-US" @value={{value}} />
        </template>
      );

      assert.dom('[data-part="segment"][data-type="month"]').hasText('01');
      assert.dom('[data-part="segment"][data-type="day"]').hasText('20');
      assert.dom('[data-part="segment"][data-type="year"]').hasText('2026');
    });

    test('picking a day writes the segments', async function (assert) {
      await render(
        <template>
          <DatePicker
            @label="Start date"
            @locale="en-US"
            @defaultValue={{jan20}}
          />
        </template>
      );

      await click('[data-part="calendar-button"]');
      await click('[data-part="day"][data-key="2026-01-22"]');

      assert.dom('[data-part="segment"][data-type="month"]').hasText('01');
      assert.dom('[data-part="segment"][data-type="day"]').hasText('22');
      assert.dom('[data-part="segment"][data-type="year"]').hasText('2026');
    });

    test('typing a complete date reports it and moves the calendar', async function (assert) {
      const received = cell<Date | null>(null);
      const onChange = (v: Date | null) => (received.current = v);

      await render(
        <template>
          <DatePicker
            @label="Start date"
            @locale="en-US"
            @onChange={{onChange}}
          />
        </template>
      );

      await focus(
        find('[data-part="segment"][data-type="month"]') as HTMLElement
      );
      await type('03152027');

      assert.strictEqual(received.current?.getFullYear(), 2027);
      assert.strictEqual(received.current?.getMonth(), 2);
      assert.strictEqual(received.current?.getDate(), 15);

      await click('[data-part="calendar-button"]');
      assert
        .dom('[role="dialog"]')
        .includesText('March', 'the calendar followed the typing');
    });

    test('typing on does not rewrite the segments underneath it', async function (assert) {
      const received = cell<Date | null | undefined>(undefined);
      const onChange = (v: Date | null) => (received.current = v);

      await render(
        <template>
          <DatePicker
            @label="Start date"
            @locale="en-US"
            @onChange={{onChange}}
          />
        </template>
      );

      await focus(
        find('[data-part="segment"][data-type="month"]') as HTMLElement
      );
      await type('03152027');

      // Retyping the year un-commits it, so the composed value drops back to
      // null -- a value change like any other. If that change wrote the
      // segments back, it would clear the month and day the user just typed
      // and replace the year they are mid-way through.
      await type('1');

      assert.strictEqual(
        received.current,
        null,
        'an incomplete date composes nothing'
      );
      assert.dom('[data-part="segment"][data-type="month"]').hasText('03');
      assert.dom('[data-part="segment"][data-type="day"]').hasText('15');
      assert.dom('[data-part="segment"][data-type="year"]').hasText('1');
    });

    test('Escape closes the popover and returns focus to the segment', async function (assert) {
      await render(
        <template><DatePicker @label="Start date" @locale="en-US" /></template>
      );

      // The year, not the month: the first segment is also the fallback, so
      // only a later one can show that the field remembers where focus was.
      const year = find(
        '[data-part="segment"][data-type="year"]'
      ) as HTMLElement;
      await focus(year);
      await click('[data-part="calendar-button"]');
      assert.dom('[role="dialog"]').exists();

      await triggerKeyEvent(active(), 'keydown', 'Escape');

      assert.dom('[role="dialog"]').doesNotExist();
      assert.strictEqual(
        document.activeElement,
        year,
        'focus returns to the segment the user was in, not to <body>'
      );
    });

    test('closing with no segment ever focused falls back to the first one', async function (assert) {
      await render(
        <template>
          <DatePicker
            @label="Start date"
            @locale="en-US"
            @defaultValue={{jan20}}
          />
        </template>
      );

      await click('[data-part="calendar-button"]');
      await click('[data-part="day"][data-key="2026-01-22"]');

      assert
        .dom('[role="dialog"]')
        .doesNotExist('a complete pick closes the popover');
      assert.strictEqual(
        document.activeElement,
        find('[data-part="segment"][data-type="month"]'),
        'focus lands on the first segment rather than <body>'
      );
    });

    test('clearing empties the segments and keeps focus in the field', async function (assert) {
      const value = new Date(2026, 0, 20);

      await render(
        <template>
          <DatePicker
            @label="Start date"
            @locale="en-US"
            @value={{value}}
            @isClearable={{true}}
          />
        </template>
      );

      await click('[data-part="clear-button"]');

      assert.dom('[data-part="segment"][data-type="month"]').hasText('mm');
      assert.dom('[data-part="segment"][data-type="year"]').hasText('yyyy');
      assert.strictEqual(
        document.activeElement,
        find('[data-part="segment"][data-type="month"]'),
        'focus does not fall to <body> when the clear button disappears'
      );
    });

    test('a clearable field keeps its calendar button', async function (assert) {
      await render(
        <template>
          <DatePicker
            @label="Start date"
            @locale="en-US"
            @defaultValue={{jan20}}
            @isClearable={{true}}
          />
        </template>
      );

      // The clear button cannot take the calendar button's place here the way
      // it does on the button-trigger path: nothing else opens the popover, so
      // a clearable picker holding a value would stop being a picker.
      assert
        .dom('[data-part="clear-button"]')
        .exists('both controls are present');
      assert.dom('[data-part="calendar-button"]').exists();

      await click('[data-part="calendar-button"]');
      assert
        .dom('[role="dialog"]')
        .exists('the calendar still opens with a value set');
    });

    test('@isEditable={{false}} still swaps the icon for the clear button', async function (assert) {
      await render(
        <template>
          <DatePicker
            @label="Start date"
            @locale="en-US"
            @defaultValue={{jan20}}
            @isClearable={{true}}
            @isEditable={{false}}
          />
        </template>
      );

      // On that path the trigger itself opens the popover, so the icon is
      // decorative and the either/or costs nothing.
      assert.dom('[data-part="clear-button"]').exists();
      // Not `[data-part="icon"]`: CloseButton renders one of its own, so the
      // absence of the *calendar* is what the either/or actually says.
      assert
        .dom('[data-part="calendar-button"]')
        .doesNotExist('the calendar icon gave way to the clear button');
    });

    test('no clear button on a disabled or a read-only field', async function (assert) {
      await render(
        <template>
          <DatePicker
            @label="Start date"
            @locale="en-US"
            @defaultValue={{jan20}}
            @isClearable={{true}}
            @isDisabled={{true}}
          />
        </template>
      );

      assert
        .dom('[data-part="clear-button"]')
        .doesNotExist('a disabled field offers nothing to press');
      assert
        .dom('[data-part="calendar-button"]')
        .exists('the calendar button stays');
      assert.dom('[data-part="calendar-button"]').isDisabled();

      await render(
        <template>
          <DatePicker
            @label="Start date"
            @locale="en-US"
            @defaultValue={{jan20}}
            @isClearable={{true}}
            @isReadOnly={{true}}
          />
        </template>
      );

      assert
        .dom('[data-part="clear-button"]')
        .doesNotExist('nor does a read-only one, which may not be changed');
      assert
        .dom('[data-part="calendar-button"]')
        .exists('but it can still be read');
    });

    test('a typed date reaches an enclosing Form', async function (assert) {
      const { submitted, onSubmit } = captureSubmit();

      await render(
        <template>
          <Form @onSubmit={{onSubmit}} as |form|>
            <form.Field @name="start" as |field|>
              <field.DatePicker @label="Start date" @locale="en-US" />
            </form.Field>
            <button type="submit">Save</button>
          </Form>
        </template>
      );

      await focus(
        find('[data-part="segment"][data-type="month"]') as HTMLElement
      );
      await type('03152027');
      await click('button[type="submit"]');

      assert.deepEqual(submitted.current, { start: '2027-03-15' });
    });

    test('the end-content cluster takes pointer events', async function (assert) {
      await render(
        <template><DatePicker @label="Start date" @locale="en-US" /></template>
      );

      // There is no button trigger underneath for a click to fall through to:
      // with pointer events off, the calendar button is a dead control and the
      // calendar cannot be opened at all.
      assert.strictEqual(
        getComputedStyle(find('[data-part="end-content"]') as Element)
          .pointerEvents,
        'auto',
        'the cluster is clickable on the segmented path'
      );
    });

    test('onBlur does not fire when focus moves from a segment into the calendar', async function (assert) {
      const blurs = cell(0);
      const onBlur = () => blurs.current++;

      await render(
        <template>
          <DatePicker
            @label="Start date"
            @locale="en-US"
            @defaultValue={{jan20}}
            @onBlur={{onBlur}}
          />
        </template>
      );

      await click('[data-part="calendar-button"]');
      assert.dom('[data-component="calendar"]').exists('the calendar is open');

      // The popover is portaled, so a day is not a DOM descendant of the
      // field: the blur tracker has to find the content through the element
      // the popover's trigger modifier sits on, which on this path is the
      // calendar button rather than the (absent) button trigger. Dispatched
      // rather than performed because reaching a day from a segment by hand
      // takes the focus through the button first.
      await triggerEvent('[data-part="group"]', 'focusout', {
        relatedTarget: find('[data-part="day"][data-key="2026-01-22"]')
      });

      assert.strictEqual(
        blurs.current,
        0,
        'entering the popover is not leaving the control'
      );
    });

    test('a textual @formatOptions falls back to numeric segments', async function (assert) {
      const options = { dateStyle: 'medium' } as Intl.DateTimeFormatOptions;

      await render(
        <template>
          <DatePicker
            @label="Date"
            @locale="en-US"
            @formatOptions={{options}}
          />
        </template>
      );

      assert.dom('[data-part="segment"]').exists({ count: 3 });
      // `{ dateStyle: 'medium' }` would lay the field out as "mmm dd, yyyy".
      // The fallback is the numeric default, separators and all.
      assert.dom('[data-part="literal"]').hasText('/');
      assert.dom('[data-part="segment"][data-type="month"]').hasText('mm');
    });
  }
);

module(
  'Integration | Component | DatePicker | range segments',
  function (hooks) {
    setupRenderingTest(hooks);

    /** The two `role="group"` elements, start first. */
    function groups(): HTMLElement[] {
      return findAll('[data-part="group"]') as HTMLElement[];
    }

    /** The first segment of one of them, which is where typing starts. */
    function firstSegment(which: 0 | 1): HTMLElement {
      return groups()[which]!.querySelector(
        '[data-part="segment"]'
      ) as HTMLElement;
    }

    function textOf(which: 0 | 1, type: string): string | undefined {
      return groups()
        [which]!.querySelector(`[data-part="segment"][data-type="${type}"]`)
        ?.textContent?.trim();
    }

    async function type(digits: string): Promise<void> {
      for (const digit of digits) {
        await triggerKeyEvent(
          document.activeElement as Element,
          'keydown',
          digit
        );
      }
    }

    test('renders two groups, a separator and six segments', async function (assert) {
      await render(
        <template>
          <DatePicker @mode="range" @label="Trip dates" @locale="en-US" />
        </template>
      );

      assert.dom('[data-part="group"]').exists({ count: 2 });
      assert.dom('[data-part="separator"]').exists({ count: 1 });
      assert.dom('[data-part="segment"]').exists({ count: 6 });
      assert
        .dom('button[data-part="input"]')
        .doesNotExist('range mode no longer forces the button trigger');
    });

    test('the two groups sit together rather than splitting the field', async function (assert) {
      // Both groups growing would leave the separator stranded mid-field with
      // dead space on either side of it, instead of reading as one
      // "start - end" phrase. Measured rather than asserted on class names, so
      // it survives the classes being renamed.
      await render(
        <template>
          <DatePicker @mode="range" @label="Trip dates" @locale="en-US" />
        </template>
      );

      const [start, end] = groups();

      // Each group must be exactly as wide as the segments inside it: too wide
      // and the separator is stranded mid-field, but zero-wide is the opposite
      // failure -- dropping only `grow` from `flex-1` leaves a 0% basis with
      // shrink still on, which collapses the group and overflows its segments.
      for (const group of [start!, end!]) {
        const segments = Array.from(
          group.querySelectorAll('[data-part="segment"], [data-part="literal"]')
        );
        const first = segments[0] as HTMLElement;
        const last = segments[segments.length - 1] as HTMLElement;
        const content =
          last.getBoundingClientRect().right -
          first.getBoundingClientRect().left;

        assert.ok(content > 0, 'the group has rendered content');
        assert.ok(
          Math.abs(group.getBoundingClientRect().width - content) < 4,
          `the group hugs its segments (group ${Math.round(
            group.getBoundingClientRect().width
          )}px vs content ${Math.round(content)}px)`
        );
      }

      const separator = find('[data-part="separator"]') as HTMLElement;
      const gap =
        separator.getBoundingClientRect().left -
        start!.getBoundingClientRect().right;

      assert.ok(
        gap < 4,
        `the separator follows the start group directly (gap was ${gap}px)`
      );
    });

    test('@isEditable={{false}} still restores the button trigger', async function (assert) {
      await render(
        <template>
          <DatePicker
            @mode="range"
            @isEditable={{false}}
            @label="Trip dates"
            @locale="en-US"
          />
        </template>
      );

      assert.dom('button[data-part="input"]').exists();
      assert.dom('[data-part="group"]').doesNotExist();
    });

    test('each group carries its own accessible name and id', async function (assert) {
      await render(
        <template>
          <DatePicker
            @mode="range"
            @label="Trip dates"
            @description="When you travel"
            @locale="en-US"
          />
        </template>
      );

      const [start, end] = groups();

      assert
        .dom(start)
        .hasAttribute(
          'aria-label',
          'Trip dates start',
          'the start group names itself from @label'
        );
      assert
        .dom(end)
        .hasAttribute(
          'aria-label',
          'Trip dates end',
          'and the end group differs from it'
        );

      const startId = start!.getAttribute('id');
      const endId = end!.getAttribute('id');
      assert.ok(startId, 'the start group has an id');
      assert.ok(endId, 'the end group has an id');
      assert.notStrictEqual(startId, endId, 'the two ids are distinct');
      assert.strictEqual(
        document.querySelectorAll(`#${CSS.escape(startId!)}`).length,
        1,
        'and each is unique in the document'
      );

      const describedBy = start!.getAttribute('aria-describedby');
      assert.ok(
        describedBy && find(`#${CSS.escape(describedBy.split(' ')[0]!)}`),
        'aria-describedby still reaches the description'
      );
      assert.strictEqual(
        end!.getAttribute('aria-describedby'),
        describedBy,
        'both groups are described by the same help text'
      );
    });

    test('a group with no @label is still named', async function (assert) {
      await render(
        <template><DatePicker @mode="range" @locale="en-US" /></template>
      );

      assert.dom(groups()[0]).hasAttribute('aria-label', 'start date');
      assert.dom(groups()[1]).hasAttribute('aria-label', 'end date');
    });

    test('typing both ends produces a range', async function (assert) {
      const seen = cell<{ start: Date; end: Date | null } | null>(null);
      const calls = cell(0);
      const onChange = (value: { start: Date; end: Date | null } | null) => {
        seen.current = value;
        calls.current = calls.current + 1;
      };

      await render(
        <template>
          <DatePicker
            @mode="range"
            @label="Trip dates"
            @locale="en-US"
            @onChange={{onChange}}
          />
        </template>
      );

      await focus(firstSegment(0));
      await type('01202026');

      assert.strictEqual(
        calls.current,
        1,
        'eight keystrokes, one report -- only the one that completed a date'
      );
      assert.strictEqual(
        seen.current?.start.getDate(),
        20,
        'the start is reported as soon as it composes'
      );
      assert.strictEqual(
        seen.current?.end,
        null,
        'with a half-open end, the shape the calendar produces mid-selection'
      );

      await focus(firstSegment(1));
      await type('01252026');

      assert.strictEqual(calls.current, 2, 'and one more for the second end');
      assert.strictEqual(seen.current?.start.getDate(), 20);
      assert.strictEqual(seen.current?.end?.getDate(), 25);
    });

    test('clearing the start reports null rather than keeping a stale range', async function (assert) {
      const seen = cell<{ start: Date; end: Date | null } | null>(null);
      const calls = cell(0);
      const onChange = (value: { start: Date; end: Date | null } | null) => {
        seen.current = value;
        calls.current = calls.current + 1;
      };
      const range = {
        start: new Date(2026, 0, 20),
        end: new Date(2026, 0, 25)
      };

      await render(
        <template>
          <DatePicker
            @mode="range"
            @label="Trip dates"
            @locale="en-US"
            @defaultValue={{range}}
            @onChange={{onChange}}
          />
        </template>
      );

      assert.strictEqual(textOf(0, 'day'), '20', 'the start group is seeded');
      assert.strictEqual(textOf(1, 'day'), '25', 'and so is the end group');

      const before = calls.current;
      await focus(firstSegment(0));
      await triggerKeyEvent(
        document.activeElement as Element,
        'keydown',
        'Delete'
      );

      assert.strictEqual(
        seen.current,
        null,
        'a range with no start is no range at all'
      );
      assert.strictEqual(
        calls.current,
        before + 1,
        'reported exactly once, on the transition'
      );
      assert.strictEqual(
        textOf(1, 'day'),
        '25',
        'the digits the user did not touch stay on screen'
      );

      // Clearing an already-empty segment is a keystroke that moves nothing.
      // Without a transition check every one of them would report `null`
      // again, and a consumer would see churn for input it already has.
      await triggerKeyEvent(
        document.activeElement as Element,
        'keydown',
        'Delete'
      );

      assert.strictEqual(
        calls.current,
        before + 1,
        'and a keystroke that changes no date reports nothing'
      );
    });

    test('submits start and end under dot-notated names', async function (assert) {
      const { submitted, onSubmit } = captureSubmit();
      const range = {
        start: new Date(2026, 0, 20),
        end: new Date(2026, 0, 25)
      };

      await render(
        <template>
          <Form @onSubmit={{onSubmit}}>
            <DatePicker
              @mode="range"
              @name="trip"
              @label="Trip"
              @locale="en-US"
              @value={{range}}
            />
            <button type="submit">Submit</button>
          </Form>
        </template>
      );

      await click('button[type="submit"]');
      assert.deepEqual(submitted.current, {
        trip: { start: '2026-01-20', end: '2026-01-25' }
      });
    });

    test('pasting two dates into the start group fills both ends', async function (assert) {
      const seen = cell<{ start: Date; end: Date | null } | null>(null);
      const onChange = (value: { start: Date; end: Date | null } | null) => {
        seen.current = value;
      };

      await render(
        <template>
          <DatePicker
            @mode="range"
            @label="Trip dates"
            @locale="en-US"
            @onChange={{onChange}}
          />
        </template>
      );

      await focus(firstSegment(0));

      const data = new DataTransfer();
      data.setData('text/plain', '2026-01-20 – 2026-01-25');
      const event = new ClipboardEvent('paste', {
        clipboardData: data,
        bubbles: true,
        cancelable: true
      });
      (document.activeElement as HTMLElement).dispatchEvent(event);
      await settled();

      assert.true(event.defaultPrevented, 'the raw text never reaches the DOM');
      assert.strictEqual(textOf(0, 'day'), '20', 'the start group is filled');
      assert.strictEqual(textOf(1, 'day'), '25', 'and so is the end group');
      assert.strictEqual(seen.current?.start.getDate(), 20);
      assert.strictEqual(seen.current?.end?.getDate(), 25);
    });

    test('pasting two dates into the end group is declined', async function (assert) {
      await render(
        <template>
          <DatePicker @mode="range" @label="Trip dates" @locale="en-US" />
        </template>
      );

      await focus(firstSegment(1));

      const data = new DataTransfer();
      data.setData('text/plain', '2026-01-20 – 2026-01-25');
      (document.activeElement as HTMLElement).dispatchEvent(
        new ClipboardEvent('paste', {
          clipboardData: data,
          bubbles: true,
          cancelable: true
        })
      );
      await settled();

      assert.strictEqual(
        textOf(1, 'day'),
        'dd',
        'rewriting the start from the end of the field would be surprising'
      );
      assert.strictEqual(textOf(0, 'day'), 'dd', 'and the start is untouched');
    });

    test('picking a range in the calendar writes both groups', async function (assert) {
      await render(
        <template>
          <DatePicker
            @mode="range"
            @label="Trip dates"
            @locale="en-US"
            @defaultValue={{janAnchor}}
          />
        </template>
      );

      assert.strictEqual(
        textOf(1, 'day'),
        '06',
        'the seeded end is in the end group to begin with'
      );

      await click('[data-part="calendar-button"]');
      await click('[data-part="day"][data-key="2026-01-22"]');

      assert.strictEqual(
        textOf(0, 'day'),
        '22',
        'a fresh anchor lands in the start group'
      );
      assert.strictEqual(
        textOf(1, 'day'),
        'dd',
        'and the end group is cleared with it, until the second click'
      );

      await click('[data-part="day"][data-key="2026-01-25"]');

      assert.strictEqual(
        textOf(1, 'day'),
        '25',
        'which then writes the end group'
      );
    });
  }
);
