---
url: /notifications/
label: Updated
imports:
  - import Signature from 'site/components/signature';
---

# Toast Notification

Toast notifications provide brief, non-intrusive feedback about an operation through a small popup. They automatically disappear after a short time and don't require user interaction.

## Import

```js
import {
  NotificationsContainer,
  type NotificationsService
} from 'frontile';
```

> **Important**: `NotificationsContainer` renders `notifications.notifications` from the
> **shared, application-wide** notifications service — it does not own any notification data
> itself. If more than one `NotificationsContainer` is mounted at the same time, **every**
> container renders **every** notification, so each toast appears once per mounted container,
> all stacked in the same corner (or in whichever corners the containers use). Mount a single
> `NotificationsContainer` in your application template rather than including it in individual
> components — this prevents duplicate stacks and gives your app one consistent notification
> experience.

## Key Features

- **Title & Description**: Structured content with a title and an optional supporting description
- **Intent Icons**: Default, info, success, warning, and danger icons rendered automatically per intent
- **Three Variants**: `default`, `tonal`, and `solid` surface styles
- **Collapsible Stack**: Toasts collapse into a peeking stack and expand on hover or focus
- **Promise-Driven Notifications**: Show a loading state that resolves into success or error
- **Auto-Dismissal**: Configurable timeout that pauses while the stack is hovered
- **Custom Actions**: Close button and custom action buttons
- **Six Placements**: Position the stack around the screen
- **Dismissal Callbacks**: Track when notifications are removed
- **Metadata Support**: Attach custom data for analytics and tracking
- **TypeScript Ready**: Full type safety with generic metadata support
- **Accessible**: ARIA roles and a live region tuned to each notification's intent

## Usage

### Global Setup

For best results, place a single `NotificationsContainer` in your application template:

```hbs
{{! app/templates/application.hbs }}
<div id='app-content'>
  {{outlet}}
</div>

{{! Global notifications container }}
<NotificationsContainer @placement='bottom-right' />
```

This approach ensures:

- No conflicting notification containers
- Consistent placement across your application
- Centralized callback handling for analytics/logging
- Better performance with a single container

### Basic Notification

The simplest way to show a notification is to inject the notifications service and call the `add` method.

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

### Notification Intents

Use `intent` to convey the appropriate message type: `'default'`, `'info'`, `'success'`,
`'warning'`, or `'danger'`. Each intent renders a matching icon automatically; pass
`hideIcon: true` to suppress it.

`'default'` is the default intent — a bare `notifications.add('message')` with no `intent`
option produces a `default` toast. It still renders the same info glyph as the `info` intent,
just in a neutral color rather than the primary accent, so callers who want the old
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

### Title and Description

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

### Container Configuration

`NotificationsContainer` takes several arguments that change how the whole stack renders:
`@variant` controls the surface style applied to every card (`default` is a neutral opaque
card where the intent color is carried by the icon and title, `tonal` is a tinted opaque
surface, and `solid` is a filled surface with contrast text), `@placement` controls where the
stack sits on screen, and `@visibleToasts` (default `3`) sets how many cards stay visible
while collapsed — `@spacing` (default `16`) is the peek offset between collapsed cards and the
gap between expanded ones, in pixels, and `@expand` forces the stack to stay expanded instead
of collapsing when it isn't hovered.

Because only one container should ever be mounted at a time (see the callout above), this
single demo drives one `NotificationsContainer` from all three controls, rather than mounting
a separate container per argument.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import {
  Button,
  RadioGroup,
  NotificationsContainer,
  type NotificationsService,
  type NotificationIntent
} from 'frontile';

export default class ContainerConfigExample extends Component {
  @service notifications!: NotificationsService;

  @tracked variant: 'default' | 'tonal' | 'solid' = 'default';
  @tracked placement = 'bottom-right';
  @tracked visibleToastsKey = '3';

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

      <div class='flex flex-wrap gap-2'>
        <Button @onPress={{this.showAllIntents}}>Show All Intents</Button>
        <Button @onPress={{this.showFive}}>Show 5 Notifications</Button>
        <Button @onPress={{this.clear}} @appearance='outlined'>Clear</Button>
      </div>

      <p class='text-body-2xs text-neutral-muted'>
        Hover or focus the stack to expand it. Collapsed, it shows
        {{this.visibleToasts}}
        card(s) peeking; the rest stay tucked behind them.
      </p>

      <NotificationsContainer
        @placement={{this.placement}}
        @variant={{this.variant}}
        @visibleToasts={{this.visibleToasts}}
      />
    </div>
  </template>
}
```

### Custom Actions

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

### Persistent Notifications

Use `preserve: true` to prevent automatic dismissal.

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

### Notification Callbacks

Track notification dismissals for analytics, backend updates, or cleanup. When using a global container, set up callbacks in your application template:

`@onDismiss` is called **exactly once per notification**, after it has actually been removed — repeated dismissals of the same notification (e.g. a double-click on the close button) do not call it again. The callback is always read from the current `@onDismiss` argument, so changing it at runtime takes effect immediately.

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
      // Send analytics event
      this.analytics.track('notification_dismissed', notification.metadata);

      // Mark as read on backend
      if (notification.metadata.notificationId) {
        this.api.markNotificationAsRead(notification.metadata.notificationId);
      }
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

### Custom Duration

Control timing for individual notifications.

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

### Promise-Driven Notifications

`promise()` shows a loading toast with a spinner, then mutates that same toast into a success or error state once the promise settles — no second toast is created. While pending, the toast cannot be dismissed. `loading` takes a string or a `{ title, description }` object; `success` and `error` each take a string, a `{ title, description }` object, or a function of the resolved value (for `success`) or rejection reason (for `error`) returning either.

`promise()` returns the **original promise** unchanged, so the caller still owns rejection handling — the toast alone does not swallow a rejection.

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

## Advanced Usage

### Type-Safe Metadata

Use TypeScript generics for strongly-typed metadata.

```typescript
interface UserActionMetadata {
  userId: string;
  action: 'upload' | 'delete' | 'share';
  resourceId: string;
  timestamp: string;
}

// Type-safe notification with metadata
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

### Backend Integration Example

```typescript
export default class NotificationService extends Component {
  @service notifications;
  @service api;

  async showNotificationWithBackendSync() {
    const notification = this.notifications.add('New message received', {
      intent: 'info',
      metadata: {
        notificationId: 'msg_123',
        userId: this.currentUser.id,
        source: 'message_system'
      }
    });
  }

  handleNotificationDismissed = async (notification) => {
    if (notification.metadata?.notificationId) {
      // Mark as read on backend
      await this.api.markNotificationAsRead(
        notification.metadata.notificationId
      );

      // Track analytics
      this.analytics.track('notification_dismissed', {
        notificationId: notification.metadata.notificationId,
        userId: notification.metadata.userId,
        dismissedAt: new Date().toISOString()
      });
    }
  };
}
```

## Configuration Options

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
| `transitionDuration`  | `number`                                         | `200`       | Animation duration in milliseconds                                                             |
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

### Container Configuration

Options for the NotificationsContainer component:

- **`placement`**: Position on screen (default: `'bottom-right'`)
  - `'top-left'` | `'top-center'` | `'top-right'`
  - `'bottom-left'` | `'bottom-center'` | `'bottom-right'`
- **`variant`**: Visual style applied to every card (default: `'default'`) — `'default'` | `'tonal'` | `'solid'`
- **`visibleToasts`**: How many cards stay visible while collapsed (default: `3`)
- **`expand`**: Keep the stack always expanded instead of collapsing (default: `false`)
- **`spacing`**: Peek offset between collapsed cards, and gap between expanded cards, in pixels (default: `16`)
- **`onDismiss`**: Callback function called once per notification, after it is removed
- **`class`**: Custom CSS classes for styling

> **Note**: The notifications service holds a single `onDismiss` slot. If more than one
> `NotificationsContainer` is rendered at the same time, the most recently rendered one
> owns the callback — another reason to render a single global container.

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

## Accessibility

The notification system includes built-in accessibility features:

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

## Best Practices

### When to Use Notifications

- **Success confirmations**: "File uploaded successfully"
- **Error messages**: "Failed to save changes"
- **Status updates**: "Connecting to server..."
- **Undo actions**: "Item deleted" with undo button

### When NOT to Use Notifications

- **Critical errors**: Use modals or inline validation instead
- **Complex forms**: Use inline feedback for form validation
- **Permanent status**: Use status indicators in the UI
- **Long content**: Use modals or dedicated pages

### Design Guidelines

- **Keep messages brief**: A short title, with a description only when it adds information
- **Use appropriate intent**: Match the semantic meaning
- **Provide actions when useful**: Undo, View, Retry buttons
- **Consider timing**: Longer duration for actionable notifications
- **Limit simultaneous notifications**: The stack collapses automatically, but avoid firing
  many notifications for one user action

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

### CustomAction

Structure for notification action buttons:

| Property  | Type         | Description                            |
| --------- | ------------ | -------------------------------------- |
| `label`   | `string`     | Text displayed on the button           |
| `onClick` | `() => void` | Function called when button is clicked |

### Container Placement Options

Available positions for the notifications container:

- `'top-left'` - Top left corner
- `'top-center'` - Top center
- `'top-right'` - Top right corner
- `'bottom-left'` - Bottom left corner
- `'bottom-center'` - Bottom center
- `'bottom-right'` - Bottom right corner (default)

<Signature @component="NotificationsContainer" />
