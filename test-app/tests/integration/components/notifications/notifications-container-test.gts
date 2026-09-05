import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  rerender,
  find,
  findAll,
  triggerEvent,
  settled
} from '@ember/test-helpers';
import {
  NotificationsContainer,
  type NotificationsService,
  type NotificationOptions,
  type NotificationsContainerSignature
} from 'frontile';
import { registerCustomStyles, useStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import { cell } from 'ember-resources';

// Captured before the `registerCustomStyles` override below replaces
// `notificationsContainer` for the rest of this suite, so tests can still
// assert against the real, shipped classes (e.g. the pointer-events
// gap-bridging fix) rather than the class names this file mocks in below.
const realNotificationsContainerStyles = useStyles().notificationsContainer;
const realNotificationCardStyles = useStyles().notificationCard;

registerCustomStyles({
  notificationsContainer: tv({
    slots: {
      base: 'notifications-container',
      stack: 'notifications-container__stack'
    },
    variants: {
      placement: {
        'top-left': { base: 'notifications-container--top-left' },
        'top-center': { base: 'notifications-container--top-center' },
        'top-right': { base: 'notifications-container--top-right' },
        'bottom-left': { base: 'notifications-container--bottom-left' },
        'bottom-center': { base: 'notifications-container--bottom-center' },
        'bottom-right': { base: 'notifications-container--bottom-right' }
      }
    },
    defaultVariants: { placement: 'bottom-right' }
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

    test('it renders no cards if there are no notifications', async function (assert) {
      await render(template);

      assert.dom('[data-test-notifications]').exists();
      assert.dom('[data-test-notification-card]').doesNotExist();
    });

    test('it render all notifications from service', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      service.add('Message 1', options);
      service.add('Message 2', options);

      await render(template);

      assert.dom('[data-test-notifications]').exists();
      assert.dom('[data-test-notification-card]').exists({ count: 2 });
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

      assert.dom('[data-test-notifications]').hasAttribute('role', 'region');
      assert
        .dom('[data-test-notifications]')
        .hasAttribute('aria-live', 'polite');
    });

    test('notifications render newest-first regardless of placement', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      service.add('Message 1', options);
      service.add('Message 2', options);

      placement.current = 'bottom-right';
      await render(template);

      let cards = findAll('[data-test-notification-card]');
      assert.dom(cards[0]).containsText('Message 2');
      assert.dom(cards[1]).containsText('Message 1');

      placement.current = 'top-right';
      await settled();

      cards = findAll('[data-test-notification-card]');
      assert.dom(cards[0]).containsText('Message 2');
      assert.dom(cards[1]).containsText('Message 1');
    });

    test('it stacks cards front-first with descending z-index', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      // `options` sets `preserve: true`, which skips timer creation entirely
      // (see `manager.ts`), so the literal add-then-render ordering below
      // resolves instantly with full `settled()` guarantees and never races
      // an auto-dismiss timer.
      service.add('First', options);
      service.add('Second', options);
      await render(<template><NotificationsContainer /></template>);

      const cards = findAll('[data-test-notification-card]');
      assert.strictEqual(cards.length, 2);
      assert
        .dom(cards[0])
        .hasStyle({ zIndex: '2' }, 'the newest card is at the front');
      assert.dom(cards[0]!).hasText(/Second/);
    });

    test('the front card sizes to its content instead of a locked-in pixel height', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      // A long description that wraps across several lines, so the card's
      // natural content height is meaningfully taller than whatever height
      // might be latched on the very first (pre-layout) measurement.
      service.add('First', {
        ...options,
        description:
          'This is a much longer description that is expected to wrap ' +
          'across multiple lines once it is laid out, so the card needs ' +
          'to grow taller than a short single-line title would require.'
      });
      await render(<template><NotificationsContainer /></template>);

      const card = find('[data-test-notification-card]');
      assert.ok(card, 'the front card renders');
      // The front card (index 0) must size to its content: it should never
      // carry a fixed inline `height: <n>px`, which would clip content laid
      // out after the first measurement.
      assert.notOk(
        /height:\s*\d/.test(card!.getAttribute('style') || ''),
        'the front card has no fixed pixel height'
      );
      assert.true(
        card!.scrollHeight <= card!.clientHeight,
        'the description is not clipped by a fixed height'
      );
    });

    test('expanded offsets are computed from each card natural height, not a collapsed clamp', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      // This test needs a real flex row layout on the card (icon beside the
      // content column) to get a meaningful, realistic natural height out of
      // `getBoundingClientRect()`. `notification-card-test.gts` registers a
      // process-wide `notificationCard` override with empty slot classes
      // (module-level code runs for every loaded test file regardless of
      // `--filter`), so this test installs its own minimal-but-real-layout
      // override for its duration and restores whatever was registered
      // before it, to avoid leaking into other tests.
      const previousNotificationCardStyles = useStyles().notificationCard;
      registerCustomStyles({
        notificationCard: tv({
          slots: {
            base: 'w-full',
            inner: 'flex gap-3 p-4',
            icon: 'shrink-0 size-5',
            content: 'grow min-w-0 flex flex-col gap-1',
            title: '',
            description: '',
            customActions: 'flex flex-nowrap shrink-0 items-center gap-2',
            customActionButton: '',
            closeButton: 'shrink-0 self-center inline-block p-1.5'
          },
          variants: {
            intent: {
              default: {},
              info: {},
              success: {},
              warning: {},
              danger: {}
            },
            variant: { default: {}, tonal: {}, solid: {} },
            hasDescription: {
              true: { inner: 'items-start' },
              false: { inner: 'items-center' }
            }
          },
          defaultVariants: {
            intent: 'info',
            variant: 'default',
            hasDescription: false
          }
        })
      });

      try {
        // Cards of DIFFERENT heights are what makes this bug visible: while
        // collapsed, every card behind the front one is clamped to the
        // FRONT card's height (see notification-stack.ts `geometryFor`). If
        // the `ResizeObserver` that reports a card's height reads it off
        // the same element the clamp is applied to, a clamped card reports
        // the forced height instead of its true content height, and that
        // wrong number gets stored and later summed to position every card
        // behind it once expanded. Uniform-height cards would hide this
        // completely, since the clamped height and the true height would
        // coincide.
        //
        // A description adds a whole extra line to the card (see
        // `hasDescription` above), independent of text wrapping, so this is
        // a reliable height difference regardless of the rendered width.
        const description = 'Starts at 8:00 AM.';

        // Newest-first display order, so add in reverse of the intended
        // front-to-back order: front (newest) is short, the middle card is
        // tall, and the back card is short again.
        service.add('Short A', options);
        service.add('Tall middle', {
          ...options,
          description
        });
        service.add('Short B', options);

        await render(<template><NotificationsContainer /></template>);

        const cards = findAll('[data-test-notification-card]') as HTMLElement[];
        assert.strictEqual(cards.length, 3);

        // The true natural height of each card, read off the inner content
        // wrapper the same way the production code does (`offsetHeight`,
        // not `getBoundingClientRect()` — the test container applies a
        // visual scale transform that only affects the latter). Unlike the
        // outer element, the inner wrapper never carries the
        // collapsed-stack height clamp, so this is accurate regardless of
        // whether the stack is currently collapsed or expanded.
        const naturalHeights = cards.map((card) => {
          const inner = card.firstElementChild as HTMLElement;
          return inner.offsetHeight;
        });

        assert.true(
          Math.abs(naturalHeights[1]! - naturalHeights[0]!) > 10,
          `fixture sanity check: the middle card (${naturalHeights[1]}px) ` +
            `must be meaningfully taller than the front card ` +
            `(${naturalHeights[0]}px)`
        );

        await triggerEvent('.notifications-container', 'mouseenter');

        const gap = 16; // NotificationsContainer's default @spacing

        // Read the target `translateY` straight out of each card's inline
        // `style`. That value is set synchronously from `NotificationStack`'s
        // geometry math, so it is unaffected by the CSS transition still
        // animating toward it — unlike `getBoundingClientRect()`, which
        // would report a value mid-transition.
        const translateY = (card: HTMLElement): number => {
          const match = /translateY\((-?[\d.]+)px\)/.exec(
            card.getAttribute('style') || ''
          );
          assert.ok(
            match,
            `card has a translateY in its style: ${card.getAttribute('style')}`
          );
          return match ? parseFloat(match[1]!) : NaN;
        };

        assert.strictEqual(
          translateY(cards[0]!),
          0,
          'the front card is unmoved'
        );

        let expectedOffset = 0;
        for (let i = 1; i < cards.length; i++) {
          expectedOffset += naturalHeights[i - 1]! + gap;

          const actual = -translateY(cards[i]!);
          assert.true(
            Math.abs(actual - expectedOffset) < 1,
            `card ${i} offset (${actual}px) matches the summed natural ` +
              `heights of every card in front of it (${expectedOffset}px), ` +
              'not a collapsed-clamp value'
          );
        }
      } finally {
        registerCustomStyles({
          notificationCard: previousNotificationCardStyles
        });
      }
    });

    test('measured height includes the outer element border, so expanded gaps and stack height are exact', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      // The border lives on the *outer* card element
      // (`packages/theme/src/components/notification-card.ts`'s `base`
      // slot), not the inner one the `ResizeObserver` observes. A real,
      // non-zero border here is exactly what makes the residual bug
      // visible: `notification-card.gts`'s `measure` modifier must add the
      // outer element's vertical border back onto the inner element's
      // `offsetHeight`, or the height it reports is short by that border
      // width. This override — real flex-row layout plus a real border —
      // is intentionally more realistic than the "expanded offsets" test
      // above, whose override has no border and so cannot catch this.
      const previousNotificationCardStyles = useStyles().notificationCard;
      registerCustomStyles({
        notificationCard: tv({
          slots: {
            base: 'w-full border-4 border-solid border-black',
            inner: 'flex gap-3 p-4',
            icon: 'shrink-0 size-5',
            content: 'grow min-w-0 flex flex-col gap-1',
            title: '',
            description: '',
            customActions: 'flex flex-nowrap shrink-0 items-center gap-2',
            customActionButton: '',
            closeButton: 'shrink-0 self-center inline-block p-1.5'
          },
          variants: {
            intent: {
              default: {},
              info: {},
              success: {},
              warning: {},
              danger: {}
            },
            variant: { default: {}, tonal: {}, solid: {} },
            hasDescription: {
              true: { inner: 'items-start' },
              false: { inner: 'items-center' }
            }
          },
          defaultVariants: {
            intent: 'info',
            variant: 'default',
            hasDescription: false
          }
        })
      });

      try {
        service.add('First', {
          ...options,
          description: 'Starts at 8:00 AM.'
        });
        service.add('Second', options);

        await render(<template><NotificationsContainer /></template>);

        const cards = findAll('[data-test-notification-card]') as HTMLElement[];
        assert.strictEqual(cards.length, 2);

        await triggerEvent('.notifications-container', 'mouseenter');

        const gap = 16; // NotificationsContainer's default @spacing

        // Expanded cards size to `height: auto`, so the outer element's own
        // `offsetHeight` is now its true, complete border-box height —
        // including the border the measurement modifier is supposed to
        // account for. (`getBoundingClientRect()` is not usable here: the
        // `#ember-testing` container is rendered at a fixed zoom, which
        // scales rect-based measurements but not `offsetHeight`; see the
        // "expanded offsets" test above for the same caveat.)
        const realHeights = cards.map((card) => card.offsetHeight);

        const translateY = (card: HTMLElement): number => {
          const match = /translateY\((-?[\d.]+)px\)/.exec(
            card.getAttribute('style') || ''
          );
          assert.ok(
            match,
            `card has a translateY in its style: ${card.getAttribute('style')}`
          );
          return match ? parseFloat(match[1]!) : NaN;
        };

        assert.strictEqual(
          translateY(cards[0]!),
          0,
          'the front card is unmoved'
        );

        const actualGap = -translateY(cards[1]!) - realHeights[0]!;
        assert.true(
          Math.abs(actualGap - gap) < 1,
          `the visual gap between cards (${actualGap}px) is the documented ` +
            `@spacing (${gap}px), not short by the card's border width`
        );

        const stack = find('.notifications-container__stack') as HTMLElement;
        const expectedStackHeight = realHeights[0]! + realHeights[1]! + gap;
        const actualStackHeight = parseFloat(
          /height:\s*([\d.]+)px/.exec(stack.getAttribute('style') || '')?.[1] ??
            'NaN'
        );
        assert.true(
          Math.abs(actualStackHeight - expectedStackHeight) < 1,
          `the stack height (${actualStackHeight}px) equals the true summed ` +
            `content height (${expectedStackHeight}px)`
        );
      } finally {
        registerCustomStyles({
          notificationCard: previousNotificationCardStyles
        });
      }
    });

    test('it expands on hover and collapses on leave', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      service.add('First', options);
      service.add('Second', options);
      await render(<template><NotificationsContainer /></template>);

      assert
        .dom('.notifications-container__stack')
        .hasAttribute('data-expanded', 'false');

      await triggerEvent('.notifications-container', 'mouseenter');
      assert
        .dom('.notifications-container__stack')
        .hasAttribute('data-expanded', 'true');

      await triggerEvent('.notifications-container', 'mouseleave');
      assert
        .dom('.notifications-container__stack')
        .hasAttribute('data-expanded', 'false');
    });

    test('the stack slot is pointer-events-none while collapsed and pointer-events-auto while expanded', function (assert) {
      // Regression guard for the gap-bridging fix: hovering from one
      // expanded card to the next crosses `gap`px of the stack's own box
      // that no card covers. If the stack stayed `pointer-events-none`
      // there, the pointer would fall through to the page mid-hover and the
      // container would receive a spurious `mouseleave` (which pauses, then
      // immediately resumes, every notification's timer). This can't be
      // proven by dispatching synthetic events directly at nodes (as the
      // other tests in this file do) since that bypasses CSS hit-testing
      // entirely — it was verified against real pointer movement in a
      // browser instead. This test only guards the class list itself, using
      // the real theme styles captured above (this file overrides
      // `notificationsContainer` with class names that don't carry
      // pointer-events at all).
      const { stack } = realNotificationsContainerStyles({
        placement: 'bottom-right'
      });
      const classes = stack();

      assert.true(
        classes.includes('pointer-events-none'),
        'the collapsed stack does not intercept clicks across the page'
      );
      assert.true(
        classes.includes('data-[expanded=true]:pointer-events-auto'),
        'the expanded stack re-enables hit-testing to bridge the gap between cards'
      );
    });

    test('it expands on focusin so hidden cards are reachable', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      service.add('First', options);
      await render(<template><NotificationsContainer /></template>);

      await triggerEvent('.notifications-container', 'focusin');
      assert
        .dom('.notifications-container__stack')
        .hasAttribute('data-expanded', 'true');
    });

    test('@expand keeps the stack expanded', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      service.add('First', options);
      await render(
        <template><NotificationsContainer @expand={{true}} /></template>
      );

      assert
        .dom('.notifications-container__stack')
        .hasAttribute('data-expanded', 'true');
    });

    test('expanding pauses the timers of every notification', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      // As above: add the notifications after the initial render so their
      // real 10s timers don't block `render()`'s internal `settled()`. The
      // hover/leave interactions dispatch the DOM event directly rather than
      // through `triggerEvent`, because `triggerEvent` also awaits full
      // `settled()` — and `collapse()` resuming the timers re-arms a ~10s
      // pending timer that would make the *second* `triggerEvent` call hang
      // for the remaining duration. The container's `{{on}}` modifiers are
      // plain event listeners, so a native dispatch exercises the same
      // `expand`/`collapse` handlers synchronously.
      await render(<template><NotificationsContainer /></template>);

      service.add('First', { duration: 10000 });
      service.add('Second', { duration: 10000 });
      await rerender();

      const container = find('.notifications-container') as HTMLElement;

      container.dispatchEvent(new MouseEvent('mouseenter', { bubbles: true }));

      assert.false(service.notifications[0]!.timer!.isRunning);
      assert.false(service.notifications[1]!.timer!.isRunning);

      container.dispatchEvent(new MouseEvent('mouseleave', { bubbles: true }));

      assert.true(service.notifications[0]!.timer!.isRunning);
      assert.true(service.notifications[1]!.timer!.isRunning);
    });

    test('the container is a polite live region', async function (assert) {
      await render(<template><NotificationsContainer /></template>);

      assert.dom('[role="region"]').hasAttribute('aria-live', 'polite');
      assert.dom('[role="region"]').hasAttribute('aria-label', 'Notifications');
    });

    test('it uses the current @onDismiss when the argument changes', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      const calls: string[] = [];
      const onDismiss = cell<
        NotificationsContainerSignature['Args']['onDismiss']
      >(() => calls.push('first'));

      placement.current = 'bottom-right';

      await render(
        <template>
          <NotificationsContainer
            @onDismiss={{onDismiss.current}}
            data-test-notifications
          />
        </template>
      );

      onDismiss.current = () => calls.push('second');
      await settled();

      const notification = service.add('Message 1', options);
      await settled();

      service.remove(notification);
      await settled();

      assert.deepEqual(calls, ['second'], 'the updated callback is used');
    });

    test('destroying one container does not disable another one', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      const calls: string[] = [];
      const onDismissFirst = () => {
        calls.push('first');
      };
      const onDismissSecond = () => {
        calls.push('second');
      };
      const showFirst = cell<boolean>(true);

      await render(
        <template>
          {{#if showFirst.current}}
            <NotificationsContainer
              @onDismiss={{onDismissFirst}}
              data-test-first
            />
          {{/if}}
          <NotificationsContainer
            @onDismiss={{onDismissSecond}}
            data-test-second
          />
        </template>
      );

      // Tear down the first container; the second one is still mounted and must
      // keep receiving dismiss callbacks.
      showFirst.current = false;
      await settled();

      const notification = service.add('Message 1', options);
      await settled();

      service.remove(notification);
      await settled();

      assert.deepEqual(
        calls,
        ['second'],
        'the surviving container still receives the callback'
      );
    });

    test('it forwards @variant to each card, and each variant applies its expected classes', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      service.add('Message 1', { ...options, intent: 'success' });

      for (const variant of ['default', 'tonal', 'solid'] as const) {
        await render(
          <template>
            <NotificationsContainer
              @variant={{variant}}
              data-test-notifications
            />
          </template>
        );

        const card = find('[data-test-notification-card]') as HTMLElement;
        const expectedBase = realNotificationCardStyles({
          intent: 'success',
          variant,
          hasDescription: false
        }).base();

        assert.strictEqual(
          card.className,
          expectedBase,
          `@variant="${variant}" applies the classes the theme generates for it`
        );
      }
    });

    test('@variant defaults to "default" when omitted', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      service.add('Message 1', { ...options, intent: 'info' });

      await render(
        <template><NotificationsContainer data-test-notifications /></template>
      );

      const card = find('[data-test-notification-card]') as HTMLElement;
      const expectedBase = realNotificationCardStyles({
        intent: 'info',
        variant: 'default',
        hasDescription: false
      }).base();

      assert.strictEqual(card.className, expectedBase);
    });

    test('it forwards @spacing to the stack geometry', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      service.add('Message 1', options);
      service.add('Message 2', options);

      await render(
        <template>
          <NotificationsContainer @spacing={{40}} data-test-notifications />
        </template>
      );
      // `notification-card.gts`'s `enter` modifier flips `hasEntered` on the
      // frame after insertion (via `requestAnimationFrame`), and only once
      // that happens does the style getter switch from the enter/exit
      // transform to the geometry-driven one this test reads. `settled()`
      // doesn't wait on a raw `requestAnimationFrame`, so wait for one
      // directly.
      await new Promise((resolve) => requestAnimationFrame(resolve));
      await settled();

      const cards = findAll('[data-test-notification-card]') as HTMLElement[];
      const translateY = (card: HTMLElement): number => {
        const match = /translateY\((-?[\d.]+)px\)/.exec(
          card.getAttribute('style') || ''
        );
        return match ? parseFloat(match[1]!) : NaN;
      };

      assert.strictEqual(
        Math.abs(translateY(cards[1]!)),
        40,
        'the second card peeks by the custom @spacing, not the 16px default'
      );
    });

    test('it forwards @visibleToasts to the stack geometry', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      service.add('Message 1', options);
      service.add('Message 2', options);
      service.add('Message 3', options);

      await render(
        <template>
          <NotificationsContainer
            @visibleToasts={{1}}
            data-test-notifications
          />
        </template>
      );
      // `notification-card.gts`'s `enter` modifier flips `hasEntered` on the
      // frame after insertion (via `requestAnimationFrame`), and only once
      // that happens does the style getter switch from the enter/exit
      // transform (which forces `opacity: 0` regardless of stack position)
      // to the geometry-driven one this test reads. `settled()` doesn't
      // wait on a raw `requestAnimationFrame`, so wait for one directly.
      await new Promise((resolve) => requestAnimationFrame(resolve));
      await settled();

      const cards = findAll('[data-test-notification-card]') as HTMLElement[];
      const opacity = (card: HTMLElement): string => {
        const match = /opacity:\s*([\d.]+)/.exec(
          card.getAttribute('style') || ''
        );
        return match ? match[1]! : '';
      };

      assert.strictEqual(
        opacity(cards[0]!),
        '1',
        'the front card stays visible'
      );
      assert.strictEqual(
        opacity(cards[1]!),
        '0',
        'the second card is hidden once @visibleToasts is 1'
      );
    });

    // The `heights` map (notifications-container.gts) is keyed by
    // `Notification` identity and pruned on dismiss so it doesn't hold a
    // strong reference to every notification ever shown for the container's
    // lifetime. There's no DOM-observable difference between "pruned" and
    // "leaked" (a dismissed notification's own entry can never affect a
    // later, different notification's geometry either way), so this can't
    // assert the map's size directly without exposing an internal. Instead
    // it exercises the exact prune-on-dismiss and prune-on-measure code
    // paths end-to-end through the real dismiss and re-add flow, as a
    // regression guard against either path throwing or corrupting the
    // geometry of notifications that stay live.
    test('dismissing notifications and adding new ones after them keeps rendering correctly', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      await render(template);

      const first = service.add('Message 1', options);
      const second = service.add('Message 2', options);
      await settled();

      assert.dom('[data-test-notification-card]').exists({ count: 2 });

      service.remove(first);
      service.remove(second);
      await settled();

      assert.dom('[data-test-notification-card]').doesNotExist();

      service.add('Message 3', options);
      await settled();

      assert.dom('[data-test-notification-card]').exists({ count: 1 });

      // `notification-card.gts`'s `enter` modifier flips `hasEntered` on the
      // frame after insertion (via `requestAnimationFrame`), and only once
      // that happens does the style getter switch from the enter/exit
      // transform (which forces `opacity: 0`) to the geometry-driven one
      // this assertion reads. `settled()` doesn't wait on a raw
      // `requestAnimationFrame`, so wait for one directly.
      await new Promise((resolve) => requestAnimationFrame(resolve));
      await settled();

      const card = find('[data-test-notification-card]') as HTMLElement;
      assert.ok(
        card.getAttribute('style')?.includes('opacity: 1'),
        'the new notification, added after the previous ones were dismissed ' +
          'and pruned, renders with correct geometry'
      );
    });
  }
);
