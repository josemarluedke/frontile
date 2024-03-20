import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import {
  useStyles,
  type InputSlots,
  type InputVariants,
  type SlotsToClasses
} from '@frontile/theme';
import { FormControl, type FormControlSharedArgs } from './form-control';

interface Args extends FormControlSharedArgs {
  type?: string;
  value?: string;
  name?: string;
  size?: InputVariants['size'];
  classes?: SlotsToClasses<InputSlots>;

  // Callback when oninput is triggered
  onInput?: (value: string, event: InputEvent) => void;

  // Callback when onchange is triggered
  onChange?: (value: string, event: InputEvent) => void;
}

interface InputSignature {
  Args: Args;
  Blocks: {
    startContent: [];
    endContent: [];
  };
  Element: HTMLInputElement;
}

class Input extends Component<InputSignature> {
  get type(): string {
    if (typeof this.args.type === 'string') {
      return this.args.type;
    }
    return 'text';
  }

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
    const { input } = useStyles();
    return input({
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
      <div class={{this.classes.innerContainer class=@classes.innerContainer}}>
        {{#if (has-block "startContent")}}
          <div class={{this.classes.startContent class=@classes.startContent}}>
            {{yield to="startContent"}}
          </div>
        {{/if}}
        <input
          {{on "input" this.handleOnInput}}
          {{on "change" this.handleOnChange}}
          id={{c.id}}
          name={{@name}}
          value={{@value}}
          type={{this.type}}
          class={{this.classes.input
            class=@classes.input
            hasStartContent=(has-block "startContent")
            hasEndContent=(has-block "endContent")
          }}
          data-component="input"
          aria-invalid={{if c.isInvalid "true"}}
          aria-describedby={{c.describedBy @description c.isInvalid}}
          ...attributes
        />
        {{#if (has-block "endContent")}}
          <div class={{this.classes.endContent class=@classes.endContent}}>
            {{yield to="endContent"}}
          </div>
        {{/if}}
      </div>
    </FormControl>
  </template>
}

export { Input, type InputSignature };
export default Input;
