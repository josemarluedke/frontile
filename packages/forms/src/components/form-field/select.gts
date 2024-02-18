import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import {
  Listbox,
  type ListboxSignature,
  type ListboxItem
} from '@frontile/collections';
import { useStyles } from '@frontile/theme';
import {
  Popover,
  type PopoverSignature,
  type ContentSignature
} from '@frontile/overlays';
import { assert } from '@ember/debug';
import { hash } from '@ember/helper';
import type { ModifierLike } from '@glint/template';
import type { WithBoundArgs } from '@glint/template';

interface FormFieldSelectArgs<T = unknown>
  extends Pick<
      PopoverSignature['Args'],
      | 'placement'
      | 'flipOptions'
      | 'middleware'
      | 'shiftOptions'
      | 'offsetOptions'
      | 'strategy'
      | 'onClose'
    >,
    Pick<
      ListboxSignature<T>['Args'],
      | 'appearance'
      | 'intent'
      | 'class'
      | 'selectionMode'
      | 'selectedKeys'
      | 'disabledKeys'
      | 'allowEmpty'
      | 'onSelectionChange'
      | 'items'
    >,
    Pick<
      ContentSignature['Args'],
      | 'renderInPlace'
      | 'destinationElementId'
      | 'transitionDuration'
      | 'backdrop'
      | 'disableTransitions'
      | 'focusTrapOptions'
      | 'closeOnOutsideClick'
      | 'closeOnEscapeKey'
      | 'backdropTransition'
      | 'transition'
    > {
  /**
   * Whether the dropdown should close upon selecting an item.
   *
   * @defaultValue true
   */
  closeOnItemSelect?: boolean;
  /**
   * @defaultValue true
   */
  blockScroll?: boolean;

  /**
   * @defaultValue false
   */
  disableFocusTrap?: boolean;
}

interface FormFieldSelectSignature {
  Args: FormFieldSelectArgs;
  Element: HTMLUListElement;
  Blocks: ListboxSignature['Blocks'];
}

class FormFieldSelect extends Component<FormFieldSelectSignature> {
  get blockScroll() {
    if (this.args.blockScroll === false) {
      return false;
    }
    return true;
  }

  get disableFocusTrap() {
    if (this.args.disableFocusTrap === true) {
      return true;
    }
    return false;
  }

  onAction = (key: string) => {
    // todo
  };

  get selectedText() {
    return this.args.selectedKeys?.join(', ');
  }

  <template>
    <Popover
      @placement={{@placement}}
      @flipOptions={{@flipOptions}}
      @middleware={{@middleware}}
      @shiftOptions={{@shiftOptions}}
      @offsetOptions={{@offsetOptions}}
      @strategy={{@strategy}}
      @onClose={{@onClose}}
      as |p|
    >
      <input
        value={{this.selectedText}}
        {{p.trigger}}
        {{p.anchor}}
        data-test-id="dropdown-trigger"
      />

      <p.Content
        @destinationElementId={{@destinationElementId}}
        @renderInPlace={{@renderInPlace}}
        @disableFocusTrap={{this.disableFocusTrap}}
        @blockScroll={{this.blockScroll}}
        @transitionDuration={{@transitionDuration}}
        @backdrop={{@backdrop}}
        @disableTransitions={{@disableTransitions}}
        @focusTrapOptions={{@focusTrapOptions}}
        @closeOnOutsideClick={{@closeOnOutsideClick}}
        @closeOnEscapeKey={{@closeOnEscapeKey}}
        @backdropTransition={{@backdropTransition}}
        @transition={{@transition}}
      >
        {{#if (has-block "item")}}
          <Listbox
            @items={{@items}}
            @allowEmpty={{@allowEmpty}}
            @appearance={{@appearance}}
            @disabledKeys={{@disabledKeys}}
            @intent={{@intent}}
            @isKeyboardEventsEnabled={{true}}
            @onAction={{this.onAction}}
            @onSelectionChange={{@onSelectionChange}}
            @selectedKeys={{@selectedKeys}}
            @selectionMode={{if @selectionMode @selectionMode "single"}}
            @type="menu"
            ...attributes
          >
            <:item as |options|>
              {{yield options to="item"}}
            </:item>
          </Listbox>
        {{else}}
          <Listbox
            @items={{@items}}
            @allowEmpty={{@allowEmpty}}
            @appearance={{@appearance}}
            @disabledKeys={{@disabledKeys}}
            @intent={{@intent}}
            @isKeyboardEventsEnabled={{true}}
            @onAction={{this.onAction}}
            @onSelectionChange={{@onSelectionChange}}
            @selectedKeys={{@selectedKeys}}
            @selectionMode={{if @selectionMode @selectionMode "single"}}
            @type="menu"
            ...attributes
            as |l|
          >
            {{yield (hash Item=(component l.Item)) to="default"}}
          </Listbox>
        {{/if}}
      </p.Content>

    </Popover>
  </template>
}

export { FormFieldSelect, type FormFieldSelectSignature };
export default FormFieldSelect;
