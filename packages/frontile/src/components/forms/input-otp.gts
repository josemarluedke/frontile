import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import {
  useStyles,
  type InputOtpSlots,
  type InputOtpVariants,
  type SlotsToClasses
} from '@frontile/theme';
import { FormControl, type FormControlSharedArgs } from './form-control';
import { ref } from '../../utils/ref';

/**
 * These must match PARTIAL values. A pattern anchored to the full length --
 * `/^\d{6}$/` -- rejects the very first keystroke and makes the field
 * impossible to type into.
 */
const OTP_PATTERNS = {
  digits: /^\d+$/,
  letters: /^[a-zA-Z]+$/,
  alphanumeric: /^[a-zA-Z0-9]+$/
} as const;

type AllowedChars = keyof typeof OTP_PATTERNS;

interface Cell {
  index: number;
  char: string | null;
  placeholderChar: string | null;
  isActive: boolean;
  hasFakeCaret: boolean;
}

interface Args extends FormControlSharedArgs {
  /**
   * How many characters the code has. Also the input's `maxlength`.
   *
   * @defaultValue 6
   */
  length?: number;

  /**
   * The name attribute of the underlying input, used when the code is
   * submitted as part of a form.
   */
  name?: string;

  /**
   * Which characters the code may contain. Also decides the on-screen keyboard
   * (`inputmode`) and autocapitalisation.
   *
   * @defaultValue 'digits'
   */
  allowedChars?: AllowedChars;

  /**
   * A custom character rule, overriding `allowedChars`. It is tested against
   * every intermediate value, so it must accept partial input: `/^\d+$/`, not
   * `/^\d{6}$/`.
   */
  pattern?: RegExp;

  /**
   * The size of the cells and the label.
   *
   * @defaultValue 'md'
   */
  size?: InputOtpVariants['size'];

  /**
   * Class names for each slot of the component, merged with the theme's.
   */
  classes?: SlotsToClasses<InputOtpSlots>;

  /**
   * The value of the input. Pair with `onInput` or `onChange` to control the
   * input; leave it unset to let the component track its own value.
   */
  value?: string;

  /**
   * Callback when oninput is triggered.
   */
  onInput?: (value: string, event?: Event) => void;

  /**
   * Callback when onchange is triggered.
   */
  onChange?: (value: string, event?: Event) => void;

  /**
   * Callback when onblur is triggered.
   */
  onBlur?: () => void;

  /**
   * Called when the code becomes complete. Fires on the transition from a
   * shorter value to exactly `length` characters, so re-rendering an already
   * full value does not fire it again.
   */
  onComplete?: (value: string) => void;
}

interface InputOtpSignature {
  Args: Args;
  Element: HTMLInputElement;
}

class InputOtp extends Component<InputOtpSignature> {
  @tracked uncontrolledValue: string = this.args.value || '';

  /**
   * What the element itself currently holds. A controlled parent does not
   * always feed the value back through `@value` -- `<Form>`, for one, reads it
   * off the DOM instead -- and the cells are decoration rendered from a string,
   * so without this they would sit empty while the user types.
   */
  @tracked elementValue: string = this.args.value || '';

  /**
   * The last value we saw on the element. `@onComplete` fires on a transition,
   * not on a state, so the previous length is the thing that decides it.
   */
  previousValue: string = this.args.value || '';

  inputRef = ref<HTMLInputElement>();

  get length(): number {
    return this.args.length ?? 6;
  }

  get allowedChars(): AllowedChars {
    return this.args.allowedChars ?? 'digits';
  }

  get pattern(): RegExp {
    return this.args.pattern ?? OTP_PATTERNS[this.allowedChars];
  }

  /**
   * `tel` is deliberately not offered: its keypad carries `*`, `#` and pause
   * characters that every one of our patterns rejects.
   */
  get inputMode(): 'numeric' | 'text' {
    return this.allowedChars === 'digits' ? 'numeric' : 'text';
  }

  get autoCapitalize(): 'off' | 'characters' {
    return this.allowedChars === 'digits' ? 'off' : 'characters';
  }

  get isControlled(): boolean {
    return (
      typeof this.args.onChange === 'function' ||
      typeof this.args.onInput === 'function'
    );
  }

  get currentValue(): string {
    if (!this.isControlled) {
      return this.uncontrolledValue;
    }

    return typeof this.args.value === 'undefined'
      ? this.elementValue
      : this.args.value;
  }

  /**
   * The cells are decoration rendered from a string, so they are grouped here
   * rather than in the template. Grouping arrives in a later task; for now
   * every cell lives in a single group.
   */
  get cellGroups(): Cell[][] {
    const value = this.currentValue;
    const cells: Cell[] = [];

    for (let index = 0; index < this.length; index++) {
      cells.push({
        index,
        char: value[index] ?? null,
        placeholderChar: null,
        isActive: false,
        hasFakeCaret: false
      });
    }

    return [cells];
  }

  get classes() {
    const { inputOtp } = useStyles();
    return inputOtp({ size: this.args.size });
  }

  /**
   * Both `input` and `change` funnel through here so the element, our mirror of
   * it, and the parent never disagree about the value.
   */
  syncValue(event: Event, notify: 'input' | 'change'): void {
    const element = event.target as HTMLInputElement;
    const next = element.value.slice(0, this.length);

    // All-or-nothing: a value that fails the rule is dropped whole rather than
    // filtered, so a pasted "123-456" never silently becomes "123456".
    if (next.length > 0 && !this.pattern.test(next)) {
      element.value = this.currentValue;
      return;
    }

    element.value = next;
    this.elementValue = next;

    if (this.isControlled) {
      if (notify === 'input') {
        this.args.onInput?.(next, event);
      } else {
        this.args.onChange?.(next, event);
      }
    } else {
      this.uncontrolledValue = next;
    }

    const previous = this.previousValue;
    this.previousValue = next;

    if (
      next !== previous &&
      previous.length < this.length &&
      next.length === this.length
    ) {
      this.args.onComplete?.(next);
    }
  }

  @action handleInput(event: Event): void {
    this.syncValue(event, 'input');
  }

  @action handleChange(event: Event): void {
    this.syncValue(event, 'change');
  }

  @action handleBlur(): void {
    this.args.onBlur?.();
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
      {{! Chrome's translate feature rewrites the cell text nodes, wrapping
          them in <font> elements that Glimmer then tries to update. }}
      <div
        class={{this.classes.container class=@classes.container}}
        data-component="input-otp"
        translate="no"
      >
        {{#each this.cellGroups key="@index" as |group|}}
          <div class={{this.classes.group class=@classes.group}}>
            {{#each group key="index" as |cell|}}
              <div
                class={{this.classes.cell
                  class=@classes.cell
                  isInvalid=c.isInvalid
                  isDisabled=@isDisabled
                }}
                data-test-id="input-otp-cell"
                aria-hidden="true"
              >
                <span class={{this.classes.cellChar class=@classes.cellChar}}>
                  {{cell.char}}
                </span>
              </div>
            {{/each}}
          </div>
        {{/each}}

        <input
          {{this.inputRef.setup}}
          {{on "input" this.handleInput}}
          {{on "change" this.handleChange}}
          {{on "blur" this.handleBlur}}
          id={{c.id}}
          name={{@name}}
          type="text"
          maxlength={{this.length}}
          value={{this.currentValue}}
          disabled={{@isDisabled}}
          class={{this.classes.input class=@classes.input}}
          data-component="input-otp-input"
          aria-invalid={{if c.isInvalid "true"}}
          aria-describedby={{c.describedBy @description c.isInvalid}}
          autocomplete="one-time-code"
          inputmode={{this.inputMode}}
          pattern={{this.pattern.source}}
          autocapitalize={{this.autoCapitalize}}
          autocorrect="off"
          spellcheck="false"
          ...attributes
        />
      </div>
    </FormControl>
  </template>
}

export { InputOtp, type InputOtpSignature, type Cell };
export default InputOtp;
