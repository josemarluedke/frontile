import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find, findAll } from '@ember/test-helpers';
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
  }
);
