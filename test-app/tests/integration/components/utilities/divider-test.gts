import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { Divider } from 'frontile';

module(
  'Integration | Component | @frontile/utilities/Divider',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders an hr by default', async function (assert) {
      await render(<template><Divider /></template>);

      assert.dom('[data-test-id="divider"]').hasTagName('hr');
      assert.dom('[data-test-id="divider"]').hasAttribute('role', 'separator');
    });

    test('a vertical divider renders a div', async function (assert) {
      await render(<template><Divider @orientation="vertical" /></template>);

      assert.dom('[data-test-id="divider"]').hasTagName('div');
    });

    // The separator role defaults to horizontal, so a vertical divider that
    // does not say so is reported the wrong way round. `<hr>` needs no such
    // attribute — its orientation is implicit.
    test('it reports its orientation', async function (assert) {
      await render(
        <template>
          <Divider data-test-horizontal />
          <Divider @orientation="vertical" data-test-vertical />
        </template>
      );

      assert
        .dom('[data-test-vertical]')
        .hasAttribute('aria-orientation', 'vertical');
      assert.dom('[data-test-horizontal]').hasNoAttribute('aria-orientation');
    });

    // The theme has always had an `orientation` variant, but the component did
    // not pass it — so a vertical divider rendered a <div> that was still
    // styled `w-full h-px`, i.e. a horizontal line.
    test('it applies the orientation styles', async function (assert) {
      await render(
        <template>
          <Divider data-test-horizontal />
          <Divider @orientation="vertical" data-test-vertical />
        </template>
      );

      assert.dom('[data-test-horizontal]').hasClass('w-full');
      assert.dom('[data-test-horizontal]').hasClass('h-px');
      assert.dom('[data-test-vertical]').hasClass('h-full');
      assert.dom('[data-test-vertical]').hasClass('w-px');
    });

    test('@as overrides the rendered tag', async function (assert) {
      await render(<template><Divider @as="span" /></template>);

      assert.dom('[data-test-id="divider"]').hasTagName('span');
    });
  }
);
