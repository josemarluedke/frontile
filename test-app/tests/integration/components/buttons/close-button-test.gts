import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, triggerEvent } from '@ember/test-helpers';
import { CloseButton } from 'frontile';
import { cell } from 'ember-resources';
import { settled } from '@ember/test-helpers';
import Component from '@glimmer/component';
import { collectAssertions } from '../../../helpers/collect-assertions';
import { useCustomStyles } from '../../../helpers/scoped-styles';
import { closeButtonStubStyles } from '../../../helpers/close-button-stub-styles';

const noop = () => {};

module(
  'Integration | Component | @frontile/utilities/CloseButton',
  function (hooks) {
    setupRenderingTest(hooks);
    useCustomStyles(hooks, { closeButton: closeButtonStubStyles });

    test('it renders title', async function (assert) {
      const title = cell('');
      await render(
        <template>
          <div data-test-element><CloseButton @title={{title.current}} /></div>
        </template>
      );

      assert.dom('[data-test-element]').hasText('Close');

      title.current = 'Fechar Menu';
      await settled();

      assert.dom('[data-test-element]').hasText('Fechar Menu');
    });

    test('it allows to yield', async function (assert) {
      await render(
        <template>
          <CloseButton><div class="icon">Here is my icon</div></CloseButton>
        </template>
      );
      assert.dom('.close-button .icon').exists();

      assert.dom('.close-button .icon').hasText('Here is my icon');
    });

    test('it yields the icon classes', async function (assert) {
      await render(
        <template>
          <CloseButton as |class|><div
              class="icon"
            >{{class}}</div></CloseButton>
        </template>
      );
      assert.dom('.close-button .icon').hasText('close-button__icon');
    });

    test('it adds size classes', async function (assert) {
      const size = cell<undefined | 'xs' | 'sm' | 'md' | 'lg' | 'xl'>();
      await render(<template><CloseButton @size={{size.current}} /></template>);

      assert.dom('.close-button').hasClass('close-button--md');

      size.current = 'xs';
      await settled();
      assert.dom('.close-button').hasClass('close-button--xs');

      size.current = 'sm';
      await settled();
      assert.dom('.close-button').hasClass('close-button--sm');

      size.current = 'md';
      await settled();
      assert.dom('.close-button').hasClass('close-button--md');

      size.current = 'lg';
      await settled();
      assert.dom('.close-button').hasClass('close-button--lg');

      size.current = 'xl';
      await settled();
      assert.dom('.close-button').hasClass('close-button--xl');
    });

    test('it allows to pass @class for component curlying', async function (assert) {
      await render(<template><CloseButton @class="some-class" /></template>);
      assert.dom('.close-button').hasClass('some-class');
    });

    test('@variant="soft" renders the new class', async function (assert) {
      await render(
        <template>
          <CloseButton @variant="soft" data-test-id="close-button" />
        </template>
      );

      assert.dom('[data-test-id="close-button"]').hasClass('close-button-soft');
    });

    test('@variant="subtle" fails in development', async function (assert) {
      const failed = await collectAssertions(() =>
        render(
          <template>
            {{! @glint-expect-error -- removed in 0.19.0 }}
            <CloseButton @variant="subtle" data-test-id="close-button" />
          </template>
        )
      );

      assert.true(
        failed.includes(
          'CloseButton: @variant="subtle" was removed in 0.19.0. Use @variant="soft".'
        ),
        `got: ${failed.join(' | ')}`
      );
    });

    test('@variant="transparent" fails in development', async function (assert) {
      const failed = await collectAssertions(() =>
        render(
          <template>
            {{! @glint-expect-error -- removed in 0.19.0 }}
            <CloseButton @variant="transparent" data-test-id="close-button" />
          </template>
        )
      );

      assert.true(
        failed.includes(
          'CloseButton: @variant="transparent" was removed in 0.19.0. Use @variant="ghost".'
        ),
        `got: ${failed.join(' | ')}`
      );
    });

    test('@onClick fails in development', async function (assert) {
      const failed = await collectAssertions(() =>
        render(
          <template>
            {{! @glint-expect-error -- removed in 0.19.0 }}
            <CloseButton @onClick={{noop}} data-test-id="close-button" />
          </template>
        )
      );

      assert.true(
        failed.includes(
          'CloseButton: @onClick was removed in 0.19.0. Use @onPress.'
        ),
        `got: ${failed.join(' | ')}`
      );
    });

    test('explicitly undefined @onClick stays silent', async function (assert) {
      const failed = await collectAssertions(() =>
        render(
          <template>
            {{! @glint-expect-error -- removed in 0.19.0 }}
            <CloseButton @onClick={{undefined}} data-test-id="close-button" />
          </template>
        )
      );

      assert.deepEqual(failed, []);
    });

    module('Press functionality', () => {
      test('it handles onPress callback', async function (assert) {
        let pressEventCount = 0;

        class TestComponent extends Component {
          handlePress = () => {
            pressEventCount++;
          };

          <template>
            <CloseButton
              @onPress={{this.handlePress}}
              data-test-id="close-button"
            />
          </template>
        }

        await render(<template><TestComponent /></template>);

        await triggerEvent('[data-test-id="close-button"]', 'pointerdown');
        await triggerEvent('[data-test-id="close-button"]', 'pointerup');

        assert.strictEqual(
          pressEventCount,
          1,
          'onPress callback was called once'
        );
      });

      test('it sets data-pressed attribute when pressed', async function (assert) {
        await render(
          <template><CloseButton data-test-id="close-button" /></template>
        );

        assert
          .dom('[data-test-id="close-button"]')
          .doesNotHaveAttribute('data-pressed');

        await triggerEvent('[data-test-id="close-button"]', 'pointerdown');
        assert
          .dom('[data-test-id="close-button"]')
          .hasAttribute('data-pressed', 'true');

        await triggerEvent('[data-test-id="close-button"]', 'pointerup');
        assert
          .dom('[data-test-id="close-button"]')
          .doesNotHaveAttribute('data-pressed');
      });
    });

    module('anatomy', function () {
      test('renders data-component="close-button" on the root only, with data-part on every slot', async function (assert) {
        await render(<template><CloseButton /></template>);

        assert
          .dom('[data-component="close-button"]')
          .hasAttribute('data-part', 'base');
        assert
          .dom('[data-component="close-button"] [data-part="icon"]')
          .exists();
        assert.strictEqual(
          document.querySelectorAll('[data-component="close-button"]').length,
          1,
          'data-component="close-button" marks the root only, never a part'
        );
      });
    });
  }
);
