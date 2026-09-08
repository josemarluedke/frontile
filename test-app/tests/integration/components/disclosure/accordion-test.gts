import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find, findAll, click, settled } from '@ember/test-helpers';
import { array } from '@ember/helper';
import { cell } from 'ember-resources';
import { Accordion } from 'frontile';

module(
  'Integration | Component | Accordion | frontile/disclosure',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders each item with APG heading/trigger/region wiring', async function (assert) {
      await render(
        <template>
          <Accordion as |a|>
            <a.Item @title="Shipping">Three to five days.</a.Item>
            <a.Item @title="Returns">Thirty days.</a.Item>
          </Accordion>
        </template>
      );

      assert.dom('[data-fr-accordion]').exists('renders the root');

      const triggers = findAll('[data-fr-accordion-trigger]');
      assert.strictEqual(triggers.length, 2, 'renders one trigger per item');

      const first = triggers[0]!;
      assert.dom(first).hasTagName('button');
      assert.dom(first).hasAttribute('type', 'button');
      assert.dom(first).hasAria('expanded', 'false', 'starts collapsed');
      assert.dom(first).hasAttribute('data-open', 'false');
      assert.dom(first).containsText('Shipping');

      assert
        .dom('h3 > [data-fr-accordion-trigger]')
        .exists('the trigger sits inside an h3 by default');

      const panelId = first.getAttribute('aria-controls');
      assert.ok(panelId, 'trigger points at a panel');

      const panel = document.getElementById(panelId!);
      assert.dom(panel).exists('the panel it points at exists');
      assert.dom(panel).hasAttribute('role', 'region');
      assert.dom(panel).hasAria('labelledby', first.id);
      assert.dom(panel).containsText('Three to five days.');
    });

    test('@headingLevel changes the heading tag', async function (assert) {
      await render(
        <template>
          <Accordion @headingLevel={{2}} as |a|>
            <a.Item @title="Shipping">Three to five days.</a.Item>
          </Accordion>
        </template>
      );

      assert.dom('h2 > [data-fr-accordion-trigger]').exists();
      assert.dom('h3 > [data-fr-accordion-trigger]').doesNotExist();
    });

    test('@subtitle renders alongside the title', async function (assert) {
      await render(
        <template>
          <Accordion as |a|>
            <a.Item
              @title="Billing"
              @subtitle="Plans and invoices"
            >Monthly.</a.Item>
          </Accordion>
        </template>
      );

      assert.dom('[data-fr-accordion-trigger]').containsText('Billing');
      assert
        .dom('[data-fr-accordion-trigger]')
        .containsText('Plans and invoices');
    });

    test('each item gets a unique id without any @key', async function (assert) {
      await render(
        <template>
          <Accordion as |a|>
            <a.Item @title="One">1</a.Item>
            <a.Item @title="Two">2</a.Item>
          </Accordion>
        </template>
      );

      const [a, b] = findAll('[data-fr-accordion-trigger]');
      assert.notStrictEqual(a!.id, b!.id, 'trigger ids differ');
      assert.notStrictEqual(
        a!.getAttribute('aria-controls'),
        b!.getAttribute('aria-controls'),
        'panel ids differ'
      );
      assert.ok(find('[data-fr-accordion]'), 'root still renders');
    });

    test('single mode: opening one item closes the previous', async function (assert) {
      await render(
        <template>
          <Accordion as |a|>
            <a.Item @title="One">First body</a.Item>
            <a.Item @title="Two">Second body</a.Item>
          </Accordion>
        </template>
      );

      const triggers = findAll('[data-fr-accordion-trigger]');

      await click(triggers[0]!);
      assert.dom(triggers[0]!).hasAria('expanded', 'true');
      assert.dom(triggers[1]!).hasAria('expanded', 'false');

      await click(triggers[1]!);
      assert.dom(triggers[0]!).hasAria('expanded', 'false', 'the first closed');
      assert.dom(triggers[1]!).hasAria('expanded', 'true');
    });

    test('single mode: clicking the open item closes it', async function (assert) {
      await render(
        <template>
          <Accordion as |a|>
            <a.Item @title="One">First body</a.Item>
          </Accordion>
        </template>
      );

      const trigger = find('[data-fr-accordion-trigger]')!;

      await click(trigger);
      assert.dom(trigger).hasAria('expanded', 'true');

      await click(trigger);
      assert.dom(trigger).hasAria('expanded', 'false');
    });

    test('@isCollapsible={{false}} keeps the open item open', async function (assert) {
      await render(
        <template>
          <Accordion @isCollapsible={{false}} as |a|>
            <a.Item @title="One">First body</a.Item>
            <a.Item @title="Two">Second body</a.Item>
          </Accordion>
        </template>
      );

      const triggers = findAll('[data-fr-accordion-trigger]');

      await click(triggers[0]!);
      await click(triggers[0]!);
      assert
        .dom(triggers[0]!)
        .hasAria('expanded', 'true', 'cannot close the only open item');

      await click(triggers[1]!);
      assert.dom(triggers[1]!).hasAria('expanded', 'true', 'can still move');
      assert.dom(triggers[0]!).hasAria('expanded', 'false');
    });

    test('item @isDefaultOpen seeds the open item with no keys anywhere', async function (assert) {
      await render(
        <template>
          <Accordion as |a|>
            <a.Item @title="One">First body</a.Item>
            <a.Item @title="Two" @isDefaultOpen={{true}}>Second body</a.Item>
          </Accordion>
        </template>
      );

      const triggers = findAll('[data-fr-accordion-trigger]');
      assert.dom(triggers[1]!).hasAria('expanded', 'true');
      assert.dom(triggers[0]!).hasAria('expanded', 'false');
    });

    test('single mode: with two @isDefaultOpen items, the first in document order wins', async function (assert) {
      await render(
        <template>
          <Accordion as |a|>
            <a.Item @title="One" @isDefaultOpen={{true}}>First body</a.Item>
            <a.Item @title="Two" @isDefaultOpen={{true}}>Second body</a.Item>
          </Accordion>
        </template>
      );

      const triggers = findAll('[data-fr-accordion-trigger]');
      assert.dom(triggers[0]!).hasAria('expanded', 'true');
      assert.dom(triggers[1]!).hasAria('expanded', 'false');
    });

    test('multiple mode keeps several items open', async function (assert) {
      await render(
        <template>
          <Accordion @selectionMode="multiple" as |a|>
            <a.Item @title="One">First body</a.Item>
            <a.Item @title="Two">Second body</a.Item>
          </Accordion>
        </template>
      );

      const triggers = findAll('[data-fr-accordion-trigger]');

      await click(triggers[0]!);
      await click(triggers[1]!);

      assert.dom(triggers[0]!).hasAria('expanded', 'true');
      assert.dom(triggers[1]!).hasAria('expanded', 'true');

      await click(triggers[0]!);
      assert.dom(triggers[0]!).hasAria('expanded', 'false');
      assert
        .dom(triggers[1]!)
        .hasAria('expanded', 'true', 'the other stays open');
    });

    test('multiple mode: all @isDefaultOpen items start open', async function (assert) {
      await render(
        <template>
          <Accordion @selectionMode="multiple" as |a|>
            <a.Item @title="One" @isDefaultOpen={{true}}>First body</a.Item>
            <a.Item @title="Two" @isDefaultOpen={{true}}>Second body</a.Item>
            <a.Item @title="Three">Third body</a.Item>
          </Accordion>
        </template>
      );

      const triggers = findAll('[data-fr-accordion-trigger]');
      assert.dom(triggers[0]!).hasAria('expanded', 'true');
      assert.dom(triggers[1]!).hasAria('expanded', 'true');
      assert.dom(triggers[2]!).hasAria('expanded', 'false');
    });

    test('uncontrolled: @defaultKeys seeds the open items and wins over @isDefaultOpen', async function (assert) {
      await render(
        <template>
          <Accordion @defaultKeys={{array "two"}} as |a|>
            <a.Item @key="one" @title="One" @isDefaultOpen={{true}}>First body</a.Item>
            <a.Item @key="two" @title="Two">Second body</a.Item>
          </Accordion>
        </template>
      );

      const triggers = findAll('[data-fr-accordion-trigger]');
      assert
        .dom(triggers[1]!)
        .hasAria('expanded', 'true', '@defaultKeys took precedence');
      assert.dom(triggers[0]!).hasAria('expanded', 'false');
    });

    test('@onChange reports the new key set in both modes', async function (assert) {
      const calls: string[][] = [];
      const onChange = (keys: string[]): void => {
        calls.push(keys);
      };

      await render(
        <template>
          <Accordion @selectionMode="multiple" @onChange={{onChange}} as |a|>
            <a.Item @key="one" @title="One">First body</a.Item>
            <a.Item @key="two" @title="Two">Second body</a.Item>
          </Accordion>
        </template>
      );

      const triggers = findAll('[data-fr-accordion-trigger]');
      await click(triggers[0]!);
      await click(triggers[1]!);
      await click(triggers[0]!);

      assert.deepEqual(calls, [['one'], ['one', 'two'], ['two']]);
    });

    test('controlled: @keys governs, and clicking alone changes nothing', async function (assert) {
      const keys = cell<string[]>(['two']);

      await render(
        <template>
          <Accordion @keys={{keys.current}} as |a|>
            <a.Item @key="one" @title="One">First body</a.Item>
            <a.Item @key="two" @title="Two">Second body</a.Item>
          </Accordion>
        </template>
      );

      const triggers = findAll('[data-fr-accordion-trigger]');
      assert.dom(triggers[1]!).hasAria('expanded', 'true');

      await click(triggers[0]!);
      assert
        .dom(triggers[0]!)
        .hasAria('expanded', 'false', 'the component did not self-update');

      keys.current = ['one'];
      await settled();
      assert.dom(triggers[0]!).hasAria('expanded', 'true');
      assert.dom(triggers[1]!).hasAria('expanded', 'false');
    });

    test('controlled: @keys={{undefined}} is controlled-with-nothing-open', async function (assert) {
      await render(
        <template>
          <Accordion @keys={{undefined}} as |a|>
            <a.Item @key="one" @title="One" @isDefaultOpen={{true}}>First body</a.Item>
          </Accordion>
        </template>
      );

      const trigger = find('[data-fr-accordion-trigger]')!;
      assert
        .dom(trigger)
        .hasAria(
          'expanded',
          'false',
          '@isDefaultOpen is ignored when controlled'
        );

      await click(trigger);
      assert.dom(trigger).hasAria('expanded', 'false', 'still controlled');
    });

    test('a disabled item cannot be toggled', async function (assert) {
      const calls: string[][] = [];
      const onChange = (keys: string[]): void => {
        calls.push(keys);
      };

      await render(
        <template>
          <Accordion @onChange={{onChange}} as |a|>
            <a.Item @title="One" @isDisabled={{true}}>First body</a.Item>
            <a.Item @title="Two">Second body</a.Item>
          </Accordion>
        </template>
      );

      const triggers = findAll('[data-fr-accordion-trigger]');
      assert.dom(triggers[0]!).hasAria('disabled', 'true');
      assert.dom(triggers[0]!).hasAttribute('data-disabled', 'true');

      // A per-item disabled trigger keeps its pointer events -- only the
      // group-level `@isDisabled` variant sets `pointer-events-none` -- so a
      // real click lands on the handler and exercises the guard in `toggle`.
      await click(triggers[0]!);
      assert.dom(triggers[0]!).hasAria('expanded', 'false');
      assert.deepEqual(calls, [], '@onChange never fired for a disabled item');

      await click(triggers[1]!);
      assert.dom(triggers[1]!).hasAria('expanded', 'true', 'others still work');
    });

    test('@isDisabled on the accordion disables every item', async function (assert) {
      const calls: string[][] = [];
      const onChange = (keys: string[]): void => {
        calls.push(keys);
      };

      await render(
        <template>
          <Accordion @isDisabled={{true}} @onChange={{onChange}} as |a|>
            <a.Item @title="One">First body</a.Item>
            <a.Item @title="Two">Second body</a.Item>
          </Accordion>
        </template>
      );

      const triggers = findAll('[data-fr-accordion-trigger]');
      assert.dom(triggers[0]!).hasAria('disabled', 'true');
      assert.dom(triggers[1]!).hasAria('disabled', 'true');

      // The theme puts `pointer-events-none` on a group-disabled trigger, so a
      // hit-tested click would assert the CSS rather than the guard in
      // `toggle`. A native `.click()` bypasses hit-testing and reaches the
      // handler, which is the thing under test: delete the guard and this
      // fails.
      triggers[0]!.click();
      await settled();

      assert.dom(triggers[0]!).hasAria('expanded', 'false');
      assert.deepEqual(calls, [], '@onChange never fired while group-disabled');
    });
  }
);
