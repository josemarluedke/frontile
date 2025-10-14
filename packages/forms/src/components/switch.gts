import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { FormControl, type FormControlSharedArgs } from './form-control';
import {
  useStyles,
  type SwitchVariants,
  type SwitchSlots,
  type SlotsToClasses
} from '@frontile/theme';
import { tracked } from '@ember/-internals/metal';
import type Owner from '@ember/owner';
import { hash } from '@ember/helper';

interface Args extends FormControlSharedArgs {
  /**
   * Controls the current selected state of the Switch.
   * When provided a boolean value, the component operates in a controlled mode.
   */
  isSelected?: boolean;

  /**
   * Sets the initial selected state of the Switch when used in uncontrolled mode.
   * @defaultValue false
   */
  defaultSelected?: boolean;

  /**
   * The name attribute for the input element.
   * Useful for form submissions.
   */
  name?: string;

  /**
   * The size of the Switch.
   */
  size?: SwitchVariants['size'];

  /**
   * The visual intent (e.g., color or style) of the Switch.
   * @defaultValue 'primary'
   */
  intent?: SwitchVariants['intent'];

  /**
   * Custom classes to style different slots of the Switch component.
   */
  classes?: SlotsToClasses<SwitchSlots>;

  /**
   * Whether the Switch is disabled.
   * When true, user interaction is prevented.
   */
  isDisabled?: boolean;

  /**
   * Callback triggered when the Switch value changes.
   * Receives the new boolean value and, optionally, the triggering Event.
   */
  onChange?:
    | ((value: boolean, event: Event) => void)
    | ((value: boolean) => void);

  /**
   * Callback triggered when the Switch loses focus (blur event).
   */
  onBlur?: () => void;
}

interface SwitchSignature {
  Args: Args;
  Blocks: {
    startContent: [];
    thumbContent: [{ isSelected: boolean }];
    endContent: [];
  };

  Element: HTMLInputElement;
}

class Switch extends Component<SwitchSignature> {
  @tracked _isSelected;

  constructor(owner: Owner, args: Args) {
    super(owner, args);

    this._isSelected = this.args.defaultSelected ? true : false;
  }

  get isControlled(): boolean {
    return typeof this.args.isSelected === 'boolean';
  }

  get isSelected(): boolean {
    if (this.isControlled) {
      return !!this.args.isSelected;
    }
    return this._isSelected;
  }

  handleChange = (event: Event) => {
    event.preventDefault();

    const value = !this.isSelected;
    this._isSelected = value;

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(value, event);
    }
  };

  handleBlur = (): void => {
    this.args.onBlur?.();
  };

  get classes() {
    const { switchInput } = useStyles();
    return switchInput({
      size: this.args.size,
      intent: this.args.intent,
      isDisabled: this.args.isDisabled
    });
  }

  <template>
    <FormControl
      @isInvalid={{@isInvalid}}
      @errors={{@errors}}
      @size={{@size}}
      @isRequired={{@isRequired}}
      @class={{this.classes.base class=@classes.base}}
      @preventErrorFeedback={{true}}
      data-component="switch"
      data-selected="{{this.isSelected}}"
      data-disabled="{{@isDisabled}}"
      as |c|
    >
      <span class={{this.classes.wrapper class=@classes.wrapper}}>
        <input
          {{on "change" this.handleChange}}
          {{on "blur" this.handleBlur}}
          id={{c.id}}
          name={{@name}}
          checked={{this.isSelected}}
          class={{this.classes.hiddenInput class=@classes.hiddenInput}}
          type="checkbox"
          disabled={{@isDisabled}}
          aria-invalid={{if c.isInvalid "true"}}
          aria-describedby={{c.describedBy @description c.isInvalid}}
          ...attributes
        />
        {{#if (has-block "startContent")}}
          <div
            data-test-id="switch-start-content"
            class={{this.classes.startContent class=@classes.startContent}}
          >
            {{yield to="startContent"}}
          </div>
        {{/if}}

        <span
          class={{this.classes.thumb class=@classes.thumb}}
          data-test-id="switch-thumb-content"
        >
          {{#if (has-block "thumbContent")}}
            {{yield (hash isSelected=this.isSelected) to="thumbContent"}}
          {{/if}}

        </span>
        {{#if (has-block "endContent")}}
          <div
            data-test-id="switch-end-content"
            class={{this.classes.endContent class=@classes.endContent}}
          >
            {{yield to="endContent"}}
          </div>
        {{/if}}
      </span>

      <div class={{this.classes.labelContainer class=@classes.labelContainer}}>
        {{#if @label}}
          <c.Label @class={{this.classes.label class=@classes.label}}>
            {{@label}}
          </c.Label>
        {{/if}}
        {{#if @description}}
          <c.Description>{{@description}}</c.Description>
        {{/if}}
        {{#if c.isInvalid}}
          <c.Feedback />
        {{/if}}
      </div>
    </FormControl>
  </template>
}

export { Switch, type SwitchSignature };
export default Switch;
