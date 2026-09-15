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

      assert.dom('[data-component="divider"]').hasTagName('hr');
      assert
        .dom('[data-component="divider"]')
        .hasAttribute('role', 'separator');
    });

    test('a vertical divider renders a div', async function (assert) {
      await render(<template><Divider @orientation="vertical" /></template>);

      assert.dom('[data-component="divider"]').hasTagName('div');
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

      assert.dom('[data-component="divider"]').hasTagName('span');
    });

    test('renders data-component="divider" on the root only, with data-part="base"', async function (assert) {
      await render(<template><Divider /></template>);

      assert
        .dom('[data-component="divider"]')
        .hasAttribute('data-part', 'base');
      assert.strictEqual(
        document.querySelectorAll('[data-component="divider"]').length,
        1,
        'data-component="divider" marks the root only'
      );
    });

    test('@variant="sketch" applies the sketch styles', async function (assert) {
      await render(<template><Divider @variant="sketch" /></template>);

      assert.dom('[data-component="divider"]').hasClass('divider-sketch');
      // 4px — the artwork's native height. It must win over the `h-px` the
      // horizontal orientation sets.
      assert.dom('[data-component="divider"]').hasClass('h-1');
      assert.dom('[data-component="divider"]').doesNotHaveClass('h-px');
    });

    test('@variant="sketch" keeps the element and its semantics', async function (assert) {
      await render(<template><Divider @variant="sketch" /></template>);

      assert.dom('[data-component="divider"]').hasTagName('hr');
      assert
        .dom('[data-component="divider"]')
        .hasAttribute('role', 'separator');
    });

    // The artwork is a near-horizontal ribbon. Squashed into a 1px-wide column
    // it renders as a stub covering part of the height, not a rule — so the
    // theme scopes the mask to horizontal and vertical falls back to a plain
    // line. This test is the guard on that scoping.
    test('@variant="sketch" is ignored for a vertical divider', async function (assert) {
      await render(
        <template>
          <Divider @orientation="vertical" @variant="sketch" />
        </template>
      );

      assert
        .dom('[data-component="divider"]')
        .doesNotHaveClass('divider-sketch');
      assert.dom('[data-component="divider"]').hasClass('w-px');
      assert
        .dom('[data-component="divider"]')
        .hasAttribute('aria-orientation', 'vertical');
    });

    test('@variant="sketch" composes with @class and @as', async function (assert) {
      await render(
        <template>
          <Divider @variant="sketch" @class="bg-primary" data-test-colored />
          <Divider @variant="sketch" @as="li" data-test-as />
        </template>
      );

      assert.dom('[data-test-colored]').hasClass('divider-sketch');
      // The artwork carries no colour of its own — it is a mask — so the line's
      // colour is just the element's background, and overriding it is a plain
      // utility override.
      assert.dom('[data-test-colored]').hasClass('bg-primary');
      assert.dom('[data-test-colored]').doesNotHaveClass('bg-neutral-subtle');
      assert.dom('[data-test-as]').hasTagName('li');
      assert.dom('[data-test-as]').hasClass('divider-sketch');
    });
  }
);
