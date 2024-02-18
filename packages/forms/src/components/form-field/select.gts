import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import {
  NativeSelect,
  Listbox,
  type ListboxSignature,
  type ListItemNode
} from '@frontile/collections';
import { useStyles } from '@frontile/theme';
import { VisuallyHidden } from '@frontile/utilities';
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
  selectionMode?: 'single' | 'multiple';

  /**
   * Whether the select should close upon selecting an item.
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
  Element: HTMLUListElement | HTMLSelectElement;
  Blocks: ListboxSignature['Blocks'];
}

class FormFieldSelect extends Component<FormFieldSelectSignature> {
  @tracked nodes: ListItemNode[] = [];

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

  onItemsChange = (nodes: ListItemNode[], _: 'add' | 'remove') => {
    this.nodes = nodes;
  };

  get selectedTextValue(): string {
    let selectedTextValues: string[] = [];
    for (let node of this.nodes) {
      if (this.args.selectedKeys?.includes(node.key)) {
        selectedTextValues.push(node.textValue);
      }
    }
    return selectedTextValues.join(', ');
  }

  get backdrop() {
    if (typeof this.args.backdrop === 'undefined') {
      return 'transparent';
    }
    return this.args.backdrop;
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
      <VisuallyHidden>
        <NativeSelect
          @items={{@items}}
          @allowEmpty={{@allowEmpty}}
          @disabledKeys={{@disabledKeys}}
          @onSelectionChange={{@onSelectionChange}}
          @selectedKeys={{@selectedKeys}}
          @selectionMode={{if @selectionMode @selectionMode "single"}}
          @onItemsChange={{this.onItemsChange}}
          ...attributes
        >
          <:item as |l|>
            {{#if (has-block "item")}}
              {{yield l to="item"}}
            {{else}}
              <l.Item @key={{l.key}}>
                {{l.label}}
              </l.Item>
            {{/if}}
          </:item>
          <:default as |l|>
            {{yield l to="default"}}
          </:default>
        </NativeSelect>
      </VisuallyHidden>

      <button {{p.trigger}} {{p.anchor}} data-test-id="trigger">
        {{this.selectedTextValue}}
        BUTTON
      </button>

      <p.Content
        @destinationElementId={{@destinationElementId}}
        @renderInPlace={{@renderInPlace}}
        @disableFocusTrap={{this.disableFocusTrap}}
        @blockScroll={{this.blockScroll}}
        @transitionDuration={{@transitionDuration}}
        @backdrop={{this.backdrop}}
        @disableTransitions={{@disableTransitions}}
        @focusTrapOptions={{@focusTrapOptions}}
        @closeOnOutsideClick={{@closeOnOutsideClick}}
        @closeOnEscapeKey={{@closeOnEscapeKey}}
        @backdropTransition={{@backdropTransition}}
        @transition={{@transition}}
      >
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
          @type="listbox"
          ...attributes
        >
          <:item as |l|>
            {{#if (has-block "item")}}
              {{yield l to="item"}}
            {{else}}
              <l.Item
                @key={{l.key}}
                @appearance={{@appearance}}
                @intent={{@intent}}
              >
                {{l.label}}
              </l.Item>
            {{/if}}
          </:item>
          <:default as |l|>
            {{yield l to="default"}}
          </:default>
        </Listbox>
      </p.Content>
    </Popover>
  </template>
}

export { FormFieldSelect, type FormFieldSelectSignature };
export default FormFieldSelect;
