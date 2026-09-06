import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  find,
  click,
  findAll,
  focus,
  triggerKeyEvent,
  waitUntil
} from '@ember/test-helpers';
import { cell } from 'ember-resources';
import { Tabs } from 'frontile';

module(
  'Integration | Component | Tabs | @frontile/navigation',
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

      // `data-fr-si-ready` gates opacity, so the class is only meaningful in
      // combination with it. Assert the gate exists rather than the opacity.
      assert
        .dom('[role="tablist"]')
        .hasAttribute(
          'data-fr-si-ready',
          '',
          'the ready flag is set once measured'
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
      assert.strictEqual(
        computed.width,
        `${secondTab.offsetWidth}px`,
        'the bar is as wide as the selected tab'
      );
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
      assert.strictEqual(
        computed.height,
        `${secondTab.offsetHeight}px`,
        'the bar is as tall as the selected tab'
      );
      assert.ok(
        computed.translate.includes(`${secondTab.offsetTop}px`),
        `the bar's translate (${computed.translate}) reflects the selected ` +
          `tab's offsetTop (${secondTab.offsetTop}px)`
      );
    });
  }
);
