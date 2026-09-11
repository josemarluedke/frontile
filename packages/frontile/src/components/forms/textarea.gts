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
  /**
   * The id attribute of the textarea, also used to associate the label and
   * description with it. One is generated when this is omitted.
   */
  id?: string;

  /**
   * The value of the textarea. Pair with `onInput` or `onChange` to control it;
   * leave it unset to let the element track its own value.
   */
  value?: string | number | boolean;

  /**
   * The name attribute of the underlying textarea, used when it is submitted as
   * part of a form.
   */
  name?: string;

  /**
   * The size of the textarea and its label.
   *
   * @defaultValue 'md'
   */
  size?: TextareaVariants['size'];

  /**
   * Class names for each slot of the component, merged with the theme's.
   */
  classes?: SlotsToClasses<TextareaSlots>;

  /**
   * Callback when oninput is triggered
   */
  onInput?: (value: string, event: InputEvent) => void;

  /**
   * Callback when onchange is triggered
   */
  onChange?: (value: string, event: InputEvent) => void;

  /**
   * Callback when onblur is triggered
   */
  onBlur?: () => void;

  /**
   * Controls pointer-events property of startContent.
   * If you want to pass the click event to the textarea, set it to `none`.
   *
   * @defaultValue 'auto'
   */
  startContentPointerEvents?: 'none' | 'auto';

  /**
   * Controls pointer-events property of endContent.
   * If you want to pass the click event to the textarea, set it to `none`.
   *
   * @defaultValue 'auto'
   */
  endContentPointerEvents?: 'none' | 'auto';
}

interface TextareaSignature {
  Args: Args;
  Blocks: {
    startContent: [];
    endContent: [];
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

  @action handleOnBlur(): void {
    this.args.onBlur?.();
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
      data-component="textarea"
      data-part="base"
      as |c|
    >
      <div
        class={{this.classes.innerContainer class=@classes.innerContainer}}
        data-part="inner-container"
      >
        {{#if (has-block "startContent")}}
          <div
            data-part="start-content"
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
        <textarea
          {{on "input" this.handleOnInput}}
          {{on "change" this.handleOnChange}}
          {{on "blur" this.handleOnBlur}}
          id={{c.id}}
          name={{@name}}
          value={{@value}}
          disabled={{@isDisabled}}
          class={{this.classes.input
            class=@classes.input
            hasStartContent=(has-block "startContent")
            hasEndContent=(has-block "endContent")
          }}
          data-part="input"
          aria-invalid={{if c.isInvalid "true"}}
          aria-describedby={{c.describedBy @description c.isInvalid}}
          ...attributes
        />
        {{#if (has-block "endContent")}}
          <div
            data-part="end-content"
            class={{this.classes.endContent
              class=@classes.endContent
              endContentPointerEvents=(if
                @endContentPointerEvents @endContentPointerEvents "auto"
              )
            }}
          >
            {{yield to="endContent"}}
          </div>
        {{/if}}
      </div>
    </FormControl>
  </template>
}
export { Textarea, type TextareaSignature };
export default Textarea;
