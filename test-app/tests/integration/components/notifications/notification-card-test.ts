import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, triggerEvent } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';
import { Notification, NotificationsService } from '@frontile/notifications';
import sinon from 'sinon';

declare module '@ember/test-helpers' {
  interface TestContext {
    notification?: Notification;
  }
}

module(
  'Integration | Component | @frontile/notifications/NotificationCard',
  function (hooks) {
    setupRenderingTest(hooks);

    const template = hbs`
    <NotificationCard
      data-test-notification
      @notification={{this.notification}}
    />`;

    test('it renders the notification content & close button', async function (assert) {
      this;
      this.set('notification', new Notification('My message'));

      await render(template);

      assert.dom('[data-test-notification]').containsText('My message');
      assert
        .dom('[data-test-notification] .notification-card__close-btn')
        .containsText('Close');
    });

    test('it renders the correct appearance', async function (assert) {
      this.set('notification', new Notification('My message'));

      await render(template);

      assert
        .dom('[data-test-notification]')
        .hasClass('notification-card--info');

      this.set(
        'notification',
        new Notification('My message', {
          appearance: 'success'
        })
      );
      assert
        .dom('[data-test-notification]')
        .hasClass('notification-card--success');

      this.set(
        'notification',
        new Notification('My message', {
          appearance: 'warning'
        })
      );
      assert
        .dom('[data-test-notification]')
        .hasClass('notification-card--warning');

      this.set(
        'notification',
        new Notification('My message', {
          appearance: 'error'
        })
      );
      assert
        .dom('[data-test-notification]')
        .hasClass('notification-card--error');
    });

    test('it does not render close button when allowClosing=false', async function (assert) {
      this.set(
        'notification',
        new Notification('My message', {
          allowClosing: false
        })
      );

      await render(template);

      assert
        .dom('[data-test-notification] .notification-card__close-btn')
        .doesNotExist();
    });

    test('it calls remove function from service on close-btn click', async function (assert) {
      assert.expect(1);

      this.set(
        'notification',
        new Notification('My message', { transitionDuration: 1 })
      );

      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      sinon.stub(service, 'remove').callsFake((n: Notification): void => {
        assert.equal(n, this.notification);
      });

      await render(template);

      await click('[data-test-notification] .notification-card__close-btn');

      sinon.restore();
    });

    test('it renders and calls custom actions', async function (assert) {
      assert.expect(5);

      this.set(
        'notification',
        new Notification('My message', {
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
        })
      );

      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      sinon.stub(service, 'remove').callsFake((n: Notification): void => {
        assert.equal(n, this.notification);
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

      this.set(
        'notification',
        new Notification('My message', { transitionDuration: 1 })
      );

      // @ts-ignore
      this.notification.timer = {
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
  }
);
