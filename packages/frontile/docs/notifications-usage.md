---
url: /notifications/
label: Updated
imports:
  - import Signature from 'site/components/signature';
---

# Toast Notification

Toast notifications give brief, non-intrusive feedback about an operation — a save
succeeded, an upload failed, an item can still be undone — through a small popup that
disappears on its own and never demands the user's attention the way a modal does. Reach
for a modal instead when the message needs a decision, and for inline validation when it's
about a specific form field.

## Import

```js
import {
  NotificationsContainer,
  type NotificationsService
} from 'frontile';
```

## Usage

`NotificationsContainer` renders `notifications.notifications` from the **shared,
application-wide** notifications service — it does not own any notification data itself.
Mount exactly one `NotificationsContainer`, in your application template, rather than one
per feature or component:

```hbs
{{! app/templates/application.hbs }}
<div id='app-content'>
  {{outlet}}
</div>

{{! Global notifications container }}
<NotificationsContainer @placement='bottom-right' />
```

> **Important**: if more than one `NotificationsContainer` is mounted at the same time,
> **every** container renders **every** notification, so each toast appears once per mounted
> container. A single global container also gives you one place to configure placement and
> handle dismissal callbacks (see [Dismissal Callbacks and Metadata](#dismissal-callbacks-and-metadata)).

With the container mounted, inject the notifications service anywhere and call `add`:

```gts preview
import Component from '@glimmer/component';
import { service } from '@ember/service';
import { Button } from 'frontile';
import type { NotificationsService } from 'frontile';

export default class BasicExample extends Component {
  @service notifications!: NotificationsService;

  showNotification = () => {
    this.notifications.add('This is a basic notification!');
  };

  <template>
    <Button @onPress={{this.showNotification}}>
      Show Notification
    </Button>
  </template>
}
```

## Intents

Use `intent` to convey the appropriate message type: `'default'`, `'info'`, `'success'`,
`'warning'`, or `'danger'`. Each intent renders a matching icon automatically; pass
`hideIcon: true` to suppress it.

`'default'` is the intent used when none is given — a bare `notifications.add('message')`
produces a `default` toast. It still renders the same info glyph as the `info` intent, just
in a neutral color rather than the primary accent, so callers who want the old
teal-accented look pass `intent: 'info'` explicitly.

```gts preview
import Component from '@glimmer/component';
import { service } from '@ember/service';
import { Button } from 'frontile';
import type { NotificationsService } from 'frontile';

export default class IntentExample extends Component {
  @service notifications!: NotificationsService;

  showDefault = () => {
    this.notifications.add('This is a default notification');
  };

  showInfo = () => {
    this.notifications.add('This is an info notification', {
      intent: 'info'
    });
  };

  showSuccess = () => {
    this.notifications.add('Operation completed successfully!', {
      intent: 'success'
    });
  };

  showWarning = () => {
    this.notifications.add('Please check your input', {
      intent: 'warning'
    });
  };

  showDanger = () => {
    this.notifications.add('Something went wrong', {
      intent: 'danger'
    });
  };

  <template>
    <div class='grid grid-cols-2 gap-2'>
      <Button @onPress={{this.showDefault}}>Default</Button>
      <Button @onPress={{this.showInfo}}>Info</Button>
      <Button @onPress={{this.showSuccess}} @intent='success'>Success</Button>
      <Button @onPress={{this.showWarning}} @intent='warning'>Warning</Button>
      <Button @onPress={{this.showDanger}} @intent='danger'>Danger</Button>
    </div>
  </template>
}
```

> **Note**: `appearance` still works but is deprecated — see [Migrating from `appearance`](#migrating-from-appearance) below.

## Title and Description

`add` takes the title as a string, with an optional `description` alongside it, or a single content object with both fields.

```gts preview
import Component from '@glimmer/component';
import { service } from '@ember/service';
import { Button } from 'frontile';
import type { NotificationsService } from 'frontile';

export default class DescriptionExample extends Component {
  @service notifications!: NotificationsService;

  showStringForm = () => {
    this.notifications.add('Event created', {
      description: 'The event starts at 8:00 AM.',
      intent: 'success'
    });
  };

  showObjectForm = () => {
    this.notifications.add({
      title: 'Event created',
      description: 'The event starts at 8:00 AM.'
    });
  };

  <template>
    <div class='flex gap-2'>
      <Button @onPress={{this.showStringForm}}>
        String + Options
      </Button>
      <Button @onPress={{this.showObjectForm}} @appearance='outlined'>
        Content Object
      </Button>
    </div>
  </template>
}
```

## Variants

`@variant` on `NotificationsContainer` controls the surface style applied to every card in
the stack:

- **`default`** — a neutral opaque card; the intent color is carried only by the icon and title.
- **`tonal`** — the same recipe as `Button`'s `appearance="tonal"`: an opaque neutral card
  whose inner row carries a translucent `{intent}-soft` tint with its `on-{intent}-soft`
  contrast text, so the card stays fully opaque while the tint reads like a tonal button.
- **`solid`** — a filled surface in the intent color, with contrast text.

```gts
<NotificationsContainer @variant='tonal' />
```

Try all three live in the [Stacking](#stacking) demo below — its variant control drives the
one container mounted on this page.

## Placement

`@placement` controls which corner or edge the stack sits on: `'top-left'`, `'top-center'`,
`'top-right'`, `'bottom-left'`, `'bottom-center'`, or `'bottom-right'` (the default).
Placement only decides which edge the stack is pinned to — newer notifications always stack
toward the front regardless of placement.

```gts
<NotificationsContainer @placement='top-right' />
```

Compare placements live in the [Stacking](#stacking) demo below.

## Stacking

Collapsed, the stack shows only the front few cards peeking out from behind each other;
hovering or focusing it expands the whole stack so every toast is readable. Three
container arguments control this:

- **`@visibleToasts`** (default `3`) — how many cards stay visible while collapsed.
- **`@spacing`** (default `16`) — the peek offset between collapsed cards, in pixels, and
  also the gap between cards once the stack is expanded.
- **`@expand`** (default `false`) — keep the stack always expanded instead of collapsing it
  when it isn't hovered or focused.

Because only one `NotificationsContainer` should ever be mounted at a time, this single demo
drives that one container from every argument covered in this section as well as
[Variants](#variants) and [Placement](#placement) above — rather than mounting a second
container per argument.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import {
  Button,
  RadioGroup,
  Switch,
  NotificationsContainer,
  type NotificationsService,
  type NotificationIntent
} from 'frontile';

export default class StackingExample extends Component {
  @service notifications!: NotificationsService;

  @tracked variant: 'default' | 'tonal' | 'solid' = 'default';
  @tracked placement = 'bottom-right';
  @tracked visibleToastsKey = '3';
  @tracked expand = false;

  variants = [
    { key: 'default', label: 'Default' },
    { key: 'tonal', label: 'Tonal' },
    { key: 'solid', label: 'Solid' }
  ];

  placements = [
    { key: 'top-left', label: 'Top Left' },
    { key: 'top-center', label: 'Top Center' },
    { key: 'top-right', label: 'Top Right' },
    { key: 'bottom-left', label: 'Bottom Left' },
    { key: 'bottom-center', label: 'Bottom Center' },
    { key: 'bottom-right', label: 'Bottom Right' }
  ];

  visibleToastsOptions = [
    { key: '2', label: '2' },
    { key: '3', label: '3' },
    { key: '5', label: '5' }
  ];

  intents: NotificationIntent[] = [
    'default',
    'info',
    'success',
    'warning',
    'danger'
  ];

  get visibleToasts() {
    return parseInt(this.visibleToastsKey, 10) || 3;
  }

  setVariant = (variant: string) => {
    this.variant = variant as 'default' | 'tonal' | 'solid';
  };

  setPlacement = (placement: string) => {
    this.placement = placement;
  };

  setVisibleToasts = (value: string) => {
    this.visibleToastsKey = value;
  };

  toggleExpand = (value: boolean) => {
    this.expand = value;
  };

  showAllIntents = () => {
    this.intents.forEach((intent) => {
      this.notifications.add(`${intent} notification`, {
        intent,
        preserve: true
      });
    });
  };

  showFive = () => {
    for (let i = 1; i <= 5; i++) {
      this.notifications.add(`Notification ${i}`, { preserve: true });
    }
  };

  clear = () => {
    this.notifications.removeAll();
  };

  <template>
    <div class='flex flex-col gap-4'>
      <div class='grid grid-cols-1 sm:grid-cols-3 gap-4'>
        <RadioGroup
          @label='Variant'
          @value={{this.variant}}
          @onChange={{this.setVariant}}
          as |Radio|
        >
          {{#each this.variants as |option|}}
            <Radio @value={{option.key}} @label={{option.label}} />
          {{/each}}
        </RadioGroup>

        <RadioGroup
          @label='Placement'
          @value={{this.placement}}
          @onChange={{this.setPlacement}}
          as |Radio|
        >
          {{#each this.placements as |option|}}
            <Radio @value={{option.key}} @label={{option.label}} />
          {{/each}}
        </RadioGroup>

        <RadioGroup
          @label='Visible Toasts'
          @value={{this.visibleToastsKey}}
          @onChange={{this.setVisibleToasts}}
          as |Radio|
        >
          {{#each this.visibleToastsOptions as |option|}}
            <Radio @value={{option.key}} @label={{option.label}} />
          {{/each}}
        </RadioGroup>
      </div>

      <Switch
        @label='Keep stack expanded (@expand)'
        @isSelected={{this.expand}}
        @onChange={{this.toggleExpand}}
      />

      <div class='flex flex-wrap gap-2'>
        <Button @onPress={{this.showAllIntents}}>Show All Intents</Button>
        <Button @onPress={{this.showFive}}>Show 5 Notifications</Button>
        <Button @onPress={{this.clear}} @appearance='outlined'>Clear</Button>
      </div>

      <p class='text-body-2xs text-neutral-muted'>
        Hover or focus the stack to expand it (or toggle "Keep stack expanded"
        above). Collapsed, it shows
        {{this.visibleToasts}}
        card(s) peeking; the rest stay tucked behind them.
      </p>

      <NotificationsContainer
        @placement={{this.placement}}
        @variant={{this.variant}}
        @visibleToasts={{this.visibleToasts}}
        @expand={{this.expand}}
      />
    </div>
  </template>
}
```

## Custom Actions

Add action buttons to notifications for user interaction.

```gts preview
import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { Button } from 'frontile';
import type { NotificationsService } from 'frontile';

export default class ActionsExample extends Component {
  @service notifications!: NotificationsService;
  @tracked result = '';

  showWithActions = () => {
    this.result = '';
    this.notifications.add('File uploaded successfully!', {
      intent: 'success',
      duration: 10000, // Keep it open longer for user to act
      customActions: [
        {
          label: 'View',
          onClick: () => {
            this.result = 'User clicked View';
          }
        },
        {
          label: 'Share',
          onClick: () => {
            this.result = 'User clicked Share';
          }
        }
      ]
    });
  };

  showUndoAction = () => {
    this.result = '';
    this.notifications.add('Item deleted', {
      intent: 'info',
      duration: 8000,
      customActions: [
        {
          label: 'Undo',
          onClick: () => {
            this.result = 'Undo clicked - item restored!';
          }
        }
      ]
    });
  };

  <template>
    <div class='flex flex-col gap-4'>
      <div class='flex gap-2'>
        <Button @onPress={{this.showWithActions}}>
          Upload Success with Actions
        </Button>
        <Button @onPress={{this.showUndoAction}}>
          Show Undo Action
        </Button>
      </div>

      {{#if this.result}}
        <div
          class='p-3 rounded border bg-success-subtle text-success-strong border-success-muted'
        >
          {{this.result}}
        </div>
      {{/if}}
    </div>
  </template>
}
```

## Duration and Persistence

Every notification auto-dismisses after `duration` milliseconds (default `5000`), unless
`preserve: true` keeps it open until the user (or a custom action) closes it.

```gts preview
import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { Button } from 'frontile';
import { Input } from 'frontile';
import type { NotificationsService } from 'frontile';

export default class TimingExample extends Component {
  @service notifications!: NotificationsService;
  @tracked duration = 3000;

  showShortDuration = () => {
    this.notifications.add('Quick notification (1 second)', {
      intent: 'info',
      duration: 1000
    });
  };

  showLongDuration = () => {
    this.notifications.add('Long notification (10 seconds)', {
      intent: 'warning',
      duration: 10000
    });
  };

  showCustomDuration = () => {
    this.notifications.add(`Custom duration (${this.duration}ms)`, {
      intent: 'success',
      duration: this.duration
    });
  };

  updateDuration = (value) => {
    this.duration = parseInt(value) || 3000;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Input
        @label='Duration (ms)'
        @type='number'
        @value={{this.duration}}
        @onInput={{this.updateDuration}}
      />

      <div class='flex gap-2'>
        <Button @onPress={{this.showShortDuration}}>
          1 Second
        </Button>
        <Button @onPress={{this.showLongDuration}}>
          10 Seconds
        </Button>
        <Button @onPress={{this.showCustomDuration}}>
          Custom Duration
        </Button>
      </div>
    </div>
  </template>
}
```

Use `preserve: true` to prevent automatic dismissal entirely, and `allowClosing: false` to
also hide the close button — pair the latter with a custom action so the notification still
has a way out.

```gts preview
import Component from '@glimmer/component';
import { service } from '@ember/service';
import { Button } from 'frontile';
import type { NotificationsService } from 'frontile';

export default class PersistentExample extends Component {
  @service notifications!: NotificationsService;

  showPersistent = () => {
    this.notifications.add('This notification stays until manually closed', {
      intent: 'warning',
      preserve: true
    });
  };

  showWithoutCloseButton = () => {
    this.notifications.add('No close button - click actions to dismiss', {
      intent: 'info',
      preserve: true,
      allowClosing: false,
      customActions: [
        {
          label: 'Got it',
          onClick: () => {
            // This will dismiss the notification
          }
        }
      ]
    });
  };

  <template>
    <div class='flex gap-2'>
      <Button @onPress={{this.showPersistent}}>
        Persistent Notification
      </Button>
      <Button @onPress={{this.showWithoutCloseButton}}>
        No Close Button
      </Button>
    </div>
  </template>
}
```

> Auto-dismissal pauses for every visible notification while the stack is hovered or
> focused, not just the one under the pointer — see [Accessibility](#accessibility).

## Promise-Driven Notifications

`promise()` shows a loading toast with a spinner, then mutates that same toast into a
success or error state once the promise settles — no second toast is created. While
pending, the toast cannot be dismissed. `loading` takes a string or a `{ title, description }`
object; `success` and `error` each take a string, a `{ title, description }` object, or a
function of the resolved value (for `success`) or rejection reason (for `error`) returning
either.

`promise()` returns the **original promise** unchanged, so the caller still owns rejection
handling — the toast alone does not swallow a rejection. Any other notification option
passed alongside `loading`/`success`/`error` — `preserve` included — carries through to the
settled notification: the loading phase is always non-dismissible while pending, but once it
settles, a caller's own `preserve: true` is honored rather than silently overridden.

```gts preview
import Component from '@glimmer/component';
import { service } from '@ember/service';
import { Button } from 'frontile';
import type { NotificationsService } from 'frontile';

interface Event {
  name: string;
}

export default class PromiseExample extends Component {
  @service notifications!: NotificationsService;

  saveEvent = (shouldFail: boolean): Promise<Event> => {
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        if (shouldFail) {
          reject(new Error('Network error'));
        } else {
          resolve({ name: 'Team sync' });
        }
      }, 1500);
    });
  };

  save = () => {
    this.notifications.promise(this.saveEvent(false), {
      loading: 'Saving event…',
      success: (event) => ({
        title: 'Event created',
        description: `${event.name} starts at 8:00 AM.`
      }),
      error: (e) => `Could not save: ${(e as Error).message}`
    });
  };

  saveWithError = () => {
    // promise() returns the original promise, so rejection handling is
    // still ours even though the toast already told the user what happened.
    this.notifications
      .promise(this.saveEvent(true), {
        loading: 'Saving event…',
        success: (event) => ({
          title: 'Event created',
          description: `${event.name} starts at 8:00 AM.`
        }),
        error: (e) => `Could not save: ${(e as Error).message}`
      })
      .catch(() => {
        // Already surfaced to the user as a toast.
      });
  };

  <template>
    <div class='flex flex-col gap-4'>
      <div class='flex gap-2'>
        <Button @onPress={{this.save}}>Save (succeeds)</Button>
        <Button @onPress={{this.saveWithError}} @appearance='outlined'>
          Save (fails)
        </Button>
      </div>
    </div>
  </template>
}
```

## Dismissal Callbacks and Metadata

Track notification dismissals for analytics, backend updates, or cleanup. Set the callback
on the global container, in your application template:

`@onDismiss` is called **exactly once per notification**, after it has actually been
removed — repeated dismissals of the same notification (e.g. a double-click on the close
button) do not call it again. The callback is always read from the current `@onDismiss`
argument, so changing it at runtime takes effect immediately.

```hbs
{{! app/templates/application.hbs }}
<NotificationsContainer
  @placement='bottom-right'
  @onDismiss={{this.handleNotificationDismissed}}
/>
```

```gts
// app/controllers/application.ts
import Controller from '@ember/controller';

export default class ApplicationController extends Controller {
  handleNotificationDismissed = (notification) => {
    if (notification.metadata) {
      this.analytics.track('notification_dismissed', notification.metadata);
    }
  };
}
```

Then from any component, add notifications with metadata:

```gts preview
import Component from '@glimmer/component';
import { service } from '@ember/service';
import { Button } from 'frontile';
import type { NotificationsService } from 'frontile';

export default class CallbackExample extends Component {
  @service notifications!: NotificationsService;

  showWithCallback = () => {
    this.notifications.add('Notification with tracking', {
      intent: 'info',
      metadata: {
        id: `notification_${Date.now()}`,
        source: 'demo',
        action: 'user_interaction'
      }
    });
  };

  <template>
    <Button @onPress={{this.showWithCallback}}>
      Show Tracked Notification
    </Button>
  </template>
}
```

Use a TypeScript generic on `add` for strongly-typed metadata, so a reader (or the compiler)
knows exactly what shape to expect back from `notification.metadata`:

```typescript
interface UserActionMetadata {
  userId: string;
  action: 'upload' | 'delete' | 'share';
  resourceId: string;
  timestamp: string;
}

const notification = this.notifications.add<UserActionMetadata>(
  'File uploaded successfully',
  {
    intent: 'success',
    metadata: {
      userId: '123',
      action: 'upload',
      resourceId: 'file-456',
      timestamp: new Date().toISOString()
    }
  }
);

// notification.metadata is now strongly typed as UserActionMetadata
```

## Accessibility

- **ARIA Attributes**: The container uses `role="region"`, `aria-label="Notifications"`, and
  `aria-live="polite"`. Each card carries `role="status"` (default, info, success) or
  `role="alert"` (warning, danger) — `alert` is reserved for intents that warrant interrupting the screen
  reader.
- **Screen Reader Support**: Notifications are announced as they appear, without stealing
  focus.
- **Keyboard Navigation**: The stack expands on `focusin` as well as hover, so keyboard users
  reach the same expanded view; close buttons and custom actions are focusable and operable
  with the keyboard.
- **Hover and Focus Behavior**: Auto-dismissal pauses for every visible notification while the
  stack is hovered or focused, not just the one underneath the pointer.
- **Text Contrast**: `default` uses the brightest levels of the `success`/`warning` palette scale
  at the `firm` level the other intents' title/icon text uses, so both fall below the 4.5:1 WCAG
  AA floor at `firm` — the theme uses `bolder` for their title/icon text instead. `tonal` composites
  the translucent `{intent}-soft` tint over the card's opaque surface and pairs it with the
  auto-generated `on-{intent}-soft` contrast ink (the same recipe `Button`'s `appearance="tonal"`
  uses), which clears AA for every intent in both themes without any hand-picked text level or
  background override. `solid`'s title, icon, and description all use the full-strength
  `on-{intent}` ink — an earlier version put the description at 80% opacity, but compositing
  white/black at 80% over a saturated fill (e.g. `danger`'s `#e51701`) drops as low as 3.37:1 in
  light mode, well below the 4.5:1 WCAG AA floor. Measured ratios (WCAG relative luminance,
  resolving the composited `{intent}-soft`-over-surface color where relevant):

  | Pairing                                                                | Light | Dark  |
  | ----------------------------------------------------------------------- | ----- | ----- |
  | `default`/`tonal` description (`text-neutral-firm`)                     | 8.1   | 8.9–11.6 |
  | `default` `success`/`warning` title (`bolder`)                          | 9.3 / 7.6 | 16.3 / 11.4 |
  | `default` `info`/`danger`/neutral title                                 | ≥5.6  | ≥6.4  |
  | `tonal` `default` (`on-neutral-soft` on composited `neutral-soft`)      | 15.4  | 8.1   |
  | `tonal` `info` (`on-primary-soft` on composited `primary-soft`)         | 18.0  | 12.4  |
  | `tonal` `success` (`on-success-soft` on composited `success-soft`)      | 19.5  | 12.0  |
  | `tonal` `warning` (`on-warning-soft` on composited `warning-soft`)      | 17.9  | 13.8  |
  | `tonal` `danger` (`on-danger-soft` on composited `danger-soft`)         | 16.4  | 16.6  |
  | `solid` `default` title/icon/description (`on-neutral`)                 | 6.71  | 9.60  |
  | `solid` `info` title/icon/description (`on-primary`)                    | 6.49  | 9.72  |
  | `solid` `success` title/icon/description (`on-success`)                 | 16.29 | 16.29 |
  | `solid` `warning` title/icon/description (`on-warning`)                 | 9.41  | 9.41  |
  | `solid` `danger` title/icon/description (`on-danger`)                   | 4.71  | 6.09  |

## Migrating from `appearance`

The notification API was redesigned in 0.18: `message` became the title with a new sibling
`description`, `appearance` was renamed `intent` (`'error'` became `'danger'`), the container
gained a collapsible stack, and the theme slots changed to match. `appearance` keeps working
until 0.19, emitting a deprecation warning.

**The default intent changed from `'info'` to `'default'`**

A bare `add()` call with no `intent` option used to render as an `info`-colored (primary/teal)
toast. It now renders as a neutral `default` toast — same info icon, no accent color. This is
an intentional visual behavior change. Callers who want the previous teal look should pass
`intent: 'info'` explicitly:

```ts
// Before: a bare add() was info-colored
this.notifications.add('Saved');

// After: a bare add() is neutral; pass intent explicitly for the old look
this.notifications.add('Saved', { intent: 'info' });
```

**`appearance` → `intent`, `'error'` → `'danger'`**

```ts
// Before
this.notifications.add('Something went wrong', { appearance: 'error' });

// After
this.notifications.add('Something went wrong', { intent: 'danger' });
```

**Reading `notification.appearance` back can now yield `'default'`**

The deprecated `appearance` getter on a `Notification` instance mirrors `intent`, and since
`default` is now the intent a bare `add()` call resolves to, `appearance` can return `'default'`
for it — a value that isn't part of the exported `NotificationAppearance` type (`'info' |
'success' | 'warning' | 'error'`). Code that still reads this getter should account for it:
assigning it to a `NotificationAppearance`-typed variable is a compile error, and a `switch`
over the four old names silently falls through for every notification created without an
explicit `appearance`/`intent`. Add a `'default'` case (or switch to `intent`, which is typed
to include it):

```ts
// Reading the deprecated getter still compiles, but 'default' needs handling
switch (notification.appearance) {
  case 'default':
    // new: bare add() calls land here now
    break;
  case 'info':
  case 'success':
  case 'warning':
  case 'error':
    // ...
    break;
}
```

**`notificationTransitions` removed**

`notificationTransitions` is no longer exported from `@frontile/theme`, and the
`.notification-transition--*` classes were removed from the Tailwind plugin and its safelist.
Transitions are now built into the `notificationCard` and `notificationsContainer` theme
slots directly — remove any import of `notificationTransitions` and any manual use of those
classes.

```ts
// Before
import { notificationTransitions } from '@frontile/theme';

// After
// no import needed — transitions ship with the component styles
```

**`notificationCard` theme slots**

The `message` slot was replaced by `title` and `description`, and `icon` and `content` slots
were added. Update any `registerCustomStyles({ notificationCard })` call accordingly:

```ts
// Before
registerCustomStyles({
  notificationCard: tv({
    slots: {
      base: '...',
      message: '...',
      closeButton: '...'
    }
  })
});

// After
registerCustomStyles({
  notificationCard: tv({
    slots: {
      base: '...',
      icon: '...',
      content: '...',
      title: '...',
      description: '...',
      closeButton: '...'
    }
  })
});
```

**`notificationCard` gained an `inner` slot**

The card is now two elements: `base` (the outer box — surface color, border, rounded corners,
shadow, and the collapsed-stack height clamp) and `inner` (a new slot — the flex row layout:
gap, padding, and icon/content-alignment). This split exists so the stack's height measurement
always reads the content's true natural height rather than whatever height `base` might be
clamped to while the stack is collapsed. If you override `notificationCard`, add an `inner`
slot for the row layout (`flex gap-3 p-4`) and move any padding/gap/alignment classes off
`base` and onto it; `base` should keep only box/surface classes.

**`notificationsContainer` theme slots**

`notificationsContainer` now returns `base` and `stack` slots instead of a single class
string:

```ts
// Before
registerCustomStyles({
  notificationsContainer: tv({
    base: '...'
  })
});

// After
registerCustomStyles({
  notificationsContainer: tv({
    slots: {
      base: '...',
      stack: '...'
    }
  })
});
```

**ARIA attributes**

The container's live region moved from `role="alert"` + `aria-live="assertive"` to
`role="region"` + `aria-label="Notifications"` + `aria-live="polite"`, so the whole stack no
longer interrupts a screen reader on every new toast. Each card now carries its own
`role="status"` (default/info/success) or `role="alert"` (warning/danger) instead. No consumer code
change is required, but update any test or a11y check that asserted the old attributes.

## API

### NotificationsService

The notifications service manages the global notification state and provides methods for adding and removing notifications.

| Method                | Parameters                                                                          | Return Type               | Description                                                                                             |
| --------------------- | ------------------------------------------------------------------------------------ | -------------------------- | --------------------------------------------------------------------------------------------------------- |
| `add<TMetadata>`      | `content: string \| NotificationContent`, `options?: NotificationOptions<TMetadata>` | `Notification<TMetadata>` | Adds a new notification with optional metadata and configuration                                          |
| `promise<T, TMetadata>` | `promise: Promise<T>`, `options: PromiseNotificationOptions<T, TMetadata>`          | `Promise<T>`               | Shows a loading toast that mutates into success or danger when the promise settles; returns the original promise |
| `remove`              | `notification?: Notification`                                                        | `void`                      | Removes a specific notification                                                                           |
| `removeAll`           | -                                                                                     | `void`                      | Removes all current notifications                                                                         |
| `setOnRemoveCallback` | `callback?: (notification: Notification) => void`                                    | `void`                      | Sets a global callback for when notifications are dismissed                                               |

| Property        | Type             | Description                                |
| --------------- | ---------------- | ------------------------------------------ |
| `notifications` | `Notification[]` | Array of current notifications (read-only) |

### Notification Options

All options available when creating notifications with `add`:

| Option               | Type                                            | Default     | Description                                                                                 |
| --------------------- | ------------------------------------------------ | ----------- | --------------------------------------------------------------------------------------------- |
| `intent`              | `'default' \| 'info' \| 'success' \| 'warning' \| 'danger'` | `'default'` | The intent of the notification                                                     |
| `appearance`          | `'info' \| 'success' \| 'warning' \| 'error'`    | `undefined` | **Deprecated** — use `intent` instead. `'error'` maps to `'danger'`. Removed in 0.19           |
| `description`         | `string`                                         | `undefined` | Supporting text rendered below the title (string content form only)                           |
| `duration`            | `number`                                         | `5000`      | Auto-dismiss time in milliseconds                                                              |
| `preserve`            | `boolean`                                        | `false`     | Prevent auto-dismissal                                                                         |
| `allowClosing`        | `boolean`                                        | `true`      | Show close button                                                                              |
| `transitionDuration`  | `number`                                         | `200`       | Duration of the enter/exit fade, in milliseconds. Card slide/scale and the container's expand-collapse height animate at a fixed 400ms, independent of this option. |
| `hideIcon`            | `boolean`                                        | `false`     | Hide the leading intent icon                                                                   |
| `customActions`       | `CustomAction[]`                                 | `undefined` | Array of action buttons                                                                        |
| `metadata`            | `TMetadata`                                      | `undefined` | Custom data attached to the notification                                                       |

> The `title` (or `message` for backwards compatibility) comes from the `content` argument to
> `add`, either as a plain string or as `{ title, description }`.

### Promise Options

Options for `promise()`, in addition to everything above except `isLoading` (which `promise()` manages itself):

| Option    | Type                                                                | Description                                     |
| --------- | -------------------------------------------------------------------- | ------------------------------------------------ |
| `loading` | `string \| NotificationContent`                                      | Shown with a spinner while the promise is pending |
| `success` | `string \| NotificationContent \| (value) => string \| NotificationContent` | Shown when the promise resolves            |
| `error`   | `string \| NotificationContent \| (reason) => string \| NotificationContent` | Shown when the promise rejects            |

### CustomAction

Structure for notification action buttons:

| Property  | Type         | Description                            |
| --------- | ------------ | -------------------------------------- |
| `label`   | `string`     | Text displayed on the button           |
| `onClick` | `() => void` | Function called when button is clicked |

### NotificationsContainer

> The notifications service holds a single `onDismiss` slot. If more than one
> `NotificationsContainer` is rendered at the same time, the most recently rendered one
> owns the callback — another reason to render a single global container.

<Signature @component="NotificationsContainer" />
