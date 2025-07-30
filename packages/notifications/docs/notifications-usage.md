---
title: Usage
url: /
---

# Notifications Usage

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
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

  @tracked customActions: NotificationOptions['customActions'] = [
    {
      key: 'ok',
      label: 'Ok',
      onClick: (): void => {
        // empty
      }
    },
    {
      key: 'undo',
      label: 'Undo',
      onClick: (): void => {
        // empty
      }
    },
    {
      key: 'cancel',
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

  get selectedCustomActionKeys(): string[] {
    return this.options.customActions?.map((action) => action.key!) || [];
  }

  @action onCustomActionsChange(selectedKeys: string[]): void {
    const selectedActions = this.customActions.filter((action) =>
      selectedKeys.includes(action.key!)
    );
    this.setValue('customActions', selectedActions);
  }

  @action addNotification(): void {
    this.notifications.add(
      'Sed diam nonumy eirmod tempor invidunt ut labore et dolore magna.',
      this.options
    );
  }

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

    <Button type='button' {{on 'click' this.addNotification}} class='mt-6'>
      Add Notification
    </Button>

    <NotificationsContainer @placement={{this.placement}} />
  </template>
}
```
