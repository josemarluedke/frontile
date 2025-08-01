import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { tracked } from '@glimmer/tracking';
import { useStyles } from '@frontile/theme';
import { press, type PressEvent } from '@frontile/utilities';

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
  appearance?: 'default' | 'outlined' | 'minimal' | 'custom';

  /**
   * The intent of the button
   */
  intent?: 'default' | 'primary' | 'success' | 'warning' | 'danger';

  /**
   * The size of the button
   */
  size?: 'xs' | 'sm' | 'lg' | 'xl';

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

  get classNames(): string {
    const { button } = useStyles();

    return button({
      intent: this.args.intent || 'default',
      size: this.args.size,
      appearance: this.args.appearance || 'default',
      isInGroup: this.args.isInGroup,
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
        data-pressed={{if this.isPressed "true"}}
        {{press this.onPress onPressChange=this.handlePressChange}}
        ...attributes
      >
        {{yield (hash classNames=this.classNames)}}
      </button>
    {{/if}}
  </template>
}

export { Button, type ButtonSignature };
export default Button;
