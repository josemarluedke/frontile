export interface CustomAction {
  label: string;
  onClick: () => void;
}

export interface NotificationOptions {
  /* If set to false, the close button will not be displayed.
   *
   * @defaultValue true
   */
  allowClosing?: boolean;

  /*
   * @defaultValue false
   */
  preserve?: boolean;

  /*
   * @defaultValue 5000
   */
  duration?: number;

  /*
   * The duration for the transition on removal
   * @defaultValue 200
   */
  transitionDuration?: number;

  /*
   * @defaultValue 'info'
   */
  appearance?: 'info' | 'success' | 'warning' | 'error';

  /*
   * @defaultValue undefined
   */
  customActions?: CustomAction[];
}

export interface DefaultConfig extends NotificationOptions {
  /*
   * If set to true, we will preserve the notification, therefore skiping the timer.
   * This is useful in tests because Ember will wait for any runloop to
   * finish before proceeding.
   *
   * @defaultValue false
   */
  skipTimer?: boolean;
}
