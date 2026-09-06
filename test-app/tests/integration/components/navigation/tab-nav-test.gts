import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find, findAll, waitUntil } from '@ember/test-helpers';
import { TabNav } from 'frontile';

module(
  'Integration | Component | TabNav | @frontile/navigation',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders a labelled nav landmark', async function (assert) {
      await render(
        <template>
          <TabNav @label="Sections" as |nav|>
            <a
              href="/one"
              class={{nav.itemClass}}
              {{nav.setupItem true}}
            >One</a>
          </TabNav>
        </template>
      );

      assert.dom('nav').exists('renders a nav landmark');
      assert.dom('nav').hasAria('label', 'Sections');
    });

    test('a consumer-supplied element gets aria-current, data-selected and the indicator', async function (assert) {
      await render(
        <template>
          <TabNav @label="Sections" as |nav|>
            <a
              href="/one"
              class={{nav.itemClass}}
              {{nav.setupItem false}}
            >One</a>
            <a
              href="/two"
              class={{nav.itemClass}}
              {{nav.setupItem true}}
            >Two</a>
          </TabNav>
        </template>
      );

      const links = findAll('nav a');
      assert.dom(links[1]!).hasAttribute('aria-current', 'page');
      assert.dom(links[1]!).hasAttribute('data-selected', 'true');
      assert.dom(links[0]!).hasAttribute('data-selected', 'false');
      assert
        .dom(links[0]!)
        .doesNotHaveAttribute(
          'aria-current',
          'inactive links carry no aria-current at all'
        );

      const nav = find('nav')!;
      await waitUntil(() => nav.hasAttribute('data-fr-si-ready'), {
        timeout: 1000
      });
      assert.strictEqual(
        nav.style.getPropertyValue('--fr-si-width'),
        `${(links[1] as HTMLElement).offsetWidth}px`,
        'the indicator measured the active link'
      );
    });

    test('every link stays in the tab order and arrow keys are not intercepted', async function (assert) {
      // The deliberate opposite of Tabs. Nav links are links: removing them
      // from the tab order or hijacking the arrow keys would be a regression.
      await render(
        <template>
          <TabNav @label="Sections" as |nav|>
            <a
              href="/one"
              class={{nav.itemClass}}
              {{nav.setupItem true}}
            >One</a>
            <a
              href="/two"
              class={{nav.itemClass}}
              {{nav.setupItem false}}
            >Two</a>
          </TabNav>
        </template>
      );

      for (const link of findAll('nav a')) {
        assert
          .dom(link)
          .doesNotHaveAttribute('tabindex', 'no roving tabindex is applied');
      }

      const first = findAll('nav a')[0]!;
      const event = new KeyboardEvent('keydown', {
        key: 'ArrowRight',
        bubbles: true,
        cancelable: true
      });
      first.dispatchEvent(event);

      assert.false(event.defaultPrevented, 'ArrowRight is left to the browser');
    });
  }
);
