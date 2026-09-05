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
   * The size of the cells and the label.
   *
   * @defaultValue 'md'
   */
  size?: InputOtpVariants['size'];

  /**
   * Class names for each slot of the component, merged with the theme's.
   */
  classes?: SlotsToClasses<InputOtpSlots>;
}

interface InputOtpSignature {
  Args: Args;
  Element: HTMLInputElement;
}

class InputOtp extends Component<InputOtpSignature> {
  @tracked uncontrolledValue: string = '';

  inputRef = ref<HTMLInputElement>();

  get length(): number {
    return this.args.length ?? 6;
  }

  get currentValue(): string {
    return this.uncontrolledValue;
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

  @action handleInput(event: Event): void {
    const element = event.target as HTMLInputElement;
    const next = element.value.slice(0, this.length);

    element.value = next;
    this.uncontrolledValue = next;
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
          ...attributes
        />
      </div>
    </FormControl>
  </template>
}

export { InputOtp, type InputOtpSignature, type Cell };
export default InputOtp;
