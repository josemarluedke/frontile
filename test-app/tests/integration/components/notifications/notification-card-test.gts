import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, triggerEvent } from '@ember/test-helpers';
import { NotificationCard } from 'frontile';
import {
  Notification,
  type NotificationsService
} from 'frontile/notifications';
import sinon from 'sinon';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import { cell } from 'ember-resources';
import { settled } from '@ember/test-helpers';

registerCustomStyles({
  notificationCard: tv({
    slots: {
      base: '',
      message: '',
      customActions: '',
      customActionButton: 'notification-card__custom-action-btn',
      closeButton: 'notification-card__close-btn'
    },

    variants: {
      appearance: {
        info: {
          base: 'notification-card--info',
          closeButton: '',
          customActionButton: ''
        },
        success: {
          base: 'notification-card--success',
          closeButton: '',
          customActionButton: ''
        },
        warning: {
          base: 'notification-card--warning',
          closeButton: '',
          customActionButton: ''
        },
        error: {
          base: 'notification-card--error',
          closeButton: '',
          customActionButton: ''
        }
      }
    },
    defaultVariants: {
      appearance: 'info'
    }
  })
});

module(
  'Integration | Component | @frontile/notifications/NotificationCard',
  function (hooks) {
    setupRenderingTest(hooks);

    const notification = cell<Notification>(new Notification({}, ''));
    const template = <template>
      <NotificationCard
        data-test-notification
        @placement="top-right"
        @notification={{notification.current}}
      />
    </template>;

    test('it renders the notification content & close button', async function (assert) {
      notification.current = new Notification({}, 'My message');

      await render(template);

      assert.dom('[data-test-notification]').containsText('My message');
      assert
        .dom('[data-test-notification] .notification-card__close-btn')
        .containsText('Close');
    });

    test('it renders the correct appearance', async function (assert) {
      notification.current = new Notification({}, 'My message');

      await render(template);

      assert
        .dom('[data-test-notification]')
        .hasClass('notification-card--info');

      notification.current = new Notification({}, 'My message', {
        appearance: 'success'
      });
      await settled();

      assert
        .dom('[data-test-notification]')
        .hasClass('notification-card--success');

      notification.current = new Notification({}, 'My message', {
        appearance: 'warning'
      });
      await settled();

      assert
        .dom('[data-test-notification]')
        .hasClass('notification-card--warning');

      notification.current = new Notification({}, 'My message', {
        appearance: 'error'
      });
      await settled();

      assert
        .dom('[data-test-notification]')
        .hasClass('notification-card--error');
    });

    test('it does not render close button when allowClosing=false', async function (assert) {
      notification.current = new Notification({}, 'My message', {
        allowClosing: false
      });

      await render(template);

      assert
        .dom('[data-test-notification] .notification-card__close-btn')
        .doesNotExist();
    });

    test('it calls remove function from service on close-btn click', async function (assert) {
      assert.expect(1);

      notification.current = new Notification({}, 'My message', {
        transitionDuration: 1
      });

      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      sinon.stub(service, 'remove').callsFake((n?: Notification): void => {
        assert.equal(n, notification.current);
      });

      await render(template);

      await click('[data-test-notification] .notification-card__close-btn');

      sinon.restore();
    });

    test('it renders and calls custom actions', async function (assert) {
      assert.expect(5);

      notification.current = new Notification({}, 'My message', {
        transitionDuration: 1,
        customActions: [
          {
            label: 'Undo',
            onClick: () => {
              assert.ok(true);
            }
          },
          {
            label: 'Ok',
            onClick: () => {
              assert.ok(true);
            }
          }
        ]
      });

      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      sinon.stub(service, 'remove').callsFake((n?: Notification): void => {
        assert.equal(n, notification.current);
      });

      await render(template);

      assert
        .dom('[data-test-notification] .notification-card__custom-action-btn')
        .exists({ count: 2 });

      assert
        .dom(
          '[data-test-notification] .notification-card__custom-action-btn:first-child'
        )
        .hasText('Undo');

      assert
        .dom(
          '[data-test-notification] .notification-card__custom-action-btn:last-child'
        )
        .hasText('Ok');

      await click(
        '[data-test-notification] .notification-card__custom-action-btn:first-child'
      );

      sinon.restore();
    });

    test('it pauses/resumes the timer on mouseenter/mouseleave', async function (assert) {
      assert.expect(2);

      notification.current = new Notification({}, 'My message', {
        transitionDuration: 1
      });

      // @ts-ignore
      notification.current.timer = {
        pause() {
          assert.ok('should have paused');
        },
        resume() {
          assert.ok('should have resumed');
        }
      };

      await render(template);

      await triggerEvent('[data-test-notification]', 'mouseenter');
      await triggerEvent('[data-test-notification]', 'mouseleave');
    });

    test('notification can store metadata', async function (assert) {
      const metadata = {
        userId: 123,
        action: 'delete',
        resourceId: 'abc-123',
        timestamp: 1234567890
      };

      notification.current = new Notification({}, 'My message', {
        metadata
      });

      assert.ok(notification.current.metadata, 'metadata should exist');
      assert.equal(
        notification.current.metadata?.userId,
        123,
        'userId should match'
      );
      assert.equal(
        notification.current.metadata?.action,
        'delete',
        'action should match'
      );
      assert.equal(
        notification.current.metadata?.resourceId,
        'abc-123',
        'resourceId should match'
      );
      assert.equal(
        notification.current.metadata?.timestamp,
        1234567890,
        'timestamp should match'
      );
    });
  }
);
