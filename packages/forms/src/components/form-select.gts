import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { assert } from '@ember/debug';
import PowerSelect, {
  PowerSelectArgs,
  Select
} from 'ember-power-select/components/power-select';
import PowerSelectMultiple from 'ember-power-select/components/power-select-multiple';
import useFrontileClass from '@frontile/core/helpers/use-frontile-class';
import FormField from './form-field';
import { concat } from '@ember/helper';

export interface FormSelectArgs extends PowerSelectArgs {
  /** The input field label */
  label?: string;
  /** A help text to be displayed */
  hint?: string;
  /** If the form has been submitted, used to force displaying errors */
  hasSubmitted?: boolean;
  /** If has errors */
  hasError?: boolean;
  /** Force displaying errors */
  showError?: boolean;
  /** A list of errors or a single text describing the error */
  errors?: string[] | string;
  /** CSS classes to be added in the container element */
  containerClass?: string;
  /** The size */
  size?: 'sm' | 'lg';

  /** If is multiple select instead of single */
  isMultiple?: boolean;

  // Same as onFocus from ember-power-select
  onFocusIn?: (select: Select, event: FocusEvent) => void;
  // Same as onBlur from ember-power-select
  onFocusOut?: (select: Select, event: FocusEvent) => void;
}

export interface FormSelectSignature {
  Args: FormSelectArgs;
  Blocks: {
    default: [option: unknown, select: Select];
  };
  Element: HTMLDivElement;
}

export default class FormSelect extends Component<FormSelectSignature> {
  @tracked shouldShowErrorFeedback = false;
  @tracked isOpen = false;

  constructor(owner: unknown, args: FormSelectArgs) {
    super(owner, args);
    assert(
      '<FormSelect> requires an `@onChange` function',
      this.args.onChange && typeof this.args.onChange === 'function'
    );
  }

  get showErrorFeedback(): boolean {
    if (this.args.hasError === false) {
      return false;
    }

    if (
      (this.args.showError ||
        this.args.hasSubmitted ||
        this.shouldShowErrorFeedback) &&
      this.args.errors &&
      this.args.errors.length > 0
    ) {
      return true;
    } else {
      return false;
    }
  }

  @action handleOpen(select: Select, event: Event): void {
    this.isOpen = true;
    this.shouldShowErrorFeedback = false;

    if (typeof this.args.onOpen === 'function') {
      this.args.onOpen(select, event);
    }
  }

  @action handleClose(select: Select, event: Event): void {
    this.isOpen = false;
    this.shouldShowErrorFeedback = true;

    if (typeof this.args.onClose === 'function') {
      this.args.onClose(select, event);
    }
  }

  @action handleFocusIn(select: Select, event: FocusEvent): void {
    this.shouldShowErrorFeedback = false;

    if (typeof this.args.onFocusIn === 'function') {
      this.args.onFocusIn(select, event);
    }

    // ember-power-select argument
    if (typeof this.args.onFocus === 'function') {
      this.args.onFocus(select, event);
    }
  }

  @action handleFocusOut(select: Select, event: FocusEvent): void {
    if (!this.isOpen) {
      this.shouldShowErrorFeedback = true;
    }

    if (typeof this.args.onFocusOut === 'function') {
      this.args.onFocusOut(select, event);
    }

    // ember-power-select argument
    if (typeof this.args.onBlur === 'function') {
      this.args.onBlur(select, event);
    }
  }

  @action handleChange(
    selection: unknown,
    select: Select,
    event?: Event
  ): void {
    this.shouldShowErrorFeedback = true;
    this.args.onChange(selection, select, event);
  }

  <template>
    <FormField
      @size={{@size}}
      class={{useFrontileClass "form-select" @size class=@containerClass}}
      as |f|
    >

      {{#if @label}}
        <f.Label
          @for=""
          id={{f.id}}
          class={{useFrontileClass "form-select" @size part="label"}}
        >
          {{@label}}
        </f.Label>
      {{/if}}

      {{#if @hint}}
        <f.Hint class={{useFrontileClass "form-select" @size part="hint"}}>
          {{@hint}}
        </f.Hint>
      {{/if}}

      {{#let (if @isMultiple PowerSelectMultiple PowerSelect) as |Component|}}
        <Component
          ...attributes
          @onChange={{this.handleChange}}
          @onFocus={{this.handleFocusIn}}
          @onBlur={{this.handleFocusOut}}
          @onOpen={{this.handleOpen}}
          @onClose={{this.handleClose}}
          @ariaDescribedBy="{{if @hint f.hintId}}{{if
            this.showErrorFeedback
            (concat ' ' f.feedbackId)
          }}{{if @ariaDescribedBy (concat ' ' @ariaDescribedBy)}}"
          @ariaLabelledBy="{{if @label f.id}}{{if
            @ariaLabelledBy
            (concat ' ' @ariaLabelledBy)
          }}"
          @ariaInvalid={{if this.showErrorFeedback "true"}}
          @triggerClass="{{@triggerClass}}{{if
            @size
            (concat 'ember-power-select-trigger-' @size)
          }}{{useFrontileClass 'form-select' @size part="select"}}"
          @highlightOnHover={{@highlightOnHover}}
          @placeholderComponent={{@placeholderComponent}}
          @searchMessage={{@searchMessage}}
          @noMatchesMessage={{@noMatchesMessage}}
          @matchTriggerWidth={{@matchTriggerWidth}}
          @options={{@options}}
          @selected={{@selected}}
          @closeOnSelect={{@closeOnSelect}}
          @defaultHighlighted={{@defaultHighlighted}}
          @searchField={{@searchField}}
          @searchEnabled={{@searchEnabled}}
          @tabindex={{@tabindex}}
          @triggerComponent={{@triggerComponent}}
          @matcher={{@matcher}}
          @initiallyOpened={{@initiallyOpened}}
          @typeAheadOptionMatcher={{@typeAheadOptionMatcher}}
          @buildSelection={{@buildSelection}}
          @search={{@search}}
          @onInput={{@onInput}}
          @onKeydown={{@onKeydown}}
          @scrollTo={{@scrollTo}}
          @registerAPI={{@registerAPI}}
          @horizontalPosition={{@horizontalPosition}}
          @destination={{@destination}}
          @preventScroll={{@preventScroll}}
          @renderInPlace={{@renderInPlace}}
          @verticalPosition={{@verticalPosition}}
          @disabled={{@disabled}}
          @calculatePosition={{@calculatePosition}}
          @eventType={{@eventType}}
          @ariaLabel={{@ariaLabel}}
          @required={{@required}}
          @triggerRole={{@triggerRole}}
          @title={{@title}}
          @triggerId={{@triggerId}}
          @allowClear={{@allowClear}}
          @loadingMessage={{@loadingMessage}}
          @selectedItemComponent={{@selectedItemComponent}}
          @dropdownClass={{@dropdownClass}}
          @beforeOptionsComponent={{@beforeOptionsComponent}}
          @placeholder={{@placeholder}}
          @searchPlaceholder={{@searchPlaceholder}}
          @searchMessageComponent={{@searchMessageComponent}}
          @optionsComponent={{@optionsComponent}}
          @extra={{@extra}}
          @groupComponent={{@groupComponent}}
          @afterOptionsComponent={{@afterOptionsComponent}}
          as |option term|
        >
          {{yield option term}}
        </Component>
      {{/let}}

      {{#if this.showErrorFeedback}}
        <f.Feedback
          class={{useFrontileClass "form-select" @size part="feedback"}}
          @errors={{@errors}}
        />
      {{/if}}
    </FormField>
  </template>
}
