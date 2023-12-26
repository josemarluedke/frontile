import Base, { type BaseArgs, type BaseSignature } from './base';
import { action } from '@ember/object';
import FormSelect, {
  type FormSelectArgs,
  type Select
} from '@frontile/forms/components/form-select';

export interface ChangesetFormFieldsSelectArgs
  extends BaseArgs,
    FormSelectArgs {
  onChange: (selection: unknown, select: Select, event?: Event) => void;
  onFocusOut?: (select: Select, event: FocusEvent) => void;
  onClose?: (select: Select, e: Event) => boolean | undefined;
}

export interface ChangesetFormFieldsSelectSignature extends BaseSignature {
  Args: ChangesetFormFieldsSelectArgs;
  Blocks: {
    default: [option: unknown, select: Select];
  };
  Element: HTMLDivElement;
}

export default class ChangesetFormFieldsSelect extends Base<ChangesetFormFieldsSelectSignature> {
  @action
  async handleChange(
    selection: unknown,
    select: Select,
    event?: Event
  ): Promise<void> {
    this.args.changeset.set(this.args.fieldName, selection);
    await this.validate();

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(selection, select, event);
    }
  }

  @action
  async handleFocusOut(select: Select, event: FocusEvent): Promise<void> {
    await this.validate();

    if (typeof this.args.onFocusOut === 'function') {
      this.args.onFocusOut(select, event);
    }
  }

  @action
  async handleClose(select: Select, event: Event): Promise<void> {
    await this.validate();

    if (typeof this.args.onClose === 'function') {
      this.args.onClose(select, event);
    }
  }
  <template>
    {{! @glint-nocheck: need to fix powerselect types}}
    <FormSelect
      @selected={{this.value}}
      @onChange={{this.handleChange}}
      @onFocusOut={{this.handleFocusOut}}
      @onClose={{this.handleClose}}
      @errors={{this.errors}}
      @hasSubmitted={{@hasSubmitted}}
      @isMultiple={{@isMultiple}}
      @label={{@label}}
      @hint={{@hint}}
      @hasError={{@hasError}}
      @showError={{@showError}}
      @containerClass={{@containerClass}}
      @size={{@size}}
      @onFocusIn={{@onFocusIn}}
      @onFocus={{@onFocus}}
      @onBlur={{@onBlur}}
      @onOpen={{@onOpen}}
      @triggerClass={{@triggerClass}}
      @highlightOnHover={{@highlightOnHover}}
      @placeholderComponent={{@placeholderComponent}}
      @searchMessage={{@searchMessage}}
      @noMatchesMessage={{@noMatchesMessage}}
      @matchTriggerWidth={{@matchTriggerWidth}}
      @options={{@options}}
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
      ...attributes
      as |option term|
    >
      {{yield option term}}
    </FormSelect>
  </template>
}
