import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { useStyles } from '@frontile/theme';

interface TextareaSignature {
  Args: {
    id?: string;
    value?: string | number | boolean;
    size?: 'sm' | 'md' | 'lg';
    class?: string;
    name?: string;

    // Callback when oninput is triggered
    onInput?: (value: string, event: InputEvent) => void;

    // Callback when onchange is triggered
    onChange?: (value: string, event: InputEvent) => void;
  };
  Element: HTMLTextAreaElement;
}

class Textarea extends Component<TextareaSignature> {
  @action handleOnInput(event: Event): void {
    if (typeof this.args.onInput === 'function') {
      this.args.onInput(
        (event.target as HTMLInputElement).value,
        event as InputEvent
      );
    }
  }

  @action handleOnChange(event: Event): void {
    if (typeof this.args.onChange === 'function') {
      this.args.onChange(
        (event.target as HTMLInputElement).value,
        event as InputEvent
      );
    }
  }

  get classes() {
    const { textarea } = useStyles();

    return textarea({
      size: this.args.size,
      class: this.args.class
    });
  }

  <template>
    <textarea
      {{on "input" this.handleOnInput}}
      {{on "change" this.handleOnChange}}
      id={{@id}}
      name={{@name}}
      value={{@value}}
      class={{this.classes}}
      data-component="textarea"
      ...attributes
    >
    </textarea>
  </template>
}
export { Textarea, type TextareaSignature };
export default Textarea;
