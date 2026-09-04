export type containerPlacement =
  | 'top-left'
  | 'top-center'
  | 'top-right'
  | 'bottom-left'
  | 'bottom-center'
  | 'bottom-right';

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

export type NotificationIntent = 'info' | 'success' | 'warning' | 'danger';

/**
 * The deprecated intent names. `error` maps onto `danger`.
 */
export type NotificationAppearance = 'info' | 'success' | 'warning' | 'error';

export interface NotificationContent {
  /**
   * The heading line of the notification.
   */
  title: string;

  /**
   * Optional supporting line rendered below the title.
   */
  description?: string;
}

export interface NotificationUpdate {
  title?: string;
  description?: string;
  intent?: NotificationIntent;
  allowClosing?: boolean;
  isLoading?: boolean;
}

export interface NotificationOptions<
  TMetadata extends Record<string, unknown> = Record<string, unknown>
> {
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
   * Supporting text rendered below the title.
   *
   * @defaultValue undefined
   */
  description?: string;

  /**
   * The intent of the notification.
   *
   * @defaultValue 'info'
   */
  intent?: NotificationIntent;

  /**
   * The appearance of the notification.
   *
   * @deprecated Use `intent` instead. `error` maps onto `danger`.
   * @defaultValue undefined
   */
  appearance?: NotificationAppearance;

  /**
   * Hide the leading icon.
   *
   * @defaultValue false
   */
  hideIcon?: boolean;

  /**
   * Render a spinner in place of the intent icon. Set by `promise()`.
   *
   * @defaultValue false
   */
  isLoading?: boolean;

  /**
   * A list of custom actions
   *
   * @defaultValue undefined
   */
  customActions?: CustomAction[];

  /**
   * Additional metadata to attach to the notification
   *
   * @defaultValue undefined
   */
  metadata?: TMetadata;
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
