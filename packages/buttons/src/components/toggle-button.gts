import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { useStyles } from '@frontile/theme';
import type { ButtonArgs } from './button';

interface ToggleButtonArgs
  extends Pick<ButtonArgs, 'intent' | 'size' | 'class' | 'isInGroup'> {
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
  get classNames(): string {
    const { toggleButton } = useStyles();

    return toggleButton({
      intent: this.args.intent || 'default',
      size: this.args.size,
      appearance: 'outlined',
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
      {{on "click" this.onChange}}
      class={{this.classNames}}
      aria-pressed="{{this.isSelected}}"
      ...attributes
    >
      {{yield}}
    </button>
  </template>
}

export { ToggleButton, type ToggleButtonSignature };
export default ToggleButton;
