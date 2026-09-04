import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  rerender,
  find,
  findAll,
  triggerEvent,
  settled
} from '@ember/test-helpers';
import {
  NotificationsContainer,
  type NotificationsService,
  type NotificationOptions,
  type NotificationsContainerSignature
} from 'frontile';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import { cell } from 'ember-resources';

registerCustomStyles({
  notificationsContainer: tv({
    slots: {
      base: 'notifications-container',
      stack: 'notifications-container__stack'
    },
    variants: {
      placement: {
        'top-left': { base: 'notifications-container--top-left' },
        'top-center': { base: 'notifications-container--top-center' },
        'top-right': { base: 'notifications-container--top-right' },
        'bottom-left': { base: 'notifications-container--bottom-left' },
        'bottom-center': { base: 'notifications-container--bottom-center' },
        'bottom-right': { base: 'notifications-container--bottom-right' }
      }
    },
    defaultVariants: { placement: 'bottom-right' }
  })
});

module(
  'Integration | Component | @frontile/notifications/NotificationsContainer',
  function (hooks) {
    setupRenderingTest(hooks);

    const options: NotificationOptions = {
      transitionDuration: 0,
      preserve: true
    };

    const placement =
      cell<NotificationsContainerSignature['Args']['placement']>();

    const template = <template>
      <NotificationsContainer
        @placement={{placement.current}}
        data-test-notifications
      />
    </template>;

    test('it renders no cards if there are no notifications', async function (assert) {
      await render(template);

      assert.dom('[data-test-notifications]').exists();
      assert.dom('[data-test-notification-card]').doesNotExist();
    });

    test('it render all notifications from service', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      service.add('Message 1', options);
      service.add('Message 2', options);

      await render(template);

      assert.dom('[data-test-notifications]').exists();
      assert.dom('[data-test-notification-card]').exists({ count: 2 });
    });

    test('it adds placement classes', async function (assert) {
      (this.owner.lookup('service:notifications') as NotificationsService).add(
        'Message 1',
        options
      );

      placement.current = undefined;

      await render(template);

      assert
        .dom('[data-test-notifications]')
        .hasClass('notifications-container--bottom-right');

      placement.current = 'top-left';
      await settled();
      assert
        .dom('[data-test-notifications]')
        .hasClass('notifications-container--top-left');

      placement.current = 'top-center';
      await settled();
      assert
        .dom('[data-test-notifications]')
        .hasClass('notifications-container--top-center');

      placement.current = 'top-right';
      await settled();
      assert
        .dom('[data-test-notifications]')
        .hasClass('notifications-container--top-right');

      placement.current = 'bottom-left';
      await settled();
      assert
        .dom('[data-test-notifications]')
        .hasClass('notifications-container--bottom-left');

      placement.current = 'bottom-center';
      await settled();
      assert
        .dom('[data-test-notifications]')
        .hasClass('notifications-container--bottom-center');

      placement.current = 'bottom-right';
      await settled();
      assert
        .dom('[data-test-notifications]')
        .hasClass('notifications-container--bottom-right');
    });

    test('it adds accessibility attributes', async function (assert) {
      (this.owner.lookup('service:notifications') as NotificationsService).add(
        'Message 1',
        options
      );

      await render(template);

      assert.dom('[data-test-notifications]').hasAttribute('role', 'region');
      assert
        .dom('[data-test-notifications]')
        .hasAttribute('aria-live', 'polite');
    });

    test('notifications render newest-first regardless of placement', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      service.add('Message 1', options);
      service.add('Message 2', options);

      placement.current = 'bottom-right';
      await render(template);

      let cards = findAll('[data-test-notification-card]');
      assert.dom(cards[0]).containsText('Message 2');
      assert.dom(cards[1]).containsText('Message 1');

      placement.current = 'top-right';
      await settled();

      cards = findAll('[data-test-notification-card]');
      assert.dom(cards[0]).containsText('Message 2');
      assert.dom(cards[1]).containsText('Message 1');
    });

    test('it stacks cards front-first with descending z-index', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      // `options` sets `preserve: true`, which skips timer creation entirely
      // (see `manager.ts`), so the literal add-then-render ordering below
      // resolves instantly with full `settled()` guarantees and never races
      // an auto-dismiss timer.
      service.add('First', options);
      service.add('Second', options);
      await render(<template><NotificationsContainer /></template>);

      const cards = findAll('[data-test-notification-card]');
      assert.strictEqual(cards.length, 2);
      assert
        .dom(cards[0])
        .hasStyle({ zIndex: '2' }, 'the newest card is at the front');
      assert.dom(cards[0]!).hasText(/Second/);
    });

    test('it expands on hover and collapses on leave', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      service.add('First', options);
      service.add('Second', options);
      await render(<template><NotificationsContainer /></template>);

      assert
        .dom('.notifications-container__stack')
        .hasAttribute('data-expanded', 'false');

      await triggerEvent('.notifications-container', 'mouseenter');
      assert
        .dom('.notifications-container__stack')
        .hasAttribute('data-expanded', 'true');

      await triggerEvent('.notifications-container', 'mouseleave');
      assert
        .dom('.notifications-container__stack')
        .hasAttribute('data-expanded', 'false');
    });

    test('it expands on focusin so hidden cards are reachable', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      service.add('First', options);
      await render(<template><NotificationsContainer /></template>);

      await triggerEvent('.notifications-container', 'focusin');
      assert
        .dom('.notifications-container__stack')
        .hasAttribute('data-expanded', 'true');
    });

    test('@expand keeps the stack expanded', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      service.add('First', options);
      await render(
        <template><NotificationsContainer @expand={{true}} /></template>
      );

      assert
        .dom('.notifications-container__stack')
        .hasAttribute('data-expanded', 'true');
    });

    test('expanding pauses the timers of every notification', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      // As above: add the notifications after the initial render so their
      // real 10s timers don't block `render()`'s internal `settled()`. The
      // hover/leave interactions dispatch the DOM event directly rather than
      // through `triggerEvent`, because `triggerEvent` also awaits full
      // `settled()` — and `collapse()` resuming the timers re-arms a ~10s
      // pending timer that would make the *second* `triggerEvent` call hang
      // for the remaining duration. The container's `{{on}}` modifiers are
      // plain event listeners, so a native dispatch exercises the same
      // `expand`/`collapse` handlers synchronously.
      await render(<template><NotificationsContainer /></template>);

      service.add('First', { duration: 10000 });
      service.add('Second', { duration: 10000 });
      await rerender();

      const container = find('.notifications-container') as HTMLElement;

      container.dispatchEvent(new MouseEvent('mouseenter', { bubbles: true }));

      assert.false(service.notifications[0]!.timer!.isRunning);
      assert.false(service.notifications[1]!.timer!.isRunning);

      container.dispatchEvent(new MouseEvent('mouseleave', { bubbles: true }));

      assert.true(service.notifications[0]!.timer!.isRunning);
      assert.true(service.notifications[1]!.timer!.isRunning);
    });

    test('the container is a polite live region', async function (assert) {
      await render(<template><NotificationsContainer /></template>);

      assert.dom('[role="region"]').hasAttribute('aria-live', 'polite');
      assert.dom('[role="region"]').hasAttribute('aria-label', 'Notifications');
    });

    test('it uses the current @onDismiss when the argument changes', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      const calls: string[] = [];
      const onDismiss = cell<
        NotificationsContainerSignature['Args']['onDismiss']
      >(() => calls.push('first'));

      placement.current = 'bottom-right';

      await render(
        <template>
          <NotificationsContainer
            @onDismiss={{onDismiss.current}}
            data-test-notifications
          />
        </template>
      );

      onDismiss.current = () => calls.push('second');
      await settled();

      const notification = service.add('Message 1', options);
      await settled();

      service.remove(notification);
      await settled();

      assert.deepEqual(calls, ['second'], 'the updated callback is used');
    });

    test('destroying one container does not disable another one', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      const calls: string[] = [];
      const onDismissFirst = () => {
        calls.push('first');
      };
      const onDismissSecond = () => {
        calls.push('second');
      };
      const showFirst = cell<boolean>(true);

      await render(
        <template>
          {{#if showFirst.current}}
            <NotificationsContainer
              @onDismiss={{onDismissFirst}}
              data-test-first
            />
          {{/if}}
          <NotificationsContainer
            @onDismiss={{onDismissSecond}}
            data-test-second
          />
        </template>
      );

      // Tear down the first container; the second one is still mounted and must
      // keep receiving dismiss callbacks.
      showFirst.current = false;
      await settled();

      const notification = service.add('Message 1', options);
      await settled();

      service.remove(notification);
      await settled();

      assert.deepEqual(
        calls,
        ['second'],
        'the surviving container still receives the callback'
      );
    });
  }
);
