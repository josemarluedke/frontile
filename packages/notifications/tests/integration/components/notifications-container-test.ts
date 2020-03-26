import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';
import {
  NotificationsService,
  NotificationOptions
} from '@frontile/notifications';

module('Integration | Component | NotificationsContainer', function (hooks) {
  setupRenderingTest(hooks);

  const options: NotificationOptions = {
    transitionDuration: 0,
    preserve: true
  };

  const template = hbs`
    <NotificationsContainer
      @placement={{this.placement}}
      data-test-notifications
    />`;

  test('it does not render if there are no notifications', async function (assert) {
    await render(template);

    assert.dom('[data-test-notifications]').doesNotExist();
  });

  test('it render all notifications from service', async function (assert) {
    const service: NotificationsService = this.owner.lookup(
      'service:notifications'
    );

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

    this.set('placement', undefined);

    await render(template);

    assert.dom('[data-test-notifications]').hasClass('bottom-right');

    this.set('placement', 'top-left');
    assert.dom('[data-test-notifications]').hasClass('top-left');

    this.set('placement', 'top-center');
    assert.dom('[data-test-notifications]').hasClass('top-center');

    this.set('placement', 'top-right');
    assert.dom('[data-test-notifications]').hasClass('top-right');

    this.set('placement', 'bottom-left');
    assert.dom('[data-test-notifications]').hasClass('bottom-left');

    this.set('placement', 'bottom-center');
    assert.dom('[data-test-notifications]').hasClass('bottom-center');

    this.set('placement', 'bottom-right');
    assert.dom('[data-test-notifications]').hasClass('bottom-right');
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
    assert.dom('[data-test-notifications]').hasAttribute('aria-atomic', 'true');
  });
});
