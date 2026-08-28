import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, find, findAll } from '@ember/test-helpers';
import {
  NotificationsContainer,
  type NotificationsService,
  type NotificationOptions,
  type NotificationsContainerSignature
} from 'frontile';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import { cell } from 'ember-resources';
import { settled } from '@ember/test-helpers';

registerCustomStyles({
  notificationsContainer: tv({
    base: ['notifications-container'],
    variants: {
      placement: {
        'top-left': 'notifications-container--top-left',
        'top-center': 'notifications-container--top-center',
        'top-right': 'notifications-container--top-right',
        'bottom-left': 'notifications-container--bottom-left',
        'bottom-center': 'notifications-container--bottom-center',
        'bottom-right': 'notifications-container--bottom-right'
      }
    },
    defaultVariants: {
      placement: 'bottom-right'
    }
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

    test('it does not render if there are no notifications', async function (assert) {
      await render(template);

      assert.dom('[data-test-notifications]').doesNotExist();
    });

    test('it render all notifications from service', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      service.add('Message 1', options);
      service.add('Message 2', options);

      await render(template);

      assert.dom('[data-test-notifications]').exists();
      assert.dom('[data-test-notifications] > div').exists({ count: 2 });
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

      assert.dom('[data-test-notifications]').hasAttribute('role', 'alert');
      assert
        .dom('[data-test-notifications]')
        .hasAttribute('aria-live', 'assertive');
      assert
        .dom('[data-test-notifications]')
        .hasAttribute('aria-atomic', 'true');
    });
    test('it sets and clears margin-top based on placement', async function (assert) {
      (this.owner.lookup('service:notifications') as NotificationsService).add(
        'Message 1',
        options
      );

      placement.current = 'top-left';

      await render(template);

      assert
        .dom('[data-test-notifications]')
        .hasStyle(
          { marginTop: '16px' },
          'top placements receive the spacing as margin-top'
        );

      placement.current = 'bottom-left';
      await settled();

      assert.equal(
        (
          find('[data-test-notifications]') as HTMLElement
        ).style.marginTop.trim(),
        '',
        'switching to a bottom placement clears the stale margin-top'
      );
    });

    test('top placements render notifications in reverse order', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      service.add('Message 1', options);
      service.add('Message 2', options);

      placement.current = 'bottom-right';
      await render(template);

      let cards = findAll('[data-test-notifications] > div');
      assert.dom(cards[0]).containsText('Message 1');
      assert.dom(cards[1]).containsText('Message 2');

      placement.current = 'top-right';
      await settled();

      cards = findAll('[data-test-notifications] > div');
      assert.dom(cards[0]).containsText('Message 2');
      assert.dom(cards[1]).containsText('Message 1');
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
