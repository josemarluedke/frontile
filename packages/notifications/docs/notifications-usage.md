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
} from '@frontile/notifications';
```

> **Note**: In most applications, you should place a single `NotificationsContainer` in your application template rather than including it in individual components. This prevents conflicts and provides a consistent notification experience across your app.

## Key Features

- **Multiple Appearances**: Info, success, warning, and error styles
- **Auto-dismissal**: Configurable timeout with pause on hover
- **Manual Dismissal**: Close button and custom actions
- **Flexible Positioning**: 6 placement options around the screen
- **Callback Support**: Track when notifications are dismissed
- **Metadata Support**: Attach custom data for analytics and tracking
- **TypeScript Ready**: Full type safety with generic metadata support
- **Accessible**: Proper ARIA attributes and keyboard support

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
import { Button } from '@frontile/buttons';
import type { NotificationsService } from '@frontile/notifications';

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

### Notification Appearances

Use different appearances to convey the appropriate message type.

```gts preview
import Component from '@glimmer/component';
import { service } from '@ember/service';
import { Button } from '@frontile/buttons';
import type { NotificationsService } from '@frontile/notifications';

export default class AppearanceExample extends Component {
  @service notifications!: NotificationsService;

  showInfo = () => {
    this.notifications.add('This is an info notification', {
      appearance: 'info'
    });
  };

  showSuccess = () => {
    this.notifications.add('Operation completed successfully!', {
      appearance: 'success'
    });
  };

  showWarning = () => {
    this.notifications.add('Please check your input', {
      appearance: 'warning'
    });
  };

  showError = () => {
    this.notifications.add('Something went wrong', {
      appearance: 'error'
    });
  };

  <template>
    <div class='grid grid-cols-2 gap-2'>
      <Button @onPress={{this.showInfo}}>Info</Button>
      <Button @onPress={{this.showSuccess}} @intent='success'>Success</Button>
      <Button @onPress={{this.showWarning}} @intent='warning'>Warning</Button>
      <Button @onPress={{this.showError}} @intent='danger'>Error</Button>
    </div>
  </template>
}
```

### Notification Positions

Control where notifications appear on screen with the `@placement` argument.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { Button } from '@frontile/buttons';
import { RadioGroup } from '@frontile/forms';
import {
  NotificationsContainer,
  type NotificationsService
} from '@frontile/notifications';

export default class PositionExample extends Component {
  @service notifications!: NotificationsService;
  @tracked placement = 'bottom-right';

  placements = [
    { key: 'top-left', label: 'Top Left' },
    { key: 'top-center', label: 'Top Center' },
    { key: 'top-right', label: 'Top Right' },
    { key: 'bottom-left', label: 'Bottom Left' },
    { key: 'bottom-center', label: 'Bottom Center' },
    { key: 'bottom-right', label: 'Bottom Right' }
  ];

  setPlacement = (placement: string) => {
    this.placement = placement;
  };

  showNotification = () => {
    this.notifications.add(`Positioned at ${this.placement}`, {
      appearance: 'info'
    });
  };

  <template>
    <div class='flex flex-col gap-4'>
      <RadioGroup
        @label='Position'
        @value={{this.placement}}
        @onChange={{this.setPlacement}}
        as |Radio|
      >
        {{#each this.placements as |option|}}
          <Radio @value={{option.key}} @label={{option.label}} />
        {{/each}}
      </RadioGroup>

      <Button @onPress={{this.showNotification}}>
        Show at
        {{this.placement}}
      </Button>

      <NotificationsContainer @placement={{this.placement}} />
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
import { Button } from '@frontile/buttons';
import type { NotificationsService } from '@frontile/notifications';

export default class ActionsExample extends Component {
  @service notifications!: NotificationsService;
  @tracked result = '';

  showWithActions = () => {
    this.result = '';
    this.notifications.add('File uploaded successfully!', {
      appearance: 'success',
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
      appearance: 'info',
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
        <div class='p-3 rounded border bg-success-50 text-success-700'>
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
import { Button } from '@frontile/buttons';
import type { NotificationsService } from '@frontile/notifications';

export default class PersistentExample extends Component {
  @service notifications!: NotificationsService;

  showPersistent = () => {
    this.notifications.add('This notification stays until manually closed', {
      appearance: 'warning',
      preserve: true
    });
  };

  showWithoutCloseButton = () => {
    this.notifications.add('No close button - click actions to dismiss', {
      appearance: 'info',
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
import { Button } from '@frontile/buttons';
import type { NotificationsService } from '@frontile/notifications';

export default class CallbackExample extends Component {
  @service notifications!: NotificationsService;

  showWithCallback = () => {
    this.notifications.add('Notification with tracking', {
      appearance: 'info',
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
import { Button } from '@frontile/buttons';
import { Input } from '@frontile/forms';
import type { NotificationsService } from '@frontile/notifications';

export default class TimingExample extends Component {
  @service notifications!: NotificationsService;
  @tracked duration = 3000;

  showShortDuration = () => {
    this.notifications.add('Quick notification (1 second)', {
      appearance: 'info',
      duration: 1000
    });
  };

  showLongDuration = () => {
    this.notifications.add('Long notification (10 seconds)', {
      appearance: 'warning',
      duration: 10000
    });
  };

  showCustomDuration = () => {
    this.notifications.add(`Custom duration (${this.duration}ms)`, {
      appearance: 'success',
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
    appearance: 'success',
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
      appearance: 'info',
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

All options available when creating notifications:

- **`appearance`**: Visual style (`'info'` | `'success'` | `'warning'` | `'error'`)
- **`duration`**: Auto-dismiss time in milliseconds (default: `5000`)
- **`preserve`**: Prevent auto-dismissal (default: `false`)
- **`allowClosing`**: Show close button (default: `true`)
- **`transitionDuration`**: Animation duration in milliseconds (default: `200`)
- **`customActions`**: Array of action buttons with labels and onClick handlers
- **`metadata`**: Custom data attached to the notification

### Container Configuration

Options for the NotificationsContainer component:

- **`placement`**: Position on screen (default: `'bottom-right'`)
  - `'top-left'` | `'top-center'` | `'top-right'`
  - `'bottom-left'` | `'bottom-center'` | `'bottom-right'`
- **`spacing`**: Gap between notifications in pixels (default: `16`)
- **`onDismiss`**: Callback function called when notifications are dismissed
- **`class`**: Custom CSS classes for styling

## Accessibility

The notification system includes built-in accessibility features:

- **ARIA Attributes**: Proper `role="alert"`, `aria-live="assertive"`, and `aria-atomic="true"`
- **Screen Reader Support**: Notifications are announced when they appear
- **Keyboard Navigation**: Close buttons are focusable and operable with keyboard
- **Hover Behavior**: Notifications pause auto-dismissal on mouse hover

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

- **Keep messages brief**: One or two sentences maximum
- **Use appropriate appearance**: Match the semantic meaning
- **Provide actions when useful**: Undo, View, Retry buttons
- **Consider timing**: Longer duration for actionable notifications
- **Limit simultaneous notifications**: Avoid overwhelming users

## API

### NotificationsService

The notifications service manages the global notification state and provides methods for adding and removing notifications.

| Method                | Parameters                                                    | Return Type               | Description                                                      |
| --------------------- | ------------------------------------------------------------- | ------------------------- | ---------------------------------------------------------------- |
| `add<TMetadata>`      | `message: string`, `options?: NotificationOptions<TMetadata>` | `Notification<TMetadata>` | Adds a new notification with optional metadata and configuration |
| `remove`              | `notification?: Notification`                                 | `void`                    | Removes a specific notification                                  |
| `removeAll`           | -                                                             | `void`                    | Removes all current notifications                                |
| `setOnRemoveCallback` | `callback?: (notification: Notification) => void`             | `void`                    | Sets a global callback for when notifications are dismissed      |

| Property        | Type             | Description                                |
| --------------- | ---------------- | ------------------------------------------ |
| `notifications` | `Notification[]` | Array of current notifications (read-only) |

### NotificationOptions

Configuration options when creating notifications:

| Option               | Type                                          | Default     | Description                          |
| -------------------- | --------------------------------------------- | ----------- | ------------------------------------ |
| `appearance`         | `'info' \| 'success' \| 'warning' \| 'error'` | `'info'`    | Visual style of the notification     |
| `duration`           | `number`                                      | `5000`      | Auto-dismiss time in milliseconds    |
| `preserve`           | `boolean`                                     | `false`     | Prevent auto-dismissal               |
| `allowClosing`       | `boolean`                                     | `true`      | Show close button                    |
| `transitionDuration` | `number`                                      | `200`       | Animation duration in milliseconds   |
| `customActions`      | `CustomAction[]`                              | `undefined` | Array of action buttons              |
| `metadata`           | `TMetadata`                                   | `undefined` | Custom data attached to notification |

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

<Signature @package="notifications" @component="NotificationsContainer" />
