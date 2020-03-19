import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import NotificationsService from '../services/notifications';

export interface NotificationsContainerArgs {
  /*
   * @defaultValue 'bottom-right'
   */
  placement:
    | 'top-left'
    | 'top-center'
    | 'top-right'
    | 'bottom-left'
    | 'bottom-center'
    | 'bottom-right';
}

export default class NotificationsContainer extends Component<
  NotificationsContainerArgs
> {
  @service notifications!: NotificationsService;
}
