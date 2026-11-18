import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';
import { Notification, Timer } from 'frontile/notifications';
import { collectAssertions } from '../../helpers/collect-assertions';

module('Unit | @frontile/notifications/Notification', function (hooks) {
  setupTest(hooks);

  test('it creates with default values', async function (assert) {
    const notification = new Notification({}, 'Message');

    assert.equal(notification.message, 'Message');
    assert.equal(notification.title, 'Message', 'title aliases message');
    assert.equal(typeof notification.description, 'undefined');
    assert.equal(notification.status, 'neutral');
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

  test('it accepts an status', async function (assert) {
    const notification = new Notification({}, 'Message', { status: 'danger' });

    assert.equal(notification.status, 'danger');
  });

  test('a bare notification resolves to the neutral status, not primary', async function (assert) {
    const notification = new Notification({}, 'Message');

    assert.equal(notification.status, 'neutral');
  });

  test('an explicit primary status stays distinct from neutral', async function (assert) {
    const notification = new Notification({}, 'Message', { status: 'primary' });

    assert.equal(notification.status, 'primary');
  });

  test('the appearance option fails in development', async function (assert) {
    const failed = await collectAssertions(
      () =>
        new Notification({}, 'Message', {
          // @ts-expect-error -- removed in 0.19.0
          appearance: 'error'
        })
    );

    assert.true(
      failed.includes(
        'Notifications: the "appearance" option was removed in 0.19.0. Use "status".'
      ),
      `got: ${failed.join(' | ')}`
    );
  });

  test('a config-level appearance fails in development', async function (assert) {
    const failed = await collectAssertions(
      () =>
        // @ts-expect-error -- removed in 0.19.0
        new Notification({ appearance: 'success' }, 'Message')
    );

    assert.true(
      failed.includes(
        'Notifications: the "appearance" option was removed in 0.19.0. Use "status".'
      ),
      `got: ${failed.join(' | ')}`
    );
  });

  test('an explicitly undefined appearance stays silent', async function (assert) {
    const failed = await collectAssertions(
      () =>
        new Notification({}, 'Message', {
          // @ts-expect-error -- removed in 0.19.0
          appearance: undefined
        })
    );

    assert.deepEqual(failed, []);
  });

  test('precedence: option status > config status > default', async function (assert) {
    assert.equal(
      new Notification({ status: 'primary' }, 'Message', { status: 'danger' })
        .status,
      'danger',
      'option status wins over config'
    );

    assert.equal(
      new Notification({ status: 'primary' }, 'Message').status,
      'primary',
      'config status is used when no option is set'
    );

    assert.equal(
      new Notification({}, 'Message').status,
      'neutral',
      'the built-in default is the last resort'
    );
  });

  test('update replaces content and status', async function (assert) {
    const notification = new Notification({}, 'Saving…', {
      status: 'primary',
      allowClosing: false
    });
    notification.isLoading = true;

    notification.update({
      title: 'Saved',
      description: 'All good.',
      status: 'success',
      allowClosing: true,
      isLoading: false
    });

    assert.equal(notification.title, 'Saved');
    assert.equal(notification.description, 'All good.');
    assert.equal(notification.status, 'success');
    assert.equal(notification.allowClosing, true);
    assert.equal(notification.isLoading, false);
  });

  test('update leaves omitted fields alone', async function (assert) {
    const notification = new Notification({}, 'Title', {
      description: 'Description'
    });

    notification.update({ status: 'warning' });

    assert.equal(notification.title, 'Title');
    assert.equal(notification.description, 'Description');
    assert.equal(notification.status, 'warning');
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
      status: 'success',
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
    assert.equal(notification.status, 'success');
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
