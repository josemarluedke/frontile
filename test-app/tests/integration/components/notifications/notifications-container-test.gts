import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
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
  }
);
