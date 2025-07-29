import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import {
  Form,
  Checkbox,
  Input,
  RadioGroup,
  Select,
  type FormResultData
} from '@frontile/forms';
import { Button } from '@frontile/buttons';
import {
  NotificationsContainer,
  type CustomAction,
  type NotificationOptions,
  type NotificationsContainerSignature,
  type NotificationsService
} from '@frontile/notifications';

interface DemoArgs {}

const customActionsOptions = [
  {
    key: 'ok',
    label: 'Ok',
    onClick: () => {
      // empty
    }
  },
  {
    key: 'undo',
    label: 'Undo',
    onClick: () => {
      // empty
    }
  },
  {
    key: 'cancel',
    label: 'Cancel',
    onClick: () => {
      // empty
    }
  }
];

export default class Demo extends Component<DemoArgs> {
  @service notifications!: NotificationsService;
  @tracked placement: NotificationsContainerSignature['Args']['placement'] =
    'bottom-right';
  @tracked customActions: string[] = ['ok'];

  onChangeCustomActions = (keys: string[]) => {
    this.customActions = keys;
  };

  handleForm = (data: FormResultData, eventType: 'input' | 'submit') => {
    if (data['placement']) {
      this.placement = data[
        'placement'
      ] as NotificationsContainerSignature['Args']['placement'];
    }

    if (eventType === 'submit') {
      this.notifications.add(
        'Sed diam nonumy eirmod tempor invidunt ut labore et dolore magna.',
        {
          appearance: data['appearance'] as NotificationOptions['appearance'],
          preserve: data['preserve'] == 'on',
          duration: parseInt(data['duration'] as string) || 5000,
          allowClosing: data['allowClosing'] == 'on',
          customActions: this.customActions.map(
            (key) =>
              customActionsOptions.find(
                (action) => action.key === key
              ) as CustomAction
          )
        }
      );
    }
  };

  <template>
    <Form @onChange={{this.handleForm}} class="mt-4 flex flex-col gap-y-4">
      <RadioGroup
        @orientation="horizontal"
        @label="Placement"
        @name="placement"
        @value={{this.placement}}
        as |Radio|
      >
        <Radio @value="top-left" @label="top-left" />
        <Radio @value="top-center" @label="top-center" />
        <Radio @value="top-right" @label="top-right" />
        <Radio @value="bottom-left" @label="bottom-left" />
        <Radio @value="bottom-center" @label="bottom-center" />
        <Radio @value="bottom-right" @label="bottom-right" />
      </RadioGroup>

      <RadioGroup
        @orientation="horizontal"
        @label="Appearance"
        @name="appearance"
        @value="info"
        as |Radio|
      >
        <Radio @value="info" @label="info" />
        <Radio @value="success" @label="success" />
        <Radio @value="warning" @label="warning" />
        <Radio @value="error" @label="error" />
      </RadioGroup>

      <Checkbox
        @label="Preserve"
        @description="Preserved notifications will not automatically close"
        @name="preserve"
      />

      <Checkbox
        @label="Allow Closing"
        @description="Allow users to close the notification"
        @name="allowClosing"
        @checked={{true}}
      />

      <Input
        @label="Duration"
        @description="Duration is in ms"
        @name="duration"
        @type="number"
        @value="5000"
      />

      <Select
        @description="Allow users to take an action on a notification"
        @label="Custom Actions"
        @items={{customActionsOptions}}
        @selectionMode="multiple"
        @selectedKeys={{this.customActions}}
        @onSelectionChange={{this.onChangeCustomActions}}
      />

      <div>
        <Button @type="submit" @intent="primary">
          Add Notification
        </Button>
      </div>
    </Form>

    <NotificationsContainer @placement={{this.placement}} />
  </template>
}
