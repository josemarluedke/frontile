---
title: Usage
url: /
---

# Notifications Usage

The Frontile notifications system provides a flexible way to display toast notifications to users. It supports various appearances, automatic dismissal, custom actions, and callback handling for tracking notification lifecycle events.

## Basic Usage

The simplest way to show a notification is to inject the notifications service and call the `add` method:

```javascript
@service notifications;

showSuccess() {
  this.notifications.add('Operation completed successfully!', {
    appearance: 'success'
  });
}
```

## Notification Options

You can customize notifications with various options:

- **`appearance`**: Visual style (`info`, `success`, `warning`, `error`)
- **`duration`**: Auto-dismiss time in milliseconds (default: 5000)
- **`preserve`**: Prevent auto-dismissal (default: false)
- **`allowClosing`**: Show close button (default: true)
- **`customActions`**: Add action buttons to the notification
- **`metadata`**: Attach additional data for tracking and callbacks

## Callbacks and Metadata

The notification system supports a callback mechanism that's useful for tracking user interactions, marking notifications as read on a backend, or performing cleanup actions.

### Use Cases

- **Backend Integration**: Mark notifications as read when users dismiss them
- **Analytics**: Track which notifications users interact with
- **Cleanup**: Remove related data when notifications are dismissed
- **Real-time Updates**: Sync notification state across multiple clients

### Example: Backend Integration

```javascript
// Component with backend integration
export default class MyComponent extends Component {
  @service notifications;
  @service api;

  async showNotificationWithTracking() {
    // Add notification with metadata for tracking
    const notification = this.notifications.add('New message received', {
      appearance: 'info',
      metadata: {
        notificationId: 'msg_123',
        userId: this.currentUser.id,
        action: 'message_received',
        timestamp: new Date().toISOString()
      }
    });
  }

  handleNotificationDismissed = (notification) => {
    // Called when user dismisses the notification
    if (notification.metadata?.notificationId) {
      // Mark as read on backend
      this.api.markNotificationAsRead(notification.metadata.notificationId);

      // Track analytics
      this.analytics.track('notification_dismissed', {
        notificationId: notification.metadata.notificationId,
        action: notification.metadata.action,
        dismissedAt: new Date().toISOString()
      });
    }
  };
}
```

## Type Safety with Generics

For better TypeScript support, you can use generic types with metadata:

```typescript
interface MessageMetadata {
  messageId: string;
  senderId: string;
  priority: 'low' | 'medium' | 'high';
}

// Type-safe notification creation
const notification = this.notifications.add<MessageMetadata>('New message', {
  metadata: {
    messageId: 'msg_456',
    senderId: 'user_789',
    priority: 'high'
  }
});

// notification.metadata is now strongly typed as MessageMetadata
```

## Interactive Demo

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { fn, hash } from '@ember/helper';
import { Button } from '@frontile/buttons';
import { RadioGroup, Checkbox, Input, Select } from '@frontile/forms';
import {
  NotificationsContainer,
  type NotificationOptions,
  type NotificationsService
} from '@frontile/notifications';

interface DemoArgs {}

export default class Demo extends Component<DemoArgs> {
  @service notifications!: NotificationsService;
  @tracked options: NotificationOptions = {
    appearance: 'info',
    preserve: false,
    duration: 5000,
    allowClosing: true
  };

  @tracked placement = 'bottom-right';
  @tracked dismissedNotifications: string[] = [];
  @tracked notificationCounter = 0;

  @tracked customActions: NotificationOptions['customActions'] = [
    {
      key: 'ok',
      label: 'Ok',
      onClick: (): void => {
        console.log('Ok clicked');
      }
    },
    {
      key: 'undo',
      label: 'Undo',
      onClick: (): void => {
        console.log('Undo clicked');
      }
    },
    {
      key: 'cancel',
      label: 'Cancel',
      onClick: (): void => {
        console.log('Cancel clicked');
      }
    }
  ];

  setPlacement = (placement: string): void => {
    this.placement = placement;
  };

  setValue = <T extends keyof NotificationOptions>(
    key: T,
    value: NotificationOptions[T]
  ): void => {
    const options = {
      ...this.options,
      [key]: value
    };
    this.options = options;
  };

  get selectedCustomActionKeys(): string[] {
    return this.options.customActions?.map((action) => action.key!) || [];
  }

  onCustomActionsChange = (selectedKeys: string[]): void => {
    const selectedActions = this.customActions.filter((action) =>
      selectedKeys.includes(action.key!)
    );
    this.setValue('customActions', selectedActions);
  };

  addNotification = (): void => {
    this.notificationCounter++;

    // Add notification with metadata for tracking
    this.notifications.add(
      `Notification #${this.notificationCounter}: Sed diam nonumy eirmod tempor invidunt ut labore et dolore magna.`,
      {
        ...this.options,
        metadata: {
          id: `notification_${this.notificationCounter}`,
          createdAt: new Date().toISOString(),
          source: 'demo',
          counter: this.notificationCounter
        }
      }
    );
  };

  handleNotificationDismissed = (notification: any): void => {
    // Called when a notification is dismissed
    if (notification.metadata?.id) {
      this.dismissedNotifications = [
        ...this.dismissedNotifications,
        `${notification.metadata.id} (dismissed at ${new Date().toLocaleTimeString()})`
      ];

      // In a real app, you might:
      // - Mark notification as read on backend
      // - Track analytics event
      // - Perform cleanup actions
      console.log('Notification dismissed:', notification.metadata);
    }
  };

  <template>
    <div class='flex items-baseline'>
      <RadioGroup
        @classes={{hash base='mr-6'}}
        @label='Placement'
        @value={{this.placement}}
        @onChange={{this.setPlacement}}
        as |Radio|
      >
        <Radio @value='top-left' @label='top-left' />
        <Radio @value='top-center' @label='top-center' />
        <Radio @value='top-right' @label='top-right' />
        <Radio @value='bottom-left' @label='bottom-left' />
        <Radio @value='bottom-center' @label='bottom-center' />
        <Radio @value='bottom-right' @label='bottom-right' />
      </RadioGroup>

      <RadioGroup
        @label='Appearance'
        @value={{this.options.appearance}}
        @onChange={{fn this.setValue 'appearance'}}
        as |Radio|
      >
        <Radio @value='info' @label='info' />
        <Radio @value='success' @label='success' />
        <Radio @value='warning' @label='warning' />
        <Radio @value='error' @label='error' />
      </RadioGroup>
    </div>

    <Checkbox
      @classes={{hash base='mt-6'}}
      @label='Preserve'
      @description='Preserved notifications will not automatically close'
      @checked={{this.options.preserve}}
      @onChange={{fn this.setValue 'preserve'}}
    />

    <Checkbox
      @classes={{hash base='mt-6'}}
      @label='Allow Closing'
      @description='Allow users to close the notification'
      @checked={{this.options.allowClosing}}
      @onChange={{fn this.setValue 'allowClosing'}}
    />

    <div class='flex items-baseline mt-6'>
      <Input
        @classes={{hash base='w-24 mr-6'}}
        @label='Duration'
        @description='Duration is in ms'
        @value={{this.options.duration}}
        @onInput={{fn this.setValue 'duration'}}
      />

      <Select
        @classes={{hash base='w-64'}}
        @description='Allow users to take an action on a notification'
        @label='Custom Actions'
        @items={{this.customActions}}
        @selectionMode='multiple'
        @selectedKeys={{this.selectedCustomActionKeys}}
        @onSelectionChange={{this.onCustomActionsChange}}
      />

    </div>

    <Button type='button' @onPress={{this.addNotification}} class='mt-6'>
      Add Notification
    </Button>

    {{#if this.dismissedNotifications}}
      <div class='mt-6 p-4 border border-default-300 rounded-lg'>
        <h3 class='font-semibold mb-2'>Dismissed Notifications (via callback):</h3>
        <ul class='text-sm space-y-1'>
          {{#each this.dismissedNotifications as |dismissed|}}
            <li class='text-default-600'>{{dismissed}}</li>
          {{/each}}
        </ul>
      </div>
    {{/if}}

    <NotificationsContainer
      @placement={{this.placement}}
      @onDismiss={{this.handleNotificationDismissed}}
    />
  </template>
}
```

## NotificationsService API

### Methods

- **`add<TMetadata>(message: string, options?: NotificationOptions<TMetadata>): Notification<TMetadata>`**
  - Creates and displays a new notification
  - Returns the created notification instance
  - Supports generic metadata typing for TypeScript

- **`remove(notification: Notification): void`**
  - Manually removes a specific notification

- **`removeAll(): void`**
  - Removes all active notifications

### Properties

- **`notifications: Notification[]`** (read-only)
  - Array of currently active notifications
