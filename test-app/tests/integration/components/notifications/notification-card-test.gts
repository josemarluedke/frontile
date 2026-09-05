import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, clearRender, settled } from '@ember/test-helpers';
import { NotificationCard } from 'frontile';
import {
  Notification,
  type NotificationsService
} from 'frontile/notifications';
import sinon from 'sinon';
import { registerCustomStyles, useStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import { cell } from 'ember-resources';

// Captured before the `registerCustomStyles` call below replaces
// `notificationCard` for the rest of this module — `notificationCard` itself
// isn't part of the package's public value exports (only its type is), so
// this is the one way to keep a handle on the *real* production tv() function
// for the direct, unmocked assertions later in this file.
const realNotificationCardStyles = useStyles().notificationCard;

registerCustomStyles({
  notificationCard: tv({
    slots: {
      base: '',
      inner: '',
      icon: 'notification-card__icon',
      spinner: 'notification-card__spinner',
      content: '',
      title: 'notification-card__title',
      description: 'notification-card__description',
      customActions: '',
      customActionButton: 'notification-card__custom-action-btn',
      closeButton: 'notification-card__close-btn'
    },
    variants: {
      intent: {
        default: { base: 'notification-card--default-intent' },
        info: { base: 'notification-card--info' },
        success: { base: 'notification-card--success' },
        warning: { base: 'notification-card--warning' },
        danger: { base: 'notification-card--danger' }
      },
      variant: {
        default: { base: 'notification-card--default' },
        tonal: { base: 'notification-card--tonal' },
        solid: { base: 'notification-card--solid' }
      },
      hasDescription: {
        true: {
          base: 'notification-card--has-description',
          icon: 'notification-card__icon--top-aligned'
        },
        false: {
          base: 'notification-card--centered',
          icon: 'notification-card__icon--centered'
        }
      }
    },
    defaultVariants: {
      intent: 'info',
      variant: 'default',
      hasDescription: false
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

    test('it renders the title', async function (assert) {
      notification.current = new Notification({}, 'My message');
      await render(template);

      assert.dom('.notification-card__title').hasText('My message');
      assert.dom('.notification-card__description').doesNotExist();
    });

    test('it renders the description when present', async function (assert) {
      notification.current = new Notification({}, 'Event created', {
        description: 'Starts at 8:00 AM.'
      });
      await render(template);

      assert.dom('.notification-card__title').hasText('Event created');
      assert
        .dom('.notification-card__description')
        .hasText('Starts at 8:00 AM.');
    });

    test('it applies the centered layout when there is no description', async function (assert) {
      notification.current = new Notification({}, 'My message');
      await render(template);

      assert.dom('.notification-card--centered').exists();
      assert.dom('.notification-card--has-description').doesNotExist();
      assert.dom('.notification-card__icon--centered').exists();
    });

    test('it applies the top-aligned layout when there is a description', async function (assert) {
      notification.current = new Notification({}, 'Event created', {
        description: 'Starts at 8:00 AM.'
      });
      await render(template);

      assert.dom('.notification-card--has-description').exists();
      assert.dom('.notification-card--centered').doesNotExist();
      assert.dom('.notification-card__icon--top-aligned').exists();
    });

    test('it switches from centered to top-aligned when a description is added at runtime', async function (assert) {
      notification.current = new Notification({}, 'Saving…', {
        isLoading: true
      });
      await render(template);

      assert.dom('.notification-card--centered').exists();
      assert.dom('.notification-card--has-description').doesNotExist();

      notification.current.update({ description: 'Saved successfully.' });
      await settled();

      assert.dom('.notification-card--has-description').exists();
      assert.dom('.notification-card--centered').doesNotExist();
    });

    test('the default intent composes with all three variants', async function (assert) {
      // This file's module-level `registerCustomStyles` replaces the real
      // `notificationCard` theme classes with plain marker strings for the
      // whole test run (see the comment in notifications-container-test.gts
      // about module-level code running regardless of `--filter`), so this
      // exercises the `intent`/`variant` plumbing rather than the actual
      // Tailwind color literals — those are reviewed directly in
      // packages/theme/src/components/notification-card.ts and verified by
      // the site build's live demos.
      notification.current = new Notification({}, 'Message');

      await render(
        <template>
          <NotificationCard
            data-test-notification
            @placement="top-right"
            @notification={{notification.current}}
            @variant="default"
          />
        </template>
      );
      assert
        .dom('[data-test-notification]')
        .hasClass('notification-card--default-intent');
      assert
        .dom('[data-test-notification]')
        .hasClass('notification-card--default');

      await render(
        <template>
          <NotificationCard
            data-test-notification
            @placement="top-right"
            @notification={{notification.current}}
            @variant="tonal"
          />
        </template>
      );
      assert
        .dom('[data-test-notification]')
        .hasClass('notification-card--default-intent');
      assert
        .dom('[data-test-notification]')
        .hasClass('notification-card--tonal');

      await render(
        <template>
          <NotificationCard
            data-test-notification
            @placement="top-right"
            @notification={{notification.current}}
            @variant="solid"
          />
        </template>
      );
      assert
        .dom('[data-test-notification]')
        .hasClass('notification-card--default-intent');
      assert
        .dom('[data-test-notification]')
        .hasClass('notification-card--solid');
    });

    test('it applies the intent class', async function (assert) {
      notification.current = new Notification({}, 'Message', {
        intent: 'danger'
      });
      await render(template);

      assert.dom('.notification-card--danger').exists();
    });

    test('the default intent renders the info icon in neutral styling, distinct from info', async function (assert) {
      notification.current = new Notification({}, 'Message');
      await render(template);

      assert
        .dom('[data-test-notification]')
        .hasAttribute('data-test-intent', 'default');
      assert
        .dom('.notification-card__icon')
        .hasAttribute(
          'data-test-icon',
          'info',
          'the default intent reuses the info glyph'
        );
      assert.dom('.notification-card--default-intent').exists();
      assert.dom('.notification-card--info').doesNotExist();
    });

    test('an explicit info intent is distinguishable from default via data-test-intent', async function (assert) {
      notification.current = new Notification({}, 'Message', {
        intent: 'info'
      });
      await render(template);

      assert
        .dom('[data-test-notification]')
        .hasAttribute('data-test-intent', 'info');
      assert.dom('.notification-card--info').exists();
      assert.dom('.notification-card--default-intent').doesNotExist();
    });

    test('the default intent uses role=status', async function (assert) {
      notification.current = new Notification({}, 'Message');
      await render(template);

      assert.dom('[role="status"]').exists();
      assert.dom('[role="alert"]').doesNotExist();
    });

    test('it renders an icon per intent', async function (assert) {
      notification.current = new Notification({}, 'Message', {
        intent: 'success'
      });
      await render(template);

      assert
        .dom('.notification-card__icon')
        .hasAttribute('data-test-icon', 'success');
    });

    test('it renders a spinner while loading', async function (assert) {
      notification.current = new Notification({}, 'Saving…', {
        isLoading: true
      });
      await render(template);

      // The spinner has its own `spinner` slot now, distinct from `icon` —
      // see the class comment on that slot in
      // packages/theme/src/components/notification-card.ts.
      assert
        .dom('.notification-card__spinner')
        .hasAttribute('data-test-icon', 'loading');
    });

    test('the loading spinner uses a dim track distinct from its accent-coloured arc', async function (assert) {
      // This exercises the *real* Spinner theme (only `notificationCard` is
      // overridden by this file's module-level `registerCustomStyles` above;
      // `spinner` is not), so the `fill-*`/`text-*` classes asserted here are
      // the actual Tailwind literals, not test marker strings. Regression
      // target: passing the card's `icon` slot classes to <Spinner> put an
      // intent-coloured `text-*` class on the track, which Tailwind-merge let
      // win over the Spinner's own dim `text-neutral-muted`, making arc and
      // track nearly identical.
      notification.current = new Notification({}, 'Saving…', {
        isLoading: true,
        intent: 'danger'
      });
      await render(template);

      const spinner = document.querySelector('[data-test-icon="loading"]');
      assert.ok(spinner, 'the spinner renders');

      const classList = Array.from(spinner!.classList);
      const fillClass = classList.find((c) => c.startsWith('fill-'));
      const trackClass = classList.find(
        (c) => c === 'text-neutral-muted' || c.startsWith('text-neutral-muted')
      );

      assert.true(
        classList.includes('fill-danger'),
        `the arc picks up the danger accent via @intent; got classes: ${classList.join(' ')}`
      );
      assert.true(
        classList.includes('text-neutral-muted'),
        `the track stays a dim neutral, not the intent color; got classes: ${classList.join(' ')}`
      );
      assert.ok(fillClass, 'an arc fill-* class is present');
      assert.ok(trackClass, 'a track text-* class is present');
      assert.notEqual(
        fillClass,
        trackClass,
        'the arc and track resolve to two different color utilities, not the same value'
      );
      assert.true(
        classList.includes('animate-spin'),
        'the spin animation class survives the class merge'
      );
    });

    test('the loading spinner is the same size as the settled intent icon, in every variant', function (assert) {
      // This must be checked against the *real* theme, not through render:
      // this file's module-level `registerCustomStyles` mock (needed by the
      // rendering tests above, e.g. `.notification-card__icon`) replaces
      // both the `icon` and `spinner` slots with plain marker classes that
      // carry no size utility at all, so a render-based assertion here would
      // pass or fail independently of the real classes — it would not catch
      // a real size mismatch. A mismatch here would resize the card the
      // instant a promise settles and the spinner swaps for an icon,
      // re-triggering the stack's layout (see `measure` in
      // notification-card.gts).
      const variants: ('default' | 'tonal' | 'solid')[] = [
        'default',
        'tonal',
        'solid'
      ];

      for (const variant of variants) {
        const { icon, spinner } = realNotificationCardStyles({
          intent: 'danger',
          variant
        });

        assert.true(
          icon().includes('size-5'),
          `${variant}: icon is size-5; got "${icon()}"`
        );
        assert.true(
          spinner().includes('size-5'),
          `${variant}: spinner is size-5; got "${spinner()}"`
        );
      }
    });

    test('the solid variant gives the spinner an accent arc and a dim track drawn from the same contrast ink, distinct from each other', function (assert) {
      // Unlike the default/tonal case above, `solid`'s surface is a
      // saturated `bg-{intent}` fill — the same color `@intent` would put on
      // the arc via the Spinner's own `fill-{intent}`, which would make the
      // arc invisible against its own card. This is verified directly
      // against the real (unmocked) theme object, since this file's
      // module-level `registerCustomStyles` replaces `notificationCard`'s
      // classes with test markers for rendering tests.
      const cases: {
        intent: 'default' | 'info' | 'success' | 'warning' | 'danger';
        arc: string;
        track: string;
      }[] = [
        {
          intent: 'default',
          arc: 'fill-on-neutral',
          track: 'text-on-neutral/30'
        },
        { intent: 'info', arc: 'fill-on-primary', track: 'text-on-primary/30' },
        {
          intent: 'success',
          arc: 'fill-on-success',
          track: 'text-on-success/30'
        },
        {
          intent: 'warning',
          arc: 'fill-on-warning',
          track: 'text-on-warning/30'
        },
        { intent: 'danger', arc: 'fill-on-danger', track: 'text-on-danger/30' }
      ];

      for (const { intent, arc, track } of cases) {
        const { spinner, icon } = realNotificationCardStyles({
          intent,
          variant: 'solid'
        });
        const spinnerClass = spinner();
        const iconClass = icon();

        assert.true(
          spinnerClass.includes(arc),
          `solid/${intent} spinner includes the arc class "${arc}"; got "${spinnerClass}"`
        );
        assert.true(
          spinnerClass.includes(track),
          `solid/${intent} spinner includes the track class "${track}"; got "${spinnerClass}"`
        );
        assert.notEqual(
          arc,
          track,
          `solid/${intent} arc and track are distinct color utilities`
        );
        assert.true(
          spinnerClass.includes('size-5'),
          `solid/${intent} spinner is still size-5, matching the icon`
        );
        assert.true(
          iconClass.includes('size-5'),
          `solid/${intent} icon is size-5, for parity with the spinner`
        );
      }
    });

    test('hideIcon removes the icon', async function (assert) {
      notification.current = new Notification({}, 'Message', {
        hideIcon: true
      });
      await render(template);

      assert.dom('.notification-card__icon').doesNotExist();
    });

    test('info and success use role=status', async function (assert) {
      notification.current = new Notification({}, 'Message', {
        intent: 'success'
      });
      await render(template);

      assert.dom('[role="status"]').exists();
      assert.dom('[role="alert"]').doesNotExist();
    });

    test('warning and danger use role=alert', async function (assert) {
      notification.current = new Notification({}, 'Message', {
        intent: 'warning'
      });
      await render(template);

      assert.dom('[role="alert"]').exists();
    });

    test('it hides the close button when closing is not allowed', async function (assert) {
      notification.current = new Notification({}, 'Message', {
        allowClosing: false
      });
      await render(template);

      assert.dom('.notification-card__close-btn').doesNotExist();
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

    test('cancels the pending enter animation frame when destroyed', async function (assert) {
      const rafStub = sinon.stub(window, 'requestAnimationFrame').returns(4242);
      const cafStub = sinon.stub(window, 'cancelAnimationFrame');

      try {
        notification.current = new Notification({}, 'My message');
        await render(template);

        assert.ok(
          rafStub.calledOnce,
          'requestAnimationFrame was scheduled by the enter modifier'
        );

        // Destroy the card before the stubbed frame ever "fires", simulating
        // a card removed mid-enter-transition (e.g. rapid add/remove).
        await clearRender();

        assert.ok(
          cafStub.calledWith(4242),
          'cancelAnimationFrame was called with the pending frame id on teardown'
        );
      } finally {
        sinon.restore();
      }
    });

    test('@transitionDuration only governs the opacity fade, not the fixed 400ms transform/height animation', async function (assert) {
      notification.current = new Notification({}, 'My message', {
        transitionDuration: 1000
      });

      await render(template);

      const style =
        document
          .querySelector('[data-test-notification]')
          ?.getAttribute('style') || '';

      assert.ok(
        style.includes('transition-duration: 400ms, 1000ms, 400ms'),
        `transform and height stay fixed at 400ms regardless of ` +
          `@transitionDuration; only the opacity slot (the middle value) ` +
          `follows it. Got: "${style}"`
      );
    });
  }
);
