/* eslint-disable @typescript-eslint/no-non-null-assertion */
import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';
import { Notification, Timer } from 'frontile/notifications';

module('Unit | @frontile/notifications/Notification', function (hooks) {
  setupTest(hooks);

  test('it creates with default values', async function (assert) {
    const notification = new Notification({}, 'Message');

    assert.equal(notification.message, 'Message');
    assert.equal(notification.title, 'Message', 'title aliases message');
    assert.equal(typeof notification.description, 'undefined');
    assert.equal(notification.intent, 'default');
    assert.equal(notification.isLoading, false);
    assert.equal(typeof notification.customActions, 'undefined');
    assert.equal(notification.duration, 5000);
    assert.equal(notification.transitionDuration, 200);
    assert.equal(notification.allowClosing, true);
  });

  test('it accepts a description', async function (assert) {
    const notification = new Notification({}, 'Event created', {
      description: 'Starts at 8:00 AM.'
    });

    assert.equal(notification.title, 'Event created');
    assert.equal(notification.description, 'Starts at 8:00 AM.');
  });

  test('it accepts an object content form', async function (assert) {
    const notification = new Notification(
      {},
      {
        title: 'Event created',
        description: 'Starts at 8:00 AM.'
      }
    );

    assert.equal(notification.message, 'Event created');
    assert.equal(notification.description, 'Starts at 8:00 AM.');
  });

  test('an object content description is not overridden by options', async function (assert) {
    const notification = new Notification(
      {},
      { title: 'Title', description: 'From content' },
      { description: 'From options' }
    );

    assert.equal(
      notification.description,
      'From content',
      'the content argument wins'
    );
  });

  test('it accepts an intent', async function (assert) {
    const notification = new Notification({}, 'Message', { intent: 'danger' });

    assert.equal(notification.intent, 'danger');
  });

  test('a bare notification resolves to the default intent, not info', async function (assert) {
    const notification = new Notification({}, 'Message');

    assert.equal(notification.intent, 'default');
  });

  test('an explicit info intent stays distinct from default', async function (assert) {
    const notification = new Notification({}, 'Message', { intent: 'info' });

    assert.equal(notification.intent, 'info');
  });

  test('appearance reads back "default" for the default intent', async function (assert) {
    const notification = new Notification({}, 'Message');

    assert.equal(notification.appearance, 'default');
  });

  test('the deprecated appearance option maps onto intent', async function (assert) {
    const notification = new Notification({}, 'Message', {
      appearance: 'error'
    });

    assert.equal(notification.intent, 'danger');
    assert.equal(
      notification.appearance,
      'error',
      'reads back as the old name'
    );
  });

  test('appearance reads back from intent for the shared names', async function (assert) {
    const notification = new Notification({}, 'Message', {
      intent: 'success'
    });

    assert.equal(notification.appearance, 'success');
  });

  test('intent wins when both are supplied', async function (assert) {
    const notification = new Notification({}, 'Message', {
      intent: 'warning',
      appearance: 'error'
    });

    assert.equal(notification.intent, 'warning');
  });

  test('update replaces content and intent', async function (assert) {
    const notification = new Notification({}, 'Saving…', {
      intent: 'info',
      allowClosing: false
    });
    notification.isLoading = true;

    notification.update({
      title: 'Saved',
      description: 'All good.',
      intent: 'success',
      allowClosing: true,
      isLoading: false
    });

    assert.equal(notification.title, 'Saved');
    assert.equal(notification.description, 'All good.');
    assert.equal(notification.intent, 'success');
    assert.equal(notification.allowClosing, true);
    assert.equal(notification.isLoading, false);
  });

  test('update leaves omitted fields alone', async function (assert) {
    const notification = new Notification({}, 'Title', {
      description: 'Description'
    });

    notification.update({ intent: 'warning' });

    assert.equal(notification.title, 'Title');
    assert.equal(notification.description, 'Description');
    assert.equal(notification.intent, 'warning');
  });

  test('update can clear a description with an empty string', async function (assert) {
    const notification = new Notification({}, 'Title', {
      description: 'Description'
    });

    notification.update({ description: '' });

    assert.equal(notification.description, '');
  });

  test('it can create with custom options', async function (assert) {
    const notification = new Notification({}, 'Message', {
      intent: 'success',
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
    assert.equal(notification.intent, 'success');
    assert.equal(notification.transitionDuration, 0);
    assert.equal(notification.allowClosing, false);
    assert.equal(notification.customActions?.length, 1);
  });

  test('remove marks it as removing and clears the timer', async function (assert) {
    const notification = new Notification({}, 'Message');
    notification.timer = new Timer(5000, () => {
      /* test */
    });

    notification.remove();

    assert.equal(notification.isRemoving, true);
    assert.equal(notification.timer!.isRunning, false);
  });

  // Carried over from the pre-redesign test file: these exercise `isRemoving`
  // and `timer` as directly settable tracked properties, independent of the
  // `remove()` method's own behavior covered above.
  test('it can set isRemoving', async function (assert) {
    const notification = new Notification({}, 'Message');

    notification.isRemoving = true;
    assert.ok(notification.isRemoving);
  });

  test('it can set a timer', async function (assert) {
    const notification = new Notification({}, 'Message');

    notification.timer = new Timer(0, () => {
      // empty
    });
    assert.ok(notification.timer instanceof Timer);
  });
});
