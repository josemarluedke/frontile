import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find, findAll, click } from '@ember/test-helpers';
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
  }
);
