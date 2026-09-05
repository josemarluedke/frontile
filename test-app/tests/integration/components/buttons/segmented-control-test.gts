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
  triggerKeyEvent,
  waitUntil
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

    test('uncontrolled: @defaultValue seeds the selection and clicking moves it', async function (assert) {
      // No `@value` at all, and no state wired on the consumer's side. This is
      // the shape every documentation demo uses, and before Task 8 it could not
      // be clicked: the control had no selection of its own to fall back on.
      const received: string[] = [];
      const onChange = (next: string): void => {
        received.push(next);
      };

      await render(
        <template>
          <SegmentedControl
            @defaultValue="week"
            @onChange={{onChange}}
            as |Ctl|
          >
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
            <Ctl.Item @value="month">Month</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const items = findAll('[role="radio"]') as HTMLElement[];
      assert
        .dom(items[1]!)
        .hasAria('checked', 'true', '@defaultValue seeds the selection');

      await click(items[2]!);

      assert
        .dom(items[2]!)
        .hasAria('checked', 'true', 'the click moves the selection');
      assert.dom(items[1]!).hasAria('checked', 'false', 'and releases the old');
      assert.deepEqual(
        received,
        ['month'],
        '@onChange still fires in uncontrolled mode'
      );
    });

    test('uncontrolled: it is clickable with no @onChange at all', async function (assert) {
      await render(
        <template>
          <SegmentedControl @defaultValue="day" as |Ctl|>
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const items = findAll('[role="radio"]') as HTMLElement[];
      await click(items[1]!);

      assert
        .dom(items[1]!)
        .hasAria(
          'checked',
          'true',
          'the internal state moves without a handler'
        );
    });

    test('controlled: @value without @onChange does not move on click', async function (assert) {
      // The mirror image of the test above: passing `@value` is what opts into
      // controlled mode, and a controlled control that nobody updates must
      // genuinely refuse to move -- otherwise the internal field would leak
      // through and the two modes would not be distinguishable.
      await render(
        <template>
          <SegmentedControl @value="day" as |Ctl|>
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const items = findAll('[role="radio"]') as HTMLElement[];
      await click(items[1]!);

      assert
        .dom(items[0]!)
        .hasAria('checked', 'true', '@value still decides the selection');
      assert
        .dom(items[1]!)
        .hasAria('checked', 'false', 'the click is not honoured locally');
    });

    test('controlled: @value with @onChange moves when the consumer updates', async function (assert) {
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

      const items = findAll('[role="radio"]') as HTMLElement[];
      await click(items[1]!);

      assert.strictEqual(value.current, 'week', 'the consumer was told');
      assert
        .dom(items[1]!)
        .hasAria('checked', 'true', 'and the update is reflected');
    });

    test('uncontrolled form mode: the click sticks and the submitted value follows', async function (assert) {
      // `requestFormSync` re-asserts every native `checked` a frame after the
      // click. Reading `@value` there rather than the effective value would
      // snap this pick straight back.
      await render(
        <template>
          <form data-test-form>
            <SegmentedControl @defaultValue="day" @name="range" as |Ctl|>
              <Ctl.Item @value="day">Day</Ctl.Item>
              <Ctl.Item @value="week">Week</Ctl.Item>
            </SegmentedControl>
          </form>
        </template>
      );

      const formEl = find('[data-test-form]') as HTMLFormElement;
      const inputs = findAll('input[type="radio"]') as HTMLInputElement[];

      assert.true(inputs[0]!.checked, '@defaultValue seeds the native state');
      assert.strictEqual(new FormData(formEl).get('range'), 'day');

      await click(inputs[1]!);

      assert.true(
        inputs[1]!.checked,
        'the pick survives the deferred form sync'
      );
      assert.false(inputs[0]!.checked, 'and the old one is released');
      assert.strictEqual(
        new FormData(formEl).get('range'),
        'week',
        'the submitted value follows the selection'
      );
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

    test('the indicator transitions the property that actually moves it', async function (assert) {
      // Regression: the theme declared the ready-state transition as
      // `transition-[transform,width,height]`, but Tailwind v4 compiles
      // `translate-x-*`/`translate-y-*` to the standalone CSS `translate`
      // property -- the indicator's computed style is `transform: none;
      // translate: <x> <y>`. With `translate` missing from the transition
      // list the pill *snapped* to its new position in a single frame while
      // only `width` eased, so the slide never happened.
      //
      // Asserting on the class string would not have caught this: the class
      // was present and spelled exactly as intended. Only the *computed*
      // transition, and the animations the browser actually creates, tell
      // the truth.
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
      const indicator = find('[aria-hidden="true"]') as HTMLElement;

      assert.ok(
        container.hasAttribute('data-fr-si-ready'),
        'the indicator is ready, so the gated transition applies'
      );

      const computed = window.getComputedStyle(indicator);
      const transitioned = computed.transitionProperty
        .split(',')
        .map((property) => property.trim());

      // The property the geometry is actually written to.
      const positionProperty =
        computed.translate && computed.translate !== 'none'
          ? 'translate'
          : 'transform';

      assert.ok(
        transitioned.includes(positionProperty),
        `the transition list (${computed.transitionProperty}) includes the property the indicator is positioned with (${positionProperty}: ${computed[positionProperty]})`
      );
      assert.ok(transitioned.includes('width'), 'and still transitions width');

      // Reading the computed style above also establishes the before-change
      // style, so the browser has something to transition *from* when the
      // selection moves below.
      void computed[positionProperty];

      await click(findAll('[role="radio"]')[1]!);

      // getAnimations() flushes pending style changes, so the transitions
      // created by this selection change are observable here. Only a
      // CSSTransition carries `transitionProperty`, so reading that field is
      // enough to pick them out of whatever else may be animating.
      const running = indicator
        .getAnimations()
        .map((animation) => ({
          property: (animation as Animation & { transitionProperty?: string })
            .transitionProperty,
          effect: animation.effect as {
            getKeyframes?: () => Record<string, unknown>[];
          } | null
        }))
        .filter((entry) => typeof entry.property === 'string');

      assert.ok(
        running.some((entry) => entry.property === positionProperty),
        `moving the selection starts a transition on ${positionProperty} (running: ${running.map((entry) => entry.property).join(', ') || 'none'})`
      );

      // A transition that exists but interpolates between two identical
      // values would still be a snap; check its endpoints actually differ.
      const frames =
        running
          .find((entry) => entry.property === positionProperty)
          ?.effect?.getKeyframes?.() ?? [];
      const from = frames[0]?.[positionProperty];
      const to = frames[frames.length - 1]?.[positionProperty];

      assert.notStrictEqual(
        from,
        to,
        `and it eases between two different positions (${String(from)} -> ${String(to)})`
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

    test('form mode paints the selected item with the intent contrast colour', async function (assert) {
      // The selected-state colour is expressed as `aria-checked:text-*` for
      // button mode; the label in form mode carries no `aria-checked`, so it
      // needs the `has-[:checked]:text-*` counterpart. Asserting on the class
      // string would not catch a class that is present but generates no CSS,
      // so this compares what the browser actually resolves.
      await render(
        <template>
          <SegmentedControl
            @value="day"
            @name="range"
            @intent="primary"
            as |Ctl|
          >
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
          </SegmentedControl>

          <SegmentedControl @value="day" @intent="primary" as |Ctl|>
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const labels = findAll('label') as HTMLLabelElement[];
      const buttons = findAll('[role="radio"]') as HTMLElement[];

      const selected = getComputedStyle(labels[0]!).color;
      const unselected = getComputedStyle(labels[1]!).color;
      const buttonSelected = getComputedStyle(buttons[0]!).color;
      const buttonUnselected = getComputedStyle(buttons[1]!).color;

      assert.notStrictEqual(
        buttonSelected,
        buttonUnselected,
        'sanity: button mode does distinguish the selected item'
      );
      assert.notStrictEqual(
        selected,
        unselected,
        'the selected label does not keep the unselected text colour'
      );
      assert.strictEqual(
        selected,
        buttonSelected,
        'the selected label resolves to the same colour button mode uses'
      );
      assert.strictEqual(
        unselected,
        buttonUnselected,
        'unselected items match across modes'
      );
    });

    test('form mode restores the native checked state when the value does not change', async function (assert) {
      // No `@onChange`: the click mutates the DOM's `checked` directly, and
      // `checked={{isSelected}}` alone would never write it back.
      await render(
        <template>
          <SegmentedControl @value="day" @name="range" as |Ctl|>
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const inputs = findAll('input[type="radio"]') as HTMLInputElement[];

      await click(inputs[1]!);

      assert.true(
        inputs[0]!.checked,
        'the input matching @value is checked again'
      );
      assert.false(
        inputs[1]!.checked,
        'the declined pick does not linger in the DOM'
      );
    });

    test('form mode keeps an accepted change', async function (assert) {
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
            <Ctl.Item @value="week">Week</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const inputs = findAll('input[type="radio"]') as HTMLInputElement[];

      await click(inputs[1]!);

      assert.strictEqual(value.current, 'week', 'the consumer accepted it');
      assert.false(inputs[0]!.checked, 'the old selection is released');
      assert.true(
        inputs[1]!.checked,
        'the accepted pick sticks -- the guard does not fight it'
      );
    });

    test('separators are drawn between items and hidden around the selection', async function (assert) {
      const value = cell('week');
      const onChange = (next: string): void => {
        value.current = next;
      };

      await render(
        <template>
          <SegmentedControl
            @value={{value.current}}
            @onChange={{onChange}}
            @hasSeparators={{true}}
            as |Ctl|
          >
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
            <Ctl.Item @value="month">Month</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const items = findAll('[role="radio"]') as HTMLElement[];
      const before = (el: HTMLElement): CSSStyleDeclaration =>
        getComputedStyle(el, '::before');

      assert.strictEqual(
        before(items[0]!).content,
        'none',
        'the first item has no leading separator'
      );
      assert.strictEqual(
        before(items[1]!).opacity,
        '0',
        'the separator before the selected item is hidden'
      );
      assert.strictEqual(
        before(items[2]!).opacity,
        '0',
        'so is the one immediately after it'
      );

      // Dimensions come from `getComputedStyle`, not `getBoundingClientRect`:
      // `#ember-testing` renders at 50% scale, which halves every rect value
      // but leaves computed styles alone. Without these two assertions the
      // horizontal `compoundVariants` entry could be deleted outright and the
      // opacity checks above would still pass, because a 0x0 pseudo-element
      // still reports a `content` value and a transitioning `opacity`.
      const separator = before(items[1]!);
      assert.strictEqual(
        separator.width,
        '1px',
        'the horizontal hairline is one pixel wide'
      );
      assert.ok(
        parseFloat(separator.height) > parseFloat(separator.width),
        `and taller than it is wide (${separator.height} tall)`
      );

      await click(items[0]!);

      // The separator's own `before:transition-opacity before:duration-200`
      // (Step 3) means the browser does not settle the CSS transition within
      // the same tick `settled()` resolves on -- reading the computed value
      // immediately after `click()` can still catch it mid-animation.
      // `waitUntil` polls past that window; the assertion below still checks
      // the exact settled value, so nothing about the check itself is
      // weakened.
      await waitUntil(() => before(items[2]!).opacity === '1', {
        timeout: 1000
      });

      assert.strictEqual(
        before(items[2]!).opacity,
        '1',
        'a separator away from the selection is visible again'
      );
    });

    test('separators are hidden around the selection in form mode', async function (assert) {
      const value = cell('week');
      const onChange = (next: string): void => {
        value.current = next;
      };

      await render(
        <template>
          <SegmentedControl
            @value={{value.current}}
            @onChange={{onChange}}
            @name="range"
            @hasSeparators={{true}}
            as |Ctl|
          >
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
            <Ctl.Item @value="month">Month</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const labels = findAll('label') as HTMLElement[];
      const before = (el: HTMLElement): CSSStyleDeclaration =>
        getComputedStyle(el, '::before');

      assert.strictEqual(
        before(labels[0]!).content,
        'none',
        'the first item has no leading separator'
      );
      assert.strictEqual(
        before(labels[1]!).opacity,
        '0',
        'the separator before the selected item is hidden'
      );
      assert.strictEqual(
        before(labels[2]!).opacity,
        '0',
        'so is the one immediately after it'
      );

      const inputs = findAll('input[type="radio"]') as HTMLInputElement[];
      await click(inputs[0]!);

      // See the button-mode test above: the separator's own CSS transition
      // does not settle within the same tick `settled()` resolves on.
      await waitUntil(() => before(labels[2]!).opacity === '1', {
        timeout: 1000
      });

      assert.strictEqual(
        before(labels[2]!).opacity,
        '1',
        'a separator away from the selection is visible again'
      );
    });

    test('separators transpose their geometry when the control is vertical', async function (assert) {
      const value = cell('week');
      const onChange = (next: string): void => {
        value.current = next;
      };

      await render(
        <template>
          <SegmentedControl
            @value={{value.current}}
            @onChange={{onChange}}
            @orientation="vertical"
            @hasSeparators={{true}}
            as |Ctl|
          >
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
            <Ctl.Item @value="month">Month</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const items = findAll('[role="radio"]') as HTMLElement[];
      const before = (el: HTMLElement): CSSStyleDeclaration =>
        getComputedStyle(el, '::before');

      // `getComputedStyle` again rather than `getBoundingClientRect`, for the
      // 50%-scale reason given in the horizontal test above. In the vertical
      // compound variant the hairline runs across the stack instead of down
      // between columns, so its two dimensions swap.
      const separator = before(items[1]!);
      assert.strictEqual(
        separator.height,
        '1px',
        'the vertical hairline is one pixel tall'
      );
      assert.ok(
        parseFloat(separator.width) > parseFloat(separator.height),
        `and wider than it is tall (${separator.width} wide)`
      );

      assert.strictEqual(
        before(items[0]!).content,
        'none',
        'the first item still has no leading separator'
      );
      assert.strictEqual(
        before(items[1]!).opacity,
        '0',
        'the separator before the selected item is hidden on this axis too'
      );
      assert.strictEqual(
        before(items[2]!).opacity,
        '0',
        'so is the one immediately after it'
      );

      await click(items[0]!);

      // See the horizontal test: the separator's own 200ms opacity transition
      // does not settle within the tick `settled()` resolves on.
      await waitUntil(() => before(items[2]!).opacity === '1', {
        timeout: 1000
      });

      assert.strictEqual(
        before(items[2]!).opacity,
        '1',
        'a separator away from the selection is visible again'
      );
    });

    test('vertical drops the pill radius that horizontal keeps', async function (assert) {
      // A 9999px radius on a tall narrow column renders as an oval blob rather
      // than a stack, so the vertical axis swaps to a rounded rectangle -- on
      // the track and on the indicator, or the indicator would bulge out of the
      // squared-off track.
      await render(
        <template>
          <div>
            <SegmentedControl
              @defaultValue="week"
              @orientation="vertical"
              data-test-vertical
              as |Ctl|
            >
              <Ctl.Item @value="day">Day</Ctl.Item>
              <Ctl.Item @value="week">Week</Ctl.Item>
              <Ctl.Item @value="month">Month</Ctl.Item>
            </SegmentedControl>
            <SegmentedControl
              @defaultValue="week"
              data-test-horizontal
              as |Ctl|
            >
              <Ctl.Item @value="day">Day</Ctl.Item>
              <Ctl.Item @value="week">Week</Ctl.Item>
              <Ctl.Item @value="month">Month</Ctl.Item>
            </SegmentedControl>
          </div>
        </template>
      );

      const vertical = find('[data-test-vertical]') as HTMLElement;
      const horizontal = find('[data-test-horizontal]') as HTMLElement;
      const radius = (el: Element): string =>
        getComputedStyle(el).borderTopLeftRadius;

      assert.strictEqual(
        radius(horizontal),
        '9999px',
        'horizontal keeps the pill'
      );
      assert.notStrictEqual(
        radius(vertical),
        '9999px',
        `vertical is a rounded rectangle instead (${radius(vertical)})`
      );
      assert.ok(
        parseFloat(radius(vertical)) > 0,
        'but is still rounded rather than squared off'
      );

      const verticalIndicator = vertical.firstElementChild as HTMLElement;
      const horizontalIndicator = horizontal.firstElementChild as HTMLElement;
      assert.strictEqual(
        radius(horizontalIndicator),
        '9999px',
        'the horizontal indicator keeps the pill too'
      );
      assert.notStrictEqual(
        radius(verticalIndicator),
        '9999px',
        `and the vertical indicator follows the track (${radius(verticalIndicator)})`
      );
      assert.ok(
        parseFloat(radius(verticalIndicator)) <= parseFloat(radius(vertical)),
        'the indicator sits inside the track, so its radius is no larger'
      );
    });

    test('a separator is visible from the first render, not only after a click', async function (assert) {
      // The three-item/middle-selected fixture the other separator tests use
      // suppresses EVERY hairline at rest: the first by
      // `first-of-type:before:content-none`, the second because its item is
      // selected, the third because it follows the selected one. So their
      // initial-state assertions cannot tell "all correctly hidden" apart from
      // "the rule never generated". Four items with the second selected leaves
      // the fourth item's separator genuinely visible.
      await render(
        <template>
          <SegmentedControl
            @defaultValue="week"
            @hasSeparators={{true}}
            as |Ctl|
          >
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
            <Ctl.Item @value="month">Month</Ctl.Item>
            <Ctl.Item @value="year">Year</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const items = findAll('[role="radio"]') as HTMLElement[];
      const before = (el: HTMLElement): CSSStyleDeclaration =>
        getComputedStyle(el, '::before');

      assert.strictEqual(
        before(items[0]!).content,
        'none',
        'the first item has no leading separator'
      );
      assert.strictEqual(
        before(items[1]!).opacity,
        '0',
        'the separator before the selected item is hidden'
      );
      assert.strictEqual(
        before(items[2]!).opacity,
        '0',
        'so is the one immediately after it'
      );
      assert.strictEqual(
        before(items[3]!).opacity,
        '1',
        'and the one clear of the selection is visible at rest'
      );
      assert.strictEqual(
        before(items[3]!).width,
        '1px',
        'the visible hairline is a real one pixel wide'
      );
    });

    test('an underline indicator positions from x and width alone', async function (assert) {
      // This test is the artifact that locks in the reusable-geometry
      // contract: SelectionIndicator publishes --fr-si-x / --fr-si-width and
      // paints nothing, so a consumer (a future Tabs, say) can draw a bar
      // instead of a pill without touching the JS. For it to prove that, the
      // override has to be doing ALL of the positioning -- `@classes` MERGES
      // with the theme's classes rather than replacing them, and tv's twMerge
      // does not drop the theme's `translate-x-[var(--fr-si-x)]` or
      // `w-[var(--fr-si-width)]` for an unrecognised name like
      // `.test-underline`. So the rule below first neutralises the theme's
      // geometry outright -- `translate: none` kills its translate-x/y,
      // `width: auto` its w-[var(...)], `top: auto` its top-0, and the
      // explicit `height` its h-[var(...)] -- and only then re-derives the box
      // from the published custom properties alone: `left` straight from
      // --fr-si-x, and the width implied by `left` plus a `right` computed
      // from both properties. `.test-underline` is unlayered while Tailwind's
      // utilities sit in a cascade layer, so it wins regardless of
      // specificity.
      await render(
        <template>
          {{! template-lint-disable no-forbidden-elements }}
          {{! This <style> is scoped to the test container and torn down with
              the test; it exists only to prove the indicator's geometry
              (--fr-si-x/--fr-si-width) is consumable by a bar-shaped override,
              not to style production markup. }}
          <style>
            .test-underline {
              translate: none;
              width: auto;
              position: absolute;
              top: auto;
              bottom: 0;
              left: var(--fr-si-x);
              right: calc(100% - var(--fr-si-x) - var(--fr-si-width));
              height: 2px;
            }
          </style>
          <SegmentedControl
            @value="week"
            @classes={{hash indicator="test-underline"}}
            as |Ctl|
          >
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">A much longer label</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const indicator = find('[aria-hidden="true"]') as HTMLElement;
      const container = find('[role="radiogroup"]') as HTMLElement;
      const selected = findAll('[role="radio"]')[1] as HTMLElement;

      const indicatorBox = indicator.getBoundingClientRect();
      const containerBox = container.getBoundingClientRect();
      const selectedBox = selected.getBoundingClientRect();

      // Rects are in device pixels and `#ember-testing` renders at 50%, so
      // this 1 is 2 real CSS px -- enough to absorb the sub-pixel gap between
      // the integer offsetLeft/offsetWidth the indicator publishes and the
      // fractional rect it is compared against, and far tighter than the
      // ~34px (device) error the assertions below report when the override
      // stops positioning.
      const tolerance = 1;

      assert.ok(
        Math.abs(indicatorBox.left - selectedBox.left) < tolerance,
        `a bar-shaped indicator lines up with the selected item (off by ${Math.abs(indicatorBox.left - selectedBox.left)})`
      );
      assert.ok(
        Math.abs(indicatorBox.width - selectedBox.width) < tolerance,
        `and matches its width (off by ${Math.abs(indicatorBox.width - selectedBox.width)})`
      );
      assert.ok(
        indicatorBox.height < 5,
        `while keeping its own height (${indicatorBox.height})`
      );

      // The vertical edge is what only the override can produce: the theme
      // pins the pill to the top with the item's full height, so its bottom
      // sits exactly on the item's bottom, one padding step ABOVE the
      // container's. A bar flush with the container's bottom edge therefore
      // cannot be the theme's doing.
      assert.ok(
        Math.abs(indicatorBox.bottom - containerBox.bottom) < tolerance,
        `the bar is flush with the container's bottom edge (off by ${Math.abs(indicatorBox.bottom - containerBox.bottom)})`
      );
      assert.ok(
        indicatorBox.bottom > selectedBox.bottom,
        'and sits below the selected item, where the theme pill never does'
      );
    });

    test('controlled: a starting @value of undefined still means controlled', async function (assert) {
      // `undefined` is a legitimate value of the generic `T` -- "nothing is
      // selected" -- so it cannot also be the signal for "argument omitted".
      // Deciding controlled-ness by value rather than by presence used to run
      // this control uncontrolled until its first pick, so a consumer that
      // validates and declines the change still saw the selection move.
      const value = cell<string | undefined>(undefined);
      const received: string[] = [];
      const onChange = (next: string): void => {
        // Deliberately declines the change: a controlled consumer that
        // validates and says no.
        received.push(next);
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

      const items = findAll('[role="radio"]') as HTMLButtonElement[];
      items.forEach((item) => assert.dom(item).hasAria('checked', 'false'));

      await click(items[1]!);

      assert.deepEqual(received, ['week'], 'onChange still reports the pick');
      findAll('[role="radio"]').forEach((item) => {
        assert
          .dom(item)
          .hasAria(
            'checked',
            'false',
            'but the declined change does not move the selection'
          );
      });
    });

    test('controlled: the consumer can clear the selection back to nothing', async function (assert) {
      const value = cell<string | undefined>('day');
      const onChange = (next: string | undefined): void => {
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

      assert.dom(findAll('[role="radio"]')[0]!).hasAria('checked', 'true');

      value.current = undefined;
      await settled();

      findAll('[role="radio"]').forEach((item) => {
        assert
          .dom(item)
          .hasAria(
            'checked',
            'false',
            'setting @value back to undefined clears'
          );
      });
      assert.notOk(
        (find('[role="radiogroup"]') as HTMLElement).hasAttribute(
          'data-fr-si-ready'
        ),
        'and the indicator goes back to hidden'
      );
    });

    test('a selection that moves to a value matching no item ends not ready', async function (assert) {
      // The fall-through case of the deferred re-measure: the outgoing target
      // tears down, nothing claims the slot, and the deferred measure has to
      // actually strip data-fr-si-ready. The "value matching no item" test
      // above only covers the never-ready path, which the deferral cannot
      // regress.
      const value = cell('day');

      await render(
        <template>
          <SegmentedControl @value={{value.current}} as |Ctl|>
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const container = find('[role="radiogroup"]') as HTMLElement;
      assert.ok(
        container.hasAttribute('data-fr-si-ready'),
        'ready while a real item is selected'
      );

      value.current = 'nothing';
      await settled();

      assert.notOk(
        container.hasAttribute('data-fr-si-ready'),
        'and not ready once the selection matches no item'
      );
    });

    test('form mode stands RovingFocus down and leaves the keyboard to the browser', async function (assert) {
      // The docs justify not running RovingFocus in form mode by saying a
      // same-named native radio group already owns the keyboard. Two things
      // have to hold for that to be true, and neither is implied by the
      // button-mode tests:
      //
      // 1. Nothing managed sets tabindex on the labels or the inputs. A roving
      //    tabindex would leave every unselected radio unreachable and would
      //    be the visible fingerprint of RovingFocus still being attached.
      // 2. Arrow keys reach the browser unhandled -- RovingFocus calls
      //    preventDefault() on every key it acts on, so an un-prevented arrow
      //    keydown is the proof it is not listening.
      const value = cell('day');
      const received: string[] = [];
      const onChange = (next: string): void => {
        received.push(next);
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
            <Ctl.Item @value="week">Week</Ctl.Item>
            <Ctl.Item @value="month">Month</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const labels = findAll('label') as HTMLLabelElement[];
      const inputs = findAll('input[type="radio"]') as HTMLInputElement[];

      labels.forEach((label, index) => {
        assert
          .dom(label)
          .doesNotHaveAttribute(
            'tabindex',
            `label ${index} carries no managed tabindex`
          );
      });
      inputs.forEach((input, index) => {
        assert
          .dom(input)
          .doesNotHaveAttribute(
            'tabindex',
            `input ${index} carries no managed tabindex either`
          );
      });

      await focus(inputs[0]!);

      // Native radio arrow-keying is a browser default action, which a
      // synthetic keydown does not perform. What the browser *does* on that
      // key is well defined, though: it focuses and checks the next radio in
      // the same-named group and fires `change` on it. Reproduce exactly that
      // and assert the component responds to it, which is the half of the
      // contract the component actually owns.
      inputs[1]!.checked = true;
      await triggerEvent(inputs[1]!, 'change');

      assert.deepEqual(
        received,
        ['week'],
        'a keyboard-driven native change fires @onChange'
      );
      assert.strictEqual(value.current, 'week', 'and moves the selection');
      assert.true(
        (findAll('input[type="radio"]')[1] as HTMLInputElement).checked,
        'the newly selected radio stays checked'
      );
      assert.false(
        (findAll('input[type="radio"]')[0] as HTMLInputElement).checked,
        'and the previously selected one does not'
      );

      // Arrow again, from the new position, to prove it is not a one-shot.
      inputs[2]!.checked = true;
      await triggerEvent(inputs[2]!, 'change');

      assert.deepEqual(
        received,
        ['week', 'month'],
        'and it keeps working as the keyboard walks the group'
      );
    });

    test('form mode does not swallow the arrow keys the browser needs', async function (assert) {
      await render(
        <template>
          <SegmentedControl @value="day" @name="range" as |Ctl|>
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const inputs = findAll('input[type="radio"]') as HTMLInputElement[];
      const label = find('label') as HTMLLabelElement;

      // RovingFocus preventDefaults every key it handles. If it were attached
      // here -- to either the label or the input -- this event would come back
      // prevented, and the browser's own radio-group navigation would never
      // run.
      for (const target of [inputs[0]!, label]) {
        const event = new KeyboardEvent('keydown', {
          key: 'ArrowRight',
          bubbles: true,
          cancelable: true
        });
        target.dispatchEvent(event);
        assert.false(
          event.defaultPrevented,
          `ArrowRight on the ${target.tagName.toLowerCase()} reaches the browser unhandled`
        );
      }

      await settled();
    });

    test('the documented pill example works against a real control', async function (assert) {
      // C1 regression: selection-indicator.md used to gate both worked
      // examples with `.indicator[data-fr-si-ready]`. The attribute lands on
      // the CONTAINER and the indicator is its child, so that selector can
      // never match -- anyone copying the example got an indicator stuck at
      // opacity 0 with no transition. This is the corrected rule from the
      // docs, verbatim, rendered against a real control.
      const value = cell('day');
      const onChange = (next: string): void => {
        value.current = next;
      };

      await render(
        <template>
          {{! template-lint-disable no-forbidden-elements }}
          {{! Scoped to the test container and torn down with the test. It is
              the docs' own rule, copied, so that the published contract is
              executed rather than merely proof-read. }}
          <style>
            .my-control .pill-indicator {
              opacity: 0;
            }

            .my-control[data-fr-si-ready] .pill-indicator {
              opacity: 1;
              transition:
                translate 200ms ease-out,
                width 200ms ease-out,
                height 200ms ease-out;
            }
          </style>
          <SegmentedControl
            @value={{value.current}}
            @onChange={{onChange}}
            @classes={{hash base="my-control" indicator="pill-indicator"}}
            as |Ctl|
          >
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">A much longer label</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const container = find('[role="radiogroup"]') as HTMLElement;
      const indicator = find('[aria-hidden="true"]') as HTMLElement;

      assert.ok(
        container.matches('.my-control[data-fr-si-ready]'),
        'the ready attribute is on the container, which is what the rule keys off'
      );
      assert.notOk(
        indicator.matches('[data-fr-si-ready]'),
        'and never on the indicator itself -- the old example could not match'
      );

      const computed = window.getComputedStyle(indicator);
      assert.strictEqual(
        computed.opacity,
        '1',
        'the gated rule makes the indicator visible'
      );
      assert.ok(
        computed.transitionProperty
          .split(',')
          .map((property) => property.trim())
          .includes('translate'),
        `and applies the transition (${computed.transitionProperty})`
      );

      // Establish the before-change style so the browser has something to
      // transition from, then confirm the move really animates.
      void computed.translate;

      await click(findAll('[role="radio"]')[1]!);

      const running = indicator
        .getAnimations()
        .map(
          (animation) =>
            (animation as Animation & { transitionProperty?: string })
              .transitionProperty
        )
        .filter((property): property is string => typeof property === 'string');

      assert.ok(
        running.includes('translate'),
        `moving the selection starts a translate transition (running: ${running.join(', ') || 'none'})`
      );
    });

    test('the documented underline example works against a real control', async function (assert) {
      const value = cell('day');
      const onChange = (next: string): void => {
        value.current = next;
      };

      await render(
        <template>
          {{! template-lint-disable no-forbidden-elements }}
          {{! The docs' underline rule, copied verbatim. }}
          <style>
            .my-control .underline-indicator {
              translate: none;
              width: auto;
              position: absolute;
              top: auto;
              bottom: 0;
              left: var(--fr-si-x);
              right: calc(100% - var(--fr-si-x) - var(--fr-si-width));
              height: 2px;
              opacity: 0;
            }

            .my-control[data-fr-si-ready] .underline-indicator {
              opacity: 1;
              transition:
                left 200ms ease-out,
                right 200ms ease-out;
            }
          </style>
          <SegmentedControl
            @value={{value.current}}
            @onChange={{onChange}}
            @classes={{hash base="my-control" indicator="underline-indicator"}}
            as |Ctl|
          >
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">A much longer label</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const indicator = find('[aria-hidden="true"]') as HTMLElement;
      const selected = findAll('[role="radio"]')[0] as HTMLElement;

      const computed = window.getComputedStyle(indicator);
      assert.strictEqual(
        computed.opacity,
        '1',
        'the gated rule makes the bar visible'
      );
      const transitioned = computed.transitionProperty
        .split(',')
        .map((property) => property.trim());
      assert.ok(
        transitioned.includes('left') && transitioned.includes('right'),
        `and applies the transition (${computed.transitionProperty})`
      );

      // Visible means more than opacity: it has to be over the selected item.
      const indicatorBox = indicator.getBoundingClientRect();
      const selectedBox = selected.getBoundingClientRect();
      assert.ok(
        Math.abs(indicatorBox.left - selectedBox.left) < 1,
        `the bar lines up with the selected item (off by ${Math.abs(indicatorBox.left - selectedBox.left)})`
      );

      void computed.left;

      await click(findAll('[role="radio"]')[1]!);

      const running = indicator
        .getAnimations()
        .map(
          (animation) =>
            (animation as Animation & { transitionProperty?: string })
              .transitionProperty
        )
        .filter((property): property is string => typeof property === 'string');

      assert.ok(
        running.includes('left'),
        `moving the selection eases the bar across (running: ${running.join(', ') || 'none'})`
      );
    });

    test('the indicator lands on the selected item in an RTL container', async function (assert) {
      // SelectionIndicator publishes physical offsets (offsetLeft/offsetTop)
      // on purpose: the browser has already laid the items out for the
      // container's direction, so a physical offset fed to `translate` is
      // correct in both directions and a logical property would flip an
      // already-flipped value. That claim is made in three places and was
      // never executed.
      await render(
        <template>
          <div dir="rtl">
            <SegmentedControl @value="month" as |Ctl|>
              <Ctl.Item @value="day">Day</Ctl.Item>
              <Ctl.Item @value="week">A much longer label</Ctl.Item>
              <Ctl.Item @value="month">Month</Ctl.Item>
            </SegmentedControl>
          </div>
        </template>
      );

      const container = find('[role="radiogroup"]') as HTMLElement;
      const items = findAll('[role="radio"]') as HTMLElement[];
      const indicator = find('[aria-hidden="true"]') as HTMLElement;
      const selected = items[2]!;

      assert.strictEqual(
        window.getComputedStyle(container).direction,
        'rtl',
        'the control really is laid out right-to-left'
      );
      // If direction were being ignored the last item would sit on the right;
      // in RTL it is the leftmost. Establishes that this is a real RTL layout
      // and not an LTR one that happens to agree.
      assert.ok(
        selected.getBoundingClientRect().left <
          items[0]!.getBoundingClientRect().left,
        'the last item is the leftmost one, as RTL requires'
      );

      const indicatorBox = indicator.getBoundingClientRect();
      const selectedBox = selected.getBoundingClientRect();

      // Rects are device pixels and `#ember-testing` renders at 50%, so this
      // 3 is 1.5 real CSS px -- enough for the sub-pixel gap between the
      // integer offsetLeft the indicator publishes and the fractional rect it
      // is compared against. A direction bug is nothing like that small: the
      // double-flip a logical property would cause lands the indicator on the
      // mirrored item instead, which the second assertion pins down.
      assert.ok(
        Math.abs(indicatorBox.left - selectedBox.left) < 3,
        `the indicator sits over the selected item (off by ${Math.abs(indicatorBox.left - selectedBox.left)})`
      );
      assert.ok(
        Math.abs(indicatorBox.left - items[0]!.getBoundingClientRect().left) >
          20,
        'and nowhere near the mirror-image position a double-flip would produce'
      );
      assert.ok(
        Math.abs(indicatorBox.width - selectedBox.width) < 3,
        `and matches its width (off by ${Math.abs(indicatorBox.width - selectedBox.width)})`
      );
    });
    test('items publish data-selected and data-disabled in button mode', async function (assert) {
      const value = cell('week');
      const onChange = (next: string): void => {
        value.current = next;
      };

      await render(
        <template>
          <SegmentedControl
            @value={{value.current}}
            @onChange={{onChange}}
            aria-label="Range"
            as |Ctl|
          >
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
            <Ctl.Item @value="month" @isDisabled={{true}}>Month</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const items = findAll('[role="radio"]') as HTMLElement[];
      assert.dom(items[0]!).hasAttribute('data-selected', 'false');
      assert.dom(items[1]!).hasAttribute('data-selected', 'true');
      assert.dom(items[0]!).hasAttribute('data-disabled', 'false');
      assert.dom(items[2]!).hasAttribute('data-disabled', 'true');

      await click(items[0]!);

      assert
        .dom(findAll('[role="radio"]')[0]!)
        .hasAttribute(
          'data-selected',
          'true',
          'data-selected follows the selection'
        );
      assert
        .dom(findAll('[role="radio"]')[1]!)
        .hasAttribute('data-selected', 'false');
    });

    test('items publish data-selected and data-disabled in form mode too', async function (assert) {
      // The whole point of the attribute: form mode's item is a <label> whose
      // sr-only input holds the state, so `aria-checked:` and `disabled:` are
      // both dead there. One hook has to span both modes.
      const value = cell('week');
      const onChange = (next: string): void => {
        value.current = next;
      };

      await render(
        <template>
          <SegmentedControl
            @value={{value.current}}
            @onChange={{onChange}}
            @name="range"
            aria-label="Range"
            as |Ctl|
          >
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
            <Ctl.Item @value="month" @isDisabled={{true}}>Month</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const labels = findAll('label') as HTMLElement[];
      assert.dom('[role="radio"]').doesNotExist('form mode renders labels');
      assert.dom(labels[0]!).hasAttribute('data-selected', 'false');
      assert.dom(labels[1]!).hasAttribute('data-selected', 'true');
      assert.dom(labels[2]!).hasAttribute('data-disabled', 'true');

      await click(findAll('input[type="radio"]')[0]!);

      assert
        .dom(findAll('label')[0]!)
        .hasAttribute(
          'data-selected',
          'true',
          'data-selected follows the selection in form mode as well'
        );
    });

    test('a consumer can style the selected item through data-selected in both modes', async function (assert) {
      // The contract consumers actually rely on: not that the attribute is
      // present, but that a rule keyed off it wins over the resting item
      // colour. Asserted as computed colour, since a class can be present and
      // still not apply.
      await render(
        <template>
          {{! template-lint-disable no-forbidden-elements }}
          <style>
            .seg-test-item {
              color: rgb(10, 20, 30);
            }
            .seg-test-item[data-selected="true"] {
              color: rgb(200, 100, 50);
            }
          </style>

          <SegmentedControl
            @defaultValue="week"
            @classes={{hash item="seg-test-item"}}
            aria-label="Button mode"
            as |Ctl|
          >
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
          </SegmentedControl>

          <SegmentedControl
            @defaultValue="week"
            @name="range"
            @classes={{hash item="seg-test-item"}}
            aria-label="Form mode"
            as |Ctl|
          >
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const buttons = findAll('[role="radio"]') as HTMLElement[];
      assert.strictEqual(
        getComputedStyle(buttons[1]!).color,
        'rgb(200, 100, 50)',
        'button mode: the selected item takes the overridden colour'
      );
      assert.strictEqual(
        getComputedStyle(buttons[0]!).color,
        'rgb(10, 20, 30)',
        'button mode: an unselected item keeps the resting colour'
      );

      const labels = findAll('label') as HTMLElement[];
      assert.strictEqual(
        getComputedStyle(labels[1]!).color,
        'rgb(200, 100, 50)',
        'form mode: the same rule works, with no mode-specific modifier'
      );
      assert.strictEqual(
        getComputedStyle(labels[0]!).color,
        'rgb(10, 20, 30)',
        'form mode: an unselected item keeps the resting colour'
      );
    });

    test('Home and End select the first and last enabled items', async function (assert) {
      // Covered against the bare primitive, but that only proves focus moves.
      // What matters here is that automatic activation turns that move into a
      // selection -- the component contract, not the utility's.
      const value = cell('week');
      const onChange = (next: string): void => {
        value.current = next;
      };

      await render(
        <template>
          <SegmentedControl
            @value={{value.current}}
            @onChange={{onChange}}
            aria-label="Range"
            as |Ctl|
          >
            <Ctl.Item @value="day" @isDisabled={{true}}>Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
            <Ctl.Item @value="month">Month</Ctl.Item>
            <Ctl.Item @value="year" @isDisabled={{true}}>Year</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const items = findAll('[role="radio"]') as HTMLElement[];
      await focus(items[1]!);

      await triggerKeyEvent(items[1]!, 'keydown', 'End');
      assert.strictEqual(
        value.current,
        'month',
        'End selects the last enabled item, skipping the disabled one'
      );

      await triggerKeyEvent(items[2]!, 'keydown', 'Home');
      assert.strictEqual(
        value.current,
        'week',
        'Home selects the first enabled item, skipping the disabled one'
      );
    });

    test('arrow navigation wraps at both ends and selects as it goes', async function (assert) {
      const value = cell('day');
      const onChange = (next: string): void => {
        value.current = next;
      };

      await render(
        <template>
          <SegmentedControl
            @value={{value.current}}
            @onChange={{onChange}}
            aria-label="Range"
            as |Ctl|
          >
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
            <Ctl.Item @value="month">Month</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const first = (): HTMLElement =>
        findAll('[role="radio"]')[0] as HTMLElement;
      const last = (): HTMLElement =>
        findAll('[role="radio"]')[2] as HTMLElement;

      await focus(first());
      await triggerKeyEvent(first(), 'keydown', 'ArrowLeft');
      assert.strictEqual(
        value.current,
        'month',
        'stepping back from the first item wraps to the last'
      );

      await triggerKeyEvent(last(), 'keydown', 'ArrowRight');
      assert.strictEqual(
        value.current,
        'day',
        'and stepping forward from the last wraps to the first'
      );
    });

    test('a control whose every item is disabled has no tab stop and cannot be moved', async function (assert) {
      let calls = 0;
      const onChange = (): void => {
        calls += 1;
      };

      await render(
        <template>
          <SegmentedControl
            @value="day"
            @onChange={{onChange}}
            aria-label="Range"
            as |Ctl|
          >
            <Ctl.Item @value="day" @isDisabled={{true}}>Day</Ctl.Item>
            <Ctl.Item @value="week" @isDisabled={{true}}>Week</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const items = findAll('[role="radio"]') as HTMLButtonElement[];
      assert.deepEqual(
        items.map((i) => i.tabIndex),
        [-1, -1],
        'nothing in the group is tabbable'
      );

      // test-helpers refuses to drive a natively-disabled element, so dispatch
      // straight at it -- listeners still run, which is the point.
      items[0]!.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true })
      );
      await settled();

      assert.strictEqual(calls, 0, 'and arrow keys select nothing');
    });

    test('resting ink is secondary to selected, and hover is scoped away from both selected and disabled items', async function (assert) {
      await render(
        <template>
          <SegmentedControl @defaultValue="week" aria-label="Range" as |Ctl|>
            <Ctl.Item @value="day">Day</Ctl.Item>
            <Ctl.Item @value="week">Week</Ctl.Item>
            <Ctl.Item @value="month" @isDisabled={{true}}>Month</Ctl.Item>
          </SegmentedControl>
        </template>
      );

      const [unselected, selected, disabled] = findAll(
        '[role="radio"]'
      ) as HTMLElement[];

      const resting = getComputedStyle(unselected!).color;

      assert.notStrictEqual(
        resting,
        getComputedStyle(selected!).color,
        'the resting ink is clearly secondary to the selected ink'
      );
      assert.strictEqual(
        getComputedStyle(disabled!).color,
        resting,
        'a disabled item rests at the same ink, dimmed by opacity rather than colour'
      );

      // The hover ink itself cannot be asserted from computed styles here: CSS
      // :hover follows the real pointer, and synthetic mouseenter/mouseover do
      // not set it. What is checkable is that the rule is scoped, which is the
      // part that regressed before -- an unscoped `hover:` ties on specificity
      // with the variants' `data-[selected=true]:` ink, leaving the winner to
      // Tailwind's emitted variant order. The rendered colours were verified in
      // a real browser: light 0.432 resting -> 0.326 hovered -> 0.234 selected.
      const hoverClass = [...unselected!.classList].find((c) =>
        c.includes('hover:text-')
      );
      assert.ok(hoverClass, 'the item carries a hover ink rule');
      assert.ok(
        hoverClass!.includes('data-[selected=false]') &&
          hoverClass!.includes('data-[disabled=false]'),
        `the hover rule is scoped away from selected and disabled items (${hoverClass})`
      );
    });
  }
);
