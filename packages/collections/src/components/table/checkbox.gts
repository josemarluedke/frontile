import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { modifier } from 'ember-modifier';
import {
  useStyles,
  type CheckboxVariants,
  type CheckboxSlots,
  type SlotsToClasses
} from '@frontile/theme';

interface CheckboxSignature {
  Args: {
    checked?: boolean;
    indeterminate?: boolean;
    disabled?: boolean;
    onChange?: (checked: boolean, event: Event) => void;
    size?: CheckboxVariants['size'];
    classes?: SlotsToClasses<CheckboxSlots>;
    ariaLabel?: string;
    ariaLabelledby?: string;
  };
  Element: HTMLInputElement;
}

/**
 * Internal checkbox component for table selection.
 * Simplified version without FormControl wrapper.
 */
class Checkbox extends Component<CheckboxSignature> {
  get isChecked(): boolean {
    return !!this.args.checked;
  }

  @action handleChange(event: Event): void {
    if (this.args.disabled) {
      return;
    }

    const target = event.target as HTMLInputElement;
    const value = target.checked;

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(value, event);
    }
  }

  get classes() {
    const { checkbox } = useStyles();
    return checkbox({
      size: this.args.size
    });
  }

  setIndeterminate = modifier(
    (element: HTMLInputElement, [indeterminate]: [boolean | undefined]) => {
      element.indeterminate = !!indeterminate;
    }
  );

  <template>
    <input
      {{on "change" this.handleChange}}
      {{this.setIndeterminate @indeterminate}}
      type="checkbox"
      checked={{this.isChecked}}
      disabled={{@disabled}}
      class={{this.classes.input class=@classes.input}}
      aria-label={{@ariaLabel}}
      aria-labelledby={{@ariaLabelledby}}
      role="checkbox"
      aria-checked={{if
        @indeterminate
        "mixed"
        (if this.isChecked "true" "false")
      }}
      ...attributes
    />
  </template>
}

export { Checkbox, type CheckboxSignature };
export default Checkbox;
