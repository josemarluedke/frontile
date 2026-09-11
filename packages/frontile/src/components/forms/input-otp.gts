import Component from '@glimmer/component';
import { cached, tracked } from '@glimmer/tracking';
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
   * development; the groups then run out of cells or take a final group of the
   * remainder, so exactly `length` cells render either way.
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

/**
 * Ownership model, stated once.
 *
 * The `<input>` element is the source of truth for what the user typed -- the
 * browser guarantees that -- so a parent-owned `@value` is *written down into*
 * it (by `syncFromValueArg` and `reconcileWithParent`) rather than bound over
 * it with `value={{...}}`.
 *
 * That binding is what broke typing inside a `<Form>`. `elementValue` is
 * dirtied mid-dispatch and the template reads it (through `cellGroups`), so
 * Glimmer revalidates in a microtask that runs *between* event listeners --
 * rewriting the `value` attribute from a still-stale `@value` before the
 * `input` event had finished bubbling to the `<form>`, wiping the keystroke and
 * handing `<Form>` an empty value to store.
 *
 * The one invariant that keeps the mirror honest: every code path that writes
 * `element.value` goes through `writeValue`, which re-derives the selection
 * mirror straight afterwards.
 */
class InputOtp extends Component<InputOtpSignature> {
  /** What the element holds, and what the cells draw. */
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

  /**
   * The only way the element's value is ever written. Keeping the element, the
   * mirror of its value and the mirror of its selection in step here is what
   * lets every reader downstream just read them.
   */
  writeValue(element: HTMLInputElement, value: string): void {
    // Assigning to `value` resets the selection even when the string is
    // unchanged, so a redundant write is not merely wasteful.
    if (element.value !== value) {
      element.value = value;
    }

    // Deliberately unguarded: `syncFromValueArg` reaches here from inside a
    // modifier, and reading `elementValue` there would consume it into the same
    // computation that then writes it -- which Glimmer rejects outright.
    this.elementValue = value;

    // No browser fires `selectionchange` for a programmatic write (nor for a
    // deletion or a cut), so the mirror is re-derived by hand. It is a no-op
    // while the input is not focused, which is exactly right.
    this.onSelectionChange();
  }

  /**
   * Writes a parent-owned value down into the element. A modifier re-runs only
   * when its tracked arguments actually change, so a `@value` that is merely
   * lagging behind what the user typed never re-runs this and never clobbers a
   * keystroke.
   */
  syncFromValueArg = modifier(
    (element: HTMLInputElement, [value]: [string | undefined]) => {
      if (typeof value === 'string' && value !== element.value) {
        this.writeValue(element, value);
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

      this.writeValue(element, value);
    });
  }

  /** The selection mirror, kept in step by `writeValue`. */
  get mirroredSelection(): [number | null, number | null] {
    return [this.selectionStart, this.selectionEnd];
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

    if (total !== this.length) {
      warn(
        `<InputOtp>: @groups must sum to @length (${this.length}), got ${total}. ` +
          `Rendering ${this.length} cells and adjusting the groups to fit.`,
        false,
        { id: 'frontile.input-otp.groups-mismatch' }
      );
    }

    return groups;
  }

  get cellGroups(): Cell[][] {
    const value = this.elementValue;
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

    // `slice` clamps on its own, so a `@groups` that overshoots simply runs out
    // of cells; anything left over becomes a final group. Either way exactly
    // `length` cells render.
    const groups: Cell[][] = [];
    let offset = 0;

    for (const size of this.groupSizes) {
      if (offset >= cells.length) {
        break;
      }
      if (size <= 0) {
        continue;
      }
      groups.push(cells.slice(offset, offset + size));
      offset += size;
    }

    if (offset < cells.length) {
      groups.push(cells.slice(offset));
    }

    return groups;
  }

  @cached
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
    const previous = this.elementValue;

    // All-or-nothing: a value that fails the rule is dropped whole rather than
    // filtered, so a pasted "123-456" never silently becomes "123456".
    if (next.length > 0 && !this.pattern.test(next)) {
      this.writeValue(element, previous);
      return;
    }

    this.writeValue(element, next);

    // Only a parent that was actually told gets a say in the reconciliation --
    // an `@onChange`-only parent is not credited with knowing about an `input`
    // it never heard.
    const notifyParent =
      notify === 'input' ? this.args.onInput : this.args.onChange;

    if (notifyParent) {
      notifyParent(next, event);
      this.reconcileWithParent(element, next);
    }

    if (
      next !== previous &&
      previous.length < this.length &&
      next.length === this.length
    ) {
      this.args.onComplete?.(next);
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

    // `selectionchange` fires several times per keystroke; writing an identical
    // value would still dirty the tag and rebuild every cell. The comparison
    // goes through the untracked `prevSelection`, which holds exactly what was
    // last mirrored -- reading the tracked fields here would consume them into
    // the modifier computation that `writeValue` calls this from.
    const [lastStart, lastEnd] = this.prevSelection;

    if (lastStart !== input.selectionStart) {
      this.selectionStart = input.selectionStart;
    }

    if (lastEnd !== input.selectionEnd) {
      this.selectionEnd = input.selectionEnd;
    }

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
      data-component="input-otp"
      data-part="base"
      as |c|
    >
      {{! Chrome's translate feature rewrites the cell text nodes, wrapping
          them in <font> elements that Glimmer then tries to update. }}
      <div
        class={{this.classes.container class=@classes.container}}
        data-part="container"
        translate="no"
      >
        {{#each this.cellGroups key="@index" as |group groupIndex|}}
          {{#if groupIndex}}
            <div
              class={{this.classes.separator class=@classes.separator}}
              data-part="separator"
              aria-hidden="true"
            >{{this.separator}}</div>
          {{/if}}
          <div
            class={{this.classes.group class=@classes.group}}
            data-part="group"
          >
            {{#each group key="index" as |cell|}}
              <div
                class={{this.classes.cell
                  class=@classes.cell
                  isActive=cell.isActive
                  isInvalid=c.isInvalid
                  isDisabled=@isDisabled
                }}
                data-part="cell"
                data-active={{if cell.isActive "true"}}
                aria-hidden="true"
              >
                <span
                  class={{this.classes.cellChar class=@classes.cellChar}}
                  data-part="cell-char"
                >
                  {{cell.displayChar}}
                </span>
                {{#if cell.hasFakeCaret}}
                  {{! Never the only focus affordance -- under
                      prefers-reduced-motion it stops blinking and reads as a
                      static bar, so the active cell also rings. }}
                  <span
                    class={{this.classes.caret class=@classes.caret}}
                    data-part="caret"
                  ></span>
                {{/if}}
              </div>
            {{/each}}
          </div>
        {{/each}}

        {{! False positive in no-unsupported-role-attributes
            (ember-template-lint 7.9.3). Its getImplicitRole helper matches an
            aria-query key on the type attribute alone and ignores that key's
            other constraints, so a plain text input resolves to the
            list-bearing combobox entry instead of textbox. This input has no
            list attribute, so textbox is its real implicit role, and textbox
            does support aria-placeholder. The rule is disabled for this
            element only, so its autofixer cannot silently delete
            aria-placeholder when someone runs pnpm lint:hbs --fix. See the
            @placeholder test in input-otp-test.gts. }}
        {{! template-lint-disable no-unsupported-role-attributes }}
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
          data-part="input"
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
        {{! template-lint-enable no-unsupported-role-attributes }}
      </div>
    </FormControl>
  </template>
}

export { InputOtp, type InputOtpSignature };
export default InputOtp;
