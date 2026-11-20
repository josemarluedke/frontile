import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import { press } from '../../modifiers/press';
import type { ButtonArgs } from './button';
import { assertRemovedArg } from '../../-private/removed-args';
import type Owner from '@ember/owner';

interface ToggleButtonArgs extends Pick<
  ButtonArgs,
  'variant' | 'color' | 'size' | 'class' | 'isInGroup'
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
  constructor(owner: Owner, args: ToggleButtonSignature['Args']) {
    super(owner, args);

    assertRemovedArg('ToggleButton', args, 'appearance', 'variant');
    assertRemovedArg('ToggleButton', args, 'intent', 'color');
  }

  get classNames(): string {
    const { toggleButton } = useStyles();

    return toggleButton({
      // The theme only defines the `outline` variant for ToggleButton.
      color: this.args.color || 'neutral',
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
