import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, settled } from '@ember/test-helpers';
import { Collapsible } from 'frontile';
import { cell } from 'ember-resources';

module(
  'Integration | Component | @frontile/utilities/Collapsible',
  function (hooks) {
    setupRenderingTest(hooks);

    test('renders content and starts closed', async function (assert) {
      const isOpen = cell(false);
      await render(
        <template>
          <Collapsible @isOpen={{isOpen.current}} data-test-id="collapsible">
            Content
          </Collapsible>
        </template>
      );

      assert.dom('[data-test-id=collapsible]').hasText('Content');
      assert.dom('[data-test-id=collapsible]').hasStyle({ height: '0px' });
      assert.dom('[data-test-id=collapsible]').hasStyle({ opacity: '0' });
      assert.dom('[data-test-id=collapsible]').hasStyle({ overflow: 'hidden' });
    });

    test('renders content and starts open', async function (assert) {
      const isOpen = cell(true);
      await render(
        <template>
          <Collapsible @isOpen={{isOpen.current}} data-test-id="collapsible">
            Content
          </Collapsible>
        </template>
      );

      assert.dom('[data-test-id=collapsible]').hasText('Content');
      assert
        .dom('[data-test-id=collapsible]')
        .doesNotHaveStyle({ height: '0px' });
      assert.dom('[data-test-id=collapsible]').hasStyle({ opacity: '1' });
      assert
        .dom('[data-test-id=collapsible]')
        .hasStyle({ overflow: 'visible' });
    });

    test('expands content when opened; closes content when closed', async function (assert) {
      const isOpen = cell(false);
      await render(
        <template>
          <Collapsible @isOpen={{isOpen.current}} data-test-id="collapsible">
            Content
          </Collapsible>
        </template>
      );

      isOpen.current = true;
      await settled();

      assert.dom('[data-test-id=collapsible]').hasStyle({ opacity: '1' });
      assert.dom('[data-test-id=collapsible]').hasText('Content');
      assert
        .dom('[data-test-id=collapsible]')
        .hasStyle({ overflow: 'visible' });
      assert
        .dom('[data-test-id=collapsible]')
        .doesNotHaveStyle({ height: '0px' });

      isOpen.current = false;
      await settled();

      assert.dom('[data-test-id=collapsible]').hasStyle({ opacity: '0' });
      assert.dom('[data-test-id=collapsible]').hasStyle({ height: '0px' });
      assert.dom('[data-test-id=collapsible]').hasStyle({ overflow: 'hidden' });
    });

    test('renders initial height when set', async function (assert) {
      const isOpen = cell(false);
      await render(
        <template>
          <Collapsible
            @isOpen={{isOpen.current}}
            @initialHeight="2px"
            data-test-id="collapsible"
          >
            Content
          </Collapsible>
        </template>
      );

      assert.dom('[data-test-id=collapsible]').hasText('Content');
      assert.dom('[data-test-id=collapsible]').hasStyle({ height: '2px' });
      assert.dom('[data-test-id=collapsible]').hasStyle({ opacity: '1' });
      assert.dom('[data-test-id=collapsible]').hasStyle({ overflow: 'hidden' });

      isOpen.current = true;
      await settled();

      assert.dom('[data-test-id=collapsible]').hasStyle({ opacity: '1' });
      assert
        .dom('[data-test-id=collapsible]')
        .hasStyle({ overflow: 'visible' });
      assert.dom('[data-test-id=collapsible]').hasText('Content');
      assert
        .dom('[data-test-id=collapsible]')
        .doesNotHaveStyle({ height: '2px' });

      isOpen.current = false;
      await settled();

      assert.dom('[data-test-id=collapsible]').hasStyle({ opacity: '1' });
      assert.dom('[data-test-id=collapsible]').hasStyle({ height: '2px' });
      assert.dom('[data-test-id=collapsible]').hasStyle({ overflow: 'hidden' });
    });
  }
);
