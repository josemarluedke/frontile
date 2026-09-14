import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import { press } from '../../modifiers/press';
import type { ButtonArgs } from './button';
import { renamedArgValue } from '../../-private/deprecated-args';

interface ToggleButtonArgs extends Pick<
  ButtonArgs,
  'variant' | 'appearance' | 'intent' | 'size' | 'class' | 'isInGroup'
> {
  /**
   * If the button is currently selected
   *
   * @defaultValue false
   */
  isSelected?: boolean;

  /**
   * Callback when the buttle is toggled
   */
  onChange?: (isSelected: boolean) => void;
}

interface ToggleButtonSignature {
  Args: ToggleButtonArgs;
  Blocks: {
    default: [];
  };
  Element: HTMLButtonElement;
}

class ToggleButton extends Component<ToggleButtonSignature> {
  /**
   * ToggleButton's theme only ever renders the `outline` variant — reading
   * this getter resolves (and, when needed, deprecates) `@appearance` /
   * `@variant` so a consumer still migrating gets the warning, even though
   * the resolved value itself has nowhere else to go.
   */
  get variant() {
    return renamedArgValue(
      this.args.variant,
      this.args.appearance,
      {
        default: 'solid',
        outlined: 'outline',
        minimal: 'plain',
        soft: 'subtle',
        tonal: 'soft'
      } as const,
      {
        component: 'ToggleButton',
        from: 'appearance',
        to: 'variant',
        id: 'frontile.toggle-button.appearance'
      }
    );
  }

  get classNames(): string {
    const { toggleButton } = useStyles();
    // Resolve (and deprecate) `@appearance`/`@variant` for their side effect;
    // the theme itself only defines the `outline` variant for ToggleButton.
    void this.variant;

    return toggleButton({
      intent: this.args.intent || 'default',
      size: this.args.size,
      variant: 'outline',
      isSelected: this.isSelected,
      isInGroup: this.args.isInGroup,
      class: this.args.class
    });
  }

  get isSelected() {
    return !!this.args.isSelected;
  }

  onChange = () => {
    if (typeof this.args.onChange === 'function') {
      this.args.onChange(!this.isSelected);
    }
  };

  <template>
    <button
      type="button"
      {{press this.onChange}}
      class={{this.classNames}}
      aria-pressed="{{this.isSelected}}"
      data-component="toggle-button"
      data-part="base"
      ...attributes
    >
      {{yield}}
    </button>
  </template>
}

export { ToggleButton, type ToggleButtonSignature };
export default ToggleButton;
