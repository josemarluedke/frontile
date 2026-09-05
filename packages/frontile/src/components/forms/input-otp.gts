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

  @tracked isFocused = false;
  @tracked selectionStart: number | null = null;
  @tracked selectionEnd: number | null = null;

  /**
   * The previous selection. The selection API cannot tell us which side of a
   * character boundary the user meant, so direction is inferred by comparing
   * against where the caret was a moment ago.
   */
  prevSelection: [number | null, number | null] = [null, null];

  /**
   * `selectionchange` only fires on `document`, and capture phase keeps us
   * ahead of anything else listening.
   */
  inputRef = ref<HTMLInputElement>((element) => {
    if (element) {
      document.addEventListener('selectionchange', this.onSelectionChange, {
        capture: true
      });
    } else {
      document.removeEventListener('selectionchange', this.onSelectionChange, {
        capture: true
      });
    }
  });

  willDestroy(): void {
    super.willDestroy();
    document.removeEventListener('selectionchange', this.onSelectionChange, {
      capture: true
    });
  }

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
   * The mirror, clamped against the value it is describing. A controlled parent
   * can shrink `@value` on its own -- a "Clear" button beside the field -- and
   * that never travels through `syncValue`, so the stored selection would keep
   * pointing past the end of the code and light up a phantom cell. Deriving the
   * clamp here rather than observing the argument keeps the fix to one place:
   * a selection past the end collapses to the append position, which is exactly
   * where a fresh focus on a value of that length would put it.
   *
   * Current Chrome happens to clamp the element's own selection and fire
   * `selectionchange` when a programmatic value shrinks, which papers over this
   * -- as it also papers over the synthetic dispatch in `syncValue`. Neither is
   * guaranteed, so the derivation stands on its own.
   */
  get mirroredSelection(): [number | null, number | null] {
    const { selectionStart: start, selectionEnd: end } = this;

    if (start === null || end === null) {
      return [null, null];
    }

    const length = this.currentValue.length;

    if (end > length && length < this.length) {
      return [length, length];
    }

    return [start, end];
  }

  /**
   * The cells are decoration rendered from a string, so they are grouped here
   * rather than in the template. Grouping arrives in a later task; for now
   * every cell lives in a single group.
   */
  get cellGroups(): Cell[][] {
    const value = this.currentValue;
    const cells: Cell[] = [];

    const [start, end] = this.mirroredSelection;

    for (let index = 0; index < this.length; index++) {
      const char = value[index] ?? null;
      // A range selection lights up every cell it covers -- that is correct,
      // not a bug.
      const isActive =
        this.isFocused &&
        start !== null &&
        end !== null &&
        ((start === end && index === start) || (index >= start && index < end));

      cells.push({
        index,
        char,
        placeholderChar: null,
        isActive,
        hasFakeCaret: isActive && char === null
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

    // No browser fires selectionchange for a deletion or a cut, so the active
    // cell would stick where it was. Known cost: this also fires on
    // select-all-then-paste-shorter, which is harmless.
    if (next.length < previous.length) {
      document.dispatchEvent(new Event('selectionchange'));
    }
  }

  @action handleInput(event: Event): void {
    this.syncValue(event, 'input');
  }

  @action handleChange(event: Event): void {
    this.syncValue(event, 'change');
  }

  /**
   * Maps the input's text caret onto discrete cells. A collapsed caret sits
   * between characters and so belongs to no cell; widening it to a
   * one-character range makes exactly one cell active and makes typing
   * overwrite rather than insert.
   */
  @action onSelectionChange(): void {
    const input = this.inputRef.current;
    if (!input || document.activeElement !== input) {
      return;
    }

    const value = input.value;
    const maxLength = this.length;
    const caretStart = input.selectionStart;
    const caretEnd = input.selectionEnd;

    if (caretStart === null || caretEnd === null) {
      return;
    }

    let start = -1;
    let end = -1;
    let direction: 'forward' | 'backward' | 'none' =
      input.selectionDirection ?? 'none';

    const isSingleCaret = caretStart === caretEnd;
    // Appending to a not-yet-full code: leave the caret collapsed, or the next
    // keystroke would replace the character before it instead of adding one.
    const isInsertMode =
      caretStart === value.length && value.length < maxLength;

    if (isSingleCaret && !isInsertMode) {
      const caret = caretStart;

      if (caret === 0) {
        start = 0;
        end = 1;
        direction = 'forward';
      } else if (caret === maxLength) {
        start = caret - 1;
        end = caret;
        direction = 'backward';
      } else if (maxLength > 1 && value.length > 1) {
        let offset = 0;
        const [prevStart, prevEnd] = this.prevSelection;

        if (prevStart !== null && prevEnd !== null) {
          direction = caret < prevEnd ? 'backward' : 'forward';
          const wasInserting = prevStart === prevEnd && prevStart < maxLength;
          // Without this, ArrowLeft appears to skip a cell -- except when
          // leaving append mode, where the shift would overshoot.
          if (direction === 'backward' && !wasInserting) {
            offset = -1;
          }
        }

        start = offset + caret;
        end = offset + caret + 1;
      }
    }

    if (start !== -1 && end !== -1 && start !== end) {
      input.setSelectionRange(start, end, direction);
    }

    this.selectionStart = input.selectionStart;
    this.selectionEnd = input.selectionEnd;
    this.prevSelection = [input.selectionStart, input.selectionEnd];
  }

  @action handleFocus(): void {
    this.isFocused = true;

    const input = this.inputRef.current;
    if (!input) {
      return;
    }

    // Park on the last cell rather than past the end of a full code.
    const start = Math.min(input.value.length, this.length - 1);
    input.setSelectionRange(start, input.value.length);
    this.onSelectionChange();
  }

  @action handleBlur(): void {
    this.isFocused = false;
    this.selectionStart = null;
    this.selectionEnd = null;
    this.prevSelection = [null, null];
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
                  isActive=cell.isActive
                  isInvalid=c.isInvalid
                  isDisabled=@isDisabled
                }}
                data-test-id="input-otp-cell"
                data-active={{if cell.isActive "true"}}
                aria-hidden="true"
              >
                <span class={{this.classes.cellChar class=@classes.cellChar}}>
                  {{cell.char}}
                </span>
                {{#if cell.hasFakeCaret}}
                  {{! Never the only focus affordance -- it is invisible under
                      prefers-reduced-motion, so the active cell also rings. }}
                  <span
                    class={{this.classes.caret class=@classes.caret}}
                    data-test-id="input-otp-caret"
                  ></span>
                {{/if}}
              </div>
            {{/each}}
          </div>
        {{/each}}

        <input
          {{this.inputRef.setup}}
          {{on "input" this.handleInput}}
          {{on "change" this.handleChange}}
          {{on "focus" this.handleFocus}}
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
