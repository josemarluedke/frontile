import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  triggerEvent,
  triggerKeyEvent,
  find,
  settled,
  waitUntil
} from '@ember/test-helpers';
import { Tooltip } from 'frontile/overlays';
import { cell } from 'ember-resources';

module(
  'Integration | Component | Tooltip | @frontile/overlays',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders @content on hover and closes on leave', async function (assert) {
      await render(
        <template>
          <Tooltip
            @content="Add to library"
            @openDelay={{0}}
            @closeDelay={{0}}
            as |t|
          >
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Top</button>
          </Tooltip>
        </template>
      );

      assert.dom('[data-test-id="tooltip-content"]').doesNotExist();

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');
      assert.dom('[role="tooltip"]').exists();
      assert.dom('[role="tooltip"]').hasText('Add to library');

      await triggerEvent('[data-test-id="trigger"]', 'mouseleave');
      await waitUntil(() => !find('[role="tooltip"]'), { timeout: 2000 });
      assert.dom('[role="tooltip"]').doesNotExist();
    });

    test('it renders a rich content block', async function (assert) {
      await render(
        <template>
          <Tooltip @openDelay={{0}} @closeDelay={{0}} as |t|>
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Help</button>
            <t.Content>
              <div data-test-id="title">Help Information</div>
            </t.Content>
          </Tooltip>
        </template>
      );

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');
      assert
        .dom('[role="tooltip"] [data-test-id="title"]')
        .hasText('Help Information');
    });

    test('it is not a tab stop and carries role=tooltip', async function (assert) {
      await render(
        <template>
          <Tooltip @content="Hi" @openDelay={{0}} @closeDelay={{0}} as |t|>
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Trigger</button>
          </Tooltip>
        </template>
      );

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');

      assert.dom('[role="tooltip"]').hasAttribute('tabindex', '-1');
    });

    test('it wires aria-describedby only while open', async function (assert) {
      await render(
        <template>
          <Tooltip @content="Hi" @openDelay={{0}} @closeDelay={{0}} as |t|>
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Trigger</button>
          </Tooltip>
        </template>
      );

      assert
        .dom('[data-test-id="trigger"]')
        .doesNotHaveAttribute('aria-describedby');
      assert
        .dom('[data-test-id="trigger"]')
        .doesNotHaveAttribute('aria-haspopup');

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');

      const id = (find('[role="tooltip"]') as HTMLElement).id;
      assert
        .dom('[data-test-id="trigger"]')
        .hasAttribute('aria-describedby', id);
    });

    test('hovering the content keeps it open', async function (assert) {
      await render(
        <template>
          <Tooltip @content="Hi" @openDelay={{0}} @closeDelay={{30}} as |t|>
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Trigger</button>
          </Tooltip>
        </template>
      );

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');
      assert.dom('[role="tooltip"]').exists();

      // Crossing the offset gap: leave the trigger, arrive on the content
      // inside the close delay. Dispatched raw, not through `triggerEvent` --
      // `triggerEvent` awaits `settled()` after firing, which would wait out
      // the still-pending close from `mouseleave` (a real, runloop-tracked
      // timer) before the `mouseenter` on the content ever got a chance to
      // cancel it. See `popover-test.gts`'s "hover: moving the pointer into
      // the content keeps it open" for the same pattern.
      const trigger = find('[data-test-id="trigger"]') as HTMLElement;
      trigger.dispatchEvent(new MouseEvent('mouseleave', { bubbles: true }));
      (find('[role="tooltip"]') as HTMLElement).dispatchEvent(
        new MouseEvent('mouseenter', { bubbles: true })
      );
      await settled();

      assert.dom('[role="tooltip"]').exists('surviving the gap crossing');
    });

    test('Escape closes it', async function (assert) {
      await render(
        <template>
          <Tooltip @content="Hi" @openDelay={{0}} @closeDelay={{0}} as |t|>
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Trigger</button>
          </Tooltip>
        </template>
      );

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');
      assert.dom('[role="tooltip"]').exists();

      await triggerKeyEvent(document, 'keydown', 'Escape');
      await waitUntil(() => !find('[role="tooltip"]'), { timeout: 2000 });
      assert.dom('[role="tooltip"]').doesNotExist();
    });

    test('it renders an arrow and the resolved placement', async function (assert) {
      await render(
        <template>
          <Tooltip
            @content="Hi"
            @arrow={{true}}
            @placement="top"
            @openDelay={{0}}
            @closeDelay={{0}}
            as |t|
          >
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Trigger</button>
          </Tooltip>
        </template>
      );

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');

      assert.dom('[role="tooltip"] [data-part="arrow"]').exists();
      assert
        .dom('[role="tooltip"]')
        .hasAttribute('data-placement', /^(top|bottom)/);
    });

    test('@intent and @size apply theme classes', async function (assert) {
      await render(
        <template>
          <Tooltip
            @content="Hi"
            @intent="danger"
            @size="lg"
            @openDelay={{0}}
            @closeDelay={{0}}
            as |t|
          >
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Trigger</button>
          </Tooltip>
        </template>
      );

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');

      assert.dom('[role="tooltip"]').hasClass('bg-danger');
      assert.dom('[role="tooltip"]').hasClass('px-3');
    });

    test('@isDisabled never opens', async function (assert) {
      const isDisabled = cell(true);

      await render(
        <template>
          <Tooltip
            @content="Hi"
            @isDisabled={{isDisabled.current}}
            @openDelay={{0}}
            as |t|
          >
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Trigger</button>
          </Tooltip>
        </template>
      );

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');

      assert
        .dom('[role="tooltip"]')
        .doesNotExist('does not open while @isDisabled is true');

      await triggerEvent('[data-test-id="trigger"]', 'mouseleave');

      isDisabled.current = false;
      await settled();

      await triggerEvent('[data-test-id="trigger"]', 'mouseenter');

      assert
        .dom('[role="tooltip"]')
        .exists('the same markup opens once @isDisabled is false');
    });

    test('it supports controlled mode', async function (assert) {
      const isOpen = cell(false);
      const onOpenChange = (next: boolean) => {
        isOpen.current = next;
      };

      await render(
        <template>
          <Tooltip
            @content="Hi"
            @isOpen={{isOpen.current}}
            @onOpenChange={{onOpenChange}}
            @openDelay={{0}}
            @closeDelay={{0}}
            as |t|
          >
            <button
              data-test-id="trigger"
              type="button"
              {{t.trigger}}
            >Trigger</button>
          </Tooltip>
        </template>
      );

      assert.dom('[role="tooltip"]').doesNotExist();

      isOpen.current = true;
      await settled();
      assert.dom('[role="tooltip"]').exists('opens from the outside');

      isOpen.current = false;
      await settled();
      assert.dom('[role="tooltip"]').doesNotExist();
    });
  }
);
