export interface CustomAction {
  /**
   * The label of the action
   */
  label: string;

  /**
   * The function to be called when clicked
   */
  onClick: () => void;
}

export interface NotificationOptions {
  /**
   * If set to false, the close button will not be displayed.
   *
   * @defaultValue true
   */
  allowClosing?: boolean;

  /**
   * Preserve the notification open, no auto-dismiss.
   *
   * @defaultValue false
   */
  preserve?: boolean;

  /**
   * Duration before the notification is auto-dismissed, in milliseconds.
   *
   * @defaultValue 5000
   */
  duration?: number;

  /*
   * The duration for the transition on removal, in milliseconds.
   *
   * @defaultValue 200
   */
  transitionDuration?: number;

  /**
   * The appearance of the notification
   *
   * @defaultValue 'info'
   */
  appearance?: 'info' | 'success' | 'warning' | 'error';

  /**
   * A list of custom actions
   *
   * @defaultValue undefined
   */
  customActions?: CustomAction[];
}

export interface DefaultConfig extends NotificationOptions {
  /**
   * If set to true, we will preserve the notification, therefore skiping the timer.
   * This is useful in tests because Ember will wait for any runloop to
   * finish before proceeding.
   *
   * @defaultValue false
   */
  skipTimer?: boolean;
}
