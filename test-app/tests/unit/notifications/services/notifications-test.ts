/* eslint-disable @typescript-eslint/no-non-null-assertion */
import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';
import { NotificationsService, Timer } from 'frontile/notifications';
import { waitUntil, settled } from '@ember/test-helpers';

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
    test('removing the same notification twice only calls onRemove once', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      let calls = 0;
      service.setOnRemoveCallback(() => {
        calls++;
      });

      const notification = service.add('My Notification', {
        duration: 1,
        transitionDuration: 0,
        preserve: true
      });

      service.remove(notification);
      service.remove(notification);

      await settled();

      assert.equal(service.notifications.length, 0);
      assert.equal(calls, 1, 'onRemove is called exactly once');
    });

    test('removeAll after remove does not call onRemove twice', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      let calls = 0;
      service.setOnRemoveCallback(() => {
        calls++;
      });

      const first = service.add('My Notification', {
        transitionDuration: 0,
        preserve: true
      });
      service.add('My Notification 2', {
        transitionDuration: 0,
        preserve: true
      });

      service.remove(first);
      service.removeAll();

      await settled();

      assert.equal(service.notifications.length, 0);
      assert.equal(calls, 2, 'onRemove is called once per notification');
    });

    test('it calls onRemove with the removed notification after auto removal', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      const removed: string[] = [];
      service.setOnRemoveCallback((notification) => {
        removed.push(notification.message);
      });

      service.add('My Notification', {
        duration: 10,
        transitionDuration: 0
      });

      await waitUntil(
        () => {
          return service.notifications.length === 0;
        },
        { timeout: 500 }
      );
      await settled();

      assert.deepEqual(removed, ['My Notification']);
    });
    test('the skipTimer config option preserves notifications', async function (assert) {
      const env = this.owner.resolveRegistration(
        'config:environment'
      ) as Record<string, unknown>;
      const original = env['@frontile/notifications'];
      env['@frontile/notifications'] = { skipTimer: true };

      try {
        const service = this.owner.lookup(
          'service:notifications'
        ) as NotificationsService;

        const notification = service.add('My Notification', {
          duration: 1,
          transitionDuration: 0
        });

        assert.equal(
          typeof notification.timer,
          'undefined',
          'no timer is created when skipTimer is configured'
        );
        assert.equal(service.notifications.length, 1);
      } finally {
        if (typeof original === 'undefined') {
          delete env['@frontile/notifications'];
        } else {
          env['@frontile/notifications'] = original;
        }
      }
    });
  }
);
