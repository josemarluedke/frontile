import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { warn } from '@ember/debug';
import { next } from '@ember/runloop';
import { modifier } from 'ember-modifier';
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

/**
 * The on-screen keyboard and autocapitalisation each character set implies.
 *
 * `tel` is deliberately not offered: its keypad carries `*`, `#` and pause
 * characters that every one of our patterns rejects.
 */
const OTP_INPUT_HINTS = {
  digits: { inputMode: 'numeric', autoCapitalize: 'off' },
  letters: { inputMode: 'text', autoCapitalize: 'characters' },
  alphanumeric: { inputMode: 'text', autoCapitalize: 'characters' }
} as const satisfies Record<
  AllowedChars,
  { inputMode: 'numeric' | 'text'; autoCapitalize: 'off' | 'characters' }
>;

interface Cell {
  index: number;
  /** What the cell actually draws: the character, a mask, or a placeholder. */
  displayChar: string | null;
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

  /**
   * Splits the cells into visual groups, e.g. `[3, 3]` for a six-digit code.
   * Omit it for a single group. Entries that do not sum to `length` warn in
   * development and are then clamped and padded, so exactly `length` cells
   * render either way.
   */
  groups?: number[];

  /**
   * The character shown between groups. Rendered `aria-hidden`, because the
   * value itself contains no separator.
   *
   * @defaultValue '–'
   */
  separator?: string;

  /**
   * Renders a bullet in place of each entered character. The real input's text
   * is already transparent, so this is purely what the cells draw -- the input
   * stays `type="text"`, which `type="password"` would break for autofill.
   *
   * @defaultValue false
   */
  isMasked?: boolean;

  /**
   * Characters shown in empty cells before anything is entered. Also exposed as
   * `aria-placeholder`.
   */
  placeholder?: string;
}

interface InputOtpSignature {
  Args: Args;
  Element: HTMLInputElement;
}

class InputOtp extends Component<InputOtpSignature> {
  /**
   * What the element holds, and what the cells draw. The element is the source
   * of truth for what the user typed -- the browser guarantees that -- so a
   * parent-owned `@value` is *written down into* it (by `syncFromValueArg` and
   * `reconcileWithParent`) rather than bound over it.
   *
   * Binding `value={{...}}` here is what broke typing inside a `<Form>`:
   * Glimmer revalidates in a microtask that runs *between* event listeners, so
   * the attribute was rewritten from a still-stale `@value` before the `input`
   * event had finished bubbling to the `<form>` -- wiping the keystroke, and
   * handing `<Form>` an empty value to store.
   */
  @tracked elementValue: string = this.args.value || '';

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

  get inputMode(): 'numeric' | 'text' {
    return OTP_INPUT_HINTS[this.allowedChars].inputMode;
  }

  get autoCapitalize(): 'off' | 'characters' {
    return OTP_INPUT_HINTS[this.allowedChars].autoCapitalize;
  }

  get isControlled(): boolean {
    return (
      typeof this.args.onChange === 'function' ||
      typeof this.args.onInput === 'function'
    );
  }

  /**
   * The cells are decoration for the real `<input>`, so they mirror what that
   * element actually holds. A controlled parent's `@value` reaches them the
   * same way it reaches the element: written down by `syncFromValueArg` when
   * the parent genuinely changes it, or by `reconcileWithParent` once the
   * parent has had its say about an edit.
   */
  get currentValue(): string {
    return this.elementValue;
  }

  /**
   * Writes a parent-owned value down into the element. A modifier re-runs only
   * when its tracked arguments actually change, so a `@value` that is merely
   * lagging behind what the user typed never re-runs this and never clobbers a
   * keystroke -- which is exactly what the removed `value=` binding did.
   *
   * This is what makes an external change take effect: a "Clear" button, a
   * transform, a value pushed in from elsewhere.
   */
  syncFromValueArg = modifier(
    (element: HTMLInputElement, [value]: [string | undefined]) => {
      if (typeof value === 'string' && value !== element.value) {
        element.value = value;
        this.elementValue = value;
      }
    }
  );

  /**
   * Gives a controlled parent the last word on an edit -- but only once the
   * `input` (or `change`) event has finished travelling.
   *
   * A parent that has been told the new value and still holds a different one
   * has *rejected* it, and controlled semantics say its value wins. A parent
   * that has not caught up yet has not rejected anything, and the two are
   * indistinguishable from `@value` at the moment we notify: `<Form>` updates
   * its data from a handler on the `<form>` element, which runs after ours.
   * Waiting for the dispatch to finish is what separates them.
   */
  reconcileWithParent(element: HTMLInputElement, emitted: string): void {
    next(this, () => {
      if (this.isDestroying || this.isDestroyed) {
        return;
      }

      const { value } = this.args;

      // Anything typed since this was scheduled wins: it is a later edit, with
      // a reconciliation of its own already on its way.
      if (
        typeof value !== 'string' ||
        value === emitted ||
        element.value !== emitted
      ) {
        return;
      }

      element.value = value;
      this.elementValue = value;
    });
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

  get separator(): string {
    return this.args.separator ?? '–';
  }

  /**
   * Cell counts per group. A mismatched `@groups` warns in development and
   * still renders `length` cells, so development and production behave the
   * same way.
   */
  get groupSizes(): number[] {
    const { groups } = this.args;

    if (!groups || groups.length === 0) {
      return [this.length];
    }

    const total = groups.reduce((sum, size) => sum + size, 0);

    warn(
      `<InputOtp>: @groups must sum to @length (${this.length}), got ${total}. ` +
        `Rendering ${this.length} cells and adjusting the groups to fit.`,
      total === this.length,
      { id: 'frontile.input-otp.groups-mismatch' }
    );

    const sizes: number[] = [];
    let taken = 0;

    for (const size of groups) {
      const clamped = Math.max(0, Math.min(size, this.length - taken));
      if (clamped > 0) {
        sizes.push(clamped);
        taken += clamped;
      }
    }

    if (taken < this.length) {
      sizes.push(this.length - taken);
    }

    return sizes;
  }

  /**
   * The cells are decoration rendered from a string, so they are grouped here
   * rather than in the template.
   */
  get cellGroups(): Cell[][] {
    const value = this.currentValue;
    const cells: Cell[] = [];

    const [start, end] = this.mirroredSelection;

    for (let index = 0; index < this.length; index++) {
      const char = value[index] ?? null;
      // The placeholder is an all-or-nothing preview: it survives only while
      // nothing at all has been entered.
      const placeholderChar =
        value.length === 0 ? (this.args.placeholder?.[index] ?? null) : null;

      let displayChar: string | null = placeholderChar;
      if (char !== null) {
        displayChar = this.args.isMasked ? '•' : char;
      }

      // A range selection lights up every cell it covers -- that is correct,
      // not a bug.
      const isActive =
        this.isFocused &&
        start !== null &&
        end !== null &&
        ((start === end && index === start) || (index >= start && index < end));

      cells.push({
        index,
        displayChar,
        isActive,
        hasFakeCaret: isActive && char === null
      });
    }

    const groups: Cell[][] = [];
    let offset = 0;

    for (const size of this.groupSizes) {
      groups.push(cells.slice(offset, offset + size));
      offset += size;
    }

    return groups;
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

    // The value as it stood before this edit, read before anything is mutated.
    // It is what we last wrote to the element, which is the rendered truth in
    // every ownership mode: a change the parent made on its own -- a "Clear" or
    // "Resend code" button -- has been written down into the element too, so
    // this does not go stale and the next single-event autofill still reads as
    // a genuine transition rather than a full-to-full replacement.
    //
    // It is also what stops the `change` that merely echoes an `input` we have
    // already handled from completing a second time: by then it already equals
    // `next`.
    const previous = this.currentValue;

    // All-or-nothing: a value that fails the rule is dropped whole rather than
    // filtered, so a pasted "123-456" never silently becomes "123456".
    if (next.length > 0 && !this.pattern.test(next)) {
      element.value = previous;
      return;
    }

    element.value = next;
    this.elementValue = next;

    // Only a parent that was actually told gets a say in the reconciliation --
    // an `@onChange`-only parent is not credited with knowing about an `input`
    // it never heard.
    if (this.isControlled) {
      if (notify === 'input') {
        if (this.args.onInput) {
          this.args.onInput(next, event);
          this.reconcileWithParent(element, next);
        }
      } else if (this.args.onChange) {
        this.args.onChange(next, event);
        this.reconcileWithParent(element, next);
      }
    }

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

  @action handleOnInput(event: Event): void {
    this.syncValue(event, 'input');
  }

  @action handleOnChange(event: Event): void {
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

  @action handleOnBlur(): void {
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
        {{#each this.cellGroups key="@index" as |group groupIndex|}}
          {{#if groupIndex}}
            <div
              class={{this.classes.separator class=@classes.separator}}
              data-test-id="input-otp-separator"
              aria-hidden="true"
            >{{this.separator}}</div>
          {{/if}}
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
                  {{cell.displayChar}}
                </span>
                {{#if cell.hasFakeCaret}}
                  {{! Never the only focus affordance -- under
                      prefers-reduced-motion it stops blinking and reads as a
                      static bar, so the active cell also rings. }}
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
          {{this.syncFromValueArg @value}}
          {{on "input" this.handleOnInput}}
          {{on "change" this.handleOnChange}}
          {{on "focus" this.handleFocus}}
          {{on "blur" this.handleOnBlur}}
          id={{c.id}}
          name={{@name}}
          type="text"
          maxlength={{this.length}}
          disabled={{@isDisabled}}
          class={{this.classes.input class=@classes.input}}
          data-component="input-otp-input"
          aria-invalid={{if c.isInvalid "true"}}
          aria-describedby={{c.describedBy @description c.isInvalid}}
          aria-placeholder={{@placeholder}}
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

export { InputOtp, type InputOtpSignature };
export default InputOtp;
