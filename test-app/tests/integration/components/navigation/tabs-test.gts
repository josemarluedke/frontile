import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find, click, findAll } from '@ember/test-helpers';
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
  }
);
