# Toast Notification Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Frontile's broken, translucent, square toast notifications with an opaque, rounded, sonner-style stacked toast system that supports title/description content, icons, hover-expand stacking, and promise-driven notifications.

**Architecture:** All stack geometry is extracted into a dependency-free `NotificationStack` class so the hard math is unit-testable without a DOM. The container owns the stack, measures each card with a `ResizeObserver`, and hands each card a precomputed `{transform, zIndex, opacity, height}`. Cards are absolutely positioned inside a height-animated stack wrapper. `promise()` mutates a single tracked `Notification` in place rather than swapping notifications, so the card never unmounts mid-flight.

**Tech Stack:** Ember Octane + Glimmer, TypeScript/Glint, `.gts` template tags, Tailwind CSS v4 + `tailwind-variants` (`tv`) via `@frontile/theme`, QUnit + `@ember/test-helpers`, pnpm workspaces.

**Design spec:** `docs/superpowers/specs/2026-09-04-toast-notification-redesign-design.md`

## Global Constraints

- Source lives ONLY in `packages/frontile/src/`. The `packages/notifications/` package is a deprecation wrapper — never edit component source there.
- Prefer `.gts` over `.gjs`. Template-only components use `TOC` from `@ember/component/template-only`.
- `eq` is NOT available from `@ember/helper`. Available: `hash`, `array`, `fn`, `get`, `concat`. Import `on` from `@ember/modifier`.
- Styling is Tailwind Variants in `@frontile/theme` only. No plain CSS files, no inline colour values.
- Semantic colours are named levels, not a numbered scale: `subtle`, `muted`, `soft`, `mild`, DEFAULT, `firm`, `strong`, `bolder`. **`soft` is translucent — it must never appear in toast styles.** `subtle` is opaque in both themes.
- Build order is always `@frontile/theme` first, then `frontile`:
  ```bash
  pnpm --filter @frontile/theme build && pnpm --filter frontile build
  ```
- Tests run from `test-app` with `CI=true` and require `dangerouslyDisableSandbox: true` on the Bash tool (the sandbox blocks Chrome):
  ```bash
  cd test-app && CI=true pnpm ember test --filter="notification"
  ```
- Interpolated class strings in `tv()` generate no Tailwind CSS. Every class must appear as a complete literal string.
- Deprecation target version: `until: '0.19.0'`, `for: 'frontile'`, `since: { available: '0.18.0', enabled: '0.18.0' }`.
- Commit after every task. Never `git add -A` or `git add .` — stage only the named files.
- Branch is `claude/toast-notification-redesign-d0c0af`. Never commit to `main`.

### Accepted breaking changes

These are intentional and must be called out in the final docs task:

1. `notificationTransitions` is removed from `@frontile/theme` exports, and the `.notification-transition--*` classes are removed from the plugin and safelist. The toast no longer uses `ember-css-transitions` (the dependency stays — `overlays/backdrop.gts` and `overlays/overlay.gts` still use it).
2. The `notificationCard` theme slots change: `message` is replaced by `title` + `description`, and new slots `icon`, `content` are added. Anyone calling `registerCustomStyles({ notificationCard })` must update.
3. The theme variant axis renames `appearance` → `intent`, with `error` → `danger`.

---

## File Structure

**`@frontile/theme`**

| File | Responsibility |
| --- | --- |
| `packages/theme/src/components/notification-card.ts` | Rewritten `tv()`: new slots, `intent` × `variant` matrix. Drops `notificationTransitions`. |
| `packages/theme/src/components/notifications-container.ts` | Rewritten `tv()`: `base` (fixed, placed) + `stack` (relative positioning context). |
| `packages/theme/src/plugin.ts` | Drops the `.notification-transition` `addTransitions` call and its import. |
| `packages/theme/src/plugin/safelist.ts` | Drops the `notification-transition--*` entries. |

**`frontile`**

| File | Responsibility |
| --- | --- |
| `packages/frontile/src/-private/notification-stack.ts` | **New.** Pure geometry. No Ember, no DOM. |
| `packages/frontile/src/-private/types.ts` | `NotificationIntent`, `NotificationContent`, `PromiseNotificationOptions`; `intent`/`description`/`hideIcon` options; deprecated `appearance`. |
| `packages/frontile/src/-private/notification.ts` | Tracked content, `intent` normalisation + deprecation, `update()`. |
| `packages/frontile/src/-private/manager.ts` | `add()` content overload, `promise()`. |
| `packages/frontile/src/services/notifications.ts` | Re-exposes `add()` overload and `promise()`. |
| `packages/frontile/src/components/notifications/icons.gts` | **New.** Four `TOC` SVG icons. |
| `packages/frontile/src/components/notifications/notification-card.gts` | Rewritten: icon/title/description/actions, height reporting, geometry application. |
| `packages/frontile/src/components/notifications/notifications-container.gts` | Rewritten: owns `NotificationStack`, height registry, hover/focus expansion, global timer pause. |
| `packages/frontile/src/components/notifications/index.ts` | Exports the new types. |
| `packages/frontile/docs/notifications-usage.md` | Docs for `description`, `intent`, `variant`, `promise()`, stacking args, migration. |

**`test-app`**

| File | Responsibility |
| --- | --- |
| `test-app/tests/unit/notifications/notification-stack-test.ts` | **New.** Geometry unit tests. |
| `test-app/tests/unit/notifications/notification-test.ts` | Content model, intent, deprecation, `update()`. |
| `test-app/tests/unit/notifications/services/notifications-test.ts` | `promise()` behaviour. |
| `test-app/tests/integration/components/notifications/notification-card-test.gts` | Card rendering. |
| `test-app/tests/integration/components/notifications/notifications-container-test.gts` | Stacking, expansion, a11y. |

---

## Task 1: `NotificationStack` geometry

Pure TypeScript. No Ember, no DOM, no theme dependency — this task can be done and reviewed entirely on its own.

**Files:**
- Create: `packages/frontile/src/-private/notification-stack.ts`
- Create: `test-app/tests/unit/notifications/notification-stack-test.ts`
- Modify: `packages/frontile/src/components/notifications/index.ts`

**Interfaces:**
- Consumes: `containerPlacement` from `packages/frontile/src/-private/types.ts` (already exists: `'top-left' | 'top-center' | 'top-right' | 'bottom-left' | 'bottom-center' | 'bottom-right'`).
- Produces:
  - `class NotificationStack` with constructor `(input: NotificationStackInput)`
  - `interface NotificationStackInput { heights: number[]; isExpanded: boolean; gap: number; visibleToasts: number; placement: containerPlacement }`
  - `interface CardGeometry { transform: string; zIndex: number; opacity: number; height: number | null; transformOrigin: 'top center' | 'bottom center' }`
  - `stack.geometryFor(index: number): CardGeometry`
  - `stack.containerHeight: number`
  - `stack.isTopPlacement: boolean`

**Semantics to implement:** index `0` is the *front* of the stack (the newest toast). Cards are pinned to the placement edge, so a top placement grows downward (`directionSign = 1`) and a bottom placement grows upward (`directionSign = -1`).

- [ ] **Step 1: Write the failing test**

Create `test-app/tests/unit/notifications/notification-stack-test.ts`:

```ts
import { module, test } from 'qunit';
import { NotificationStack } from 'frontile/notifications';
import type { NotificationStackInput } from 'frontile/notifications';

function build(overrides: Partial<NotificationStackInput> = {}) {
  return new NotificationStack({
    heights: [60, 80, 100],
    isExpanded: false,
    gap: 16,
    visibleToasts: 3,
    placement: 'bottom-right',
    ...overrides
  });
}

module('Unit | @frontile/notifications/NotificationStack', function () {
  test('collapsed: front card is unscaled and unmoved', function (assert) {
    const geometry = build().geometryFor(0);

    assert.strictEqual(geometry.transform, 'translateY(0px) scale(1)');
    assert.strictEqual(geometry.opacity, 1);
    assert.strictEqual(geometry.height, 60, 'clamped to the front height');
  });

  test('collapsed: cards behind peek by gap and scale down by 0.05 each', function (assert) {
    const stack = build();

    assert.strictEqual(
      stack.geometryFor(1).transform,
      'translateY(-16px) scale(0.95)'
    );
    assert.strictEqual(
      stack.geometryFor(2).transform,
      'translateY(-32px) scale(0.9)'
    );
  });

  test('collapsed: every card is clamped to the front card height', function (assert) {
    const stack = build();

    assert.strictEqual(stack.geometryFor(1).height, 60);
    assert.strictEqual(stack.geometryFor(2).height, 60);
  });

  test('collapsed: cards past visibleToasts are transparent', function (assert) {
    const stack = build({ heights: [60, 80, 100, 40], visibleToasts: 3 });

    assert.strictEqual(stack.geometryFor(2).opacity, 1);
    assert.strictEqual(stack.geometryFor(3).opacity, 0);
  });

  test('expanded: cards offset by the summed heights of the cards in front', function (assert) {
    const stack = build({ isExpanded: true });

    assert.strictEqual(stack.geometryFor(0).transform, 'translateY(0px) scale(1)');
    assert.strictEqual(
      stack.geometryFor(1).transform,
      'translateY(-76px) scale(1)',
      '60 + 16 gap'
    );
    assert.strictEqual(
      stack.geometryFor(2).transform,
      'translateY(-172px) scale(1)',
      '60 + 16 + 80 + 16'
    );
  });

  test('expanded: heights are auto and every card is visible', function (assert) {
    const stack = build({ isExpanded: true, visibleToasts: 1 });

    assert.strictEqual(stack.geometryFor(2).height, null);
    assert.strictEqual(stack.geometryFor(2).opacity, 1);
  });

  test('top placements invert the direction and the transform origin', function (assert) {
    const stack = build({ placement: 'top-center' });

    assert.true(stack.isTopPlacement);
    assert.strictEqual(stack.geometryFor(1).transform, 'translateY(16px) scale(0.95)');
    assert.strictEqual(stack.geometryFor(1).transformOrigin, 'top center');
  });

  test('bottom placements anchor the transform origin to the bottom', function (assert) {
    const stack = build();

    assert.false(stack.isTopPlacement);
    assert.strictEqual(stack.geometryFor(0).transformOrigin, 'bottom center');
  });

  test('z-index descends from the front of the stack', function (assert) {
    const stack = build();

    assert.strictEqual(stack.geometryFor(0).zIndex, 3);
    assert.strictEqual(stack.geometryFor(2).zIndex, 1);
  });

  test('container height: collapsed shows the front card plus the peeks', function (assert) {
    assert.strictEqual(build().containerHeight, 60 + 2 * 16);
  });

  test('container height: collapsed peeks are capped at visibleToasts', function (assert) {
    const stack = build({ heights: [60, 80, 100, 40], visibleToasts: 2 });

    assert.strictEqual(stack.containerHeight, 60 + 1 * 16);
  });

  test('container height: expanded is the sum of heights plus gaps', function (assert) {
    const stack = build({ isExpanded: true });

    assert.strictEqual(stack.containerHeight, 60 + 80 + 100 + 2 * 16);
  });

  test('an empty stack has zero height', function (assert) {
    const stack = build({ heights: [] });

    assert.strictEqual(stack.containerHeight, 0);
  });

  test('a single card has no gaps in either state', function (assert) {
    assert.strictEqual(build({ heights: [60] }).containerHeight, 60);
    assert.strictEqual(
      build({ heights: [60], isExpanded: true }).containerHeight,
      60
    );
  });

  test('an unmeasured card does not produce NaN', function (assert) {
    const stack = build({ heights: [0, 0], isExpanded: true });

    assert.strictEqual(stack.geometryFor(1).transform, 'translateY(-16px) scale(1)');
    assert.strictEqual(stack.containerHeight, 16);
  });
});
```

- [ ] **Step 2: Run the test and verify it fails**

```bash
cd test-app && CI=true pnpm ember test --filter="NotificationStack"
```

Expected: FAIL — `NotificationStack` is not exported from `frontile/notifications`.

- [ ] **Step 3: Write the implementation**

Create `packages/frontile/src/-private/notification-stack.ts`:

```ts
import type { containerPlacement } from './types';

/**
 * How much each card behind the front of the stack shrinks, as a fraction.
 */
const SCALE_STEP = 0.05;

interface NotificationStackInput {
  /**
   * Measured card heights in px, ordered front-first (index 0 is the newest
   * notification). A card that has not been measured yet contributes 0.
   */
  heights: number[];

  isExpanded: boolean;

  /**
   * Peek offset between collapsed cards, and the gap between expanded cards.
   */
  gap: number;

  /**
   * How many cards stay visible while collapsed.
   */
  visibleToasts: number;

  placement: containerPlacement;
}

interface CardGeometry {
  transform: string;
  zIndex: number;
  opacity: number;

  /**
   * Fixed height in px while collapsed, so a taller card behind the front one
   * cannot stick out past it. `null` means the card sizes to its content.
   */
  height: number | null;

  transformOrigin: 'top center' | 'bottom center';
}

/**
 * Pure geometry for the notification stack: given measured card heights and
 * the current expansion state, it produces the transform for each card and
 * the height the container should animate to.
 *
 * Deliberately free of Ember and DOM dependencies so the layout maths can be
 * tested on its own.
 */
class NotificationStack {
  readonly heights: number[];
  readonly isExpanded: boolean;
  readonly gap: number;
  readonly visibleToasts: number;
  readonly placement: containerPlacement;

  constructor(input: NotificationStackInput) {
    this.heights = input.heights;
    this.isExpanded = input.isExpanded;
    this.gap = input.gap;
    this.visibleToasts = input.visibleToasts;
    this.placement = input.placement;
  }

  get isTopPlacement(): boolean {
    return this.placement.startsWith('top');
  }

  /**
   * Cards are pinned to the placement edge, so a top placement stacks
   * downwards and a bottom placement stacks upwards.
   */
  get directionSign(): number {
    return this.isTopPlacement ? 1 : -1;
  }

  get transformOrigin(): CardGeometry['transformOrigin'] {
    return this.isTopPlacement ? 'top center' : 'bottom center';
  }

  get count(): number {
    return this.heights.length;
  }

  get frontHeight(): number {
    return this.heights[0] ?? 0;
  }

  geometryFor(index: number): CardGeometry {
    const zIndex = this.count - index;

    if (this.isExpanded) {
      return {
        transform: `translateY(${this.directionSign * this.offsetBefore(index)}px) scale(1)`,
        zIndex,
        opacity: 1,
        height: null,
        transformOrigin: this.transformOrigin
      };
    }

    const offset = index * this.gap;
    const scale = Math.max(0, 1 - index * SCALE_STEP);

    return {
      transform: `translateY(${this.directionSign * offset}px) scale(${scale})`,
      zIndex,
      opacity: index < this.visibleToasts ? 1 : 0,
      height: this.frontHeight,
      transformOrigin: this.transformOrigin
    };
  }

  get containerHeight(): number {
    if (this.count === 0) {
      return 0;
    }

    if (this.isExpanded) {
      return this.offsetBefore(this.count) - this.gap;
    }

    const visible = Math.min(this.count, this.visibleToasts);
    return this.frontHeight + (visible - 1) * this.gap;
  }

  /**
   * Distance from the placement edge to the leading edge of `index`, i.e. the
   * summed heights and gaps of every card in front of it.
   */
  private offsetBefore(index: number): number {
    let offset = 0;

    for (let i = 0; i < index; i++) {
      offset += (this.heights[i] ?? 0) + this.gap;
    }

    return offset;
  }
}

export { NotificationStack };
export type { NotificationStackInput, CardGeometry };
```

- [ ] **Step 4: Export it**

In `packages/frontile/src/components/notifications/index.ts`, add below the existing `Timer` import:

```ts
import { NotificationStack } from '../../-private/notification-stack';
import type {
  NotificationStackInput,
  CardGeometry
} from '../../-private/notification-stack';
```

and extend the exports:

```ts
export { Notification, Timer, NotificationStack };
export type { NotificationStackInput, CardGeometry };
```

- [ ] **Step 5: Build and run the tests**

```bash
pnpm --filter frontile build && cd test-app && CI=true pnpm ember test --filter="NotificationStack"
```

Expected: PASS, 14 tests.

- [ ] **Step 6: Type check and lint**

```bash
pnpm --filter frontile lint:types && pnpm lint:js --fix
```

- [ ] **Step 7: Commit**

```bash
git add packages/frontile/src/-private/notification-stack.ts \
        packages/frontile/src/components/notifications/index.ts \
        test-app/tests/unit/notifications/notification-stack-test.ts
git commit -m "feat(notifications): add NotificationStack geometry

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

## Task 2: Notification content model, `intent`, and `update()`

**Files:**
- Modify: `packages/frontile/src/-private/types.ts`
- Modify: `packages/frontile/src/-private/notification.ts`
- Modify: `packages/frontile/src/components/notifications/index.ts`
- Modify: `test-app/tests/unit/notifications/notification-test.ts`

**Interfaces:**
- Consumes: nothing from Task 1.
- Produces:
  - `type NotificationIntent = 'info' | 'success' | 'warning' | 'danger'`
  - `interface NotificationContent { title: string; description?: string }`
  - `NotificationOptions` gains `intent?`, `description?`, `hideIcon?`, `isLoading?`, and keeps a deprecated `appearance?: 'info' | 'success' | 'warning' | 'error'`
  - `new Notification(config, content: string | NotificationContent, options?)`
  - `notification.title` (getter aliasing `message`), `notification.description`, `notification.intent`, `notification.isLoading`, `notification.appearance` (deprecated read-only getter)
  - `notification.update(changes: NotificationUpdate): void` where
    `interface NotificationUpdate { title?: string; description?: string; intent?: NotificationIntent; allowClosing?: boolean; isLoading?: boolean }`

- [ ] **Step 1: Write the failing tests**

Replace the whole body of `test-app/tests/unit/notifications/notification-test.ts` module with the following (keep the file's existing `eslint-disable` header line and imports, adding `NotificationIntent` where needed):

```ts
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
    assert.equal(notification.intent, 'info');
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
    const notification = new Notification({}, {
      title: 'Event created',
      description: 'Starts at 8:00 AM.'
    });

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

  test('the deprecated appearance option maps onto intent', async function (assert) {
    const notification = new Notification({}, 'Message', {
      appearance: 'error'
    });

    assert.equal(notification.intent, 'danger');
    assert.equal(notification.appearance, 'error', 'reads back as the old name');
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
});
```

Note: any remaining tests in the existing file that reference `appearance` as a writable option should be folded into the equivalents above rather than kept alongside them.

- [ ] **Step 2: Run the tests and verify they fail**

```bash
cd test-app && CI=true pnpm ember test --filter="@frontile/notifications/Notification"
```

Expected: FAIL — `notification.title`, `notification.intent`, `notification.isLoading` and `update` do not exist.

- [ ] **Step 3: Add the new types**

In `packages/frontile/src/-private/types.ts`, add above `NotificationOptions`:

```ts
export type NotificationIntent = 'info' | 'success' | 'warning' | 'danger';

/**
 * The deprecated intent names. `error` maps onto `danger`.
 */
export type NotificationAppearance = 'info' | 'success' | 'warning' | 'error';

export interface NotificationContent {
  /**
   * The heading line of the notification.
   */
  title: string;

  /**
   * Optional supporting line rendered below the title.
   */
  description?: string;
}

export interface NotificationUpdate {
  title?: string;
  description?: string;
  intent?: NotificationIntent;
  allowClosing?: boolean;
  isLoading?: boolean;
}
```

Then inside `NotificationOptions`, replace the existing `appearance` member with:

```ts
  /**
   * Supporting text rendered below the title.
   *
   * @defaultValue undefined
   */
  description?: string;

  /**
   * The intent of the notification.
   *
   * @defaultValue 'info'
   */
  intent?: NotificationIntent;

  /**
   * The appearance of the notification.
   *
   * @deprecated Use `intent` instead. `error` maps onto `danger`.
   * @defaultValue undefined
   */
  appearance?: NotificationAppearance;

  /**
   * Hide the leading icon.
   *
   * @defaultValue false
   */
  hideIcon?: boolean;

  /**
   * Render a spinner in place of the intent icon. Set by `promise()`.
   *
   * @defaultValue false
   */
  isLoading?: boolean;
```

- [ ] **Step 4: Rewrite the Notification class**

Replace the contents of `packages/frontile/src/-private/notification.ts`:

```ts
import { tracked } from '@glimmer/tracking';
import { deprecate } from '@ember/debug';
import Timer from './timer';
import { getConfigOption } from './get-config';
import type {
  NotificationOptions,
  NotificationContent,
  NotificationIntent,
  NotificationUpdate,
  CustomAction,
  DefaultConfig
} from './types';

/**
 * Normalise the two content forms into `{ title, description }`.
 */
function toContent(
  content: string | NotificationContent
): NotificationContent {
  return typeof content === 'string' ? { title: content } : content;
}

/**
 * Resolve the notification intent from the current option, the deprecated
 * `appearance` option, and the app config, in that order.
 */
function resolveIntent(
  config: DefaultConfig,
  options: NotificationOptions
): NotificationIntent {
  if (options.intent) {
    return options.intent;
  }

  if (options.appearance) {
    deprecate(
      'The `appearance` option for notifications is deprecated. Use `intent` instead, and `danger` in place of `error`.',
      false,
      {
        id: 'frontile.notification-appearance',
        until: '0.19.0',
        for: 'frontile',
        since: { available: '0.18.0', enabled: '0.18.0' }
      }
    );

    return options.appearance === 'error' ? 'danger' : options.appearance;
  }

  const fromConfig = getConfigOption(config, 'intent', 'info');
  return fromConfig as NotificationIntent;
}

export default class Notification<
  TMetadata extends Record<string, unknown> = Record<string, unknown>
> {
  /**
   * The title of the notification. Named `message` for backwards
   * compatibility with the original single-string API.
   */
  @tracked message: string;
  @tracked description?: string;
  @tracked intent: NotificationIntent;
  @tracked allowClosing: boolean;
  @tracked isLoading: boolean;
  @tracked customActions?: CustomAction[];
  @tracked timer?: Timer;
  @tracked isRemoving = false;

  readonly transitionDuration: number;
  readonly duration: number;
  readonly hideIcon: boolean;
  readonly metadata?: TMetadata;

  constructor(
    config: DefaultConfig,
    content: string | NotificationContent,
    options: NotificationOptions<TMetadata> = {}
  ) {
    const { title, description } = toContent(content);

    this.message = title;
    // An object content form owns the description outright; the option is only
    // a convenience for the string form.
    this.description =
      typeof content === 'string' ? options.description : description;
    this.intent = resolveIntent(config, options);
    this.isLoading = options.isLoading === true;
    this.hideIcon = options.hideIcon === true;
    this.customActions = options.customActions;
    this.duration =
      options.duration || getConfigOption(config, 'duration', 5000);
    this.transitionDuration =
      typeof options.transitionDuration !== 'undefined'
        ? options.transitionDuration
        : getConfigOption(config, 'transitionDuration', 200);
    this.metadata = options.metadata;
    this.allowClosing = options.allowClosing !== false;
  }

  get title(): string {
    return this.message;
  }

  /**
   * @deprecated Read `intent` instead.
   */
  get appearance(): 'info' | 'success' | 'warning' | 'error' {
    return this.intent === 'danger' ? 'error' : this.intent;
  }

  /**
   * Mutate the notification in place. Used by `promise()` so a settling
   * promise swaps the content of the toast already on screen rather than
   * replacing it with a new one.
   */
  update(changes: NotificationUpdate): void {
    if (typeof changes.title !== 'undefined') {
      this.message = changes.title;
    }

    if (typeof changes.description !== 'undefined') {
      this.description = changes.description;
    }

    if (typeof changes.intent !== 'undefined') {
      this.intent = changes.intent;
    }

    if (typeof changes.allowClosing !== 'undefined') {
      this.allowClosing = changes.allowClosing;
    }

    if (typeof changes.isLoading !== 'undefined') {
      this.isLoading = changes.isLoading;
    }
  }

  remove(): void {
    this.isRemoving = true;

    if (this.timer) {
      this.timer.clear();
    }
  }
}
```

- [ ] **Step 5: Export the new types**

In `packages/frontile/src/components/notifications/index.ts`, extend the type import and export lists:

```ts
import type {
  DefaultConfig,
  NotificationOptions,
  NotificationContent,
  NotificationIntent,
  NotificationUpdate,
  CustomAction
} from '../../-private/types';
```

```ts
export type {
  NotificationOptions,
  DefaultConfig,
  CustomAction,
  NotificationContent,
  NotificationIntent,
  NotificationUpdate
};
```

- [ ] **Step 6: Build and run the tests**

```bash
pnpm --filter frontile build && cd test-app && CI=true pnpm ember test --filter="@frontile/notifications/Notification"
```

Expected: PASS. If the deprecation causes a test failure rather than a warning, the test-app is configured to throw on deprecations — in that case wrap only the `appearance` test's assertion in `expectDeprecation` from `@ember/test-helpers` and note it in the commit.

- [ ] **Step 7: Type check and lint**

```bash
pnpm --filter frontile lint:types && pnpm lint:js --fix
```

- [ ] **Step 8: Commit**

```bash
git add packages/frontile/src/-private/types.ts \
        packages/frontile/src/-private/notification.ts \
        packages/frontile/src/components/notifications/index.ts \
        test-app/tests/unit/notifications/notification-test.ts
git commit -m "feat(notifications): add description, intent, and in-place update

Deprecates the appearance option in favour of intent, mapping error to danger.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

## Task 3: `promise()` on the manager and service

**Files:**
- Modify: `packages/frontile/src/-private/types.ts`
- Modify: `packages/frontile/src/-private/manager.ts`
- Modify: `packages/frontile/src/services/notifications.ts`
- Modify: `test-app/tests/unit/notifications/services/notifications-test.ts`

**Interfaces:**
- Consumes: from Task 2 — `NotificationContent`, `NotificationIntent`, `notification.update()`, `notification.isLoading`, `notification.isRemoving`.
- Produces:
  - `type PromiseMessage<T> = string | NotificationContent | ((value: T) => string | NotificationContent)`
  - `interface PromiseNotificationOptions<T, TMetadata>` extending `NotificationOptions<TMetadata>` with `loading: string | NotificationContent`, `success: PromiseMessage<T>`, `error: PromiseMessage<unknown>`
  - `manager.add(content: string | NotificationContent, options?)` — content overload
  - `manager.promise<T>(promise: Promise<T>, options): Promise<T>`
  - `service.promise<T>(promise: Promise<T>, options): Promise<T>`

- [ ] **Step 1: Write the failing tests**

Append to the module in `test-app/tests/unit/notifications/services/notifications-test.ts`. It already has `setupTest(hooks)`; get the service with `this.owner.lookup('service:notifications')`.

```ts
  test('promise shows a loading notification and returns the promise', async function (assert) {
    const service = this.owner.lookup(
      'service:notifications'
    ) as NotificationsService;

    let resolvePromise!: (value: string) => void;
    const pending = new Promise<string>((resolve) => {
      resolvePromise = resolve;
    });

    const returned = service.promise(pending, {
      loading: 'Saving…',
      success: 'Saved',
      error: 'Failed'
    });

    assert.strictEqual(returned, pending, 'returns the original promise');

    const notification = service.notifications[0]!;
    assert.equal(notification.title, 'Saving…');
    assert.equal(notification.isLoading, true);
    assert.equal(notification.allowClosing, false);
    assert.equal(
      typeof notification.timer,
      'undefined',
      'no auto-dismiss while loading'
    );

    resolvePromise('done');
    await pending;

    assert.equal(notification.title, 'Saved');
    assert.equal(notification.intent, 'success');
    assert.equal(notification.isLoading, false);
    assert.equal(notification.allowClosing, true);
    assert.notEqual(
      typeof notification.timer,
      'undefined',
      'auto-dismiss starts on settle'
    );
  });

  test('promise renders the rejection as a danger notification', async function (assert) {
    const service = this.owner.lookup(
      'service:notifications'
    ) as NotificationsService;

    const pending = Promise.reject(new Error('boom'));

    service.promise(pending, {
      loading: 'Saving…',
      success: 'Saved',
      error: 'Failed'
    });

    try {
      await pending;
    } catch {
      // expected
    }

    const notification = service.notifications[0]!;
    assert.equal(notification.title, 'Failed');
    assert.equal(notification.intent, 'danger');
    assert.equal(notification.isLoading, false);
  });

  test('promise accepts functions of the settled value', async function (assert) {
    const service = this.owner.lookup(
      'service:notifications'
    ) as NotificationsService;

    const pending = Promise.resolve({ name: 'Standup' });

    service.promise(pending, {
      loading: 'Saving…',
      success: (event) => ({ title: 'Saved', description: event.name }),
      error: 'Failed'
    });

    await pending;

    const notification = service.notifications[0]!;
    assert.equal(notification.title, 'Saved');
    assert.equal(notification.description, 'Standup');
  });

  test('promise accepts a function for the error message', async function (assert) {
    const service = this.owner.lookup(
      'service:notifications'
    ) as NotificationsService;

    const pending = Promise.reject(new Error('boom'));

    service.promise(pending, {
      loading: 'Saving…',
      success: 'Saved',
      error: (e) => `Could not save: ${(e as Error).message}`
    });

    try {
      await pending;
    } catch {
      // expected
    }

    assert.equal(service.notifications[0]!.title, 'Could not save: boom');
  });

  test('promise accepts an object loading form', async function (assert) {
    const service = this.owner.lookup(
      'service:notifications'
    ) as NotificationsService;

    service.promise(Promise.resolve(1), {
      loading: { title: 'Saving…', description: 'Hang tight.' },
      success: 'Saved',
      error: 'Failed'
    });

    const notification = service.notifications[0]!;
    assert.equal(notification.title, 'Saving…');
    assert.equal(notification.description, 'Hang tight.');
  });

  test('settling a dismissed notification is a no-op', async function (assert) {
    const service = this.owner.lookup(
      'service:notifications'
    ) as NotificationsService;

    const pending = Promise.resolve('done');

    service.promise(pending, {
      loading: 'Saving…',
      success: 'Saved',
      error: 'Failed'
    });

    const notification = service.notifications[0]!;
    service.remove(notification);

    await pending;

    assert.equal(notification.title, 'Saving…', 'content was not swapped');
    assert.equal(
      typeof notification.timer,
      'undefined',
      'no timer was started'
    );
  });

  test('add accepts an object content form', async function (assert) {
    const service = this.owner.lookup(
      'service:notifications'
    ) as NotificationsService;

    service.add({ title: 'Event created', description: 'Starts at 8:00 AM.' });

    assert.equal(service.notifications[0]!.title, 'Event created');
    assert.equal(service.notifications[0]!.description, 'Starts at 8:00 AM.');
  });
```

Ensure the file imports the service type:

```ts
import type { NotificationsService } from 'frontile';
```

- [ ] **Step 2: Run the tests and verify they fail**

```bash
cd test-app && CI=true pnpm ember test --filter="notifications/Service"
```

If that filter matches nothing, use the module name at the top of the test file. Expected: FAIL — `service.promise` is not a function.

- [ ] **Step 3: Add the promise types**

Append to `packages/frontile/src/-private/types.ts`:

```ts
/**
 * A promise notification message: a fixed string, a fixed content object, or
 * a function of the settled value.
 */
export type PromiseMessage<T> =
  | string
  | NotificationContent
  | ((value: T) => string | NotificationContent);

export interface PromiseNotificationOptions<
  T,
  TMetadata extends Record<string, unknown> = Record<string, unknown>
> extends Omit<NotificationOptions<TMetadata>, 'isLoading'> {
  /**
   * Shown with a spinner while the promise is pending.
   */
  loading: string | NotificationContent;

  /**
   * Shown when the promise resolves.
   */
  success: PromiseMessage<T>;

  /**
   * Shown when the promise rejects.
   */
  error: PromiseMessage<unknown>;
}
```

- [ ] **Step 4: Implement `add()` overload and `promise()` on the manager**

In `packages/frontile/src/-private/manager.ts`, extend the type imports:

```ts
import type {
  NotificationOptions,
  NotificationContent,
  NotificationIntent,
  PromiseMessage,
  PromiseNotificationOptions
} from './types';
```

Add above the class:

```ts
function resolveMessage<T>(
  message: PromiseMessage<T>,
  value: T
): NotificationContent {
  const resolved = typeof message === 'function' ? message(value) : message;
  return typeof resolved === 'string' ? { title: resolved } : resolved;
}
```

Change the `add` signature so it takes the content union (the body is unchanged):

```ts
  add<TMetadata extends Record<string, unknown> = Record<string, unknown>>(
    content: string | NotificationContent,
    options: NotificationOptions<TMetadata> = {}
  ): Notification<TMetadata> {
    const notification = new Notification<TMetadata>(
      this.config,
      content,
      options
    );
```

Add the new method after `add`:

```ts
  /**
   * Show a notification driven by a promise: a spinner while pending, then
   * the same notification mutated in place once it settles.
   *
   * Returns the original promise, so callers can still await it — and are
   * still responsible for handling its rejection.
   */
  promise<
    T,
    TMetadata extends Record<string, unknown> = Record<string, unknown>
  >(
    promise: Promise<T>,
    options: PromiseNotificationOptions<T, TMetadata>
  ): Promise<T> {
    const { loading, success, error, ...rest } = options;

    const notification = this.add<TMetadata>(loading, {
      ...(rest as NotificationOptions<TMetadata>),
      preserve: true,
      allowClosing: false,
      isLoading: true
    });

    const settle = (content: NotificationContent, intent: NotificationIntent) => {
      // The user may have dismissed the toast before the promise settled; in
      // that case there is nothing left to update.
      if (notification.isRemoving) {
        return;
      }

      notification.update({
        ...content,
        intent,
        allowClosing: true,
        isLoading: false
      });

      if (getConfigOption(this.config, 'skipTimer', false) !== true) {
        this.setupAutoRemoval(notification, notification.duration);
      }
    };

    promise.then(
      (value) => settle(resolveMessage(success, value), 'success'),
      (reason) => settle(resolveMessage(error, reason), 'danger')
    );

    return promise;
  }
```

Note `update({ ...content, ... })` spreads `{ title, description? }`, which matches `NotificationUpdate`.

- [ ] **Step 5: Expose it on the service**

In `packages/frontile/src/services/notifications.ts`, extend the type imports:

```ts
import type {
  NotificationOptions,
  NotificationContent,
  PromiseNotificationOptions
} from '../-private/types';
```

Change `add` and add `promise`:

```ts
  add = <TMetadata extends Record<string, unknown> = Record<string, unknown>>(
    content: string | NotificationContent,
    options?: NotificationOptions<TMetadata>
  ): Notification<TMetadata> => {
    return this.manager.add<TMetadata>(content, options);
  };

  promise = <
    T,
    TMetadata extends Record<string, unknown> = Record<string, unknown>
  >(
    promise: Promise<T>,
    options: PromiseNotificationOptions<T, TMetadata>
  ): Promise<T> => {
    return this.manager.promise<T, TMetadata>(promise, options);
  };
```

- [ ] **Step 6: Build and run the tests**

```bash
pnpm --filter frontile build && cd test-app && CI=true pnpm ember test --filter="notification"
```

Expected: PASS for Tasks 1–3. Card and container integration tests will still be failing at this point if they reference the old theme slots — that is expected and fixed in Tasks 5 and 6.

- [ ] **Step 7: Type check and lint**

```bash
pnpm --filter frontile lint:types && pnpm lint:js --fix
```

- [ ] **Step 8: Commit**

```bash
git add packages/frontile/src/-private/types.ts \
        packages/frontile/src/-private/manager.ts \
        packages/frontile/src/services/notifications.ts \
        test-app/tests/unit/notifications/services/notifications-test.ts
git commit -m "feat(notifications): add promise-driven notifications

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

## Task 4: Theme styles

No behavioural tests here — this task is verified by the theme build, the type check, and by Tasks 5/6 consuming it. Do not skip the build step; interpolated class strings silently generate no CSS.

**Files:**
- Modify: `packages/theme/src/components/notification-card.ts`
- Modify: `packages/theme/src/components/notifications-container.ts`
- Modify: `packages/theme/src/plugin.ts`
- Modify: `packages/theme/src/plugin/safelist.ts`

**Interfaces:**
- Consumes: nothing.
- Produces:
  - `notificationCard({ intent, variant })` returning slot functions `base`, `icon`, `content`, `title`, `description`, `customActions`, `customActionButton`, `closeButton`
  - `intent` values: `info | success | warning | danger`; `variant` values: `default | tonal | solid`
  - `notificationsContainer({ placement, class })` returning slot functions `base`, `stack`
  - `notificationTransitions` no longer exists

- [ ] **Step 1: Rewrite the card styles**

Replace the contents of `packages/theme/src/components/notification-card.ts`:

```ts
import { tv } from '../tw';
import { focusVisibleRing } from './shared';

const notificationCard = tv({
  slots: {
    base: [
      'pointer-events-auto w-full flex items-start gap-3 p-4',
      'rounded-2xl border shadow-lg',
      'font-body text-body-2xs',
      'overflow-hidden',
      'transition-[transform,opacity,height] duration-400 ease-[cubic-bezier(0.21,1.02,0.73,1)]',
      'motion-reduce:transition-[opacity] motion-reduce:duration-150'
    ],
    icon: 'shrink-0 size-5 mt-px',
    content: 'grow min-w-0 flex flex-col gap-1',
    title: 'font-label text-label-xs',
    description: 'text-body-2xs',
    customActions: 'flex flex-nowrap shrink-0 items-center gap-2 self-center',
    customActionButton: '',
    closeButton: [
      'shrink-0 self-center -mr-1 inline-block p-1.5 rounded-full',
      'transition duration-200',
      'hover:bg-surface-overlay-soft',
      ...focusVisibleRing
    ]
  },

  variants: {
    intent: {
      info: {},
      success: {},
      warning: {},
      danger: {}
    },
    variant: {
      default: {
        base: 'bg-surface-modal border-surface-overlay-mild',
        description: 'text-neutral'
      },
      tonal: {
        description: 'text-neutral'
      },
      solid: {
        base: 'border-transparent'
      }
    }
  },

  compoundVariants: [
    // default: neutral surface, colour carried by the icon and title.
    { variant: 'default', intent: 'info', class: { icon: 'text-primary', title: 'text-primary' } },
    { variant: 'default', intent: 'success', class: { icon: 'text-success-firm', title: 'text-success-firm' } },
    { variant: 'default', intent: 'warning', class: { icon: 'text-warning-firm', title: 'text-warning-firm' } },
    { variant: 'default', intent: 'danger', class: { icon: 'text-danger-firm', title: 'text-danger-firm' } },

    // tonal: opaque tinted surface. `subtle` is opaque in both themes; `soft`
    // is translucent and must never be used on a floating toast.
    {
      variant: 'tonal',
      intent: 'info',
      class: {
        base: 'bg-primary-subtle border-primary-muted',
        icon: 'text-primary',
        title: 'text-primary'
      }
    },
    {
      variant: 'tonal',
      intent: 'success',
      class: {
        base: 'bg-success-subtle border-success-muted',
        icon: 'text-success-firm',
        title: 'text-success-firm'
      }
    },
    {
      variant: 'tonal',
      intent: 'warning',
      class: {
        base: 'bg-warning-subtle border-warning-muted',
        icon: 'text-warning-firm',
        title: 'text-warning-firm'
      }
    },
    {
      variant: 'tonal',
      intent: 'danger',
      class: {
        base: 'bg-danger-subtle border-danger-muted',
        icon: 'text-danger-firm',
        title: 'text-danger-firm'
      }
    },

    // solid: filled surface, contrast text.
    {
      variant: 'solid',
      intent: 'info',
      class: {
        base: 'bg-primary text-on-primary',
        icon: 'text-on-primary',
        title: 'text-on-primary',
        description: 'text-on-primary/80'
      }
    },
    {
      variant: 'solid',
      intent: 'success',
      class: {
        base: 'bg-success text-on-success',
        icon: 'text-on-success',
        title: 'text-on-success',
        description: 'text-on-success/80'
      }
    },
    {
      variant: 'solid',
      intent: 'warning',
      class: {
        base: 'bg-warning text-on-warning',
        icon: 'text-on-warning',
        title: 'text-on-warning',
        description: 'text-on-warning/80'
      }
    },
    {
      variant: 'solid',
      intent: 'danger',
      class: {
        base: 'bg-danger text-on-danger',
        icon: 'text-on-danger',
        title: 'text-on-danger',
        description: 'text-on-danger/80'
      }
    }
  ],

  defaultVariants: {
    intent: 'info',
    variant: 'default'
  }
});

export { notificationCard };
```

- [ ] **Step 2: Rewrite the container styles**

Replace the contents of `packages/theme/src/components/notifications-container.ts`:

```ts
import { tv } from '../tw';

const notificationsContainer = tv({
  slots: {
    base: ['fixed z-1000 w-full max-w-lg px-4 py-4'],
    stack: [
      'relative w-full',
      'transition-[height] duration-400 ease-[cubic-bezier(0.21,1.02,0.73,1)]',
      'motion-reduce:transition-none'
    ]
  },
  variants: {
    placement: {
      'top-left': { base: 'top-0 left-0' },
      'top-center': { base: 'top-0 left-2/4 translate-x-[-50%]' },
      'top-right': { base: 'top-0 right-0' },
      'bottom-left': { base: 'bottom-0 left-0' },
      'bottom-center': { base: 'bottom-0 left-2/4 translate-x-[-50%]' },
      'bottom-right': { base: 'bottom-0 right-0' }
    }
  },
  defaultVariants: {
    placement: 'bottom-right'
  }
});

export { notificationsContainer };
```

- [ ] **Step 3: Remove the dead transitions**

In `packages/theme/src/plugin.ts`, delete `notificationTransitions` from the `./components` import (keep any other names in that import) and delete the `addTransitions` call block for `'.notification-transition'` at around lines 33–36.

In `packages/theme/src/plugin/safelist.ts`, delete every entry matching `notification-transition--*`.

- [ ] **Step 4: Build the theme and type check**

```bash
pnpm --filter @frontile/theme build && pnpm --filter @frontile/theme lint:types
```

Expected: clean build. If `lint:types` reports that `notificationTransitions` is still referenced, finish removing it.

- [ ] **Step 5: Confirm no translucent token slipped in**

```bash
grep -n "\-soft" packages/theme/src/components/notification-card.ts
```

Expected: only `hover:bg-surface-overlay-soft` on `closeButton` — that is an intentional hover wash over an opaque card, not a card surface.

- [ ] **Step 6: Lint**

```bash
pnpm lint:js --fix
```

- [ ] **Step 7: Commit**

```bash
git add packages/theme/src/components/notification-card.ts \
        packages/theme/src/components/notifications-container.ts \
        packages/theme/src/plugin.ts \
        packages/theme/src/plugin/safelist.ts
git commit -m "feat(theme): redesign notification card and container styles

Replaces translucent -soft surfaces with opaque ones, adds an intent x variant
matrix, and drops the ember-css-transitions notification transitions.

BREAKING CHANGE: notificationTransitions is no longer exported, and the
notificationCard slots changed from message to title + description.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

## Task 5: Icons and the NotificationCard component

**Files:**
- Create: `packages/frontile/src/components/notifications/icons.gts`
- Modify: `packages/frontile/src/components/notifications/notification-card.gts`
- Modify: `test-app/tests/integration/components/notifications/notification-card-test.gts`

**Interfaces:**
- Consumes: from Task 1 `CardGeometry`; from Task 2 `notification.title/description/intent/isLoading/hideIcon`; from Task 4 `notificationCard({ intent, variant })` with slots `base`, `icon`, `content`, `title`, `description`, `customActions`, `customActionButton`, `closeButton`.
- Produces: `NotificationCard` with args
  `@notification`, `@placement`, `@variant?`, `@geometry?: CardGeometry`, `@onMeasure?: (height: number) => void`.
  The `geometry`/`onMeasure` pair is what Task 6's container drives; when they are absent the card renders statically, which is what the card's own integration tests rely on.

**Note on the existing test file:** it calls `registerCustomStyles({ notificationCard: tv({...}) })` with the old slots and `appearance` variants. That block must be replaced with the new slot and variant names, or the test will not type check.

- [ ] **Step 1: Write the failing tests**

In `test-app/tests/integration/components/notifications/notification-card-test.gts`, replace the `registerCustomStyles` call at the top of the file with:

```ts
registerCustomStyles({
  notificationCard: tv({
    slots: {
      base: '',
      icon: 'notification-card__icon',
      content: '',
      title: 'notification-card__title',
      description: 'notification-card__description',
      customActions: '',
      customActionButton: 'notification-card__custom-action-btn',
      closeButton: 'notification-card__close-btn'
    },
    variants: {
      intent: {
        info: { base: 'notification-card--info' },
        success: { base: 'notification-card--success' },
        warning: { base: 'notification-card--warning' },
        danger: { base: 'notification-card--danger' }
      },
      variant: {
        default: { base: 'notification-card--default' },
        tonal: { base: 'notification-card--tonal' },
        solid: { base: 'notification-card--solid' }
      }
    },
    defaultVariants: {
      intent: 'info',
      variant: 'default'
    }
  })
});
```

Then add these tests to the module:

```ts
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

    test('it applies the intent class', async function (assert) {
      notification.current = new Notification({}, 'Message', {
        intent: 'danger'
      });
      await render(template);

      assert.dom('.notification-card--danger').exists();
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

      assert
        .dom('.notification-card__icon')
        .hasAttribute('data-test-icon', 'loading');
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
```

Keep the file's existing tests for custom actions and close-button behaviour, updating any assertion that targeted the removed `message` slot to target `.notification-card__title`.

**Delete** the card's existing hover pause/resume tests. Pausing moved from the card to the container in Task 6 — it now pauses every timer in the stack, not just the hovered card's — and it is covered by the container test `expanding pauses the timers of every notification`. Leaving the card tests in place would assert behaviour the card no longer has.

- [ ] **Step 2: Run the tests and verify they fail**

```bash
cd test-app && CI=true pnpm ember test --filter="NotificationCard"
```

Expected: FAIL — the title/description/icon elements do not exist.

- [ ] **Step 3: Create the icons**

Create `packages/frontile/src/components/notifications/icons.gts`:

```ts
import type { TOC } from '@ember/component/template-only';

type IconSignature = TOC<{ Element: SVGElement }>;

const IconInfo: IconSignature = <template>
  <svg
    xmlns="http://www.w3.org/2000/svg"
    fill="none"
    viewBox="0 0 24 24"
    stroke-width="1.5"
    stroke="currentColor"
    aria-hidden="true"
    data-test-icon="info"
    ...attributes
  >
    <path
      stroke-linecap="round"
      stroke-linejoin="round"
      d="M11.25 11.25h.75v4.5h.75M12 8.25h.008v.008H12V8.25ZM21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
    />
  </svg>
</template>;

const IconSuccess: IconSignature = <template>
  <svg
    xmlns="http://www.w3.org/2000/svg"
    fill="none"
    viewBox="0 0 24 24"
    stroke-width="1.5"
    stroke="currentColor"
    aria-hidden="true"
    data-test-icon="success"
    ...attributes
  >
    <path
      stroke-linecap="round"
      stroke-linejoin="round"
      d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
    />
  </svg>
</template>;

const IconWarning: IconSignature = <template>
  <svg
    xmlns="http://www.w3.org/2000/svg"
    fill="none"
    viewBox="0 0 24 24"
    stroke-width="1.5"
    stroke="currentColor"
    aria-hidden="true"
    data-test-icon="warning"
    ...attributes
  >
    <path
      stroke-linecap="round"
      stroke-linejoin="round"
      d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126ZM12 15.75h.007v.008H12v-.008Z"
    />
  </svg>
</template>;

const IconDanger: IconSignature = <template>
  <svg
    xmlns="http://www.w3.org/2000/svg"
    fill="none"
    viewBox="0 0 24 24"
    stroke-width="1.5"
    stroke="currentColor"
    aria-hidden="true"
    data-test-icon="danger"
    ...attributes
  >
    <path
      stroke-linecap="round"
      stroke-linejoin="round"
      d="m9.75 9.75 4.5 4.5m0-4.5-4.5 4.5M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
    />
  </svg>
</template>;

export { IconInfo, IconSuccess, IconWarning, IconDanger };
```

- [ ] **Step 4: Rewrite the card component**

Replace the contents of `packages/frontile/src/components/notifications/notification-card.gts`:

```ts
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { modifier } from 'ember-modifier';
import { service } from '@ember/service';
import { htmlSafe } from '@ember/template';
import { fn } from '@ember/helper';
import { CloseButton } from '../buttons/close-button';
import { Button } from '../buttons/button';
import { Spinner } from '../utilities/spinner';
import { IconInfo, IconSuccess, IconWarning, IconDanger } from './icons';
import { useStyles } from '@frontile/theme';

import type NotificationsService from '../../services/notifications';
import type Notification from '../../-private/notification';
import type { CardGeometry } from '../../-private/notification-stack';
import type {
  CustomAction,
  containerPlacement,
  NotificationIntent
} from '../../-private/types';
import type { SafeString } from '@ember/template';

const ICONS = {
  info: IconInfo,
  success: IconSuccess,
  warning: IconWarning,
  danger: IconDanger
};

/**
 * Button intent for the primary custom action, per notification intent.
 */
const ACTION_INTENT = {
  info: 'primary',
  success: 'success',
  warning: 'warning',
  danger: 'danger'
} as const;

interface NotificationCardSignature {
  Args: {
    notification: Notification<Record<string, unknown>>;
    placement: containerPlacement;

    /**
     * The visual style of the card.
     *
     * @defaultValue 'default'
     */
    variant?: 'default' | 'tonal' | 'solid';

    /**
     * Position, scale, and stacking supplied by the container. When omitted
     * the card renders in place with no stack transform.
     */
    geometry?: CardGeometry;

    /**
     * Called with the card's measured height whenever it changes.
     */
    onMeasure?: (height: number) => void;
  };
  Element: HTMLDivElement;
}

class NotificationCard extends Component<NotificationCardSignature> {
  @service notifications!: NotificationsService;

  /**
   * False for the first frame so the card can transition in from the
   * placement edge rather than appearing at its resting position.
   */
  @tracked hasEntered = false;

  get isTopPlacement(): boolean {
    return (this.args.placement || 'bottom-right').startsWith('top');
  }

  get intent(): NotificationIntent {
    return this.args.notification.intent;
  }

  get icon() {
    return ICONS[this.intent];
  }

  get actionIntent() {
    return ACTION_INTENT[this.intent];
  }

  /**
   * `alert` interrupts a screen reader, so it is reserved for the intents
   * that warrant interrupting.
   */
  get role(): 'status' | 'alert' {
    return this.intent === 'warning' || this.intent === 'danger'
      ? 'alert'
      : 'status';
  }

  get style(): SafeString {
    const { geometry, notification } = this.args;
    const declarations = [
      `transition-duration: ${notification.transitionDuration}ms, ${notification.transitionDuration}ms, 400ms`
    ];

    // Cards are pinned to the placement edge so the stack grows away from it.
    // This lives here rather than on the container, because a `style`
    // attribute passed through `...attributes` replaces the element's own
    // `style` outright and would drop the transform below.
    if (geometry) {
      declarations.push(
        'position: absolute',
        'left: 0',
        'right: 0',
        this.isTopPlacement ? 'top: 0' : 'bottom: 0'
      );
    }

    if (!this.hasEntered || notification.isRemoving) {
      // Enter from, and exit to, the placement edge.
      const offset = this.isTopPlacement ? '-100%' : '100%';
      declarations.push(
        `opacity: 0`,
        `transform: translateY(${offset}) scale(0.95)`
      );

      if (geometry) {
        declarations.push(
          `z-index: ${geometry.zIndex}`,
          `transform-origin: ${geometry.transformOrigin}`
        );
      }

      return htmlSafe(declarations.join('; '));
    }

    if (geometry) {
      declarations.push(
        `transform: ${geometry.transform}`,
        `transform-origin: ${geometry.transformOrigin}`,
        `z-index: ${geometry.zIndex}`,
        `opacity: ${geometry.opacity}`,
        geometry.height === null ? `height: auto` : `height: ${geometry.height}px`
      );
    }

    return htmlSafe(declarations.join('; '));
  }

  /**
   * Flip to the resting position on the frame after insertion, so the browser
   * has a start value to transition from.
   */
  enter = modifier(() => {
    const frame = requestAnimationFrame(() => {
      this.hasEntered = true;
    });

    return () => cancelAnimationFrame(frame);
  });

  /**
   * Report the card's height to the container so the stack can lay itself
   * out. Also fires when promise content swaps change the height.
   */
  measure = modifier((element: HTMLElement) => {
    const { onMeasure } = this.args;

    if (!onMeasure) {
      return;
    }

    const observer = new ResizeObserver(() => {
      onMeasure(element.offsetHeight);
    });

    onMeasure(element.offsetHeight);
    observer.observe(element);

    return () => observer.disconnect();
  });

  remove = () => {
    this.notifications.remove(this.args.notification);
  };

  handleClickCustomAction = (customAction: CustomAction) => {
    customAction.onClick();
    this.notifications.remove(this.args.notification);
  };

  get classes() {
    const { notificationCard } = useStyles();

    const {
      base,
      icon,
      content,
      title,
      description,
      customActions,
      customActionButton,
      closeButton
    } = notificationCard({
      intent: this.intent,
      variant: this.args.variant || 'default'
    });

    return {
      base: base(),
      icon: icon(),
      content: content(),
      title: title(),
      description: description(),
      customActions: customActions(),
      customActionButton: customActionButton(),
      closeButton: closeButton()
    };
  }

  <template>
    {{! template-lint-disable no-inline-styles style-concatenation }}
    <div
      class={{this.classes.base}}
      style={{this.style}}
      role={{this.role}}
      data-test-notification-card
      {{this.enter}}
      {{this.measure}}
      ...attributes
    >
      {{#unless @notification.hideIcon}}
        {{#if @notification.isLoading}}
          <Spinner
            class={{this.classes.icon}}
            @size="sm"
            data-test-icon="loading"
          />
        {{else}}
          {{#let this.icon as |Icon|}}
            <Icon class={{this.classes.icon}} />
          {{/let}}
        {{/if}}
      {{/unless}}

      <div class={{this.classes.content}}>
        <div class={{this.classes.title}}>{{@notification.title}}</div>

        {{#if @notification.description}}
          <div class={{this.classes.description}}>
            {{@notification.description}}
          </div>
        {{/if}}
      </div>

      {{#if @notification.customActions}}
        <div class={{this.classes.customActions}}>
          {{#each @notification.customActions as |customAction index|}}
            <Button
              @size="xs"
              @intent={{if index "default" this.actionIntent}}
              @appearance={{if index "minimal" "default"}}
              @class={{this.classes.customActionButton}}
              @onPress={{fn this.handleClickCustomAction customAction}}
            >
              {{customAction.label}}
            </Button>
          {{/each}}
        </div>
      {{/if}}

      {{#if @notification.allowClosing}}
        <CloseButton
          @onPress={{this.remove}}
          @size="sm"
          @class={{this.classes.closeButton}}
        />
      {{/if}}
    </div>
  </template>
}

export { NotificationCard, type NotificationCardSignature };
export default NotificationCard;
```

Note the `{{if index "default" this.actionIntent}}` idiom: `index` is `0` (falsy) for the first action, so the first custom action gets the intent colour and the rest are minimal. `eq` is unavailable, which is why this is written as a truthiness check.

- [ ] **Step 5: Verify the imports resolve**

```bash
grep -n "export" packages/frontile/src/components/utilities/spinner.gts | head -3
grep -n "export" packages/frontile/src/components/buttons/button.gts | head -3
```

Expected: `Spinner` and `Button` are named exports. If `Spinner` has no `@size="sm"` variant, drop that argument and size it with the `icon` slot class instead.

- [ ] **Step 6: Build and run the tests**

```bash
pnpm --filter frontile build && cd test-app && CI=true pnpm ember test --filter="NotificationCard"
```

Expected: PASS.

- [ ] **Step 7: Type check and lint**

```bash
pnpm --filter frontile lint:types && pnpm lint:hbs --fix && pnpm lint:js --fix
```

- [ ] **Step 8: Commit**

```bash
git add packages/frontile/src/components/notifications/icons.gts \
        packages/frontile/src/components/notifications/notification-card.gts \
        test-app/tests/integration/components/notifications/notification-card-test.gts
git commit -m "feat(notifications): redesign the notification card

Adds intent icons, a title/description layout, a loading spinner state, and
per-intent aria roles.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

## Task 6: Stacking container with hover/focus expansion

**Files:**
- Modify: `packages/frontile/src/components/notifications/notifications-container.gts`
- Modify: `test-app/tests/integration/components/notifications/notifications-container-test.gts`

**Interfaces:**
- Consumes: Task 1 `NotificationStack`; Task 5 `NotificationCard` with `@geometry` and `@onMeasure`; Task 4 `notificationsContainer({ placement, class })` slots `base` and `stack`.
- Produces: `NotificationsContainer` with args `@placement`, `@spacing`, `@variant`, `@visibleToasts`, `@expand`, `@class`, `@onDismiss`.

- [ ] **Step 1: Write the failing tests**

Update the `registerCustomStyles` block in `test-app/tests/integration/components/notifications/notifications-container-test.gts` so `notificationsContainer` is a slotted `tv`:

```ts
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
```

Add these tests:

```ts
    test('it stacks cards front-first with descending z-index', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      service.add('First');
      service.add('Second');
      await render(<template><NotificationsContainer /></template>);

      const cards = findAll('[data-test-notification-card]');
      assert.strictEqual(cards.length, 2);
      assert
        .dom(cards[0])
        .hasStyle({ zIndex: '2' }, 'the newest card is at the front');
      assert.dom(cards[0]!).hasText(/Second/);
    });

    test('it expands on hover and collapses on leave', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      service.add('First');
      service.add('Second');
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

    test('it expands on focusin so hidden cards are reachable', async function (assert) {
      const service = this.owner.lookup(
        'service:notifications'
      ) as NotificationsService;

      service.add('First');
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

      service.add('First');
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

      service.add('First', { duration: 10000 });
      service.add('Second', { duration: 10000 });
      await render(<template><NotificationsContainer /></template>);

      await triggerEvent('.notifications-container', 'mouseenter');

      assert.false(service.notifications[0]!.timer!.isRunning);
      assert.false(service.notifications[1]!.timer!.isRunning);

      await triggerEvent('.notifications-container', 'mouseleave');

      assert.true(service.notifications[0]!.timer!.isRunning);
      assert.true(service.notifications[1]!.timer!.isRunning);
    });

    test('the container is a polite live region', async function (assert) {
      await render(<template><NotificationsContainer /></template>);

      assert.dom('[role="region"]').hasAttribute('aria-live', 'polite');
      assert.dom('[role="region"]').hasAttribute('aria-label', 'Notifications');
    });
```

Ensure the file imports `findAll` and `triggerEvent` from `@ember/test-helpers`.

Also update any existing test in this file that asserted the old `role="alert"` on the container to expect `role="region"`.

**Note:** this test file's default config must have `skipTimer` off for the timer-pause test. If `test-app/config/environment.js` sets `'@frontile/notifications': { skipTimer: true }`, that test must construct its notifications with explicit timers instead — check the config before writing it and adapt.

- [ ] **Step 2: Run the tests and verify they fail**

```bash
cd test-app && CI=true pnpm ember test --filter="NotificationsContainer"
```

Expected: FAIL — no `data-expanded` attribute, no `role="region"`.

- [ ] **Step 3: Rewrite the container**

Replace the contents of `packages/frontile/src/components/notifications/notifications-container.gts`:

```ts
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import { htmlSafe } from '@ember/template';
import { registerDestructor } from '@ember/destroyable';
import NotificationCard from './notification-card';
import { NotificationStack } from '../../-private/notification-stack';
import type NotificationsService from '../../services/notifications';
import type Notification from '../../-private/notification';
import { type containerPlacement } from '../../-private/types';
import { useStyles } from '@frontile/theme';
import type Owner from '@ember/owner';
import type { SafeString } from '@ember/template';

interface NotificationsContainerSignature {
  Args: {
    /**
     * The placement of the notifications
     *
     * @defaultValue 'bottom-right'
     */
    placement?: containerPlacement;

    /**
     * The peek offset between collapsed cards, and the gap between expanded
     * cards, in px.
     *
     * @defaultValue 16
     */
    spacing?: number;

    /**
     * The visual style applied to every card.
     *
     * @defaultValue 'default'
     */
    variant?: 'default' | 'tonal' | 'solid';

    /**
     * How many cards stay visible while the stack is collapsed.
     *
     * @defaultValue 3
     */
    visibleToasts?: number;

    /**
     * Keep the stack expanded instead of collapsing it when not hovered.
     *
     * @defaultValue false
     */
    expand?: boolean;

    /**
     * Custom class name, it will override the default ones using Tailwind Merge library.
     */
    class?: string;

    /**
     * Callback called when a notification is dismissed
     */
    onDismiss?: (notification: Notification<Record<string, unknown>>) => void;
  };
  Element: HTMLDivElement;
}

class NotificationsContainer extends Component<NotificationsContainerSignature> {
  @service notifications!: NotificationsService;

  @tracked isHovered = false;

  /**
   * Measured card heights, keyed by notification. Reassigned rather than
   * mutated so reads stay tracked.
   */
  @tracked heights: Map<Notification<Record<string, unknown>>, number> =
    new Map();

  constructor(owner: Owner, args: NotificationsContainerSignature['Args']) {
    super(owner, args);

    // Register a stable callback that delegates to the current `@onDismiss`,
    // so a change to the argument is picked up without re-registering.
    this.notifications.setOnRemoveCallback(this.handleDismiss);

    // Clean up when component is destroyed, but only if we are still the
    // registered owner: the service holds a single callback slot, so another
    // container might have taken it over in the meantime.
    registerDestructor(this, () => {
      if (this.notifications.onRemoveCallback === this.handleDismiss) {
        this.notifications.setOnRemoveCallback(undefined);
      }
    });
  }

  handleDismiss = (notification: Notification<Record<string, unknown>>) => {
    this.args.onDismiss?.(notification);
  };

  get placement(): containerPlacement {
    return this.args.placement || 'bottom-right';
  }

  get spacing(): number {
    return typeof this.args.spacing === 'undefined' ? 16 : this.args.spacing;
  }

  get visibleToasts(): number {
    return typeof this.args.visibleToasts === 'undefined'
      ? 3
      : this.args.visibleToasts;
  }

  get isExpanded(): boolean {
    return this.args.expand === true || this.isHovered;
  }

  /**
   * Newest first, for every placement. The placement only decides which edge
   * the stack is pinned to and which way it grows, never the order.
   */
  get stackOrder(): Notification<Record<string, unknown>>[] {
    return this.notifications.notifications.slice().reverse();
  }

  get stack(): NotificationStack {
    return new NotificationStack({
      heights: this.stackOrder.map(
        (notification) => this.heights.get(notification) ?? 0
      ),
      isExpanded: this.isExpanded,
      gap: this.spacing,
      visibleToasts: this.visibleToasts,
      placement: this.placement
    });
  }

  get stackStyle(): SafeString {
    return htmlSafe(`height: ${this.stack.containerHeight}px`);
  }

  measure = (
    notification: Notification<Record<string, unknown>>,
    height: number
  ) => {
    if (this.heights.get(notification) === height) {
      return;
    }

    const next = new Map(this.heights);
    next.set(notification, height);
    this.heights = next;
  };

  /**
   * Expanding the stack pauses every timer, not just the hovered card's:
   * the user is reading the whole stack, so none of it should time out.
   */
  expand = () => {
    if (this.isHovered) {
      return;
    }

    this.isHovered = true;
    this.notifications.notifications.forEach((notification) => {
      notification.timer?.pause();
    });
  };

  collapse = () => {
    if (!this.isHovered) {
      return;
    }

    this.isHovered = false;
    this.notifications.notifications.forEach((notification) => {
      notification.timer?.resume();
    });
  };

  get classes() {
    const { notificationsContainer } = useStyles();

    const { base, stack } = notificationsContainer({
      placement: this.placement,
      class: this.args.class
    });

    return { base: base(), stack: stack() };
  }

  <template>
    {{! template-lint-disable no-inline-styles }}
    <div
      class={{this.classes.base}}
      role="region"
      aria-label="Notifications"
      aria-live="polite"
      {{on "mouseenter" this.expand}}
      {{on "mouseleave" this.collapse}}
      {{on "focusin" this.expand}}
      {{on "focusout" this.collapse}}
      ...attributes
    >
      <div
        class={{this.classes.stack}}
        style={{this.stackStyle}}
        data-expanded="{{if this.isExpanded 'true' 'false'}}"
      >
        {{#each this.stackOrder key="@identity" as |notification index|}}
          <NotificationCard
            @notification={{notification}}
            @placement={{this.placement}}
            @variant={{@variant}}
            @geometry={{this.stack.geometryFor index}}
            @onMeasure={{fn this.measure notification}}
          />
        {{/each}}
      </div>
    </div>
  </template>
}

export { NotificationsContainer, type NotificationsContainerSignature };
export default NotificationsContainer;
```

Two notes for the implementer:

1. `{{this.stack.geometryFor index}}` calls the method in the template. If Glint rejects calling a class method with an argument this way, add a `geometryFor = (index: number) => this.stack.geometryFor(index)` arrow property and use `{{this.geometryFor index}}`.
2. `@class` previously merged onto the single container class; it now merges onto the `base` slot, which is the equivalent behaviour.

- [ ] **Step 4: Build and run the tests**

```bash
pnpm --filter frontile build && cd test-app && CI=true pnpm ember test --filter="NotificationsContainer"
```

Expected: PASS.

- [ ] **Step 5: Run the whole notification suite**

```bash
cd test-app && CI=true pnpm ember test --filter="notification"
```

Expected: PASS for Tasks 1–6.

- [ ] **Step 6: Type check and lint**

```bash
pnpm --filter frontile lint:types && pnpm lint:hbs --fix && pnpm lint:js --fix
```

- [ ] **Step 7: Commit**

```bash
git add packages/frontile/src/components/notifications/notifications-container.gts \
        test-app/tests/integration/components/notifications/notifications-container-test.gts
git commit -m "feat(notifications): add collapsed stack with hover and focus expansion

Replaces the JS height animation with an absolutely positioned stack driven by
NotificationStack, and softens the container live region to polite.

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

## Task 7: Documentation

**REQUIRED SUB-SKILL:** invoke the `frontile-docs` skill before editing the docs — it governs how Frontile component docs and their live Docfy demos are written.

**Files:**
- Modify: `packages/frontile/docs/notifications-usage.md`

**Interfaces:**
- Consumes: everything from Tasks 1–6.
- Produces: no code.

Every GJS code fence in this file is rendered by Docfy as a **live demo**, so every snippet must actually compile and run against the new API.

- [ ] **Step 1: Invoke the docs skill**

Use the `frontile-docs` skill and follow its conventions for the rest of this task.

- [ ] **Step 2: Audit the existing demos**

```bash
grep -n "appearance" packages/frontile/docs/notifications-usage.md
```

Every `appearance:` in a demo must become `intent:`, with `'error'` becoming `'danger'`. Any demo left on `appearance` will emit a deprecation warning in the rendered docs.

- [ ] **Step 3: Update the Key Features list**

Replace the existing list with one that covers: title and description content, intent icons, the three variants, the collapsed stack with hover/focus expansion, promise-driven notifications, auto-dismissal with pause on hover, custom actions, six placements, dismissal callbacks, metadata, TypeScript generics, and accessibility.

- [ ] **Step 4: Add a description demo**

A live demo calling:

```ts
this.notifications.add('Event created', {
  description: 'The event starts at 8:00 AM.',
  intent: 'success'
});
```

plus a second button showing the object form `this.notifications.add({ title, description })`.

- [ ] **Step 5: Add a variants demo**

Three containers or one container with `@variant` switched between `default`, `tonal`, and `solid`, each firing all four intents so the rendered demo shows the full matrix in both themes.

- [ ] **Step 6: Add a stacking section**

Document `@visibleToasts` (default 3), `@expand`, and `@spacing` (peek offset when collapsed, gap when expanded), with a demo that adds five notifications at once so the collapsed stack and its hover expansion are visible.

- [ ] **Step 7: Add a promise section**

A live demo:

```ts
save = () => {
  this.notifications.promise(this.saveEvent(), {
    loading: 'Saving event…',
    success: (event) => ({
      title: 'Event created',
      description: `${event.name} starts at 8:00 AM.`
    }),
    error: (e) => `Could not save: ${(e as Error).message}`
  });
};
```

with a second button that rejects, so both paths are demonstrable. Note that `promise()` returns the original promise and the caller still owns its rejection handling.

- [ ] **Step 8: Add a migration section**

Cover, with before/after snippets:
- `appearance` → `intent`, and `'error'` → `'danger'` (deprecated, removed in 0.19)
- `notificationTransitions` removed from `@frontile/theme`
- `notificationCard` theme slots: `message` → `title` + `description`, plus new `icon` and `content` slots
- the container's live region moving from `assertive` to `polite`, with per-card `status`/`alert`

- [ ] **Step 9: Verify the docs render**

```bash
cd site && pnpm build
```

Expected: a clean build. A demo that references a removed API fails here.

- [ ] **Step 10: Commit**

```bash
git add packages/frontile/docs/notifications-usage.md
git commit -m "docs(notifications): document description, intent, variants, stacking, and promise

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

## Task 8: Full verification

No new code. This is the gate before opening a PR.

**Files:** none.

- [ ] **Step 1: Clean full build**

```bash
pnpm build
```

Expected: every package builds.

- [ ] **Step 2: Full test suite**

```bash
cd test-app && CI=true pnpm ember test
```

Expected: green. Compare any failure against the pre-existing failures on `main` before treating it as a regression — this repo has known red gates unrelated to notifications.

- [ ] **Step 3: Lint and type check everything**

```bash
pnpm lint:hbs --fix
pnpm lint:js --fix
pnpm --filter frontile lint:types
pnpm --filter @frontile/theme lint:types
cd test-app && pnpm lint:types
```

- [ ] **Step 4: Visual verification**

Start the docs site and screenshot the notifications page in both themes:

```bash
cd site && pnpm start
```

Use the browser tooling to fire one notification of each intent, confirm:
- no page content shows through any card (the original bug)
- the collapsed stack peeks and expands on hover
- a promise notification swaps spinner → icon without the card unmounting
- dark mode: judge whether `surface.modal` reads as a lifted card or too flat. **If it reads too flat, the spec's recorded fallback is a new `surface.toast` role (light `white`, dark `gray-900`)** — raise it rather than fixing it silently, since it changes the token set.

- [ ] **Step 5: Report**

Summarise: what passed, what failed, any pre-existing failures, and the dark-mode flatness judgement.
