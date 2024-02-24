import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { useStyles } from '@frontile/theme';

interface CheckboxSignature {
  Args: {
    id?: string;
    checked?: boolean;
    name?: string;
    size?: 'sm' | 'md' | 'lg';
    class?: string;

    /*
     * Callback when onchange is triggered
     */
    onChange?: (value: boolean, event: Event) => void;
  };
  Element: HTMLInputElement;
}

class Checkbox extends Component<CheckboxSignature> {
  get isChecked(): boolean {
    return !!this.args.checked;
  }

  @action handleChange(event: Event): void {
    event.preventDefault();

    const value = !this.args.checked;

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(value, event);
    }
  }

  get classes() {
    const { checkbox } = useStyles();

    return checkbox({
      size: this.args.size,
      class: this.args.class
    });
  }

  <template>
    <input
      {{on "change" this.handleChange}}
      id={{@id}}
      name={{@name}}
      checked={{this.isChecked}}
      type="checkbox"
      class={{this.classes}}
      data-component="checkbox"
      ...attributes
    />
  </template>
}

export { Checkbox, type CheckboxSignature };
export default Checkbox;
