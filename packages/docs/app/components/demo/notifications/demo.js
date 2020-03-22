import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { inject as service } from '@ember/service';
import { action } from '@ember/object';

export default class Demo extends Component {
  @service notifications;
  @tracked options = {
    appearance: 'info',
    preserve: false,
    duration: 5000,
    allowClosing: true
  };

  @tracked placement = 'bottom-right';

  @tracked customActions = [
    {
      label: 'Ok',
      onClick: () => {
        // empty
      }
    },
    {
      label: 'Undo',
      onClick: () => {
        // empty
      }
    },
    {
      label: 'Cancel',
      onClick: () => {
        // empty
      }
    }
  ];

  @action setPlacement(placement) {
    this.placement = placement;
  }

  @action setValue(key, value) {
    const options = {
      ...this.options,
      [key]: value
    };
    this.options = options;
  }

  @action addNotification() {
    this.notifications.add(
      'Sed diam nonumy eirmod tempor invidunt ut labore et dolore magna.',
      this.options
    );
  }
}
