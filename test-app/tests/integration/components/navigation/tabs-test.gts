import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  find,
  click,
  findAll,
  focus,
  settled,
  triggerKeyEvent,
  waitUntil
} from '@ember/test-helpers';
import { cell } from 'ember-resources';
import { Tabs } from 'frontile';

module(
  'Integration | Component | Tabs | frontile/navigation',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders a labelled tablist', async function (assert) {
      await render(
        <template>
          <Tabs as |t|>
            <t.List @label="Account settings" />
          </Tabs>
        </template>
      );

      const list = find('[role="tablist"]');
      assert.dom(list).exists('renders a tablist');
      assert.dom(list).hasAria('label', 'Account settings');
      assert.dom(list).hasAria('orientation', 'horizontal');
      assert
        .dom('[role="tablist"] > span[aria-hidden="true"]')
        .exists('renders the indicator element');
    });

    test('controlled: @value drives which tab is selected', async function (assert) {
      const value = cell('security');

      await render(
        <template>
          <Tabs @value={{value.current}} as |t|>
            <t.List @label="Settings">
              <t.Tab @value="account">Account</t.Tab>
              <t.Tab @value="security">Security</t.Tab>
            </t.List>
          </Tabs>
        </template>
      );

      const tabs = findAll('[role="tab"]');
      assert.dom(tabs[1]!).hasAria('selected', 'true');
      assert.dom(tabs[0]!).hasAria('selected', 'false');
      assert.dom(tabs[1]!).hasAttribute('data-selected', 'true');
      assert.dom(tabs[0]!).hasAttribute('data-selected', 'false');
    });

    test('uncontrolled: @defaultValue seeds selection and clicking moves it', async function (assert) {
      const received: string[] = [];
      const onChange = (next: string): void => {
        received.push(next);
      };

      await render(
        <template>
          <Tabs @defaultValue="account" @onChange={{onChange}} as |t|>
            <t.List @label="Settings">
              <t.Tab @value="account">Account</t.Tab>
              <t.Tab @value="security">Security</t.Tab>
            </t.List>
          </Tabs>
        </template>
      );

      assert.dom(findAll('[role="tab"]')[0]!).hasAria('selected', 'true');

      await click(findAll('[role="tab"]')[1]!);

      assert.deepEqual(received, ['security'], 'onChange received the value');
      assert.dom(findAll('[role="tab"]')[1]!).hasAria('selected', 'true');
    });

    test('a disabled tab cannot be selected', async function (assert) {
      const received: string[] = [];
      const onChange = (next: string): void => {
        received.push(next);
      };

      await render(
        <template>
          <Tabs @defaultValue="account" @onChange={{onChange}} as |t|>
            <t.List @label="Settings">
              <t.Tab @value="account">Account</t.Tab>
              <t.Tab @value="billing" @isDisabled={{true}}>Billing</t.Tab>
            </t.List>
          </Tabs>
        </template>
      );

      const billing = findAll('[role="tab"]')[1]!;
      assert.dom(billing).hasAttribute('data-disabled', 'true');
      assert.dom(billing).hasAria('disabled', 'true');

      billing.dispatchEvent(
        new MouseEvent('click', { bubbles: true, cancelable: true })
      );

      assert.deepEqual(received, [], 'onChange was not called');
      assert.dom(findAll('[role="tab"]')[0]!).hasAria('selected', 'true');
    });

    test('controlled: a starting @value of undefined still means controlled', async function (assert) {
      // `undefined` is a legitimate value of the generic `T` -- "nothing is
      // selected" -- so it cannot also be the signal for "argument omitted".
      // `isControlled` checks `'value' in this.args`, not `!== undefined`,
      // precisely so a starting `@value={{undefined}}` stays controlled
      // rather than falling back to internal, uncontrolled tracking.
      const value = cell<string | undefined>(undefined);
      const received: string[] = [];
      const onChange = (next: string): void => {
        // Deliberately declines the change: a controlled consumer that
        // validates and says no.
        received.push(next);
      };

      await render(
        <template>
          <Tabs @value={{value.current}} @onChange={{onChange}} as |t|>
            <t.List @label="Settings">
              <t.Tab @value="account">Account</t.Tab>
              <t.Tab @value="security">Security</t.Tab>
            </t.List>
          </Tabs>
        </template>
      );

      const tabs = findAll('[role="tab"]');
      tabs.forEach((tab) => assert.dom(tab).hasAria('selected', 'false'));

      await click(tabs[1]!);

      assert.deepEqual(
        received,
        ['security'],
        'onChange still reports the pick'
      );
      findAll('[role="tab"]').forEach((tab) => {
        assert
          .dom(tab)
          .hasAria(
            'selected',
            'false',
            'but the declined change does not move the selection'
          );
      });
    });

    test('@isDisabled on Tabs disables every tab', async function (assert) {
      const received: string[] = [];
      const onChange = (next: string): void => {
        received.push(next);
      };

      await render(
        <template>
          <Tabs
            @defaultValue="account"
            @onChange={{onChange}}
            @isDisabled={{true}}
            as |t|
          >
            <t.List @label="Settings">
              <t.Tab @value="account">Account</t.Tab>
              <t.Tab @value="security">Security</t.Tab>
            </t.List>
          </Tabs>
        </template>
      );

      const tabs = findAll('[role="tab"]');
      tabs.forEach((tab) => {
        assert.dom(tab).hasAria('disabled', 'true');
        assert.dom(tab).hasAttribute('data-disabled', 'true');
      });

      tabs[1]!.dispatchEvent(
        new MouseEvent('click', { bubbles: true, cancelable: true })
      );

      assert.deepEqual(received, [], 'onChange was not called');
      assert.dom(tabs[0]!).hasAria('selected', 'true', 'selection unchanged');
      assert.dom(tabs[1]!).hasAria('selected', 'false');
    });

    test('@isFullWidth stretches the list and each tab', async function (assert) {
      await render(
        <template>
          <Tabs @defaultValue="account" @isFullWidth={{true}} as |t|>
            <t.List @label="Settings">
              <t.Tab @value="account">Account</t.Tab>
              <t.Tab @value="security">Security</t.Tab>
            </t.List>
          </Tabs>
        </template>
      );

      assert.dom('[role="tablist"]').hasClass('w-full');
      findAll('[role="tab"]').forEach((tab) => {
        assert.dom(tab).hasClass('flex-1');
      });
    });

    test('@isFullWidth actually fills a shrink-to-fit container', async function (assert) {
      // The class assertions above pass even when the layout is broken: the
      // list carries `w-full`, but `w-full` resolves against the Tabs wrapper,
      // and a wrapper with no width of its own collapses to its content inside
      // an `align-items: flex-start` parent. Measure the rendered width, which
      // is the thing consumers actually see.
      await render(
        <template>
          {{! template-lint-disable no-inline-styles }}
          {{! An inline style, not utility classes: the container has to be a
            known width and shrink-to-fit regardless of whether Tailwind
            scanned this test file, since that is the exact condition the
            assertion below depends on. }}
          <div
            id="wrap"
            style="width: 384px; display: flex; flex-direction: column; align-items: flex-start"
          >
            <Tabs @defaultValue="account" @isFullWidth={{true}} as |t|>
              <t.List @label="Settings">
                <t.Tab @value="account">Account</t.Tab>
                <t.Tab @value="security">Security</t.Tab>
              </t.List>
            </Tabs>
          </div>
        </template>
      );

      const wrap = find('#wrap') as HTMLElement;
      const list = find('[role="tablist"]') as HTMLElement;

      assert.strictEqual(
        list.offsetWidth,
        wrap.clientWidth,
        'the tab list spans the full width of its container'
      );
    });

    test('a vertical solid control squares off its corners', async function (assert) {
      // A pill radius on a tall narrow column renders as an oval blob. The
      // horizontal track is a pill; the vertical one must not be.
      await render(
        <template>
          <Tabs @defaultValue="account" @orientation="vertical" as |t|>
            <t.List @label="Settings">
              <t.Tab @value="account">Account</t.Tab>
              <t.Tab @value="security">Security</t.Tab>
              <t.Tab @value="billing">Billing</t.Tab>
            </t.List>
          </Tabs>
        </template>
      );

      const list = find('[role="tablist"]') as HTMLElement;
      const indicator = list.querySelector(
        'span[aria-hidden="true"]'
      ) as HTMLElement;
      const tab = find('[role="tab"]') as HTMLElement;

      for (const [name, el] of [
        ['track', list],
        ['indicator', indicator],
        ['tab', tab]
      ] as [string, HTMLElement][]) {
        assert.notStrictEqual(
          window.getComputedStyle(el).borderTopLeftRadius,
          '9999px',
          `the vertical ${name} does not keep the pill radius`
        );
      }
    });

    test('only the active panel is rendered, and ARIA round-trips', async function (assert) {
      await render(
        <template>
          <Tabs @defaultValue="account" as |t|>
            <t.List @label="Settings">
              <t.Tab @value="account">Account</t.Tab>
              <t.Tab @value="security">Security</t.Tab>
            </t.List>
            <t.Panel @value="account">Account panel</t.Panel>
            <t.Panel @value="security">Security panel</t.Panel>
          </Tabs>
        </template>
      );

      assert
        .dom('[role="tabpanel"]')
        .exists({ count: 1 }, 'one panel rendered');
      assert.dom('[role="tabpanel"]').hasText('Account panel');
      assert.dom('[role="tabpanel"]').hasAttribute('tabindex', '0');

      const tab = findAll('[role="tab"]')[0]!;
      const panel = find('[role="tabpanel"]')!;

      assert.strictEqual(
        tab.getAttribute('aria-controls'),
        panel.id,
        'the tab points at its panel'
      );
      assert.strictEqual(
        panel.getAttribute('aria-labelledby'),
        tab.id,
        'the panel points back at its tab'
      );

      await click(findAll('[role="tab"]')[1]!);
      assert.dom('[role="tabpanel"]').hasText('Security panel');
      assert.dom('[role="tabpanel"]').exists({ count: 1 });
    });

    test('values that stringify alike still get distinct ids', async function (assert) {
      // Both fixtures override `toString` to return the same string, "x".
      // Ids derived from the stringified value would collide and break
      // aria-controls.
      const a = { toString: (): string => 'x' };
      const b = { toString: (): string => 'x' };

      await render(
        <template>
          <Tabs @defaultValue={{a}} as |t|>
            <t.List @label="Objects">
              <t.Tab @value={{a}}>A</t.Tab>
              <t.Tab @value={{b}}>B</t.Tab>
            </t.List>
          </Tabs>
        </template>
      );

      const tabs = findAll('[role="tab"]');
      assert.notEqual(tabs[0]!.id, tabs[1]!.id, 'ids are distinct');
      assert.notEqual(
        tabs[0]!.getAttribute('aria-controls'),
        tabs[1]!.getAttribute('aria-controls'),
        'aria-controls targets are distinct'
      );
    });

    test('exactly one tab is in the tab order, and it is the selected one', async function (assert) {
      await render(
        <template>
          <Tabs @defaultValue="security" as |t|>
            <t.List @label="Settings">
              <t.Tab @value="account">Account</t.Tab>
              <t.Tab @value="security">Security</t.Tab>
              <t.Tab @value="billing">Billing</t.Tab>
            </t.List>
          </Tabs>
        </template>
      );

      const tabs = findAll('[role="tab"]');
      assert.dom(tabs[0]!).hasAttribute('tabindex', '-1');
      assert.dom(tabs[1]!).hasAttribute('tabindex', '0');
      assert.dom(tabs[2]!).hasAttribute('tabindex', '-1');
    });

    test('automatic activation: arrow keys move focus and selection', async function (assert) {
      await render(
        <template>
          <Tabs @defaultValue="account" as |t|>
            <t.List @label="Settings">
              <t.Tab @value="account">Account</t.Tab>
              <t.Tab @value="security">Security</t.Tab>
            </t.List>
          </Tabs>
        </template>
      );

      await focus(findAll('[role="tab"]')[0]!);
      await triggerKeyEvent(
        findAll('[role="tab"]')[0]!,
        'keydown',
        'ArrowRight'
      );

      assert.dom(findAll('[role="tab"]')[1]!).isFocused();
      assert.dom(findAll('[role="tab"]')[1]!).hasAria('selected', 'true');
    });

    test('manual activation: arrows move focus only, Enter selects', async function (assert) {
      await render(
        <template>
          <Tabs @defaultValue="account" @activationMode="manual" as |t|>
            <t.List @label="Settings">
              <t.Tab @value="account">Account</t.Tab>
              <t.Tab @value="security">Security</t.Tab>
            </t.List>
          </Tabs>
        </template>
      );

      await focus(findAll('[role="tab"]')[0]!);
      await triggerKeyEvent(
        findAll('[role="tab"]')[0]!,
        'keydown',
        'ArrowRight'
      );

      assert.dom(findAll('[role="tab"]')[1]!).isFocused();
      assert
        .dom(findAll('[role="tab"]')[0]!)
        .hasAria('selected', 'true', 'selection has not moved yet');

      await triggerKeyEvent(findAll('[role="tab"]')[1]!, 'keydown', 'Enter');
      assert.dom(findAll('[role="tab"]')[1]!).hasAria('selected', 'true');
    });

    test('arrow keys skip disabled tabs', async function (assert) {
      await render(
        <template>
          <Tabs @defaultValue="account" as |t|>
            <t.List @label="Settings">
              <t.Tab @value="account">Account</t.Tab>
              <t.Tab @value="billing" @isDisabled={{true}}>Billing</t.Tab>
              <t.Tab @value="security">Security</t.Tab>
            </t.List>
          </Tabs>
        </template>
      );

      await focus(findAll('[role="tab"]')[0]!);
      await triggerKeyEvent(
        findAll('[role="tab"]')[0]!,
        'keydown',
        'ArrowRight'
      );

      assert
        .dom(findAll('[role="tab"]')[2]!)
        .isFocused('focus jumped over the disabled tab');
    });

    test('Home and End jump to the first and last enabled tab', async function (assert) {
      await render(
        <template>
          <Tabs @defaultValue="security" as |t|>
            <t.List @label="Settings">
              <t.Tab @value="account">Account</t.Tab>
              <t.Tab @value="security">Security</t.Tab>
              <t.Tab @value="billing">Billing</t.Tab>
            </t.List>
          </Tabs>
        </template>
      );

      await focus(findAll('[role="tab"]')[1]!);

      await triggerKeyEvent(findAll('[role="tab"]')[1]!, 'keydown', 'End');
      assert.dom(findAll('[role="tab"]')[2]!).isFocused('End goes to the last');

      await triggerKeyEvent(findAll('[role="tab"]')[2]!, 'keydown', 'Home');
      assert
        .dom(findAll('[role="tab"]')[0]!)
        .isFocused('Home goes back to the first');
    });

    test('Home and End skip tabs disabled at either end', async function (assert) {
      // Four tabs with both ends disabled, so the enabled span is the middle
      // pair. Focus starts on the second of those, which means Home and End
      // each have somewhere to move to -- were the keys unhandled, or were
      // disabled tabs not skipped, focus would land somewhere else and these
      // assertions would fail rather than pass by standing still.
      await render(
        <template>
          <Tabs @defaultValue="security" as |t|>
            <t.List @label="Settings">
              <t.Tab @value="account" @isDisabled={{true}}>Account</t.Tab>
              <t.Tab @value="security">Security</t.Tab>
              <t.Tab @value="billing">Billing</t.Tab>
              <t.Tab @value="archive" @isDisabled={{true}}>Archive</t.Tab>
            </t.List>
          </Tabs>
        </template>
      );

      await focus(findAll('[role="tab"]')[2]!);

      await triggerKeyEvent(findAll('[role="tab"]')[2]!, 'keydown', 'Home');
      assert
        .dom(findAll('[role="tab"]')[1]!)
        .isFocused('Home lands on the first *enabled* tab, not the first tab');

      await triggerKeyEvent(findAll('[role="tab"]')[1]!, 'keydown', 'End');
      assert
        .dom(findAll('[role="tab"]')[2]!)
        .isFocused('and End on the last enabled one, not the last tab');
    });

    test('arrow keys wrap around at both ends', async function (assert) {
      await render(
        <template>
          <Tabs @defaultValue="account" as |t|>
            <t.List @label="Settings">
              <t.Tab @value="account">Account</t.Tab>
              <t.Tab @value="security">Security</t.Tab>
              <t.Tab @value="billing">Billing</t.Tab>
            </t.List>
          </Tabs>
        </template>
      );

      // Backwards off the first tab lands on the last.
      await focus(findAll('[role="tab"]')[0]!);
      await triggerKeyEvent(
        findAll('[role="tab"]')[0]!,
        'keydown',
        'ArrowLeft'
      );
      assert
        .dom(findAll('[role="tab"]')[2]!)
        .isFocused('ArrowLeft from the first wraps to the last');

      // And forwards off the last lands back on the first.
      await triggerKeyEvent(
        findAll('[role="tab"]')[2]!,
        'keydown',
        'ArrowRight'
      );
      assert
        .dom(findAll('[role="tab"]')[0]!)
        .isFocused('ArrowRight from the last wraps to the first');
    });

    test('vertical orientation uses the vertical arrow keys', async function (assert) {
      await render(
        <template>
          <Tabs @defaultValue="account" @orientation="vertical" as |t|>
            <t.List @label="Settings">
              <t.Tab @value="account">Account</t.Tab>
              <t.Tab @value="security">Security</t.Tab>
            </t.List>
          </Tabs>
        </template>
      );

      assert.dom('[role="tablist"]').hasAria('orientation', 'vertical');

      await focus(findAll('[role="tab"]')[0]!);
      await triggerKeyEvent(
        findAll('[role="tab"]')[0]!,
        'keydown',
        'ArrowDown'
      );
      assert.dom(findAll('[role="tab"]')[1]!).isFocused();
    });

    test('the indicator measures the selected tab and animates between tabs', async function (assert) {
      await render(
        <template>
          <Tabs @defaultValue="account" as |t|>
            <t.List @label="Settings">
              <t.Tab @value="account">Account</t.Tab>
              <t.Tab @value="security">A much longer label</t.Tab>
            </t.List>
          </Tabs>
        </template>
      );

      const list = find('[role="tablist"]')!;
      const indicator = list.querySelector('span[aria-hidden="true"]')!;

      await waitUntil(() => list.hasAttribute('data-fr-si-ready'), {
        timeout: 1000
      });

      assert.strictEqual(
        (list as HTMLElement).style.getPropertyValue('--fr-si-width'),
        `${(findAll('[role="tab"]')[0] as HTMLElement).offsetWidth}px`,
        'the indicator is sized to the selected tab'
      );

      const computed = window.getComputedStyle(indicator);
      const transitioned = computed.transitionProperty
        .split(',')
        .map((property) => property.trim());

      // Tailwind v4 compiles `translate-x-*` to the standalone `translate`
      // property, not `transform`. Omitting `translate` from the transition
      // list is what made the SegmentedControl indicator snap instead of
      // slide, so assert against the *computed* list, not the class string.
      const positionProperty =
        computed.translate && computed.translate !== 'none'
          ? 'translate'
          : 'transform';

      assert.ok(
        transitioned.includes(positionProperty),
        `the transition list (${computed.transitionProperty}) includes ${positionProperty}`
      );
      assert.ok(transitioned.includes('width'), 'and transitions width');

      // Reading the computed style establishes the before-change value, so the
      // browser has something to transition from.
      void computed[positionProperty];

      await click(findAll('[role="tab"]')[1]!);

      assert.ok(
        indicator
          .getAnimations()
          .some((animation) => animation.playState === 'running'),
        'moving the selection starts a running animation'
      );
    });

    test('the ready flag lands after the first measurement', async function (assert) {
      await render(
        <template>
          <Tabs @defaultValue="account" as |t|>
            <t.List @label="Settings">
              <t.Tab @value="account">Account</t.Tab>
            </t.List>
          </Tabs>
        </template>
      );

      const list = find('[role="tablist"]') as HTMLElement;
      const indicator = list.querySelector(
        'span[aria-hidden="true"]'
      ) as HTMLElement;

      assert
        .dom(list)
        .hasAttribute(
          'data-fr-si-ready',
          '',
          'the ready flag is set once measured'
        );
      assert.strictEqual(
        window.getComputedStyle(indicator).opacity,
        '1',
        'and the indicator is visible while it is set'
      );

      // The flag is only worth setting if its absence actually hides the
      // indicator. Taking it away is the one way to observe the pre-ready
      // state deterministically -- it lands within a frame of the first
      // measurement, so a fresh render cannot be caught before it. Without
      // this, dropping `opacity-0` from the theme would leave the indicator
      // flying in from the container origin on first paint and no test would
      // notice.
      list.removeAttribute('data-fr-si-ready');
      await settled();

      assert.strictEqual(
        window.getComputedStyle(indicator).opacity,
        '0',
        'and hidden whenever it is not'
      );
    });

    test('the underline variant pins a bar to the bottom edge', async function (assert) {
      await render(
        <template>
          <Tabs @variant="underline" @defaultValue="account" as |t|>
            <t.List @label="Settings">
              <t.Tab @value="account">Account</t.Tab>
              <t.Tab @value="security">Security</t.Tab>
            </t.List>
          </Tabs>
        </template>
      );

      const list = find('[role="tablist"]')!;
      const indicator = list.querySelector('span[aria-hidden="true"]')!;

      await waitUntil(() => list.hasAttribute('data-fr-si-ready'), {
        timeout: 1000
      });

      // Select the second tab: the first tab's offsetLeft is 0px, which
      // would make a translate assertion pass even with the positioning
      // class missing entirely.
      await click(findAll('[role="tab"]')[1]!);
      const secondTab = findAll('[role="tab"]')[1] as HTMLElement;

      // `translate` is a transitioned property (200ms), so reading it right
      // after the click can catch it mid-animation. Wait for it to settle at
      // the selected tab's offset before asserting against it.
      await waitUntil(
        () =>
          window
            .getComputedStyle(indicator)
            .translate.includes(`${secondTab.offsetLeft}px`),
        { timeout: 1000 }
      );

      const computed = window.getComputedStyle(indicator);

      assert.strictEqual(
        computed.bottom,
        '0px',
        'the bar sits on the bottom edge'
      );
      assert.notStrictEqual(
        computed.height,
        '0px',
        'the bar has a height of its own rather than the tab height'
      );
      // `computed.width` is the fractional used value from getComputedStyle,
      // while `offsetWidth` is rounded to an integer. On macOS the fraction
      // happens to land on a whole pixel so a strict string comparison
      // passes; on Linux CI, different font metrics land the tab's real
      // width off the whole pixel (e.g. 116.156px vs offsetWidth's rounded
      // 117). Compare against the tab's own fractional computed width
      // instead: `getBoundingClientRect()` returns the post-zoom rendered
      // size, which the ember-testing container's `zoom` can scale by a
      // factor unrelated to the indicator's own computed style, whereas
      // both computed-style reads live in the same coordinate space.
      const secondTabWidth = parseFloat(
        window.getComputedStyle(secondTab).width
      );
      assert.pushResult({
        result: Math.abs(parseFloat(computed.width) - secondTabWidth) < 0.75,
        actual: computed.width,
        expected: `~${secondTabWidth}px`,
        message: 'the bar is as wide as the selected tab'
      });
      assert.ok(
        computed.translate.includes(`${secondTab.offsetLeft}px`),
        `the bar's translate (${computed.translate}) reflects the selected ` +
          `tab's offsetLeft (${secondTab.offsetLeft}px)`
      );
    });

    test('the underline variant, vertical, pins a bar to the inline start', async function (assert) {
      await render(
        <template>
          <Tabs
            @variant="underline"
            @orientation="vertical"
            @defaultValue="account"
            as |t|
          >
            <t.List @label="Settings">
              <t.Tab @value="account">Account</t.Tab>
              <t.Tab @value="security">Security</t.Tab>
            </t.List>
          </Tabs>
        </template>
      );

      const list = find('[role="tablist"]')!;
      const indicator = list.querySelector('span[aria-hidden="true"]')!;

      await waitUntil(() => list.hasAttribute('data-fr-si-ready'), {
        timeout: 1000
      });

      // Select the second tab: the first tab's offsetTop is 0px, which
      // would make a translate assertion pass even with the vertical
      // compound variant missing entirely.
      await click(findAll('[role="tab"]')[1]!);
      const secondTab = findAll('[role="tab"]')[1] as HTMLElement;

      // `translate` is a transitioned property (200ms), so reading it right
      // after the click can catch it mid-animation. Wait for it to settle at
      // the selected tab's offset before asserting against it.
      await waitUntil(
        () =>
          window
            .getComputedStyle(indicator)
            .translate.includes(`${secondTab.offsetTop}px`),
        { timeout: 1000 }
      );

      const computed = window.getComputedStyle(indicator);
      assert.strictEqual(
        computed.width,
        '2px',
        'the bar is the thin vertical accent (w-0.5), not the full tab width'
      );
      // Same fraction-vs-rounded-integer mismatch as the horizontal underline
      // test above: `computed.height` is the fractional used value while
      // `offsetHeight` is rounded, and differing font metrics on Linux CI can
      // put the real height off the whole pixel. Compare against the tab's
      // own fractional computed height (not `getBoundingClientRect()`, whose
      // post-zoom rendered size the ember-testing container's `zoom` can
      // scale independently of a computed-style read) within a sub-pixel
      // tolerance instead of an exact string match.
      const secondTabHeight = parseFloat(
        window.getComputedStyle(secondTab).height
      );
      assert.pushResult({
        result: Math.abs(parseFloat(computed.height) - secondTabHeight) < 0.75,
        actual: computed.height,
        expected: `~${secondTabHeight}px`,
        message: 'the bar is as tall as the selected tab'
      });
      assert.ok(
        computed.translate.includes(`${secondTab.offsetTop}px`),
        `the bar's translate (${computed.translate}) reflects the selected ` +
          `tab's offsetTop (${secondTab.offsetTop}px)`
      );
    });
  }
);
