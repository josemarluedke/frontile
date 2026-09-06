import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { tracked } from '@glimmer/tracking';
import { modifier } from 'ember-modifier';
import { useStyles } from '@frontile/theme';
import { press, type PressEvent } from '../../modifiers/press';

/**
 * Sets `disabled` on the element while `loading` is true, restoring whatever
 * the consumer had before. This is a modifier rather than a plain attribute
 * because splattributes are applied last: `disabled={{@isLoading}}` written
 * before `...attributes` is clobbered by a consumer's own `disabled`, and
 * written after it a consumer's `disabled={{false}}` would erase ours.
 * Modifiers run after attributes, so neither ordering problem applies.
 *
 * Known limitation: this re-runs only when `loading` changes. If a consumer's
 * own `disabled` binding flips from true to false while loading is already in
 * flight, Glimmer rewrites the attribute and we do not re-run, so the button
 * goes live mid-load. Closing that would need a MutationObserver for a case
 * nobody has hit.
 */
const disableWhile = modifier((el: HTMLButtonElement, [loading]: [boolean]) => {
  if (!loading) {
    return;
  }

  const previous = el.disabled;
  el.disabled = true;

  return () => {
    el.disabled = previous;
  };
});

export interface ButtonArgs {
  /**
   * The HTML type of the button
   *
   * @defaultValue 'button'
   */
  type?: 'button' | 'submit' | 'reset';

  /**
   * The button appearance
   *
   * @defaultValue 'default'
   */
  appearance?: 'default' | 'soft' | 'outlined' | 'minimal' | 'tonal' | 'custom';

  /**
   * The intent of the button
   */
  intent?:
    | 'default'
    | 'primary'
    | 'secondary'
    | 'tertiary'
    | 'success'
    | 'warning'
    | 'danger';

  /**
   * The size of the button
   */
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl' | '2xl';

  /**
   * Disable rendering the button element. It yields an object with classNames instead.
   */
  isRenderless?: boolean;

  /**
   * Custom class name, it will override the default ones using Tailwind Merge library.
   */
  class?: string;

  /**
   * If button is part of a group. Most of the time, this is automatically set
   * when using the ButtonGroup component.
   */
  isInGroup?: boolean;

  /**
   * Renders a spinner in place of the icon and disables the button.
   *
   * @defaultValue false
   */
  isLoading?: boolean;

  /**
   * Callback for when the button is pressed.
   */
  onPress?: (event: PressEvent) => void;
}

interface ButtonSignature {
  Args: ButtonArgs;
  Blocks: {
    default: [{ classNames: string }];
  };
  Element: HTMLButtonElement;
}

class Button extends Component<ButtonSignature> {
  @tracked isPressed = false;

  get type(): string {
    if (this.args.type) {
      return this.args.type;
    }
    return 'button';
  }

  get isLoading(): boolean {
    return this.args.isLoading === true;
  }

  get classNames(): string {
    const { button } = useStyles();

    return button({
      intent: this.args.intent || 'default',
      size: this.args.size,
      appearance: this.args.appearance || 'default',
      isInGroup: this.args.isInGroup,
      isLoading: this.isLoading,
      class: this.args.class
    });
  }

  handlePressChange = (isPressed: boolean): void => {
    this.isPressed = isPressed;
  };

  onPress = (event: PressEvent) => {
    if (typeof this.args.onPress === 'function') {
      this.args.onPress(event);
    }
  };

  <template>
    {{#if @isRenderless}}
      {{yield (hash classNames=this.classNames)}}
    {{else}}
      <button
        type={{this.type}}
        class={{this.classNames}}
        aria-busy={{if this.isLoading "true"}}
        data-loading={{if this.isLoading "true"}}
        data-pressed={{if this.isPressed "true"}}
        {{press this.onPress onPressChange=this.handlePressChange}}
        ...attributes
        {{disableWhile this.isLoading}}
      >
        {{yield (hash classNames=this.classNames)}}
      </button>
    {{/if}}
  </template>
}

export { Button, type ButtonSignature };
export default Button;
