import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  find,
  findAll,
  focus,
  settled,
  triggerKeyEvent
} from '@ember/test-helpers';
import { cell } from 'ember-resources';
import { DateInput } from 'frontile';

/** The segments, in document order. */
function segments(): HTMLElement[] {
  return findAll('[data-part="segment"]') as HTMLElement[];
}

function segment(type: 'year' | 'month' | 'day'): HTMLElement {
  return find(`[data-part="segment"][data-type="${type}"]`) as HTMLElement;
}

/** Types a run of digits into whichever segment has focus. */
async function type(digits: string): Promise<void> {
  for (const d of digits) {
    await triggerKeyEvent(document.activeElement as Element, 'keydown', d);
  }
}

module(
  'Integration | Component | DateInput | frontile/forms',
  function (hooks) {
    setupRenderingTest(hooks);

    test('renders one focusable spinbutton per segment', async function (assert) {
      await render(
        <template><DateInput @label="Start date" @locale="en-US" /></template>
      );

      assert.strictEqual(segments().length, 3);
      assert.deepEqual(
        segments().map((s) => s.dataset['type']),
        ['month', 'day', 'year'],
        'en-US order'
      );

      for (const s of segments()) {
        assert.dom(s).hasAttribute('role', 'spinbutton');
        assert.dom(s).hasAttribute('tabindex', '0');
        assert.dom(s).hasAttribute('data-placeholder', 'true');
        assert
          .dom(s)
          .doesNotHaveAttribute(
            'aria-valuenow',
            'an empty segment has no current value at all'
          );
      }

      assert.dom(segment('month')).hasText('mm');
      assert.dom(segment('year')).hasText('yyyy');
    });

    test('typing fills segments and advances focus', async function (assert) {
      let received: Date | null = null;
      const onChange = (v: Date | null): void => {
        received = v;
      };

      await render(
        <template>
          <DateInput
            @label="Start date"
            @locale="en-US"
            @onChange={{onChange}}
          />
        </template>
      );

      await focus(segment('month'));
      await type('1');
      assert.dom(segment('month')).hasText('01');
      assert.strictEqual(
        document.activeElement,
        segment('month'),
        'waits for a second digit'
      );

      await type('2');
      assert.dom(segment('month')).hasText('12');
      assert.strictEqual(
        document.activeElement,
        segment('day'),
        'advances once full'
      );
      assert.strictEqual(
        received as Date | null,
        null,
        'no change event while incomplete'
      );

      await type('25');
      await type('2026');

      assert.strictEqual((received as Date | null)?.getFullYear(), 2026);
      assert.strictEqual((received as Date | null)?.getMonth(), 11);
      assert.strictEqual((received as Date | null)?.getDate(), 25);
    });

    test('onChange fires once on completion, not on every keystroke', async function (assert) {
      const seen: (Date | null)[] = [];
      const onChange = (v: Date | null): void => {
        seen.push(v);
      };

      await render(
        <template>
          <DateInput
            @label="Start date"
            @locale="en-US"
            @onChange={{onChange}}
          />
        </template>
      );

      await focus(segment('month'));
      await type('1225');
      assert.strictEqual(
        seen.length,
        0,
        'four keystrokes, no change: the date is still incomplete'
      );

      await type('2026');
      assert.strictEqual(seen.length, 1, 'eight keystrokes, one change');
      assert.strictEqual(seen[0]?.getFullYear(), 2026);
      assert.strictEqual(seen[0]?.getMonth(), 11);
      assert.strictEqual(seen[0]?.getDate(), 25);

      await focus(segment('day'));
      await triggerKeyEvent(segment('day'), 'keydown', 'Delete');
      assert.strictEqual(seen.length, 2, 'clearing reports once');
      assert.strictEqual(seen[1], null, 'and reports null');

      await triggerKeyEvent(segment('day'), 'keydown', 'Delete');
      assert.strictEqual(
        seen.length,
        2,
        'a keystroke that changes no value reports nothing'
      );
    });

    test('retyping a year never reports the years it is typed through', async function (assert) {
      const seen: (Date | null)[] = [];
      const onChange = (v: Date | null): void => {
        seen.push(v);
      };
      const value = new Date(2020, 11, 25);

      await render(
        <template>
          <DateInput
            @label="Start date"
            @locale="en-US"
            @value={{value}}
            @onChange={{onChange}}
          />
        </template>
      );

      await focus(segment('year'));
      await type('2026');

      // 2, 20 and 202 are digits on the way to 2026, not years anybody meant.
      // Task 9 drives a calendar from this value, which would otherwise jump to
      // 2002 and then to the year 202 AD while the user is still typing.
      assert.deepEqual(
        seen.map((d) => d?.getFullYear() ?? null),
        [null, 2026],
        'the old value drops, and only 2026 is ever reported'
      );
      assert.dom(segment('year')).hasText('2026');
    });

    test('a two-digit year expands when focus leaves the segment', async function (assert) {
      let received: Date | null = null;
      const onChange = (v: Date | null): void => {
        received = v;
      };

      await render(
        <template>
          <DateInput
            @label="Start date"
            @locale="en-US"
            @onChange={{onChange}}
          />
        </template>
      );

      await focus(segment('month'));
      await type('122526');
      assert.dom(segment('year')).hasText('26', 'shown as typed, so far');
      assert.strictEqual(
        received as Date | null,
        null,
        'and composing nothing while it could still become 2601'
      );

      // Any way out of the segment commits it; Home is the arrow-navigation one.
      await triggerKeyEvent(segment('year'), 'keydown', 'Home');

      assert.dom(segment('year')).hasText('2026');
      assert.strictEqual((received as Date | null)?.getFullYear(), 2026);
      assert.strictEqual((received as Date | null)?.getDate(), 25);
    });

    test('arrow keys move between segments and step values', async function (assert) {
      await render(
        <template><DateInput @label="Start date" @locale="en-US" /></template>
      );

      await focus(segment('month'));
      await triggerKeyEvent(segment('month'), 'keydown', 'ArrowRight');
      assert.strictEqual(document.activeElement, segment('day'));

      await triggerKeyEvent(segment('day'), 'keydown', 'ArrowLeft');
      assert.strictEqual(document.activeElement, segment('month'));

      await triggerKeyEvent(segment('month'), 'keydown', 'End');
      assert.strictEqual(document.activeElement, segment('year'));

      await triggerKeyEvent(segment('year'), 'keydown', 'Home');
      assert.strictEqual(document.activeElement, segment('month'));
    });

    test('ArrowUp on an empty segment seeds from the placeholder value', async function (assert) {
      const placeholder = new Date(2026, 8, 22);

      await render(
        <template>
          <DateInput
            @label="Start date"
            @locale="en-US"
            @placeholderValue={{placeholder}}
          />
        </template>
      );

      await focus(segment('month'));
      await triggerKeyEvent(segment('month'), 'keydown', 'ArrowUp');
      assert
        .dom(segment('month'))
        .hasText('09', 'September, from the placeholder');

      await triggerKeyEvent(segment('month'), 'keydown', 'ArrowUp');
      assert.dom(segment('month')).hasText('10');
    });

    test('values wrap at the segment bounds', async function (assert) {
      await render(
        <template><DateInput @label="Start date" @locale="en-US" /></template>
      );

      await focus(segment('month'));
      await type('12');
      await focus(segment('month'));
      await triggerKeyEvent(segment('month'), 'keydown', 'ArrowUp');
      assert.dom(segment('month')).hasText('01', 'December wraps to January');
    });

    test('PageUp steps further than ArrowUp', async function (assert) {
      await render(
        <template><DateInput @label="Start date" @locale="en-US" /></template>
      );

      await focus(segment('day'));
      await type('10');
      await focus(segment('day'));
      await triggerKeyEvent(segment('day'), 'keydown', 'PageUp');
      assert.dom(segment('day')).hasText('17', 'day pages by a week');
    });

    test('Backspace removes a digit and Delete clears the segment', async function (assert) {
      await render(
        <template><DateInput @label="Start date" @locale="en-US" /></template>
      );

      await focus(segment('year'));
      await type('2026');
      await focus(segment('year'));
      await triggerKeyEvent(segment('year'), 'keydown', 'Backspace');
      assert.dom(segment('year')).hasText('202');

      await triggerKeyEvent(segment('year'), 'keydown', 'Delete');
      assert.dom(segment('year')).hasText('yyyy');
      assert.dom(segment('year')).hasAttribute('data-placeholder', 'true');
    });

    test('clearing a segment of a complete value emits null once', async function (assert) {
      const seen: (Date | null)[] = [];
      const onChange = (v: Date | null): void => {
        seen.push(v);
      };
      const value = new Date(2026, 0, 20);

      await render(
        <template>
          <DateInput
            @label="Start date"
            @locale="en-US"
            @value={{value}}
            @onChange={{onChange}}
          />
        </template>
      );

      await focus(segment('day'));
      await triggerKeyEvent(segment('day'), 'keydown', 'Delete');

      assert.deepEqual(seen, [null]);
    });

    test('a partial entry survives blur', async function (assert) {
      await render(
        <template><DateInput @label="Start date" @locale="en-US" /></template>
      );

      await focus(segment('month'));
      await type('12');
      (document.activeElement as HTMLElement).blur();

      assert.dom(segment('month')).hasText('12', 'not cleared behind the user');
      assert.dom(segment('day')).hasText('dd', 'and not auto-completed');
    });

    test('segments carry spinbutton ARIA state', async function (assert) {
      const value = new Date(2026, 0, 20);

      await render(
        <template>
          <DateInput @label="Start date" @locale="en-US" @value={{value}} />
        </template>
      );

      assert.dom(segment('month')).hasAttribute('aria-valuenow', '1');
      assert.dom(segment('month')).hasAttribute('aria-valuemin', '1');
      assert.dom(segment('month')).hasAttribute('aria-valuemax', '12');
      assert.dom(segment('month')).hasAttribute('aria-valuetext', 'January');
      assert.dom(segment('month')).hasAttribute('aria-label', 'month');
      assert.dom(segment('year')).hasAttribute('aria-valuetext', '2026');
    });

    test('@segmentLabels overrides the English defaults', async function (assert) {
      const labels = { month: 'mois', day: 'jour', year: 'année' };

      await render(
        <template>
          <DateInput @label="Date" @locale="fr-FR" @segmentLabels={{labels}} />
        </template>
      );

      assert.dom(segment('month')).hasAttribute('aria-label', 'mois');
    });

    test('read-only segments are focusable but not editable', async function (assert) {
      const value = new Date(2026, 0, 20);

      await render(
        <template>
          <DateInput
            @label="Date"
            @locale="en-US"
            @value={{value}}
            @isReadOnly={{true}}
          />
        </template>
      );

      assert.dom(segment('month')).hasAttribute('tabindex', '0');
      assert.dom(segment('month')).hasAttribute('contenteditable', 'false');

      await focus(segment('month'));
      await triggerKeyEvent(segment('month'), 'keydown', 'ArrowUp');
      assert.dom(segment('month')).hasText('01', 'unchanged');
    });

    test('changing the locale reorders segments and keeps their values', async function (assert) {
      const locale = cell('en-US');
      const value = new Date(2026, 0, 20);

      await render(
        <template>
          <DateInput
            @label="Date"
            @locale={{locale.current}}
            @value={{value}}
          />
        </template>
      );

      assert.deepEqual(
        segments().map((s) => s.dataset['type']),
        ['month', 'day', 'year']
      );

      locale.current = 'en-GB';
      await settled();

      assert.deepEqual(
        segments().map((s) => s.dataset['type']),
        ['day', 'month', 'year'],
        'reordered'
      );
      assert.dom(segment('day')).hasText('20', 'and the values survived');
      assert.dom(segment('month')).hasText('01');
    });

    test('disabled segments leave the tab order', async function (assert) {
      await render(
        <template>
          <DateInput @label="Date" @locale="en-US" @isDisabled={{true}} />
        </template>
      );

      assert.dom(segment('month')).doesNotHaveAttribute('tabindex');
    });
  }
);
