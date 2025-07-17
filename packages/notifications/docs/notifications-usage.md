---
title: Usage
url: /
---

# Notifications Usage

# Demo

```hbs template
<div class="flex items-baseline">
  <FormRadioGroup
    @containerClass="mr-6"
    @label="Placement"
    @value={{this.placement}}
    @onChange={{this.setPlacement}}
    as |Radio|
  >
    <Radio @value="top-left" @label="top-left" />
    <Radio @value="top-center" @label="top-center" />
    <Radio @value="top-right" @label="top-right" />
    <Radio @value="bottom-left" @label="bottom-left" />
    <Radio @value="bottom-center" @label="bottom-center" />
    <Radio @value="bottom-right" @label="bottom-right" />
  </FormRadioGroup>

  <FormRadioGroup
    @label="Appearance"
    @value={{this.options.appearance}}
    @onChange={{fn this.setValue "appearance"}}
    as |Radio|
  >
    <Radio @value="info" @label="info" />
    <Radio @value="success" @label="success" />
    <Radio @value="warning" @label="warning" />
    <Radio @value="error" @label="error" />
  </FormRadioGroup>
</div>

<FormCheckbox
  @containerClass="mt-6"
  @label="Preserve"
  @hint="Preserved notifications will not automatically close"
  @checked={{this.options.preserve}}
  @onChange={{fn this.setValue "preserve"}}
/>

<FormCheckbox
  @containerClass="mt-6"
  @label="Allow Closing"
  @hint="Allow users to close the notification"
  @checked={{this.options.allowClosing}}
  @onChange={{fn this.setValue "allowClosing"}}
/>

<div class="flex items-baseline mt-6 ">
  <FormInput
    @containerClass="w-24 mr-6"
    @label="Duration"
    @hint="Duration is in ms"
    @value={{this.options.duration}}
    @onInput={{fn this.setValue "duration"}}
  />

  <FormSelect
    @containerClass="w-64"
    @hint="Allow users to take an action on a notification"
    @label="Custom Actions"
    @options={{this.customActions}}
    @isMultiple={{true}}
    @selected={{this.options.customActions}}
    @onChange={{fn this.setValue "customActions"}}
    as |action|
  >
    {{action.label}}
  </FormSelect>
</div>

<button
  type="button"
  {{on "click" this.addNotification}}
  class="px-4 py-2 mt-6 text-white bg-teal-700 rounded hover:bg-teal-800"
>
  Add Notification
</button>

<NotificationsContainer @placement={{this.placement}} />
```

```ts component
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { inject as service } from '@ember/service';
import { action } from '@ember/object';
import type {
  NotificationOptions,
  NotificationsService
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

  @tracked customActions: NotificationOptions['customActions'] = [
    {
      label: 'Ok',
      onClick: (): void => {
        // empty
      }
    },
    {
      label: 'Undo',
      onClick: (): void => {
        // empty
      }
    },
    {
      label: 'Cancel',
      onClick: (): void => {
        // empty
      }
    }
  ];

  @action setPlacement(placement: string): void {
    this.placement = placement;
  }

  @action setValue<T extends keyof NotificationOptions>(
    key: T,
    value: NotificationOptions[T]
  ): void {
    const options = {
      ...this.options,
      [key]: value
    };
    this.options = options;
  }

  @action addNotification(): void {
    this.notifications.add(
      'Sed diam nonumy eirmod tempor invidunt ut labore et dolore magna.',
      this.options
    );
  }
}
```
