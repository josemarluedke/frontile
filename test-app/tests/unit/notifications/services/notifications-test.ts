/* eslint-disable @typescript-eslint/no-non-null-assertion */
import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';
import { NotificationsService, Timer } from 'frontile/notifications';
import { waitUntil } from '@ember/test-helpers';

module(
  'Unit | Service | @frontile/notifications/notifications',
  function (hooks) {
    setupTest(hooks);

    test('it creates a notification', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      assert.equal(service.notifications.length, 0);

      const notification = service.add('My Notification', {
        duration: 1,
        transitionDuration: 0
      });
      assert.equal(notification.message, 'My Notification');

      assert.equal(service.notifications.length, 1);
    });

    test('auto removal works', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      const notification = service.add('My Notification', {
        duration: 10,
        transitionDuration: 0
      });
      assert.equal(service.notifications.length, 1);

      assert.ok(notification.timer instanceof Timer);
      assert.ok(notification.timer!.remaining <= 10);

      await waitUntil(
        () => {
          return service.notifications.length === 0;
        },
        { timeout: 500 }
      );
    });

    test('it creates a notification with preserve', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      assert.equal(service.notifications.length, 0);

      const notification = service.add('My Notification', {
        duration: 1,
        transitionDuration: 0,
        preserve: true
      });
      assert.equal(notification.message, 'My Notification');
      assert.equal(typeof notification.timer, 'undefined');

      assert.equal(service.notifications.length, 1);
    });

    test('it passes options to the notification', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      assert.equal(service.notifications.length, 0);

      const notification = service.add('My Notification', {
        appearance: 'error',
        duration: 1,
        transitionDuration: 0,
        allowClosing: false,
        customActions: [
          {
            label: 'Label',
            onClick: () => {
              /* test */
            }
          }
        ]
      });
      assert.equal(notification.message, 'My Notification');
      assert.equal(notification.appearance, 'error');
      assert.equal(notification.transitionDuration, 0);
      assert.equal(notification.allowClosing, false);
      assert.equal(notification.customActions?.length, 1);
      assert.equal(notification.customActions![0].label, 'Label');
      assert.equal(typeof notification.customActions![0].onClick, 'function');

      assert.equal(service.notifications.length, 1);
    });

    test('it removes a notification', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      assert.equal(service.notifications.length, 0);

      const notification = service.add('My Notification', {
        duration: 1,
        transitionDuration: 0,
        preserve: true
      });

      assert.equal(service.notifications.length, 1);

      service.remove(notification);

      await waitUntil(
        () => {
          return service.notifications.length === 0;
        },
        { timeout: 500 }
      );
    });

    test('it removes all notifications', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      assert.equal(service.notifications.length, 0);

      service.add('My Notification', {
        duration: 1,
        transitionDuration: 0,
        preserve: true
      });
      service.add('My Notification 2', {
        duration: 1,
        transitionDuration: 0,
        preserve: true
      });

      assert.equal(service.notifications.length, 2);

      service.removeAll();

      await waitUntil(
        () => {
          return service.notifications.length === 0;
        },
        { timeout: 500 }
      );
    });
  }
);
