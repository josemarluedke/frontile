import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';
import { Notification, Timer } from '@frontile/notifications';

module('Unit | Notification', function(hooks) {
  setupTest(hooks);

  test('it creates with default values', async function(assert) {
    const notification = new Notification('Message');

    assert.equal(notification.message, 'Message');
    assert.equal(notification.appearance, 'info');
    assert.equal(typeof notification.customActions, 'undefined');
    assert.equal(notification.duration, 5000);
    assert.equal(notification.transitionDuration, 200);
    assert.equal(notification.allowClosing, true);
  });

  test('it can create with custom options', async function(assert) {
    const notification = new Notification('Message', {
      appearance: 'success',
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

    assert.equal(notification.message, 'Message');
    assert.equal(notification.appearance, 'success');
    assert.equal(notification.transitionDuration, 0);
    assert.equal(notification.allowClosing, false);
    assert.equal(notification.customActions!.length, 1);
    assert.equal(notification.customActions![0].label, 'Label');
    assert.equal(typeof notification.customActions![0].onClick, 'function');
  });

  test('it can set isRemoving', async function(assert) {
    const notification = new Notification('Message');

    notification.isRemoving = true;
    assert.ok(notification.isRemoving);
  });

  test('it can set a timer', async function(assert) {
    const notification = new Notification('Message');

    notification.timer = new Timer(0, () => {
      // empty
    });
    assert.ok(notification.timer instanceof Timer);
  });
});
