import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click } from '@ember/test-helpers';
import { DrawerDragHandle } from 'frontile/overlays';

module(
  'Integration | Component | @frontile/overlays/Drawer::DragHandle',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders an accessible button and closes on press', async function (assert) {
      let pressed = 0;
      const onPress = () => {
        pressed += 1;
      };

      await render(
        <template>
          <DrawerDragHandle
            @onPress={{onPress}}
            @class="drawer__drag-handle"
            @barClass="drawer__drag-handle-bar"
            data-test-id="handle"
          />
        </template>
      );

      assert.dom('[data-test-id="handle"]').hasTagName('button');
      assert.dom('[data-test-id="handle"]').hasAttribute('type', 'button');
      assert
        .dom('[data-test-id="handle"]')
        .hasAttribute('aria-label', 'Close drawer');
      assert
        .dom('[data-test-id="handle"]')
        .hasAttribute('data-drawer-drag-handle');
      assert.dom('[data-test-id="handle"] .drawer__drag-handle-bar').exists();

      await click('[data-test-id="handle"]');
      assert.strictEqual(pressed, 1, 'onPress fired');
    });

    test('it accepts a custom label', async function (assert) {
      await render(
        <template>
          <DrawerDragHandle @label="Dismiss panel" data-test-id="handle" />
        </template>
      );

      assert
        .dom('[data-test-id="handle"]')
        .hasAttribute('aria-label', 'Dismiss panel');
    });
  }
);
