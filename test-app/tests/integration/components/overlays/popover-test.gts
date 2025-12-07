import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  click,
  render,
  triggerEvent,
  find,
  settled
} from '@ember/test-helpers';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import Popover from '@frontile/overlays/components/popover';
import { on } from '@ember/modifier';
import { cell } from 'ember-resources';

module(
  'Integration | Component | Popover | @frontile/overlays',
  function (hooks) {
    setupRenderingTest(hooks);

    registerCustomStyles({
      backdrop: tv({ base: 'overlay__backdrop' }) as never,
      overlay: tv({
        base: 'overlay__content',
        variants: {
          inPlace: {
            true: 'overlay--in-place'
          }
        }
      }) as never
    });

    test('it works with trigger and opening content', async function (assert) {
      await render(
        <template>
          <Popover as |p|>
            <button data-test-id="trigger" type="button" {{p.trigger}} {{p.anchor}}>
              Trigger
            </button>

            <p.Content data-test-id="content">
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      assert.dom('[data-test-id="content"]').doesNotExist();
      await click('[data-test-id="trigger"]');

      assert.dom('[data-test-id="content"]').exists();
      assert.dom('[data-test-id="content"]').containsText('Content here');
      assert
        .dom(document.activeElement)
        .hasAttribute(
          'data-test-id',
          'content',
          'should have focused in the content'
        );
    });

    test('it works with trigger hover mode, prevents focus restore', async function (assert) {
      await render(
        <template>
          <button type="button" data-test-id="focused-element">Button</button>
          <Popover as |p|>
            <button data-test-id="trigger" type="button" {{p.trigger "hover"}} {{p.anchor}}>
              Trigger
            </button>

            <p.Content data-test-id="content">
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      (find('[data-test-id="focused-element"]') as HTMLButtonElement).focus();

      assert.dom('[data-test-id="content"]').doesNotExist();
      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');

      assert.dom('[data-test-id="content"]').exists();
      assert.dom('[data-test-id="content"]').containsText('Content here');
      assert
        .dom(document.activeElement)
        .hasAttribute(
          'data-test-id',
          'content',
          'should have focused in the content'
        );

      await triggerEvent('[data-test-id="trigger"]', 'mouseleave');
      assert.dom('[data-test-id="content"]').doesNotExist();

      assert
        .dom(document.activeElement)
        .doesNotHaveAttribute(
          'data-test-id',
          'should have not restored the focus'
        );
    });

    test('it renders accessibility attributes', async function (assert) {
      await render(
        <template>
          <Popover as |p|>
            <button data-test-id="trigger" type="button" {{p.trigger}} {{p.anchor}}>
              Trigger
            </button>

            <p.Content data-test-id="content">
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      assert.dom('[data-test-id="trigger"]').hasAria('haspopup', 'true');
      assert.dom('[data-test-id="trigger"]').hasAria('expanded', 'false');
      assert.dom('[data-test-id="trigger"]').hasAttribute('aria-controls');

      await click('[data-test-id="trigger"]');

      assert.dom('[data-test-id="trigger"]').hasAria('expanded', 'true');
      assert.dom('[data-test-id="content"]').hasAttribute('id');
    });

    test('it shows backdrop when @backdrop=none', async function (assert) {
      const backdrop = cell<'none' | 'faded' | undefined>('none');

      await render(
        <template>
          <Popover as |p|>
            <button data-test-id="trigger" type="button" {{p.trigger}} {{p.anchor}}>
              Trigger
            </button>

            <p.Content
              @backdrop={{backdrop.current}}
              @disableTransitions={{true}}
              data-test-id="content"
            >
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      await click('[data-test-id="trigger"]');

      assert.dom('.overlay__backdrop').doesNotExist();

      backdrop.current = 'faded';
      await settled();

      assert.dom('.overlay__backdrop').exists();
    });

    test('clicking outside closes menu', async function (assert) {
      let calledClosed = false;
      const didClose = () => {
        calledClosed = true;
      };

      await render(
        <template>
          <div id="outside" tabindex="0"></div>
          <Popover @didClose={{didClose}} as |p|>
            <button data-test-id="trigger" type="button" {{p.trigger}} {{p.anchor}}>
              Trigger
            </button>

            <p.Content @disableTransitions={{true}} data-test-id="content">
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      assert.dom('[data-test-id="content"]').doesNotExist();
      await click('[data-test-id="trigger"]');
      assert.dom('[data-test-id="content"]').exists();

      await click('#outside');
      assert.dom('[data-test-id="content"]').doesNotExist();
      assert.equal(calledClosed, true, 'should called didClose argument');
      assert
        .dom(document.activeElement)
        .hasAttribute(
          'data-test-id',
          'trigger',
          'should have restored the focus to the triggeer'
        );
    });

    test('controlled isOpen', async function (assert) {
      let isOpenValue = false;
      const isOpen = cell(false);
      const onOpenChange = (value: boolean) => {
        isOpenValue = value;
        isOpen.current = value;
      };

      await render(
        <template>
          <div id="outside" tabindex="0"></div>
          <Popover
            @isOpen={{isOpen.current}}
            @onOpenChange={{onOpenChange}}
            as |p|
          >
            <button data-test-id="trigger" type="button" {{p.trigger}} {{p.anchor}}>
              Trigger
            </button>

            <p.Content @disableTransitions={{true}} data-test-id="content">
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      assert.dom('[data-test-id="content"]').doesNotExist();
      await click('[data-test-id="trigger"]');
      assert.dom('[data-test-id="content"]').exists();
      assert.equal(isOpenValue, true);

      await click('#outside');
      assert.dom('[data-test-id="content"]').doesNotExist();
      assert.equal(isOpenValue, false);

      isOpen.current = true;
      await settled();
      assert.dom('[data-test-id="content"]').exists();

      isOpen.current = false;
      await settled();
      assert.dom('[data-test-id="content"]').doesNotExist();
    });

    test('it prevents trigger event bubbling', async function (assert) {
      assert.expect(1);

      const parentClick = () => {
        assert.ok(false, 'popover trigger should not bubble click event');
      };

      await render(
        <template>
          <Popover as |p|>
            <button type="button" {{on "click" parentClick}}>
              <button data-test-id="trigger" type="button" {{p.trigger}} {{p.anchor}}>
                Trigger
              </button>
            </button>
            <p.Content data-test-id="content">
              Content here
            </p.Content>
          </Popover>
        </template>
      );

      await click('[data-test-id="trigger"]');

      assert.dom('[data-test-id="content"]').exists();
    });
  }
);
