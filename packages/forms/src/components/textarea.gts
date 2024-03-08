import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { FormControl, type FormControlSharedArgs } from './form-control';
import {
  useStyles,
  type TextareaSlots,
  type TextareaVariants,
  type SlotsToClasses
} from '@frontile/theme';

interface Args extends FormControlSharedArgs {
  id?: string;
  value?: string | number | boolean;
  name?: string;

  size?: TextareaVariants['size'];
  classes?: SlotsToClasses<TextareaSlots>;

  // Callback when oninput is triggered
  onInput?: (value: string, event: InputEvent) => void;

  // Callback when onchange is triggered
  onChange?: (value: string, event: InputEvent) => void;
}

interface TextareaSignature {
  Args: Args;
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
      size: this.args.size
    });
  }

  <template>
    <FormControl
      @size={{@size}}
      @label={{@label}}
      @isRequired={{@isRequired}}
      @description={{@description}}
      @errors={{@errors}}
      @isInvalid={{@isInvalid}}
      @class={{this.classes.base class=@classes.base}}
      as |c|
    >
      <textarea
        {{on "input" this.handleOnInput}}
        {{on "change" this.handleOnChange}}
        id={{c.id}}
        name={{@name}}
        value={{@value}}
        class={{this.classes.input class=@classes.input}}
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
