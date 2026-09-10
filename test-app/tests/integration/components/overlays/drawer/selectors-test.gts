import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find } from '@ember/test-helpers';
import { Drawer } from 'frontile/overlays';
import {
  DRAWER_BODY_ATTRIBUTE,
  DRAWER_BODY_SELECTOR,
  DRAWER_DRAG_HANDLE_ATTRIBUTE,
  DRAWER_DRAG_HANDLE_SELECTOR
} from 'frontile/components/overlays/drawer/selectors';
import { cell } from 'ember-resources';

// A template cannot bind an attribute's *name*, so the drawer's parts write
// these attributes as literals while `drawer.gts` looks them up through the
// shared constants. Nothing in the type system connects the two: renaming an
// attribute leaves the selectors pointing at markup that no longer exists, and
// the only symptom is a drag that silently never starts. These tests are that
// connection.
module(
  'Integration | Component | @frontile/overlays/Drawer::selectors',
  function (hooks) {
    setupRenderingTest(hooks);

    test('the body carries the attribute its selector looks for', async function (assert) {
      const isOpen = cell(true);

      await render(
        <template>
          <Drawer
            @isOpen={{isOpen.current}}
            @disableTransitions={{true}}
            data-test-id="drawer"
            as |d|
          >
            <d.Header>My Header</d.Header>
            <d.Body>My Content</d.Body>
          </Drawer>
        </template>
      );

      const body = find(`[data-test-id="drawer"] ${DRAWER_BODY_SELECTOR}`);

      assert.ok(
        body,
        `the body is findable by ${DRAWER_BODY_SELECTOR}, the selector passed ` +
          `to dragToDismiss as scrollSelector`
      );
      assert.ok(
        body?.hasAttribute(DRAWER_BODY_ATTRIBUTE),
        `and carries ${DRAWER_BODY_ATTRIBUTE}`
      );
    });

    test('the drag handle carries the attribute its selector looks for', async function (assert) {
      const isOpen = cell(true);

      await render(
        <template>
          <Drawer
            @isOpen={{isOpen.current}}
            @placement="bottom"
            @disableTransitions={{true}}
            data-test-id="drawer"
            as |d|
          >
            <d.Header>My Header</d.Header>
            <d.Body>My Content</d.Body>
          </Drawer>
        </template>
      );

      const handle = find(
        `[data-test-id="drawer"] ${DRAWER_DRAG_HANDLE_SELECTOR}`
      );

      assert.ok(
        handle,
        `the handle is findable by ${DRAWER_DRAG_HANDLE_SELECTOR}, the ` +
          `selector passed to dragToDismiss as handleSelector`
      );
      assert.ok(
        handle?.hasAttribute(DRAWER_DRAG_HANDLE_ATTRIBUTE),
        `and carries ${DRAWER_DRAG_HANDLE_ATTRIBUTE}`
      );
    });
  }
);
