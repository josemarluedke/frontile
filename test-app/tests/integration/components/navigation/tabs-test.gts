import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find } from '@ember/test-helpers';
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
  }
);
