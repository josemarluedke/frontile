import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import {
  useStyles,
  type InputSlots,
  type InputVariants,
  type SlotsToClasses
} from '@frontile/theme';
import { FormControl, type FormControlSharedArgs } from './form-control';
import { triggerFormInputEvent } from '../utils';
import { ref } from '@frontile/utilities';
import { CloseButton } from '@frontile/buttons';

interface Args extends FormControlSharedArgs {
  type?: string;
  value?: string;
  name?: string;
  size?: InputVariants['size'];
  classes?: SlotsToClasses<InputSlots>;

  /**
   * Whether to include a clear button
   */
  isClearable?: boolean;

  /**
   * Controls pointer-events property of startContent.
   * If you want to pass the click event to the input, set it to `none`.
   *
   * @defaultValue 'auto'
   */
  startContentPointerEvents?: 'none' | 'auto';

  /**
   * Controls pointer-events property of endContent.
   * If you want to pass the click event to the input, set it to `none`.
   *
   * @defaultValue 'auto'
   */
  endContentPointerEvents?: 'none' | 'auto';

  /**
   * Callback when oninput is triggered
   */
  onInput?: (value: string, event?: InputEvent) => void;

  /**
   * Callback when onchange is triggered
   */
  onChange?: (value: string, event?: InputEvent) => void;
}

interface InputSignature {
  Args: Args;
  Blocks: {
    startContent: [];
    endContent: [];
  };
  Element: HTMLInputElement;
}

function or(arg1: unknown, arg2: unknown): boolean {
  return !!(arg1 || arg2);
}

class Input extends Component<InputSignature> {
  @tracked uncontrolledValue: string = this.args.value || '';

  inputRef = ref<HTMLInputElement>();

  get isControlled() {
    return (
      typeof this.args.onChange === 'function' ||
      typeof this.args.onInput === 'function'
    );
  }

  get value(): string | undefined {
    return this.isControlled ? this.args.value : this.uncontrolledValue;
  }

  get type(): string {
    if (typeof this.args.type === 'string') {
      return this.args.type;
    }
    return 'text';
  }

  @action handleOnInput(event: Event): void {
    const value = (event.target as HTMLInputElement).value;

    if (this.isControlled) {
      this.args.onInput?.(value, event as InputEvent);
    } else {
      this.uncontrolledValue = value;
    }
  }

  @action handleOnChange(event: Event): void {
    const value = (event.target as HTMLInputElement).value;

    if (this.isControlled) {
      this.args.onChange?.(value, event as InputEvent);
    } else {
      this.uncontrolledValue = value;
    }
  }

  @action clearValue(): void {
    if (this.isControlled) {
      this.args.onChange?.('');
      this.args.onInput?.('');
    } else {
      this.uncontrolledValue = '';
    }

    this.inputRef.current?.focus();
    triggerFormInputEvent(this.inputRef.current);
  }

  get isClearable(): boolean {
    if (
      this.args.isClearable === true &&
      this.value !== '' &&
      typeof this.value !== 'undefined'
    ) {
      return true;
    }
    return false;
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
          <div
            data-test-id="input-start-content"
            class={{this.classes.startContent
              class=@classes.startContent
              startContentPointerEvents=(if
                @startContentPointerEvents @startContentPointerEvents "auto"
              )
            }}
          >
            {{yield to="startContent"}}
          </div>
        {{/if}}
        <input
          {{this.inputRef.setup}}
          {{on "input" this.handleOnInput}}
          {{on "change" this.handleOnChange}}
          id={{c.id}}
          name={{@name}}
          value={{this.value}}
          type={{this.type}}
          disabled={{@isDisabled}}
          class={{this.classes.input
            class=@classes.input
            hasStartContent=(has-block "startContent")
            hasEndContent=(or (has-block "endContent") this.isClearable)
          }}
          data-component="input"
          aria-invalid={{if c.isInvalid "true"}}
          aria-describedby={{c.describedBy @description c.isInvalid}}
          ...attributes
        />
        {{#if (or (has-block "endContent") this.isClearable)}}
          <div
            data-test-id="input-end-content"
            class={{this.classes.endContent
              class=@classes.endContent
              endContentPointerEvents=(if
                @endContentPointerEvents @endContentPointerEvents "auto"
              )
            }}
          >
            {{yield to="endContent"}}

            {{#if this.isClearable}}
              <CloseButton
                @title="Clear"
                @variant="subtle"
                @size="xs"
                data-test-id="input-clear-button"
                @onPress={{this.clearValue}}
              />
            {{/if}}
          </div>
        {{/if}}
      </div>
    </FormControl>
  </template>
}

export { Input, type InputSignature };
export default Input;
