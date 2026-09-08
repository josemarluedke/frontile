import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import type { AlertSlots, SlotsToClasses } from '@frontile/theme';
import {
  IconInfo,
  IconSuccess,
  IconWarning,
  IconDanger
} from '../../-private/intent-icons';
import { CloseButton } from '../buttons/close-button';

type AlertIntent = 'default' | 'info' | 'success' | 'warning' | 'danger';

/**
 * Everything that varies by intent, keyed in one place — the same shape
 * NotificationCard's own table uses — so adding an intent means adding one
 * row rather than remembering to touch an icon map and a role cascade
 * separately.
 */
const INTENT_CONFIG = {
  default: {
    icon: IconInfo,
    // `alert` interrupts a screen reader, so it is reserved for the
    // intents that warrant interrupting.
    role: 'status'
  },
  info: {
    icon: IconInfo,
    role: 'status'
  },
  success: {
    icon: IconSuccess,
    role: 'status'
  },
  warning: {
    icon: IconWarning,
    role: 'alert'
  },
  danger: {
    icon: IconDanger,
    role: 'alert'
  }
} as const satisfies Record<
  AlertIntent,
  {
    icon: unknown;
    role: 'status' | 'alert';
  }
>;

/**
 * `true` when either half of a content pair is present. Used for
 * `(or @description (has-block "description"))` in the template, since
 * `has-block` is a template-only keyword and cannot be read from JS.
 */
function or(arg1: unknown, arg2: unknown): boolean {
  return !!(arg1 || arg2);
}

interface AlertSignature {
  Args: {
    /**
     * The alert's heading. Ignored when a `title` block is passed.
     */
    title?: string;

    /**
     * The supporting copy under the title. Ignored when a `description`
     * block is passed — use the block for anything that needs markup, such
     * as a list or a link.
     */
    description?: string;

    /**
     * The intent of the alert, which drives its colour, its default icon,
     * and its default ARIA role.
     *
     * @defaultValue 'default'
     */
    intent?: AlertIntent;

    /**
     * The visual style of the alert.
     *
     * @defaultValue 'default'
     */
    variant?: 'default' | 'tonal' | 'solid';

    /**
     * Removes the icon. Wins over the `icon` block if both are supplied.
     *
     * @defaultValue false
     */
    hideIcon?: boolean;

    /**
     * Called when the close button is pressed. Passing this argument is what
     * reveals the close button.
     *
     * Alert does not hide itself — the consumer removes it from the DOM, so
     * showing it again, animating it out, or persisting the dismissal are all
     * the application's to decide.
     */
    onClose?: () => void;

    /**
     * The accessible name of the close button. Worth setting when several
     * alerts sit together, since every close button would otherwise be
     * announced as just "Close" without saying what is being dismissed.
     *
     * @defaultValue 'Close'
     */
    closeButtonTitle?: string;

    /**
     * Custom class name, it will override the default ones using Tailwind
     * Merge library.
     */
    class?: string;

    /**
     * Custom CSS classes for styling the individual slots.
     */
    classes?: SlotsToClasses<AlertSlots>;
  };
  Blocks: {
    /** Replaces the default intent glyph. Ignored when `@hideIcon` is set. */
    icon: [];

    /** Overrides `@title`. */
    title: [];

    /** Overrides `@description`. Takes markup. */
    description: [];

    /**
     * Buttons, rendered in a row between the content and the close button.
     */
    actions: [];
  };
  Element: HTMLDivElement;
}

/**
 * Displays an important message inline in the page.
 *
 * The static counterpart to `NotificationCard`: same intents and visual
 * recipes, but rendered as part of the page rather than pushed through the
 * notifications service.
 */
class Alert extends Component<AlertSignature> {
  get intent(): AlertIntent {
    return this.args.intent ?? 'default';
  }

  get icon() {
    return INTENT_CONFIG[this.intent].icon;
  }

  /**
   * A method rather than a getter because `hasDescription` can only be
   * determined in the template — `has-block` is a template keyword with no
   * JS equivalent — and it drives the icon's optical alignment.
   */
  classNames = (hasDescription: boolean) => {
    const { alert } = useStyles();
    const { classes } = this.args;

    const {
      base,
      inner,
      icon,
      content,
      title,
      description,
      actions,
      closeButton
    } = alert({
      intent: this.intent,
      variant: this.args.variant ?? 'default',
      hasDescription
    });

    return {
      base: base({ class: [classes?.base, this.args.class] }),
      inner: inner({ class: classes?.inner }),
      icon: icon({ class: classes?.icon }),
      content: content({ class: classes?.content }),
      title: title({ class: classes?.title }),
      description: description({ class: classes?.description }),
      actions: actions({ class: classes?.actions }),
      closeButton: closeButton({ class: classes?.closeButton })
    };
  };

  <template>
    {{#let (or @description (has-block "description")) as |hasDescription|}}
      {{#let (this.classNames hasDescription) as |classNames|}}
        <div
          class={{classNames.base}}
          data-test-id="alert"
          data-component="alert"
          data-test-intent={{this.intent}}
          ...attributes
        >
          <div class={{classNames.inner}}>
            {{#unless @hideIcon}}
              {{#if (has-block "icon")}}
                <span class={{classNames.icon}} data-test-id="alert-icon">
                  {{yield to="icon"}}
                </span>
              {{else}}
                {{#let this.icon as |Icon|}}
                  <Icon class={{classNames.icon}} data-test-id="alert-icon" />
                {{/let}}
              {{/if}}
            {{/unless}}

            <div class={{classNames.content}} data-test-id="alert-content">
              {{#if (has-block "title")}}
                <div class={{classNames.title}} data-test-id="alert-title">
                  {{yield to="title"}}
                </div>
              {{else if @title}}
                <div class={{classNames.title}} data-test-id="alert-title">
                  {{@title}}
                </div>
              {{/if}}

              {{#if (has-block "description")}}
                <div
                  class={{classNames.description}}
                  data-test-id="alert-description"
                >
                  {{yield to="description"}}
                </div>
              {{else if @description}}
                <div
                  class={{classNames.description}}
                  data-test-id="alert-description"
                >
                  {{@description}}
                </div>
              {{/if}}
            </div>

            {{#if (has-block "actions")}}
              <div class={{classNames.actions}} data-test-id="alert-actions">
                {{yield to="actions"}}
              </div>
            {{/if}}

            {{#if @onClose}}
              <CloseButton
                @onPress={{@onClose}}
                @size="sm"
                @title={{@closeButtonTitle}}
                @class={{classNames.closeButton}}
                data-test-id="alert-close-button"
              />
            {{/if}}
          </div>
        </div>
      {{/let}}
    {{/let}}
  </template>
}

export { Alert, type AlertSignature };
export default Alert;
