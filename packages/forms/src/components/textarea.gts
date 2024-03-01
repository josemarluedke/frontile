import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { FormControl } from './form-control';
import { useStyles } from '@frontile/theme';

interface TextareaSignature {
  Args: {
    id?: string;
    value?: string | number | boolean;
    size?: 'sm' | 'md' | 'lg';
    class?: string;
    name?: string;

    label?: string;
    isRequired?: boolean;
    description?: string;
    errors?: string[] | string;
    isInvalid?: boolean;

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

    const { input } = textarea({
      size: this.args.size
    });

    return {
      input: input({
        class: this.args.class
      })
    };
  }

  <template>
    <FormControl
      @size={{@size}}
      @label={{@label}}
      @isRequired={{@isRequired}}
      @description={{@description}}
      @errors={{@errors}}
      @isInvalid={{@isInvalid}}
      as |c|
    >
      <textarea
        {{on "input" this.handleOnInput}}
        {{on "change" this.handleOnChange}}
        id={{c.id}}
        name={{@name}}
        value={{@value}}
        class={{this.classes.input}}
        data-component="textarea"
        aria-invalid={{if c.isInvalid "true"}}
        aria-describedby={{c.describedBy @description c.isInvalid}}
        ...attributes
      />
    </FormControl>
  </template>
}
export { Textarea, type TextareaSignature };
export default Textarea;
